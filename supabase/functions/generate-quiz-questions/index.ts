// Follow this setup guide to integrate the Deno language server with your editor:
// https://deno.land/manual/getting_started/setup_your_environment
// This enables autocomplete, go to definition, etc.

// Setup type definitions for built-in Supabase Runtime APIs
import "jsr:@supabase/functions-js/edge-runtime.d.ts"
import { createClient } from 'jsr:@supabase/supabase-js@2'
import { z } from "npm:zod@3.22.4"
import { openai } from "npm:@ai-sdk/openai@0.0.66"
import { generateObject } from "npm:ai@3.4.33"

// Zod schemas for request validation
const GenerateQuizRequestSchema = z.object({
  material_id: z.string().uuid(),
  quiz_type: z.enum(['flashcard', 'multiple_choice']),
  max_questions: z.number().min(1).max(12).default(10), // Changed to max_questions with lower limit
  difficulty_level: z.enum(['easy', 'medium', 'hard']).default('medium')
});

// Response schemas for structured generation
const FlashcardSchema = z.object({
  question: z.string().min(1).max(500),
  answer: z.string().min(1).max(300) // Shorter answers for better flashcard experience
});

const MultipleChoiceSchema = z.object({
  question: z.string().min(1).max(500),
  options: z.array(z.string().min(1).max(200)).length(4),
  correct_option_index: z.number().min(0).max(3)
});

const QuizQuestionsSchema = z.object({
  optimal_count: z.number().min(1).max(12), // Let AI specify how many it thinks is optimal
  questions: z.array(z.union([
    FlashcardSchema.extend({ type: z.literal('flashcard') }),
    MultipleChoiceSchema.extend({ type: z.literal('multiple_choice') })
  ])).min(1).max(12) // Enforce the same limit on the questions array
});

// Helper function to get user from auth context
async function getAuthenticatedUser(supabase) {
  const { data: { user }, error } = await supabase.auth.getUser();
  if (error || !user) {
    throw new Error('Authentication required');
  }
  return user;
}

// Helper function to extract text from PDF using pdf-parse
async function extractTextFromPDF(pdfBuffer) {
  try {
    const { default: pdfParse } = await import("npm:pdf-parse");
    const data = await pdfParse(pdfBuffer);
    return data.text.trim();
  } catch (error) {
    console.error('Error extracting PDF text:', error);
    throw new Error('Failed to extract text from PDF file');
  }
}

// Helper function to extract text from DOCX using mammoth
async function extractTextFromDOCX(docxBuffer) {
  try {
    const { default: mammoth } = await import("npm:mammoth");
    const result = await mammoth.extractRawText({ buffer: docxBuffer });
    return result.value.trim();
  } catch (error) {
    console.error('Error extracting DOCX text:', error);
    throw new Error('Failed to extract text from DOCX file');
  }
}

// Helper function to determine file type from file path
function getFileExtension(filePath) {
  return filePath.split('.').pop()?.toLowerCase() || '';
}

// Helper function to read file content from storage
async function readFileFromStorage(supabase, filePath) {
  try {
    const { data, error } = await supabase.storage
      .from('study-materials')
      .download(filePath);

    if (error) {
      throw error;
    }

    const fileExtension = getFileExtension(filePath);
    
    // Handle PDF files specially
    if (fileExtension === 'pdf') {
      const arrayBuffer = await data.arrayBuffer();
      const buffer = new Uint8Array(arrayBuffer);
      return await extractTextFromPDF(buffer);
    }
    
    // Handle DOCX files specially
    if (fileExtension === 'docx') {
      const arrayBuffer = await data.arrayBuffer();
      const buffer = new Uint8Array(arrayBuffer);
      return await extractTextFromDOCX(buffer);
    }
    
    // For other text files (txt, md, etc.), convert blob to text
    const text = await data.text();
    return text;
  } catch (error) {
    console.error('Error reading file content:', error);
    throw new Error('Failed to read file content');
  }
}

// Helper function to determine if content type is text-based
function isTextBasedContent(contentType) {
  return contentType === 'textFile' || contentType === 'text_file';
}

// Helper function to extract content from Flutter Quill JSON
function extractTextFromQuillDelta(quillJson) {
  try {
    // Handle null or undefined input
    if (!quillJson) {
      return '';
    }
    
    // Parse JSON if it's a string
    let delta;
    if (typeof quillJson === 'string') {
      // Handle empty string
      if (quillJson.trim() === '') {
        return '';
      }
      try {
        delta = JSON.parse(quillJson);
      } catch (parseError) {
        console.warn('Failed to parse Quill JSON, treating as plain text:', parseError);
        return quillJson; // Fallback to treating as plain text
      }
    } else {
      delta = quillJson;
    }
    
    // Handle case where delta is not an object
    if (!delta || typeof delta !== 'object') {
      return String(delta || '');
    }
    
    // Handle different Quill delta formats
    let ops = delta.ops;
    
    // Some formats might have the ops nested differently
    if (!ops && delta.delta && delta.delta.ops) {
      ops = delta.delta.ops;
    }
    
    // If still no ops, try to extract from document format
    if (!ops && delta.document && delta.document.ops) {
      ops = delta.document.ops;
    }
    
    // Final fallback - if it looks like a direct ops array
    if (!ops && Array.isArray(delta)) {
      ops = delta;
    }
    
    if (!ops || !Array.isArray(ops)) {
      console.warn('No valid ops found in Quill delta, returning empty string');
      return '';
    }
    
    const textContent = ops
      .map(op => {
        if (typeof op.insert === 'string') {
          return op.insert;
        }
        // Handle embedded objects (images, etc.) - skip them
        return '';
      })
      .join('')
      .trim();
      
    return textContent;
  } catch (error) {
    console.error('Error extracting text from Quill delta:', error);
    console.error('Input was:', quillJson);
    // Final fallback - if input was a string, return it as-is
    if (typeof quillJson === 'string') {
      return quillJson;
    }
    return '';
  }
}

// Helper function to get material content
async function getMaterialContent(supabase, materialId, userId) {
  const { data, error } = await supabase
    .from('study_materials')
    .select('original_content_text, ocr_extracted_text, title, content_type, file_storage_path')
    .eq('id', materialId)
    .eq('user_id', userId)
    .single();

  if (error) {
    console.error('Error fetching material:', error);
    throw new Error('Material not found or access denied');
  }

  let textContent: string = '';

  try {
    // Handle different content types in priority order
    if (data.content_type === 'typedText' && data.original_content_text) {
      // For typed text (Quill format), extract from JSON
      textContent = extractTextFromQuillDelta(data.original_content_text);
    }
    else if (data.content_type === 'imageFile' && data.ocr_extracted_text) {
      // For images, use OCR extracted text
      textContent = data.ocr_extracted_text;
    }
    else if (isTextBasedContent(data.content_type) && data.file_storage_path) {
      // For text-based files, read the actual file content from storage
      try {
        textContent = await readFileFromStorage(supabase, data.file_storage_path);
      } catch (error) {
        console.warn('Failed to read file content, falling back to original_content_text:', error);
        textContent = data.original_content_text || '';
      }
    }
    else if (data.original_content_text) {
      // Fallback to original content text
      textContent = data.original_content_text;
    }
    
    // Additional fallback: try OCR text for any content type if nothing else worked
    if (!textContent || textContent.trim().length === 0) {
      if (data.ocr_extracted_text && data.ocr_extracted_text.trim().length > 0) {
        textContent = data.ocr_extracted_text;
      }
    }
    
  } catch (error) {
    console.error('Error extracting content:', error);
    // Final fallback to any available text
    textContent = data.original_content_text || data.ocr_extracted_text || '';
  }
  
  if (!textContent || textContent.trim().length === 0) {
    console.error('No content found for material:', {
      materialId,
      contentType: data.content_type,
      hasOriginalContent: !!data.original_content_text,
      hasOcrContent: !!data.ocr_extracted_text,
      hasFilePath: !!data.file_storage_path
    });
    throw new Error('No text content available for quiz generation');
  }

  return {
    content: textContent.trim(),
    title: data.title,
    contentType: data.content_type
  };
}

// Helper function to create generation prompt
function createGenerationPrompt(textContent, quizType, maxQuestions, difficultyLevel, title = '') {
  const titleContext = title ? `from the material titled "${title}"` : '';
  
  const difficultyInstructions = {
    easy: 'Focus on basic concepts, definitions, and simple recall questions.',
    medium: 'Include moderate complexity questions requiring understanding and application.',
    hard: 'Create challenging questions requiring analysis, synthesis, and critical thinking.'
  };

  const typeInstructions = quizType === 'flashcard' 
    ? `Analyze the content and generate the optimal number of flashcard questions (maximum ${maxQuestions}). Each flashcard should have:
       - A clear, concise question focusing on key terms, definitions, or concepts
       - A brief, focused answer (1-3 sentences maximum)
       - Prioritize term-definition pairs and essential facts
       - Keep answers under 150 words for better study efficiency
       - IMPORTANT: Each question must have "type": "flashcard"`
    : `Analyze the content and generate the optimal number of multiple choice questions (maximum ${maxQuestions}). Each question should have 4 options with only one correct answer.
       - IMPORTANT: Each question must have "type": "multiple_choice"`;

  return `You are an AI study assistant helping students create quiz questions ${titleContext} for effective learning and review.

  CRITICAL INSTRUCTIONS:
  1. MAXIMUM QUESTIONS: You MUST NOT exceed ${maxQuestions} questions under any circumstances
  2. QUALITY OVER QUANTITY: Better to have fewer excellent questions than many mediocre ones
  3. CONTENT ANALYSIS: First analyze the study material to determine how many meaningful, non-repetitive questions can be created
  4. TYPE FIELD: Each question MUST include the correct "type" field: "${quizType === 'flashcard' ? 'flashcard' : 'multiple_choice'}"

  Content Analysis Guidelines:
  - If the material has 1-3 distinct key concepts: Generate 2-4 questions
  - If the material has 4-6 distinct key concepts: Generate 4-7 questions  
  - If the material has 7+ distinct key concepts: Generate up to ${maxQuestions} questions
  - Always prioritize the most important and testable information
  - Do not create filler questions just to reach a number
  - Avoid redundant or overlapping questions

  ${typeInstructions}

  Guidelines:
  - ${difficultyInstructions[difficultyLevel]}
  - Focus on key concepts, important facts, and essential information
  - Questions should be clear, unambiguous, and educationally valuable
  - For flashcards: Prioritize key terms, definitions, formulas, and core concepts with concise answers
  - For multiple choice: Ensure incorrect options are plausible but clearly wrong
  - Avoid trick questions or overly specific details unless relevant
  - Cover different aspects of the material when possible

  RESPONSE FORMAT:
  You must return both:
  1. optimal_count: The number of questions you determined is best for this content (must be ≤ ${maxQuestions})
  2. questions: An array of exactly that many questions (must match optimal_count and be ≤ ${maxQuestions})

  ${quizType === 'flashcard' 
    ? `FLASHCARD FORMAT - Each question must be:
  {
    "question": "Your question here",
    "answer": "Your concise answer here",
    "type": "flashcard"
  }`
    : `MULTIPLE CHOICE FORMAT - Each question must be:
  {
    "question": "Your question here",
    "options": ["Option A", "Option B", "Option C", "Option D"],
    "correct_option_index": 0,
    "type": "multiple_choice"
  }`
  }

  Study material content:
  ${textContent}`;
}

Deno.serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response(null, {
      status: 200,
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'POST, OPTIONS',
        'Access-Control-Allow-Headers': 'authorization, content-type',
      },
    });
  }

  try {
    // Initialize Supabase client
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      {
        global: {
          headers: {
            Authorization: req.headers.get('Authorization') ?? '',
          },
        },
      }
    );

    // Authenticate user
    const user = await getAuthenticatedUser(supabase);

    // Parse and validate request body
    const body = await req.json();
    const validatedRequest = GenerateQuizRequestSchema.parse(body);

    // Get material content
    const materialData = await getMaterialContent(
      supabase,
      validatedRequest.material_id,
      user.id
    );

    // Check if content is sufficient for question generation
    if (materialData.content.length < 50) {
      throw new Error('Study material content is too short to generate meaningful questions');
    }

    // Truncate content if too long (to avoid token limits)
    const maxContentLength = 8000;
    const truncatedContent = materialData.content.length > maxContentLength
      ? materialData.content.substring(0, maxContentLength) + '...'
      : materialData.content;

    // Generate questions using AI - let AI decide optimal count
    const prompt = createGenerationPrompt(
      truncatedContent,
      validatedRequest.quiz_type,
      validatedRequest.max_questions, // Use max_questions instead of num_questions
      validatedRequest.difficulty_level,
      materialData.title
    );

    // Initialize OpenAI client
    const model = openai('gpt-4o-mini');

    // Generate structured questions
    const result = await generateObject({
      model,
      schema: QuizQuestionsSchema,
      prompt,
      temperature: 0.7,
    });

    console.log('✅ AI Response received:', JSON.stringify(result.object, null, 2));

    // CRITICAL: Enforce maximum limit even if AI tries to exceed it
    const actualCount = Math.min(result.object.questions.length, validatedRequest.max_questions);
    const finalQuestions = result.object.questions.slice(0, actualCount);
    
    // Also validate that optimal_count doesn't exceed our limit
    const reportedOptimalCount = Math.min(result.object.optimal_count, validatedRequest.max_questions);

    console.log(`📊 Processing ${finalQuestions.length} questions (optimal: ${reportedOptimalCount}, max: ${validatedRequest.max_questions})`);

    // CRITICAL: Ensure all questions have the correct type field (fix AI inconsistencies)
    const correctedQuestions = finalQuestions.map((question, index) => {
      const correctedQuestion = {
        ...question,
        type: validatedRequest.quiz_type === 'flashcard' ? 'flashcard' : 'multiple_choice'
      };
      
      // Log any type corrections
      if (question.type !== correctedQuestion.type) {
        console.log(`🔧 Fixed question ${index + 1} type: "${question.type}" → "${correctedQuestion.type}"`);
      }
      
      return correctedQuestion;
    });

    // Validate and format the generated questions
    const formattedQuestions = correctedQuestions.map((question, index) => ({
      id: `generated_${Date.now()}_${index}`,
      ...question,
      type: validatedRequest.quiz_type === 'flashcard' ? 'flashcard' : 'multiple_choice'
    }));

    return new Response(
      JSON.stringify({
        success: true,
        questions: formattedQuestions,
        material_title: materialData.title,
        generated_count: formattedQuestions.length,
        optimal_count: reportedOptimalCount, // Include AI's reasoning
        max_requested: validatedRequest.max_questions
      }),
      {
        status: 200,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        },
      }
    );

  } catch (error) {
    console.error('Quiz generation error:', error);
    const errorMessage = error instanceof Error ? error.message : 'Unknown error';
    
    return new Response(
      JSON.stringify({
        success: false,
        error: 'Failed to generate quiz questions',
        message: errorMessage,
      }),
      {
        status: 400,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        },
      }
    );
  }
})

/* To invoke locally:

  1. Run `supabase start` (see: https://supabase.com/docs/reference/cli/supabase-start)
  2. Make an HTTP request:

  # Generate flashcard questions with AI-determined count:
  curl -i --location --request POST 'http://127.0.0.1:54321/functions/v1/generate-quiz-questions' \
    --header 'Authorization: Bearer [YOUR_JWT_TOKEN]' \
    --header 'Content-Type: application/json' \
    --data '{"material_id":"your-material-uuid-here","quiz_type":"flashcard","max_questions":10,"difficulty_level":"medium"}'

  # Generate multiple choice questions with AI-determined count:
  curl -i --location --request POST 'http://127.0.0.1:54321/functions/v1/generate-quiz-questions' \
    --header 'Authorization: Bearer [YOUR_JWT_TOKEN]' \
    --header 'Content-Type: application/json' \
    --data '{"material_id":"your-material-uuid-here","quiz_type":"multiple_choice","max_questions":8,"difficulty_level":"hard"}'

*/

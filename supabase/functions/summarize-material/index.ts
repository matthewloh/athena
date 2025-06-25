import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";
import { openai } from "npm:@ai-sdk/openai";
import { generateText } from "npm:ai";
import { z } from "npm:zod";

// Zod schemas for request validation
const SummarizeRequestSchema = z.object({
  material_id: z.string().uuid().optional(),
  text_to_summarize: z.string().min(1).max(10000).optional(),
  summary_length: z.enum(['brief', 'detailed']).default('brief')
}).refine(
  data => data.material_id || data.text_to_summarize,
  { message: "Either material_id or text_to_summarize must be provided" }
);

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
    // Import pdf-parse dynamically
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
    // Import mammoth dynamically
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
      console.error('Error downloading file:', error);
      throw new Error('Failed to download file from storage');
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
      return await extractTextFromDOCX(arrayBuffer);
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
  // Based on the database enum: 'typedText', 'textFile', 'imageFile'
  return contentType === 'textFile';
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

  let textContent: string;

  // For images, prefer OCR extracted text
  if (data.ocr_extracted_text && data.ocr_extracted_text.trim().length > 0) {
    textContent = data.ocr_extracted_text;
  }
  // For text-based files, read the actual file content from storage
  else if (isTextBasedContent(data.content_type) && data.file_storage_path) {
    try {
      textContent = await readFileFromStorage(supabase, data.file_storage_path);
    } catch (error) {
      // Fallback to original_content_text if file reading fails
      console.warn('Failed to read file from storage, falling back to original_content_text:', error);
      textContent = data.original_content_text;
    }
  }
  // Fallback to original content text
  else {
    textContent = data.original_content_text;
  }
  
  if (!textContent || textContent.trim().length === 0) {
    throw new Error('No text content available for summarization');
  }

  return {
    content: textContent,
    title: data.title,
    contentType: data.content_type
  };
}

// Helper function to generate summary prompt
function createSummaryPrompt(textContent, summaryLength, title = '') {
  const lengthInstructions = summaryLength === 'detailed' 
    ? 'Provide a comprehensive summary that covers all major points and key details.'
    : 'Provide a concise summary highlighting only the most important points.';

  const titleContext = title ? `for the material titled "${title}"` : '';

  return `You are an AI study assistant helping students understand their academic materials. 
Please create a well-structured summary ${titleContext} that will help with studying and review.

${lengthInstructions}

Guidelines:
- Focus on key concepts, definitions, and main ideas
- Use clear, student-friendly language
- Organize information logically with bullet points or numbered lists when appropriate
- Highlight important facts, formulas, or principles
- Include any critical examples or case studies mentioned
- End with a complete sentence or thought
- If space is limited, prioritize the most important information and conclude naturally

Text to summarize:
${textContent}`;
}

// Helper function to save summary to database
async function saveSummary(supabase, materialId, summaryText) {
  const { error } = await supabase
    .from('study_materials')
    .update({ 
      summary_text: summaryText,
      updated_at: new Date().toISOString()
    })
    .eq('id', materialId);

  if (error) {
    console.error('Error saving summary:', error);
    throw new Error('Failed to save summary to database');
  }
}

Deno.serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response(null, {
      status: 200,
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'POST, OPTIONS',
        'Access-Control-Allow-Headers': 'authorization, content-type'
      }
    });
  }

  try {
    // Initialize Supabase client with auth context
    const supabase = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_ANON_KEY") ?? "",
      {
        global: {
          headers: {
            Authorization: req.headers.get("Authorization")
          }
        }
      }
    );

    // Verify authentication
    const user = await getAuthenticatedUser(supabase);

    // Parse and validate request body
    const body = await req.json();
    const validatedRequest = SummarizeRequestSchema.parse(body);

    let textToSummarize: string;
    let materialTitle = '';
    let materialId: string | null = null;

    // Get text content based on request type
    if (validatedRequest.material_id) {
      materialId = validatedRequest.material_id;
      const materialData = await getMaterialContent(supabase, materialId, user.id);
      textToSummarize = materialData.content;
      materialTitle = materialData.title;
    } else {
      textToSummarize = validatedRequest.text_to_summarize!;
    }

    // Intelligently truncate text if too long (to stay within token limits)
    const maxTextLength = validatedRequest.summary_length === 'detailed' ? 8000 : 5000;
    if (textToSummarize.length > maxTextLength) {
      // Try to truncate at a sentence boundary for better context
      const truncated = textToSummarize.substring(0, maxTextLength);
      const lastSentenceEnd = Math.max(
        truncated.lastIndexOf('.'),
        truncated.lastIndexOf('!'),
        truncated.lastIndexOf('?')
      );
      
      if (lastSentenceEnd > maxTextLength * 0.8) {
        // If we found a sentence boundary in the last 20% of the text, use it
        textToSummarize = truncated.substring(0, lastSentenceEnd + 1);
      } else {
        // Otherwise, just truncate and add ellipsis
        textToSummarize = truncated + '...';
      }
    }

    // Initialize OpenAI client
    const model = openai('gpt-4o-mini', {
      apiKey: Deno.env.get('OPENAI_API_KEY')
    });

    // Generate summary using AI with improved token handling
    const prompt = createSummaryPrompt(textToSummarize, validatedRequest.summary_length, materialTitle);
    
    // Set token limits with buffer for completion
    const maxTokens = validatedRequest.summary_length === 'detailed' ? 1200 : 600;
    
    const result = await generateText({
      model,
      prompt,
      temperature: 0.3, // Lower temperature for more consistent summaries
      maxTokens,
      // Add stop sequences to ensure proper completion
      stop: ['\n\n---', '\n\nNote:', '\n\nDisclaimer:']
    });

    let summaryText = result.text;
    
    // Enhanced detection for abruptly cut off summaries
    const trimmedSummary = summaryText.trim();
    let isIncomplete = false;
    
    // Check multiple indicators of incomplete summaries
    const lastChar = trimmedSummary.slice(-1);
    const lastTwoChars = trimmedSummary.slice(-2);
    const lastSentence = trimmedSummary.split(/[.!?]/).pop()?.trim() || '';
    
    // Detect various forms of incomplete summaries
    isIncomplete = (
      // Doesn't end with proper punctuation
      !['.', '!', '?', ':', ')'].includes(lastChar) ||
      // Last sentence is suspiciously long (likely cut off mid-sentence)
      lastSentence.length > 60 ||
      // Ends with common incomplete patterns
      /\b(and|or|but|however|therefore|additionally|furthermore|moreover|in|on|at|for|with|by|the|a|an|to|of|as|is|are|was|were|will|would|could|should|may|might)$/i.test(trimmedSummary) ||
      // Ends with incomplete phrases
      /\b(such as|including|for example|e\.g\.|i\.e\.|that is|namely|specifically|particularly|especially)$/i.test(trimmedSummary) ||
      // Ends with numbers or lists that seem incomplete
      /\d+\.\s*$/.test(trimmedSummary) ||
      // Ends with incomplete bullet points
      /[-•*]\s*$/.test(trimmedSummary)
    );
    
    if (isIncomplete) {
      // Find the last complete sentence more reliably
      const sentences = trimmedSummary.split(/([.!?]+\s*)/);
      let completeText = '';
      
      for (let i = 0; i < sentences.length - 1; i += 2) {
        const sentence = sentences[i]?.trim();
        const punctuation = sentences[i + 1]?.trim();
        
        if (sentence && punctuation && sentence.length > 10) {
          completeText += sentence + punctuation + ' ';
        }
      }
      
      // If we have substantial complete content, use it
      if (completeText.trim().length > 50) {
        summaryText = completeText.trim() + '\n\n[Summary continues with additional key points from the material]';
      } else {
        // If even that's too short, try to salvage what we can
        const words = trimmedSummary.split(' ');
        if (words.length > 20) {
          // Take most words but ensure it ends reasonably
          const cutoffPoint = Math.max(10, words.length - 5);
          summaryText = words.slice(0, cutoffPoint).join(' ') + '.\n\n[Summary continues with additional key points from the material]';
        }
      }
    }
    
    // Save summary to database if material_id was provided
    if (materialId) {
      await saveSummary(supabase, materialId, summaryText);
    }

    // Determine if summary was truncated
    const wasTruncated = summaryText.includes('[Summary continues with additional key points');

    // Return successful response
    return new Response(
      JSON.stringify({
        success: true,
        summary: summaryText,
        material_id: materialId,
        summary_length: validatedRequest.summary_length,
        was_truncated: wasTruncated,
        generated_at: new Date().toISOString(),
        ...(wasTruncated && {
          message: "Summary was truncated due to length. Consider using 'brief' summary for shorter content or splitting large documents."
        })
      }),
      {
        status: 200,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'POST, OPTIONS',
          'Access-Control-Allow-Headers': 'authorization, content-type'
        }
      }
    );

  } catch (error) {
    console.error('Summarization error:', error);
    
    // Handle specific error types
    let statusCode = 500;
    let errorMessage = 'Internal server error';

    if (error instanceof z.ZodError) {
      statusCode = 400;
      errorMessage = 'Invalid request format';
    } else if (error.message.includes('Authentication required')) {
      statusCode = 401;
      errorMessage = 'Authentication required';
    } else if (error.message.includes('Material not found')) {
      statusCode = 404;
      errorMessage = 'Material not found or access denied';
    } else if (error.message.includes('No text content')) {
      statusCode = 400;
      errorMessage = 'No text content available for summarization';
    }

    return new Response(
      JSON.stringify({
        success: false,
        error: errorMessage,
        details: error instanceof Error ? error.message : 'Unknown error'
      }),
      {
        status: statusCode,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*'
        }
      }
    );
  }
});

/* To invoke locally:

  1. Run `supabase start` (see: https://supabase.com/docs/reference/cli/supabase-start)
  2. Make an HTTP request:

  # Summarize by material_id:
  curl -i --location --request POST 'http://127.0.0.1:54321/functions/v1/summarize-material' \
    --header 'Authorization: Bearer [YOUR_JWT_TOKEN]' \
    --header 'Content-Type: application/json' \
    --data '{"material_id":"your-material-uuid-here","summary_length":"brief"}'

  # Summarize direct text:
  curl -i --location --request POST 'http://127.0.0.1:54321/functions/v1/summarize-material' \
    --header 'Authorization: Bearer [YOUR_JWT_TOKEN]' \
    --header 'Content-Type: application/json' \
    --data '{"text_to_summarize":"Your text content here...","summary_length":"detailed"}'

*/

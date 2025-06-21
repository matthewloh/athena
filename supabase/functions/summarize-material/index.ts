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

// Helper function to get material content
async function getMaterialContent(supabase, materialId, userId) {
  const { data, error } = await supabase
    .from('study_materials')
    .select('original_content_text, ocr_extracted_text, title, content_type')
    .eq('id', materialId)
    .eq('user_id', userId)
    .single();

  if (error) {
    console.error('Error fetching material:', error);
    throw new Error('Material not found or access denied');
  }

  // Prefer OCR extracted text if available, otherwise use original content
  const textContent = data.ocr_extracted_text || data.original_content_text;
  
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

    // Truncate text if too long (to stay within token limits)
    const maxTextLength = 5000;
    if (textToSummarize.length > maxTextLength) {
      textToSummarize = textToSummarize.substring(0, maxTextLength) + '...';
    }

    // Initialize OpenAI client
    const model = openai('gpt-4o-mini', {
      apiKey: Deno.env.get('OPENAI_API_KEY')
    });

    // Generate summary using AI
    const prompt = createSummaryPrompt(textToSummarize, validatedRequest.summary_length, materialTitle);
    
    const result = await generateText({
      model,
      prompt,
      temperature: 0.3, // Lower temperature for more consistent summaries
      maxTokens: validatedRequest.summary_length === 'detailed' ? 800 : 400
    });

    const summaryText = result.text;

    // Save summary to database if material_id was provided
    if (materialId) {
      await saveSummary(supabase, materialId, summaryText);
    }

    // Return successful response
    return new Response(
      JSON.stringify({
        success: true,
        summary: summaryText,
        material_id: materialId,
        summary_length: validatedRequest.summary_length,
        generated_at: new Date().toISOString()
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

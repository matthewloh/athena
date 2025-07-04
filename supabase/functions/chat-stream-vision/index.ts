import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient, SupabaseClient } from "jsr:@supabase/supabase-js@2";
import { openai } from "npm:@ai-sdk/openai";
import { google } from "npm:@ai-sdk/google";
import { CoreMessage, streamText } from "npm:ai";
import { z } from "npm:zod";

// Enhanced request schema with image support
const ChatRequestSchema = z.object({
  conversationId: z.string().uuid(),
  message: z.string().min(1).max(4000),
  imageUrls: z.array(z.string().url()).optional(),
  includeContext: z.boolean().default(true),
  maxContextMessages: z.number().min(1).max(20).default(10),
});

// Enhanced system prompt for vision capabilities
const SYSTEM_PROMPT = `You are Athena, an AI-powered study companion with advanced vision capabilities. Your enhanced principles:

1. **Educational Focus**: Prioritize learning and understanding over just providing answers
2. **Visual Analysis**: When images are provided, analyze them thoroughly to help with:
   - Mathematical equations and problem-solving
   - Scientific diagrams and concepts
   - Handwritten notes transcription and explanation
   - Textbook pages and academic materials
   - Graphs, charts, and data visualization
3. **Encouraging Tone**: Be supportive, patient, and motivating
4. **Clear Explanations**: Break down complex visual concepts into digestible parts
5. **Academic Integrity**: Guide students to understand concepts rather than just giving answers

For image analysis:
- Describe what you see in the image clearly
- Extract text if present and explain its significance
- Identify mathematical formulas, diagrams, or scientific concepts
- Provide step-by-step explanations for problems shown
- Connect visual information to relevant academic concepts
- Suggest follow-up questions or related topics

Always maintain a helpful, encouraging, and educational tone while leveraging your visual understanding.`;

// Helper function to save message with images to database
async function saveMessage(
  supabase: SupabaseClient,
  conversationId: string,
  sender: string,
  content: string,
  imageUrls?: string[],
) {
  const { error } = await supabase.from("chat_messages").insert({
    conversation_id: conversationId,
    sender,
    content,
    has_attachments: imageUrls && imageUrls.length > 0,
    metadata: imageUrls ? { imageUrls } : null,
  });

  if (error) {
    console.error("Error saving message:", error);
    throw new Error("Failed to save message");
  }
}

// Helper function to get conversation context with images
async function getConversationContext(
  supabase: SupabaseClient,
  conversationId: string,
  maxMessages: number,
): Promise<CoreMessage[]> {
  const { data, error } = await supabase
    .from("chat_messages")
    .select("sender, content, metadata")
    .eq("conversation_id", conversationId)
    .order("timestamp", { ascending: false })
    .limit(maxMessages);

  if (error) {
    console.error("Error fetching context:", error);
    return [];
  }

  return data.reverse().map((msg) => {
    const content: any = [{ type: "text", text: msg.content }];
    
    // Add images if present in metadata
    if (msg.metadata?.imageUrls) {
      msg.metadata.imageUrls.forEach((url: string) => {
        content.push({ type: "image", image: url });
      });
    }

    return {
      role: msg.sender === "user" ? "user" : "assistant",
      content,
    };
  });
}

Deno.serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === "OPTIONS") {
    return new Response(null, {
      status: 200,
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "POST, OPTIONS",
        "Access-Control-Allow-Headers": "authorization, content-type",
      },
    });
  }

  try {
    // Initialize Supabase client
    const supabase = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_ANON_KEY") ?? "",
      {
        global: {
          headers: {
            Authorization: req.headers.get("Authorization") ?? "",
          },
        },
      },
    );

    // Parse and validate request body
    const body = await req.json();
    const validatedRequest = ChatRequestSchema.parse(body);

    // Save user message with images
    await saveMessage(
      supabase,
      validatedRequest.conversationId,
      "user",
      validatedRequest.message,
      validatedRequest.imageUrls,
    );

    // Get conversation context
    const contextMessages = validatedRequest.includeContext
      ? await getConversationContext(
          supabase,
          validatedRequest.conversationId,
          validatedRequest.maxContextMessages,
        )
      : [];

    // Prepare current message content
    const currentContent: any = [{ type: "text", text: validatedRequest.message }];
    
    // Add images to current message if provided
    if (validatedRequest.imageUrls && validatedRequest.imageUrls.length > 0) {
      validatedRequest.imageUrls.forEach((url) => {
        currentContent.push({ type: "image", image: url });
      });
    }

    // Prepare messages for AI
    const messages: CoreMessage[] = [
      { role: "system", content: SYSTEM_PROMPT },
      ...contextMessages,
      { role: "user", content: currentContent },
    ];

    // Choose model based on whether images are present
    const hasImages = validatedRequest.imageUrls && validatedRequest.imageUrls.length > 0;
    const model = hasImages 
      ? openai("gpt-4-vision-preview") // or google("gemini-pro-vision")
      : openai("gpt-4o-mini");

    // Stream the AI response
    const result = await streamText({
      model,
      messages,
      temperature: 0.7,
      maxTokens: hasImages ? 1500 : 1000, // More tokens for image analysis
    });

    // Create a readable stream for the response
    const stream = new ReadableStream({
      async start(controller) {
        try {
          let fullResponse = "";
          for await (const delta of result.textStream) {
            fullResponse += delta;
            const chunk = `data: ${JSON.stringify({
              type: "chunk",
              content: delta,
            })}\n\n`;
            controller.enqueue(new TextEncoder().encode(chunk));
          }

          // Save the complete AI response to database
          await saveMessage(
            supabase,
            validatedRequest.conversationId,
            "ai",
            fullResponse,
          );

          // Send completion signal
          const completionChunk = `data: ${JSON.stringify({
            type: "complete",
            fullResponse,
          })}\n\n`;
          controller.enqueue(new TextEncoder().encode(completionChunk));
          controller.close();
        } catch (error) {
          console.error("Streaming error:", error);
          const errorMessage = error instanceof Error ? error.message : "Unknown error";
          const errorChunk = `data: ${JSON.stringify({
            type: "error",
            error: errorMessage,
          })}\n\n`;
          controller.enqueue(new TextEncoder().encode(errorChunk));
          controller.close();
        }
      },
    });

    return new Response(stream, {
      headers: {
        "Content-Type": "text/event-stream",
        "Cache-Control": "no-cache",
        "Connection": "keep-alive",
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "POST, OPTIONS",
        "Access-Control-Allow-Headers": "authorization, content-type",
      },
    });
  } catch (error) {
    console.error("Vision chat error:", error);
    const errorMessage = error instanceof Error ? error.message : "Unknown error";
    return new Response(
      JSON.stringify({
        error: "Internal server error",
        message: errorMessage,
      }),
      {
        status: 500,
        headers: {
          "Content-Type": "application/json",
        },
      },
    );
  }
}); 
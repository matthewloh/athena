import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient, SupabaseClient } from "jsr:@supabase/supabase-js@2";
import { openai } from "npm:@ai-sdk/openai";
import { CoreMessage, streamText } from "npm:ai";
import { z } from "npm:zod";
// Zod schemas for request validation
const ChatRequestSchema = z.object({
  conversationId: z.string().uuid(),
  message: z.string().min(1).max(4000),
  includeContext: z.boolean().default(true),
  maxContextMessages: z.number().min(1).max(20).default(10),
});
// System prompt with academic focus
const SYSTEM_PROMPT =
  `You are Athena, an AI-powered study companion designed to help students learn effectively. Your core principles:

1. **Educational Focus**: Prioritize learning and understanding over just providing answers
2. **Encouraging Tone**: Be supportive, patient, and motivating
3. **Clear Explanations**: Break down complex concepts into digestible parts
4. **Academic Integrity**: Guide students to understand concepts rather than just giving homework answers
5. **Adaptive Communication**: Adjust your explanation level based on the student's apparent understanding

When helping with homework:
- Provide step-by-step guidance rather than direct answers
- Ask clarifying questions to ensure understanding
- Suggest additional practice or resources when appropriate

When explaining concepts:
- Use analogies and examples relevant to students
- Provide multiple perspectives or approaches
- Connect new information to previously learned concepts

Always maintain a helpful, encouraging, and educational tone.`;
// Helper function to save message to database
async function saveMessage(
  supabase: SupabaseClient,
  conversationId: string,
  sender: string,
  content: string,
) {
  const { error } = await supabase.from("chat_messages").insert({
    conversation_id: conversationId,
    sender,
    content,
  });
  if (error) {
    console.error("Error saving message:", error);
    throw new Error("Failed to save message");
  }
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
    // Save user message first
    await saveMessage(
      supabase,
      validatedRequest.conversationId,
      "user",
      validatedRequest.message,
    );
    // Prepare messages for AI
    const messages = [
      {
        role: "system",
        content: SYSTEM_PROMPT,
      },
      {
        role: "user",
        content: validatedRequest.message,
      },
    ];
    // Initialize OpenAI client
    const model = openai("gpt-4o-mini", {
      apiKey: Deno.env.get("OPENAI_API_KEY"),
    });
    // Stream the AI response
    const result = await streamText({
      model,
      messages: messages as CoreMessage[],
      temperature: 0.7,
      maxTokens: 1000,
    });
    // Create a readable stream for the response
    const stream = new ReadableStream({
      async start(controller) {
        try {
          let fullResponse = "";
          for await (const delta of result.textStream) {
            fullResponse += delta;
            const chunk = `data: ${
              JSON.stringify({
                type: "chunk",
                content: delta,
              })
            }\n\n`;
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
          const completionChunk = `data: ${
            JSON.stringify({
              type: "complete",
              fullResponse,
            })
          }\n\n`;
          controller.enqueue(new TextEncoder().encode(completionChunk));
          controller.close();
        } catch (error) {
          console.error("Streaming error:", error);
          const errorMessage = error instanceof Error
            ? error.message
            : "Unknown error";
          const errorChunk = `data: ${
            JSON.stringify({
              type: "error",
              error: errorMessage,
            })
          }\n\n`;
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
    console.error("Chat stream error:", error);
    const errorMessage = error instanceof Error
      ? error.message
      : "Unknown error";
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

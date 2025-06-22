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
<<<<<<< HEAD

const MessageSchema = z.object({
  id: z.string(),
  sender: z.enum(["user", "ai", "system"]),
  content: z.string(),
  timestamp: z.string(),
});

type ChatRequest = z.infer<typeof ChatRequestSchema>;
type Message = z.infer<typeof MessageSchema>;

=======
>>>>>>> 5c773fd1b1b3cf86226be86f597a1f7c26919e81
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
<<<<<<< HEAD

// Helper function to get conversation context
async function getConversationContext(
  supabase: any,
  conversationId: string,
  maxMessages: number = 10,
): Promise<CoreMessage[]> {
  const { data: messages, error } = await supabase
    .from("chat_messages")
    .select("sender, content, timestamp")
    .eq("conversation_id", conversationId)
    .order("timestamp", { ascending: false })
    .limit(maxMessages);

  if (error) {
    console.error("Error fetching conversation context:", error);
    return [];
  }

  // Convert to CoreMessage format and reverse to get chronological order
  return messages
    .reverse()
    .map((msg: any): CoreMessage => ({
      role: msg.sender === "user" ? "user" : "assistant",
      content: msg.content,
    }));
}

=======
>>>>>>> 5c773fd1b1b3cf86226be86f597a1f7c26919e81
// Helper function to save message to database
async function saveMessage(
  supabase: SupabaseClient,
  conversationId: string,
<<<<<<< HEAD
  sender: "user" | "ai",
  content: string,
): Promise<void> {
  const { error } = await supabase
    .from("chat_messages")
    .insert({
      conversation_id: conversationId,
      sender,
      content,
    });

=======
  sender: string,
  content: string,
) {
  const { error } = await supabase.from("chat_messages").insert({
    conversation_id: conversationId,
    sender,
    content,
  });
>>>>>>> 5c773fd1b1b3cf86226be86f597a1f7c26919e81
  if (error) {
    console.error("Error saving message:", error);
    throw new Error("Failed to save message");
  }
}
<<<<<<< HEAD

// Helper function to ensure conversation exists
async function ensureConversationExists(
  supabase: any,
  conversationId: string,
  userId: string,
): Promise<boolean> {
  const { data, error } = await supabase
    .from("conversations")
    .select("id")
    .eq("id", conversationId)
    .eq("user_id", userId)
    .single();

  if (error && error.code !== "PGRST116") { // PGRST116 is "not found"
    console.error("Error checking conversation:", error);
    return false;
  }

  return !!data;
}

=======
>>>>>>> 5c773fd1b1b3cf86226be86f597a1f7c26919e81
Deno.serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === "OPTIONS") {
    return new Response(null, {
      status: 200,
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "POST, OPTIONS",
<<<<<<< HEAD
        "Access-Control-Allow-Headers":
          "authorization, x-client-info, apikey, content-type",
=======
        "Access-Control-Allow-Headers": "authorization, content-type",
>>>>>>> 5c773fd1b1b3cf86226be86f597a1f7c26919e81
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
<<<<<<< HEAD

    // Get user from auth
    const { data: { user }, error: authError } = await supabase.auth.getUser();
    if (authError || !user) {
      return new Response(
        JSON.stringify({ error: "Unauthorized" }),
        {
          status: 401,
          headers: { "Content-Type": "application/json" },
        },
      );
    }

    // Parse and validate request body
    const body = await req.json();
    const validatedRequest = ChatRequestSchema.parse(body);

    // Ensure conversation exists and belongs to user
    const conversationExists = await ensureConversationExists(
      supabase,
      validatedRequest.conversationId,
      user.id,
    );

    if (!conversationExists) {
      return new Response(
        JSON.stringify({ error: "Conversation not found or access denied" }),
        {
          status: 404,
          headers: { "Content-Type": "application/json" },
        },
      );
    }

=======
    // Parse and validate request body
    const body = await req.json();
    const validatedRequest = ChatRequestSchema.parse(body);
>>>>>>> 5c773fd1b1b3cf86226be86f597a1f7c26919e81
    // Save user message first
    await saveMessage(
      supabase,
      validatedRequest.conversationId,
      "user",
      validatedRequest.message,
    );
<<<<<<< HEAD

    // Get conversation context if requested
    let messages: CoreMessage[] = [
      { role: "system", content: SYSTEM_PROMPT },
    ];

    if (validatedRequest.includeContext) {
      const contextMessages = await getConversationContext(
        supabase,
        validatedRequest.conversationId,
        validatedRequest.maxContextMessages,
      );
      messages.push(...contextMessages);
    }

    // Add the current user message
    messages.push({
      role: "user",
      content: validatedRequest.message,
    });

    // Initialize OpenAI client correctly
    const model = openai("gpt-4o");

=======
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
>>>>>>> 5c773fd1b1b3cf86226be86f597a1f7c26919e81
    // Stream the AI response
    const result = await streamText({
      model,
      messages: messages as CoreMessage[],
      temperature: 0.7,
      maxTokens: 1000,
    });
    // Create a readable stream for the response
<<<<<<< HEAD
    let fullResponse = "";
=======
>>>>>>> 5c773fd1b1b3cf86226be86f597a1f7c26919e81
    const stream = new ReadableStream({
      async start(controller) {
        try {
          let fullResponse = "";
          for await (const delta of result.textStream) {
            fullResponse += delta;
<<<<<<< HEAD

            // Send each chunk as Server-Sent Events format
=======
>>>>>>> 5c773fd1b1b3cf86226be86f597a1f7c26919e81
            const chunk = `data: ${
              JSON.stringify({
                type: "chunk",
                content: delta,
              })
            }\n\n`;
<<<<<<< HEAD

=======
>>>>>>> 5c773fd1b1b3cf86226be86f597a1f7c26919e81
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
<<<<<<< HEAD

=======
>>>>>>> 5c773fd1b1b3cf86226be86f597a1f7c26919e81
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
<<<<<<< HEAD
        "Access-Control-Allow-Headers":
          "authorization, x-client-info, apikey, content-type",
=======
        "Access-Control-Allow-Headers": "authorization, content-type",
>>>>>>> 5c773fd1b1b3cf86226be86f597a1f7c26919e81
      },
    });
  } catch (error) {
    console.error("Chat stream error:", error);
<<<<<<< HEAD

    if (error instanceof z.ZodError) {
      return new Response(
        JSON.stringify({
          error: "Invalid request format",
          details: error.errors,
        }),
        {
          status: 400,
          headers: { "Content-Type": "application/json" },
        },
      );
    }

=======
>>>>>>> 5c773fd1b1b3cf86226be86f597a1f7c26919e81
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
<<<<<<< HEAD
        headers: { "Content-Type": "application/json" },
=======
        headers: {
          "Content-Type": "application/json",
        },
>>>>>>> 5c773fd1b1b3cf86226be86f597a1f7c26919e81
      },
    );
  }
});
<<<<<<< HEAD

/* To invoke locally:

  1. Run `supabase start`
  2. Set environment variables:
     - OPENAI_API_KEY=your_openai_api_key
  3. Make an HTTP request:

  curl -i --location --request POST 'http://127.0.0.1:54321/functions/v1/chat-stream' \
    --header 'Authorization: Bearer [YOUR_SUPABASE_JWT_TOKEN]' \
    --header 'Content-Type: application/json' \
    --data '{
      "conversationId": "uuid-here",
      "message": "Explain photosynthesis",
      "includeContext": true,
      "maxContextMessages": 5
    }'

*/
=======
>>>>>>> 5c773fd1b1b3cf86226be86f597a1f7c26919e81

import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient, SupabaseClient } from "jsr:@supabase/supabase-js@2";
import { openai } from "npm:@ai-sdk/openai";
import { CoreMessage, streamText, tool } from "npm:ai";
import { z } from "npm:zod";

// Request schema for tool-enhanced chat
const ChatRequestSchema = z.object({
  conversationId: z.string().uuid(),
  message: z.string().min(1).max(4000),
  imageUrls: z.array(z.string().url()).optional(),
  includeContext: z.boolean().default(true),
  maxContextMessages: z.number().min(1).max(20).default(10),
  enableTools: z.boolean().default(true),
});

// Wikipedia API tool
const wikipediaTool = tool({
  description: "Search Wikipedia for academic information on any topic. Use this when students ask about concepts, historical events, scientific topics, or need factual information.",
  parameters: z.object({
    query: z.string().describe("The search query for Wikipedia"),
    language: z.string().default("en").describe("Language code (en, es, fr, etc.)"),
  }),
  execute: async ({ query, language = "en" }) => {
    try {
      // Search Wikipedia API
      const searchUrl = `https://${language}.wikipedia.org/api/rest_v1/page/summary/${encodeURIComponent(query)}`;
      const response = await fetch(searchUrl);
      
      if (!response.ok) {
        throw new Error(`Wikipedia API error: ${response.status}`);
      }
      
      const data = await response.json();
      
      return {
        title: data.title || "Not found",
        extract: data.extract || "No summary available",
        content_url: data.content_urls?.desktop?.page || "",
        thumbnail: data.thumbnail?.source || "",
        type: data.type || "standard",
      };
    } catch (error) {
      return {
        title: "Error",
        extract: `Failed to fetch Wikipedia information: ${error.message}`,
        content_url: "",
        thumbnail: "",
        type: "error",
      };
    }
  },
});

// Study materials search tool (integrates with your study materials feature)
const studyMaterialsTool = tool({
  description: "Search the user's personal study materials and notes. Use this when students ask about their own notes, previously saved materials, or want to reference their study content.",
  parameters: z.object({
    query: z.string().describe("The search query for study materials"),
    subject: z.string().optional().describe("Optional subject filter"),
  }),
  execute: async ({ query, subject }) => {
    // This would integrate with your study materials database
    // For now, returning a placeholder that can be implemented
    return {
      materials: [],
      message: "Study materials search integration coming soon. This will search through your saved notes, summaries, and study materials.",
      query,
      subject,
    };
  },
});

// Study planner tool (integrates with your planner feature)
const studyPlannerTool = tool({
  description: "Access and manage study goals and sessions. Use this when students ask about their study schedule, goals, or want to plan their study time.",
  parameters: z.object({
    action: z.enum(["view_goals", "view_schedule", "suggest_session"]).describe("The action to perform"),
    date: z.string().optional().describe("Date for schedule queries (YYYY-MM-DD)"),
  }),
  execute: async ({ action, date }) => {
    // This would integrate with your planner database
    // For now, returning a placeholder that can be implemented
    return {
      action,
      date,
      message: "Study planner integration coming soon. This will access your goals, schedule, and provide AI-powered study suggestions.",
    };
  },
});

// Calculator tool for math problems
const calculatorTool = tool({
  description: "Perform mathematical calculations. Use this for solving equations, arithmetic, or when students need help with math problems.",
  parameters: z.object({
    expression: z.string().describe("Mathematical expression to evaluate"),
  }),
  execute: async ({ expression }) => {
    try {
      // Simple evaluation (in production, use a more secure math parser)
      // This is a simplified version - in production, use a proper math library
      const result = eval(expression.replace(/[^0-9+\-*/().]/g, ""));
      return {
        expression,
        result: result.toString(),
        success: true,
      };
    } catch (error) {
      return {
        expression,
        result: "Invalid mathematical expression",
        success: false,
        error: error.message,
      };
    }
  },
});

// Enhanced system prompt for tool-enhanced chatbot
const SYSTEM_PROMPT = `You are Athena, an AI-powered study companion with advanced tool capabilities. Your enhanced principles:

1. **Educational Focus**: Prioritize learning and understanding over just providing answers
2. **Tool Integration**: You have access to several tools to enhance your responses:
   - Wikipedia search for factual information and academic topics
   - Study materials search for personal study content
   - Study planner for goals and scheduling
   - Calculator for mathematical problems
3. **Proactive Tool Use**: When appropriate, use tools to:
   - Verify facts and provide authoritative sources
   - Find related academic information
   - Help with calculations and problem-solving
   - Access the user's personal study ecosystem
4. **Encouraging Tone**: Be supportive, patient, and motivating
5. **Clear Explanations**: Break down complex concepts into digestible parts
6. **Academic Integrity**: Guide students to understand concepts rather than just giving answers

When using tools:
- Always explain why you're using a tool and what you're looking for
- Cite Wikipedia sources when using factual information
- Connect tool results back to the student's learning goals
- Use multiple tools when beneficial for comprehensive answers

Always maintain a helpful, encouraging, and educational tone while leveraging your tool capabilities.`;

// Helper function to save message to database
async function saveMessage(
  supabase: SupabaseClient,
  conversationId: string,
  sender: string,
  content: string,
  toolCalls?: any[],
) {
  const { error } = await supabase.from("chat_messages").insert({
    conversation_id: conversationId,
    sender,
    content,
    metadata: toolCalls ? { toolCalls } : null,
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

    // Save user message
    await saveMessage(
      supabase,
      validatedRequest.conversationId,
      "user",
      validatedRequest.message,
    );

    // Prepare messages for AI
    const messages: CoreMessage[] = [
      { role: "system", content: SYSTEM_PROMPT },
      { role: "user", content: validatedRequest.message },
    ];

    // Initialize tools
    const tools = validatedRequest.enableTools ? {
      wikipedia: wikipediaTool,
      studyMaterials: studyMaterialsTool,
      studyPlanner: studyPlannerTool,
      calculator: calculatorTool,
    } : {};

    // Initialize OpenAI client with tool support
    const model = openai("gpt-4o-mini");

    // Stream the AI response with tools
    const result = await streamText({
      model,
      messages,
      tools,
      temperature: 0.7,
      maxTokens: 1500,
    });

    // Create a readable stream for the response
    const stream = new ReadableStream({
      async start(controller) {
        try {
          let fullResponse = "";
          let toolCalls: any[] = [];

          for await (const delta of result.fullStream) {
            if (delta.type === "text-delta") {
              fullResponse += delta.textDelta;
              const chunk = `data: ${JSON.stringify({
                type: "chunk",
                content: delta.textDelta,
              })}\n\n`;
              controller.enqueue(new TextEncoder().encode(chunk));
            } else if (delta.type === "tool-call") {
              toolCalls.push({
                toolCallId: delta.toolCallId,
                toolName: delta.toolName,
                args: delta.args,
              });
              
              const toolChunk = `data: ${JSON.stringify({
                type: "tool-call",
                toolName: delta.toolName,
                args: delta.args,
              })}\n\n`;
              controller.enqueue(new TextEncoder().encode(toolChunk));
            } else if (delta.type === "tool-result") {
              const resultChunk = `data: ${JSON.stringify({
                type: "tool-result",
                toolCallId: delta.toolCallId,
                result: delta.result,
              })}\n\n`;
              controller.enqueue(new TextEncoder().encode(resultChunk));
            }
          }

          // Save the complete AI response with tool calls to database
          await saveMessage(
            supabase,
            validatedRequest.conversationId,
            "ai",
            fullResponse,
            toolCalls.length > 0 ? toolCalls : undefined,
          );

          // Send completion signal
          const completionChunk = `data: ${JSON.stringify({
            type: "complete",
            fullResponse,
            toolCalls,
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
    console.error("Tool chat error:", error);
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
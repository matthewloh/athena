import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient, SupabaseClient } from "jsr:@supabase/supabase-js@2";
import { openai } from "npm:@ai-sdk/openai";
import { anthropic } from "npm:@ai-sdk/anthropic";
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
  description:
    "Search Wikipedia for academic information on any topic. Use this when students ask about concepts, historical events, scientific topics, or need factual information.",
  parameters: z.object({
    query: z.string().describe("The search query for Wikipedia"),
    language: z.string().default("en").describe(
      "Language code (en, es, fr, etc.)",
    ),
  }),
  execute: async ({ query, language = "en" }) => {
    try {
      // Search Wikipedia API
      const searchUrl =
        `https://${language}.wikipedia.org/api/rest_v1/page/summary/${
          encodeURIComponent(query)
        }`;
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

// Create tool factory function to capture auth token
function createToolsWithAuth(authToken: string) {
  // Study materials search tool
  const studyMaterialsTool = tool({
    description:
      "Search the user's personal study materials and notes. Use this when students ask about their own notes, previously saved materials, or want to reference their study content.",
    parameters: z.object({
      query: z.string().describe("The search query for study materials"),
      subject: z.string().optional().describe("Optional subject filter"),
      content_type: z.enum(["typedText", "textFile", "imageFile"]).optional()
        .describe("Filter by content type"),
      has_ai_summary: z.boolean().optional().describe(
        "Filter materials with AI summaries",
      ),
      limit: z.number().default(5).describe(
        "Maximum number of results to return",
      ),
    }),
    execute: async (
      { query, subject, content_type, has_ai_summary, limit },
    ) => {
      try {
        const response = await fetch(
          `${Deno.env.get("SUPABASE_URL")}/functions/v1/get-study-materials`,
          {
            method: "POST",
            headers: {
              "Content-Type": "application/json",
              "Authorization": `Bearer ${authToken}`,
            },
            body: JSON.stringify({
              search_query: query,
              subject,
              content_type,
              has_ai_summary,
              limit,
            }),
          },
        );

        if (!response.ok) {
          throw new Error(`Materials search failed: ${response.status}`);
        }

        const data = await response.json();
        return {
          success: true,
          materials: data.materials || [],
          total_count: data.total_count || 0,
          search_performed: data.search_performed,
          filters_applied: data.filters_applied,
          navigation_actions: data.navigation_actions || [],
          query,
        };
      } catch (error) {
        return {
          success: false,
          error: error.message,
          materials: [],
          query,
        };
      }
    },
  });

  // Study insights tool
  const studyInsightsTool = tool({
    description:
      "Get comprehensive insights about the user's study progress, goals, materials, quizzes, and receive personalized recommendations. Use this when students ask about their overall progress, study statistics, or need personalized study advice.",
    parameters: z.object({
      include_goals: z.boolean().default(true).describe(
        "Include study goals analysis",
      ),
      include_materials: z.boolean().default(true).describe(
        "Include study materials analysis",
      ),
      include_quizzes: z.boolean().default(true).describe(
        "Include quiz and review analysis",
      ),
      include_sessions: z.boolean().default(true).describe(
        "Include study sessions analysis",
      ),
      days_back: z.number().default(30).describe(
        "Number of days to look back for recent activity",
      ),
    }),
    execute: async (
      {
        include_goals,
        include_materials,
        include_quizzes,
        include_sessions,
        days_back,
      },
    ) => {
      try {
        const response = await fetch(
          `${Deno.env.get("SUPABASE_URL")}/functions/v1/get-study-insights`,
          {
            method: "POST",
            headers: {
              "Content-Type": "application/json",
              "Authorization": `Bearer ${authToken}`,
            },
            body: JSON.stringify({
              include_goals,
              include_materials,
              include_quizzes,
              include_sessions,
              days_back,
            }),
          },
        );

        if (!response.ok) {
          throw new Error(`Study insights failed: ${response.status}`);
        }

        const insights = await response.json();
        return {
          success: true,
          insights,
          generated_at: insights.generated_at,
          period_analyzed: `${days_back} days`,
          navigation_actions: insights.navigation_actions || [],
        };
      } catch (error) {
        return {
          success: false,
          error: error.message,
          message: "Unable to fetch study insights at this time.",
        };
      }
    },
  });

  // Material content search tool
  const materialContentSearchTool = tool({
    description:
      "Search within the actual content of study materials for specific information, concepts, or topics. Use this when you need to find specific details, quotes, or concepts from the user's study materials.",
    parameters: z.object({
      query: z.string().describe(
        "The search query to find within material content",
      ),
      material_id: z.string().optional().describe(
        "Specific material ID to search within",
      ),
      subject: z.string().optional().describe("Filter by subject"),
      max_results: z.number().default(5).describe(
        "Maximum number of results to return",
      ),
      include_context: z.boolean().default(true).describe(
        "Include surrounding context for matches",
      ),
    }),
    execute: async (
      { query, material_id, subject, max_results, include_context },
    ) => {
      try {
        const response = await fetch(
          `${
            Deno.env.get("SUPABASE_URL")
          }/functions/v1/search-material-content`,
          {
            method: "POST",
            headers: {
              "Content-Type": "application/json",
              "Authorization": `Bearer ${authToken}`,
            },
            body: JSON.stringify({
              query,
              material_id,
              subject,
              max_results,
              include_context,
            }),
          },
        );

        if (!response.ok) {
          throw new Error(`Content search failed: ${response.status}`);
        }

        const data = await response.json();
        return {
          success: true,
          results: data.results || [],
          total_matches: data.total_matches || 0,
          query_used: data.query_used,
          searched_materials: data.searched_materials || 0,
          search_terms: data.search_terms || [],
        };
      } catch (error) {
        return {
          success: false,
          error: error.message,
          results: [],
          query,
        };
      }
    },
  });

  return {
    wikipedia: wikipediaTool,
    studyMaterials: studyMaterialsTool,
    materialContentSearch: materialContentSearchTool,
    studyInsights: studyInsightsTool,
    calculator: calculatorTool,
  };
}

// Calculator tool for math problems
const calculatorTool = tool({
  description:
    "Perform mathematical calculations. Use this for solving equations, arithmetic, or when students need help with math problems.",
  parameters: z.object({
    expression: z.string().describe("Mathematical expression to evaluate"),
  }),
  execute: async ({ expression }) => {
    try {
      // Simple evaluation (in production, use a more secure math parser)
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
const SYSTEM_PROMPT =
  `You are Athena, an AI-powered study companion with advanced tool capabilities that connect to the user's complete study ecosystem. Your enhanced principles:

1. **Educational Focus**: Prioritize learning and understanding over just providing answers
2. **Comprehensive Tool Integration**: You have access to powerful tools that connect to the user's personal study data:
   - **Wikipedia search**: For factual information and academic topics
   - **Study materials search**: Find and reference the user's personal notes, summaries, and study content
   - **Material content search**: Deep search within study materials for specific concepts, quotes, and details
   - **Study insights**: Comprehensive analysis of study progress, goals, quiz performance, and personalized recommendations
   - **Calculator**: For mathematical problems and calculations

3. **Intelligent Tool Usage**: Proactively use tools to:
   - Reference the user's own study materials when answering questions
   - Provide personalized insights based on their study data
   - Connect new concepts to materials they've already studied
   - Give progress feedback and actionable recommendations
   - Verify facts with authoritative sources
   - Help with calculations and problem-solving

4. **Personalized Learning**: Leverage the user's study data to:
   - Reference their specific materials and notes
   - Build on concepts they've already learned
   - Identify knowledge gaps and suggest improvements
   - Provide context-aware study recommendations
   - Track progress across their learning journey

5. **Interactive Navigation Actions**: **CRITICAL** - When tools return navigation_actions in their results, you MUST include helpful navigation options at the end of your response. These appear as actionable chips that help users navigate to relevant parts of the app. Present them naturally by saying something like "Would you like me to:" or "Here are some ways I can help you:" followed by the suggested actions. This makes your assistance more actionable and connected to the broader study app.

6. **Encouraging Tone**: Be supportive, patient, and motivating
7. **Clear Explanations**: Break down complex concepts into digestible parts
8. **Academic Integrity**: Guide students to understand concepts rather than just giving answers

When using tools:
- Always explain why you're using a tool and what you're looking for
- Reference the user's own materials when relevant ("Based on your notes on...")
- Provide insights that connect to their personal study progress
- Use multiple tools together for comprehensive, personalized responses
   - **ALWAYS check tool results for navigation_actions and include them in your response**
- Present navigation actions naturally as helpful suggestions for next steps
- Cite sources appropriately (Wikipedia, their own materials, etc.)

Example of including navigation actions:
"Based on your study progress... [analysis]... Would you like me to:
1. [First action from tool result]
2. [Second action from tool result]"

Always maintain a helpful, encouraging, and educational tone while leveraging your comprehensive tool capabilities to provide personalized, data-driven study assistance.`;

// Helper function to save message to database
async function saveMessage(
  supabase: SupabaseClient,
  conversationId: string,
  sender: string,
  content: string,
  toolCalls?: any[],
  additionalMetadata?: any,
) {
  const metadata = {
    ...(toolCalls && toolCalls.length > 0 && { toolCalls }),
    ...additionalMetadata,
  };

  const { error } = await supabase.from("chat_messages").insert({
    conversation_id: conversationId,
    sender,
    content,
    metadata: Object.keys(metadata).length > 0 ? metadata : null,
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
    // Get auth token from request
    const authToken =
      req.headers.get("Authorization")?.replace("Bearer ", "") || "";

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

    // Initialize tools with auth token
    const tools = validatedRequest.enableTools
      ? createToolsWithAuth(authToken)
      : {};

    // Initialize Claude client
    const model = anthropic("claude-4-sonnet-20250514");

    // Stream the AI response with tools
    const result = await streamText({
      // @ts-ignore - some deprecated api/types
      model,
      messages,
      tools,
      temperature: 0.7,
      maxTokens: 1500,
      maxSteps: 10,
    });

    // Create a readable stream for the response
    const stream = new ReadableStream({
      async start(controller) {
        try {
          let fullResponse = "";
          let toolCalls: any[] = [];
          let allNavigationActions: any[] = [];

          for await (const delta of result.fullStream) {
            if (delta.type === "text-delta") {
              fullResponse += delta.textDelta;
              const chunk = `data: ${
                JSON.stringify({
                  type: "chunk",
                  content: delta.textDelta,
                })
              }\n\n`;
              controller.enqueue(new TextEncoder().encode(chunk));
            } else if (delta.type === "tool-call") {
              toolCalls.push({
                toolCallId: delta.toolCallId,
                toolName: delta.toolName,
                args: delta.args,
              });

              const toolChunk = `data: ${
                JSON.stringify({
                  type: "tool-call",
                  toolName: delta.toolName,
                  args: delta.args,
                })
              }\n\n`;
              controller.enqueue(new TextEncoder().encode(toolChunk));
            } else if (delta.type === "tool-result") {
              // Extract navigation actions from tool results
              if (
                delta.result && typeof delta.result === "object" &&
                delta.result.navigation_actions
              ) {
                allNavigationActions.push(...delta.result.navigation_actions);
              }

              const resultChunk = `data: ${
                JSON.stringify({
                  type: "tool-result",
                  toolCallId: delta.toolCallId,
                  result: delta.result,
                })
              }\n\n`;
              controller.enqueue(new TextEncoder().encode(resultChunk));
            }
          }

          // Prepare metadata with tool calls and navigation actions
          const messageMetadata = {
            ...(toolCalls.length > 0 && { toolCalls }),
            ...(allNavigationActions.length > 0 &&
              { navigation_actions: allNavigationActions }),
          };

          // Save the complete AI response with enhanced metadata
          await saveMessage(
            supabase,
            validatedRequest.conversationId,
            "ai",
            fullResponse,
            toolCalls,
            messageMetadata,
          );

          // Send completion signal with navigation actions
          const completionChunk = `data: ${
            JSON.stringify({
              type: "complete",
              fullResponse,
              toolCalls,
              navigationActions: allNavigationActions,
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
    console.error("Tool chat error:", error);
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

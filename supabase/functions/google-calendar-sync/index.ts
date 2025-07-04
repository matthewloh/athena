import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";
import { z } from "npm:zod";

// Google Calendar API configuration
interface GoogleCalendarConfig {
  clientId: string;
  clientSecret: string;
  redirectUri: string;
}

// Request schemas
const CalendarSyncRequestSchema = z.object({
  action: z.enum(["authorize", "sync_session", "sync_all", "disconnect"]),
  code: z.string().optional(), // OAuth authorization code
  sessionId: z.string().optional(), // For syncing specific session
  calendarId: z.string().default("primary"), // Google Calendar ID
});

const StudySessionSchema = z.object({
  id: z.string(),
  title: z.string(),
  subject: z.string(),
  start_time: z.string(),
  end_time: z.string(),
  description: z.string().optional(),
  location: z.string().optional(),
});

// Exchange authorization code for access token
async function exchangeCodeForTokens(
  config: GoogleCalendarConfig,
  code: string
): Promise<any> {
  const response = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: {
      "Content-Type": "application/x-www-form-urlencoded",
    },
    body: new URLSearchParams({
      client_id: config.clientId,
      client_secret: config.clientSecret,
      code,
      grant_type: "authorization_code",
      redirect_uri: config.redirectUri,
    }),
  });

  if (!response.ok) {
    const errorText = await response.text();
    throw new Error(`Token exchange failed: ${response.status} - ${errorText}`);
  }

  return await response.json();
}

// Refresh access token
async function refreshAccessToken(
  config: GoogleCalendarConfig,
  refreshToken: string
): Promise<any> {
  const response = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: {
      "Content-Type": "application/x-www-form-urlencoded",
    },
    body: new URLSearchParams({
      client_id: config.clientId,
      client_secret: config.clientSecret,
      refresh_token: refreshToken,
      grant_type: "refresh_token",
    }),
  });

  if (!response.ok) {
    const errorText = await response.text();
    throw new Error(`Token refresh failed: ${response.status} - ${errorText}`);
  }

  return await response.json();
}

// Get valid access token (refresh if needed)
async function getValidAccessToken(
  supabase: any,
  userId: string,
  config: GoogleCalendarConfig
): Promise<string> {
  const { data: auth, error } = await supabase
    .from("user_google_calendar_auth")
    .select("access_token, refresh_token, expires_at")
    .eq("user_id", userId)
    .single();

  if (error || !auth) {
    throw new Error("No Google Calendar authorization found");
  }

  // Check if token is expired (with 5-minute buffer)
  const expiresAt = new Date(auth.expires_at);
  const now = new Date();
  const fiveMinutesFromNow = new Date(now.getTime() + 5 * 60 * 1000);

  if (expiresAt <= fiveMinutesFromNow) {
    // Token is expired or about to expire, refresh it
    const tokenData = await refreshAccessToken(config, auth.refresh_token);
    
    const newExpiresAt = new Date(now.getTime() + tokenData.expires_in * 1000);
    
    // Update database with new token
    await supabase
      .from("user_google_calendar_auth")
      .update({
        access_token: tokenData.access_token,
        expires_at: newExpiresAt.toISOString(),
      })
      .eq("user_id", userId);

    return tokenData.access_token;
  }

  return auth.access_token;
}

// Create Google Calendar event
async function createCalendarEvent(
  accessToken: string,
  calendarId: string,
  session: any
): Promise<any> {
  const event = {
    summary: `📚 ${session.title}`,
    description: `Study session for ${session.subject}${session.description ? `\n\n${session.description}` : ""}\n\nCreated by Athena Study Companion`,
    start: {
      dateTime: session.start_time,
      timeZone: "UTC",
    },
    end: {
      dateTime: session.end_time,
      timeZone: "UTC",
    },
    location: session.location || "",
    colorId: getSubjectColorId(session.subject),
    reminders: {
      useDefault: false,
      overrides: [
        { method: "email", minutes: 60 },
        { method: "popup", minutes: 15 },
      ],
    },
    extendedProperties: {
      private: {
        athenaSessionId: session.id,
        source: "athena-study-companion",
      },
    },
  };

  const response = await fetch(
    `https://www.googleapis.com/calendar/v3/calendars/${encodeURIComponent(calendarId)}/events`,
    {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${accessToken}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify(event),
    }
  );

  if (!response.ok) {
    const errorText = await response.text();
    throw new Error(`Failed to create calendar event: ${response.status} - ${errorText}`);
  }

  return await response.json();
}

// Update Google Calendar event
async function updateCalendarEvent(
  accessToken: string,
  calendarId: string,
  eventId: string,
  session: any
): Promise<any> {
  const event = {
    summary: `📚 ${session.title}`,
    description: `Study session for ${session.subject}${session.description ? `\n\n${session.description}` : ""}\n\nCreated by Athena Study Companion`,
    start: {
      dateTime: session.start_time,
      timeZone: "UTC",
    },
    end: {
      dateTime: session.end_time,
      timeZone: "UTC",
    },
    location: session.location || "",
    colorId: getSubjectColorId(session.subject),
  };

  const response = await fetch(
    `https://www.googleapis.com/calendar/v3/calendars/${encodeURIComponent(calendarId)}/events/${eventId}`,
    {
      method: "PUT",
      headers: {
        "Authorization": `Bearer ${accessToken}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify(event),
    }
  );

  if (!response.ok) {
    const errorText = await response.text();
    throw new Error(`Failed to update calendar event: ${response.status} - ${errorText}`);
  }

  return await response.json();
}

// Delete Google Calendar event
async function deleteCalendarEvent(
  accessToken: string,
  calendarId: string,
  eventId: string
): Promise<void> {
  const response = await fetch(
    `https://www.googleapis.com/calendar/v3/calendars/${encodeURIComponent(calendarId)}/events/${eventId}`,
    {
      method: "DELETE",
      headers: {
        "Authorization": `Bearer ${accessToken}`,
      },
    }
  );

  if (!response.ok && response.status !== 404) {
    const errorText = await response.text();
    throw new Error(`Failed to delete calendar event: ${response.status} - ${errorText}`);
  }
}

// Get color ID for subject (Google Calendar color scheme)
function getSubjectColorId(subject: string): string {
  const colorMap: Record<string, string> = {
    "Mathematics": "11", // Red
    "Science": "10", // Green
    "Physics": "9", // Blue
    "Chemistry": "5", // Yellow
    "Biology": "2", // Green
    "History": "6", // Orange
    "English": "7", // Turquoise
    "Literature": "7", // Turquoise
    "Computer Science": "8", // Gray
    "Programming": "8", // Gray
    "Art": "4", // Flamingo
    "Music": "4", // Flamingo
    "Psychology": "3", // Grape
    "Philosophy": "3", // Grape
    "Economics": "11", // Red
    "Business": "11", // Red
  };

  return colorMap[subject] || "1"; // Default to Lavender
}

// Sync all study sessions to Google Calendar
async function syncAllSessions(
  supabase: any,
  userId: string,
  accessToken: string,
  calendarId: string
): Promise<any> {
  // Get all upcoming study sessions
  const { data: sessions, error } = await supabase
    .from("study_sessions")
    .select("*")
    .eq("user_id", userId)
    .eq("status", "scheduled")
    .gte("start_time", new Date().toISOString())
    .order("start_time", { ascending: true });

  if (error) {
    throw new Error(`Failed to fetch sessions: ${error.message}`);
  }

  const results = [];
  for (const session of sessions) {
    try {
      // Check if already synced
      const { data: existingSync } = await supabase
        .from("study_session_calendar_sync")
        .select("google_event_id")
        .eq("session_id", session.id)
        .single();

      if (existingSync) {
        // Update existing event
        await updateCalendarEvent(accessToken, calendarId, existingSync.google_event_id, session);
        results.push({ sessionId: session.id, action: "updated", eventId: existingSync.google_event_id });
      } else {
        // Create new event
        const event = await createCalendarEvent(accessToken, calendarId, session);
        
        // Save sync record
        await supabase
          .from("study_session_calendar_sync")
          .insert({
            session_id: session.id,
            user_id: userId,
            google_event_id: event.id,
            calendar_id: calendarId,
          });

        results.push({ sessionId: session.id, action: "created", eventId: event.id });
      }
    } catch (error) {
      console.error(`Failed to sync session ${session.id}:`, error);
      results.push({ sessionId: session.id, action: "error", error: error.message });
    }
  }

  return results;
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

    // Get user from JWT
    const { data: { user }, error: userError } = await supabase.auth.getUser();
    if (userError || !user) {
      throw new Error("Unauthorized");
    }

    // Parse and validate request body
    const body = await req.json();
    const validatedRequest = CalendarSyncRequestSchema.parse(body);

    // Google Calendar configuration
    const googleConfig: GoogleCalendarConfig = {
      clientId: Deno.env.get("GOOGLE_CLIENT_ID") ?? "",
      clientSecret: Deno.env.get("GOOGLE_CLIENT_SECRET") ?? "",
      redirectUri: Deno.env.get("GOOGLE_REDIRECT_URI") ?? "",
    };

    // Validate Google config
    if (!googleConfig.clientId || !googleConfig.clientSecret || !googleConfig.redirectUri) {
      throw new Error("Google Calendar configuration missing");
    }

    let result = {};

    switch (validatedRequest.action) {
      case "authorize":
        if (!validatedRequest.code) {
          // Return authorization URL
          const authUrl = new URL("https://accounts.google.com/o/oauth2/v2/auth");
          authUrl.searchParams.set("client_id", googleConfig.clientId);
          authUrl.searchParams.set("redirect_uri", googleConfig.redirectUri);
          authUrl.searchParams.set("response_type", "code");
          authUrl.searchParams.set("scope", "https://www.googleapis.com/auth/calendar");
          authUrl.searchParams.set("access_type", "offline");
          authUrl.searchParams.set("prompt", "consent");

          result = {
            authUrl: authUrl.toString(),
            message: "Visit this URL to authorize Google Calendar access",
          };
        } else {
          // Exchange code for tokens
          const tokenData = await exchangeCodeForTokens(googleConfig, validatedRequest.code);
          const expiresAt = new Date(Date.now() + tokenData.expires_in * 1000);

          // Save tokens to database
          await supabase
            .from("user_google_calendar_auth")
            .upsert({
              user_id: user.id,
              access_token: tokenData.access_token,
              refresh_token: tokenData.refresh_token,
              expires_at: expiresAt.toISOString(),
              scope: tokenData.scope,
            });

          result = {
            success: true,
            message: "Google Calendar authorization successful",
          };
        }
        break;

      case "sync_session":
        if (!validatedRequest.sessionId) {
          throw new Error("Session ID required for sync_session action");
        }

        const accessToken = await getValidAccessToken(supabase, user.id, googleConfig);
        
        // Get session details
        const { data: session, error: sessionError } = await supabase
          .from("study_sessions")
          .select("*")
          .eq("id", validatedRequest.sessionId)
          .eq("user_id", user.id)
          .single();

        if (sessionError || !session) {
          throw new Error("Session not found");
        }

        // Create calendar event
        const event = await createCalendarEvent(accessToken, validatedRequest.calendarId, session);
        
        // Save sync record
        await supabase
          .from("study_session_calendar_sync")
          .upsert({
            session_id: session.id,
            user_id: user.id,
            google_event_id: event.id,
            calendar_id: validatedRequest.calendarId,
          });

        result = {
          success: true,
          eventId: event.id,
          message: "Session synced to Google Calendar",
        };
        break;

      case "sync_all":
        const allAccessToken = await getValidAccessToken(supabase, user.id, googleConfig);
        const syncResults = await syncAllSessions(supabase, user.id, allAccessToken, validatedRequest.calendarId);

        result = {
          success: true,
          syncedSessions: syncResults.length,
          results: syncResults,
          message: "All sessions synced to Google Calendar",
        };
        break;

      case "disconnect":
        // Remove authorization and sync records
        await supabase
          .from("user_google_calendar_auth")
          .delete()
          .eq("user_id", user.id);

        await supabase
          .from("study_session_calendar_sync")
          .delete()
          .eq("user_id", user.id);

        result = {
          success: true,
          message: "Google Calendar integration disconnected",
        };
        break;

      default:
        throw new Error("Invalid action");
    }

    return new Response(JSON.stringify(result), {
      status: 200,
      headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
      },
    });

  } catch (error) {
    console.error("Google Calendar sync error:", error);
    const errorMessage = error instanceof Error ? error.message : "Unknown error";

    return new Response(JSON.stringify({
      error: "Google Calendar sync failed",
      message: errorMessage,
    }), {
      status: 500,
      headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
      },
    });
  }
}); 
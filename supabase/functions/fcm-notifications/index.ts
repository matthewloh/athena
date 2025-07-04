import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";
import { z } from "npm:zod";

// Firebase Admin SDK configuration
interface FirebaseConfig {
  projectId: string;
  privateKey: string;
  clientEmail: string;
}

// Notification payload schemas
const StudyGoalNotificationSchema = z.object({
  type: z.enum(["INSERT", "UPDATE", "DELETE"]),
  table: z.literal("study_goals"),
  record: z.object({
    id: z.string(),
    user_id: z.string(),
    title: z.string(),
    subject: z.string(),
    target_date: z.string(),
    progress: z.number(),
    is_completed: z.boolean(),
  }).optional(),
  old_record: z.object({
    id: z.string(),
    user_id: z.string(),
    title: z.string(),
    subject: z.string(),
    target_date: z.string(),
    progress: z.number(),
    is_completed: z.boolean(),
  }).optional(),
});

const StudySessionNotificationSchema = z.object({
  type: z.enum(["INSERT", "UPDATE", "DELETE"]),
  table: z.literal("study_sessions"),
  record: z.object({
    id: z.string(),
    user_id: z.string(),
    title: z.string(),
    subject: z.string(),
    start_time: z.string(),
    end_time: z.string(),
    status: z.enum(["scheduled", "completed", "cancelled"]),
  }).optional(),
  old_record: z.object({
    id: z.string(),
    user_id: z.string(),
    title: z.string(),
    subject: z.string(),
    start_time: z.string(),
    end_time: z.string(),
    status: z.enum(["scheduled", "completed", "cancelled"]),
  }).optional(),
});

// Firebase JWT token generation
async function generateFirebaseJWT(config: FirebaseConfig): Promise<string> {
  const header = {
    alg: "RS256",
    typ: "JWT",
  };

  const now = Math.floor(Date.now() / 1000);
  const payload = {
    iss: config.clientEmail,
    sub: config.clientEmail,
    aud: "https://oauth2.googleapis.com/token",
    iat: now,
    exp: now + 3600, // 1 hour
    scope: "https://www.googleapis.com/auth/firebase.messaging",
  };

  // Simple JWT implementation (in production, use a proper JWT library)
  const encoder = new TextEncoder();
  const headerB64 = btoa(JSON.stringify(header));
  const payloadB64 = btoa(JSON.stringify(payload));
  const data = encoder.encode(`${headerB64}.${payloadB64}`);

  // Import private key for signing
  const privateKey = await crypto.subtle.importKey(
    "pkcs8",
    encoder.encode(config.privateKey),
    {
      name: "RSASSA-PKCS1-v1_5",
      hash: "SHA-256",
    },
    false,
    ["sign"],
  );

  const signature = await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    privateKey,
    data,
  );
  const signatureB64 = btoa(String.fromCharCode(...new Uint8Array(signature)));

  return `${headerB64}.${payloadB64}.${signatureB64}`;
}

// Get Firebase access token
async function getFirebaseAccessToken(config: FirebaseConfig): Promise<string> {
  const jwt = await generateFirebaseJWT(config);

  const response = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: {
      "Content-Type": "application/x-www-form-urlencoded",
    },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: jwt,
    }),
  });

  if (!response.ok) {
    throw new Error(`Failed to get access token: ${response.status}`);
  }

  const data = await response.json();
  return data.access_token;
}

// Get user's FCM token from profiles table
async function getUserFCMToken(
  supabase: any,
  userId: string,
): Promise<string | null> {
  const { data, error } = await supabase
    .from("profiles")
    .select("fcm_token")
    .eq("id", userId)
    .single();

  if (error || !data || !data.fcm_token) {
    console.log(`No FCM token found for user ${userId}`);
    return null;
  }

  return data.fcm_token;
}

// Send FCM notification
async function sendFCMNotification(
  accessToken: string,
  projectId: string,
  fcmToken: string,
  title: string,
  body: string,
  data?: Record<string, string>,
) {
  const message = {
    message: {
      token: fcmToken,
      notification: {
        title,
        body,
      },
      data: data || {},
      android: {
        notification: {
          channel_id: "athena_study_reminders",
          priority: "high",
        },
      },
      apns: {
        payload: {
          aps: {
            alert: {
              title,
              body,
            },
            sound: "default",
            badge: 1,
          },
        },
      },
    },
  };

  const response = await fetch(
    `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`,
    {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${accessToken}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify(message),
    },
  );

  if (!response.ok) {
    const errorText = await response.text();
    throw new Error(`FCM send failed: ${response.status} - ${errorText}`);
  }

  return await response.json();
}

// Generate notification content for study goals
function generateGoalNotification(type: string, record: any, oldRecord?: any) {
  switch (type) {
    case "INSERT":
      return {
        title: "🎯 New Study Goal Created!",
        body: `You've set a new goal: "${record.title}" for ${record.subject}`,
        data: {
          type: "goal_created",
          goalId: record.id,
          subject: record.subject,
        },
      };
    case "UPDATE":
      if (record.is_completed && !oldRecord?.is_completed) {
        return {
          title: "🎉 Goal Completed!",
          body: `Congratulations! You've completed "${record.title}"`,
          data: {
            type: "goal_completed",
            goalId: record.id,
            subject: record.subject,
          },
        };
      }
      if (record.progress !== oldRecord?.progress) {
        return {
          title: "📈 Progress Updated",
          body: `"${record.title}" is now ${record.progress}% complete`,
          data: {
            type: "goal_progress",
            goalId: record.id,
            progress: record.progress.toString(),
          },
        };
      }
      break;
    case "DELETE":
      return {
        title: "🗑️ Goal Deleted",
        body: `Study goal "${oldRecord?.title}" has been removed`,
        data: {
          type: "goal_deleted",
          subject: oldRecord?.subject || "",
        },
      };
  }
  return null;
}

// Generate notification content for study sessions
function generateSessionNotification(
  type: string,
  record: any,
  oldRecord?: any,
) {
  const sessionTime = record?.start_time
    ? new Date(record.start_time).toLocaleTimeString()
    : "";

  switch (type) {
    case "INSERT":
      return {
        title: "📅 Study Session Scheduled",
        body: `"${record.title}" scheduled for ${sessionTime}`,
        data: {
          type: "session_created",
          sessionId: record.id,
          subject: record.subject,
          startTime: record.start_time,
        },
      };
    case "UPDATE":
      if (record.status === "completed" && oldRecord?.status !== "completed") {
        return {
          title: "✅ Session Completed!",
          body: `Great job completing "${record.title}"!`,
          data: {
            type: "session_completed",
            sessionId: record.id,
            subject: record.subject,
          },
        };
      }
      if (record.start_time !== oldRecord?.start_time) {
        return {
          title: "🔄 Session Rescheduled",
          body: `"${record.title}" moved to ${sessionTime}`,
          data: {
            type: "session_rescheduled",
            sessionId: record.id,
            newTime: record.start_time,
          },
        };
      }
      break;
    case "DELETE":
      return {
        title: "❌ Session Cancelled",
        body: `Study session "${oldRecord?.title}" has been cancelled`,
        data: {
          type: "session_cancelled",
          subject: oldRecord?.subject || "",
        },
      };
  }
  return null;
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
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "", // Use service role for admin operations
    );

    // Parse webhook payload
    const body = await req.json();
    console.log("Webhook received:", body);

    // Firebase configuration from environment variables
    const firebaseConfig: FirebaseConfig = {
      projectId: Deno.env.get("FIREBASE_PROJECT_ID") ?? "",
      privateKey: (Deno.env.get("FIREBASE_PRIVATE_KEY") ?? "").replace(
        /\\n/g,
        "\n",
      ),
      clientEmail: Deno.env.get("FIREBASE_CLIENT_EMAIL") ?? "",
    };

    // Validate Firebase config
    if (
      !firebaseConfig.projectId || !firebaseConfig.privateKey ||
      !firebaseConfig.clientEmail
    ) {
      throw new Error("Firebase configuration missing");
    }

    let notification = null;
    let userId = "";

    // Handle study goals webhook
    if (body.table === "study_goals") {
      const goalData = StudyGoalNotificationSchema.parse(body);
      userId = goalData.record?.user_id || goalData.old_record?.user_id || "";
      notification = generateGoalNotification(
        goalData.type,
        goalData.record,
        goalData.old_record,
      );
    } // Handle study sessions webhook
    else if (body.table === "study_sessions") {
      const sessionData = StudySessionNotificationSchema.parse(body);
      userId = sessionData.record?.user_id || sessionData.old_record?.user_id ||
        "";
      notification = generateSessionNotification(
        sessionData.type,
        sessionData.record,
        sessionData.old_record,
      );
    }

    // Skip if no notification to send or no user ID
    if (!notification || !userId) {
      return new Response(
        JSON.stringify({ message: "No notification to send" }),
        {
          status: 200,
          headers: { "Content-Type": "application/json" },
        },
      );
    }

    // Get user's FCM token
    const fcmToken = await getUserFCMToken(supabase, userId);
    if (!fcmToken) {
      return new Response(
        JSON.stringify({ message: "No FCM token found for user" }),
        {
          status: 200,
          headers: { "Content-Type": "application/json" },
        },
      );
    }

    // Get Firebase access token and send notification
    const accessToken = await getFirebaseAccessToken(firebaseConfig);

    // Filter out undefined values and ensure all values are strings
    const cleanData: Record<string, string> = {};
    if (notification.data) {
      for (const [key, value] of Object.entries(notification.data)) {
        if (value !== undefined) {
          cleanData[key] = String(value);
        }
      }
    }

    const result = await sendFCMNotification(
      accessToken,
      firebaseConfig.projectId,
      fcmToken,
      notification.title,
      notification.body,
      cleanData,
    );

    console.log("Notification sent successfully:", result);

    return new Response(
      JSON.stringify({
        success: true,
        messageId: result.name,
        notification: notification,
      }),
      {
        status: 200,
        headers: { "Content-Type": "application/json" },
      },
    );
  } catch (error) {
    console.error("FCM notification error:", error);
    const errorMessage = error instanceof Error
      ? error.message
      : "Unknown error";

    return new Response(
      JSON.stringify({
        error: "Failed to send notification",
        message: errorMessage,
      }),
      {
        status: 500,
        headers: { "Content-Type": "application/json" },
      },
    );
  }
});

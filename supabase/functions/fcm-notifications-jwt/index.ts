import { createClient } from "npm:@supabase/supabase-js@2";
import { JWT } from "npm:google-auth-library@9";
import serviceAccount from "../service-account.json" with { type: "json" };

console.log("🔥 Athena FCM Notifications (JWT) Function Started!");

interface NotificationRequest {
  user_id: string;
  type:
    | "goal_created"
    | "goal_completed"
    | "goal_progress"
    | "session_created"
    | "session_completed"
    | "test";
  title: string;
  body: string;
  data?: Record<string, string>;
}

interface WebhookPayload {
  type: "INSERT" | "UPDATE" | "DELETE";
  table: string;
  record: any;
  schema: "public";
  old_record?: any;
}

const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
);

// Generate notification content based on type and data
function generateNotificationContent(
  type: string,
  data: any = {},
): { title: string; body: string; notificationData: Record<string, string> } {
  switch (type) {
    case "goal_created":
      return {
        title: "🎯 New Study Goal Created!",
        body: data.title
          ? `You've set a new goal: "${data.title}"`
          : "You've created a new study goal!",
        notificationData: {
          type: "goal_created",
          goalId: data.goalId || data.id || "unknown",
          subject: data.subject || "General",
        },
      };
    case "goal_completed":
      return {
        title: "🎉 Goal Completed!",
        body: data.title
          ? `Congratulations! You've completed "${data.title}"`
          : "Congratulations on completing your goal!",
        notificationData: {
          type: "goal_completed",
          goalId: data.goalId || data.id || "unknown",
        },
      };
    case "goal_progress":
      return {
        title: "📈 Progress Updated",
        body: data.title && data.progress
          ? `"${data.title}" is now ${data.progress}% complete`
          : "Your goal progress has been updated!",
        notificationData: {
          type: "goal_progress",
          goalId: data.goalId || data.id || "unknown",
          progress: data.progress?.toString() || "0",
        },
      };
    case "session_created":
      return {
        title: "📅 Study Session Scheduled",
        body: data.title
          ? `"${data.title}" has been scheduled`
          : "A new study session has been scheduled!",
        notificationData: {
          type: "session_created",
          sessionId: data.sessionId || data.id || "unknown",
          subject: data.subject || "General",
        },
      };
    case "session_completed":
      return {
        title: "✅ Session Completed!",
        body: data.title
          ? `Great job completing "${data.title}"!`
          : "Great job completing your study session!",
        notificationData: {
          type: "session_completed",
          sessionId: data.sessionId || data.id || "unknown",
        },
      };
    case "test":
      return {
        title: "🧪 Test Notification",
        body: data.message || "This is a test notification from Athena!",
        notificationData: {
          type: "test",
          timestamp: new Date().toISOString(),
        },
      };
    default:
      return {
        title: "📨 Athena Notification",
        body: data.message || "You have a new notification from Athena!",
        notificationData: {
          type: "general",
        },
      };
  }
}

Deno.serve(async (req) => {
  try {
    // Handle different request types
    let notificationRequest: NotificationRequest;

    if (req.method === "POST") {
      const body = await req.json();

      // Check if it's a direct notification request
      if (body.user_id && body.type) {
        notificationRequest = body as NotificationRequest;
      } // Check if it's a webhook payload
      else if (body.record && body.table) {
        const payload = body as WebhookPayload;

        // Convert webhook to notification request
        notificationRequest = {
          user_id: payload.record.user_id,
          type: determineNotificationType(payload),
          title: "",
          body: "",
          data: payload.record,
        };
      } else {
        throw new Error("Invalid request format");
      }
    } else {
      throw new Error("Only POST method is supported");
    }

    console.log("📨 Processing notification request:", notificationRequest);

    // Get user's FCM token
    const { data, error } = await supabase
      .from("profiles")
      .select("fcm_token")
      .eq("id", notificationRequest.user_id)
      .single();

    if (error) {
      console.error("❌ Error fetching user profile:", error);
      throw new Error(`Failed to fetch user profile: ${error.message}`);
    }

    if (!data?.fcm_token) {
      console.log(
        "⚠️ No FCM token found for user:",
        notificationRequest.user_id,
      );
      return new Response(
        JSON.stringify({
          success: false,
          message: "No FCM token found for user",
        }),
        {
          status: 400,
          headers: { "Content-Type": "application/json" },
        },
      );
    }

    const fcmToken = data.fcm_token as string;
    console.log("🎯 Found FCM token for user:", notificationRequest.user_id);

    // Generate notification content
    const { title, body, notificationData } = generateNotificationContent(
      notificationRequest.type,
      notificationRequest.data || {},
    );

    // Get access token using service account
    const accessToken = await getAccessToken({
      clientEmail: serviceAccount.client_email,
      privateKey: serviceAccount.private_key,
    });

    console.log("🔑 Generated access token successfully");

    // Send FCM notification
    const fcmResponse = await fetch(
      `https://fcm.googleapis.com/v1/projects/${serviceAccount.project_id}/messages:send`,
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${accessToken}`,
        },
        body: JSON.stringify({
          message: {
            token: fcmToken,
            notification: {
              title: title,
              body: body,
            },
            data: notificationData,
            android: {
              priority: "high",
              notification: {
                channel_id: "athena_study_reminders",
                icon: "ic_notification",
                color: "#6C5CE7", // Athena purple
              },
            },
            apns: {
              payload: {
                aps: {
                  alert: {
                    title: title,
                    body: body,
                  },
                  sound: "default",
                  badge: 1,
                },
              },
            },
          },
        }),
      },
    );

    const fcmResult = await fcmResponse.json();

    if (fcmResponse.status < 200 || fcmResponse.status > 299) {
      console.error("❌ FCM send failed:", fcmResult);
      throw new Error(
        `FCM send failed: ${fcmResponse.status} - ${JSON.stringify(fcmResult)}`,
      );
    }

    console.log("✅ Notification sent successfully:", fcmResult);

    // Log to notification history (optional)
    try {
      await supabase
        .from("notification_history")
        .insert({
          user_id: notificationRequest.user_id,
          type: notificationRequest.type,
          title: title,
          body: body,
          status: "sent",
          fcm_message_id: fcmResult.name,
        });
    } catch (historyError) {
      console.warn("⚠️ Failed to log notification history:", historyError);
      // Don't fail the main request if history logging fails
    }

    return new Response(
      JSON.stringify({
        success: true,
        messageId: fcmResult.name,
        notification: {
          title,
          body,
          data: notificationData,
        },
      }),
      {
        headers: { "Content-Type": "application/json" },
      },
    );
  } catch (error) {
    console.error("❌ FCM notification error:", error);
    return new Response(
      JSON.stringify({
        success: false,
        error: "Failed to send notification",
        message: error instanceof Error ? error.message : "Unknown error",
      }),
      {
        status: 500,
        headers: { "Content-Type": "application/json" },
      },
    );
  }
});

// Helper function to determine notification type from webhook payload
function determineNotificationType(
  payload: WebhookPayload,
): NotificationRequest["type"] {
  const { type, table, record, old_record } = payload;

  if (table === "study_goals") {
    if (type === "INSERT") return "goal_created";
    if (type === "UPDATE") {
      if (record.is_completed && !old_record?.is_completed) {
        return "goal_completed";
      }
      if (record.progress !== old_record?.progress) return "goal_progress";
    }
  }

  if (table === "study_sessions") {
    if (type === "INSERT") return "session_created";
    if (
      type === "UPDATE" && record.status === "completed" &&
      old_record?.status !== "completed"
    ) {
      return "session_completed";
    }
  }

  return "test"; // fallback
}

// Get access token using JWT
const getAccessToken = ({
  clientEmail,
  privateKey,
}: {
  clientEmail: string;
  privateKey: string;
}): Promise<string> => {
  return new Promise((resolve, reject) => {
    const jwtClient = new JWT({
      email: clientEmail,
      key: privateKey,
      scopes: ["https://www.googleapis.com/auth/firebase.messaging"],
    });
    jwtClient.authorize((err, tokens) => {
      if (err) {
        reject(err);
        return;
      }
      resolve(tokens!.access_token!);
    });
  });
};

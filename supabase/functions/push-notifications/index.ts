import { createClient } from "jsr:@supabase/supabase-js@2";

console.log("🔥 Athena FCM Push Notifications Function Started!");

interface StudyGoal {
  id: string;
  user_id: string;
  title: string;
  subject: string;
  progress: number;
  is_completed: boolean;
}

interface StudySession {
  id: string;
  user_id: string;
  title: string;
  subject: string;
  start_time: string;
  status: string;
}

interface WebhookPayload {
  type: "INSERT" | "UPDATE" | "DELETE";
  table: string;
  record: StudyGoal | StudySession;
  schema: "public";
  old_record: null | StudyGoal | StudySession;
}

const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
);

// Generate notification content based on webhook data
function generateNotification(payload: WebhookPayload) {
  const { type, table, record, old_record } = payload;

  if (table === "study_goals") {
    const goal = record as StudyGoal;
    const oldGoal = old_record as StudyGoal | null;

    switch (type) {
      case "INSERT":
        return {
          title: "🎯 New Study Goal Created!",
          body: `You've set a new goal: "${goal.title}" for ${goal.subject}`,
          data: {
            type: "goal_created",
            goalId: goal.id,
            subject: goal.subject,
          },
        };
      case "UPDATE":
        if (goal.is_completed && !oldGoal?.is_completed) {
          return {
            title: "🎉 Goal Completed!",
            body: `Congratulations! You've completed "${goal.title}"`,
            data: { type: "goal_completed", goalId: goal.id },
          };
        }
        if (goal.progress !== oldGoal?.progress) {
          return {
            title: "📈 Progress Updated",
            body: `"${goal.title}" is now ${goal.progress}% complete`,
            data: {
              type: "goal_progress",
              goalId: goal.id,
              progress: goal.progress.toString(),
            },
          };
        }
        break;
    }
  }

  if (table === "study_sessions") {
    const session = record as StudySession;
    const oldSession = old_record as StudySession | null;

    switch (type) {
      case "INSERT": {
        const sessionTime = new Date(session.start_time).toLocaleTimeString();
        return {
          title: "📅 Study Session Scheduled",
          body: `"${session.title}" scheduled for ${sessionTime}`,
          data: {
            type: "session_created",
            sessionId: session.id,
            subject: session.subject,
          },
        };
      }
      case "UPDATE": {
        if (
          session.status === "completed" && oldSession?.status !== "completed"
        ) {
          return {
            title: "✅ Session Completed!",
            body: `Great job completing "${session.title}"!`,
            data: { type: "session_completed", sessionId: session.id },
          };
        }
        break;
      }
    }
  }

  return null;
}

Deno.serve(async (req) => {
  try {
    const payload: WebhookPayload = await req.json();
    console.log("📨 Received webhook:", payload);

    // Generate notification content
    const notification = generateNotification(payload);
    if (!notification) {
      console.log("ℹ️ No notification needed for this webhook");
      return new Response(
        JSON.stringify({ message: "No notification needed" }),
        {
          headers: { "Content-Type": "application/json" },
        },
      );
    }

    // Get user's FCM token from profiles
    const { data } = await supabase
      .from("profiles")
      .select("fcm_token")
      .eq("id", payload.record.user_id)
      .single();

    if (!data?.fcm_token) {
      console.log("⚠️ No FCM token found for user");
      return new Response(JSON.stringify({ message: "No FCM token found" }), {
        headers: { "Content-Type": "application/json" },
      });
    }

    // Send FCM notification
    const fcmResponse = await fetch(
      `https://fcm.googleapis.com/v1/projects/${
        Deno.env.get("FIREBASE_PROJECT_ID")
      }/messages:send`,
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${Deno.env.get("FIREBASE_ACCESS_TOKEN")}`,
        },
        body: JSON.stringify({
          message: {
            token: data.fcm_token,
            notification: {
              title: notification.title,
              body: notification.body,
            },
            data: notification.data,
            android: {
              notification: {
                channel_id: "athena_study_reminders",
                priority: "high",
                icon: "ic_notification",
                color: "#6C5CE7", // Athena purple
              },
            },
            apns: {
              payload: {
                aps: {
                  alert: {
                    title: notification.title,
                    body: notification.body,
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

    if (!fcmResponse.ok) {
      const errorText = await fcmResponse.text();
      console.error("❌ FCM send failed:", errorText);
      throw new Error(`FCM send failed: ${fcmResponse.status}`);
    }

    const result = await fcmResponse.json();
    console.log("✅ Notification sent successfully:", result);

    return new Response(
      JSON.stringify({
        success: true,
        messageId: result.name,
        notification: notification,
      }),
      {
        headers: { "Content-Type": "application/json" },
      },
    );
  } catch (error) {
    console.error("❌ Push notification error:", error);
    return new Response(
      JSON.stringify({
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

import { createClient } from "jsr:@supabase/supabase-js@2";
import { Database } from "../types.ts";
console.log("🕒 Athena Study Reminders Cron Function Started!");

const supabase = createClient<Database>(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
);

interface ReminderJob {
  type:
    | "session_reminder"
    | "daily_checkin"
    | "evening_summary"
    | "overdue_goals"
    | "streak_maintenance";
  targetUsers?: string[];
}

// Helper function to call FCM notifications
async function sendNotificationToUser(
  userId: string,
  notificationType: string,
  customData: Record<string, any> = {},
) {
  try {
    const response = await supabase.functions.invoke("fcm-notifications-jwt", {
      body: {
        user_id: userId,
        type: notificationType,
        title: "",
        body: "",
        data: customData,
      },
    });

    if (response.error) {
      console.error(
        `❌ Failed to send notification to user ${userId}:`,
        response.error,
      );
      return false;
    }

    console.log(`✅ Notification sent to user ${userId}`);
    return true;
  } catch (error) {
    console.error(`❌ Error sending notification to user ${userId}:`, error);
    return false;
  }
}

// Get users with FCM tokens (active users only)
async function getActiveUsers(): Promise<string[]> {
  const { data, error } = await supabase
    .from("profiles")
    .select("id")
    .not("fcm_token", "is", null);

  if (error) {
    console.error("❌ Error fetching active users:", error);
    return [];
  }

  return data.map((profile) => profile.id);
}

// 15-minute session reminders
async function handleSessionReminders() {
  console.log("🔔 Processing session reminders...");

  const now = new Date();
  const fifteenMinutesLater = new Date(now.getTime() + 15 * 60 * 1000);

  // Get sessions starting in 15 minutes
  const { data: upcomingSessions, error } = await supabase
    .from("study_sessions")
    .select("id, user_id, title, subject, start_time")
    .eq("status", "scheduled")
    .gte("start_time", now.toISOString())
    .lte("start_time", fifteenMinutesLater.toISOString());

  if (error) {
    console.error("❌ Error fetching upcoming sessions:", error);
    return;
  }

  let notificationCount = 0;
  for (const session of upcomingSessions) {
    const success = await sendNotificationToUser(
      session.user_id,
      "session_reminder",
      {
        sessionId: session.id,
        title: session.title,
        subject: session.subject,
        startTime: session.start_time,
        minutesUntil: "15",
      },
    );
    if (success) notificationCount++;
  }

  console.log(`📅 Sent ${notificationCount} session reminders`);
}

// Daily morning check-in
async function handleDailyCheckin() {
  console.log("🌅 Processing daily check-in...");

  const users = await getActiveUsers();
  let notificationCount = 0;

  for (const userId of users) {
    // Get today's sessions and active goals
    const today = new Date().toISOString().split("T")[0];

    const [sessionsResult, goalsResult] = await Promise.all([
      supabase
        .from("study_sessions")
        .select("count")
        .eq("user_id", userId)
        .eq("status", "scheduled")
        .gte("start_time", `${today}T00:00:00`)
        .lt("start_time", `${today}T23:59:59`),

      supabase
        .from("study_goals")
        .select("count")
        .eq("user_id", userId)
        .eq("is_completed", false),
    ]);

    const todaySessions = sessionsResult.data?.[0]?.count || 0;
    const activeGoals = goalsResult.data?.[0]?.count || 0;

    const success = await sendNotificationToUser(userId, "daily_checkin", {
      todaySessions: todaySessions.toString(),
      activeGoals: activeGoals.toString(),
      date: today,
    });

    if (success) notificationCount++;
  }

  console.log(`🌟 Sent ${notificationCount} daily check-ins`);
}

// Evening progress summary
async function handleEveningSummary() {
  console.log("🌆 Processing evening summaries...");

  const users = await getActiveUsers();
  let notificationCount = 0;

  for (const userId of users) {
    const today = new Date().toISOString().split("T")[0];

    // Get today's completed sessions
    const { data: completedSessions } = await supabase
      .from("study_sessions")
      .select("count")
      .eq("user_id", userId)
      .eq("status", "completed")
      .gte("start_time", `${today}T00:00:00`)
      .lt("start_time", `${today}T23:59:59`);

    const sessionsCompleted = completedSessions?.[0]?.count || 0;

    if (sessionsCompleted > 0) {
      const success = await sendNotificationToUser(userId, "evening_summary", {
        sessionsCompleted: sessionsCompleted.toString(),
        date: today,
      });

      if (success) notificationCount++;
    }
  }

  console.log(`🎉 Sent ${notificationCount} evening summaries`);
}

// Overdue goals alert
async function handleOverdueGoals() {
  console.log("⚠️ Processing overdue goals...");

  const today = new Date().toISOString().split("T")[0];

  const { data: overdueGoals, error } = await supabase
    .from("study_goals")
    .select("user_id, title, target_date, subject")
    .eq("is_completed", false)
    .lt("target_date", today);

  if (error) {
    console.error("❌ Error fetching overdue goals:", error);
    return;
  }

  // Group by user
  const userOverdueGoals = overdueGoals.reduce((acc, goal) => {
    if (!acc[goal.user_id]) acc[goal.user_id] = [];
    acc[goal.user_id].push(goal);
    return acc;
  }, {} as Record<string, any[]>);

  let notificationCount = 0;
  for (const [userId, goals] of Object.entries(userOverdueGoals)) {
    const success = await sendNotificationToUser(userId, "overdue_goals", {
      overdueCount: goals.length.toString(),
      firstGoalTitle: goals[0].title,
      firstGoalSubject: goals[0].subject,
    });

    if (success) notificationCount++;
  }

  console.log(`📢 Sent ${notificationCount} overdue goal alerts`);
}

// Study streak maintenance
async function handleStreakMaintenance() {
  console.log("🔥 Processing streak maintenance...");

  const users = await getActiveUsers();
  let notificationCount = 0;

  for (const userId of users) {
    // Calculate current study streak (days with completed sessions)
    const { data: recentSessions } = await supabase
      .from("study_sessions")
      .select("start_time")
      .eq("user_id", userId)
      .eq("status", "completed")
      .gte(
        "start_time",
        new Date(Date.now() - 14 * 24 * 60 * 60 * 1000).toISOString(),
      )
      .order("start_time", { ascending: false });

    if (recentSessions && recentSessions.length > 0) {
      // Simple streak calculation
      const streak = calculateStudyStreak(recentSessions);

      const success = await sendNotificationToUser(
        userId,
        "streak_maintenance",
        {
          currentStreak: streak.toString(),
          weekGoal: "5", // Encourage 5 study days per week
        },
      );

      if (success) notificationCount++;
    }
  }

  console.log(`🏆 Sent ${notificationCount} streak maintenance reminders`);
}

// Helper function to calculate study streak
function calculateStudyStreak(sessions: any[]): number {
  if (!sessions.length) return 0;

  const uniqueDays = new Set(
    sessions.map((session) =>
      new Date(session.start_time).toISOString().split("T")[0]
    ),
  );

  return uniqueDays.size;
}

Deno.serve(async (req) => {
  try {
    const { type, targetUsers }: ReminderJob = await req.json();

    console.log(`🎯 Processing reminder job: ${type}`);

    switch (type) {
      case "session_reminder":
        await handleSessionReminders();
        break;
      case "daily_checkin":
        await handleDailyCheckin();
        break;
      case "evening_summary":
        await handleEveningSummary();
        break;
      case "overdue_goals":
        await handleOverdueGoals();
        break;
      case "streak_maintenance":
        await handleStreakMaintenance();
        break;
      default:
        throw new Error(`Unknown reminder type: ${type}`);
    }

    return new Response(
      JSON.stringify({
        success: true,
        message: `${type} processed successfully`,
        timestamp: new Date().toISOString(),
      }),
      {
        headers: { "Content-Type": "application/json" },
      },
    );
  } catch (error) {
    console.error("❌ Cron job error:", error);
    return new Response(
      JSON.stringify({
        success: false,
        error: error instanceof Error ? error.message : "Unknown error",
      }),
      {
        status: 500,
        headers: { "Content-Type": "application/json" },
      },
    );
  }
});

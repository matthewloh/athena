import { createClient } from "jsr:@supabase/supabase-js@2";
import { Database } from "../types.ts";

console.log("⏰ Athena Personalized Session Reminders Cron Function Started!");

const supabase = createClient<Database>(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
);

interface PendingReminder {
  id: string;
  session_id: string;
  user_id: string;
  offset_minutes: number;
  custom_message: string | null;
  scheduled_time: string;
  session_title: string;
  session_subject: string | null;
  session_start_time: string;
  message_template: string | null;
  fcm_token: string | null;
  notifications_enabled: boolean;
  session_reminders_enabled: boolean;
  quiet_hours_start: string | null;
  quiet_hours_end: string | null;
  timezone: string;
}

// Helper function to check if current time is within quiet hours
function isInQuietHours(
  currentTime: Date,
  quietStart: string | null,
  quietEnd: string | null,
  timezone: string,
): boolean {
  if (!quietStart || !quietEnd) return false;

  try {
    // Convert current time to user's timezone
    const userTime = new Date(
      currentTime.toLocaleString("en-US", { timeZone: timezone }),
    );
    const currentHour = userTime.getHours();
    const currentMinute = userTime.getMinutes();
    const currentTimeMinutes = currentHour * 60 + currentMinute;

    // Parse quiet hours (format: "HH:MM:SS")
    const [startHour, startMin] = quietStart.split(":").map(Number);
    const [endHour, endMin] = quietEnd.split(":").map(Number);

    const startTimeMinutes = startHour * 60 + startMin;
    const endTimeMinutes = endHour * 60 + endMin;

    // Handle cases where quiet hours span midnight
    if (startTimeMinutes <= endTimeMinutes) {
      // Same day: start <= current <= end
      return currentTimeMinutes >= startTimeMinutes &&
        currentTimeMinutes <= endTimeMinutes;
    } else {
      // Spans midnight: current >= start OR current <= end
      return currentTimeMinutes >= startTimeMinutes ||
        currentTimeMinutes <= endTimeMinutes;
    }
  } catch (error) {
    console.warn("⚠️ Error checking quiet hours:", error);
    return false;
  }
}

// Helper function to generate personalized notification message
function generateReminderMessage(
  reminder: PendingReminder,
  minutesUntilSession: number,
): { title: string; body: string } {
  const sessionTitle = reminder.session_title;
  const subject = reminder.session_subject || "General";

  // Use custom message if provided, otherwise use template or default
  let messageBody: string;

  if (reminder.custom_message) {
    messageBody = reminder.custom_message;
  } else if (reminder.message_template) {
    // Replace template variables
    messageBody = reminder.message_template
      .replace("{{sessionTitle}}", sessionTitle)
      .replace("{{subject}}", subject)
      .replace("{{minutesUntil}}", minutesUntilSession.toString());
  } else {
    // Default message
    if (minutesUntilSession <= 5) {
      messageBody =
        `"${sessionTitle}" starts in ${minutesUntilSession} minutes. Get ready!`;
    } else if (minutesUntilSession <= 15) {
      messageBody =
        `"${sessionTitle}" starts in ${minutesUntilSession} minutes. Time to prepare!`;
    } else {
      messageBody =
        `"${sessionTitle}" is coming up in ${minutesUntilSession} minutes.`;
    }
  }

  return {
    title: minutesUntilSession <= 5
      ? "📚 Study Session Starting Very Soon!"
      : "⏰ Study Session Reminder",
    body: messageBody,
  };
}

// Add this enhanced message function:
function generateReminderMessageEnhanced(
  reminder: PendingReminder,
  minutesUntilSession: number,
): { title: string; body: string } {
  const sessionTitle = reminder.session_title;
  const subject = reminder.session_subject || "General";
  let messageBody: string;
  let title: string;

  if (reminder.custom_message) {
    messageBody = reminder.custom_message;
    title = "⏰ Study Session Reminder";
  } else if (reminder.message_template) {
    messageBody = reminder.message_template
      .replace("{{sessionTitle}}", sessionTitle)
      .replace("{{subject}}", subject)
      .replace("{{minutesUntil}}", minutesUntilSession.toString());
    title = "⏰ Study Session Reminder";
  } else {
    // Enhanced default messages
    if (minutesUntilSession === 1) {
      messageBody = `"${sessionTitle}" starts in 1 minute. Get ready to focus!`;
      title = "🚨 Starting in 1 Minute!";
    } else if (minutesUntilSession > 1 && minutesUntilSession <= 5) {
      messageBody =
        `"${sessionTitle}" starts in ${minutesUntilSession} minutes. Grab your materials!`;
      title = "⏰ Almost Time to Study!";
    } else if (minutesUntilSession > 5 && minutesUntilSession < 60) {
      messageBody =
        `"${sessionTitle}" starts in ${minutesUntilSession} minutes. Plan your approach!`;
      title = "📚 Study Session Coming Up";
    } else if (minutesUntilSession === 60) {
      messageBody = `"${sessionTitle}" starts in 1 hour. Set your goals!`;
      title = "🕐 1 Hour Until Study Session";
    } else if (minutesUntilSession > 60 && minutesUntilSession < 1440) {
      const hours = Math.floor(minutesUntilSession / 60);
      const mins = minutesUntilSession % 60;
      messageBody = `"${sessionTitle}" starts in ${hours} hour${
        hours > 1 ? "s" : ""
      }${mins > 0 ? ` ${mins} minutes` : ""}. Stay prepared!`;
      title = "📅 Study Session Reminder";
    } else if (minutesUntilSession === 1440) {
      messageBody =
        `"${sessionTitle}" starts in 1 day. Don't forget to review your notes!`;
      title = "📆 Study Session Tomorrow";
    } else if (minutesUntilSession > 1440) {
      const days = Math.floor(minutesUntilSession / 1440);
      messageBody = `"${sessionTitle}" starts in ${days} day${
        days > 1 ? "s" : ""
      }. Mark your calendar!`;
      title = "📆 Upcoming Study Session";
    } else {
      messageBody = `"${sessionTitle}" is coming up soon!`;
      title = "⏰ Study Session Reminder";
    }
  }

  return { title, body: messageBody };
}

// Helper function to send FCM notification
async function sendFCMNotification(
  reminder: PendingReminder,
  title: string,
  body: string,
): Promise<boolean> {
  try {
    const response = await supabase.functions.invoke("fcm-notifications-jwt", {
      body: {
        user_id: reminder.user_id,
        type: "session_reminder",
        title: title,
        body: body,
        data: {
          sessionId: reminder.session_id,
          title: reminder.session_title,
          subject: reminder.session_subject || "General",
          startTime: reminder.session_start_time,
          offsetMinutes: reminder.offset_minutes.toString(),
          reminderId: reminder.id,
          minutesUntil: reminder.offset_minutes.toString(), // <-- Pass the correct value
        },
      },
    });

    if (response.error) {
      console.error(
        `❌ Failed to send FCM notification for reminder ${reminder.id}:`,
        response.error,
      );
      return false;
    }

    console.log(`✅ FCM notification sent for reminder ${reminder.id}`);
    return true;
  } catch (error) {
    console.error(
      `❌ Error sending FCM notification for reminder ${reminder.id}:`,
      error,
    );
    return false;
  }
}

// Helper function to update reminder delivery status
async function updateReminderStatus(
  reminderId: string,
  status: "sent" | "failed",
  errorMessage?: string,
): Promise<void> {
  try {
    const updateData: any = {
      delivery_status: status,
      updated_at: new Date().toISOString(),
    };

    if (status === "sent") {
      updateData.sent_at = new Date().toISOString();
    }

    if (errorMessage) {
      updateData.error_message = errorMessage;
    }

    const { error } = await supabase
      .from("session_reminders")
      .update(updateData)
      .eq("id", reminderId);

    if (error) {
      console.error(
        `❌ Failed to update reminder ${reminderId} status:`,
        error,
      );
    } else {
      console.log(`📝 Updated reminder ${reminderId} status to ${status}`);
    }
  } catch (error) {
    console.error(`❌ Error updating reminder ${reminderId} status:`, error);
  }
}

// Main function to process pending reminders
async function processPendingReminders(): Promise<{
  processed: number;
  sent: number;
  skipped: number;
  failed: number;
}> {
  console.log("🔍 Fetching pending session reminders...");

  const now = new Date();

  // 1. Fetch pending reminders (without profiles/user_reminder_preferences)
  const { data: pendingReminders, error } = await supabase
    .from("session_reminders")
    .select(`
      id, session_id, user_id, offset_minutes, custom_message, scheduled_time,
      study_sessions!inner (title, subject, start_time, status),
      reminder_templates (message_template)
    `)
    .eq("delivery_status", "pending")
    .eq("is_enabled", true)
    .eq("study_sessions.status", "scheduled")
    .lte("scheduled_time", now.toISOString());

  if (error) {
    console.error("❌ Error fetching pending reminders:", error);
    throw error;
  }

  if (!pendingReminders || pendingReminders.length === 0) {
    console.log("✅ No pending reminders found");
    return { processed: 0, sent: 0, skipped: 0, failed: 0 };
  }

  console.log(
    `📋 Found ${pendingReminders.length} pending reminders to process`,
  );

  let processed = 0;
  let sent = 0;
  let skipped = 0;
  let failed = 0;

  // 2. For each reminder, fetch profile and preferences
  for (const rawReminder of pendingReminders) {
    const [{ data: profile }, { data: prefs }] = await Promise.all([
      supabase.from("profiles").select("fcm_token").eq(
        "id",
        rawReminder.user_id,
      ).single(),
      supabase.from("user_reminder_preferences").select(`
        notifications_enabled, session_reminders_enabled, quiet_hours_start, quiet_hours_end, timezone
      `).eq("user_id", rawReminder.user_id).single(),
    ]);

    processed++;

    // Transform the data structure
    const reminder: PendingReminder = {
      id: rawReminder.id,
      session_id: rawReminder.session_id,
      user_id: rawReminder.user_id,
      offset_minutes: rawReminder.offset_minutes,
      custom_message: rawReminder.custom_message,
      scheduled_time: rawReminder.scheduled_time || "",
      session_title: rawReminder.study_sessions.title,
      session_subject: rawReminder.study_sessions.subject,
      session_start_time: rawReminder.study_sessions.start_time,
      message_template: rawReminder.reminder_templates?.message_template ||
        null,
      fcm_token: profile?.fcm_token || "",
      notifications_enabled: prefs?.notifications_enabled || false,
      session_reminders_enabled: prefs?.session_reminders_enabled || false,
      quiet_hours_start: prefs?.quiet_hours_start || "",
      quiet_hours_end: prefs?.quiet_hours_end ||
        "",
      timezone: prefs?.timezone ||
        "Asia/Kuala_Lumpur",
    };

    console.log(
      `🔄 Processing reminder ${reminder.id} for session "${reminder.session_title}"`,
    );

    // Check if user has notifications enabled
    if (
      !reminder.notifications_enabled || !reminder.session_reminders_enabled
    ) {
      console.log(
        `⏸️ Skipping reminder ${reminder.id} - notifications disabled`,
      );
      await updateReminderStatus(
        reminder.id,
        "failed",
        "User notifications disabled",
      );
      skipped++;
      continue;
    }

    // Check if user has FCM token
    if (!reminder.fcm_token) {
      console.log(`⏸️ Skipping reminder ${reminder.id} - no FCM token`);
      await updateReminderStatus(reminder.id, "failed", "No FCM token found");
      skipped++;
      continue;
    }

    // Check quiet hours
    if (
      isInQuietHours(
        now,
        reminder.quiet_hours_start,
        reminder.quiet_hours_end,
        reminder.timezone,
      )
    ) {
      console.log(`🤫 Skipping reminder ${reminder.id} - quiet hours active`);
      await updateReminderStatus(reminder.id, "failed", "Quiet hours active");
      skipped++;
      continue;
    }

    // Use the original offset_minutes for the message
    const { title, body } = generateReminderMessageEnhanced(
      reminder,
      reminder.offset_minutes,
    );

    // Send FCM notification
    const notificationSent = await sendFCMNotification(reminder, title, body);

    if (notificationSent) {
      await updateReminderStatus(reminder.id, "sent");
      sent++;
      console.log(`✅ Successfully sent reminder ${reminder.id}`);
    } else {
      await updateReminderStatus(reminder.id, "failed", "FCM delivery failed");
      failed++;
      console.log(`❌ Failed to send reminder ${reminder.id}`);
    }
  }

  return { processed, sent, skipped, failed };
}

Deno.serve(async (req) => {
  try {
    console.log("🚀 Starting personalized session reminders cron job...");

    const result = await processPendingReminders();

    const message =
      `Session reminders processed: ${result.processed} total, ${result.sent} sent, ${result.skipped} skipped, ${result.failed} failed`;
    console.log(`📊 ${message}`);

    return new Response(
      JSON.stringify({
        success: true,
        message: message,
        stats: result,
        timestamp: new Date().toISOString(),
      }),
      {
        headers: { "Content-Type": "application/json" },
      },
    );
  } catch (error) {
    console.error("❌ Session reminders cron job error:", error);
    return new Response(
      JSON.stringify({
        success: false,
        error: error instanceof Error ? error.message : "Unknown error",
        timestamp: new Date().toISOString(),
      }),
      {
        status: 500,
        headers: { "Content-Type": "application/json" },
      },
    );
  }
});

#!/usr/bin/env node

/**
 * 🧪 Test Script for Athena Cron Reminders
 *
 * This script helps you test all the automated reminder types
 * before setting up the actual cron jobs.
 */

const PROJECT_REF = "rbxlzltxpymgioxnhivo"; // Your project reference
const ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJieGx6bHR4cHltZ2lveG5oaXZvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDc0OTQyODgsImV4cCI6MjA2MzA3MDI4OH0.XSrpDEGSQo-8rVJLzsXphgYP_sSJubkNY7Uk3bru2rI"; // Replace with your anon key

const FUNCTION_URL = `https://${PROJECT_REF}.supabase.co/functions/v1/study-reminders-cron`;

const reminderTypes = [
  {
    name: "🔔 Session Reminders",
    type: "session_reminder",
    description: "Checks for sessions starting in 15 minutes",
  },
  {
    name: "🌅 Daily Check-in",
    type: "daily_checkin",
    description: "Morning motivation with session count",
  },
  {
    name: "🌆 Evening Summary",
    type: "evening_summary",
    description: "Celebrate completed sessions",
  },
  {
    name: "⚠️ Overdue Goals",
    type: "overdue_goals",
    description: "Gentle nudges for overdue goals",
  },
  {
    name: "🔥 Streak Maintenance",
    type: "streak_maintenance",
    description: "Weekly study streak motivation",
  },
];

async function testReminder(reminderType) {
  console.log(`\n🧪 Testing: ${reminderType.name}`);
  console.log(`📝 ${reminderType.description}`);

  try {
    const response = await fetch(FUNCTION_URL, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${ANON_KEY}`,
      },
      body: JSON.stringify({
        type: reminderType.type,
      }),
    });

    const result = await response.json();

    if (response.ok) {
      console.log(`✅ SUCCESS: ${result.message}`);
      console.log(`⏰ Processed at: ${result.timestamp}`);
    } else {
      console.log(`❌ FAILED: ${result.error}`);
    }
  } catch (error) {
    console.log(`💥 ERROR: ${error.message}`);
  }
}

async function testAllReminders() {
  console.log("🚀 Starting Athena Cron Reminder Tests...\n");

  if (ANON_KEY === "YOUR_ANON_KEY_HERE") {
    console.log("❌ Please update the ANON_KEY in this script first!");
    console.log(
      "📋 Find it in: Supabase Dashboard → Project Settings → API → Project API keys"
    );
    return;
  }

  console.log(`🎯 Testing against: ${FUNCTION_URL}`);
  console.log(`🔑 Using project: ${PROJECT_REF}`);

  for (const reminderType of reminderTypes) {
    await testReminder(reminderType);
    // Small delay between tests
    await new Promise((resolve) => setTimeout(resolve, 1000));
  }

  console.log("\n🎉 All tests completed!");
  console.log("\n📋 Next steps:");
  console.log("1. Check your phone for any FCM notifications");
  console.log("2. Review function logs in Supabase Dashboard");
  console.log(
    "3. Set up the actual cron jobs using the SQL script in SUPABASE_CRON_SETUP_GUIDE.md"
  );
}

// Run the tests
testAllReminders().catch(console.error);

# Athena: Feature Deep Dive & Design Foundation 5. Intelligent Study Planner

Okay, fantastic! We're on a roll. We've designed the foundations for user management, AI-driven academic help, personal content integration, and adaptive reviews. Now, let's focus on **Part 5: Intelligent Study Planner**.

This feature helps students organize their study time, set goals, and receive reminders, aiming to improve time management and consistency. The "intelligent" aspect, for CW2, will focus on practical integrations rather than complex AI-driven emotional adaptation from CW1, to ensure feasibility while still providing significant value.

Here's the detailed breakdown for Part 5:

**5.1. Purpose & Value:**
The Intelligent Study Planner addresses the common student challenge of time management and consistent study habits. It allows users to schedule study sessions, set goals, and receive timely notifications. By integrating with other parts of Athena (like suggesting reviews for due quiz items), it becomes more than a simple calendar. For CW2, this feature demonstrates complexity in UI (scheduling interfaces), data persistence, and the use of device capabilities (notifications). The "intelligent" part can be showcased by how it helps prioritize or suggest tasks based on other app data.

**5.2. User Stories / Key Use Cases:**

- **UC5.1 (Student - Create Study Goal):** As a student, I want to create overarching study goals (e.g., "Master Chapter 5 by next Friday," "Prepare for Midterm Exam").
- **UC5.2 (Student - Schedule Study Session):** As a student, I want to schedule specific study sessions in a planner/calendar, linking them to a study goal or a specific topic/material.
- **UC5.3 (Student - Set Reminders):** As a student, when scheduling a session, I want to set reminders (e.g., 15 minutes before) so I don't miss it.
- **UC5.4 (Student - View Planner/Agenda):** As a student, I want to view my study schedule in a daily, weekly, or monthly calendar format, or as an agenda list.
- **UC5.5 (Student - Mark Session Complete):** As a student, I want to mark a study session as completed, and perhaps log how long I actually studied.
- **UC5.6 (Student - Receive Notifications):** As a student, I want to receive push notifications on my device for upcoming study sessions.
- **UC5.7 (Student - Reschedule/Edit Session):** As a student, I want to be able to easily edit or reschedule a study session if my plans change.
- **UC5.8 (Student - Get Smart Suggestions - _Basic Intelligence_):** As a student, I would like the planner to sometimes suggest scheduling a review session for topics I'm finding difficult (based on quiz performance) or for quiz items due soon.
- **UC5.9 (Student - Break Down Goals - _Basic Intelligence_):** As a student, when I create a large study goal, I'd appreciate suggestions on how to break it down into smaller, schedulable tasks/sessions.

**5.3. Screen Mock-up Ideas & UI/UX Considerations:**

- **A. Planner Dashboard / Main View Screen:**

  - **UI:**
    - Choice of view: Calendar (e.g., using `table_calendar` package), Agenda List for the day/week.
    - Highlight days with scheduled sessions.
    - A section for "Upcoming Sessions" or "Today's Tasks."
    - FAB to "Add New Goal" or "Schedule Session."
    - (Optional) "Smart Suggestions" card (UC5.8, UC5.9).
  - **UX:**
    - Clear and intuitive navigation between dates/views.
    - Easy to see scheduled commitments at a glance.
    - Quick access to add new items.

- **B. Add/Edit Study Goal Screen:**

  - **UI:**
    - `TextField` for "Goal Title/Description."
    - Date Picker for "Target Completion Date."
    - (Optional) Dropdown to link to a `study_material` or general subject.
    - "Save Goal" button.
  - **UX:**
    - Simple form, easy to understand fields.

- **C. Add/Edit Study Session Screen:**

  - **UI:**
    - `TextField` for "Session Title" (e.g., "Review Biology Chapter 3").
    - Date and Time Pickers for "Start Time" and "End Time" (or Start Time + Duration).
    - (Optional) Link to a specific `study_goal`.
    - (Optional) Link to a specific `quiz` or `study_material` for focused study.
    - Reminder toggle/settings (e.g., "Remind me 15 mins before").
    - `TextField` for "Location/Notes" (optional).
    - "Save Session" / "Schedule Session" button.
  - **UX:**
    - User-friendly date/time selection.
    - Clear options for linking to goals or materials.
    - Simple reminder setup.

- **D. Session Detail Screen (when tapping a scheduled session):**
  - **UI:**
    - Display all session details (title, time, goal, material, notes).
    - Buttons: "Mark as Complete," "Edit Session," "Delete Session."
    - If linked to a material/quiz, a button to "Go to Material/Quiz."
  - **UX:**
    - All relevant info clearly presented.
    - Easy to perform common actions on the session.

**5.4. Flutter Implementation Notes:**

- **Packages:**
  - `supabase_flutter`: For all database interactions.
  - `flutter_local_notifications`: **Crucial for UC5.6**. This involves platform-specific setup (Android/iOS) for permissions and notification handling. This can be argued as using a device service/API.
  - `table_calendar` (or similar): For a rich calendar UI.
  - State management (`flutter_bloc`, `riverpod`, `provider`): For managing lists of goals, sessions, calendar events, and notification scheduling.
  - `intl`: For date/time formatting.
  - `timezone`: For handling timezones correctly with `flutter_local_notifications`.
- **Widgets:** Calendar views, `ListView.builder` for agenda, `showDatePicker`, `showTimePicker`, `AlertDialog` for confirmations, `Switch` for reminders.
- **Logic - Notifications:**
  - When a session with a reminder is saved, schedule a local notification using `flutter_local_notifications`.
  - Initialize `flutter_local_notifications` in `main.dart` and request permissions.
  - Ensure notifications are re-scheduled if the app is restarted (e.g., on app launch, fetch upcoming sessions and re-schedule if necessary).
  - Handle notification taps (e.g., open the app to the session detail screen).
- **Logic - "Intelligent" Suggestions (Basic for CW2):**
  - **UC5.8:** On planner dashboard, query `quiz_items` for items due soon or items consistently answered incorrectly. If found, display a suggestion card: "You have X items due for review in 'Quiz Y'. Schedule a session?"
  - **UC5.9:** When a `study_goal` is created with a distant target date, suggest creating 2-3 intermediate `study_session` tasks leading up to it. This would be rule-based.

**5.5. Supabase Integration & Architecture:**

- **Supabase Database (PostgreSQL):**
  - **`study_goals` table:**
    - `id` (UUID, PK)
    - `user_id` (UUID, FK to `auth.users.id`)
    - `title` (TEXT, Not Null)
    - `description` (TEXT, Nullable)
    - `target_completion_date` (DATE, Nullable)
    - `is_completed` (BOOLEAN, default FALSE)
    - `created_at` (TIMESTAMPTZ)
  - **`study_sessions` table:**
    - `id` (UUID, PK)
    - `user_id` (UUID, FK to `auth.users.id`)
    - `study_goal_id` (UUID, FK to `study_goals.id`, Nullable)
    - `title` (TEXT, Not Null)
    - `start_time` (TIMESTAMPTZ, Not Null)
    - `end_time` (TIMESTAMPTZ, Not Null)
    - `actual_duration_minutes` (INTEGER, Nullable - logged after completion)
    - `status` (TEXT, e.g., 'scheduled', 'completed', 'missed', default 'scheduled')
    - `reminder_offset_minutes` (INTEGER, Nullable - e.g., 15 for 15 mins before)
    - `linked_material_id` (UUID, FK to `study_materials.id`, Nullable)
    - `linked_quiz_id` (UUID, FK to `quizzes.id`, Nullable)
    - `notes` (TEXT, Nullable)
    - `created_at` (TIMESTAMPTZ)
  - **RLS Policies:** Standard RLS for users to access/modify their own goals and sessions.
- **Supabase Edge Functions (Less likely needed for core planner, but potential for advanced suggestions):**
  - If more complex "intelligent" suggestion logic was needed that required heavy data processing across multiple tables or external data, an Edge Function could do it. For CW2, Flutter-side logic based on Supabase queries is likely sufficient for basic intelligence.

**5.6. LLM Integration Specifics:**

- Direct LLM integration for the planner (e.g., "AI, plan my week for me") is likely too complex for CW2's core.
- **Indirect Link:** The planner can benefit from LLM-generated content elsewhere. E.g., if AI generates quiz questions (Part 4), the planner can then suggest reviewing those. If AI summarizes notes (Part 3), a study session could be to review that summary.
- **Future Enhancement (CW1 Vision):** An LLM could analyze user's free-form goal descriptions (UC5.1) to help break them down into tasks (UC5.9) more intelligently or suggest resources. For CW2, keep this simpler.

**5.7. Design Chart Suggestions (Mermaid):**

- **A. Use Case Diagram - Intelligent Study Planner:**

  ```mermaid
  graph TD
      actor Student
      subgraph "Athena App - Intelligent Study Planner"
          UC5_1["UC5.1: Create Study Goal"]
          UC5_2["UC5.2: Schedule Study Session"]
          UC5_3["UC5.3: Set Reminders"]
          UC5_4["UC5.4: View Planner/Agenda"]
          UC5_5["UC5.5: Mark Session Complete"]
          UC5_7["UC5.7: Reschedule/Edit Session"]
          UC5_8["UC5.8: Get Smart Suggestions"]
      end
      actor System_Device as "Device Notification System"

      Student --> UC5_1
      Student --> UC5_2
      UC5_2 -- includes --> UC5_3
      Student --> UC5_4
      Student --> UC5_5
      Student --> UC5_7
      Student --> UC5_8

      UC5_3 -.-> System_Device  // FlutterLocalNotifications schedules OS notification
      UC5_1 -.-> SDB_SG(Supabase DB - study_goals)
      UC5_2 -.-> SDB_SS(Supabase DB - study_sessions)
      UC5_4 -.-> SDB_SS
      UC5_5 -.-> SDB_SS
      UC5_7 -.-> SDB_SS
      UC5_8 -.-> SDB_QI(Supabase DB - quiz_items) // For suggestions
      UC5_8 -.-> SDB_SS // To create suggested sessions

      classDef actor fill:#D6EAF8,stroke:#2E86C1,stroke-width:2px;
      classDef usecase fill:#E8F8F5,stroke:#1ABC9C,stroke-width:2px;
      class Student,System_Device actor;
      class UC5_1,UC5_2,UC5_3,UC5_4,UC5_5,UC5_7,UC5_8 usecase;
  ```

- **B. Activity Diagram - Scheduling a Study Session with Reminder:**

  ```mermaid
  graph TD
      A[User Taps 'Schedule Session'] --> B[Display Add Session Screen];
      B --> C{User Enters Details (Title, Time, Reminder Toggle)};
      C --> D{Validate Input};
      D -- Invalid --> C;
      D -- Valid --> E[Save Session to Supabase DB];
      E --> F{Reminder Toggled ON?};
      F -- Yes --> G[Flutter App: Schedule Local Notification via flutter_local_notifications];
      G --> H[Session Scheduled Successfully];
      F -- No --> H;
      H --> I[End];
  ```

- **C. Sequence Diagram - Receiving a Smart Suggestion to Review Due Quiz Items:**

  ```mermaid
  sequenceDiagram
      participant User
      participant PlannerScreen as Planner Dashboard (Flutter)
      participant SupabaseClient as Supabase Flutter SDK
      participant QuizItemsDB as Supabase DB (quiz_items)
      participant StudySessionsDB as Supabase DB (study_sessions)

      User->>PlannerScreen: Opens Planner Dashboard
      PlannerScreen->>SupabaseClient: Query quiz_items (WHERE next_review_date <= today AND user_id = current_user)
      SupabaseClient->>QuizItemsDB: SELECT from quiz_items
      QuizItemsDB-->>SupabaseClient: Returns Due Quiz Items
      SupabaseClient-->>PlannerScreen: Due Quiz Items Data

      PlannerScreen->>PlannerScreen: Process data (e.g., count due items per quiz)
      alt Due Items Found
          PlannerScreen->>User: Display "Smart Suggestion" Card (e.g., "X items due in 'Quiz Y'. Schedule review?")
          User->>PlannerScreen: Taps "Schedule" on suggestion
          PlannerScreen->>PlannerScreen: Pre-fill Add Session Screen (Title="Review Quiz Y", linked_quiz_id=Y)
          User->>PlannerScreen: Confirms session details & Saves
          PlannerScreen->>SupabaseClient: Insert into study_sessions
          SupabaseClient->>StudySessionsDB: INSERT new session
          StudySessionsDB-->>SupabaseClient: Success
          SupabaseClient-->>PlannerScreen: Confirmation
          PlannerScreen->>User: Show session in planner
      else No Due Items or Suggestion Ignored
          PlannerScreen->>User: Display regular planner view
      end
  ```

The Intelligent Study Planner, with robust scheduling, notifications, and basic smart suggestions linked to other app modules, adds significant practical value and addresses rubric criteria for complexity and functionality. `flutter_local_notifications` is a key piece here for user engagement.

This completes the core functional modules from the CW1 vision, adapted for CW2. The next logical step would be to consider a "User Dashboard/Progress Tracking" screen that consolidates information from all these modules. What are your thoughts on this planner section, and are you ready to move to the dashboard concept?

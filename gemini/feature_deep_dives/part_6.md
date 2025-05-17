# Athena: Feature Deep Dive & Design Foundation 6. User Dashboard & Progress Tracking

Alright, let's keep that midnight oil burning and power through to the final core functional piece: **Part 6: User Dashboard & Progress Tracking**.

This screen acts as the central hub, providing users with a consolidated overview of their activities, achievements, and upcoming tasks across all modules of Athena. It's where the "big picture" of their learning journey comes together.

**6.1. Purpose & Value:**
The User Dashboard provides immediate, actionable insights into a student's learning patterns, progress, and commitments. It serves as a motivational tool by visualizing achievements and highlighting areas for attention. By aggregating data from the AI Chatbot (e.g., recent topics), Adaptive Review System (quiz performance, items due), Study Planner (upcoming sessions), and potentially Study Material Management (recently added notes), it offers a holistic view. For CW2, this demonstrates complexity in data aggregation from multiple sources, UI design for information presentation (potentially with charts), and contributes to a polished, user-centric application.

**6.2. User Stories / Key Use Cases:**

- **UC6.1 (Student - Quick Overview):** As a student, when I open the dashboard, I want to see a quick summary of my key study metrics at a glance (e.g., upcoming sessions today, items due for review, recent achievements).
- **UC6.2 (Student - Track Review Progress):** As a student, I want to see my overall progress in the Adaptive Review System, like total items mastered, accuracy trends, or weakest subjects/quizzes.
- **UC6.3 (Student - See Upcoming Schedule):** As a student, I want a clear view of my next few scheduled study sessions from the Study Planner.
- **UC6.4 (Student - View Recent Activity):** As a student, I might want to see a feed of recent activities, like notes I've added, quizzes I've taken, or topics I've discussed with the AI chatbot.
- **UC6.5 (Student - Navigate to Modules):** As a student, from the dashboard, I want quick links or shortcuts to jump into specific modules (e.g., "Start Review," "Open Planner," "Chat with AI").
- **UC6.6 (Student - Track Goals):** As a student, I want to see the status of my active study goals from the Study Planner.
- **(Optional/Stretch) UC6.7 (Student - Gamification Overview):** As a student, if gamification (badges, points) is implemented, I want to see my current score, level, or recently earned badges on the dashboard.

**6.3. Screen Mock-up Ideas & UI/UX Considerations:**

- **A. Dashboard Screen:**
  - **UI Layout:** Likely a `ScrollView` containing various `Card` widgets or custom sections, each dedicated to a different piece of information.
    - **"Welcome Back, [User Name]!"** section.
    - **"Today's Focus" Card:**
      - Number of study sessions scheduled for today.
      - Number of quiz items due for review today.
      - Quick link: "Start Today's Review," "View Today's Plan."
    - **"Planner At a Glance" Card:**
      - List of next 2-3 upcoming study sessions (Title, Time).
      - Link: "Go to Full Planner."
    - **"Review System Snapshot" Card:**
      - Total items mastered vs. total items.
      - Overall accuracy percentage (if tracked).
      - (Optional) Small bar chart showing items due by quiz/subject.
      - Link: "Go to Review System."
    - **"Active Study Goals" Card:**
      - List 2-3 active goals with progress (e.g., if sub-tasks are tracked or based on target date).
      - Link: "View All Goals."
    - **(Optional) "Recent Activity Feed" Card:**
      - Scrollable list of recent events (e.g., "Added notes: 'Chapter 5 Biology'," "Completed quiz: 'History Terms'," "Chatted about: 'Photosynthesis'").
    - **(Optional) "Achievements/Badges" Card:**
      - Display recently earned badges or current point score.
  - **UX:**
    - Information should be easily scannable and digestible.
    - Prioritize the most important information at the top.
    - Use clear iconography and consistent design with the rest of the app.
    - Ensure good performance even when fetching data from multiple sources (use loading indicators for individual cards if data loads asynchronously).
    - Provide clear navigation paths to the respective modules for more detailed views or actions.

**6.4. Flutter Implementation Notes:**

- **Packages:**
  - `supabase_flutter`: For fetching all data.
  - State management (`flutter_bloc`, `riverpod`, `provider`): To manage the aggregated dashboard state, loading states for different sections.
  - `charts_flutter` (or `fl_chart`): If implementing graphical representations of progress.
  - `intl`: For formatting dates, numbers.
- **Widgets:** `Scaffold`, `AppBar` (perhaps with user profile icon), `ScrollView`, `Column`, `Card`, `ListTile`, `Row`, `Text`, `Icon`, `CircularProgressIndicator`, potentially chart widgets.
- **Logic - Data Fetching and Aggregation:**
  - The core challenge here is efficiently fetching and combining data from multiple Supabase tables when the dashboard loads.
  - Consider using `Future.wait` if fetching data for multiple cards independently.
  - For more complex aggregations (e.g., "total items mastered across all quizzes"), you might:
    - Perform multiple queries in Flutter and combine the results.
    - **Or, create Supabase Database Views or Functions (RPCs - Remote Procedure Calls)** to pre-aggregate some of this data on the backend. This is often more efficient.
      - Example Supabase Function (`get_dashboard_summary`): Could return a JSON object with `due_review_count`, `upcoming_sessions_today_count`, `active_goals_count`, etc. This reduces the number of individual calls from Flutter.
  - Ensure data is refreshed appropriately (e.g., pull-to-refresh, or when navigating back to the dashboard after an action in another module).

**6.5. Supabase Integration & Architecture:**

- **Supabase Database (PostgreSQL):**

  - The dashboard primarily _reads_ from tables already defined: `study_sessions`, `quiz_items`, `quizzes`, `study_goals`, `study_materials`, `chat_history` (for recent topics).
  - **Database Views (Highly Recommended for Complex Queries):**

    - Example View `user_quiz_item_status_summary`: Could count, for each user, total items, items due, items mastered (e.g., `repetitions > X`).

      ```sql
      -- Example View for quiz item summary
      CREATE OR REPLACE VIEW public.user_quiz_item_summary AS
      SELECT
          user_id,
          COUNT(*) AS total_items,
          SUM(CASE WHEN next_review_date <= CURRENT_DATE THEN 1 ELSE 0 END) AS items_due_today,
          SUM(CASE WHEN repetitions >= 5 THEN 1 ELSE 0 END) AS items_mastered -- Define 'mastered' criteria
      FROM
          quiz_items
      GROUP BY
          user_id;
      ```

      Flutter then queries this view: `supabase.from('user_quiz_item_summary').select().eq('user_id', userId)`.

  - **Supabase Functions (RPC):**
    - As mentioned, an RPC can encapsulate more complex logic to return a structured JSON response for the dashboard, minimizing client-side logic and network requests.
    - Example `get_user_dashboard_data(p_user_id uuid)` function in PL/pgSQL could fetch:
      - Upcoming sessions for today/tomorrow from `study_sessions`.
      - Due review items count from `quiz_items`.
      - Active goals count from `study_goals`.
      - ...and return it all as a single JSON object.

- **RLS Policies:** Existing RLS on individual tables will ensure users only see their own data, even when aggregated via views or RPCs (if views/RPCs are defined with `SECURITY DEFINER` and properly filter by `auth.uid()`).

**6.6. LLM Integration Specifics:**

- The dashboard itself doesn't typically involve direct real-time LLM calls.
- It _displays_ information that might have been influenced by LLMs elsewhere (e.g., "Recent chat topic: [topic identified by LLM in Chatbot]", "Summary available for 'Note X' [summary generated by LLM]").
- **Future Enhancement:** An LLM could potentially analyze dashboard data to provide personalized insights or suggestions (e.g., "You seem to be struggling with 'Topic Y' in quizzes, but haven't scheduled a study session for it. Would you like to?"). This is advanced and likely out of scope for CW2 core.

**6.7. Design Chart Suggestions (Mermaid):**

- **A. Component Diagram - Dashboard Data Flow:**

  ```mermaid
  graph TD
      subgraph "Flutter Application (Client-Side)"
          style FlutterApp fill:#D6EAF8,stroke:#2E86C1
          DashboardUI["Dashboard Screen UI (Widgets, Charts)"]
          DashboardState["Dashboard State Management (BLoC/Provider)"]
          SupabaseSDK["Supabase Flutter SDK Client"]
      end

      subgraph "Supabase Backend (Cloud)"
          style SupabaseBackend fill:#E8F8F5,stroke:#1ABC9C
          SupaAuth["Supabase Authentication"]
          SupaDB["Supabase Database"]
          SupaDB_Planner["- study_sessions table"]
          SupaDB_Review["- quiz_items, quizzes tables"]
          SupaDB_Goals["- study_goals table"]
          SupaDB_Views["(Optional) Database Views (e.g., user_quiz_item_summary)"]
          SupaRPCs["(Optional) RPC Functions (e.g., get_user_dashboard_data)"]
      end

      DashboardUI --> DashboardState;
      DashboardState --> SupabaseSDK;
      SupabaseSDK --> SupaAuth;
      SupabaseSDK --> SupaDB;

      SupaDB --> SupaDB_Planner;
      SupaDB --> SupaDB_Review;
      SupaDB --> SupaDB_Goals;
      SupaDB --> SupaDB_Views;
      SupaDB --> SupaRPCs;

      SupabaseSDK -- Query Views/Tables or Call RPCs --> SupaDB_Views;
      SupabaseSDK -- Query Views/Tables or Call RPCs --> SupaRPCs;
      SupabaseSDK -- Query Tables --> SupaDB_Planner;
      SupabaseSDK -- Query Tables --> SupaDB_Review;
      SupabaseSDK -- Query Tables --> SupaDB_Goals;

      classDef component fill:#E8F8F5,stroke:#1ABC9C,stroke-width:1px;
      classDef cloudcomponent fill:#FADBD8,stroke:#C0392B,stroke-width:1px;
      class DashboardUI,DashboardState,SupabaseSDK component;
      class SupaAuth,SupaDB,SupaDB_Planner,SupaDB_Review,SupaDB_Goals,SupaDB_Views,SupaRPCs cloudcomponent;
  ```

- **B. Sequence Diagram - Loading Dashboard Data (using an RPC example):**

  ```mermaid
  sequenceDiagram
      actor User
      participant FlutterApp as Athena App (Dashboard Screen)
      participant SupabaseClient as Supabase Flutter SDK
      participant GetDashboardDataRPC as Supabase RPC (get_user_dashboard_data)
      participant Database as Supabase Database (Multiple Tables)

      User->>FlutterApp: Navigates to Dashboard Screen
      FlutterApp->>FlutterApp: Show Loading State
      FlutterApp->>SupabaseClient: supabase.rpc('get_user_dashboard_data', params: {'p_user_id': userId})
      SupabaseClient->>GetDashboardDataRPC: Execute RPC

      GetDashboardDataRPC->>Database: Query study_sessions
      Database-->>GetDashboardDataRPC: Upcoming Sessions Data

      GetDashboardDataRPC->>Database: Query quiz_items (or summary view)
      Database-->>GetDashboardDataRPC: Due Review Items Data

      GetDashboardDataRPC->>Database: Query study_goals
      Database-->>GetDashboardDataRPC: Active Goals Data

      GetDashboardDataRPC->>GetDashboardDataRPC: Aggregate Data into JSON
      GetDashboardDataRPC-->>SupabaseClient: Returns Aggregated JSON
      SupabaseClient-->>FlutterApp: Dashboard Data

      FlutterApp->>FlutterApp: Parse JSON and Update UI State
      FlutterApp->>FlutterApp: Hide Loading State
      FlutterApp->>User: Display Populated Dashboard
  ```

- **C. (Conceptual) Dashboard UI Layout Sketch:**
  _(This would be a visual sketch/wireframe in your report, but for Mermaid, we can list components):_

  ```mermaid
  graph LR
      DashboardScreen["Dashboard Screen (ScrollView)"]

      Header["Header: Welcome [User]"]
      Card_TodayFocus["Card: Today's Focus (Sessions Due, Reviews Due)"]
      Card_Planner["Card: Planner At a Glance (Next 2-3 Sessions)"]
      Card_ReviewStats["Card: Review System Snapshot (Mastered Items, Accuracy Chart)"]
      Card_ActiveGoals["Card: Active Study Goals"]
      Card_RecentActivity["(Optional) Card: Recent Activity Feed"]

      DashboardScreen --> Header
      DashboardScreen --> Card_TodayFocus
      DashboardScreen --> Card_Planner
      DashboardScreen --> Card_ReviewStats
      DashboardScreen --> Card_ActiveGoals
      DashboardScreen --> Card_RecentActivity

      Card_TodayFocus --> QuickLink_StartReview["Button: Start Review"]
      Card_TodayFocus --> QuickLink_ViewPlan["Button: View Today's Plan"]
      Card_Planner --> NavLink_FullPlanner["Link: Go to Full Planner"]
      Card_ReviewStats --> NavLink_FullReview["Link: Go to Review System"]
  ```

This User Dashboard ties everything together, providing a central point of interaction and feedback for the user. It's a feature that really enhances the perceived completeness and utility of the application. Using Supabase Views or RPCs can greatly simplify the client-side logic for data fetching and improve performance.

With this, we've covered the 6 primary functional areas envisioned for Athena! The next steps would involve thinking about overall app structure, navigation (e.g., BottomNavigationBar to switch between Dashboard, Planner, Review, Chatbot), settings, and any additional smaller features or polish.

How does this dashboard concept sit with you? Do you feel this completes the core set of features we need to detail for the CW2 report structure?

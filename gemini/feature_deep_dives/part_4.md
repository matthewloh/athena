# Athena: Feature Deep Dive & Design Foundation 4. Adaptive Review System (Quizzes & Spaced Repetition)

Okay, excellent! We've covered User Authentication, the AI Chatbot, and Study Material Management. Now, let's dive into
**Part 4: Adaptive Review System (Quizzes & Spaced Repetition)**.

This feature is a cornerstone of Athena's promise to enhance learning and knowledge retention. It leverages the study materials users input and provides a structured way to review them effectively. For CW2, this is a high-complexity feature demonstrating sophisticated logic, data management, and potentially another strong use of an LLM API (for question generation).

Here's the detailed breakdown for Part 4:

## 4. Adaptive Review System (Quizzes & Spaced Repetition)

**4.1. Purpose & Value:**
The Adaptive Review System aims to combat the Ebbinghaus forgetting curve by providing personalized and timely review sessions. It allows students to test their knowledge on their study materials, identifies areas of weakness, and schedules future reviews using spaced repetition principles. This active recall and spaced practice are proven methods for long-term knowledge retention. For CW2, this feature showcases significant UI complexity (flashcards, quiz interfaces), algorithmic complexity (spaced repetition), robust data persistence, and a potential "intensive" use of an LLM API if AI-driven question generation is implemented.

**4.2. User Stories / Key Use Cases:**

- **UC4.1 (Student - Create Quiz from Material):** As a student, I want to be able to select one of my uploaded study materials and have the system (or myself) generate a quiz (e.g., flashcards, MCQs) based on its content.
- **UC4.2 (Student - Create Manual Quiz/Flashcards):** As a student, I want to be able to manually create my own flashcards (term/definition) or simple quiz questions and answers.
- **UC4.3 (Student - Start Review Session):** As a student, I want to be able to start a review session that presents me with questions/flashcards due for review based on the spaced repetition schedule.
- **UC4.4 (Student - Answer Question/Flip Flashcard):** As a student, during a review session, I want to be able to answer a question or view a flashcard term, then reveal the answer/definition.
- **UC4.5 (Student - Self-Assess Performance):** As a student, after revealing an answer, I want to be able to indicate how well I knew it (e.g., "Easy," "Good," "Hard," "Again") so the system can adjust the next review schedule for that item.
- **UC4.6 (Student - View Quiz List):** As a student, I want to see a list of all my quizzes, perhaps with information about the number of items due for review in each.
- **UC4.7 (Student - View Progress/Stats):** As a student, I want to see my overall progress in the review system, such as items mastered, weak areas, and review streaks.
- **UC4.8 (System - Schedule Next Review):** As the system, based on the student's self-assessment for a quiz item, I need to calculate and store the next review date for that item using a spaced repetition algorithm.
- **UC4.9 (Student - AI-Generated Questions - _LLM Use_):** As a student, I want the option for the AI to automatically generate relevant questions (flashcards, MCQs) from my selected study material to save me time.

**4.3. Screen Mock-up Ideas & UI/UX Considerations:**

- **A. Review Dashboard / Quiz List Screen:**

  - **UI:**
    - A prominent section showing "Items Due for Review Today" with a "Start Review" button.
    - A `ListView` of all created quizzes/decks. Each item shows: Quiz Title, number of items, number of items due for review.
    - FAB to "Create New Quiz."
    - (Optional) Overall stats: total items, items mastered.
  - **UX:**
    - Clear call to action for starting a review.
    - Easy to see the status of different quiz decks.
    - Intuitive navigation to create or manage quizzes.

- **B. Create/Edit Quiz Screen:**

  - **UI:**
    - `TextField` for "Quiz Title."
    - Option to link to an existing `study_material` (if generating from notes).
    - **If AI Generation (UC4.9):**
      - Dropdown to select a `study_material`.
      - Button: "Generate Questions with AI."
      - Loading indicator while AI generates.
      - Display generated questions for user to review/edit/approve before saving.
    - **If Manual Creation (UC4.2):**
      - A list of question/answer pairs or term/definition pairs.
      - Buttons to "Add Question/Card."
      - `TextFields` for "Question/Term" and "Answer/Definition."
      - Option to reorder or delete individual questions/cards.
    - "Save Quiz" button.
  - **UX:**
    - Clear distinction between AI generation and manual creation.
    - User-friendly interface for adding/editing multiple Q&A pairs.
    - Feedback on AI generation progress and success/failure.

- **C. Review Session Screen (Flashcard Mode Example):**

  - **UI:**
    - Display the "front" of the flashcard (Term or Question).
    - A "Flip" or "Show Answer" button.
    - Once flipped, display the "back" (Definition or Answer).
    - Below the flipped card, buttons for self-assessment: e.g., "Again" (Hard), "Good," "Easy." (These map to spaced repetition intervals).
    - Progress bar or counter: "Card X of Y."
    - Option to "End Session."
  - **UX:**
    - Clean, focused interface to minimize distractions.
    - Smooth animations for flipping cards.
    - Clear, distinct self-assessment buttons.
    - Immediate feedback or transition to the next card based on assessment.

- **D. Quiz Results / Session Summary Screen:**
  - **UI:**
    - Display number of items reviewed, number correct (if applicable, or distribution of "Easy/Good/Hard").
    - (Optional) List of items marked "Again" or "Hard" for quick re-review.
    - Button to "Return to Dashboard" or "Review Again."
  - **UX:**
    - Clear summary of performance.
    - Actionable next steps.

**4.4. Flutter Implementation Notes:**

- **Packages:**
  - `supabase_flutter`: For all database interactions.
  - State management (`flutter_bloc`, `riverpod`, `provider`): Crucial for managing quiz state, session progress, list of questions, current question, etc.
  - `flip_card` (or custom animation): For flashcard UI.
  - (Potentially) `charts_flutter` for progress visualization on the dashboard.
- **Widgets:** `ListView.builder`, `Card`, `PageView` (for swiping through flashcards), `Stack` (for card overlays), `ElevatedButton`, `TextButton`, `LinearProgressIndicator`.
- **Logic - Spaced Repetition (Core of "Adaptive"):**
  - Implement a simplified version of an algorithm like SM-2 or FSRS (Free Spaced Repetition Scheduler).
  - **Key Data per Item:** `easiness_factor` (EF), `interval` (days until next review), `repetitions` (number of times correctly recalled).
  - **When user self-assesses (e.g., rating 0-5 for quality of response):**
    - If quality < 3 (e.g., "Again"): Reset interval to 1 day, reset repetitions.
    - If quality >= 3:
      - Increment repetitions.
      - Calculate new interval:
        - Rep 1: Interval = 1 day
        - Rep 2: Interval = 6 days
        - Rep > 2: Interval = previous_interval \* EF
      - Update EF based on quality (e.g., `new_EF = old_EF - 0.8 + 0.28*quality - 0.02*quality^2`. Ensure EF doesn't drop below 1.3).
    - Store the `next_review_date` by adding the `interval` to the current date.
  - **Fetching items for review:** Query `quiz_items` where `next_review_date <= today`.

**4.5. Supabase Integration & Architecture:**

- **Supabase Database (PostgreSQL):**
  - **`quizzes` table:**
    - `id` (UUID, PK)
    - `user_id` (UUID, FK to `auth.users.id`)
    - `title` (TEXT)
    - `study_material_id` (UUID, FK to `study_materials.id`, Nullable - if quiz is based on a specific material)
    - `created_at` (TIMESTAMPTZ)
  - **`quiz_items` table (individual questions/flashcards):**
    - `id` (UUID, PK)
    - `quiz_id` (UUID, FK to `quizzes.id`)
    - `user_id` (UUID, FK to `auth.users.id` - for easier RLS and queries)
    - `item_type` (TEXT, e.g., 'flashcard', 'mcq')
    - `question_text` (TEXT)
    - `answer_text` (TEXT)
    - `mcq_options` (JSONB, Nullable - for MCQ type: `{"a": "Option A", "b": "Option B", ...}`)
    - `mcq_correct_option_key` (TEXT, Nullable - e.g., 'a')
    - **Spaced Repetition Fields:**
      - `easiness_factor` (NUMERIC, default 2.5)
      - `interval_days` (INTEGER, default 0)
      - `repetitions` (INTEGER, default 0)
      - `last_reviewed_at` (TIMESTAMPTZ, Nullable)
      - `next_review_date` (DATE, Nullable - index this field for performance)
    - `created_at` (TIMESTAMPTZ)
  - **RLS Policies:** Apply standard RLS ensuring users can only access/modify their own quizzes and quiz items.
- **Supabase Edge Functions (TypeScript/Dart) - Optional but Powerful:**
  - **Function Name:** `generate-quiz-questions`
  - **Purpose:** If implementing UC4.9 (AI-Generated Questions).
  - **Input:** `{ "study_material_id": "uuid", "num_questions": 5, "question_type": "flashcard" }`
  - **Authentication:** Enforce user authentication.
  - **Logic:**
    1. Fetch content of `study_material_id` (e.g., `summary_text` or `ocr_extracted_text`).
    2. Retrieve LLM API key (Supabase secret).
    3. Construct prompt for LLM: "Based on the following text, generate [num_questions] [question_type] questions. For flashcards, provide term and definition. For MCQs, provide question, 4 options (a,b,c,d), and indicate the correct option key. Text: [material_content]".
    4. Call LLM API.
    5. Parse LLM response into structured question data.
    6. Insert these new questions into the `quiz_items` table, associated with a new or existing `quizzes` record.
    7. Return the generated questions or success/failure status to Flutter app.

**4.6. LLM Integration Specifics (for UC4.9):**

- **Use Case:** Generating questions (flashcards, MCQs) from user's study materials.
- **Prompt Engineering:** Critical for getting well-formed questions.
  - Specify format clearly: "For flashcards, use 'Term: [term]\nDefinition: [definition]' format for each."
  - "For MCQs, use 'Question: [question]\n(A) [optionA]\n(B) [optionB]\n(C) [optionC]\n(D) [optionD]\nCorrect: [A/B/C/D]' format."
  - Adjust prompts to guide difficulty or topic focus if needed (more advanced).
- **Output Parsing:** The LLM response will be text. The Edge Function needs robust logic to parse this text into individual questions, answers, and options to store in the database correctly. Regular expressions or structured output requests (if supported by LLM and enabled by specific prompting) can help.

**4.7. Design Chart Suggestions (Mermaid):**

- **A. Use Case Diagram - Adaptive Review System:**

  ```mermaid
  graph TD
      actor Student
      subgraph "Athena App - Adaptive Review System"
          UC4_1["UC4.1: Create Quiz from Material"]
          UC4_9["UC4.9: AI Generates Questions (optional)"]
          UC4_2["UC4.2: Create Manual Quiz/Flashcards"]
          UC4_6["UC4.6: View Quiz List"]
          UC4_3["UC4.3: Start Review Session"]
          UC4_4["UC4.4: Answer Question / Flip Card"]
          UC4_5["UC4.5: Self-Assess Performance"]
          UC4_7["UC4.7: View Progress/Stats"]
      end
      actor System

      Student --> UC4_1
      UC4_1 -- includes (optional) --> UC4_9
      Student --> UC4_2
      Student --> UC4_6
      Student --> UC4_3
      Student --> UC4_4
      Student --> UC4_5
      Student --> UC4_7

      UC4_9 -.-> SEF_GenQuiz(Supabase Edge Function: generate-quiz-questions)
      SEF_GenQuiz -.-> LLM_API
      SEF_GenQuiz -.-> SDB_QI(Supabase DB - quiz_items)

      UC4_1 -.-> SDB_Q(Supabase DB - quizzes)
      UC4_1 -.-> SDB_QI
      UC4_2 -.-> SDB_Q
      UC4_2 -.-> SDB_QI
      UC4_6 -.-> SDB_Q
      UC4_3 -.-> SDB_QI // Fetch due items

      System -- UC4.8: Schedule Next Review --> SDB_QI
      UC4_5 -- triggers --> System

      classDef actor fill:#D6EAF8,stroke:#2E86C1,stroke-width:2px;
      classDef usecase fill:#E8F8F5,stroke:#1ABC9C,stroke-width:2px;
      class Student,System actor;
      class UC4_1,UC4_9,UC4_2,UC4_6,UC4_3,UC4_4,UC4_5,UC4_7 usecase;
  ```

- **B. Activity Diagram - Spaced Repetition Logic during Review:**

  ```mermaid
  graph TD
      A[Start Review Session] --> B{Fetch Due Item from DB};
      B -- No More Items --> J[End Session];
      B -- Item Found --> C[Display Question/Term];
      C --> D{User Interacts (e.g., Taps 'Show Answer')};
      D --> E[Display Answer/Definition];
      E --> F{User Self-Assesses (e.g., Easy, Good, Hard)};
      F --> G[Calculate New EF, Interval, Reps];
      G --> H[Update next_review_date in DB for Item];
      H --> I{Any Items Remaining?};
      I -- Yes --> B;
      I -- No --> J;
  ```

- **C. Sequence Diagram - AI Question Generation for a Quiz:**

  ```mermaid
  sequenceDiagram
      actor User
      participant FlutterApp as Athena App (Flutter)
      participant SupabaseClient as Supabase Flutter SDK
      participant GenerateQuizFunc as Supabase Edge Function (generate-quiz-questions)
      participant StudyMaterialsDB as Supabase DB (study_materials)
      participant LLM_API as External LLM API
      participant QuizItemsDB as Supabase DB (quiz_items, quizzes)

      User->>FlutterApp: Selects Study Material & "Generate Quiz with AI"
      FlutterApp->>FlutterApp: Shows loading
      FlutterApp->>SupabaseClient: supabase.functions.invoke('generate-quiz-questions', body: {material_id, ...})
      SupabaseClient->>GenerateQuizFunc: Request

      GenerateQuizFunc->>StudyMaterialsDB: Fetch content for material_id
      StudyMaterialsDB-->>GenerateQuizFunc: Material Content

      GenerateQuizFunc->>LLM_API: Prompt + Content for Question Generation
      LLM_API-->>GenerateQuizFunc: Raw Text of Questions

      GenerateQuizFunc->>GenerateQuizFunc: Parse LLM Text into Structured Questions
      GenerateQuizFunc->>QuizItemsDB: Create Quiz Record in 'quizzes'
      GenerateQuizFunc->>QuizItemsDB: Insert Parsed Questions into 'quiz_items'
      QuizItemsDB-->>GenerateQuizFunc: Success

      GenerateQuizFunc-->>SupabaseClient: Returns Generated Questions / Success
      SupabaseClient-->>FlutterApp: Response
      FlutterApp->>FlutterApp: Hides loading
      FlutterApp->>FlutterApp: Displays generated questions for review/save
  ```

This Adaptive Review System is undoubtedly complex but also incredibly valuable for a learning app. Successfully implementing the spaced repetition logic and, optionally, the AI question generation will significantly contribute to the "Application Complexity" and "API Integration" marks.

How does this detailed plan for the Adaptive Review System look to you? Ready to tackle the "Intelligent Study Planner" next?

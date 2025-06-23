# Adaptive Review System Feature (`feature/review`)

## 1. Overview

The Adaptive Review System is a core feature of the Athena application designed to enhance learning and knowledge retention through personalized and timely review sessions. It leverages spaced repetition principles and active recall techniques to combat the Ebbinghaus forgetting curve. Users can create quizzes from their study materials, engage in structured review sessions with flashcards and multiple-choice questions, and receive AI-generated questions to optimize their learning experience. The system intelligently schedules reviews based on user performance and proven learning science principles.

## 2. Key Responsibilities

- **Quiz Creation:** Allow users to create quizzes manually or generate them automatically from existing study materials using AI.
- **Spaced Repetition Algorithm:** Implement intelligent scheduling of review items based on user performance and spaced repetition principles (SM-2 algorithm).
- **Review Sessions:** Provide interactive review sessions with flashcards and multiple-choice questions.
- **Performance Tracking:** Monitor user progress, self-assessment, and learning analytics.
- **AI Integration:** Interface with backend LLM (via Supabase Edge Function) to generate relevant questions from study materials.
- **Data Persistence:** Store quiz data, review history, and spaced repetition metadata for long-term learning tracking.

## 3. Architecture & Key Components

This feature follows the Clean Architecture principles adopted by the Athena project, separating concerns into domain, data, and presentation layers.

### 3.1. Domain Layer (`lib/features/review/domain/`)

- **Entities:**
  - `QuizEntity.dart`: Represents a quiz collection (e.g., ID, title, subject, description, study material reference, creation timestamp).
  - `QuizItemEntity.dart`: Represents individual quiz items (flashcards, MCQs) with spaced repetition metadata (easiness factor, interval, repetitions, next review date).
  - `ReviewSessionEntity.dart`: Represents a review session with performance metrics and session progress.
  - `ReviewResponseEntity.dart`: Represents individual responses during review sessions with spaced repetition data.
  - `QuizType` enum: Defines types of quiz items (`flashcard`, `multipleChoice`).
  - `DifficultyRating` enum: User self-assessment ratings (`again`, `hard`, `good`, `easy`).
  - `SessionType` enum: Types of review sessions (`mixed`, `dueOnly`, `newOnly`).
  - `SessionStatus` enum: Review session states (`active`, `completed`, `abandoned`).
- **Repositories:**
  - `ReviewRepository.dart` (Interface): Defines the contract for all review-related data operations, including:
    - Creating and managing quizzes.
    - Fetching quiz items due for review.
    - Updating spaced repetition metadata.
    - Generating AI-powered questions from study materials.
    - Managing review sessions and performance tracking.
- **Use Cases:**
  - `GetQuizzesUseCase.dart`: Fetches all quizzes for the user.
  - `CreateQuizUseCase.dart`: Creates a new quiz collection.
  - `GetDueItemsUseCase.dart`: Fetches quiz items due for review based on spaced repetition schedule.
  - `StartReviewSessionUseCase.dart`: Initiates a new review session.
  - `SubmitReviewResponseUseCase.dart`: Processes user responses and updates spaced repetition algorithm.
  - `GenerateAiQuestionsUseCase.dart`: Triggers AI generation of questions from study materials.
  - `GetReviewStatsUseCase.dart`: Retrieves user progress and learning analytics.

### 3.2. Data Layer (`lib/features/review/data/`)

- **Models:**
  - `QuizModel.dart`: Data Transfer Object (DTO) for quizzes, with `fromJson`/`toJson` for Supabase.
  - `QuizItemModel.dart`: DTO for quiz items including spaced repetition fields, with `fromJson`/`toJson` for Supabase.
  - `ReviewSessionModel.dart`: DTO for review sessions with performance metrics and session tracking.
  - `ReviewResponseModel.dart`: DTO for individual review responses with spaced repetition calculations.
- **Data Sources:**
  - `ReviewRemoteDataSource.dart` (Interface): Defines methods for interacting with the backend (Supabase).
  - `ReviewSupabaseDataSourceImpl.dart`: Concrete implementation using Supabase client to:
    - Perform CRUD operations on `quizzes` and `quiz_items` tables.
    - Fetch items due for review based on spaced repetition schedule.
    - Invoke Supabase Edge Function for AI question generation.
    - Update spaced repetition metadata after user responses.
- **Repositories:**
  - `ReviewRepositoryImpl.dart`: Implements `ReviewRepository`, coordinating with `ReviewRemoteDataSource` and handling data mapping between models and entities.

### 3.3. Presentation Layer (`lib/features/review/presentation/`)

- **Providers:**
  - `review_providers.dart`: Contains Riverpod providers for all review feature dependencies:
    - Use case providers (`getAllQuizzesUseCaseProvider`, `createQuizUseCaseProvider`, etc.)
    - Repository and data source providers
    - ViewModel providers for each screen's state management

- **ViewModels & State Management:**
  - `review_viewmodel.dart` & `review_state.dart`: 
    - Main review dashboard state management
    - Handles quiz list display, due items overview, and navigation to other screens
    - Manages loading states and error handling for quiz data
  
  - `create_quiz_viewmodel.dart` & `create_quiz_state.dart`:
    - Manages quiz creation flow (manual and AI-assisted)
    - Handles form validation, quiz metadata input, and initial question creation
    - Coordinates with AI question generation use cases
  
  - `edit_quiz_viewmodel.dart` & `edit_quiz_state.dart`:
    - Manages quiz editing operations (title, description, questions)
    - Handles adding/removing/modifying quiz items
    - Provides CRUD operations for existing quiz content
  
  - `review_session_viewmodel.dart` & `review_session_state.dart`:
    - Controls active review session flow and progress tracking
    - Manages question presentation, user responses, and spaced repetition calculations
    - Handles session completion and performance metrics
  
  - `quiz_results_viewmodel.dart` & `quiz_results_state.dart`:
    - Displays session completion summary and performance analytics
    - Shows spaced repetition adjustments and next review scheduling
    - Provides navigation back to dashboard or start new session

- **Views (Screens):**
  - `review_screen.dart`: Main dashboard showing quiz overview, due items count, and quick access to review sessions
  - `create_quiz_screen.dart`: Interface for creating new quizzes with title, subject, description, and initial questions
  - `edit_quiz_screen.dart`: Screen for modifying existing quiz metadata and managing quiz items
  - `review_session_screen.dart`: Interactive review session with flashcard/MCQ presentation and difficulty rating
  - `quiz_results_screen.dart`: Session summary displaying performance metrics, completion stats, and next review schedule

- **Widgets:**
  - `quiz_card.dart`: Displays quiz information cards with due items count, subject, and quick action buttons
  - `flashcard.dart`: Interactive flashcard component with flip animation and self-assessment controls
  - `multiple_choice_widget.dart`: Multiple-choice question interface with option selection and answer validation
  - `progress_indicator.dart`: Shows review session progress, completion percentage, and time elapsed
  - `difficulty_buttons.dart`: Self-assessment buttons for spaced repetition feedback (Again, Hard, Good, Easy)
  - `review_stats_widget.dart`: Displays learning analytics, streak information, and progress metrics

### 3.4. Backend Integration (Supabase)

- **Tables:**
  - `quizzes`: Stores quiz metadata (`id`, `user_id`, `title`, `subject`, `description`, `study_material_id`, `created_at`, `updated_at`).
  - `quiz_items`: Stores individual quiz items with spaced repetition fields:
    - Basic fields: `id`, `quiz_id`, `user_id`, `item_type`, `question_text`, `answer_text`
    - MCQ fields: `mcq_options` (JSONB), `mcq_correct_option_key`
    - Spaced repetition fields: `easiness_factor`, `interval_days`, `repetitions`, `last_reviewed_at`, `next_review_date`
  - `review_sessions`: Tracks review session metadata and performance metrics (`id`, `user_id`, `quiz_id`, `session_type`, `total_items`, `completed_items`, `correct_responses`, `average_difficulty`, `session_duration_seconds`, `status`, `started_at`, `completed_at`).
  - `review_responses`: Records individual responses during review sessions with spaced repetition calculations (`id`, `session_id`, `quiz_item_id`, `user_id`, `difficulty_rating`, `response_time_seconds`, `user_answer`, `is_correct`, `previous_*`, `new_*`, `responded_at`).
- **Edge Function:**
  - `generate-quiz-questions`: TypeScript Edge Function responsible for:
    - Receiving study material content and question generation parameters.
    - Calling external LLM API (Gemini, OpenAI) via Vercel AI SDK.
    - Parsing LLM responses into structured question data.
    - Storing generated questions in the database.

## 4. State Management

- **Riverpod:** Used for all state management within the review feature.
  - `reviewViewModelProvider` provides access to the `ReviewViewModel`.
  - Other providers manage dependencies for use cases, repositories, and data sources.
  - State includes quiz lists, current review session, due items, and user progress metrics.

## 5. Spaced Repetition Algorithm

The system implements a simplified version of the SM-2 (SuperMemo 2) algorithm:

- **Key Metrics per Item:**
  - `easiness_factor` (EF): Determines how easy an item is to remember (default: 2.5)
  - `interval_days`: Days until next review
  - `repetitions`: Number of successful consecutive reviews
  - `next_review_date`: Calculated next review date

- **Algorithm Logic:**
  - **Rating < 3 (Again/Hard):** Reset interval to 1 day, reset repetitions to 0
  - **Rating ≥ 3 (Good/Easy):**
    - Increment repetitions
    - Calculate new interval:
      - Repetition 1: 1 day
      - Repetition 2: 6 days
      - Repetition > 2: previous_interval × EF
    - Update EF: `new_EF = old_EF - 0.8 + 0.28×quality - 0.02×quality²` (minimum EF: 1.3)

## 6. AI Integration

- **Use Case:** Generate questions (flashcards, MCQs) from user's study materials
- **Prompt Engineering:** 
  - Structured prompts for consistent question format
  - Support for different question types (flashcards, multiple-choice)
  - Content-aware generation based on study material context
- **Output Parsing:** Robust parsing of LLM responses into structured question data
- **Quality Control:** User review and editing of AI-generated questions before saving

## 7. Current Status

- **Architecture Planned:** Complete domain, data, and presentation layer architecture defined.
- **Database Schema:** ✅ **COMPLETED** - Detailed Supabase table schemas for quizzes and quiz items with spaced repetition support. Enhanced with `subject` and `description` fields for flexible quiz categorization.
- **Algorithm Design:** Spaced repetition algorithm (SM-2) specification completed.
- **UI/UX Design:** Comprehensive screen layouts and user interaction flows planned.
- **AI Integration Plan:** Edge function design for LLM-powered question generation.

## 8. Next Steps & To-Do

- **Database Implementation:** ✅ **COMPLETED**
  - ✅ Created and implemented `quizzes`, `quiz_items`, `review_sessions`, and `review_responses` table schemas in Supabase.
  - ✅ Enhanced `quizzes` table with `subject` and `description` fields for better categorization.
  - ✅ Set up proper RLS policies for user data isolation.
  - ✅ Created database indexes for performance optimization (especially `next_review_date`).

- **Core Feature Development:**
  - Implement domain layer entities and use cases.
  - Create Supabase data source implementation with CRUD operations.
  - Develop spaced repetition algorithm logic in the repository layer.
  - Build review view model with state management.

- **UI Implementation:**
  - Create review dashboard with quiz overview and due items display.
  - Implement interactive flashcard widget with flip animations.
  - Build multiple-choice question interface.
  - Develop quiz creation screens (manual and AI-assisted).
  - Create review session flow with progress tracking.

- **AI Integration:**
  - Develop Supabase Edge Function for question generation.
  - Implement LLM API integration with proper prompt engineering.
  - Create robust parsing logic for LLM responses.
  - Build user interface for AI question generation workflow.

- **Advanced Features:**
  - Implement learning analytics and progress visualization.
  - Add review session customization options.
  - Create export/import functionality for quiz data.
  - Develop collaborative quiz sharing features.

- **Testing & Polish:**
  - Implement comprehensive unit and widget tests.
  - Conduct user testing for review session UX.
  - Optimize performance for large quiz collections.
  - Add accessibility features for inclusive learning.

## 9. Technical Considerations

- **Performance:** Efficient querying of due items using database indexes and optimized spaced repetition calculations.
- **Offline Support:** Consider caching strategies for review sessions in offline scenarios.
- **Data Migration:** Plan for future algorithm improvements and data schema evolution.
- **Analytics:** Track learning patterns and system effectiveness for continuous improvement.
- **Scalability:** Design for users with large numbers of quizzes and review items.

## 10. Enhanced Quiz Schema

The quiz system supports both study material-linked and standalone quizzes through enhanced schema design:

### **Quiz Fields:**
- **`title`** (required): The quiz name/title
- **`subject`** (optional): Subject categorization (e.g., "Mathematics", "Biology", "History")
- **`description`** (optional): Additional context or notes about the quiz
- **`study_material_id`** (optional): Link to existing study material

### **Use Cases:**
- **Linked to Study Material:**
  - Create quizzes directly from selected study material content.
  - Include/exclude specific sections of the material.
  - Generate initial questions (flashcards, MCQs) based on the material.

- **Standalone Quizzes:**
  - Manually create quizzes without linking to study materials.
  - Use for self-assessment, exam preparation, or topic revision.
  - Full control over question content and structure.

- **AI-Assisted Creation:**
  - Option to use AI for generating quiz questions from study materials.
  - Review and edit AI-generated questions before saving.

- **Flexible Review Sessions:**
  - Review based on due items from all quizzes or specific subjects/topics.
  - Mixed review sessions with new and previously learned items.
  - Customizable session length and difficulty level.

## 11. Database Schema Details

The review system uses 4 main tables to support comprehensive spaced repetition and session tracking:

### **Core Tables:**

#### **1. `quizzes` Table:**
- **Purpose**: Stores quiz collections and metadata
- **Key Fields**: `id`, `user_id`, `title`, `subject`, `description`, `study_material_id`
- **Features**: Supports both study material-linked and standalone quizzes

#### **2. `quiz_items` Table:**
- **Purpose**: Individual quiz items (flashcards/MCQs) with spaced repetition data
- **Key Fields**: `question_text`, `answer_text`, `mcq_options`, `easiness_factor`, `interval_days`, `repetitions`, `next_review_date`
- **Features**: Full SM-2 algorithm support, flexible question types

#### **3. `review_sessions` Table:**
- **Purpose**: Tracks review session metadata and performance metrics
- **Key Fields**: `session_type`, `total_items`, `completed_items`, `correct_responses`, `average_difficulty`, `session_duration_seconds`, `status`
- **Features**: Session progress tracking, performance analytics, session types (mixed/due only/new only)

#### **4. `review_responses` Table:**
- **Purpose**: Records individual item responses with spaced repetition calculations
- **Key Fields**: `difficulty_rating`, `response_time_seconds`, `user_answer`, `is_correct`, `previous_*`, `new_*`
- **Features**: Detailed response tracking, before/after spaced repetition values for analytics

### **Schema Benefits:**
- **Complete Audit Trail**: Every response and calculation is recorded
- **Performance Analytics**: Detailed session and response metrics
- **Flexible Session Types**: Support for different review strategies
- **Historical Analysis**: Track learning progress over time
- **Algorithm Transparency**: Before/after values for spaced repetition calculations

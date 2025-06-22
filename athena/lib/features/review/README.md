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
  - `QuizEntity.dart`: Represents a quiz collection (e.g., ID, title, study material reference, creation timestamp).
  - `QuizItemEntity.dart`: Represents individual quiz items (flashcards, MCQs) with spaced repetition metadata (easiness factor, interval, repetitions, next review date).
  - `ReviewSessionEntity.dart`: Represents a review session with performance metrics and session progress.
  - `QuizType` enum: Defines types of quiz items (`flashcard`, `multipleChoice`).
  - `DifficultyRating` enum: User self-assessment ratings (`again`, `hard`, `good`, `easy`).
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
  - `ReviewSessionModel.dart`: DTO for review sessions with performance metrics.
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

- **ViewModel / Providers:**
  - `ReviewViewModel.dart` (extends `AsyncNotifier`):
    - Manages the state of the review system UI (`ReviewState`).
    - Handles quiz creation, review session management, and progress tracking.
    - Implements spaced repetition algorithm logic for scheduling reviews.
    - Interacts with domain layer use cases.
    - Provides methods like `loadQuizzes`, `createQuiz`, `startReviewSession`, `submitResponse`, `generateAiQuestions`.
  - `review_providers.dart`: Contains Riverpod providers for the `ReviewViewModel`, use cases, repository, and data source.
  - `ReviewState`: Helper class to hold UI state (list of quizzes, current review session, due items count, loading status, error status).
  - `ReviewError`: Helper class for specific error messages related to review operations.
- **Views (Screens):**
  - `review_dashboard_screen.dart`: Main dashboard showing quiz overview, due items, and progress statistics.
  - `create_quiz_screen.dart`: Interface for creating new quizzes manually or with AI assistance.
  - `review_session_screen.dart`: Interactive review session with flashcards and multiple-choice questions.
  - `quiz_results_screen.dart`: Session summary and performance feedback.
- **Widgets:**
  - `QuizCard.dart`: Displays quiz information with due items count and access to review sessions.
  - `FlashcardWidget.dart`: Interactive flashcard component with flip animation and self-assessment controls.
  - `MultipleChoiceWidget.dart`: Multiple-choice question interface with option selection.
  - `ProgressIndicator.dart`: Shows review session progress and completion status.
  - `DifficultyButtons.dart`: Self-assessment buttons for spaced repetition feedback.
  - `ReviewStatsWidget.dart`: Displays learning analytics and progress metrics.

### 3.4. Backend Integration (Supabase)

- **Tables:**
  - `quizzes`: Stores quiz metadata (`id`, `user_id`, `title`, `study_material_id`, `created_at`, `updated_at`).
  - `quiz_items`: Stores individual quiz items with spaced repetition fields:
    - Basic fields: `id`, `quiz_id`, `user_id`, `item_type`, `question_text`, `answer_text`
    - MCQ fields: `mcq_options` (JSONB), `mcq_correct_option_key`
    - Spaced repetition fields: `easiness_factor`, `interval_days`, `repetitions`, `last_reviewed_at`, `next_review_date`
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
- **Database Schema:** Detailed Supabase table schemas for quizzes and quiz items with spaced repetition support.
- **Algorithm Design:** Spaced repetition algorithm (SM-2) specification completed.
- **UI/UX Design:** Comprehensive screen layouts and user interaction flows planned.
- **AI Integration Plan:** Edge function design for LLM-powered question generation.

## 8. Next Steps & To-Do

- **Database Implementation:**
  - Create and implement `quizzes` and `quiz_items` table schemas in Supabase.
  - Set up proper RLS policies for user data isolation.
  - Create database indexes for performance optimization (especially `next_review_date`).

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

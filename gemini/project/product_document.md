# Athena Application - Product & Progress Document

## 1. Overview

This document tracks the development progress of the Athena AI-powered study companion. It provides a feature-by-feature breakdown based on the detailed plans in the `@gemini/feature_deep_dives/` documents, outlining the current status, implemented components, and upcoming work.

**Current Overall Status:**

- **Part 1 (Authentication & Profile)**: Partially Complete (Missing Password Reset, Deep-linking Email Verification, Profile Picture Upload).
- **Part 2 (AI Chatbot)**: Not Started.
- **Part 3 (Study Material Management)**: Not Started.
- **Part 4 (Adaptive Review System)**: Not Started.
- **Part 5 (Intelligent Study Planner)**: Not Started.
- **Part 6 (User Dashboard)**: Not Started.

## 2. Core Architecture & Code Expectations

The Athena application follows a structured and modern development approach:

### 2.1. Frontend (Flutter - Dart)

- **Location:** All Flutter code resides within the `athena/` subdirectory of the repository.
- **Main Directory (`athena/lib/`)**:
  - **`core/`**: Houses shared, application-wide logic and utilities.
    - `constants/`: e.g., `app_route_names.dart` for GoRouter paths.
    - `errors/`: Custom `failures.dart`, `exceptions.dart`.
    - `models/`: Shared data models.
    - `providers/`: Global Riverpod providers (e.g., `supabase_providers.dart`).
    - `router/`: `app_router.dart` using GoRouter for navigation.
    - `theme/`: `app_colors.dart`, global ThemeData.
    - `utils/`: Helper functions.
    - `widgets/`: Common reusable widgets.
  - **`features/`**: Contains individual feature modules. Each feature adheres to a Clean Architecture-inspired layered approach:
    - **`feature_name/`**
      - **`data/`**: Data sourcing and concrete implementations.
        - `datasources/`: Abstract definitions and Supabase implementations (e.g., `auth_remote_datasource.dart`, `auth_supabase_datasource.dart`).
        - `models/`: Data Transfer Objects (DTOs).
        - `repositories/`: Concrete repository implementations (e.g., `auth_repository_impl.dart`).
      - **`domain/`**: Core business logic, independent of UI and data.
        - `entities/`: Business objects (e.g., `user_entity.dart`).
        - `repositories/`: Abstract repository interfaces (e.g., `auth_repository.dart`).
        - `usecases/`: Business operations (e.g., `login_usecase.dart`, `get_user_profile_usecase.dart`).
      - **`presentation/`**: UI and user interaction.
        - `viewmodel/` or `provider/`: Riverpod ViewModels/Notifiers (e.g., `auth_viewmodel.dart`).
        - `views/` or `screens/`: Flutter widgets for screens (e.g., `login_screen.dart`, `profile_screen.dart`).
        - `widgets/`: Feature-specific UI components.
- **State Management:** Riverpod is used for robust and scalable state management. Providers are typically defined in `features/feature_name/presentation/providers/` and `core/providers/`.
- **Navigation:** GoRouter handles all navigation, configured in `core/router/app_router.dart`. It supports auth-aware routing and deep linking.
- **UI Components:** `supabase_auth_ui` is utilized for pre-built authentication forms, customized as needed.

### 2.2. Backend & Database (Supabase)

- **Authentication:** Supabase Auth for user identity management.
- **Database:** Supabase PostgreSQL. The `pgvector` extension is planned for AI-related vector embeddings.
- **Storage:** Supabase Storage for file uploads (e.g., study materials).
- **Serverless Functions:** Supabase Edge Functions (TypeScript) will be used for backend logic, especially for interacting with LLMs.

### 2.3. AI Integration

- **LLM Abstraction:** Vercel AI SDK (planned for use within Supabase Edge Functions) to interface with various LLMs (e.g., Gemini, OpenAI).
- **Local AI/ML:** `google_mlkit_text_recognition` for OCR on device.

## 3. Feature Progress Breakdown

---

### **Part 1: User Authentication & Profile Management**

- **Reference:** `@gemini/feature_deep_dives/part_1.md`
- **Status:** 🚧 **Partially Complete** (Core functionality implemented)

- **Summary of Responsibilities:** Secure user account creation (email/password), login, logout, password reset (planned, not yet implemented), and basic profile management (name, preferred subjects).
- **Key Technologies Involved:** Flutter (Riverpod, GoRouter), Supabase Auth, Supabase PostgreSQL (`profiles` table), `supabase_auth_ui`.

- **Current Implementation Details & Progress:**

  - **User Authentication Flow:**
    - Landing Screen (`landing_screen.dart`): Provides options to login or signup.
    - Login Screen (`login_screen.dart`): Uses `SupaEmailAuth` from `supabase_auth_ui` for email/password login.
    - Signup Screen (`signup_screen.dart`): Uses `SupaEmailAuth` for email/password registration, including `full_name` metadata.
    - Auth state changes are managed by `AuthViewModel` and reflect in GoRouter for automatic redirection.
  - **Profile Management:**
    - `profiles` table in Supabase: Stores `id` (FK to `auth.users`), `full_name`, `preferred_subjects` (TEXT ARRAY), `updated_at`.
    - An SQL trigger `on_auth_user_created` automatically creates a new profile row when a new user signs up.
    - Profile Screen (`profile_screen.dart`): Allows authenticated users to view and update their `full_name` and `preferred_subjects`.
  - **State Management (`AuthViewModel`):**
    - Manages login, signup, logout states (loading, error, success).
    - Handles fetching and updating user profile data (`UserEntity` which includes `id`, `email`, `fullName`, `preferredSubjects`).
    - Integrates with `GetAuthStateChangesUsecase`, `LoginUsecase`, `SignUpUsecase`, `LogoutUsecase`, `GetUserProfileUsecase`, `UpdateUserProfileUsecase`.
  - **Domain Layer (`features/auth/domain/`):**
    - `UserEntity`: Defines the user model including profile fields.
    - `AuthRepository` (interface): Defines contracts for auth and profile operations.
    - Usecases: `GetAuthStateChangesUsecase`, `LoginUsecase`, `SignUpUsecase`, `LogoutUsecase`, `GetUserProfileUsecase`, `UpdateUserProfileUsecase`.
  - **Data Layer (`features/auth/data/`):**
    - `AuthRemoteDataSource` (interface) & `AuthSupabaseDataSourceImpl`: Implement data fetching/updates from Supabase Auth and the `profiles` table.
    - `AuthRepositoryImpl`: Implements `AuthRepository` interface, mapping data and handling errors.
  - **Routing (`core/router/app_router.dart`):**
    - Routes: `/landing`, `/login`, `/signup`, `/home`, `/profile`.
    - Auth-aware redirection protects `/home` and `/profile`.
    - Navigation to Profile screen from a placeholder Home screen.
  - **Core Files Created/Modified:**
    - `main.dart`: Supabase initialization, `ProviderScope`.
    - `core/theme/app_colors.dart`: Application color palette.
    - `core/constants/app_route_names.dart`: Route names.
    - `core/errors/failures.dart`, `core/errors/exceptions.dart`.
    - `core/providers/supabase_providers.dart` (implicitly used via `auth_providers.dart`).
    - `features/auth/presentation/providers/auth_providers.dart`: Riverpod providers for auth usecases, repository, datasource.
    - All files within `features/auth/` subdirectories.

- **File Structure (`athena/lib/features/auth/`):**

  - `data/datasources/auth_remote_datasource.dart`, `auth_supabase_datasource.dart`
  - `data/repositories/auth_repository_impl.dart`
  - `domain/entities/user_entity.dart`
  - `domain/repositories/auth_repository.dart`
  - `domain/usecases/...` (6 use case files)
  - `presentation/providers/auth_providers.dart`
  - `presentation/viewmodel/auth_viewmodel.dart`, `auth_viewmodel.g.dart`
  - `presentation/views/landing_screen.dart`, `login_screen.dart`, `signup_screen.dart`, `profile_screen.dart`

- **Next Steps / To-Do:**
  - Implement Password Reset functionality (requires UI, ViewModel logic, Usecase, Repository, Datasource method).
  - Implement Email Verification (with deep-linking considerations if default Supabase behavior isn't sufficient).
  - Allow users to upload/manage a Profile Picture (integrating with Supabase Storage).
  - Refine error handling and user feedback on ProfileScreen for update success/failure.

---

### **Part 2: AI Chatbot (Academic Assistance & LLM Integration)**

- **Reference:** `@gemini/feature_deep_dives/part_2.md`
- **Status:** 🟡 **Not Started**

- **Summary of Responsibilities:** Provide instant academic support via a chat interface. Answer questions, explain concepts, help with homework, and maintain conversation context. Store chat history.
- **Key Technologies Involved:** Flutter, Supabase Edge Functions (TypeScript) to securely call external LLM APIs (e.g., OpenAI, Gemini via Vercel AI SDK), Supabase PostgreSQL for `chat_history` table.

- **Current Implementation Details & Progress:**

  - No implementation yet.

- **File Structure (Expected):**

  - `athena/lib/features/chat/`
    - `data/datasources/chat_remote_datasource.dart` (for Supabase interactions)
    - `data/models/chat_message_model.dart`
    - `data/repositories/chat_repository_impl.dart`
    - `domain/entities/chat_message_entity.dart`, `conversation_entity.dart`
    - `domain/repositories/chat_repository.dart`
    - `domain/usecases/send_message_usecase.dart`, `get_chat_history_usecase.dart`
    - `presentation/providers/chat_providers.dart`
    - `presentation/viewmodel/chat_viewmodel.dart`
    - `presentation/views/chat_screen.dart`
    - `presentation/widgets/chat_bubble.dart`, `message_input_bar.dart`
  - `supabase/functions/chat-handler/index.ts` (or similar for Edge Function)

- **Next Steps / To-Do:**
  - Define Supabase schema for `chat_messages` and `conversations` tables.
  - Develop the Supabase Edge Function for LLM interaction.
  - Implement the Flutter domain, data, and presentation layers for the chat feature.
  - Design and build the chat UI.

---

### **Part 3: Study Material Management and Note Summarization (RAG & Content Management)**

- **Reference:** `@gemini/feature_deep_dives/part_3.md`
- **Status:** 🟡 **Not Started**

- **Summary of Responsibilities:** Allow users to add study materials (typed, text file, image OCR). View, manage, and request AI-generated summaries of these materials. Enable RAG for the AI Chatbot.
- **Key Technologies Involved:** Flutter, Supabase PostgreSQL for `study_materials` table (metadata, text, OCR content, summaries), Supabase Storage for file uploads, Supabase Edge Function for summarization via LLM, `google_mlkit_text_recognition` for OCR.

- **Current Implementation Details & Progress:**

  - No implementation yet.

- **File Structure (Expected):**

  - `athena/lib/features/study_material/` (similar layered structure)
  - `supabase/functions/summarize-material/index.ts` (Edge Function)

- **Next Steps / To-Do:**
  - Design `study_materials` table schema.
  - Implement file upload to Supabase Storage.
  - Integrate OCR for images.
  - Develop Edge Function for summarization.
  - Build Flutter UI for material management and display.

---

### **Part 4: Adaptive Review System (Quizzes & Spaced Repetition)**

- **Reference:** `@gemini/feature_deep_dives/part_4.md`
- **Status:** 🟡 **Not Started**

- **Summary of Responsibilities:** Enable users to create quizzes from study materials (manually or via AI generation) or create manual flashcards. Implement a spaced repetition system for reviewing quiz items. Track progress.
- **Key Technologies Involved:** Flutter, Supabase PostgreSQL for `quizzes` and `quiz_items` tables (including spaced repetition fields). Optional Supabase Edge Function for AI question generation.

- **Current Implementation Details & Progress:**

  - No implementation yet.

- **File Structure (Expected):**

  - `athena/lib/features/quiz/` (similar layered structure)
  - `athena/lib/features/flashcard/` (if treated separately, or combined)
  - `supabase/functions/generate-questions/index.ts` (Optional Edge Function)

- **Next Steps / To-Do:**
  - Design database schema for quizzes, items, and spaced repetition metadata.
  - Implement core spaced repetition algorithm.
  - Develop UI for quiz creation, taking, and review.
  - Optionally, integrate AI for question generation.

---

### **Part 5: Intelligent Study Planner**

- **Reference:** `@gemini/feature_deep_dives/part_5.md`
- **Status:** 🟡 **Not Started**

- **Summary of Responsibilities:** Allow users to create study goals and schedule study sessions with reminders. View planner/agenda. Mark sessions complete. Offer basic intelligent suggestions.
- **Key Technologies Involved:** Flutter, Supabase PostgreSQL for `study_goals` and `study_sessions` tables, `flutter_local_notifications` for reminders.

- **Current Implementation Details & Progress:**

  - No implementation yet.

- **File Structure (Expected):**

  - `athena/lib/features/planner/` (similar layered structure)

- **Next Steps / To-Do:**
  - Design database schema for goals and sessions.
  - Implement UI for creating/viewing study plans and sessions.
  - Integrate local notifications for reminders.

---

### **Part 6: User Dashboard & Progress Tracking**

- **Reference:** `@gemini/feature_deep_dives/part_6.md`
- **Status:** 🟡 **Not Started**

- **Summary of Responsibilities:** Provide a consolidated overview of user activities, achievements, and upcoming tasks. Aggregate data from Chatbot, Review System, Planner, and Material Management.
- **Key Technologies Involved:** Flutter, Supabase PostgreSQL (reading from multiple tables). Potential use of Supabase Database Views or RPC Functions for efficient data aggregation.

- **Current Implementation Details & Progress:**

  - No implementation yet.

- **File Structure (Expected):**

  - `athena/lib/features/dashboard/` (similar layered structure)

- **Next Steps / To-Do:**
  - Design data aggregation strategies (Views, RPCs).
  - Develop UI for displaying dashboard information, potentially with charts.

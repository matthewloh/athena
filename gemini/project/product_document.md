# Athena Application - Product & Progress Document

## 1. Overview

This document tracks the development progress of the Athena AI-powered study companion. It provides a feature-by-feature breakdown based on the detailed plans in the `@gemini/feature_deep_dives/` documents, outlining the current status, implemented components, and upcoming work.

**Current Overall Status:**

- **Part 1 (Authentication & Profile)**: Partially Complete (Core login/signup, profile view/edit, and email verification deep-linking functional. Missing Password Reset, Profile Picture Upload).
- **Part 2 (AI Chatbot)**: Not Started.
- **Part 3 (Study Material Management)**: 🚧 **Partially Complete** (UI Scaffold implemented).
- **Part 4 (Adaptive Review System)**: 🚧 **Partially Complete** (UI Scaffold implemented).
- **Part 5 (Intelligent Study Planner)**: Not Started.
- **Part 6 (User Dashboard)**: 🚧 **Partially Complete** (Home screen implemented with navigation).

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
- **Status:** 🚧 **Partially Complete** (Core functionality and email verification deep-linking implemented)

- **Summary of Responsibilities:** Secure user account creation (email/password), login, logout, password reset (planned, not yet implemented), email verification (deep-linking now functional), and basic profile management (name, preferred subjects).
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
  - Implement Password Reset functionality (requires UI, ViewModel logic, Usecase, Repository, Datasource method, and handling of associated deep links).
  - Allow users to upload/manage a Profile Picture (integrating with Supabase Storage).
  - Refine error handling and user feedback on ProfileScreen for update success/failure.

---

### **Part 2: AI Chatbot (Academic Assistance & LLM Integration)**

- **Reference:** `@gemini/feature_deep_dives/part_2.md`
- **Status:** 🟡 **Scaffolding Complete**

- **Summary of Responsibilities:** Provide instant academic support via a chat interface. Answer questions, explain concepts, help with homework, and maintain conversation context. Store chat history. Stream AI responses.
- **Key Technologies Involved:** Flutter (Riverpod, GoRouter), Supabase Edge Functions (TypeScript) to securely call external LLM APIs (e.g., OpenAI, Gemini via Vercel AI SDK), Supabase PostgreSQL for `chat_messages` and `conversations` tables.

- **Current Implementation Details & Progress:**

  - **Core Layers Scaffolded:**
    - **Domain Layer (`features/chatbot/domain/`):**
      - Entities: `ConversationEntity.dart`, `ChatMessageEntity.dart` (with `MessageSender` enum) created.
      - Repositories: `ChatRepository.dart` interface defined.
      - Use Cases: `GetConversationsUseCase.dart`, `GetChatHistoryUseCase.dart`, `SendMessageUseCase.dart`, `CreateConversationUseCase.dart` created (interfaces/placeholders).
    - **Data Layer (`features/chatbot/data/`):**
      - Models: `ConversationModel.dart`, `ChatMessageModel.dart` created (placeholder DTOs).
      - Data Sources: `ChatRemoteDataSource.dart` (interface), `ChatSupabaseDataSourceImpl.dart` (placeholder class) created.
      - Repositories: `ChatRepositoryImpl.dart` (placeholder class) created.
    - **Presentation Layer (`features/chatbot/presentation/`):**
      - ViewModel: `ChatViewModel.dart` (extends `AsyncNotifier`) implemented to manage `ChatState`.
        - Handles loading initial conversations and messages for an active conversation.
        - Manages sending messages and optimistically updates UI.
        - Includes logic for streaming AI responses (updates UI per chunk).
        - Uses `fold` to handle `Either` results from use cases.
        - Defines `ChatState` and `ChatError` helper classes.
      - Providers: `chat_providers.dart` set up to provide `ChatViewModel`, use cases, repository, and data source.
      - Views: `chatbot_screen.dart` created.
      - Widgets: `ChatBubble.dart`, `MessageInputBar.dart` created.
  - \*\*UI (`chatbot_screen.dart`):
    - Displays a list of messages using `ListView.builder` and `ChatBubble`.
    - Integrates `MessageInputBar` for user input.
    - Shows loading and error states based on `ChatViewModel`.
    - Includes a scroll-to-bottom functionality.
    - Basic AppBar with title and info dialog.
  - **Routing:**
    - Route to `ChatbotScreen` is defined in `app_router.dart` and accessible from the `HomeScreen`.
  - **Error Handling:**
    - `ChatViewModel` uses `AsyncValue` to represent loading/error/data states.
    - `ChatError` class is used for specific error messages within `ChatState`.
    - Use cases are expected to return `Either<Failure, SuccessType>`.
  - **README:**
    - `athena/lib/features/chatbot/README.md` created, detailing the feature's architecture, components, and status.

- **File Structure (`athena/lib/features/chatbot/`):**

  - `README.md`
  - `data/datasources/chat_remote_datasource.dart`, `chat_supabase_datasource.dart`
  - `data/models/chat_message_model.dart`, `conversation_model.dart`
  - `data/repositories/chat_repository_impl.dart`
  - `domain/entities/chat_message_entity.dart`, `conversation_entity.dart`
  - `domain/repositories/chat_repository.dart`
  - `domain/usecases/create_conversation_usecase.dart`, `get_chat_history_usecase.dart`, `get_conversations_usecase.dart`, `send_message_usecase.dart`
  - `presentation/providers/chat_providers.dart`, `chat_providers.g.dart`
  - `presentation/viewmodel/chat_viewmodel.dart`, `chat_viewmodel.g.dart`
  - `presentation/views/chatbot_screen.dart`
  - `presentation/widgets/chat_bubble.dart`, `message_input_bar.dart`
  - `supabase/functions/chat-handler/index.ts` (or similar for Edge Function - placeholder)

- **Next Steps / To-Do:**
  - Define Supabase schema for `chat_messages` and `conversations` tables.
  - Develop the Supabase Edge Function for LLM interaction (TypeScript, Vercel AI SDK).
  - Fully implement `ChatSupabaseDataSourceImpl.dart` to connect to Supabase tables and the Edge Function.
  - Fully implement `ChatRepositoryImpl.dart`.
  - Implement actual AI response streaming logic end-to-end.
  - Enhance conversation management (listing, selecting, starting new ones from UI).
  - Refine UI/UX, error handling, and loading states.

---

### **Part 3: Study Material Management and Note Summarization (RAG & Content Management)**

- **Reference:** `@gemini/feature_deep_dives/part_3.md`
- **Status:** 🚧 **Partially Complete** (UI Scaffold implemented)

- **Summary of Responsibilities:** Allow users to add study materials (typed, text file, image OCR). View, manage, and request AI-generated summaries of these materials. Enable RAG for the AI Chatbot.
- **Key Technologies Involved:** Flutter, Supabase PostgreSQL for `study_materials` table (metadata, text, OCR content, summaries), Supabase Storage for file uploads, Supabase Edge Function for summarization via LLM, `google_mlkit_text_recognition` for OCR.

- **Current Implementation Details & Progress:**

  - **UI Implementation:**
    - `MaterialsScreen` created with a clean, modern interface
    - Subject filter tabs for material categorization
    - Material cards with subject icons, titles, descriptions, and tags
    - Empty state UI with prompt to add materials
    - Modal sheet for adding materials with multiple input options (Type/Paste, Upload, Camera, Gallery)
    - Action buttons for AI summarization and quiz generation
  - **Navigation:**
    - Route added for materials screen, accessible from home screen

- **File Structure (Current):**

  - `athena/lib/features/study_materials/presentation/views/materials_screen.dart`

- **Next Steps / To-Do:**
  - Design `study_materials` table schema.
  - Implement file upload to Supabase Storage.
  - Integrate OCR for images.
  - Develop Edge Function for summarization.
  - Implement data layer (repositories, datasources) and domain layer (entities, usecases).
  - Connect UI to actual data sources and backend functionality.

---

### **Part 4: Adaptive Review System (Quizzes & Spaced Repetition)**

- **Reference:** `@gemini/feature_deep_dives/part_4.md`
- **Status:** 🚧 **Partially Complete** (UI Scaffold implemented)

- **Summary of Responsibilities:** Enable users to create quizzes from study materials (manually or via AI generation) or create manual flashcards. Implement a spaced repetition system for reviewing quiz items. Track progress.
- **Key Technologies Involved:** Flutter, Supabase PostgreSQL for `quizzes` and `quiz_items` tables (including spaced repetition fields). Optional Supabase Edge Function for AI question generation.

- **Current Implementation Details & Progress:**

  - **UI Implementation:**
    - `ReviewScreen` created with statistics dashboard showing due items, total items, and accuracy
    - Quick review button for items due today
    - Quiz set cards with detailed information:
      - Subject icons and category tags
      - Status indicators (Due items, Recently reviewed)
      - Item counts and last review dates
      - Action buttons for editing and reviewing
    - Empty state UI with prompt to create quizzes
    - Modal sheet for creating quizzes with multiple options (Manual Entry, AI Generated, Import)
  - **Navigation:**
    - Route added for review screen, accessible from home screen

- **File Structure (Current):**

  - `athena/lib/features/review/presentation/views/review_screen.dart`

- **Next Steps / To-Do:**
  - Design database schema for quizzes, items, and spaced repetition metadata.
  - Implement core spaced repetition algorithm.
  - Develop quiz creation, editing, and review functionality.
  - Implement data layer (repositories, datasources) and domain layer (entities, usecases).
  - Connect UI to actual data sources and backend functionality.
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
- **Status:** 🚧 **Partially Complete** (Home screen implemented)

- **Summary of Responsibilities:** Provide a consolidated overview of user activities, achievements, and upcoming tasks. Aggregate data from Chatbot, Review System, Planner, and Material Management.
- **Key Technologies Involved:** Flutter, Supabase PostgreSQL (reading from multiple tables). Potential use of Supabase Database Views or RPC Functions for efficient data aggregation.

- **Current Implementation Details & Progress:**

  - **UI Implementation:**
    - Redesigned `HomeScreen` with modern dashboard layout
    - Feature grid with cards for all major app functions:
      - AI Chatbot
      - Study Materials
      - Adaptive Review
      - Study Planner
    - Quick action cards for common tasks
    - Proper navigation to all feature screens
  - **Navigation:**
    - Home screen serves as the main hub for app navigation
    - Direct links to all major feature screens

- **File Structure (Current):**

  - `athena/lib/screens/home_screen.dart`
  - `athena/lib/features/home/README.md` (with implementation plan)

- **Next Steps / To-Do:**
  - Design data aggregation strategies (Views, RPCs).
  - Implement actual dashboard data fetching and display.
  - Connect the home screen widgets to real data from other features.
  - Add analytics and statistics summaries from other features.
  - Implement progress tracking and achievement displays.
  - Reorganize home screen code into the features/home directory structure.

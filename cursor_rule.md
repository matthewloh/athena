# Athena App - 6002CEM CW2 Project Rule

This rule outlines the "Athena" mobile application project for the 6002CEM Coursework 2.

## Project Overview

- **Application Name:** Athena
- **Concept:** An AI-powered study companion designed to enhance student learning.
- **Coursework:** 6002CEM Mobile App Development - Coursework 2 (CW2)
- **Team:** Matthew & Thor Wen Zheng

## Core Technologies

- **Frontend:** Flutter (Dart)
  - **State Management:** Riverpod
  - **Navigation:** GoRouter
  - **UI Components:** `supabase_auth_ui` for authentication forms.
- **Backend & Database:** Supabase
  - Authentication: Supabase Auth
  - Database: Supabase PostgreSQL with `pgvector` extension
  - Storage: Supabase Storage
  - Serverless Functions: Supabase Edge Functions (TypeScript)
- **AI Integration:**
  - Vercel AI SDK (for LLM abstraction, used within Supabase Edge Functions)
  - LLM (e.g., Gemini, OpenAI - accessed via Vercel AI SDK)
- **Local Persistence:** Hive or sqflite for offline capabilities (planned).

## Project Architecture & Directory Structure

The project follows a structured approach to organize code within the `lib/` directory, separating core functionalities from feature-specific modules. This promotes
maintainability, scalability, and separation of concerns.

The **Athena Flutter project** is located within the `athena/` subdirectory of the overall repository. All Flutter-specific code, including the `lib/` directory, `pubspec.yaml`, etc., resides within `repo_root/athena/`.

### Current Directory Structure

```txt
athena/lib/
├── main.dart
├── core/
│   ├── constants/
│   ├── errors/
│   ├── providers/
│   ├── router/
│   └── theme/
├── features/
│   ├── auth/
│   ├── chatbot/
│   ├── home/
│   ├── navigation/
│   ├── planner/
│   ├── review/
│   └── study_materials/
├── screens/
└── services/
```

### Core Directory Structure

- **`athena/lib/core/`**: Contains shared code used across multiple features.
  - `constants/`: Application-wide constants (e.g., `app_route_names.dart`).
  - `errors/`: Defines custom error/failure classes (e.g., `failures.dart`).
  - `providers/`: Global Riverpod providers (e.g., `supabase_providers.dart` for Supabase client).
  - `router/`: Navigation setup using GoRouter (e.g., `app_router.dart`).
  - `theme/`: Application-wide theme configurations, colors, and styles (e.g., `app_colors.dart`).

### Features Directory Structure

- **`athena/lib/features/`**: Contains individual feature modules. Each feature follows a Clean Architecture-inspired layered approach:
  - **`auth/`**: Authentication and user profile management
  - **`chatbot/`**: AI-powered academic assistance
  - **`home/`**: Dashboard and navigation hub
  - **`navigation/`**: Navigation utilities
  - **`planner/`**: Study session scheduler
  - **`review/`**: Adaptive quiz system with spaced repetition
  - **`study_materials/`**: Study material management and AI summarization

### Feature Structure Pattern

Each feature directory should follow this layered structure:

- **`data/`**: Handles data sourcing and concrete implementations.
  - `datasources/`: Abstract definitions and implementations for fetching data.
  - `models/`: Data Transfer Objects (DTOs) specific to the data layer.
  - `repositories/`: Concrete implementations of repository interfaces.
- **`domain/`**: Contains core business logic, independent of UI and data layers.
  - `entities/`: Business objects/models for the feature.
  - `repositories/`: Abstract repository interfaces defining data contracts.
  - `usecases/`: Encapsulates specific business operations or user interactions.
- **`presentation/`**: Handles UI and user interaction, managed by ViewModels.
  - `viewmodel/` or `provider/`: Contains ViewModels/Notifiers that manage UI state.
  - `views/`: Flutter widgets representing full screens.
  - `widgets/`: UI components specific to this feature.

## Feature Status Summary

- **Part 1: User Authentication & Profile Management**

  - **Status:** Partially Complete
  - Core login/logout functionality and basic profile management implemented
  - Missing password reset and profile picture upload

- **Part 2: AI Chatbot (Academic Assistance & LLM Integration)**

  - **Status:** Not Started
  - Route and navigation from home screen established

- **Part 3: Study Material Management**

  - **Status:** UI Scaffold Implemented
  - Complete UI with material cards, filters, and add options
  - Missing backend integration and actual functionality

- **Part 4: Adaptive Review System**

  - **Status:** UI Scaffold Implemented
  - Complete UI with quiz sets, statistics, and creation dialog
  - Missing backend integration and actual functionality

- **Part 5: Intelligent Study Planner**

  - **Status:** Not Started
  - Route and navigation from home screen established

- **Part 6: User Dashboard & Progress Tracking**
  - **Status:** Initial Implementation (Basic HomeScreen)
  - Modern home screen with feature grid and quick actions
  - Missing real data aggregation and statistics

## Key Project Documents

The primary planning and tracking for the Athena project are managed in the `athena/` directory:

- **Project README:** @athena/README.md - General overview and objectives.
- **Feature List & Prioritization:** @athena/CW2_FEATURES.md - Detailed breakdown of app features, priorities, and alignment with CW2 requirements.
- **Technical Plan:** @athena/TECHNICAL_PLAN.md - Outlines the technical architecture, tools, and implementation strategies.
- **Rubric Mapping:** @athena/RUBRIC_MAPPING.md - Tracks alignment of project deliverables with the CW2 marking rubric.
- **Product Document:** `gemini/project/product_document.md` - Detailed progress tracking

## Feature Deep Dive Summaries

This section summarizes the core features of the Athena application:

- **Part 1: User Authentication & Profile Management**

  - Secure user account creation (email/password), login, logout, password reset, and basic profile management.

- **Part 2: AI Chatbot (Academic Assistance & LLM Integration)**

  - Instant academic support via chat interface with AI-powered responses and conversation history.

- **Part 3: Study Material Management**

  - Study material addition (typed, text file, image OCR), AI-generated summaries, and RAG integration.

- **Part 4: Adaptive Review System**

  - Quiz creation, flashcards, spaced repetition system, and progress tracking.

- **Part 5: Intelligent Study Planner**

  - Study goals, scheduled sessions with reminders, and intelligent scheduling suggestions.

- **Part 6: User Dashboard & Progress Tracking**
  - Overview of activities, achievements, upcoming tasks, and aggregated statistics.

## Implementation Guidelines

1. **Navigation and Screen Structure**

   - Main app navigation via GoRouter
   - Home screen as central navigation hub
   - Feature screens accessible via navigation links

2. **UI Component Consistency**

   - Consistent design language across all screens
   - Shared color scheme (primarily athenaPurple as the main brand color)
   - Consistent card styles with rounded corners and subtle elevation
   - Standardized button styles and action patterns

3. **Clean Architecture Implementation**
   - Separate data, domain, and presentation layers
   - Use repository pattern for data access
   - Implement use cases for business logic
   - Use ViewModels/Providers for UI state management

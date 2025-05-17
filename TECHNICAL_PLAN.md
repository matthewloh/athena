# Athena CW2: Technical Plan

This document outlines the proposed technical architecture, tools, and strategies for developing the Athena app.

## 1. Core Technology Stack

- **Framework:** Flutter
- **Language:** Dart

## 2. Project Structure

- (To be discussed: e.g., Feature-first, Layer-first - BLoC/Cubit, Provider, GetX for state management?)

## 3. Key Feature Implementation Strategies

### 3.1. AI Chatbot

- **LLM Integration:** Via Supabase Edge Function (TypeScript) utilizing the Vercel AI SDK.
  - The Vercel AI SDK will abstract LLM communication and handle streaming to the Flutter app.
  - The Supabase Edge Function will host this logic.
- **Vector Database:** `pgvector` extension in Supabase PostgreSQL for managing embeddings (e.g., for RAG capabilities or advanced summarization).
- **UI:** Chat interface (e.g., using `flutter_chat_ui` or custom).
- **State Management:** For conversation history, loading states.

### 3.2. Adaptive Review System

- **Quiz Logic:** Dart-based logic for generating questions (e.g., from user notes, or predefined sets initially), managing spaced repetition (e.g., basic SM-2 algorithm).
- **Data Models:** For questions, answers, user progress, review schedules.
- **UI:** Flashcard interface, quiz interface, progress display.

### 3.3. Intelligent Study Planner

- **Scheduling Logic:** Initially manual input, potential for dynamic suggestions based on user activity (P2/P3).
- **Data Models:** For tasks, schedules, deadlines.
- **Notifications:** `flutter_local_notifications` for reminders.
- **UI:** Calendar view / List view for tasks.

## 4. Data Persistence

- **Local Storage:**
  - Options: `sqflite` (SQL), `hive` (NoSQL). Hive is often simpler for Dart objects.
  - Use Cases: Storing user preferences, offline quiz data, study session history, planner schedules.
- **Cloud Storage (Supabase as primary candidate):**
  - `Supabase Authentication`: For user login/registration (Email/Password, Google Sign-In, etc.).
  - `Supabase Database (PostgreSQL)`: For user profiles, study plans, quiz data/progress, AI chat history (optional). Will utilize `pgvector` for AI-related vector storage.
  - `Supabase Storage`: For user-uploaded materials (if this feature is scoped in).
- **Authorization:** Ensure that cloud data access is properly secured using Supabase Row Level Security (RLS).

## 5. External APIs & Sensors

- **Requirement:** >1 external API or sensors intensively for 'Excellent'.
- **Candidate 1: LLM via Supabase Edge Function & Vercel AI SDK:** The Flutter app will call the Supabase Edge Function, which in turn interacts with an LLM. This constitutes the first major API integration.
- **Candidate 2 (to be decided):**
  - `Google ML Kit Text Recognition (OCR)`: For multimodal input (photo of text).
  - `Device Calendar API` (e.g., `add_2_calendar` package): To integrate study plans with device calendar.
  - `Device Sensors` (e.g., accelerometer/gyroscope for 'break time' suggestions, light sensor for screen adjustments - more experimental).
  - `Open-source education API` for supplementary content (if relevant and simple to integrate).

## 6. UI/UX Design

- **Theme:** Clean, modern, intuitive, and conducive to studying.
- **Color Palette:** To be decided (consider accessibility).
- **Navigation:** Clear and logical (e.g., BottomNavigationBar, Drawer).
- **Key Libraries:** `Material` / `Cupertino` widgets, potentially UI component libraries.

## 7. State Management

- (To be decided: Provider, BLoC/Cubit, Riverpod, GetX). Choice depends on team familiarity and project complexity.

## 8. Testing

- **Unit Tests:** For business logic (Dart).
- **Widget Tests:** For UI components (Flutter).
- **Integration Tests:** For app flows (Flutter).

## 9. Version Control

- **Git & GitHub:** For collaborative development and version tracking.

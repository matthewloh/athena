# Athena CW2: Rubric Alignment & Tracking

This document maps the Athena project features, technical choices, and report sections to the 6002CEM CW2 marking rubric to ensure comprehensive coverage and aim for high marks.

<!-- *(Based on CW2 Marking Scheme provided by Matthew)* -->

## I. Coverage & Functionalities (30%)

- **Criteria:** Application Complexity (UI interface elements, >3 screens, >3 features for 'Excellent').
- **Athena Alignment & Strategy:**
  - **>3 Screens:**
    1. Chatbot Screen
    2. Adaptive Review Screen (e.g., Flashcards/Quiz)
    3. Study Planner Screen
    4. User Dashboard/Profile Screen
    5. Settings Screen
    6. Login/Registration Screen
  - \*\*>3 Features (targeting P1 from `CW2_FEATURES.md`):
    1. AI Chatbot (High complexity: LLM integration, chat UI)
    2. Adaptive Review System (High complexity: Quiz logic, spaced repetition, local DB)
    3. Intelligent Study Planner (Med-High complexity: Scheduling UI, notifications, local DB)
    4. User Authentication (Med complexity: Firebase Auth, UI flow)
  - **UI Interface Elements:** Rich UI components will be used across all screens (text fields, buttons, lists, custom widgets for flashcards, calendar views, chat bubbles etc.).
- **Evidence in Report/VIVA:** Screenshots of all screens, detailed description of each feature, live demo of features.

## II. Application Complexity - Data Persistence/API Integration (10%)

- **Criteria:** Local or cloud persistence services with authorization. Use of more than one external API or sensors intensively for 'Excellent'.
- **Athena Alignment & Strategy:**
  - **Data Persistence:**
    - **Local:** `hive` or `sqflite` for offline quiz data, user progress, planner schedules, preferences. (Addresses "Local ... persistence")
    - **Cloud:** `Firebase Firestore` for user profiles, potentially syncing study plans/progress. (Addresses "cloud persistence services")
    - **Authorization:** `Firebase Authentication` for user login, securing Firestore data access with security rules. (Addresses "...with authorization")
  - **>1 External API/Sensors:**
    1. **LLM API (e.g., Gemini/OpenAI):** For AI Chatbot (Intensive use for Q&A, summarization). (API 1)
    2. **Candidate API/Sensor 2 (from `TECHNICAL_PLAN.md`):**
       - `Google ML Kit Text Recognition (OCR)`: If multimodal photo input for chatbot is implemented. (API 2 - intensive if used for core input)
       - `Device Calendar API` (e.g., `add_2_calendar`): To sync study plans. (API 2 - potentially intensive if bidirectional sync or rich integration)
       - `flutter_local_notifications`: While a package, it interacts with the OS-level notification system (could be argued as using a device service/API implicitly). We should aim for a clearer external API if possible.
       - _Decision Needed: Select a strong second API/Sensor that can be demonstrated with intensive use._
- **Evidence in Report/VIVA:** Screenshots of database structure (local/cloud), code snippets for API integration, demo of data saving/loading, user login, API calls and responses.

## III. Application UI Design (20%)

- **Criteria:** User-friendly, easy to understand, suitable color palettes, appropriate for purpose.
- **Athena Alignment & Strategy:**
  - **User-Friendly & Easy to Understand:** Intuitive navigation (BottomNav/Drawer), clear labeling, consistent design patterns.
  - **Suitable Color Palettes:** Choose a palette that is modern, calming, and accessible (contrast checks).
  - **Appropriate for Purpose (Study App):** Design should be clean, focused, and minimize distractions.
- **Evidence in Report/VIVA:** Screenshots of all UI screens, justification for design choices in the report, live demo showcasing UI/UX flow.

## IV. Report - Contents (20%)

- **Criteria:** All required sections, clear, comprehensive, almost flawless explanations.
- **Athena Alignment & Strategy:** Systematically address each required section:
  - Cover Page (with GitHub link)
  - Table of Contents
  - Introduction (Project Aims, Athena Concept)
  - List of all app features & group member responsible (Table from `CW2_FEATURES.md`)
  - Description of functions for each module (Screenshots, Module Name, Student Responsible)
    - _Strategy: Each P1/P2 feature will be a "module"._
  - Strengths of the app (max 2 pages)
  - Limitations of the app (max 2 pages)
  - Future enhancements (max 1 page)
  - Personal Reflection from each member
- **Evidence:** The report itself.

## V. Report - Format (5%)

- **Criteria:** Complete, proper labels/captions, comprehensive screenshots.
- **Athena Alignment & Strategy:** Adhere strictly to the DOCX template. Ensure all figures/screenshots are labeled and referenced. Proofread carefully.
- **Evidence:** The report itself.

## VI. VIVA - Clarity, Relevance, Confidence (5%) & Q&A (10%)

- **Criteria:** Smooth, clear, confident presentation; outstanding knowledge in Q&A.
- **Athena Alignment & Strategy:**
  - **Preparation:** Rehearse the demo flow. Each member prepares to discuss their responsible modules.
  - **Content:** Demonstrate live app, navigation, features with test data, showcase sensors/APIs, explain database interactions, highlight complexity.
  - **Q&A Prep:** Anticipate questions on technical choices, challenges, limitations, future work.
- **Evidence:** Performance during VIVA.

## Key Decisions for Rubric Alignment

1. **Finalize P1 Features:** Confirm the core >3 features that satisfy complexity and showcase Athena.
2. **Select Second API/Sensor:** Choose a strong candidate for the second API/sensor and plan for its "intensive use."
3. **Division of Labor:** Clearly assign features/modules to Matthew and Thor for development and reporting.

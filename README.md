# Athena - 6002CEM CW2 App Project

## Overview

Athena is an AI-powered study companion designed to enhance student learning through personalized academic support, adaptive review systems, and intelligent study planning. This comprehensive, user-friendly platform enables students to receive instant help with their studies, efficiently organize and review study materials, and manage their time effectively.

The app is being developed for the 6002CEM Mobile App Development Coursework 2 (CW2) by Matthew Loh Yet Marn and Thor Wen Zheng, with the concept originating from Thor Wen Zheng's CW1 report. Athena leverages AI/ML and cloud technologies to create a truly adaptive and personalized learning experience.

<div align="center">
  <img src="athena/assets/images/logo.png" alt="Logo" width="200" height="200">
  <h1 align="center" >Athena</h1>
  <h3 align="center">
    Your personal AI study companion, built with Flutter, Supabase, and Vercel AI SDK.
  </h3>
</div>

## Core Objectives (CW2)

- Design, develop, and test a functional mobile application using Flutter and Dart.
- Meet the requirements outlined in the CW2 brief, focusing on application complexity, data persistence, API integration, UI design, and comprehensive reporting.
- Align development efforts with the CW2 marking rubric to achieve high marks.

## Development Setup

### Prerequisites

- [Flutter](https://flutter.dev/docs/get-started/install) (latest stable version)
- [Supabase CLI](https://supabase.com/docs/guides/cli)
- [Docker](https://www.docker.com/products/docker-desktop/) (for running local Supabase)
- [Android Studio](https://developer.android.com/studio) with emulator or a physical device

### Setting Up Local Supabase

1. Install Supabase CLI:

   ```bash
   # macOS/Linux
   brew install supabase/tap/supabase

   # Windows
   scoop bucket add supabase
   scoop install supabase
   ```

2. Initialize and start a local Supabase project:

   ```bash
   # Navigate to project root
   cd athena_project

   # Start Supabase
   supabase start
   ```

3. Verify Supabase is running:

   - Studio UI should be available at: <http://localhost:54323>
   - API endpoint: <http://localhost:54321>

   ```bash
   supabase status
   ```

### Running the Flutter App

1. Ensure environment variables are set correctly in `athena/env.local.json`:

   ```json
   {
     "SUPABASE_URL": "http://127.0.0.1:54321",
     "SUPABASE_ANON_KEY": "your-anon-key"
   }
   ```

2. Run the app using VS Code launch configuration or:

   ```bash
   cd athena
   flutter run --dart-define-from-file=env.local.json
   ```

### Connecting Emulator to Local Supabase

When running on an Android emulator, you'll need to create a port forwarding to allow the emulator to access your local Supabase instance:

1. Make sure your emulator is running

2. Set up port forwarding:

   ```bash
   adb reverse tcp:54321 tcp:54321
   ```

3. For additional services, you may also need:

   ```bash
   adb reverse tcp:54323 tcp:54323  # For Supabase Studio
   ```

This creates a tunnel so when your app tries to connect to localhost:54321 inside the emulator, it gets forwarded to your development machine.

## Key Links

- [GitHub Repository](https://github.com/matthewloh/athena)

## Team Members

- [Matthew Loh Yet Marn](https://github.com/matthewloh)
- [Thor Wen Zheng](https://github.com/Vaneryn)

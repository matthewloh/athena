# Athena: Feature Deep Dive & Design Foundation

This document provides an in-depth exploration of Athena's key features, outlining UI/UX considerations, system architecture with Supabase and Flutter, LLM integration strategies, and suggestions for design charts to be included in your CW2 report.

## 1. User Authentication & Profile Management

**1.1. Purpose & Value:**
Securely managing user identity is fundamental. This allows for personalized experiences, data persistence, and controlled access to features. For Athena, it means each student's study materials, progress, and plans are their own. This directly addresses CW2 LO3 (Security Policy) and the rubric's requirement for "authorization."

**1.2. User Stories / Key Use Cases:**

- **UC1.1 (New User):** As a new student, I want to create an account easily using my email and a password so that I can start using Athena's features.
- **UC1.2 (Returning User):** As a returning student, I want to log in securely with my credentials to access my personalized dashboard and study materials.
- **UC1.3 (User):** As a logged-in student, I want to be able to log out of the application to protect my account on a shared device.
- **UC1.4 (User):** As a student, I want to be able to reset my password if I forget it.
- **UC1.5 (User):** As a student, I want to view and optionally edit basic profile information (e.g., name, preferred subjects - for personalization).

**1.3. Screen Mock-up Ideas & UI/UX Considerations:**

- **A. Splash Screen / Initial Screen:**
  - **UI:** Clean, welcoming design with Athena logo. Buttons: "Sign Up" and "Login."
  - **UX:** Clear calls to action. Option for "Continue as Guest" (limited functionality – consider if this fits CW2 scope or is a future enhancement).
- **B. Sign Up Screen:**
  - **UI:** Fields for Full Name, Email, Password (with confirmation), "Sign Up" button. Link to Terms & Conditions/Privacy Policy.
  - **UX:** Real-time validation for email format and password strength. Clear error messages. Loading indicator on submission.
- **C. Login Screen:**
  - **UI:** Fields for Email, Password, "Login" button. "Forgot Password?" link.
  - **UX:** Clear error messages for incorrect credentials. Loading indicator.
- **D. Forgot Password Screen:**
  - **UI:** Field for Email, "Send Reset Link" button.
  - **UX:** Confirmation message that a reset email has been sent (if email exists).
- **E. Profile Screen (Post-Login):**
  - **UI:** Display user's name and email. Editable fields for preferred subjects (multi-select chips or dropdown). "Save Changes" button. "Logout" button. "Delete Account" (consider for data privacy - advanced).
  - **UX:** Clear indication of editable fields. Confirmation on saving changes. Confirmation dialog before logout/delete.

**1.4. Flutter Implementation Notes:**

- **Packages:** `supabase_flutter` for Supabase integration, `flutter_bloc` or `provider` for state management (to manage auth state globally), `form_field_validator` for easy form validation.
- **Widgets:** `TextFormField` for input, `ElevatedButton` for actions, `Scaffold` for screen structure, `CircularProgressIndicator` for loading states.
- **Navigation:** Use Flutter's Navigator for screen transitions. Protect routes based on auth state.
- **State Management:** An `AuthBloc` or `AuthProvider` can listen to Supabase's `onAuthStateChange` stream to update the UI dynamically (e.g., redirect to home screen on successful login, or login screen on logout).

**1.5. Supabase Integration & Architecture:**

- **Supabase Auth:**
  - Handles user creation (`supabase.auth.signUp()`), login (`supabase.auth.signInWithPassword()`), logout (`supabase.auth.signOut()`), password reset (`supabase.auth.resetPasswordForEmail()`), and session management (JWTs automatically handled by the SDK).
  - The `users` table is automatically managed by Supabase Auth.
- **Supabase Database (PostgreSQL):**
  - Create a `profiles` table:
    - `id` (UUID, primary key, references `auth.users.id` ON DELETE CASCADE) - This links your profile to the Supabase auth user.
    - `full_name` (TEXT)
    - `preferred_subjects` (ARRAY of TEXT, or link to a separate `subjects` table if subjects are predefined)
    - `updated_at` (TIMESTAMP WITH TIME ZONE, default `now()`)
  - **Row Level Security (RLS):**
    - Enable RLS on the `profiles` table.
    - Policy 1 (SELECT): Users can only select their own profile: `auth.uid() = id`.
    - Policy 2 (UPDATE): Users can only update their own profile: `auth.uid() = id`.
    - Policy 3 (INSERT): A new profile can be inserted if `auth.uid() = id`. (Often handled by a trigger function after user sign-up).
- **Supabase Functions (Optional for Profile Creation):**

  - You can create a Supabase Edge Function (triggered by `auth.users` table inserts) to automatically create a corresponding entry in your `profiles` table when a new user signs up. This keeps user creation atomic.
  - -- Example Trigger Function in SQL (run in Supabase SQL Editor)

    ```sql
    create function public.handle_new_user()
    returns trigger
    language plpgsql
    security definer set search_path = public
    as $$ begin insert into public.profiles (id, full_name) -- Add other default fields if any values (new.id, new.raw_user_meta_data->>'full_name'); -- Assuming full_name is passed in metadata during signup return new; end; $$;
    create trigger on_auth_user_created
    after insert on auth.users
    for each row execute procedure public.handle_new_user();
    ```

    (Note: Passing `full_name` during Supabase `signUp` requires sending it in the `data` parameter, which then appears in `raw_user_meta_data`)

**1.6. LLM Integration:**

- Not directly applicable to basic authentication, but user preferences from their profile (e.g., `preferred_subjects`) will be crucial context fed to the LLM in other features for personalization.

**1.7. Design Chart Suggestions (Mermaid):**

- **A. Use Case Diagram - Authentication & Profile:**

  ```mermaid
  graph TD
      actor User
      subgraph "Athena App - Authentication System"
          UC1_1["UC1.1: Sign Up"]
          UC1_2["UC1.2: Login"]
          UC1_3["UC1.3: Logout"]
          UC1_4["UC1.4: Reset Password"]
          UC1_5["UC1.5: Manage Profile"]
      end
      User --> UC1_1
      User --> UC1_2
      User --> UC1_3
      User --> UC1_4
      User --> UC1_5

      UC1_1 -.-> SA(Supabase Auth)
      UC1_2 -.-> SA
      UC1_3 -.-> SA
      UC1_4 -.-> SA
      UC1_5 -.-> SDB(Supabase DB - Profiles Table)

      classDef actor fill:#D6EAF8,stroke:#2E86C1,stroke-width:2px;
      classDef usecase fill:#E8F8F5,stroke:#1ABC9C,stroke-width:2px;
      class User actor;
      class UC1_1,UC1_2,UC1_3,UC1_4,UC1_5 usecase;
  ```

- **B. Sequence Diagram - User Login:**

  ```mermaid
  sequenceDiagram
      actor User
      participant FlutterApp as Athena App (Flutter)
      participant SupabaseClient as Supabase Flutter SDK
      participant SupabaseAuth as Supabase Auth Service

      User->>FlutterApp: Enters Email & Password
      User->>FlutterApp: Taps Login Button
      FlutterApp->>SupabaseClient: supabase.auth.signInWithPassword(email, password)
      SupabaseClient->>SupabaseAuth: POST /token?grant_type=password (credentials)
      SupabaseAuth-->>SupabaseClient: Returns JWT (Access Token, Refresh Token) / Error
      alt Login Successful
          SupabaseClient-->>FlutterApp: AuthChangeEvent (SignedIn, Session)
          FlutterApp->>FlutterApp: Update Auth State (e.g., BLoC/Provider)
          FlutterApp->>User: Navigate to Home Screen
      else Login Failed
          SupabaseClient-->>FlutterApp: AuthException
          FlutterApp->>User: Display Error Message (e.g., "Invalid credentials")
      end
  ```

- **C. Activity Diagram - New User Registration & Profile Creation:**

  ```mermaid
  graph TD
      A[Start] --> B{User Taps Sign Up};
      B --> C[Display Sign Up Screen];
      C --> D{User Enters Details (Name, Email, Pass)};
      D --> E{Validate Input};
      E -- Invalid --> D;
      E -- Valid --> F[Flutter App: supabase.auth.signUp()];
      F --> G{Supabase Auth: Create User in auth.users};
      G -- Success --> H[Supabase Trigger: handle_new_user()];
      H --> I[Supabase DB: Insert into profiles table];
      I --> J[Flutter App: AuthChangeEvent (SignedIn)];
      J --> K[Navigate to Home Screen];
      K --> L[End];
      G -- Failure --> M[Display Error to User];
      M --> C;
  ```

  This detailed breakdown for User Authentication should provide a strong foundation. Next, we can tackle the AI Chatbot with similar depth. How does this look so far? Are there any specific aspects of authentication you'd like to explore further before we move on?

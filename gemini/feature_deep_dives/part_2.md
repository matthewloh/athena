# Athena: Feature Deep Dive & Design Foundation

## 2. AI Chatbot (Academic Assistance & LLM Integration)

**2.1. Purpose & Value:**
The AI Chatbot is Athena's primary interface for providing instant, personalized academic support. It aims to answer student questions, explain concepts, help with homework, and potentially summarize notes (linking to the Study Material Management feature). Its value lies in providing on-demand assistance, reducing information search time, and offering a supportive, interactive learning tool. This directly addresses the CW1 problem statements regarding difficulty in accessing accurate information and the need for study support. For CW2, this feature showcases complexity in UI, backend logic (Edge Functions), and intensive API integration (LLM).

**2.2. User Stories / Key Use Cases:**

- **UC2.1 (Student with Question):** As a student, I want to type a question about a specific topic (e.g., "Explain photosynthesis") and receive a clear, concise explanation from the AI chatbot.
- **UC2.2 (Student with Homework Problem):** As a student, I want to describe a homework problem (e.g., "How do I solve this algebra equation: 2x + 5 = 11?") and get step-by-step guidance or the solution from the AI.
- **UC2.3 (Student Needing Clarification):** As a student, I want to ask follow-up questions if the AI's initial explanation is unclear, and have the AI remember the context of our conversation.
- **UC2.4 (Student Reviewing Notes):** As a student, I want to ask the AI questions specifically about my uploaded study materials (e.g., "In my 'Chapter 5 Biology Notes', what are the key differences between mitosis and meiosis?"). (This links to RAG capabilities).
- **UC2.5 (Student Seeking Encouragement - CW1 Vision):** As a student feeling stuck, I want the AI to respond empathetically and offer encouragement if my query indicates frustration. (This is an advanced "emotional awareness" aspect; for CW2, a simpler, positive default tone might be more feasible).
- **UC2.6 (Student):** As a student, I want to be able to view my past chat conversations with the AI for later review.

**2.3. Screen Mock-up Ideas & UI/UX Considerations:**

- **A. Chat Interface Screen:**
  - **UI:**
    - Standard chat layout: Message bubbles (user on one side, AI on the other).
    - Text input field at the bottom with a "Send" button.
    - (CW1 Vision - simplify for CW2 MVP): Icons for alternative inputs like microphone (voice-to-text) or camera/gallery (image input for questions about diagrams/problems). For CW2, focus on robust text input first.
    - Timestamp for each message.
    - Clear indication of AI vs. User messages (e.g., different bubble colors, avatars).
    - Loading indicator when AI is "typing" or processing.
    - Scrollable conversation history.
    - Option to "Clear Chat" or start a "New Chat Session."
    - (Optional) "Copy" or "Share" individual AI messages.
    - (Optional) Feedback mechanism (thumbs up/down) for AI responses to help improve the system (future enhancement).
  - **UX:**
    - Intuitive and familiar chat experience.
    - Fast response times are crucial for engagement.
    - Graceful handling of long AI responses (e.g., break into multiple bubbles, use expandable sections for code snippets or detailed explanations).
    - Clear error handling if the LLM API call fails or times out.
    - Maintain conversation context (scrolling up should show previous messages in the current session).
    - Accessibility: Good contrast, readable fonts, support for screen readers if possible.
- **B. Chat History List Screen (Optional, could be part of a general history/dashboard):**
  - **UI:** A list of past chat sessions, perhaps with a title/preview of the first few messages and a timestamp. Tapping a session opens it in the Chat Interface Screen.
  - **UX:** Easy to find and revisit previous conversations.

**2.4. Flutter Implementation Notes:**

- **Packages:**
  - `supabase_flutter` (for invoking Edge Functions and storing chat history).
  - `flutter_chat_ui` (a popular package for quickly building chat UIs, or build custom using `ListView.builder`, `TextField`, `MessageBubble` widgets).
  - `http` (if calling Edge Functions directly, though `supabase_flutter` handles this).
  - State management (`flutter_bloc`, `provider`, `riverpod`) to manage chat messages, loading states, and errors.
  - `uuid` for generating unique session IDs if needed.
- **Widgets:**
  - `ListView.builder` for displaying messages efficiently.
  - `TextField` for user input.
  - `IconButton` for send button.
  - Custom widgets for message bubbles.
  - `CircularProgressIndicator` for loading.
- **Logic:**
  - When user sends a message:
    - Add user message to the local chat state and display it.
    - Set loading state to true.
    - Call the Supabase Edge Function (see 2.5).
  - On receiving a response:
    - Add AI message to local chat state and display it.
    - Set loading state to false.
    - Save both user and AI messages to Supabase `chat_history` table.
  - On error:
    - Display an error message in the chat.
    - Set loading state to false.
  - Maintain a list of `ChatMessage` objects in your state, each with content, sender type (user/AI), and timestamp.

**2.5. Supabase Integration & Architecture:**

- **Supabase Edge Functions (Dart or TypeScript):** This is the core of the LLM integration.
  - **Function Name Example:** `ask-athena-ai`
  - **Purpose:**
    - Receive user's query and conversation history (for context) from the Flutter app.
    - Securely call the chosen external LLM API (e.g., OpenAI, Cohere). Your LLM API key MUST be stored as an environment variable/secret within the Supabase Edge Function settings, NOT in the Flutter app.
    - Construct the prompt for the LLM. This might involve:
      - System prompt: "You are Athena, a helpful AI study companion. Be encouraging and clear in your explanations."
      - Conversation history: To maintain context.
      - User's current query.
      - (Advanced RAG): If the query relates to specific study materials (see feature 3), this function might first query the `study_materials` (or a vector DB) for relevant content and inject that into the LLM prompt. For CW2 MVP, focus on direct Q&A first, then layer RAG.
    - Handle the response from the LLM API.
    - Return the AI's textual response to the Flutter app.
  - **Authentication:** The Edge Function should be configured to only be callable by authenticated Supabase users. The `context` object within the Edge Function provides user auth details.
  - **Error Handling:** Implement robust error handling for API call failures, timeouts, etc.
- **Supabase Database (PostgreSQL):**
  - `chat_history` table:
    - `id` (UUID, primary key)
    - `user_id` (UUID, foreign key references `auth.users.id`, RLS: `auth.uid() = user_id`)
    - `session_id` (UUID or TEXT, to group messages belonging to one conversation)
    - `message_content` (TEXT)
    - `sender` (TEXT, e.g., 'user', 'ai')
    - `timestamp` (TIMESTAMP WITH TIME ZONE, default `now()`)
    - (Optional) `llm_metadata` (JSONB, to store any metadata from the LLM response like model used, tokens, etc.)
  - RLS policies on `chat_history` to ensure users can only access their own chats.

**2.6. LLM Integration Specifics:**

- **Choosing an LLM:**
  - Consider models like OpenAI's GPT series (e.g., gpt-3.5-turbo for balance of cost/capability), Cohere's models, or other accessible LLMs.
  - Evaluate based on API cost, response quality for academic queries, ease of integration, and rate limits.
- **Prompt Engineering:** This is crucial for good results.
  - System Prompt: Define Athena's persona, tone, and core function.
  - Contextual History: Pass previous turns of the conversation (e.g., last 5-10 messages) to the LLM so it can understand follow-up questions. Be mindful of token limits.
  - RAG (Future Enhancement for CW2, or core if time permits): If querying about specific notes, the prompt will include: "Based on the following text from your notes: [retrieved note snippet], answer the question: [user's question]."
- **Managing API Keys:** Store the LLM API key securely as an environment variable in your Supabase Edge Function settings. Do not embed it in your Flutter code.
- **Cost Management:** Be aware of the pricing model for your chosen LLM API (usually per token). Implement safeguards in your Edge Function if necessary (e.g., limit response length, monitor usage).

**2.7. Design Chart Suggestions (Mermaid):**

- **A. Use Case Diagram - AI Chatbot:**

  ```mermaid
  graph TD
      actor Student
      subgraph "Athena App - AI Chatbot"
          UC2_1["UC2.1: Ask General Question"]
          UC2_2["UC2.2: Get Homework Help"]
          UC2_3["UC2.3: Ask Follow-up Question"]
          UC2_4["UC2.4: Query Own Study Notes (RAG)"]
          UC2_6["UC2.6: View Chat History"]
      end
      Student --> UC2_1
      Student --> UC2_2
      Student --> UC2_3
      Student --> UC2_4
      Student --> UC2_6

      UC2_1 -.-> SEF(Supabase Edge Function + LLM API)
      UC2_2 -.-> SEF
      UC2_3 -.-> SEF
      UC2_4 -.-> SEF
      UC2_4 -.-> SDB_SM(Supabase DB - Study Materials)
      UC2_1 -.-> SDB_CH(Supabase DB - Chat History)
      UC2_2 -.-> SDB_CH
      UC2_3 -.-> SDB_CH
      UC2_4 -.-> SDB_CH
      UC2_6 -.-> SDB_CH

      classDef actor fill:#D6EAF8,stroke:#2E86C1,stroke-width:2px;
      classDef usecase fill:#E8F8F5,stroke:#1ABC9C,stroke-width:2px;
      class Student actor;
      class UC2_1,UC2_2,UC2_3,UC2_4,UC2_6 usecase;
  ```

- **B. Sequence Diagram - User Asks AI a Question:**

  ```mermaid
  sequenceDiagram
      actor User
      participant FlutterApp as Athena App (Flutter UI)
      participant SupabaseClient as Supabase Flutter SDK
      participant AthenaEdgeFunc as Supabase Edge Function (ask-athena-ai)
      participant LLM_API as External LLM API
      participant SupabaseDB as Supabase Database

      User->>FlutterApp: Types and sends message
      FlutterApp->>FlutterApp: Displays user message in UI
      FlutterApp->>FlutterApp: Shows loading indicator
      FlutterApp->>SupabaseClient: supabase.functions.invoke('ask-athena-ai', body: {query, history})
      SupabaseClient->>AthenaEdgeFunc: HTTPS Request
      AthenaEdgeFunc->>AthenaEdgeFunc: Retrieve LLM API Key (Secret)
      AthenaEdgeFunc->>LLM_API: HTTPS POST (Prompt with query & history)
      LLM_API-->>AthenaEdgeFunc: LLM Response
      AthenaEdgeFunc-->>SupabaseClient: AI Response
      SupabaseClient-->>FlutterApp: Returns AI Response
      FlutterApp->>FlutterApp: Hides loading indicator
      FlutterApp->>FlutterApp: Displays AI message in UI
      FlutterApp->>SupabaseClient: supabase.from('chat_history').insert([{user_msg}, {ai_msg}])
      SupabaseClient->>SupabaseDB: INSERT into chat_history
      SupabaseDB-->>SupabaseClient: Insert Success/Failure
  ```

- **C. Component Diagram - AI Chatbot System:**

  ```mermaid
  graph TD
      subgraph "Flutter Application (Client-Side)"
          ChatUI["Chat Screen UI (Widgets)"]
          ChatState["Chat State Management (BLoC/Provider)"]
          SupabaseSDK["Supabase Flutter SDK Client"]
      end

      subgraph "Supabase Backend (Cloud)"
          style SupabaseBackend fill:#f9f,stroke:#333,stroke-width:2px
          EdgeFunction["Edge Function: ask-athena-ai (Dart/TS)"]
          SupabaseAuth["Supabase Authentication"]
          SupabaseDB_Chat["Database: chat_history Table"]
          SupabaseSecrets["Secrets Management (LLM API Key)"]
      end

      subgraph "External Services"
          style ExternalServices fill:#ccf,stroke:#333,stroke-width:2px
          LLMAPI["LLM API (e.g., OpenAI)"]
      end

      ChatUI --> ChatState;
      ChatState --> SupabaseSDK;
      SupabaseSDK --> EdgeFunction;
      EdgeFunction --> SupabaseSecrets;
      EdgeFunction --> LLMAPI;
      EdgeFunction --> SupabaseAuth; # For checking user auth
      EdgeFunction --> SupabaseDB_Chat; # To save history (or app does it directly)
      SupabaseSDK --> SupabaseDB_Chat; # App saves history via SDK

      classDef component fill:#E8F8F5,stroke:#1ABC9C,stroke-width:1px;
      classDef cloudcomponent fill:#FADBD8,stroke:#C0392B,stroke-width:1px;
      classDef external fill:#FDEDEC,stroke:#E74C3C,stroke-width:1px;

      class ChatUI,ChatState,SupabaseSDK component;
      class EdgeFunction,SupabaseAuth,SupabaseDB_Chat,SupabaseSecrets cloudcomponent;
      class LLMAPI external;
  ```

This covers the AI Chatbot feature in significant detail. The key for CW2 will be to implement a solid text-based chat first, ensuring the Supabase Edge Function and LLM API calls are secure and reliable. Advanced features like RAG or rich multimodal input can be stretch goals or clearly defined "future enhancements" if time is tight.
What are your thoughts on this? Shall we move on to "3. Study Material Management & Note Summarization" next?

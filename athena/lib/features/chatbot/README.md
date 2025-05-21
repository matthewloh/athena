# AI Chatbot Feature (`feature/chatbot`)

## 1. Overview

The AI Chatbot feature is a core component of the Athena application, designed to provide users with instant academic assistance. It allows users to interact with an AI an LLM (Large Language Model) to ask questions, get explanations for complex topics, receive help with homework, and engage in educational dialogues. The chatbot aims to maintain conversation context and store chat history for users to refer back to.

## 2. Key Responsibilities

- **Send and Receive Messages:** Allow users to send text messages and receive responses from the AI.
- **AI Integration:** Interface with a backend LLM (via a Supabase Edge Function) to generate intelligent and contextually relevant responses.
- **Conversation Management:**
  - Store and retrieve chat history for individual conversations.
  - Allow users to view past conversations.
  - Enable users to start new conversations.
- **Streaming Responses:** Display AI responses token by token as they are generated for a more interactive experience.
- **User Interface:** Provide a clean, intuitive, and responsive chat interface.

## 3. Architecture & Key Components

This feature follows the Clean Architecture principles adopted by the Athena project, separating concerns into domain, data, and presentation layers.

### 3.1. Domain Layer (`lib/features/chatbot/domain/`)

- **Entities:**
  - `ConversationEntity.dart`: Represents a single chat conversation (e.g., ID, title, last message snippet, timestamp).
  - `ChatMessageEntity.dart`: Represents a single message within a conversation (e.g., ID, text, sender, timestamp, conversation ID). Includes `MessageSender` enum (`user`, `ai`, `system`).
- **Repositories:**
  - `ChatRepository.dart` (Interface): Defines the contract for all chat-related data operations, including:
    - Getting all conversations.
    - Getting messages for a specific conversation.
    - Sending a user message (and triggering AI response).
    - Creating a new conversation.
    - Streaming AI responses.
- **Use Cases:**
  - `GetConversationsUseCase.dart`: Fetches all conversations for the user.
  - `GetChatHistoryUseCase.dart`: Fetches messages for a specific conversation.
  - `SendMessageUseCase.dart`: Handles sending a user message and initiating the AI response.
  - `CreateConversationUseCase.dart`: Creates a new chat conversation.
  - _(Implicit)_ `GetAiResponseStreamUseCase` (handled within repository or viewmodel subscribing to repository stream)

### 3.2. Data Layer (`lib/features/chatbot/data/`)

- **Models:**
  - `ConversationModel.dart`: Data Transfer Object (DTO) for conversations, with `fromJson`/`toJson` for Supabase.
  - `ChatMessageModel.dart`: DTO for chat messages, with `fromJson`/`toJson` for Supabase.
- **Data Sources:**
  - `ChatRemoteDataSource.dart` (Interface): Defines methods for interacting with the backend (Supabase).
  - `ChatSupabaseDataSourceImpl.dart`: Concrete implementation using Supabase client to:
    - Fetch/store conversations from/to a `conversations` table.
    - Fetch/store messages from/to a `chat_messages` table.
    - Invoke Supabase Edge Function for AI responses.
- **Repositories:**
  - `ChatRepositoryImpl.dart`: Implements `ChatRepository`, coordinating with `ChatRemoteDataSource` and handling data mapping between models and entities.

### 3.3. Presentation Layer (`lib/features/chatbot/presentation/`)

- **ViewModel / Providers:**
  - `ChatViewModel.dart` (extends `AsyncNotifier`):
    - Manages the state of the chat UI (`ChatState`).
    - Handles loading conversations, messages.
    - Manages sending messages and updating the UI with user messages and streaming AI responses.
    - Interacts with domain layer use cases.
    - Provides methods like `loadConversations`, `createNewConversation`, `setActiveConversation`, `sendMessage`.
  - `chat_providers.dart`: Contains Riverpod providers for the `ChatViewModel`, use cases, repository, and data source.
  - `ChatState`: Helper class to hold the UI state (list of conversations, current messages, loading status, error status, AI response streaming status).
  - `ChatError`: Helper class for specific error messages.
- **Views (Screens):**
  - `chatbot_screen.dart`: The main screen for the chat interface. Displays messages and the input bar.
- **Widgets:**
  - `ChatBubble.dart`: Renders individual chat messages (differentiating user vs. AI).
  - `MessageInputBar.dart`: Provides the text input field and send button.

### 3.4. Backend Integration (Supabase)

- **Tables:**
  - `conversations`: Stores metadata for each conversation (e.g., `id`, `user_id`, `title`, `created_at`, `updated_at`, `last_message_snippet`).
  - `chat_messages`: Stores individual messages (e.g., `id`, `conversation_id`, `sender` (`user` or `ai`), `content`, `timestamp`, `metadata`).
- **Edge Function:**
  - A TypeScript Edge Function (e.g., `chat-handler`) will be responsible for:
    - Receiving user prompts and conversation history.
    - Calling an external LLM API (e.g., Gemini, OpenAI via Vercel AI SDK).
    - Streaming the LLM's response back to the Flutter application.

## 4. State Management

- **Riverpod:** Used for all state management within the chatbot feature.
  - `chatViewModelProvider` provides access to the `ChatViewModel`.
  - Other providers manage dependencies for use cases, repositories, and data sources.

## 5. Current Status

- **Core Layers Scaffolded:** Domain, Data (with placeholder Supabase implementation), and Presentation layers have been established.
- **ViewModel Implemented:** `ChatViewModel` manages loading conversations, messages, sending messages, and has stubs for AI response streaming. Error handling and state updates via `AsyncValue` and `ChatState` are in place. Logic for handling `Either` from use cases (using `fold`) is implemented.
- **Basic UI Created:** `ChatbotScreen` displays messages using `ChatBubble` and includes a `MessageInputBar`.
- **Routing:** Navigation to `ChatbotScreen` is set up.

## 6. Next Steps & To-Do

- **Database Schema:** Finalize and implement the `conversations` and `chat_messages` table schemas in Supabase.
- **Supabase DataSource:** Fully implement `ChatSupabaseDataSourceImpl.dart` to perform CRUD operations on the Supabase tables.
- **Edge Function Development:**
  - Create the Supabase Edge Function in TypeScript.
  - Integrate Vercel AI SDK for LLM interaction.
  - Implement logic to handle message history and generate responses.
  - Implement streaming capabilities.
- **Connect Frontend to Backend Streaming:**
  - Update `ChatRepositoryImpl` and `ChatSupabaseDataSourceImpl` to correctly call and handle the streaming response from the Edge Function.
  - Ensure `ChatViewModel` correctly processes and displays the streamed AI response.
- **Conversation Management UI:**
  - Implement UI for users to view a list of their past conversations.
  - Allow users to select a conversation to continue or start a new one.
  - Update `ChatViewModel` and `ChatbotScreen` to support switching between conversations.
- **Error Handling & UI Polish:**
  - Refine error display in the UI for network issues, LLM errors, etc.
  - Improve loading indicators.
  - General UI/UX enhancements for the chat experience.
- **Testing:** Implement unit and widget tests for the feature.

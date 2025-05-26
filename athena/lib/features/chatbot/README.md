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

### ✅ **Completed Features:**

- **✅ Core Architecture:** All layers (Domain, Data, Presentation) fully implemented following Clean Architecture principles.
- **✅ Database Schema:** Complete schema with `conversations` and `chat_messages` tables, including RLS policies and triggers.
- **✅ Repository Pattern:** Full implementation with proper error handling using `Either<Failure, T>` pattern.
- **✅ Use Cases:** All core use cases implemented (`SendMessage`, `GetConversations`, `CreateConversation`, `GetChatHistory`).
- **✅ ViewModel:** `ChatViewModel` with complete state management, error handling, and AI response streaming.
- **✅ Chat UI:** Main chat interface with message bubbles, input bar, and proper styling.
- **✅ Conversation Management UI:** 
  - `ConversationListScreen` for viewing and managing conversations
  - Search functionality within conversations
  - New conversation creation with optional title and first message
  - Navigation between conversation list and chat screen
- **✅ Edge Function:** TypeScript edge function (`chat-stream`) with OpenAI integration and streaming responses.
- **✅ Real-time Updates:** Message streaming via Supabase real-time subscriptions.
- **✅ Authentication Integration:** Proper user authentication flow with Supabase Auth.

### 🚧 **Partially Implemented:**

- **🚧 Edge Function Integration:** Basic streaming implemented, but needs testing and error handling improvements.
- **🚧 Conversation Actions:** Rename and delete functionality UI created but backend methods need implementation.

### ⏳ **To-Do (Lower Priority):**

- **⏳ Advanced Error Handling:** Enhanced error recovery and user feedback mechanisms.
- **⏳ Message Persistence:** Ensure all messages are properly saved to database during streaming.
- **⏳ UI Polish:** Loading states, animations, and enhanced user experience features.
- **⏳ Testing:** Comprehensive unit and widget tests for all components.
- **⏳ Performance Optimization:** Message pagination and conversation lazy loading.

## 6. Implementation Architecture

### 6.1. Data Flow

```
User Input → ViewModel → Use Case → Repository → Data Source → Supabase
                ↓
Edge Function → OpenAI API → Streaming Response → Real-time UI Updates
```

### 6.2. Key Components Interaction

1. **Conversation Management:**
   - `ConversationListScreen` displays all user conversations
   - Users can create new conversations or select existing ones
   - `ChatViewModel` manages active conversation state

2. **Message Flow:**
   - User types in `MessageInputBar`
   - `ChatViewModel.sendMessage()` called with authentication
   - Message saved to database via repository
   - Edge function invoked for AI response
   - Streaming response updates UI in real-time

3. **Real-time Updates:**
   - Supabase real-time subscriptions for message updates
   - Automatic UI refresh when new messages arrive
   - Proper cleanup of subscriptions on navigation

## 7. Database Schema

### Tables:
- **`conversations`**: User conversations with metadata
- **`chat_messages`**: Individual messages with content and sender info

### Key Features:
- Row Level Security (RLS) for user data protection
- Automatic timestamp updates via triggers
- Conversation snippet generation for list display
- Foreign key constraints with CASCADE delete

## 8. Setup and Testing

### Prerequisites:
1. Supabase project with database migrations applied
2. OpenAI API key configured in Supabase Edge Functions
3. Authentication setup and working

### Quick Test Flow:
1. Login to the app
2. Navigate to Chatbot screen
3. Tap "Start New Conversation" 
4. Send a test message
5. Verify AI response streams properly
6. Check conversation appears in conversation list

## 9. Technical Achievements

- **Clean Architecture:** Proper separation of concerns across all layers
- **Type Safety:** Full `Either<Failure, T>` error handling pattern
- **Real-time Features:** Live message updates and streaming responses
- **Modern UI:** Material Design 3 compliant interface with consistent theming
- **Scalable State Management:** Riverpod with proper provider architecture
- **Database Design:** Optimized schema with proper indexing and security

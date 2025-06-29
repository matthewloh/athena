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
- **User Interface:** Provide a clean, intuitive, and responsive chat interface, including display of user profile pictures.

## 3. Architecture & Key Components

This feature follows the Clean Architecture principles adopted by the Athena project, separating concerns into domain, data, and presentation layers.

### 3.1. Domain Layer (`lib/features/chatbot/domain/`)

- **Entities:**
  - `ConversationEntity.dart`: Represents a single chat conversation (e.g., ID, title, last message snippet, timestamp).
  - `ChatMessageEntity.dart`: Represents a single message within a conversation (e.g., ID, text, sender, timestamp, conversation ID, attachments list). Includes `MessageSender` enum (`user`, `ai`, `system`).
  - `FileAttachment.dart`: Represents a file attachment (e.g., ID, file name, size, MIME type, storage path, thumbnail path).
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
  - `ChatMessageModel.dart`: DTO for chat messages, with `fromJson`/`toJson` for Supabase and file attachments support.
  - `FileAttachmentModel.dart`: DTO for file attachments, with `fromJson`/`toJson` for Supabase storage integration.
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
  - `profile_providers.dart` (from `features/auth`): Used to fetch current user profile data (e.g., `avatarUrl`) for display in chat bubbles.
  - `ChatState`: Helper class to hold the UI state (list of conversations, current messages, loading status, error status, AI response streaming status).
  - `ChatError`: Helper class for specific error messages.
- **Views (Screens):**
  - `chatbot_screen.dart`: The main screen for the chat interface. Displays messages and the input bar.
- **Widgets:**
  - `ChatBubble.dart`: Renders individual chat messages, differentiating user vs. AI, displays user avatars, and shows file attachments with thumbnails.
  - `MessageInputBar.dart`: Provides the text input field, send button, and file upload functionality with preview.
  - `FileUploadWidget.dart`: Handles file selection from camera, gallery, or documents with popup menu interface.
  - `FileAttachmentPreview.dart`: Shows selected files before sending with thumbnails and remove functionality.

### 3.4. Backend Integration (Supabase)

- **Tables:**
  - `conversations`: Stores metadata for each conversation (e.g., `id`, `user_id`, `title`, `created_at`, `updated_at`, `last_message_snippet`).
  - `chat_messages`: Stores individual messages (e.g., `id`, `conversation_id`, `sender` (`user` or `ai`), `content`, `timestamp`, `metadata`, `has_attachments`).
  - `file_attachments`: Stores file attachment metadata (e.g., `id`, `message_id`, `file_name`, `file_size`, `mime_type`, `storage_path`, `thumbnail_path`, `upload_status`).
- **Storage:**
  - `chat-attachments` bucket: Stores uploaded files with proper RLS policies for secure access.
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
- **ViewModel Implemented:** `ChatViewModel` manages loading conversations, messages, sending messages, and has stubs for AI response streaming. Error handling (including specific error codes via `ServerFailure` and `ServerException`) and state updates via `AsyncValue` and `ChatState` are in place. Logic for handling `Either` from use cases (using `fold`) is implemented.
- **Basic UI Created:** `ChatbotScreen` displays messages using `ChatBubble` (which now includes user avatars) and includes a `MessageInputBar`.
- **Profile Integration:** User avatars are fetched via `currentUserProfileProvider` and displayed in `ChatBubble`.
- **Routing:** Navigation to `ChatbotScreen` is set up.
- **File Upload System (90% Complete):**
  - ✅ **Database Schema:** `file_attachments` table with RLS policies and `chat-attachments` storage bucket
  - ✅ **Entity & Models:** `FileAttachment` entity and models for data layer integration
  - ✅ **UI Components:** Complete file upload widget with camera, gallery, and document selection
  - ✅ **File Preview:** Attachment preview system with thumbnails and remove functionality
  - ✅ **Chat Bubble Display:** Comprehensive attachment display in chat messages
  - ✅ **Message Input Integration:** File attachments fully integrated with message sending
  - ✅ **Multiple File Support:** Users can attach multiple files per message
  - ✅ **File Type Detection:** Automatic MIME type detection and appropriate icons
  - 🚧 **Placeholder Implementation:** Currently creates placeholder attachments (not uploaded to storage)

## 6. Next Steps & To-Do

### 6.1. **IMMEDIATE PRIORITY: Complete File Upload System**
- **🎯 Actual File Upload to Supabase Storage:**
  - Implement real file upload in `ChatSupabaseDataSourceImpl`
  - Handle upload progress and error states
  - Generate proper storage URLs for file attachments
- **🖼️ Image Fullscreen Viewer:**
  - Create fullscreen image viewer widget
  - Support pinch-to-zoom and pan gestures
  - Implement smooth transition animations
- **📥 File Download Functionality:**
  - Add download capability for file attachments
  - Handle different file types appropriately
  - Implement download progress indicators
- **🖼️ Real Image Thumbnails:**
  - Generate thumbnails from Supabase Storage URLs
  - Implement caching for better performance
  - Handle loading states for thumbnails

### 6.2. **Core Chat Functionality**
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

### 6.3. **UI/UX Enhancements**
- **Conversation Management UI:**
  - Implement UI for users to view a list of their past conversations.
  - Allow users to select a conversation to continue or start a new one.
  - Update `ChatViewModel` and `ChatbotScreen` to support switching between conversations.
- **Error Handling & UI Polish:**
  - Refine error display in the UI for network issues, LLM errors, etc.
  - Improve loading indicators.
  - General UI/UX enhancements for the chat experience.
- **Testing:** Implement unit and widget tests for the feature.

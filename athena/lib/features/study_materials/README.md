# Study Material Management & Note Summarization Feature (`feature/study_materials`)

## 1. Overview

The Study Material Management and Note Summarization feature allows users to upload, manage, and derive insights from their personal study materials. Users can add notes by typing, uploading text files, or uploading images of notes (which can be OCR'd). The core value lies in centralizing study content, enabling AI-powered summarization for quick reviews, and providing a foundation for personalized interactions with other Athena features like the AI Chatbot (via RAG) and the Adaptive Review System.

## 2. Key Responsibilities

- **Material Management:**
    - Allow users to add study materials (typed text, text files, image notes).
    - List all added study materials with options for filtering/sorting.
    - Allow users to view the content of specific materials.
    - Enable users to edit metadata (title, subject) of materials.
    - Allow users to delete materials and associated files.
- **Content Processing:**
    - (Optional) Perform OCR on uploaded image notes to extract text.
- **AI Summarization:**
    - Interface with an LLM (via a Supabase Edge Function) to generate summaries of study materials.
    - Display AI-generated summaries to the user.
- **Data Persistence:**
    - Store material metadata and content (or paths to content) in a database.
    - Store uploaded files (images, text files) in cloud storage.

## 3. Architecture & Key Components

This feature follows Clean Architecture principles, separating concerns into domain, data, and presentation layers.

### 3.1. Domain Layer (`lib/features/study_materials/domain/`)

- **Entities:**
  - `StudyMaterialEntity.dart`: Represents a single study material (e.g., ID, user ID, title, subject, content type, original text, image path, OCR'd text, summary, timestamps).
  - `MaterialContent.dart`: (Potentially) A value object or part of `StudyMaterialEntity` to handle different content types (raw text, file path, OCR'd text).
- **Repositories:**
  - `StudyMaterialRepository.dart` (Interface): Defines the contract for all study material operations:
    - Adding a new study material (text, file, image).
    - Fetching all study materials for a user.
    - Fetching a specific study material.
    - Updating material metadata.
    - Deleting a material (and its associated file).
    - Requesting and retrieving an AI-generated summary.
    - (Optional) Processing an image with OCR.
- **Use Cases:**
  - `AddStudyMaterialUseCase.dart`: Handles adding new material (typed, file, or image).
  - `GetStudyMaterialsUseCase.dart`: Fetches the list of user's study materials.
  - `GetStudyMaterialDetailsUseCase.dart`: Fetches details for a specific material.
  - `UpdateStudyMaterialUseCase.dart`: Updates metadata of a material.
  - `DeleteStudyMaterialUseCase.dart`: Deletes a material.
  - `RequestSummarizationUseCase.dart`: Initiates the summarization process for a material.
  - `ProcessImageOCRUseCase.dart`: (If OCR is implemented) Handles extracting text from an image.

### 3.2. Data Layer (`lib/features/study_materials/data/`)

- **Models:**
  - `StudyMaterialModel.dart`: Data Transfer Object (DTO) for study materials, with `fromJson`/`toJson` for Supabase. Maps to the `study_materials` table.
- **Data Sources:**
  - `StudyMaterialRemoteDataSource.dart` (Interface): Defines methods for interacting with Supabase (database, storage, edge functions).
  - `StudyMaterialSupabaseDataSourceImpl.dart`: Concrete implementation using Supabase client to:
    - Perform CRUD operations on the `study_materials` table.
    - Upload/delete files from Supabase Storage.
    - Invoke Supabase Edge Function for summarization.
    - (Optional) Interface with an OCR service/library if not on-device.
- **Repositories:**
  - `StudyMaterialRepositoryImpl.dart`: Implements `StudyMaterialRepository`, coordinating with `StudyMaterialRemoteDataSource`, handling file operations, and data mapping.

### 3.3. Presentation Layer (`lib/features/study_materials/presentation/`)

- **ViewModel / Providers:**
  - `StudyMaterialViewModel.dart` (extends `AsyncNotifier` or similar):
    - Manages the state of the study materials UI (`StudyMaterialState`).
    - Handles loading materials, adding new ones, viewing details, requesting summaries.
    - Manages file picking, image picking, and upload progress.
    - Interacts with domain layer use cases.
  - `study_material_providers.dart`: Contains Riverpod providers for the `StudyMaterialViewModel`, use cases, repository, and data source.
  - `StudyMaterialState`: Helper class for UI state (list of materials, current material, loading/error states for various operations).
- **Views (Screens):**
  - `StudyMaterialsListScreen.dart`: Displays the list of study materials.
  - `AddEditMaterialScreen.dart`: Form for adding new or editing existing materials.
  - `MaterialDetailScreen.dart`: Displays the content of a material and its AI summary.
- **Widgets:**
  - `MaterialListItemCard.dart`: Widget for displaying a single material in the list.
  - `ContentInputWidget.dart`: Handles different input types (text field, file picker, image picker).
  - `SummaryDisplayWidget.dart`: Displays the AI-generated summary.

### 3.4. Backend Integration (Supabase)

- **Database Table (`study_materials`):**
  - `id` (UUID, PK)
  - `user_id` (UUID, FK to `auth.users`)
  - `title` (TEXT)
  - `subject` (TEXT, Nullable)
  - `content_type` (TEXT: 'typed_text', 'uploaded_text_file', 'image_note')
  - `original_content_text` (TEXT, Nullable)
  - `image_storage_path` (TEXT, Nullable)
  - `ocr_extracted_text` (TEXT, Nullable)
  - `summary_text` (TEXT, Nullable)
  - `created_at` (TIMESTAMPTZ)
  - `updated_at` (TIMESTAMPTZ)
  - RLS policies for user-specific access.
- **Storage Bucket (e.g., `user_study_materials`):**
  - Stores uploaded text files and images.
  - Path structure: `user_id/material_id/filename.ext`.
  - RLS policies for user-specific access.
- **Edge Function (`summarize-material`):**
  - Receives `material_id` or raw text.
  - Fetches content from the database if `material_id` is provided.
  - Calls an external LLM API for summarization.
  - Updates the `summary_text` in the `study_materials` table.
  - Returns the summary to the client.

### 3.5. (Optional) OCR Integration

- **Library/API:** `google_mlkit_text_recognition` (on-device) or a cloud-based OCR API.
- **Process:**
  - User uploads an image.
  - Flutter app uses the OCR tool to extract text.
  - Extracted text is stored in `ocr_extracted_text` field.
  - This text is then used for summarization and RAG.

## 4. State Management

- **Riverpod:** Used for state management, providing `StudyMaterialViewModel` and managing dependencies for use cases, repositories, and data sources.

## 5. Current Status (as per Design Document)

- **Design Phase Complete:** Detailed feature breakdown, user stories, UI mock-up ideas, Flutter implementation notes, Supabase integration plan, and LLM specifics have been defined.
- **Core Architecture Outlined:** The structure for domain, data, and presentation layers is planned.
- **Key Components Identified:** Entities, repositories, use cases, view models, and backend components are specified.

## 6. Next Steps & To-Do

- **Database Schema & Storage Setup:**
  - Implement the `study_materials` table in Supabase with RLS.
  - Set up the Supabase Storage bucket (`user_study_materials`) with RLS.
- **Data Layer Implementation:**
  - Implement `StudyMaterialSupabaseDataSourceImpl.dart` for all CRUD, file, and function call operations.
  - Implement `StudyMaterialRepositoryImpl.dart`.
- **Domain Layer Implementation:**
  - Define `StudyMaterialEntity` and other domain models.
  - Implement all use cases.
- **Presentation Layer Development:**
  - Create `StudyMaterialViewModel` and `StudyMaterialState`.
  - Develop the UI screens: `StudyMaterialsListScreen`, `AddEditMaterialScreen`, `MaterialDetailScreen`.
  - Implement widgets: `MaterialListItemCard`, input widgets, summary display.
  - Integrate `file_picker` and `image_picker`.
- **OCR Implementation (UC3.8 - Optional Second API):**
  - Integrate `google_mlkit_text_recognition` or chosen OCR solution.
  - Add logic to process images and store extracted text.
- **Edge Function Development (`summarize-material`):**
  - Create the Supabase Edge Function in TypeScript/Dart.
  - Implement logic to fetch content, call LLM API (with appropriate prompt engineering), and store/return the summary.
  - Secure the Edge Function.
- **Connect Frontend to Backend:**
  - Ensure ViewModel correctly calls use cases for all operations (add, list, view, edit, delete, summarize).
  - Handle loading states, progress indicators (for uploads/summarization), and error messages.
- **Testing:** Implement unit, widget, and integration tests.
- **UI/UX Polish:** Refine user flows, error handling, and visual presentation.
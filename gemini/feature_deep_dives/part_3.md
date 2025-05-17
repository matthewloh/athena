# Athena: Feature Deep Dive & Design Foundation 3. Study Material Management and Note Summarization (RAG & Content Management)

Alright! We've successfully outlined User Authentication (Part 1) and the AI Chatbot (Part 2). Now, we'll focus on **Part 3: Study Material Management and Note Summarization (RAG & Content Management)**.

This module is critical for allowing users to bring their own content into Athena, forming the backbone for personalized AI interactions and review materials. It's a key step towards making Athena a truly customized study companion. For CW2, this part highlights data persistence, cloud storage, and a significant use of LLM APIs for summarization, along with a potential second API via OCR.

Here's the detailed breakdown for Part 3:

## 3. Study Material Management and Note Summarization (RAG & Content Management)

**3.1. Purpose & Value:**
This module empowers students to centralize their study materials within Athena, reducing the need to switch between multiple applications or physical notes. By integrating their own content, the AI Chatbot can provide more contextually relevant answers (via RAG), and the Adaptive Review System can generate personalized quizzes. The AI-powered summarization feature offers a quick way to distill lengthy notes into key takeaways, aiding in revision and understanding. This directly addresses the CW1 problem statement about efficiently managing and understanding study information and is a key enabler for other advanced features. For CW2, this showcases data persistence (files and metadata), cloud storage, and another intensive use of an LLM API.

**3.2. User Stories / Key Use Cases:**

- **UC3.1 (Student - Add Material):** As a student, I want to be able to add my study notes, either by typing them directly, uploading a text file, or uploading an image of my notes (which will then be OCR'd), so I can manage them in one place.
- **UC3.2 (Student - View List):** As a student, I want to see a clear list of all my study materials, perhaps filterable by subject or date, so I can easily find what I need.
- **UC3.3 (Student - View Material):** As a student, I want to be able to open and read the content of a specific study material I've added.
- **UC3.4 (Student - Request Summary):** As a student, after viewing a material, I want to request an AI-generated summary of it to get the key points quickly.
- **UC3.5 (Student - View Summary):** As a student, I want to be able to read the AI-generated summary clearly presented alongside or within the material view.
- **UC3.6 (Student - Edit Metadata):** As a student, I want to be able to edit the title or subject of my uploaded materials to keep them organized.
- **UC3.7 (Student - Delete Material):** As a student, I want to be able to delete study materials that I no longer need, and this should also remove any associated uploaded files.
- **UC3.8 (Student - OCR Image Notes - Potential Second API):** As a student, if I upload an image of my notes, I want the system to automatically extract the text from the image so it can be summarized and searched.

**3.3. Screen Mock-up Ideas & UI/UX Considerations:**

- **A. Study Materials List Screen:**

  - **UI:**
    - A `ListView` or `GridView` displaying `Card` widgets for each material. Each card shows: Title, Subject (if any), a snippet of content or an icon indicating type (text, image), and creation/update date.
    - Floating Action Button (FAB) with a "+" icon to add new material.
    - (Optional) Search bar at the top to filter materials by title or subject.
    - (Optional) Filter/Sort options (e.g., by subject, by date).
  - **UX:**
    - Clean, uncluttered, easy to scan.
    - Obvious affordance for adding new material.
    - Smooth scrolling for many items.
    - Clear feedback if the list is empty.

- **B. Add/Edit Material Screen:**

  - **UI:**
    - `TextField` for "Title".
    - `TextField` or `DropdownButtonFormField` for "Subject" (could allow free text or pre-defined list).
    - Input method selection:
      - "Type Note": A multi-line `TextField` for direct text input.
      - "Upload Text File": Button to trigger file picker (filtered for .txt, .md).
      - "Upload Image of Notes": Button to trigger image picker (camera/gallery).
    - If editing, pre-fill existing data.
    - "Save" / "Upload & Save" button.
  - **UX:**
    - Clear choices for input type.
    - Guidance on supported file types (e.g., for text files).
    - Progress indicator during file uploads.
    - Real-time validation for title (e.g., not empty).

- **C. Material Detail & Summary Screen:**
  - **UI:**
    - Display "Title" and "Subject".
    - Tabbed view or expandable sections:
      - **Tab 1: "Original Content":**
        - If typed text/text file: Display the text content (scrollable).
        - If image: Display the image. (Below it, display OCR'd text if available).
      - **Tab 2: "AI Summary":**
        - Initially shows "No summary generated yet." or a "Generate Summary" button if no summary exists.
        - If summary exists, display the summary text.
        - Button: "Generate Summary" / "Re-generate Summary".
        - (Optional) "Copy Summary" button.
    - Edit and Delete icons/buttons.
  - **UX:**
    - Easy to switch between original content and summary.
    - Clear loading state when summary is being generated (e.g., `CircularProgressIndicator` in the summary tab/section).
    - Informative messages (e.g., "Summary generated successfully," "Error generating summary").
    - Confirmation dialog before deleting a material.

**3.4. Flutter Implementation Notes:**

- **Packages:**
  - `supabase_flutter`: For all Supabase interactions.
  - `file_picker`: To pick text files from device storage.
  - `image_picker`: To pick images from gallery or camera.
  - `google_mlkit_text_recognition` (or similar): For on-device OCR if implementing UC3.8. This could be your second distinct API/Sensor for the rubric.
  - State management (e.g., `flutter_bloc`, `riverpod`, `provider`): To manage material lists, individual material state, loading states for uploads/summarization.
  - `uuid`: For generating unique IDs for materials if needed before DB insertion (though DB can handle it).
- **Widgets:** `Scaffold`, `AppBar`, `ListView.builder`, `Card`, `FloatingActionButton`, `TextField`, `ElevatedButton`, `TextButton`, `AlertDialog`, `TabBar`/`TabBarView` (for detail screen), `SingleChildScrollView`, `Image.file`/`Image.network`.
- **Logic:**
  - **CRUD Operations:** Implement BLoC/Cubit or Provider methods for fetching, adding, updating, and deleting study materials from Supabase.
  - **File Upload:**
    - Use `file_picker` to get the file path.
    - Use `supabase.storage.from('bucket_name').upload(filePath, File(file.path))`
    - Store the returned storage path in the `study_materials` table.
  - **Image Upload & OCR (UC3.8):**
    - Use `image_picker` to get the image.
    - Use `google_mlkit_text_recognition` to process the `InputImage.fromFilePath(image.path)`.
    - Extract the recognized text. Store this text in `ocr_extracted_text` field in `study_materials` table (or a dedicated field like `raw_text_for_llm`). This text is then sent for summarization.
  - **Summarization Request:**
    - When "Generate Summary" is tapped, call a Supabase Edge Function, passing the `material_id` or the actual text content.
    - Update UI with the summary upon successful response.
    - Handle loading and error states.

**3.5. Supabase Integration & Architecture:**

- **Supabase Database (PostgreSQL):**
  - **`study_materials` table:**
    - `id` (UUID, Primary Key, default `uuid_generate_v4()`)
    - `user_id` (UUID, Foreign Key references `auth.users.id`, Not Null)
    - `title` (TEXT, Not Null)
    - `subject` (TEXT, Nullable)
    - `content_type` (TEXT, Not Null, e.g., 'typed_text', 'uploaded_text_file', 'image_note')
    - `original_content_text` (TEXT, Nullable - for typed notes or content of uploaded text files)
    - `image_storage_path` (TEXT, Nullable - path in Supabase Storage if `content_type` is 'image_note')
    - `ocr_extracted_text` (TEXT, Nullable - text extracted from image if `content_type` is 'image_note')
    - `summary_text` (TEXT, Nullable - AI-generated summary)
    - `created_at` (TIMESTAMPTZ, default `now()`)
    - `updated_at` (TIMESTAMPTZ, default `now()`)
  - **RLS Policies:**
    - Users can SELECT their own materials: `auth.uid() = user_id`.
    - Users can INSERT materials for themselves: `auth.uid() = user_id`.
    - Users can UPDATE their own materials: `auth.uid() = user_id`.
    - Users can DELETE their own materials: `auth.uid() = user_id`.
- **Supabase Storage:**
  - **Bucket:** e.g., `user_study_materials`.
  - **Path Structure:** Store files under a user-specific path, e.g., `user_id/material_id/filename.ext`. This helps in managing access and deletion.
  - **RLS Policies on Storage:**
    - Users can upload to their own folder: `bucket_id = 'user_study_materials' AND (storage.foldername(name))[1] = auth.uid()::text` (This might need careful crafting based on exact path structure and Supabase storage RLS capabilities).
    - Users can read files from their own folder.
    - When a `study_materials` record is deleted, an Edge Function or trigger could be used to delete the corresponding file from Storage (or handle in Flutter app logic after DB delete confirmation).
- **Supabase Edge Functions (TypeScript/Dart):**
  - **Function Name:** `summarize-material`
  - **Purpose:** Securely call LLM API for summarization.
  - **Input:** `{ "material_id": "uuid_of_material" }` or `{ "text_to_summarize": "direct text content" }`.
  - **Authentication:** Ensure only authenticated users can call it. Access `user_id` from the auth context.
  - **Logic:**
    - If `material_id` provided:
      - Fetch the `study_materials` record for the given `material_id` and `user_id` (to ensure ownership).
      - Get the relevant text: `ocr_extracted_text` (if available and preferred) or `original_content_text`.
    - If `text_to_summarize` provided: Use this text directly.
    - Handle cases where text is empty or too short.
    - Retrieve LLM API key from Supabase secrets.
    - Construct a prompt for summarization (e.g., "Summarize the following academic notes concisely, focusing on key concepts and definitions: [TEXT]").
    - Call the external LLM API.
    - Receive the summary.
    - If `material_id` was used, update the `summary_text` field in the `study_materials` table for that record.
    - Return the generated summary (and perhaps a success/error status) to the Flutter app.

**3.6. LLM Integration Specifics:**

- **Primary Use:** Summarization of user-provided text (typed, from text files, or OCR'd from images).
- **Prompt Engineering for Summarization:**
  - "Provide a concise summary of the following text, highlighting the main topics and key arguments."
  - "Extract the 3-5 most important points from these notes."
  - "Summarize this material for a student preparing for an exam on this topic."
- **Input Handling:**
  - Be mindful of LLM token limits. If `original_content_text` or `ocr_extracted_text` is very long, you might need to truncate it or send only the initial part for summarization (for CW2 scope, full handling of massive texts is likely out of scope). A practical limit (e.g., 5000 characters) could be set.
- **Output:** The Edge Function should save the summary back to the database and also return it to the app for immediate display.

**3.7. Design Chart Suggestions (Mermaid):**

- **A. Use Case Diagram - Study Material Management & Summarization:**

  ```mermaid
  graph TD
      actor Student
      subgraph "Athena App - Material Management & Summarization"
          UC3_1["UC3.1: Add/Upload Material (Text/Image)"]
          UC3_8["UC3.8: OCR Image to Text (if image)"]
          UC3_2["UC3.2: View Material List"]
          UC3_3["UC3.3: View Material Content"]
          UC3_4["UC3.4: Request AI Summary"]
          UC3_5["UC3.5: View AI Summary"]
          UC3_6["UC3.6: Edit Material Metadata"]
          UC3_7["UC3.7: Delete Material"]
      end

      Student --> UC3_1
      UC3_1 -- includes (if image) --> UC3_8
      Student --> UC3_2
      Student --> UC3_3
      Student --> UC3_4
      Student --> UC3_5
      Student --> UC3_6
      Student --> UC3_7

      UC3_1 -.-> S_Storage(Supabase Storage)
      UC3_1 -.-> SDB_SM(Supabase DB - study_materials)
      UC3_8 -.-> OCR_API(Google ML Kit Text Recognition)
      UC3_8 -.-> SDB_SM  // Save OCR'd text
      UC3_2 -.-> SDB_SM
      UC3_3 -.-> SDB_SM
      UC3_3 -.-> S_Storage // If viewing image file
      UC3_4 -.-> SEF_Summarize(Supabase Edge Function: summarize-material)
      SEF_Summarize -.-> SDB_SM // Read text for summary
      SEF_Summarize -.-> LLM_API
      SEF_Summarize -.-> SDB_SM // Save summary
      UC3_5 -.-> SDB_SM
      UC3_6 -.-> SDB_SM
      UC3_7 -.-> SDB_SM
      UC3_7 -.-> S_Storage // Delete file from storage

      classDef actor fill:#D6EAF8,stroke:#2E86C1,stroke-width:2px;
      classDef usecase fill:#E8F8F5,stroke:#1ABC9C,stroke-width:2px;
      class Student actor;
      class UC3_1,UC3_8,UC3_2,UC3_3,UC3_4,UC3_5,UC3_6,UC3_7 usecase;
  ```

- **B. Sequence Diagram - Uploading Image Note, OCR, and AI Summarization:**

  ```mermaid
  sequenceDiagram
      actor User
      participant FlutterApp as Athena App (Flutter)
      participant MLKitOCR as Google ML Kit (On-Device)
      participant SupabaseClient as Supabase Flutter SDK
      participant SupabaseStorage as Supabase Storage
      participant SupabaseDB as Supabase Database
      participant SummarizeFunc as Supabase Edge Function (summarize-material)
      participant LLM_API as External LLM API

      User->>FlutterApp: Selects "Upload Image Note" & picks image
      FlutterApp->>FlutterApp: Display image preview
      User->>FlutterApp: Enters Title & Taps "Save"
      FlutterApp->>MLKitOCR: Process image for text recognition
      MLKitOCR-->>FlutterApp: Returns Extracted Text

      FlutterApp->>SupabaseClient: supabase.storage.upload(imagePath, imageFile)
      SupabaseClient->>SupabaseStorage: Store Image File
      SupabaseStorage-->>SupabaseClient: Storage Path

      FlutterApp->>SupabaseClient: supabase.from('study_materials').insert({title, image_storage_path, ocr_extracted_text})
      SupabaseClient->>SupabaseDB: Insert Material Record
      SupabaseDB-->>SupabaseClient: Insert Success (returns new material_id)
      FlutterApp->>FlutterApp: Shows Material in list / Opens Detail Screen

      User->>FlutterApp: Taps "Generate Summary"
      FlutterApp->>FlutterApp: Shows loading for summary
      FlutterApp->>SupabaseClient: supabase.functions.invoke('summarize-material', body: {material_id})
      SupabaseClient->>SummarizeFunc: Request with material_id
      SummarizeFunc->>SupabaseDB: Fetch ocr_extracted_text for material_id
      SupabaseDB-->>SummarizeFunc: Extracted Text
      SummarizeFunc->>LLM_API: Request Summary (Prompt + Text)
      LLM_API-->>SummarizeFunc: AI Summary
      SummarizeFunc->>SupabaseDB: Update study_materials.summary_text for material_id
      SupabaseDB-->>SummarizeFunc: Update Success
      SummarizeFunc-->>SupabaseClient: Returns AI Summary
      SupabaseClient-->>FlutterApp: AI Summary
      FlutterApp->>FlutterApp: Displays AI Summary
  ```

- **C. Data Flow Diagram (Simplified) - Adding Typed Note & Getting Summary:**

  ```mermaid
  graph TD
      U[User] --1. Enters Title & Note Text--> Screen_AddNote[Add Note Screen (Flutter)]
      Screen_AddNote --2. Save Action--> FC_SaveNote[Flutter Client: Save Logic]
      FC_SaveNote --3. Insert Request (Title, Content)--> SupaDB_SM[Supabase DB: study_materials table]
      SupaDB_SM --4. Insert Confirmation--> FC_SaveNote
      FC_SaveNote --5. Update UI--> Screen_MaterialDetail[Material Detail Screen (Flutter)]

      U --6. Taps 'Generate Summary'--> Screen_MaterialDetail
      Screen_MaterialDetail --7. Invoke Edge Function (material_id)--> FC_InvokeSummary[Flutter Client: Invoke Summary Func]
      FC_InvokeSummary --8. Call Edge Function--> SupaEF_Summarize[Supabase Edge Function: summarize-material]

      SupaEF_Summarize --9. Fetch Note Content (material_id)--> SupaDB_SM
      SupaDB_SM --10. Note Content--> SupaEF_Summarize
      SupaEF_Summarize --11. Prompt + Content--> Ext_LLM[External LLM API]
      Ext_LLM --12. Summary Text--> SupaEF_Summarize
      SupaEF_Summarize --13. Update Summary (material_id, summary_text)--> SupaDB_SM
      SupaDB_SM --14. Update Confirmation--> SupaEF_Summarize
      SupaEF_Summarize --15. Return Summary--> FC_InvokeSummary
      FC_InvokeSummary --16. Display Summary--> Screen_MaterialDetail
  ```

This detailed plan for "Study Material Management & Note Summarization" provides a solid foundation for this essential feature, demonstrating clear pathways for data persistence, cloud integration, and advanced AI functionalities like OCR and summarization. These elements are crucial for fulfilling CW2 requirements.

With this in place, are you ready to move on to the "Adaptive Review System (Quizzes & Spaced Repetition)" next?

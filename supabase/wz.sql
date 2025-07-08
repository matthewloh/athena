SET session_replication_role = replica;

--
-- PostgreSQL database dump
--

-- Dumped from database version 15.8
-- Dumped by pg_dump version 15.8

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Data for Name: conversations; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: chat_messages; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: file_attachments; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: profiles; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."profiles" ("id", "updated_at", "username", "full_name", "avatar_url", "website") VALUES
	('ec501ca8-a4e9-403d-a818-4371062bcbf8', NULL, NULL, 'Thor Wen Zheng', NULL, NULL);


--
-- Data for Name: study_materials; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."study_materials" ("id", "user_id", "title", "description", "subject", "content_type", "original_content_text", "file_storage_path", "ocr_extracted_text", "summary_text", "has_ai_summary", "created_at", "updated_at") VALUES
	('91fb0b85-52c3-4a2d-bd62-4ea6c742b56b', 'ec501ca8-a4e9-403d-a818-4371062bcbf8', 'OpenMP Scheduling', 'Scheduling techniques in OpenMP', 'computerScience', 'textFile', 'File uploaded: OpenMP Scheduling.pdf', 'ec501ca8-a4e9-403d-a818-4371062bcbf8/91fb0b85-52c3-4a2d-bd62-4ea6c742b56b/1751622681946_OpenMP Scheduling.pdf', NULL, NULL, false, '2025-07-04 09:51:21.020229+00', '2025-07-04 09:51:21.441011+00'),
	('10a0039f-105c-4e62-a1a7-a89e07a73128', 'ec501ca8-a4e9-403d-a818-4371062bcbf8', 'CS169: Data Structures 101', 'Data Structures 101 - Lesson 1: Data structure definition and the common types of data structures', 'computerScience', 'typedText', '[{"insert":"A data structure is a way of "},{"insert":"organizing and storing data","attributes":{"bold":true}},{"insert":" to enable efficient access and modification.\n\n"},{"insert":"Common types","attributes":{"bold":true}},{"insert":": arrays, linked lists, stacks, queues, trees, graphs, hash tables\n\n"},{"insert":"Arrays","attributes":{"bold":true}},{"insert":": fixed size, random access, constant time lookup"},{"insert":"\n","attributes":{"list":"ordered"}},{"insert":"Linked List","attributes":{"bold":true}},{"insert":": dynamic size, sequential access, good for insertions/deletions"},{"insert":"\n","attributes":{"list":"ordered"}},{"insert":"Stack","attributes":{"bold":true}},{"insert":": LIFO, push and pop operations"},{"insert":"\n","attributes":{"list":"ordered"}},{"insert":"Queue","attributes":{"bold":true}},{"insert":": FIFO, enqueue and dequeue operations"},{"insert":"\n","attributes":{"list":"ordered"}},{"insert":"Trees","attributes":{"bold":true}},{"insert":": hierarchical structure, binary trees, BSTs used for fast lookup"},{"insert":"\n","attributes":{"list":"ordered"}},{"insert":"Hash","attributes":{"bold":true}},{"insert":" "},{"insert":"tables","attributes":{"bold":true}},{"insert":": key-value mapping with constant time average-case access"},{"insert":"\n","attributes":{"list":"ordered"}}]', NULL, NULL, '### Summary of "Data Structures 101"

**Definition:**
- A **data structure** is a method of organizing and storing data to enable efficient access and modification.

**Common Types of Data Structures:**
1. **Arrays**
   - Fixed size
   - Random access
   - Constant time lookup (O(1))

2. **Linked Lists**
   - Dynamic size
   - Sequential access
   - Efficient for insertions and deletions

3. **Stacks**
   - Follows Last In, First Out (LIFO) principle
   - Operations: push (add) and pop (remove)

4. **Queues**
   - Follows First In, First Out (FIFO) principle
   - Operations: enqueue (add) and dequeue (remove)

5. **Trees**
   - Hierarchical structure
   - Includes binary trees and binary search trees (BSTs)
   - BSTs are used for fast lookup operations

6. **Hash Tables**
   - Key-value mapping
   - Average-case constant time access (O(1))

**Key Concepts:**
- Understanding the characteristics of each data structure helps in selecting the appropriate one for specific tasks.
- Efficiency in data access and modification is crucial for optimal performance in software applications.

In conclusion, mastering these fundamental data structures is essential for effective programming and algorithm development.', false, '2025-07-04 09:14:46.781678+00', '2025-07-04 09:45:22.901132+00'),
	('f9ae6e5d-ff62-4848-9785-c0ff782a3dc1', 'ec501ca8-a4e9-403d-a818-4371062bcbf8', 'Data Science 101', 'Categories of data in data science', 'dataScience', 'imageFile', NULL, 'ec501ca8-a4e9-403d-a818-4371062bcbf8/f9ae6e5d-ff62-4848-9785-c0ff782a3dc1/1751622917753_image_cropper_1751622784263.jpg', 'Data Types
To analyze data, it is important to know what type of data we are dealing with.
We can split the data types into three main categories:
• Numerical
• Categorical
. Ordinal
Numerical data are numbers, and can be split into two numerical categories:
• Discrete Data
- counted data that are limited to integers. Example: The number of cars passing by.
. Continuous Data
- measured data that can be any number. Example: The price of an item, or the size
of an item
Categorical data are values that cannot be measured up against each other. Example: a
color value, or any yes/no values.
Ordinal data are like categorical data, but can be measured up against each other.
Example: school grades where A is better than B and so on.
By knowing the data type of your data source, you will be able to know what technique to
use when analyzing them.
You will learn more about statistics and analyzing data in the next chapters.', NULL, false, '2025-07-04 09:55:16.818963+00', '2025-07-04 09:55:16.998863+00'),
	('2dbb12bf-0dd3-4df1-ad7f-ca5d00f7a404', 'ec501ca8-a4e9-403d-a818-4371062bcbf8', 'Athena Adaptive Review', 'Documentation', 'computerScience', 'imageFile', NULL, 'ec501ca8-a4e9-403d-a818-4371062bcbf8/2dbb12bf-0dd3-4df1-ad7f-ca5d00f7a404/1751949971524_image_cropper_1751949911937.jpg', '4. Adaptive Review System (Quizzes & Spaced Repetition)
4.1. Purpose & Value:
G Preview part_4.md X
The Adaptive Review System aims to combat the Ebbinghaus forgetting curve by providing personalized and tim
knowiedge on their study materials, identifies areas of weakness, and schedules future reviews using spaced rer
practice are proven methods for long-term knowledge retention. For CW2, this feature showcases signíficant UI
complexity (spaced repetition), robust data persistence, and a potential "intensive" use of an LLM APIl ifA-driven
4.2. User Stories I Key Use Cases:
• UC4.1 (Student - Create Quiz from Material): As a student, I want to be able to select one of my uploaded
generate a quiz (e.g., flashcards, MCQs) based on its content.
•UC4.2 (Student -Create Manual Quiz/Flashcards): As a student, I want to be able to manually create my
questions and answers.
UC4.3 (Student - Start Review Session): As a student, I want to be able to start a review session that pres
based on the spaced repetition schedule.
UC44 (Student - Answer Question/Flip Flashcard): As a student, during a review session, I want to be abl
then reveal the answer/definition.
• UC4.5 (Student - Self-Assess Performance): As a student, after revealing an answer, I want to be able to ir
"Hard," "Again") so the systerm can adjust the next review schedule for that item.', '### Summary of "Athena Adaptive Review"

#### 1. Purpose & Value
- **Adaptive Review System**: Designed to enhance long-term knowledge retention by addressing the Ebbinghaus forgetting curve.
- **Personalization**: Tailors review sessions based on individual student performance and knowledge gaps.
- **Spaced Repetition**: Utilizes spaced repetition techniques to optimize review timing and improve retention.
- **User Interface Complexity**: Incorporates a sophisticated user interface and robust data management, potentially leveraging AI-driven tools.

#### 2. Key Use Cases (User Stories)
- **UC4.1: Create Quiz from Material** 
  - Students can select uploaded materials to generate quizzes (e.g., flashcards, multiple-choice questions).
  
- **UC4.2: Create Manual Quiz/Flashcards**
  - Students have the option to manually create their own questions and answers for personalized study.

- **UC4.3: Start Review Session**
  - Students can initiate a review session that aligns with their spaced repetition schedule.

- **UC4.4: Answer Question/Flip Flashcard**
  - During review, students can answer questions and reveal the corresponding definitions or answers.

- **UC4.5: Self-Assess Performance**
  - After answering, students can rate their performance (e.g., "Hard," "Again") to adjust future review schedules for that item.

### Conclusion
The Athena Adaptive Review system is a powerful tool for students, enhancing study efficiency through personalized quizzes and spaced repetition, ultimately fostering better retention of knowledge.', true, '2025-07-08 04:46:10.374218+00', '2025-07-08 04:46:32.449166+00');


--
-- Data for Name: quizzes; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."quizzes" ("id", "user_id", "title", "quiz_type", "study_material_id", "subject", "description", "created_at", "updated_at") VALUES
	('405b4f09-f275-43c5-bb8c-2d028e7c0288', 'ec501ca8-a4e9-403d-a818-4371062bcbf8', 'CS169 Data Structures 101: Flashcards', 'flashcard', '10a0039f-105c-4e62-a1a7-a89e07a73128', 'computerScience', 'Flashcards for CS169 Data Structures 101', '2025-07-04 14:46:24.057377+00', '2025-07-04 14:46:24.057377+00'),
	('b007867d-fb09-416e-8a2c-5f8e5c268af0', 'ec501ca8-a4e9-403d-a818-4371062bcbf8', 'CS169 Data Structures 101: MCQs', 'multipleChoice', '10a0039f-105c-4e62-a1a7-a89e07a73128', 'computerScience', 'MCQ revision for CS169 Data Structures 101', '2025-07-04 14:52:20.299732+00', '2025-07-04 14:52:20.299732+00'),
	('e3a5d538-dfca-4ef2-aa2d-873a77988726', 'ec501ca8-a4e9-403d-a818-4371062bcbf8', 'CS420 Operating Systems 101: Flashcards', 'flashcard', NULL, 'computerScience', 'Flashcards for CS420 Operating Systems 101', '2025-07-04 14:34:25.394066+00', '2025-07-04 14:58:03.47398+00'),
	('0b923ab2-50e6-427c-9767-bc30b7aeb5c0', 'ec501ca8-a4e9-403d-a818-4371062bcbf8', 'CS420 Operating Systems 101: MCQs', 'multipleChoice', NULL, 'computerScience', 'MCQ revision for CS420 Operating Systems 101', '2025-07-04 14:41:29.47461+00', '2025-07-04 15:00:34.111051+00'),
	('ab3bae8b-6b97-4592-a888-65c24ba4a946', 'ec501ca8-a4e9-403d-a818-4371062bcbf8', 'Athena Adaptive Review MCQ', 'multipleChoice', '2dbb12bf-0dd3-4df1-ad7f-ca5d00f7a404', 'computerScience', 'Test', '2025-07-08 04:47:33.84434+00', '2025-07-08 04:47:33.84434+00');


--
-- Data for Name: quiz_items; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."quiz_items" ("id", "quiz_id", "user_id", "item_type", "question_text", "answer_text", "mcq_options", "mcq_correct_option_key", "easiness_factor", "interval_days", "repetitions", "last_reviewed_at", "next_review_date", "metadata", "created_at", "updated_at") VALUES
	('65a1cea7-c1b6-4998-9333-a198f131cb4b', '405b4f09-f275-43c5-bb8c-2d028e7c0288', 'ec501ca8-a4e9-403d-a818-4371062bcbf8', 'flashcard', 'What is a data structure?', 'A data structure is a way of organizing and storing data to enable efficient access and modification.', NULL, NULL, 2.50, 1, 0, '2025-07-04 14:46:18.88026+00', '2025-07-05', NULL, '2025-07-04 14:46:24.100393+00', '2025-07-04 14:46:24.100393+00'),
	('b26e050b-1f00-4b3e-95c8-2d5545a467d4', '405b4f09-f275-43c5-bb8c-2d028e7c0288', 'ec501ca8-a4e9-403d-a818-4371062bcbf8', 'flashcard', 'What are the common types of data structures?', 'The common types of data structures include arrays, linked lists, stacks, queues, trees, graphs, and hash tables.', NULL, NULL, 2.50, 1, 0, '2025-07-04 14:46:18.880413+00', '2025-07-05', NULL, '2025-07-04 14:46:24.13372+00', '2025-07-04 14:46:24.13372+00'),
	('cf7ac35d-a1aa-47ec-a556-19846b1e3dc4', '405b4f09-f275-43c5-bb8c-2d028e7c0288', 'ec501ca8-a4e9-403d-a818-4371062bcbf8', 'flashcard', 'What are the key characteristics of arrays?', 'Arrays have a fixed size, allow random access, and provide constant time lookup for elements.', NULL, NULL, 2.50, 1, 0, '2025-07-04 14:46:18.880471+00', '2025-07-05', NULL, '2025-07-04 14:46:24.154405+00', '2025-07-04 14:46:24.154405+00'),
	('dc2803be-404a-4ee8-aa10-d50fffd9c242', '405b4f09-f275-43c5-bb8c-2d028e7c0288', 'ec501ca8-a4e9-403d-a818-4371062bcbf8', 'flashcard', 'How does a linked list differ from an array?', 'A linked list has a dynamic size and allows sequential access, making it more efficient for insertions and deletions compared to arrays.', NULL, NULL, 2.50, 1, 0, '2025-07-04 14:46:18.880531+00', '2025-07-05', NULL, '2025-07-04 14:46:24.17477+00', '2025-07-04 14:46:24.17477+00'),
	('6d88069f-dcc7-44ed-919d-bb5b98315a62', '405b4f09-f275-43c5-bb8c-2d028e7c0288', 'ec501ca8-a4e9-403d-a818-4371062bcbf8', 'flashcard', 'What is the main principle of a stack?', 'A stack operates on a Last In, First Out (LIFO) principle, utilizing push and pop operations to manage data.', NULL, NULL, 2.50, 1, 0, '2025-07-04 14:46:18.880801+00', '2025-07-05', NULL, '2025-07-04 14:46:24.197304+00', '2025-07-04 14:46:24.197304+00'),
	('0f40f6a8-528f-46d3-9a69-3d7f995062b4', '405b4f09-f275-43c5-bb8c-2d028e7c0288', 'ec501ca8-a4e9-403d-a818-4371062bcbf8', 'flashcard', 'Describe the function of a queue in data structures.', 'A queue follows a First In, First Out (FIFO) principle, using enqueue to add elements and dequeue to remove them.', NULL, NULL, 2.50, 1, 0, '2025-07-04 14:46:18.88083+00', '2025-07-05', NULL, '2025-07-04 14:46:24.213385+00', '2025-07-04 14:46:24.213385+00'),
	('327586aa-9969-4eac-95b9-fdce40e489b1', '405b4f09-f275-43c5-bb8c-2d028e7c0288', 'ec501ca8-a4e9-403d-a818-4371062bcbf8', 'flashcard', 'What is a hash table and its primary advantage?', 'A hash table is a data structure that maps keys to values, allowing for average-case constant time access to elements, enhancing efficiency.', NULL, NULL, 2.50, 1, 0, '2025-07-04 14:46:18.88128+00', '2025-07-05', NULL, '2025-07-04 14:46:24.234167+00', '2025-07-04 14:46:24.234167+00'),
	('de0ea3bf-3a67-4fa1-8b64-8c4e9c64497d', 'b007867d-fb09-416e-8a2c-5f8e5c268af0', 'ec501ca8-a4e9-403d-a818-4371062bcbf8', 'multipleChoice', 'What is the primary characteristic of an array data structure?', '', '{"A": "Fixed size", "B": "Dynamic size", "C": "Hierarchical structure", "D": "Key-value mapping"}', 'A', 2.50, 1, 0, '2025-07-04 14:52:15.139514+00', '2025-07-05', NULL, '2025-07-04 14:52:20.332788+00', '2025-07-04 14:52:20.332788+00'),
	('8ccbbe5b-0a57-4a1c-931c-e0cbe0cefc89', 'b007867d-fb09-416e-8a2c-5f8e5c268af0', 'ec501ca8-a4e9-403d-a818-4371062bcbf8', 'multipleChoice', 'Which data structure is best suited for scenarios requiring frequent insertions and deletions?', '', '{"A": "Array", "B": "Stack", "C": "Linked List", "D": "Queue"}', 'C', 2.50, 1, 0, '2025-07-04 14:52:15.139638+00', '2025-07-05', NULL, '2025-07-04 14:52:20.366656+00', '2025-07-04 14:52:20.366656+00'),
	('bf9d1243-921a-41ed-81ae-814ba58e330f', 'b007867d-fb09-416e-8a2c-5f8e5c268af0', 'ec501ca8-a4e9-403d-a818-4371062bcbf8', 'multipleChoice', 'In which data structure is the Last In First Out (LIFO) principle applied?', '', '{"A": "Queue", "B": "Stack", "C": "Tree", "D": "Array"}', 'B', 2.50, 1, 0, '2025-07-04 14:52:15.139679+00', '2025-07-05', NULL, '2025-07-04 14:52:20.399452+00', '2025-07-04 14:52:20.399452+00'),
	('b85e4da5-af41-45c6-aa3d-20ede39ae234', 'b007867d-fb09-416e-8a2c-5f8e5c268af0', 'ec501ca8-a4e9-403d-a818-4371062bcbf8', 'multipleChoice', 'What is the main advantage of using a hash table?', '', '{"A": "Sequential access", "B": "Constant time average-case access", "C": "Dynamic size", "D": "Hierarchical structure"}', 'B', 2.50, 1, 0, '2025-07-04 14:52:15.13972+00', '2025-07-05', NULL, '2025-07-04 14:52:20.415635+00', '2025-07-04 14:52:20.415635+00'),
	('62988176-c48e-455f-96bc-2685a776e167', 'b007867d-fb09-416e-8a2c-5f8e5c268af0', 'ec501ca8-a4e9-403d-a818-4371062bcbf8', 'multipleChoice', 'Which of the following describes a binary search tree (BST)?', '', '{"A": "A structure that allows for fast lookup", "B": "A linear structure for sequential access", "C": "A stack that follows the FIFO principle", "D": "A fixed-size data structure"}', 'A', 2.50, 1, 0, '2025-07-04 14:52:15.139749+00', '2025-07-05', NULL, '2025-07-04 14:52:20.437461+00', '2025-07-04 14:52:20.437461+00'),
	('248bbb8c-4db1-4082-834b-ad27a938893d', 'b007867d-fb09-416e-8a2c-5f8e5c268af0', 'ec501ca8-a4e9-403d-a818-4371062bcbf8', 'multipleChoice', 'What is the primary operation associated with a queue data structure?', '', '{"A": "Push", "B": "Pop", "C": "Enqueue", "D": "Dequeue"}', 'C', 2.50, 1, 0, '2025-07-04 14:52:15.139984+00', '2025-07-05', NULL, '2025-07-04 14:52:20.460395+00', '2025-07-04 14:52:20.460395+00'),
	('a4e3fcb3-31b8-447e-89e1-9e1192746db9', 'e3a5d538-dfca-4ef2-aa2d-873a77988726', 'ec501ca8-a4e9-403d-a818-4371062bcbf8', 'flashcard', 'What is a deadlock?', 'A deadlock occurs when a set of processes are blocked because each process is waiting for a resource held by another.', NULL, NULL, 2.60, 1, 1, '2025-07-05 07:29:32.960579+00', '2025-07-06', NULL, '2025-07-04 14:34:25.558586+00', '2025-07-05 07:29:35.086399+00'),
	('f8c9bfdb-42dd-4306-bc2e-27672fd5425c', 'e3a5d538-dfca-4ef2-aa2d-873a77988726', 'ec501ca8-a4e9-403d-a818-4371062bcbf8', 'flashcard', 'What is the difference between a thread and a process?', 'A thread is the smallest unit of CPU execution within a process. Threads within the same process share memory, while processes are isolated.', NULL, NULL, 2.50, 1, 1, '2025-07-05 07:29:53.805419+00', '2025-07-06', NULL, '2025-07-04 14:34:25.541052+00', '2025-07-05 07:29:55.932113+00'),
	('49b61927-5660-4a1e-b878-ae9e28b00bec', 'e3a5d538-dfca-4ef2-aa2d-873a77988726', 'ec501ca8-a4e9-403d-a818-4371062bcbf8', 'flashcard', 'Define context switching.', 'Context switching is the process of storing and restoring the state of a CPU so that multiple processes can share a single CPU resource.', NULL, NULL, 2.18, 1, 0, '2025-07-05 07:30:04.704255+00', '2025-07-06', NULL, '2025-07-04 14:34:25.515329+00', '2025-07-05 07:30:06.827499+00'),
	('5dabcfcb-e9a7-476b-ae05-6013c6ef35b8', 'e3a5d538-dfca-4ef2-aa2d-873a77988726', 'ec501ca8-a4e9-403d-a818-4371062bcbf8', 'flashcard', 'What is a process in an OS?', 'A process is a program in execution, consisting of the program code, its current activity, and allocated resources.', NULL, NULL, 1.70, 1, 0, '2025-07-05 07:31:06.926907+00', '2025-07-06', NULL, '2025-07-04 14:34:25.463636+00', '2025-07-05 07:31:09.048329+00'),
	('8d000ecb-cf00-4743-8e3d-addfb5d3eac9', '0b923ab2-50e6-427c-9767-bc30b7aeb5c0', 'ec501ca8-a4e9-403d-a818-4371062bcbf8', 'multipleChoice', 'In a multiprogramming system, what does CPU-bound mean?', '', '{"A": "The process spends most of its time on I/O operations", "B": "The process uses minimal CPU resources", "C": "The process heavily relies on memory operations", "D": "The process spends most of its time performing computations"}', 'D', 2.60, 1, 1, '2025-07-05 07:38:04.872631+00', '2025-07-06', NULL, '2025-07-04 14:41:29.560304+00', '2025-07-05 07:38:06.996491+00'),
	('a2717b3a-799c-4a48-9ed6-aecd4498164b', '0b923ab2-50e6-427c-9767-bc30b7aeb5c0', 'ec501ca8-a4e9-403d-a818-4371062bcbf8', 'multipleChoice', 'Which of the following is NOT a type of process scheduling algorithm?', '', '{"A": "First-Come First-Served (FCFS)", "B": "Shortest Job Next (SJN)", "C": "Least Recently Used (LRU)", "D": "Round Robin (RR)"}', 'C', 2.60, 1, 1, '2025-07-05 07:38:39.480862+00', '2025-07-06', NULL, '2025-07-04 14:41:29.539416+00', '2025-07-05 07:38:41.599337+00'),
	('88ff970a-0494-4078-adbe-1d1fbbf91b02', '0b923ab2-50e6-427c-9767-bc30b7aeb5c0', 'ec501ca8-a4e9-403d-a818-4371062bcbf8', 'multipleChoice', 'What is the purpose of a scheduler in an operating system?', '', '{"A": "To detect deadlocks", "B": "To manage file systems", "C": "To decide which process runs next", "D": "To allocate memory blocks"}', 'C', 1.70, 1, 0, '2025-07-05 07:39:51.715511+00', '2025-07-06', NULL, '2025-07-04 14:41:29.508316+00', '2025-07-05 07:39:53.838029+00'),
	('bf6dd107-d082-4524-a793-10c524dc5d39', '0b923ab2-50e6-427c-9767-bc30b7aeb5c0', 'ec501ca8-a4e9-403d-a818-4371062bcbf8', 'multipleChoice', 'Which of the following conditions is NOT required for a deadlock to occur?', '', '{"A": "Mutual Exclusion", "B": "Preemption", "C": "Circular Wait", "D": "Hold and Wait"}', 'B', 2.70, 6, 2, '2025-07-08 04:32:38.699878+00', '2025-07-14', NULL, '2025-07-04 14:41:29.591627+00', '2025-07-08 04:32:40.121926+00'),
	('c5528a50-5188-4873-a246-77d5b68fd697', 'ab3bae8b-6b97-4592-a888-65c24ba4a946', 'ec501ca8-a4e9-403d-a818-4371062bcbf8', 'multipleChoice', 'What is the primary purpose of the Adaptive Review System?', '', '{"A": "To create quizzes from uploaded materials", "B": "To combat the Ebbinghaus forgetting curve", "C": "To track student performance", "D": "To provide unlimited study materials"}', 'B', 2.50, 1, 0, '2025-07-08 12:47:34.8423+00', '2025-07-09', NULL, '2025-07-08 04:47:33.882033+00', '2025-07-08 04:47:33.882033+00'),
	('436e2289-3341-4290-81dc-d7a28c4d6a87', 'ab3bae8b-6b97-4592-a888-65c24ba4a946', 'ec501ca8-a4e9-403d-a818-4371062bcbf8', 'multipleChoice', 'How does the Adaptive Review System enhance knowledge retention?', '', '{"A": "By providing random quizzes", "B": "Through spaced repetition and personalized reviews", "C": "By offering unlimited review sessions", "D": "By allowing manual question creation only"}', 'B', 2.50, 1, 0, '2025-07-08 12:47:34.843771+00', '2025-07-09', NULL, '2025-07-08 04:47:33.913653+00', '2025-07-08 04:47:33.913653+00'),
	('dfe3ace5-1fcb-47c0-a015-7c99c417c217', 'ab3bae8b-6b97-4592-a888-65c24ba4a946', 'ec501ca8-a4e9-403d-a818-4371062bcbf8', 'multipleChoice', 'What feature allows students to assess their own performance during a review session?', '', '{"A": "Creating flashcards", "B": "Flipping flashcards to reveal answers", "C": "Self-assessing with options like ''Hard'' or ''Again''", "D": "Starting a new review session"}', 'C', 2.50, 1, 0, '2025-07-08 12:47:34.843855+00', '2025-07-09', NULL, '2025-07-08 04:47:33.942215+00', '2025-07-08 04:47:33.942215+00'),
	('cbb88135-479e-4c92-9911-aaec925bb7d3', 'ab3bae8b-6b97-4592-a888-65c24ba4a946', 'ec501ca8-a4e9-403d-a818-4371062bcbf8', 'multipleChoice', 'Which user case involves a student wanting to manually create quiz questions?', '', '{"A": "UC4.1", "B": "UC4.2", "C": "UC4.3", "D": "UC4.4"}', 'B', 2.50, 1, 0, '2025-07-08 12:47:34.843888+00', '2025-07-09', NULL, '2025-07-08 04:47:33.964623+00', '2025-07-08 04:47:33.964623+00'),
	('0f0291ed-c9ce-4256-839c-daaa73f79e0c', 'ab3bae8b-6b97-4592-a888-65c24ba4a946', 'ec501ca8-a4e9-403d-a818-4371062bcbf8', 'multipleChoice', 'What does the Adaptive Review System use to schedule future reviews?', '', '{"A": "User''s choice of study materials", "B": "Spaced repetition based on weaknesses", "C": "Random selection of topics", "D": "A fixed schedule for all topics"}', 'B', 2.50, 1, 0, '2025-07-08 12:47:34.843929+00', '2025-07-09', NULL, '2025-07-08 04:47:33.990906+00', '2025-07-08 04:47:33.990906+00'),
	('be76bb3a-694c-4573-8417-439711c732e8', 'ab3bae8b-6b97-4592-a888-65c24ba4a946', 'ec501ca8-a4e9-403d-a818-4371062bcbf8', 'multipleChoice', 'What is a key benefit of using the Adaptive Review System for students?', '', '{"A": "It guarantees memorization of all materials", "B": "It helps identify areas of weakness and focuses on them", "C": "It eliminates the need for any manual study", "D": "It provides a single review session for all materials"}', 'B', 2.50, 1, 0, '2025-07-08 12:47:34.843955+00', '2025-07-09', NULL, '2025-07-08 04:47:34.010103+00', '2025-07-08 04:47:34.010103+00');


--
-- Data for Name: review_sessions; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."review_sessions" ("id", "user_id", "quiz_id", "session_type", "total_items", "completed_items", "correct_responses", "average_difficulty", "session_duration_seconds", "status", "started_at", "completed_at") VALUES
	('bf2cab6c-c396-4e39-a71e-cbf769ae1e89', 'ec501ca8-a4e9-403d-a818-4371062bcbf8', 'e3a5d538-dfca-4ef2-aa2d-873a77988726', 'mixed', 4, 0, 0, NULL, NULL, 'active', '2025-07-05 07:25:43.247139+00', NULL),
	('0a3b67fc-f7de-44a0-894b-a1faf5dcd33d', 'ec501ca8-a4e9-403d-a818-4371062bcbf8', 'e3a5d538-dfca-4ef2-aa2d-873a77988726', 'mixed', 4, 4, 2, 2.5, 140, 'completed', '2025-07-05 07:28:46.679985+00', '2025-07-05 07:31:06.989033+00'),
	('1d581006-d215-4e83-8e51-bb8a486cecb3', 'ec501ca8-a4e9-403d-a818-4371062bcbf8', '0b923ab2-50e6-427c-9767-bc30b7aeb5c0', 'mixed', 4, 4, 3, 3.5, 267, 'completed', '2025-07-05 07:35:24.663268+00', '2025-07-05 07:39:51.76925+00'),
	('24f0b854-75e6-4d68-9dac-de53ee5a5a05', 'ec501ca8-a4e9-403d-a818-4371062bcbf8', '0b923ab2-50e6-427c-9767-bc30b7aeb5c0', 'mixed', 4, 1, 1, 4.0, NULL, 'active', '2025-07-08 04:32:34.705759+00', NULL);


--
-- Data for Name: review_responses; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."review_responses" ("id", "session_id", "quiz_item_id", "user_id", "difficulty_rating", "response_time_seconds", "user_answer", "is_correct", "previous_easiness_factor", "previous_interval_days", "previous_repetitions", "new_easiness_factor", "new_interval_days", "new_repetitions", "new_next_review_date", "responded_at") VALUES
	('e25d039b-31ef-40a7-ba80-9c5cfc045679', '0a3b67fc-f7de-44a0-894b-a1faf5dcd33d', 'a4e3fcb3-31b8-447e-89e1-9e1192746db9', 'ec501ca8-a4e9-403d-a818-4371062bcbf8', 'easy', 48, NULL, true, 2.50, 1, 0, 2.60, 1, 1, '2025-07-06', '2025-07-05 07:29:32.90663+00'),
	('ecaaeda0-78a0-4947-9392-be0c0655440b', '0a3b67fc-f7de-44a0-894b-a1faf5dcd33d', 'f8c9bfdb-42dd-4306-bc2e-27672fd5425c', 'ec501ca8-a4e9-403d-a818-4371062bcbf8', 'good', 20, NULL, true, 2.50, 1, 0, 2.50, 1, 1, '2025-07-06', '2025-07-05 07:29:53.779717+00'),
	('5a8734f1-554c-4b54-90b4-3206fc7c38a1', '0a3b67fc-f7de-44a0-894b-a1faf5dcd33d', '49b61927-5660-4a1e-b878-ae9e28b00bec', 'ec501ca8-a4e9-403d-a818-4371062bcbf8', 'hard', 10, NULL, false, 2.50, 1, 0, 2.18, 1, 0, '2025-07-06', '2025-07-05 07:30:04.649502+00'),
	('95e42995-232b-47ff-8647-c503a66c626d', '0a3b67fc-f7de-44a0-894b-a1faf5dcd33d', '5dabcfcb-e9a7-476b-ae05-6013c6ef35b8', 'ec501ca8-a4e9-403d-a818-4371062bcbf8', 'forgot', 62, NULL, false, 2.50, 1, 0, 1.70, 1, 0, '2025-07-06', '2025-07-05 07:31:06.893197+00'),
	('46b9362e-eb27-4fcb-ad32-6b980b673cb1', '1d581006-d215-4e83-8e51-bb8a486cecb3', 'bf6dd107-d082-4524-a793-10c524dc5d39', 'ec501ca8-a4e9-403d-a818-4371062bcbf8', 'easy', 69, 'B', true, 2.50, 1, 0, 2.60, 1, 1, '2025-07-06', '2025-07-05 07:36:32.315808+00'),
	('2e399c0e-2256-4096-8298-ce84a6c58d29', '1d581006-d215-4e83-8e51-bb8a486cecb3', '8d000ecb-cf00-4743-8e3d-addfb5d3eac9', 'ec501ca8-a4e9-403d-a818-4371062bcbf8', 'easy', 92, 'D', true, 2.50, 1, 0, 2.60, 1, 1, '2025-07-06', '2025-07-05 07:38:04.822229+00'),
	('c31e5bce-ed8d-4551-8beb-3d960499a9d3', '1d581006-d215-4e83-8e51-bb8a486cecb3', 'a2717b3a-799c-4a48-9ed6-aecd4498164b', 'ec501ca8-a4e9-403d-a818-4371062bcbf8', 'easy', 34, 'C', true, 2.50, 1, 0, 2.60, 1, 1, '2025-07-06', '2025-07-05 07:38:39.437515+00'),
	('a8dd17ec-5063-417b-a477-61f946427eb2', '1d581006-d215-4e83-8e51-bb8a486cecb3', '88ff970a-0494-4078-adbe-1d1fbbf91b02', 'ec501ca8-a4e9-403d-a818-4371062bcbf8', 'hard', 72, 'A', false, 2.50, 1, 0, 1.70, 1, 0, '2025-07-06', '2025-07-05 07:39:51.675799+00'),
	('ace2073e-108d-41db-a9f4-7a9808b8bdf8', '24f0b854-75e6-4d68-9dac-de53ee5a5a05', 'bf6dd107-d082-4524-a793-10c524dc5d39', 'ec501ca8-a4e9-403d-a818-4371062bcbf8', 'easy', 5, 'B', true, 2.60, 1, 1, 2.70, 6, 2, '2025-07-14', '2025-07-08 04:32:38.66614+00');


--
-- Data for Name: study_goals; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: study_sessions; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."study_sessions" ("id", "user_id", "study_goal_id", "title", "subject", "start_time", "end_time", "status", "reminder_offset_minutes", "notes", "actual_duration_minutes", "linked_material_id", "created_at", "updated_at") VALUES
	('c67f25c5-9f4b-4f7f-8efc-d5edcf831f85', 'ec501ca8-a4e9-403d-a818-4371062bcbf8', NULL, '6002CEM CW2 Report: 3.2 User Dashboard', 'Computer Science', '2025-07-04 17:00:00+00', '2025-07-04 18:00:00+00', 'scheduled', NULL, 'Complete 3.0 Modules and Screenshots - 3.2 User Dashboard', NULL, NULL, '2025-07-04 08:13:34.058566+00', '2025-07-04 08:18:19.898749+00'),
	('734209e0-fa2e-4aed-95dc-54cafca5ad39', 'ec501ca8-a4e9-403d-a818-4371062bcbf8', NULL, '6002CEM CW2 Report: 3.4 Study Material Management', 'Computer Science', '2025-07-04 19:00:00+00', '2025-07-04 21:00:00+00', 'scheduled', NULL, 'Complete 3.0 Modules and Screenshots - 3.4 Study Material Management', NULL, NULL, '2025-07-04 08:17:16.569837+00', '2025-07-04 08:18:34.655768+00'),
	('b12b47b5-e73f-4ee8-a3ff-13798fe08a91', 'ec501ca8-a4e9-403d-a818-4371062bcbf8', NULL, '6002CEM CW2 Report: 3.5 Adaptive Review System', 'Computer Science', '2025-07-04 21:00:00+00', '2025-07-04 23:59:00+00', 'scheduled', NULL, 'Complete 3.0 Modules and Screenshots - 3.5 Adaptive Review System', NULL, NULL, '2025-07-04 08:18:07.071293+00', '2025-07-04 08:18:42.746753+00'),
	('091928ea-0001-47c1-a3c4-a76450c0414b', 'ec501ca8-a4e9-403d-a818-4371062bcbf8', NULL, '6002CEM CW2 Report: 4.0 Strengths of the App', 'Computer Science', '2025-07-05 08:00:00+00', '2025-07-05 09:00:00+00', 'scheduled', NULL, 'Complete 4.0 Strengths of the App (max 2 pages)', NULL, NULL, '2025-07-04 08:19:42.685288+00', '2025-07-04 08:19:42.685288+00'),
	('66560510-329c-4673-9b70-11b63fa3b721', 'ec501ca8-a4e9-403d-a818-4371062bcbf8', NULL, 'test', 'Mathematics', '2025-07-07 20:33:00+00', '2025-07-07 21:33:00+00', 'scheduled', NULL, 'test', NULL, NULL, '2025-07-08 04:34:19.751443+00', '2025-07-08 04:34:19.751443+00');


--
-- Data for Name: buckets; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

INSERT INTO "storage"."buckets" ("id", "name", "owner", "created_at", "updated_at", "public", "avif_autodetection", "file_size_limit", "allowed_mime_types", "owner_id") VALUES
	('avatars', 'avatars', NULL, '2025-07-04 07:43:22.789043+00', '2025-07-04 07:43:22.789043+00', false, false, NULL, NULL, NULL),
	('study-materials', 'study-materials', NULL, '2025-07-04 07:43:22.886832+00', '2025-07-04 07:43:22.886832+00', false, false, 10485760, '{text/plain,application/pdf,image/jpeg,image/png,image/jpg,image/webp,application/vnd.openxmlformats-officedocument.wordprocessingml.document,application/msword}', NULL),
	('chat-attachments', 'chat-attachments', NULL, '2025-07-04 07:43:23.017233+00', '2025-07-04 07:43:23.017233+00', false, false, NULL, NULL, NULL);


--
-- Data for Name: objects; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

INSERT INTO "storage"."objects" ("id", "bucket_id", "name", "owner", "created_at", "updated_at", "last_accessed_at", "metadata", "version", "owner_id", "user_metadata", "level") VALUES
	('6140141b-a9f1-4a62-8b8e-e19b812900e2', 'study-materials', 'ec501ca8-a4e9-403d-a818-4371062bcbf8/91fb0b85-52c3-4a2d-bd62-4ea6c742b56b/1751622681946_OpenMP Scheduling.pdf', 'ec501ca8-a4e9-403d-a818-4371062bcbf8', '2025-07-04 09:51:21.356053+00', '2025-07-04 09:51:21.356053+00', '2025-07-04 09:51:21.356053+00', '{"eTag": "\"fe826bcf99b352eddbabd90404468b2d\"", "size": 300639, "mimetype": "application/pdf", "cacheControl": "max-age=3600", "lastModified": "2025-07-04T09:51:21.330Z", "contentLength": 300639, "httpStatusCode": 200}', '60885e9d-8204-44c4-a29b-ba20fd2f95b6', 'ec501ca8-a4e9-403d-a818-4371062bcbf8', '{}', 3),
	('c8a5e6c7-f271-4bc2-8701-e8bc9f0822f7', 'study-materials', 'ec501ca8-a4e9-403d-a818-4371062bcbf8/f9ae6e5d-ff62-4848-9785-c0ff782a3dc1/1751622917753_image_cropper_1751622784263.jpg', 'ec501ca8-a4e9-403d-a818-4371062bcbf8', '2025-07-04 09:55:16.945082+00', '2025-07-04 09:55:16.945082+00', '2025-07-04 09:55:16.945082+00', '{"eTag": "\"42e5212e08f28acb9cb7deb9575601fd\"", "size": 327853, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2025-07-04T09:55:16.930Z", "contentLength": 327853, "httpStatusCode": 200}', '19a8b83c-33e9-438a-a90c-b8ea237efdef', 'ec501ca8-a4e9-403d-a818-4371062bcbf8', '{}', 3),
	('cc9b69a0-0f13-4b72-997c-12d70c9275ff', 'study-materials', 'ec501ca8-a4e9-403d-a818-4371062bcbf8/2dbb12bf-0dd3-4df1-ad7f-ca5d00f7a404/1751949971524_image_cropper_1751949911937.jpg', 'ec501ca8-a4e9-403d-a818-4371062bcbf8', '2025-07-08 04:46:10.763951+00', '2025-07-08 04:46:10.763951+00', '2025-07-08 04:46:10.763951+00', '{"eTag": "\"81cd3e854d610d507b1ea28b51e9e761\"", "size": 329801, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2025-07-08T04:46:10.724Z", "contentLength": 329801, "httpStatusCode": 200}', 'a361fd32-948a-4646-8cd7-25087ce29db4', 'ec501ca8-a4e9-403d-a818-4371062bcbf8', '{}', 3);


--
-- Data for Name: prefixes; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

INSERT INTO "storage"."prefixes" ("bucket_id", "name", "created_at", "updated_at") VALUES
	('study-materials', 'ec501ca8-a4e9-403d-a818-4371062bcbf8', '2025-07-04 09:51:21.356053+00', '2025-07-04 09:51:21.356053+00'),
	('study-materials', 'ec501ca8-a4e9-403d-a818-4371062bcbf8/91fb0b85-52c3-4a2d-bd62-4ea6c742b56b', '2025-07-04 09:51:21.356053+00', '2025-07-04 09:51:21.356053+00'),
	('study-materials', 'ec501ca8-a4e9-403d-a818-4371062bcbf8/f9ae6e5d-ff62-4848-9785-c0ff782a3dc1', '2025-07-04 09:55:16.945082+00', '2025-07-04 09:55:16.945082+00'),
	('study-materials', 'ec501ca8-a4e9-403d-a818-4371062bcbf8/2dbb12bf-0dd3-4df1-ad7f-ca5d00f7a404', '2025-07-08 04:46:10.763951+00', '2025-07-08 04:46:10.763951+00');


--
-- Data for Name: s3_multipart_uploads; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--



--
-- Data for Name: s3_multipart_uploads_parts; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--



--
-- PostgreSQL database dump complete
--

RESET ALL;

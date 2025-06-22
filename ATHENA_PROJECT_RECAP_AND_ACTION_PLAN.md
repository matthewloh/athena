# Athena Project - Comprehensive Recap & Action Plan

**Date: June 20, 2024**  
**Last Activity: June 4, 2024**  
**Project: 6002CEM CW2 - Athena AI Study Companion**

## 🎯 Project Overview

**Athena** is an AI-powered study companion mobile application being developed for the 6002CEM Mobile App Development Coursework 2 (CW2). This is a group project between Matthew Loh Yet Marn and Thor Wen Zheng, worth 75% of the module grade.

### Core Concept

Based on Thor Wen Zheng's CW1 report, Athena aims to enhance student learning through:

- **AI-powered academic assistance** via chatbot
- **Adaptive review system** with spaced repetition
- **Intelligent study planning** with notifications
- **Study material management** with AI summarization

### Tech Stack

- **Frontend**: Flutter/Dart with Riverpod state management
- **Backend**: Supabase (PostgreSQL + Edge Functions)
- **AI**: OpenAI GPT-4o-mini via Vercel AI SDK
- **Navigation**: GoRouter
- **Architecture**: Clean Architecture with MVVM pattern

## 📊 Current Status Analysis

### ✅ **COMPLETED COMPONENTS**

#### 1. Backend Infrastructure (🟢 FULLY FUNCTIONAL)

- **Database Schema**: Complete PostgreSQL schema with RLS policies
  - `profiles` table for user management
  - `conversations` and `chat_messages` tables for chatbot
  - Proper foreign key relationships and security policies
- **Edge Functions**: Streaming AI chat function deployed
  - `chat-stream/index.ts`: Full implementation with OpenAI integration
  - Real-time streaming responses with proper error handling
  - Zod validation and academic-focused system prompts
- **Database Functions**:
  - `update_conversation_timestamp()`: Auto-updates conversation metadata
  - `handle_new_user()`: Profile creation trigger
  - `get_conversations_with_stats()`: Conversation analytics

#### 2. Authentication System (🟡 MOSTLY COMPLETE)

- **UI Screens**: Landing, Login, Signup, Profile screens implemented
- **Core Functionality**: Email/password auth, logout, profile management
- **Integration**: Supabase Auth with proper RLS policies
- **State Management**: Riverpod-based AuthViewModel with proper error handling
- **Missing**: Password reset functionality, profile picture upload

#### 3. Chatbot Feature (🟡 BACKEND READY, FRONTEND SCAFFOLDED)

- **Architecture**: Complete Clean Architecture layers implemented
- **Backend**: Fully functional streaming chat with OpenAI
- **Frontend**: Basic UI scaffolded but not connected to backend
- **State Management**: Riverpod providers and ChatViewModel implemented
- **Missing**: Frontend-backend integration, conversation management UI

#### 4. Navigation & Core Infrastructure (🟢 COMPLETE)

- **Router**: GoRouter with auth-aware navigation
- **Theme**: Complete design system with Athena branding
- **Project Structure**: Clean Architecture with feature-based organization
- **State Management**: Riverpod with proper dependency injection

### 🔄 **PARTIALLY IMPLEMENTED**

#### 1. Home Dashboard (🟡 UI SCAFFOLDED)

- **Current**: Basic UI with feature navigation cards
- **Missing**: Real data integration from Supabase
- **Status**: Scaffold implementation with dummy data

#### 2. Study Materials Feature (🟡 UI SCAFFOLDED)

- **Current**: Complete UI design with material cards and filters
- **Missing**: Backend integration, file upload, AI summarization
- **Status**: UI-only implementation

#### 3. Review System Feature (🟡 UI SCAFFOLDED)

- **Current**: Quiz interface, statistics dashboard UI
- **Missing**: Spaced repetition logic, backend integration
- **Status**: UI-only implementation

### ⏳ **NOT STARTED**

#### 1. Study Planner Feature

- **Status**: Only route and navigation established
- **Needs**: Complete implementation from scratch

#### 2. Advanced Features

- **OCR Integration**: Planned for study materials
- **Notification System**: For study reminders
- **Data Analytics**: Progress tracking and insights

## 🎯 **IMMEDIATE PRIORITIES (Next 7 Days)**

Based on your preference for **Chatbot and Planner features**, here's the strategic roadmap:

### **Phase 1: Complete Chatbot Feature (Days 1-3)**

#### Day 1: Backend Integration

```bash
Priority: CRITICAL
Estimated Time: 6-8 hours
```

**Tasks:**

1. **Connect Frontend to Backend**

   - Update `ChatSupabaseDataSourceImpl.dart` to call the `chat-stream` Edge Function
   - Implement proper streaming response handling in the data layer
   - Test end-to-end message flow from UI to AI response

2. **Fix State Management**
   - Debug and complete `ChatViewModel` streaming integration
   - Ensure proper error handling and loading states
   - Implement conversation creation and selection

**Key Files to Modify:**

- `lib/features/chatbot/data/datasources/chat_supabase_datasource.dart`
- `lib/features/chatbot/data/repositories/chat_repository_impl.dart`
- `lib/features/chatbot/presentation/viewmodel/chat_viewmodel.dart`

#### Day 2: UI Enhancements

```bash
Priority: HIGH
Estimated Time: 4-6 hours
```

**Tasks:**

1. **Conversation Management UI**

   - Implement conversation list drawer/sidebar
   - Add "New Conversation" functionality
   - Implement conversation switching and history

2. **Enhanced Chat Interface**
   - Improve message bubbles with user avatars
   - Add typing indicators for AI responses
   - Implement message timestamps and status

**Key Files to Create/Modify:**

- `lib/features/chatbot/presentation/widgets/conversation_list_drawer.dart`
- `lib/features/chatbot/presentation/views/chatbot_screen.dart`
- `lib/features/chatbot/presentation/widgets/chat_bubble.dart`

#### Day 3: Testing & Polish

```bash
Priority: MEDIUM
Estimated Time: 3-4 hours
```

**Tasks:**

1. **End-to-End Testing**

   - Test conversation creation, messaging, AI responses
   - Verify proper data persistence and retrieval
   - Test error scenarios and recovery

2. **UI Polish**
   - Improve loading states and error handling
   - Add message retry functionality
   - Optimize performance and user experience

### **Phase 2: Build Study Planner Feature (Days 4-7)**

#### Day 4-5: Core Architecture

```bash
Priority: CRITICAL
Estimated Time: 8-10 hours
```

**Tasks:**

1. **Database Schema**

   - Create `study_goals` and `study_sessions` tables
   - Implement RLS policies for user data security
   - Add indexes for performance optimization

2. **Domain Layer**
   - Define entities: `StudyGoal`, `StudySession`
   - Create repository interfaces and use cases
   - Implement business logic for scheduling and notifications

**Database Migration Required:**

```sql
-- Create study_goals table
CREATE TABLE study_goals (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  target_completion_date DATE,
  is_completed BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create study_sessions table
CREATE TABLE study_sessions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  study_goal_id UUID REFERENCES study_goals(id) ON DELETE SET NULL,
  title TEXT NOT NULL,
  start_time TIMESTAMP WITH TIME ZONE NOT NULL,
  end_time TIMESTAMP WITH TIME ZONE NOT NULL,
  status TEXT DEFAULT 'scheduled' CHECK (status IN ('scheduled', 'completed', 'missed')),
  reminder_offset_minutes INTEGER,
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### Day 6: Data & State Management

```bash
Priority: HIGH
Estimated Time: 6-8 hours
```

**Tasks:**

1. **Data Layer Implementation**

   - Create Supabase data sources for goals and sessions
   - Implement repository with proper error handling
   - Add CRUD operations for goals and sessions

2. **State Management**
   - Create Riverpod providers for planner data
   - Implement PlannerViewModel with Riverpod
   - Handle loading states and data synchronization

#### Day 7: UI Implementation

```bash
Priority: HIGH
Estimated Time: 6-8 hours
```

**Tasks:**

1. **Calendar/Planner UI**

   - Implement calendar view using `table_calendar` package
   - Create goal creation and editing forms
   - Build session scheduling interface

2. **Notifications**
   - Integrate `flutter_local_notifications`
   - Implement reminder scheduling logic
   - Handle notification permissions and lifecycle

**Required Dependencies:**

```yaml
dependencies:
  table_calendar: ^3.0.9
  flutter_local_notifications: ^17.1.2
  timezone: ^0.9.4
```

## 🏗️ **TECHNICAL IMPLEMENTATION STRATEGY**

### **Chatbot Priority Tasks**

1. **Fix Data Source Integration**

```dart
// Key implementation in ChatSupabaseDataSourceImpl
@override
Future<Stream<ChatMessageEntity>> sendMessage(
  String conversationId,
  String message,
) async {
  final response = await _supabase.functions.invoke(
    'chat-stream',
    body: {
      'conversationId': conversationId,
      'message': message,
      'includeContext': true,
    },
  );

  // Handle streaming response and convert to ChatMessageEntity
  return _handleStreamingResponse(response);
}
```

1. **Complete ViewModel Integration**

```dart
// Update ChatViewModel to handle streaming
Future<void> sendMessage(String message) async {
  state = state.copyWith(isLoading: true);

  try {
    final messageStream = await _sendMessageUseCase.call(
      SendMessageParams(
        conversationId: state.activeConversationId,
        message: message,
      ),
    );

    // Handle streaming updates
    messageStream.listen((aiMessage) {
      state = state.copyWith(
        messages: [...state.messages, aiMessage],
        isLoading: false,
      );
    });
  } catch (error) {
    state = state.copyWith(
      isLoading: false,
      error: ChatError(error.toString()),
    );
  }
}
```

### **Planner Architecture Approach**

1. **Follow Clean Architecture Pattern**

```bash
lib/features/planner/
├── data/
│   ├── datasources/planner_supabase_datasource.dart
│   ├── models/study_goal_model.dart
│   ├── models/study_session_model.dart
│   └── repositories/planner_repository_impl.dart
├── domain/
│   ├── entities/study_goal_entity.dart
│   ├── entities/study_session_entity.dart
│   ├── repositories/planner_repository.dart
│   └── usecases/
│       ├── create_study_goal_usecase.dart
│       ├── schedule_study_session_usecase.dart
│       └── get_upcoming_sessions_usecase.dart
└── presentation/
    ├── providers/planner_providers.dart
    ├── viewmodel/planner_viewmodel.dart
    └── views/
        ├── planner_screen.dart
        ├── create_goal_screen.dart
        └── schedule_session_screen.dart
```

1. **Notification Integration Strategy**

```dart
// In PlannerViewModel
Future<void> scheduleSession(StudySessionEntity session) async {
  // Save to database
  await _scheduleSessionUseCase.call(session);

  // Schedule local notification
  if (session.reminderOffsetMinutes != null) {
    await _notificationService.scheduleNotification(
      id: session.id.hashCode,
      title: 'Study Session Reminder',
      body: session.title,
      scheduledDate: session.startTime.subtract(
        Duration(minutes: session.reminderOffsetMinutes!),
      ),
    );
  }
}
```

## 📋 **RUBRIC ALIGNMENT STRATEGY**

### **Application Complexity (30%)**

- **✅ >3 Screens**: Landing, Auth, Home, Chatbot, Planner, Profile (6+ screens)
- **✅ >3 Features**: Authentication, AI Chatbot, Study Planner, (+ Materials/Review as stretch)
- **✅ Rich UI**: Chat interface, calendar views, forms, navigation

### **Data Persistence/API Integration (10%)**

- **✅ Cloud Persistence**: Supabase PostgreSQL with user authorization (RLS)
- **✅ Multiple APIs**: OpenAI API (intensive use), Device Notifications API
- **✅ Authorization**: Complete RLS policies for user data security

### **Application UI Design (20%)**

- **✅ User-friendly**: Clean, intuitive navigation with GoRouter
- **✅ Suitable Color Palette**: Athena brand colors (blues, professional)
- **✅ Purpose-appropriate**: Academic focus, study-friendly design

## ⚠️ **POTENTIAL CHALLENGES & SOLUTIONS**

### **Technical Risks**

1. **Streaming Implementation Complexity**

   - **Risk**: Chatbot streaming might be complex to implement
   - **Solution**: Start with simple request-response, add streaming later
   - **Fallback**: Non-streaming chatbot still meets requirements

2. **Notification Permissions**
   - **Risk**: Local notifications require platform-specific setup
   - **Solution**: Implement progressive permission requests
   - **Fallback**: In-app reminders without system notifications

### **Time Management**

1. **Feature Scope Creep**

   - **Risk**: Trying to implement too many features
   - **Solution**: Focus on chatbot + planner core functionality
   - **Strategy**: Mark advanced features as "future enhancements"

2. **Integration Complexity**
   - **Risk**: Frontend-backend integration issues
   - **Solution**: Test integration early and frequently
   - **Buffer**: Leave Day 7 for debugging and polish

## 🎯 **SUCCESS METRICS**

### **Minimum Viable Demo (by Day 7)**

- [ ] User can register, login, and manage profile
- [ ] User can have conversations with AI chatbot
- [ ] User can create study goals and schedule sessions
- [ ] User can view upcoming sessions in calendar format
- [ ] App demonstrates data persistence and external API usage

### **Ideal Demo (stretch goals)**

- [ ] Conversation history and management
- [ ] Study session notifications
- [ ] AI responses show academic assistance capabilities
- [ ] Calendar integration with scheduling features
- [ ] Proper error handling and loading states

## 📝 **NEXT IMMEDIATE ACTIONS**

### **Right Now (Today)**

1. **Review Chatbot Implementation Plan** (30 minutes)

   - Study the current ChatViewModel and data source structure
   - Identify specific connection points to the Edge Function
   - Plan the streaming response handling approach

2. **Set Up Development Environment** (30 minutes)

   - Ensure Supabase is running locally
   - Test the `chat-stream` Edge Function manually
   - Verify Flutter app can run and navigate to chatbot screen

3. **Start Backend Integration** (2-3 hours)
   - Implement the actual Supabase call in `ChatSupabaseDataSourceImpl`
   - Test the connection to the Edge Function
   - Debug any authentication or CORS issues

### **This Week's Daily Schedule**

- **Day 1 (Today)**: Chatbot backend integration
- **Day 2**: Chatbot UI improvements and conversation management
- **Day 3**: Chatbot testing and polish
- **Day 4**: Planner database schema and domain layer
- **Day 5**: Planner data layer and state management
- **Day 6**: Planner UI implementation
- **Day 7**: Integration testing, polish, and demo preparation

## 💡 **FINAL RECOMMENDATIONS**

1. **Focus Strategy**: Prioritize making chatbot and planner **functional** over **perfect**
2. **Documentation**: Take screenshots and document each completed feature for the report
3. **Testing**: Test on real devices, not just emulator
4. **Backup Plan**: Keep a working version before major changes
5. **Report Prep**: Start collecting screenshots and feature descriptions as you build

**Remember**: The goal is to demonstrate competency in Flutter development, AI integration, and mobile app architecture. Two solid, working features are better than four half-finished ones.

---

**Status**: Ready to resume development  
**Next Action**: Begin chatbot backend integration  
**Target**: Functional chatbot + planner by June 27th

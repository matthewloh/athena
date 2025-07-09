# Athena - AI-Powered Study Companion 📚🤖

## Project Overview

**Athena** is a comprehensive AI-powered study companion mobile application developed for the 6002CEM Mobile App Development Coursework 2 (CW2). This enterprise-grade application enhances student learning through personalized academic support, adaptive review systems, and intelligent study planning.

<div align="center">
  <img src="athena/assets/images/logo.png" alt="Athena Logo" width="150" height="150">
  <h2 align="center">🧠 Athena Study Companion</h2>
  <p align="center">
    <em>Your intelligent study partner, powered by cutting-edge AI technology</em>
  </p>
</div>

**Developed by:** Matthew Loh Yet Marn & Thor Wen Zheng  
**Course:** 6002CEM Mobile App Development (April 2025)  
**Institution:** Coventry University  
**Project Weight:** 75% of module grade

## 🏆 Project Achievements

### ✅ **Enterprise-Grade Implementation**

- **Production-Ready Application** with professional UI/UX
- **Complete CRUD Operations** across all major features
- **Real-time Data Synchronization** with cloud backend
- **Advanced State Management** using Riverpod
- **Comprehensive Error Handling** and loading states

### 🎯 **Core Objectives (CW2)**

- ✅ Design, develop, and test a functional mobile application using Flutter and Dart
- ✅ Demonstrate application complexity with >3 screens and >3 advanced features
- ✅ Implement robust data persistence with cloud storage and authorization
- ✅ Integrate multiple external APIs with intensive usage patterns
- ✅ Create user-friendly, intuitive UI design with professional aesthetics
- ✅ Achieve high marks aligned with CW2 marking rubric requirements

## 🚀 Key Features & Implementation Status

### **1. User Authentication & Profile Management** ✅ **COMPLETE**

- **Secure Authentication**: Email/password and Google OAuth integration
- **Profile Management**: User data, preferences, and account settings
- **Security**: Row Level Security (RLS) policies with Supabase Auth
- **Real-time Session Management**: Automatic token refresh and secure state handling

### **2. AI-Powered Chatbot** ✅ **COMPLETE**

- **Intelligent Conversations**: GPT-4o-mini integration via Vercel AI SDK
- **Streaming Responses**: Real-time AI response streaming for optimal UX
- **Conversation History**: Persistent chat sessions with search functionality
- **Enhanced Features**:
  - 📸 **Image Conversations**: Upload images for homework help
  - 🔧 **AI Tool Calling**: Wikipedia integration for factual information
  - 📎 **File Attachments**: Support for various file types
  - 🎨 **Rich Content**: Markdown rendering and syntax highlighting

### **3. Study Material Management** ✅ **COMPLETE**

- **Content Organization**: Upload, categorize, and manage study materials
- **AI Summarization**: Intelligent note summarization using LLM
- **OCR Integration**: Extract text from images using Google ML Kit
- **File Storage**: Secure cloud storage with Supabase Storage
- **Smart Search**: Search through materials and AI-generated summaries

### **4. Adaptive Review System** ✅ **COMPLETE**

- **Spaced Repetition**: SM-2 algorithm implementation for optimal learning
- **Quiz Management**: Create flashcards and multiple-choice questions
- **AI Question Generation**: Automatically generate quizzes from study materials
- **Progress Tracking**: Detailed analytics and performance metrics
- **Review Sessions**: Structured review with difficulty-based scheduling

### **5. Intelligent Study Planner** ✅ **COMPLETE**

- **Study Goals**: Create, track, and manage academic objectives
- **Session Scheduling**: Advanced calendar interface with time management
- **Progress Analytics**: Comprehensive insights and study habit tracking
- **Smart Notifications**: FCM push notifications for reminders and achievements
- **Deadline Management**: Visual progress tracking with overdue detection

### **6. Push Notification System** ✅ **COMPLETE**

- **Firebase Cloud Messaging**: Real-time notifications across platforms
- **Smart Targeting**: Intelligent notification delivery and management
- **Achievement Celebrations**: Goal completions and milestone notifications
- **Study Reminders**: Customizable session and review reminders
- **Notification History**: Complete tracking and delivery analytics

## 🛠️ Technical Architecture

### **Frontend (Flutter/Dart)**

- **Framework**: Flutter 3.7.2+ with null safety
- **State Management**: Riverpod with code generation for reactive UI
- **Architecture**: Clean Architecture with MVVM pattern
- **Navigation**: GoRouter for type-safe routing
- **Design**: Material 3 with custom Athena color scheme
- **Responsive**: Adaptive layouts for different screen sizes

### **Backend (Supabase)**

- **Database**: PostgreSQL
- **Authentication**: Supabase Auth with RLS policies
- **Storage**: Secure file storage with user-specific access
- **Edge Functions**: TypeScript functions for AI processing
- **Real-time**: Live data synchronization across devices

### **AI & External APIs**

- **Primary LLM**: OpenAI GPT-4o-mini via Vercel AI SDK
- **OCR**: Google ML Kit Text Recognition for image processing
- **Push Notifications**: Firebase Cloud Messaging

## 📊 Database Schema

### **Core Tables**

- **`profiles`**: Extended user data with FCM tokens
- **`conversations`** & **`chat_messages`**: Chat system with metadata
- **`study_materials`**: Materials with OCR and AI summaries
- **`quizzes`** & **`quiz_items`**: Review system with spaced repetition
- **`review_sessions`** & **`review_responses`**: Performance tracking
- **`study_goals`** & **`study_sessions`**: Planning and scheduling
- **`notification_history`**: Push notification tracking

### **Advanced Features**

- **Row Level Security**: User data isolation and privacy
- **Vector Storage**: pgvector for AI embeddings and semantic search
- **Real-time Subscriptions**: Live data updates
- **Database Functions**: Complex analytics and recommendations
- **Performance Optimizations**: Strategic indexing and query optimization

## 💻 Development Setup

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

4. Sometimes you need to run:

   ```bash
   flutter clean && flutter pub get && dart run build_runner clean && dart run build_runner build --delete-conflicting-outputs
   ```

## 🎨 UI/UX Design

### **Design Philosophy**

- **Material 3**: Modern Material Design with custom theming
- **Athena Brand Colors**: Professional blue palette with accessibility focus
- **Responsive Design**: Adaptive layouts for different screen sizes
- **Intuitive Navigation**: Clear information hierarchy and user flow

### **Key Features**

- **Dark/Light Theme Support**: Automatic theme switching
- **Accessibility**: High contrast ratios and screen reader support
- **Animations**: Smooth transitions and micro-interactions
- **Loading States**: Professional loading indicators and skeletons

## 🔒 Security & Privacy

### **Data Protection**

- **Row Level Security (RLS)**: Database-level access control
- **JWT Authentication**: Secure token-based authentication
- **API Key Management**: Secure storage of sensitive credentials
- **HTTPS Encryption**: All data transmitted over secure connections

### **Privacy Features**

- **User Data Isolation**: Complete separation of user data
- **Secure File Storage**: Encrypted file storage with access policies
- **Anonymous Usage**: Optional anonymous usage analytics
- **GDPR Compliance**: Data export and deletion capabilities

## 📱 Supported Platforms

- **Android**: API level 21+ (Android 5.0+)
- **iOS**: iOS 11.0+ (ready for App Store)
- **Web**: Progressive Web App support
- **Desktop**: Windows, macOS, Linux (Flutter desktop)

## 🧪 Testing & Quality Assurance

### **Testing Strategy**

- **Unit Tests**: Business logic and use case testing
- **Widget Tests**: UI component testing
- **Integration Tests**: End-to-end user flow testing
- **Performance Tests**: Memory and CPU optimization

### **Code Quality**

- **Null Safety**: Complete null safety implementation
- **Linting**: Strict linting rules and code formatting
- **Documentation**: Comprehensive code documentation
- **Type Safety**: Strong typing throughout the codebase

## 📈 Performance Optimizations

### **Frontend Optimizations**

- **Lazy Loading**: Efficient data loading strategies
- **Caching**: Smart caching for offline capabilities
- **Image Optimization**: Compressed images with CDN delivery
- **State Management**: Reactive state updates with minimal rebuilds

### **Backend Optimizations**

- **Database Indexing**: Strategic indexing for query performance
- **Connection Pooling**: Efficient database connection management
- **Edge Functions**: Serverless compute for AI processing
- **CDN**: Global content delivery for static assets

## 🔮 Future Enhancements

### **Planned Features**

- **Voice Conversations**: Speech-to-text AI interactions
- **Collaborative Study**: Real-time study group features
- **Advanced Analytics**: Machine learning insights
- **Widget Support**: Home screen widgets for quick access

### **Potential Integrations**

- **Google Calendar**: Bi-directional calendar sync
- **Notion/Obsidian**: Note-taking app integrations
- **LMS Integration**: Canvas, Moodle, Blackboard support
- **Social Features**: Study buddy matching and communities

## 🏆 Academic Excellence

This project demonstrates mastery of:

- **Modern Mobile Development**: Flutter with latest best practices
- **Cloud Architecture**: Scalable backend with Supabase
- **AI Integration**: Practical LLM implementation
- **Database Design**: Complex relational schema with optimization
- **Security**: Enterprise-grade security implementation
- **User Experience**: Professional UI/UX design
- **Software Engineering**: Clean architecture and testing

## 🌟 Project Highlights

### **Technical Achievements**

- **15+ Database Tables** with complex relationships and constraints
- **12+ Edge Functions** for AI processing and integrations
- **50+ Flutter Screens** with complete CRUD operations
- **Real-time Synchronization** across all features
- **Enterprise-grade Security** with RLS and JWT

## 📄 License & Attribution

This project is developed as part of academic coursework for 6002CEM Mobile App Development at Coventry University. All code and documentation are original work by the development team.

### **Third-party Libraries**

- **Flutter**: Google's UI toolkit
- **Supabase**: Open-source Firebase alternative
- **Riverpod**: Reactive state management
- **OpenAI**: GPT-4o-mini language model
- **Firebase**: Push notification services

---

## Team Members

- [Matthew Loh Yet Marn](https://github.com/matthewloh)
- [Thor Wen Zheng](https://github.com/Vaneryn)

## Key Links

- [GitHub Repository](https://github.com/matthewloh/athena)
- [Technical Documentation](https://github.com/matthewloh/athena/tree/main/docs)
- [Live Demo](https://helloathena.app)

---

<div align="center">
  <p><strong>🎓 Athena - Empowering Students Through AI-Powered Learning</strong></p>
  <p><em>Built with ❤️ using Flutter, Supabase, and cutting-edge AI technology</em></p>
</div>

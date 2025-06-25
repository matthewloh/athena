# Intelligent Study Planner Feature (`feature/planner`)

## 1. Overview

The Intelligent Study Planner is a core feature of the Athena application designed to help students organize their study time, set academic goals, and maintain consistent study habits. It provides intelligent scheduling recommendations, progress tracking, and seamless integration with other Athena features (study materials, adaptive review system, and AI chatbot). The feature includes deep personalization capabilities to adapt to individual learning patterns and preferences.

## 2. Key Responsibilities

- **Goal Management:**
  - Create, edit, and track long-term study goals
  - Break down complex goals into manageable tasks
  - Monitor progress with visual indicators and analytics
  - Link goals to specific subjects and study materials
  
- **Session Scheduling:**
  - Schedule study sessions with flexible time slots
  - Set up recurring study patterns
  - Integrate with device calendar and notifications
  - Automatic session reminders and follow-ups
  
- **Intelligent Recommendations:**
  - Suggest optimal study times based on personal patterns
  - Recommend review sessions for due quiz items (integration with review feature)
  - Prioritize sessions based on goal deadlines and difficulty
  - Adaptive scheduling based on completion history
  
- **Progress Tracking & Analytics:**
  - Visual progress indicators for goals and sessions
  - Study time analytics and trends
  - Performance insights and recommendations
  - Achievement tracking and milestones
  
- **Deep Personalization:**
  - Learning preference profiling (time of day, duration, subjects)
  - Personalized study recommendations
  - Adaptive difficulty and pacing
  - Integration with user profile and onboarding data

## 3. Architecture & Key Components

This feature follows Clean Architecture principles, separating concerns into domain, data, and presentation layers with deep integration capabilities.

### 3.1. Domain Layer (`lib/features/planner/domain/`)

- **Entities:**
  - `StudyGoalEntity.dart`: Represents a long-term study objective (ID, title, description, subject, target date, progress, linked materials)
  - `StudySessionEntity.dart`: Represents a scheduled study session (ID, title, goal ID, start/end time, status, duration, reminders, notes)
  - `StudyProgressEntity.dart`: Tracks progress metrics and analytics
  - `PlannerPreferencesEntity.dart`: User's personalization settings and learning preferences
  
- **Repositories:**
  - `PlannerRepository.dart` (Interface): Defines contracts for all planner-related operations:
    - CRUD operations for goals and sessions
    - Progress tracking and analytics
    - Intelligent recommendation generation
    - Integration with other features (materials, review, profile)
    - Notification scheduling and management
    
- **Use Cases:**
  - `GetStudyGoalsUseCase.dart`: Fetches all user goals with filtering and sorting
  - `CreateStudyGoalUseCase.dart`: Creates new goals with validation and linking
  - `UpdateGoalProgressUseCase.dart`: Updates goal progress and metrics
  - `GetStudySessionsUseCase.dart`: Fetches scheduled sessions with date filtering
  - `CreateStudySessionUseCase.dart`: Creates sessions with notification scheduling
  - `CompleteStudySessionUseCase.dart`: Marks sessions complete and updates analytics
  - `GetIntelligentRecommendationsUseCase.dart`: Generates personalized study suggestions
  - `UpdatePlannerPreferencesUseCase.dart`: Manages user personalization settings
  - `GetStudyAnalyticsUseCase.dart`: Provides progress insights and trends

### 3.2. Data Layer (`lib/features/planner/data/`)

- **Models:**
  - `StudyGoalModel.dart`: DTO for study goals with `fromJson`/`toJson` for Supabase
  - `StudySessionModel.dart`: DTO for study sessions with `fromJson`/`toJson` for Supabase
  - `StudyProgressModel.dart`: DTO for progress tracking data
  - `PlannerPreferencesModel.dart`: DTO for user preferences and personalization data
  
- **Data Sources:**
  - `PlannerRemoteDataSource.dart` (Interface): Defines methods for backend interactions
  - `PlannerSupabaseDataSourceImpl.dart`: Concrete implementation using Supabase:
    - CRUD operations on `study_goals` and `study_sessions` tables
    - Progress analytics and metrics calculations
    - Integration queries with study materials and quiz items
    - User preference management
  - `PlannerLocalDataSource.dart` (Interface): Local storage for offline capabilities
  - `PlannerHiveDataSourceImpl.dart`: Local storage implementation using Hive
  
- **Repositories:**
  - `PlannerRepositoryImpl.dart`: Implements `PlannerRepository`, coordinates remote/local data sources

### 3.3. Presentation Layer (`lib/features/planner/presentation/`)

- **ViewModels / Providers:**
  - `PlannerViewModel.dart` (extends `AsyncNotifier`): Main state management for planner UI
    - Manages goals, sessions, and progress state
    - Handles intelligent recommendations
    - Coordinates with notification system
    - Provides methods: `loadGoals`, `createGoal`, `scheduleSession`, `updateProgress`
  - `PlannerAnalyticsViewModel.dart`: Specialized for analytics and insights
  - `PlannerPreferencesViewModel.dart`: Manages user personalization settings
  - `planner_providers.dart`: Riverpod providers for ViewModels, use cases, and repositories
  - `PlannerState.dart`: State management classes for different UI states
  
- **Views (Screens):**
  - `planner_screen.dart`: ✅ **IMPLEMENTED** - Main planner interface with Schedule/Goals tabs
  - `goal_detail_screen.dart`: Detailed view for individual goals
  - `session_detail_screen.dart`: Detailed view for study sessions
  - `planner_analytics_screen.dart`: Progress insights and analytics dashboard
  - `planner_preferences_screen.dart`: Personalization and settings
  - `create_goal_screen.dart`: Goal creation with intelligent suggestions
  - `create_session_screen.dart`: Session scheduling with calendar integration
  
- **Widgets:**
  - `goal_card.dart`: Display component for study goals
  - `session_card.dart`: Display component for study sessions
  - `progress_indicator_widget.dart`: Custom progress visualization
  - `calendar_widget.dart`: Custom calendar with session highlights
  - `recommendation_card.dart`: Intelligent suggestion display
  - `analytics_chart_widget.dart`: Charts for progress visualization
  - `session_timer_widget.dart`: Session tracking and timing

### 3.4. Backend Integration (Supabase)

- **Database Tables:**
  - `study_goals`: Goal metadata and progress tracking
  - `study_sessions`: Scheduled sessions with timing and status
  - `study_progress`: Analytics and metrics data
  - `planner_preferences`: User personalization settings
  
- **Edge Functions:**
  - `intelligent-recommendations`: Generates personalized study suggestions
  - `progress-analytics`: Calculates insights and trends
  - `notification-scheduler`: Manages reminder scheduling

## 4. Current Implementation Status

### ✅ **Completed Components:**
- **Basic UI Scaffolding**: Complete planner screen with Schedule/Goals tabs
- **Visual Components**: Progress indicators, goal cards, session timeline
- **Navigation**: Tab-based navigation and date selection
- **Dummy Data**: Comprehensive mock data for UI testing

### 🚧 **In Progress:**
- **Architecture Setup**: Need to implement domain/data layers
- **State Management**: Riverpod providers and ViewModels
- **Database Schema**: Supabase table creation and relationships

### 📋 **Planned Features:**
- **Intelligent Recommendations**: AI-powered study suggestions
- **Deep Personalization**: Learning preference profiling
- **Analytics Dashboard**: Progress insights and trends
- **Notification System**: Smart reminders and alerts
- **Cross-feature Integration**: Links with materials, review, and chatbot

## 5. Deep Personalization Features

### 5.1. Learning Profile System
- **Study Pattern Analysis**: Optimal study times, duration preferences, break patterns
- **Subject Affinity Tracking**: Performance and engagement per subject
- **Goal Achievement Patterns**: Success rates and completion strategies
- **Difficulty Preference**: Preferred challenge levels and progression speed

### 5.2. Onboarding Integration
- **Initial Preference Survey**: Learning style, schedule constraints, goal types
- **Subject Priority Setting**: Main focus areas and academic objectives
- **Notification Preferences**: Reminder frequency and timing
- **Calendar Integration**: Existing commitments and available time slots

### 5.3. Adaptive Recommendations
- **Time-based Suggestions**: Optimal scheduling based on personal patterns
- **Content-based Recommendations**: Study materials and review sessions
- **Goal Decomposition**: Intelligent breaking down of complex objectives
- **Progress-driven Adjustments**: Adaptive pacing based on achievement rates

## 6. Integration Points

### 6.1. Study Materials Integration
- Link sessions to specific study materials
- Recommend study sessions for new materials
- Track material-specific progress

### 6.2. Review System Integration
- Automatic review session scheduling for due quiz items
- Progress synchronization between planner and review analytics
- Adaptive spacing based on review performance

### 6.3. AI Chatbot Integration
- Study planning conversations and goal setting
- Progress discussions and motivation
- Resource recommendations through chat

### 6.4. User Profile Integration
- Personalization data synchronization
- Achievement tracking and gamification
- Social features and study group coordination

## 7. Technical Implementation Priorities

### Phase 1: Core Architecture (Current Priority)
1. ✅ UI scaffolding (completed)
2. 🚧 Domain layer implementation
3. 🚧 Basic CRUD operations
4. 🚧 Supabase schema setup

### Phase 2: Essential Features
1. Goal and session management
2. Progress tracking
3. Basic notifications
4. Calendar integration

### Phase 3: Intelligence & Personalization
1. Recommendation engine
2. Learning pattern analysis
3. Adaptive scheduling
4. Advanced analytics

### Phase 4: Deep Integration
1. Cross-feature synchronization
2. Advanced personalization
3. Social features
4. Gamification elements

## 8. Development Considerations

### 8.1. Scope Management
- **MVP Focus**: Core scheduling and goal tracking
- **Personalization Gradual**: Start with basic preferences, expand iteratively
- **Integration Planning**: Design for future feature connections
- **Performance Optimization**: Efficient data loading and caching

### 8.2. User Experience Priorities
- **Intuitive Interface**: Easy goal/session creation
- **Visual Feedback**: Clear progress indicators
- **Seamless Flow**: Smooth navigation between features
- **Responsive Design**: Works across different screen sizes

### 8.3. Technical Challenges
- **Notification Management**: Cross-platform local notifications
- **Calendar Integration**: Device calendar synchronization
- **Offline Support**: Local data persistence and synchronization
- **Performance**: Efficient querying and data loading

## 9. Next Steps & Development Roadmap

### Immediate Actions (Sprint 1):
1. **Create Domain Layer**: Implement entities, repositories, and use cases
2. **Setup Database Schema**: Create Supabase tables with proper relationships
3. **Implement Basic State Management**: Riverpod providers and ViewModels
4. **Replace Dummy Data**: Connect UI to real data sources

### Short-term Goals (Sprint 2-3):
1. **CRUD Operations**: Complete goal and session management
2. **Notification System**: Implement flutter_local_notifications
3. **Progress Tracking**: Basic analytics and progress visualization
4. **Form Implementation**: Goal and session creation screens

### Medium-term Goals (Sprint 4-6):
1. **Intelligent Recommendations**: Basic suggestion algorithms
2. **Cross-feature Integration**: Connect with study materials and review
3. **Advanced UI**: Analytics dashboard and preference settings
4. **Performance Optimization**: Caching and efficient data loading

### Long-term Vision (Future Iterations):
1. **Advanced Personalization**: Machine learning-based recommendations
2. **Social Features**: Study groups and collaboration
3. **Gamification**: Achievement system and progress incentives
4. **Mobile-specific Features**: Widget support and background sync

This roadmap provides a structured approach to implementing the intelligent study planner while maintaining focus on delivering core value quickly and building personalization capabilities incrementally. 
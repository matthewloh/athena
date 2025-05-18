# Home Feature Implementation

This directory contains a scaffolded implementation of the Athena app's home feature with dummy data.

## Implementation Status

### Current Progress

- Basic HomeScreen UI has been implemented in `athena/lib/screens/home_screen.dart` (outside of the feature directory structure)
- The HomeScreen includes:
  - Feature navigation grid with cards for AI Chatbot, Study Materials, Adaptive Review, and Study Planner
  - Quick actions section for common tasks
  - Navigation to all main feature screens
  - Clean, modern UI with Athena color scheme

### Next Steps

- Move the HomeScreen implementation into this feature directory structure
- Implement actual data fetching from Supabase
- Connect with other features to display real statistics and information
- Add refresh functionality and proper state management

## Directory Structure

```txt
lib/features/home/
├── data/
│   ├── datasources/
│   └── repositories/
│       └── dashboard_repository_impl.dart  - Dummy repository implementation
├── domain/
│   ├── entities/
│   │   └── dashboard_data.dart            - Entities for dashboard data
│   ├── repositories/
│   │   └── dashboard_repository.dart      - Repository interface
│   └── usecases/
│       └── get_dashboard_data_usecase.dart - Use case for fetching dashboard data
├── presentation/
│   ├── providers/
│   │   └── home_providers.dart            - Riverpod providers
│   │   └── home_providers.g.dart          - Generated code (via build_runner)
│   └── views/
│       └── home_helpers.dart              - Helper functions for the UI
│       └── home_screen.dart               - Main home screen UI (TO BE IMPLEMENTED)
└── README.md                              - This file
```

## Implementation Notes

### Current Status

The home feature has been scaffolded with:

1. Domain layer with entities and repository interfaces
2. Data layer with a dummy repository implementation
3. Presentation layer with Riverpod providers and UI helpers

### Next Steps for Complete Implementation

To complete the implementation:

1. **Update the HomeScreen UI**:

   - Modify `home_screen.dart` to use the async providers
   - For the stats cards (study materials and quiz items), update:

     ```dart
     // Replace this
     _buildStatCard(
       context,
       icon: Icons.article_rounded,
       title: 'Study Materials',
       value: '3',
       color: AppColors.athenaPurple,
     )

     // With this
     materialCountAsync.when(
       data: (count) => _buildStatCard(
         context,
         icon: Icons.article_rounded,
         title: 'Study Materials',
         value: count.toString(),
         color: AppColors.athenaPurple,
       ),
       loading: () => buildLoadingStatCard(context, 'Study Materials'),
       error: (_, __) => buildErrorStatCard(context, 'Study Materials'),
     )
     ```

   - For the Upcoming Sessions and Review Items sections, update:

     ```dart
     // Replace the hardcoded upcoming sessions with
     upcomingSessionsAsync.when(
       data: (sessions) => buildUpcomingSessionsCard(context, sessions),
       loading: () => buildLoadingCard(height: 200),
       error: (error, stackTrace) => buildErrorCard('Could not load upcoming sessions'),
     )

     // And replace the hardcoded review items with
     reviewItemsAsync.when(
       data: (items) => buildReviewItemsCard(context, items),
       loading: () => buildLoadingCard(height: 180),
       error: (error, stackTrace) => buildErrorCard('Could not load review items'),
     )
     ```

2. **Add RefreshIndicator**:

   - Wrap the SingleChildScrollView with a RefreshIndicator:

     ```dart
     RefreshIndicator(
       onRefresh: () async {
         // Refresh all providers
         ref.invalidate(dashboardDataProvider);
         ref.invalidate(materialCountProvider);
         ref.invalidate(quizItemCountProvider);
         ref.invalidate(upcomingSessionsProvider);
         ref.invalidate(reviewItemsProvider);
       },
       child: SingleChildScrollView(
         physics: const AlwaysScrollableScrollPhysics(),
         // existing content...
       ),
     )
     ```

3. **Implement Real Data Sources**:

   - Create actual Supabase datasources in the `data/datasources` directory:

     ```dart
     // Example for dashboard_datasource.dart
     abstract class DashboardDataSource {
       Future<Map<String, dynamic>> getDashboardData(String userId);
       Future<int> getStudyMaterialCount(String userId);
       Future<int> getQuizItemCount(String userId);
       Future<List<Map<String, dynamic>>> getUpcomingSessions(String userId);
       Future<List<Map<String, dynamic>>> getReviewItems(String userId);
     }

     class SupabaseDashboardDataSource implements DashboardDataSource {
       final SupabaseClient _client;

       SupabaseDashboardDataSource(this._client);

       @override
       Future<Map<String, dynamic>> getDashboardData(String userId) async {
         // Implementation using Supabase queries
       }

       // Implement other methods...
     }
     ```

   - Update the repository implementation to use real data:

     ```dart
     class DashboardRepositoryImpl implements DashboardRepository {
       final DashboardDataSource _dataSource;

       DashboardRepositoryImpl(this._dataSource);

       @override
       Future<DashboardData> getDashboardData() async {
         final userId = supabase.auth.currentUser?.id;
         if (userId == null) {
           throw const AuthException('User not authenticated');
         }

         final data = await _dataSource.getDashboardData(userId);
         return DashboardData.fromJson(data);
       }

       // Implement other methods...
     }
     ```

4. **Add Error Handling and Retry Logic**:
   - Implement proper error handling in the data sources
   - Add retry functionality for failed network requests
   - Display user-friendly error messages in the UI

## Testing

To ensure the Home feature works correctly:

1. **Unit Tests**:

   - Test the repository and use case implementations
   - Mock the data sources for controlled testing environments

   ```bash
   # Run tests for the home feature
   flutter test test/features/home/
   ```

2. **Widget Tests**:

   - Test the UI components with mocked providers
   - Verify loading, success, and error states are displayed correctly

3. **Integration Tests**:
   - Test the complete feature flow from API calls to UI rendering
   - Verify refresh functionality works as expected

## Dummy Data

The scaffold currently uses dummy data through the `DashboardData.dummy()` factory method. This can be used during development until real data sources are implemented.

## Riverpod Providers

The providers have been set up using the riverpod_annotation package. After changing providers, run:

```bash
dart run build_runner build --delete-conflicting-outputs
```

to regenerate the provider code.

## UI Helpers

The `home_helpers.dart` file contains helper functions for displaying loading states, error states, and for building complex card widgets. These can be used from the HomeScreen to make the code more organized and readable.

## Performance Considerations

For better performance:

1. Implement caching of dashboard data for faster loading
2. Use pagination for lists that might grow large (review items, study sessions)
3. Consider adding offline support using Hive or sqflite

## Design System Integration

Ensure all UI components follow the Athena design system:

1. Use colors from `AppColors` in the core theme directory
2. Follow typography guidelines from the app's theme
3. Maintain consistent spacing and component sizing

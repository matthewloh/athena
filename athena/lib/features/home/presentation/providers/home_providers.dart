import 'package:athena/core/providers/auth_provider.dart';
import 'package:athena/core/providers/supabase_providers.dart';
import 'package:athena/features/home/data/repositories/dashboard_repository_impl.dart';
import 'package:athena/features/home/domain/entities/dashboard_data.dart';
import 'package:athena/features/home/domain/repositories/dashboard_repository.dart';
import 'package:athena/features/home/domain/usecases/get_dashboard_data_usecase.dart';
import 'package:athena/features/planner/presentation/providers/planner_providers.dart';
import 'package:athena/features/study_materials/presentation/providers/study_material_providers.dart';
import 'package:athena/features/review/presentation/providers/review_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_providers.g.dart';

/// Provider for the dashboard repository
@riverpod
DashboardRepository dashboardRepository(Ref ref) {
  return DashboardRepositoryImpl();
}

/// Provider for the get dashboard data use case
@riverpod
GetDashboardDataUseCase getDashboardDataUseCase(Ref ref) {
  final repository = ref.watch(dashboardRepositoryProvider);
  return GetDashboardDataUseCase(repository);
}

/// Provider for dashboard data
@riverpod
Future<DashboardData> dashboardData(Ref ref) async {
  final useCase = ref.watch(getDashboardDataUseCaseProvider);
  return await useCase.execute();
}

/// Provider for dashboard loading state
@riverpod
bool isDashboardLoading(Ref ref) {
  final dashboardDataValue = ref.watch(dashboardDataProvider);
  return dashboardDataValue.isLoading;
}

/// Provider for dashboard material count (using real study materials data)
@riverpod
Future<int> materialCount(Ref ref) async {
  final authState = ref.watch(appAuthProvider);
  final userId = authState.value?.id;

  if (userId == null) return 0;

  final getAllStudyMaterialsUseCase = ref.watch(
    getAllStudyMaterialsUseCaseProvider,
  );
  final result = await getAllStudyMaterialsUseCase(userId);

  return result.fold(
    (failure) => 0, // Return 0 on failure
    (materials) => materials.length,
  );
}

/// Provider for dashboard quiz count (using real quiz data)
@riverpod
Future<int> quizItemCount(Ref ref) async {
  final authState = ref.watch(appAuthProvider);
  final userId = authState.value?.id;

  if (userId == null) return 0;

  final getAllQuizzesUseCase = ref.watch(getAllQuizzesUseCaseProvider);
  final result = await getAllQuizzesUseCase(userId);

  return result.fold(
    (failure) => 0, // Return 0 on failure
    (quizzes) => quizzes.length,
  );
}

/// Provider for upcoming sessions (using real planner data)
@riverpod
Future<List<UpcomingSession>> upcomingSessions(Ref ref) async {
  final authState = ref.watch(appAuthProvider);
  final userId = authState.value?.id;

  if (userId == null) return [];

  try {
    // Get upcoming study sessions from planner
    final getUpcomingSessionsUseCase = ref.watch(
      getUpcomingSessionsUseCaseProvider,
    );
    final result = await getUpcomingSessionsUseCase(userId);

    return result.fold(
      (failure) => [], // Return empty list on failure
      (studySessions) {
        // Convert StudySessionEntity to UpcomingSession for home display
        return studySessions.map((session) {
          // Format time for display
          final startTime = session.startTime;
          final endTime = session.endTime;
          final timeString =
              '${_formatTime(startTime)} - ${_formatTime(endTime)}';

          // Map subject to icon type
          final iconType = _mapSubjectToIconType(session.subject);

          return UpcomingSession(
            title: session.title,
            time: timeString,
            iconType: iconType,
          );
        }).toList();
      },
    );
  } catch (e) {
    // Log error and return empty list
    return [];
  }
}

/// Helper function to format time for display
String _formatTime(DateTime time) {
  final hour = time.hour;
  final minute = time.minute.toString().padLeft(2, '0');
  final period = hour >= 12 ? 'PM' : 'AM';
  final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
  return '$displayHour:$minute $period';
}

/// Helper function to map subject string to SessionIconType
SessionIconType _mapSubjectToIconType(String? subject) {
  if (subject == null) return SessionIconType.generic;

  final lowerSubject = subject.toLowerCase();

  if (lowerSubject.contains('math') ||
      lowerSubject.contains('calculus') ||
      lowerSubject.contains('algebra')) {
    return SessionIconType.math;
  } else if (lowerSubject.contains('science') ||
      lowerSubject.contains('biology') ||
      lowerSubject.contains('chemistry') ||
      lowerSubject.contains('physics')) {
    return SessionIconType.science;
  } else if (lowerSubject.contains('literature') ||
      lowerSubject.contains('english') ||
      lowerSubject.contains('writing') ||
      lowerSubject.contains('reading')) {
    return SessionIconType.literature;
  } else if (lowerSubject.contains('history') ||
      lowerSubject.contains('social')) {
    return SessionIconType.history;
  } else if (lowerSubject.contains('language') ||
      lowerSubject.contains('spanish') ||
      lowerSubject.contains('french') ||
      lowerSubject.contains('german')) {
    return SessionIconType.language;
  } else {
    return SessionIconType.generic;
  }
}

/// Provider for review items due (using real review data)
@riverpod
Future<List<ReviewItem>> reviewItems(Ref ref) async {
  final authState = ref.watch(appAuthProvider);
  final userId = authState.value?.id;

  if (userId == null) return [];

  // Get all quizzes to find due items across all quizzes
  final getAllQuizzesUseCase = ref.watch(getAllQuizzesUseCaseProvider);
  final quizzesResult = await getAllQuizzesUseCase(userId);

  return await quizzesResult.fold(
    (failure) async => [], // Return empty list on failure
    (quizzes) async {
      final List<ReviewItem> allReviewItems = [];

      // For each quiz, get due items
      final getDueItemsUseCase = ref.watch(getDueItemsUseCaseProvider);

      for (final quiz in quizzes) {
        final dueItemsResult = await getDueItemsUseCase(
          quiz.id,
          userId,
          includeNew: true,
          limit: null,
        );

        dueItemsResult.fold(
          (failure) {}, // Ignore failures for individual quizzes
          (dueItems) {
            if (dueItems.isNotEmpty) {
              // Create a review item representing this quiz's due items
              allReviewItems.add(
                ReviewItem(
                  title: quiz.title,
                  count: dueItems.length,
                  subject: quiz.subject,
                ),
              );
            }
          },
        );
      }

      return allReviewItems;
    },
  );
}

/// Provider for calling the hello-name edge function
@riverpod
Future<Map<String, dynamic>> helloEdgeFunction(Ref ref, String userName) async {
  final supabase = ref.read(supabaseClientProvider);
  final response = await supabase.functions.invoke(
    'hello-name',
    body: {'name': userName},
  );

  return response.data as Map<String, dynamic>;
}

/// Provider to track the input name for the edge function
@riverpod
class EdgeFunctionName extends _$EdgeFunctionName {
  @override
  String build() {
    return 'Scholar';
  }

  void updateName(String name) {
    state = name;
  }
}

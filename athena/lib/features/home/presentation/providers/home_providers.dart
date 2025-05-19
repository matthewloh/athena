import 'package:athena/core/providers/supabase_providers.dart';
import 'package:athena/features/home/data/repositories/dashboard_repository_impl.dart';
import 'package:athena/features/home/domain/entities/dashboard_data.dart';
import 'package:athena/features/home/domain/repositories/dashboard_repository.dart';
import 'package:athena/features/home/domain/usecases/get_dashboard_data_usecase.dart';
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

/// Provider for dashboard material count
@riverpod
Future<int> materialCount(Ref ref) async {
  final repository = ref.watch(dashboardRepositoryProvider);
  return await repository.getMaterialCount();
}

/// Provider for dashboard quiz items count
@riverpod
Future<int> quizItemCount(Ref ref) async {
  final repository = ref.watch(dashboardRepositoryProvider);
  return await repository.getQuizItemCount();
}

/// Provider for upcoming sessions
@riverpod
Future<List<UpcomingSession>> upcomingSessions(Ref ref) async {
  final repository = ref.watch(dashboardRepositoryProvider);
  return await repository.getUpcomingSessions();
}

/// Provider for review items
@riverpod
Future<List<ReviewItem>> reviewItems(Ref ref) async {
  final repository = ref.watch(dashboardRepositoryProvider);
  return await repository.getReviewItems();
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

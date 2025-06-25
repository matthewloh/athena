import 'package:athena/core/providers/supabase_providers.dart';
import 'package:athena/features/planner/data/datasources/planner_supabase_datasource_impl.dart';
import 'package:athena/features/planner/data/repositories/planner_repository_impl.dart';
import 'package:athena/features/planner/domain/repositories/planner_repository.dart';
import 'package:athena/features/planner/domain/usecases/get_study_goals_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'planner_providers.g.dart';

// ============================================================================
// DATA LAYER PROVIDERS
// ============================================================================

/// Provides the Supabase data source implementation
@riverpod
PlannerSupabaseDataSourceImpl plannerDataSource(Ref ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return PlannerSupabaseDataSourceImpl(supabaseClient);
}

/// Provides the planner repository implementation
@riverpod
PlannerRepository plannerRepository(Ref ref) {
  final dataSource = ref.watch(plannerDataSourceProvider);
  return PlannerRepositoryImpl(dataSource);
}

// ============================================================================
// USE CASE PROVIDERS
// ============================================================================

/// Provides the get study goals use case
@riverpod
GetStudyGoalsUseCase getStudyGoalsUseCase(Ref ref) {
  final repository = ref.watch(plannerRepositoryProvider);
  return GetStudyGoalsUseCase(repository);
}

// ============================================================================
// CURRENT USER PROVIDER
// ============================================================================

/// Provides the current authenticated user ID
@riverpod
String? currentUserId(Ref ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return supabaseClient.auth.currentUser?.id;
}

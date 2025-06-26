import 'package:athena/core/providers/supabase_providers.dart';
import 'package:athena/features/review/data/datasources/review_supabase_datasource.dart';
import 'package:athena/features/review/data/repositories/review_repository_impl.dart';
import 'package:athena/features/review/domain/repositories/review_repository.dart';
import 'package:athena/features/review/domain/usecases/create_quiz_usecase.dart';
import 'package:athena/features/review/domain/usecases/create_quiz_item_usecase.dart';
import 'package:athena/features/review/domain/usecases/delete_quiz_usecase.dart';
import 'package:athena/features/review/domain/usecases/delete_quiz_item_usecase.dart';
import 'package:athena/features/review/domain/usecases/generate_ai_quiz_usecase.dart';
import 'package:athena/features/review/domain/usecases/get_all_quiz_items_usecase.dart';
import 'package:athena/features/review/domain/usecases/get_all_quizzes_usecase.dart';
import 'package:athena/features/review/domain/usecases/get_quiz_detail_usecase.dart';
import 'package:athena/features/review/domain/usecases/update_quiz_usecase.dart';
import 'package:athena/features/review/domain/usecases/update_quiz_item_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'review_providers.g.dart';

// DataSources
@riverpod
ReviewSupabaseDataSourceImpl reviewSupabaseDataSource(Ref ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return ReviewSupabaseDataSourceImpl(supabaseClient);
}

// Repositories
@riverpod
ReviewRepository reviewRepository(Ref ref) {
  final dataSource = ref.watch(reviewSupabaseDataSourceProvider);
  return ReviewRepositoryImpl(dataSource);
}

// UseCases
// Quiz UseCases
@riverpod
GetAllQuizzesUseCase getAllQuizzesUseCase(Ref ref) {
  final repository = ref.watch(reviewRepositoryProvider);
  return GetAllQuizzesUseCase(repository);
}

@riverpod
GetQuizDetailUseCase getQuizDetailUseCase(Ref ref) {
  final repository = ref.watch(reviewRepositoryProvider);
  return GetQuizDetailUseCase(repository);
}

@riverpod
CreateQuizUseCase createQuizUseCase(Ref ref) {
  final repository = ref.watch(reviewRepositoryProvider);
  return CreateQuizUseCase(repository);
}

@riverpod
UpdateQuizUseCase updateQuizUseCase(Ref ref) {
  final repository = ref.watch(reviewRepositoryProvider);
  return UpdateQuizUseCase(repository);
}

@riverpod
DeleteQuizUseCase deleteQuizUseCase(Ref ref) {
  final repository = ref.watch(reviewRepositoryProvider);
  return DeleteQuizUseCase(repository);
}

@riverpod
GenerateAiQuizUseCase generateAiQuizUseCase(Ref ref) {
  final repository = ref.watch(reviewRepositoryProvider);
  return GenerateAiQuizUseCase(repository);
}

// QuizItem UseCases
@riverpod
GetAllQuizItemsUseCase getAllQuizItemsUseCase(Ref ref) {
  final repository = ref.watch(reviewRepositoryProvider);
  return GetAllQuizItemsUseCase(repository);
}

@riverpod
CreateQuizItemUseCase createQuizItemUseCase(Ref ref) {
  final repository = ref.watch(reviewRepositoryProvider);
  return CreateQuizItemUseCase(repository);
}

@riverpod
UpdateQuizItemUseCase updateQuizItemUseCase(Ref ref) {
  final repository = ref.watch(reviewRepositoryProvider);
  return UpdateQuizItemUseCase(repository);
}

@riverpod
DeleteQuizItemUseCase deleteQuizItemUseCase(Ref ref) {
  final repository = ref.watch(reviewRepositoryProvider);
  return DeleteQuizItemUseCase(repository);
}

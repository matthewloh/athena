import 'package:athena/features/review/domain/entities/review_session_entity.dart';
import 'package:athena/features/review/presentation/viewmodel/quiz_results_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'quiz_results_viewmodel.g.dart';

/// ViewModel for managing quiz results screen state.
///
/// Handles displaying the results of a completed review session.
@riverpod
class QuizResultsViewModel extends _$QuizResultsViewModel {
  @override
  QuizResultsState build() {
    return const QuizResultsState();
  }

  /// Initializes the quiz results with session data
  void initializeResults(ReviewSessionEntity session) {
    state = state.copyWith(session: session, isLoading: false, error: null);
  }

  /// Sets loading state
  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  /// Sets error state
  void setError(String? error) {
    state = state.copyWith(error: error);
  }

  /// Clears error state
  void clearError() {
    state = state.copyWith(error: null);
  }
}

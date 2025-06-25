import 'package:athena/core/errors/failures.dart';
import 'package:athena/features/planner/domain/entities/study_session_entity.dart';
import 'package:athena/features/planner/presentation/providers/planner_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'study_sessions_viewmodel.g.dart';

/// State for the study sessions feature
class StudySessionsState {
  final List<StudySessionEntity> sessions;
  final bool isLoading;
  final String? errorMessage;

  const StudySessionsState({
    this.sessions = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  StudySessionsState copyWith({
    List<StudySessionEntity>? sessions,
    bool? isLoading,
    String? errorMessage,
  }) {
    return StudySessionsState(
      sessions: sessions ?? this.sessions,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// Get sessions for a specific date
  List<StudySessionEntity> getSessionsForDate(DateTime date) {
    return sessions.where((session) {
      final sessionDate = DateTime(
        session.startTime.year,
        session.startTime.month,
        session.startTime.day,
      );
      final targetDate = DateTime(date.year, date.month, date.day);
      return sessionDate == targetDate;
    }).toList();
  }

  /// Get upcoming sessions (within next 7 days)
  List<StudySessionEntity> get upcomingSessions {
    final now = DateTime.now();
    final weekFromNow = now.add(const Duration(days: 7));

    return sessions.where((session) {
        return session.startTime.isAfter(now) &&
            session.startTime.isBefore(weekFromNow) &&
            session.status != StudySessionStatus.completed &&
            session.status != StudySessionStatus.cancelled;
      }).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  /// Get today's sessions
  List<StudySessionEntity> get todaySessions {
    return getSessionsForDate(DateTime.now());
  }

  /// Get overdue sessions
  List<StudySessionEntity> get overdueSessions {
    final now = DateTime.now();
    return sessions.where((session) {
      return session.endTime.isBefore(now) &&
          session.status == StudySessionStatus.scheduled;
    }).toList();
  }
}

/// ViewModel for managing study sessions
@riverpod
class StudySessionsViewModel extends _$StudySessionsViewModel {
  @override
  StudySessionsState build() {
    // Auto-load sessions when ViewModel is created
    final userId = ref.watch(currentUserIdProvider);

    print('StudySessionsViewModel build() - User ID: $userId');

    if (userId != null) {
      print('StudySessionsViewModel - Loading sessions for user: $userId');
      Future.microtask(() => loadSessions());
    } else {
      print(
        'StudySessionsViewModel - No user ID available, not loading sessions',
      );
    }

    return const StudySessionsState();
  }

  /// Load all study sessions for the current user
  Future<void> loadSessions() async {
    final userId = ref.read(currentUserIdProvider);
    print('loadSessions called - User ID: $userId');

    if (userId == null) {
      final errorMsg = 'User not authenticated';
      print('loadSessions error: $errorMsg');
      state = state.copyWith(errorMessage: errorMsg, isLoading: false);
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);
    print('loadSessions - Set loading state');

    try {
      final repository = ref.read(plannerRepositoryProvider);
      print(
        'loadSessions - Calling repository.getStudySessions with userId: $userId',
      );
      final result = await repository.getStudySessions(userId);

      result.fold(
        (failure) {
          final errorMsg =
              'Failed to load sessions: ${_mapFailureToMessage(failure)}';
          print('loadSessions failure: $errorMsg');
          state = state.copyWith(isLoading: false, errorMessage: errorMsg);
        },
        (sessions) {
          print('loadSessions success - Loaded ${sessions.length} sessions');
          for (var session in sessions) {
            print(
              '  Session: ${session.title} (ID: ${session.id}) on ${session.startTime}',
            );
          }
          state = state.copyWith(
            sessions: sessions,
            isLoading: false,
            errorMessage: null,
          );
        },
      );
    } catch (e) {
      final errorMsg = 'An unexpected error occurred: $e';
      print('loadSessions exception: $errorMsg');
      state = state.copyWith(isLoading: false, errorMessage: errorMsg);
    }
  }

  /// Create a new study session
  Future<bool> createSession({
    required String title,
    required DateTime startTime,
    required DateTime endTime,
    String? notes,
    String? subject,
  }) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return false;

    try {
      final repository = ref.read(plannerRepositoryProvider);
      final session = StudySessionEntity(
        id: '', // Will be set by the database
        userId: userId,
        title: title,
        notes: notes,
        subject: subject,
        startTime: startTime,
        endTime: endTime,
        status: StudySessionStatus.scheduled,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final result = await repository.createStudySession(session);

      return result.fold(
        (failure) {
          state = state.copyWith(errorMessage: _mapFailureToMessage(failure));
          return false;
        },
        (createdSession) {
          state = state.copyWith(
            sessions: [...state.sessions, createdSession],
            errorMessage: null,
          );
          return true;
        },
      );
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to create session');
      return false;
    }
  }

  /// Update an existing study session
  Future<bool> updateSession(StudySessionEntity session) async {
    try {
      final repository = ref.read(plannerRepositoryProvider);
      final result = await repository.updateStudySession(session);

      return result.fold(
        (failure) {
          state = state.copyWith(errorMessage: _mapFailureToMessage(failure));
          return false;
        },
        (updatedSession) {
          final updatedSessions =
              state.sessions.map((s) {
                return s.id == updatedSession.id ? updatedSession : s;
              }).toList();

          state = state.copyWith(sessions: updatedSessions, errorMessage: null);
          return true;
        },
      );
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to update session');
      return false;
    }
  }

  /// Delete a study session
  Future<bool> deleteSession(String sessionId) async {
    try {
      final repository = ref.read(plannerRepositoryProvider);
      final result = await repository.deleteStudySession(sessionId);

      return result.fold(
        (failure) {
          state = state.copyWith(errorMessage: _mapFailureToMessage(failure));
          return false;
        },
        (_) {
          final updatedSessions =
              state.sessions
                  .where((session) => session.id != sessionId)
                  .toList();

          state = state.copyWith(sessions: updatedSessions, errorMessage: null);
          return true;
        },
      );
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to delete session');
      return false;
    }
  }

  /// Mark a session as completed
  Future<bool> completeSession(String sessionId) async {
    final session = state.sessions.firstWhere(
      (s) => s.id == sessionId,
      orElse: () => throw Exception('Session not found'),
    );

    final completedSession = session.copyWith(
      status: StudySessionStatus.completed,
      updatedAt: DateTime.now(),
    );

    return await updateSession(completedSession);
  }

  /// Cancel a session
  Future<bool> cancelSession(String sessionId) async {
    final session = state.sessions.firstWhere(
      (s) => s.id == sessionId,
      orElse: () => throw Exception('Session not found'),
    );

    final cancelledSession = session.copyWith(
      status: StudySessionStatus.cancelled,
      updatedAt: DateTime.now(),
    );

    return await updateSession(cancelledSession);
  }

  /// Clear any error messages
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure) {
      case ServerFailure _:
        return 'Server error occurred. Please try again.';
      case NetworkFailure _:
        return 'Network error. Check your connection.';
      case CacheFailure _:
        return 'Local storage error occurred.';
      default:
        return 'An unexpected error occurred.';
    }
  }
}

/// Provider for sessions on a specific date
@riverpod
List<StudySessionEntity> sessionsByDate(Ref ref, DateTime date) {
  return ref.watch(studySessionsViewModelProvider).getSessionsForDate(date);
}

/// Provider for upcoming sessions
@riverpod
List<StudySessionEntity> upcomingSessions(Ref ref) {
  return ref.watch(studySessionsViewModelProvider).upcomingSessions;
}

/// Provider for today's sessions
@riverpod
List<StudySessionEntity> todaySessions(Ref ref) {
  return ref.watch(studySessionsViewModelProvider).todaySessions;
}

/// Provider for overdue sessions
@riverpod
List<StudySessionEntity> overdueSessions(Ref ref) {
  return ref.watch(studySessionsViewModelProvider).overdueSessions;
}

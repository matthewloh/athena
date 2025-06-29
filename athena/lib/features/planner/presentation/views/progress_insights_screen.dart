import 'package:athena/core/theme/app_colors.dart';
import 'package:athena/features/planner/domain/entities/study_session_entity.dart';
import 'package:athena/features/planner/presentation/viewmodel/study_goals_viewmodel.dart';
import 'package:athena/features/planner/presentation/viewmodel/study_sessions_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProgressInsightsScreen extends ConsumerWidget {
  const ProgressInsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsState = ref.watch(studyGoalsViewModelProvider);
    final sessionsState = ref.watch(studySessionsViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.athenaOffWhite,
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text(
          'Progress Insights',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            ref.read(studyGoalsViewModelProvider.notifier).refreshGoals(),
            ref.read(studySessionsViewModelProvider.notifier).loadSessions(),
          ]);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'Your Study Analytics',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Track your progress and study habits',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),

              // Quick Stats Row
              Row(
                children: [
                  Expanded(
                    child: _buildQuickStatCard(
                      '🎯',
                      'Goals',
                      '${goalsState.goals.length}',
                      'Total',
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickStatCard(
                      '📅',
                      'Sessions',
                      '${sessionsState.sessions.length}',
                      'Total',
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickStatCard(
                      '🔥',
                      'Streak',
                      '${_calculateStudyStreak(sessionsState.sessions)}',
                      'Days',
                      Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Study Goals Section
              _buildSectionHeader('🎯 Study Goals Overview'),
              const SizedBox(height: 12),
              _buildGoalsInsightCard(goalsState),
              const SizedBox(height: 24),

              // Study Sessions Section
              _buildSectionHeader('📅 Study Sessions Overview'),
              const SizedBox(height: 12),
              _buildSessionsInsightCard(sessionsState),
              const SizedBox(height: 24),

              // Progress Analytics Section
              _buildSectionHeader('📊 Progress Analytics'),
              const SizedBox(height: 12),
              _buildProgressAnalyticsCard(goalsState, sessionsState),
              const SizedBox(height: 24),

              // Study Patterns Section
              _buildSectionHeader('📈 Study Patterns'),
              const SizedBox(height: 12),
              _buildStudyPatternsCard(sessionsState),
              const SizedBox(height: 100), // Extra space for FAB
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildQuickStatCard(
    String emoji,
    String title,
    String value,
    String subtitle,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(fontSize: 10, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsInsightCard(StudyGoalsState goalsState) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.flag, color: Colors.blue),
              ),
              const SizedBox(width: 12),
              const Text(
                'Goals Progress',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildStatRow(
            'Total Goals',
            '${goalsState.goals.length}',
            Colors.blue,
          ),
          _buildStatRow(
            'Completed',
            '${goalsState.completedGoals.length}',
            Colors.green,
          ),
          _buildStatRow(
            'Active',
            '${goalsState.activeGoals.length}',
            Colors.orange,
          ),
          _buildStatRow(
            'Overdue',
            '${goalsState.overdueGoals.length}',
            Colors.red,
          ),
          const SizedBox(height: 16),
          if (goalsState.goals.isNotEmpty) ...[
            Text(
              'Completion Rate: ${(goalsState.overallProgress * 100).round()}%',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: goalsState.overallProgress,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                _getProgressColor(goalsState.overallProgress),
              ),
              minHeight: 8,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSessionsInsightCard(StudySessionsState sessionsState) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.event, color: Colors.green),
              ),
              const SizedBox(width: 12),
              const Text(
                'Session Activity',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildStatRow(
            'Total Sessions',
            '${sessionsState.sessions.length}',
            Colors.blue,
          ),
          _buildStatRow(
            'Upcoming',
            '${sessionsState.upcomingSessions.length}',
            Colors.orange,
          ),
          _buildStatRow(
            'Today',
            '${sessionsState.todaySessions.length}',
            Colors.green,
          ),
          _buildStatRow(
            'Overdue',
            '${sessionsState.overdueSessions.length}',
            Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressAnalyticsCard(
    StudyGoalsState goalsState,
    StudySessionsState sessionsState,
  ) {
    final completedSessions =
        sessionsState.sessions
            .where((s) => s.status == StudySessionStatus.completed)
            .length;
    final totalStudyHours = _calculateTotalStudyHours(sessionsState.sessions);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.analytics, color: Colors.purple),
              ),
              const SizedBox(width: 12),
              const Text(
                'Performance Metrics',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildStatRow(
            'Goal Completion',
            '${(goalsState.overallProgress * 100).round()}%',
            Colors.blue,
          ),
          _buildStatRow(
            'Sessions This Week',
            '${_getSessionsThisWeek(sessionsState.sessions)}',
            Colors.green,
          ),
          _buildStatRow(
            'Completed Sessions',
            '$completedSessions',
            Colors.purple,
          ),
          _buildStatRow(
            'Total Study Time',
            '${totalStudyHours.toStringAsFixed(1)}h',
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildStudyPatternsCard(StudySessionsState sessionsState) {
    final streak = _calculateStudyStreak(sessionsState.sessions);
    final avgSessionDuration = _calculateAverageSessionDuration(
      sessionsState.sessions,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.trending_up, color: Colors.red),
              ),
              const SizedBox(width: 12),
              const Text(
                'Study Habits',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildStatRow(
            'Current Streak',
            '$streak ${streak == 1 ? 'day' : 'days'}',
            Colors.red,
          ),
          _buildStatRow(
            'Avg Session Length',
            '${avgSessionDuration.round()} min',
            Colors.blue,
          ),
          _buildStatRow(
            'Most Productive Day',
            _getMostProductiveDay(sessionsState.sessions),
            Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getProgressColor(double progress) {
    if (progress < 0.3) return Colors.red;
    if (progress < 0.7) return Colors.orange;
    return Colors.green;
  }

  int _getSessionsThisWeek(List<StudySessionEntity> sessions) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    return sessions.where((session) {
      return session.startTime.isAfter(startOfWeek) &&
          session.startTime.isBefore(endOfWeek.add(const Duration(days: 1)));
    }).length;
  }

  int _calculateStudyStreak(List<StudySessionEntity> sessions) {
    final completedSessions =
        sessions.where((s) => s.status == StudySessionStatus.completed).toList()
          ..sort((a, b) => b.startTime.compareTo(a.startTime));

    if (completedSessions.isEmpty) return 0;

    int streak = 0;
    DateTime? lastDate;

    for (final session in completedSessions) {
      final sessionDate = DateTime(
        session.startTime.year,
        session.startTime.month,
        session.startTime.day,
      );

      if (lastDate == null) {
        lastDate = sessionDate;
        streak = 1;
      } else {
        final daysDifference = lastDate.difference(sessionDate).inDays;
        if (daysDifference == 1) {
          streak++;
          lastDate = sessionDate;
        } else {
          break;
        }
      }
    }

    return streak;
  }

  double _calculateTotalStudyHours(List<StudySessionEntity> sessions) {
    final completedSessions = sessions.where(
      (s) => s.status == StudySessionStatus.completed,
    );

    double totalMinutes = 0;
    for (final session in completedSessions) {
      totalMinutes +=
          session.actualDurationMinutes ?? session.plannedDurationMinutes;
    }

    return totalMinutes / 60;
  }

  double _calculateAverageSessionDuration(List<StudySessionEntity> sessions) {
    if (sessions.isEmpty) return 0;

    double totalMinutes = 0;
    for (final session in sessions) {
      totalMinutes += session.plannedDurationMinutes;
    }

    return totalMinutes / sessions.length;
  }

  String _getMostProductiveDay(List<StudySessionEntity> sessions) {
    if (sessions.isEmpty) return 'N/A';

    final dayCount = <String, int>{};
    final days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    for (final session in sessions) {
      if (session.status == StudySessionStatus.completed) {
        final dayName = days[session.startTime.weekday - 1];
        dayCount[dayName] = (dayCount[dayName] ?? 0) + 1;
      }
    }

    if (dayCount.isEmpty) return 'N/A';

    return dayCount.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }
}

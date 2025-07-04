import 'package:athena/core/constants/app_route_names.dart';
import 'package:athena/core/theme/app_colors.dart';
import 'package:athena/core/utils/timezone_utils.dart';
import 'package:athena/features/planner/domain/entities/study_goal_entity.dart';
import 'package:athena/features/planner/domain/entities/study_session_entity.dart';
import 'package:athena/features/planner/presentation/viewmodel/study_goals_viewmodel.dart';
import 'package:athena/features/planner/presentation/viewmodel/study_sessions_viewmodel.dart';
import 'package:athena/features/planner/presentation/widgets/study_session_form.dart';
import 'package:athena/features/planner/presentation/widgets/study_goal_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class PlannerScreen extends ConsumerStatefulWidget {
  const PlannerScreen({super.key});

  @override
  ConsumerState<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends ConsumerState<PlannerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDate = TimezoneUtils.nowInMalaysia();

  // No more dummy data - using real ViewModels!

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.athenaOffWhite,
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text(
          'Study Planner',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          tabs: const [Tab(text: 'Schedule'), Tab(text: 'Goals')],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.insights),
            onPressed: () {
              context.pushNamed(AppRouteNames.progressInsights);
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Schedule tab
          _buildScheduleTab(),

          // Goals tab
          _buildGoalsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        heroTag: 'planner_fab',
        child: const Icon(Icons.add),
        onPressed: () {
          _showAddDialog(context);
        },
      ),
    );
  }

  Widget _buildScheduleTab() {
    return Column(
      children: [
        // Date selector
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () {
                      setState(() {
                        _selectedDate = _selectedDate.subtract(
                          const Duration(days: 1),
                        );
                      });
                    },
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: TimezoneUtils.nowInMalaysia().subtract(
                            const Duration(days: 365),
                          ),
                          lastDate: TimezoneUtils.nowInMalaysia().add(
                            const Duration(days: 365),
                          ),
                        );
                        if (picked != null) {
                          setState(() {
                            _selectedDate = picked;
                          });
                        }
                      },
                      child: Column(
                        children: [
                          Text(
                            DateFormat('EEEE').format(_selectedDate),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('MMMM d, y').format(_selectedDate),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () {
                      setState(() {
                        _selectedDate = _selectedDate.add(
                          const Duration(days: 1),
                        );
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Consumer(
                builder: (context, ref, child) {
                  final sessionsState = ref.watch(
                    studySessionsViewModelProvider,
                  );

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(7, (index) {
                        final date = TimezoneUtils.nowInMalaysia().add(
                          Duration(days: index - 3),
                        );
                        final isSelected = TimezoneUtils.isSameDayMalaysia(
                          date,
                          _selectedDate,
                        );

                        // Check if this date has any sessions
                        final hasSession = sessionsState.sessions.any(
                          (session) => TimezoneUtils.isSameDayMalaysia(
                            session.startTime,
                            date,
                          ),
                        );

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedDate = date;
                              });
                            },
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor:
                                      isSelected
                                          ? Colors.orange
                                          : Colors.grey[200],
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        DateFormat('E').format(date)[0],
                                        style: TextStyle(
                                          fontSize: 12,
                                          color:
                                              isSelected
                                                  ? Colors.white
                                                  : Colors.grey[700],
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        date.day.toString(),
                                        style: TextStyle(
                                          fontSize: 14,
                                          color:
                                              isSelected
                                                  ? Colors.white
                                                  : Colors.grey[800],
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                // Session indicator dot
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color:
                                        hasSession
                                            ? (isSelected
                                                ? Colors.orange
                                                : Colors.orange.withValues(
                                                  alpha: 0.7,
                                                ))
                                            : Colors.transparent,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  );
                },
              ),
            ],
          ),
        ),

        // Session list
        Expanded(
          child: Builder(
            builder: (context) {
              return Consumer(
                builder: (context, ref, child) {
                  final sessionsState = ref.watch(
                    studySessionsViewModelProvider,
                  );
                  final filteredSessions =
                      sessionsState.sessions.where((session) {
                        return TimezoneUtils.isSameDayMalaysia(
                          session.startTime,
                          _selectedDate,
                        );
                      }).toList();

                  // Clean implementation without debug logs

                  return filteredSessions.isEmpty
                      ? _buildEmptySessionsState()
                      : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredSessions.length,
                        itemBuilder: (context, index) {
                          final session = filteredSessions[index];
                          return _buildSessionCard(context, session);
                        },
                      );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // Removed _filteredSessions getter - now handled in Consumer

  Widget _buildEmptySessionsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_available, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No study sessions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Schedule a session to get started',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              _showModernAddSessionForm(context);
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Session'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Returns a contrasting color for better readability
  Color _getContrastingColor(Color backgroundColor) {
    // Calculate luminance to determine if we need a light or dark text color
    final luminance = backgroundColor.computeLuminance();

    // For darker backgrounds, use a darker shade of the same color
    // For lighter backgrounds, use the original color but darker
    if (luminance > 0.5) {
      // Light background - return a much darker version
      return Color.lerp(backgroundColor, Colors.black, 0.7) ?? backgroundColor;
    } else {
      // Dark background - return a darker but still visible version
      return Color.lerp(backgroundColor, Colors.black, 0.3) ?? backgroundColor;
    }
  }

  Widget _buildSessionCard(BuildContext context, StudySessionEntity session) {
    Color subjectColor;
    IconData subjectIcon;

    switch (session.subject) {
      case 'Biology':
        subjectColor = Colors.green;
        subjectIcon = Icons.science_rounded;
        break;
      case 'Mathematics':
        subjectColor = Colors.blue;
        subjectIcon = Icons.calculate_rounded;
        break;
      case 'History':
        subjectColor = Colors.amber[700]!;
        subjectIcon = Icons.history_edu_rounded;
        break;
      case 'Physics':
        subjectColor = Colors.purple;
        subjectIcon = Icons.bolt;
        break;
      case 'Literature':
        subjectColor = Colors.indigo;
        subjectIcon = Icons.menu_book_rounded;
        break;
      default:
        subjectColor = Colors.grey;
        subjectIcon = Icons.school;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: subjectColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                subjectIcon,
                color: _getContrastingColor(subjectColor),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${DateFormat('h:mm a').format(TimezoneUtils.toMalaysianTime(session.startTime))} - ${DateFormat('h:mm a').format(TimezoneUtils.toMalaysianTime(session.endTime))}',
                    style: const TextStyle(color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: subjectColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      session.subject ?? 'General',
                      style: TextStyle(
                        color: _getContrastingColor(subjectColor),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                  icon: Icon(
                    session.status == StudySessionStatus.completed
                        ? Icons.check_circle
                        : Icons.check_circle_outline,
                    color:
                        session.status == StudySessionStatus.completed
                            ? Colors.green
                            : Colors.grey,
                    size: 28,
                  ),
                  onPressed: () async {
                    await _toggleSessionCompletion(session);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert, size: 24),
                  onPressed: () {
                    _showSessionOptions(context, session);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showSessionOptions(BuildContext context, StudySessionEntity session) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit Session'),
                onTap: () {
                  Navigator.pop(context);
                  _showEditSessionDialog(context, session);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Delete Session'),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteSessionConfirmation(context, session);
                },
              ),
              ListTile(
                leading: const Icon(Icons.notifications),
                title: const Text('Manage Reminders'),
                onTap: () {
                  Navigator.pop(context);
                  _showReminderSettings(context, session);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGoalsTab() {
    return Consumer(
      builder: (context, ref, child) {
        final goalsState = ref.watch(studyGoalsViewModelProvider);

        if (goalsState.isLoading && goalsState.goals.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (goalsState.errorMessage != null) {
          return _buildErrorState(goalsState.errorMessage!);
        }

        if (goalsState.goals.isEmpty) {
          return _buildEmptyGoalsState();
        }

        return RefreshIndicator(
          onRefresh: () async {
            await ref.read(studyGoalsViewModelProvider.notifier).refreshGoals();
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: goalsState.goals.length,
            itemBuilder: (context, index) {
              final goal = goalsState.goals[index];
              return _buildGoalCard(context, goal);
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyGoalsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.flag_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No study goals yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Set a goal to track your progress',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              _showModernAddGoalForm(context);
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Goal'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
          const SizedBox(height: 16),
          Text(
            'Oops! Something went wrong',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage,
            style: TextStyle(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              ref.read(studyGoalsViewModelProvider.notifier).loadGoals();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard(BuildContext context, StudyGoalEntity goal) {
    Color subjectColor;
    IconData subjectIcon;

    switch (goal.subject) {
      case 'Biology':
        subjectColor = Colors.green;
        subjectIcon = Icons.science_rounded;
        break;
      case 'Mathematics':
        subjectColor = Colors.blue;
        subjectIcon = Icons.calculate_rounded;
        break;
      case 'History':
        subjectColor = Colors.amber[700]!;
        subjectIcon = Icons.history_edu_rounded;
        break;
      default:
        subjectColor = Colors.grey;
        subjectIcon = Icons.subject;
    }

    final daysLeft = goal.targetDate?.difference(DateTime.now()).inDays ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: subjectColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(subjectIcon, color: subjectColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        goal.description ?? 'No description',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: subjectColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              goal.subject ?? 'General',
                              style: TextStyle(
                                color: subjectColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  daysLeft < 3
                                      ? Colors.red.withValues(alpha: 0.1)
                                      : Colors.orange.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '$daysLeft days left',
                              style: TextStyle(
                                color:
                                    daysLeft < 3 ? Colors.red : Colors.orange,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progress: ${(goal.progress * 100).toInt()}%',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Text(
                      'Target: ${goal.targetDate != null ? DateFormat('MMM d, y').format(goal.targetDate!) : 'No target date'}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: goal.progress,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getProgressColor(goal.progress),
                    ),
                    minHeight: 10,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _showModernEditGoalForm(context, goal);
                    },
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Edit'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey[800],
                      side: BorderSide(color: Colors.grey[400]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _showUpdateProgressDialog(context, goal);
                    },
                    icon: const Icon(Icons.update, size: 18),
                    label: const Text('Progress'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) async {
                    switch (value) {
                      case 'complete':
                        _markGoalCompleted(goal);
                        break;
                      case 'delete':
                        _showDeleteGoalConfirmation(context, goal);
                        break;
                    }
                  },
                  itemBuilder:
                      (context) => [
                        PopupMenuItem(
                          value: 'complete',
                          child: Row(
                            children: [
                              Icon(
                                goal.isCompleted
                                    ? Icons.undo
                                    : Icons.check_circle,
                                size: 20,
                                color:
                                    goal.isCompleted
                                        ? Colors.orange
                                        : Colors.green,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                goal.isCompleted
                                    ? 'Mark Incomplete'
                                    : 'Mark Complete',
                              ),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_outline,
                                size: 20,
                                color: Colors.red,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Delete Goal',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getProgressColor(double progress) {
    if (progress < 0.3) {
      return Colors.red;
    } else if (progress < 0.7) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  void _showAddDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'What would you like to add?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.event, color: Colors.orange),
                ),
                title: const Text('Study Session'),
                subtitle: const Text('Schedule a time to study'),
                onTap: () {
                  Navigator.pop(context);
                  _showModernAddSessionForm(context);
                },
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.flag, color: Colors.blue),
                ),
                title: const Text('Study Goal'),
                subtitle: const Text('Set a long-term objective'),
                onTap: () {
                  Navigator.pop(context);
                  _showModernAddGoalForm(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showModernAddSessionForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.9,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder:
                (context, scrollController) => StudySessionForm(
                  initialDate: _selectedDate,
                  onSessionCreated: () {
                    // Refresh the sessions list when a new session is created
                    // The form already handles the ViewModel call
                  },
                ),
          ),
    );
  }

  void _showModernAddGoalForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.9,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder:
                (context, scrollController) => StudyGoalForm(
                  onGoalSaved: () {
                    // Refresh the goals list when a new goal is created
                    // The form already handles the ViewModel call
                  },
                ),
          ),
    );
  }

  void _showModernEditGoalForm(BuildContext context, StudyGoalEntity goal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.9,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder:
                (context, scrollController) => StudyGoalForm(
                  initialGoal: goal,
                  onGoalSaved: () {
                    // Refresh the goals list when a goal is updated
                    // The form already handles the ViewModel call
                  },
                ),
          ),
    );
  }

  void _showUpdateProgressDialog(BuildContext context, StudyGoalEntity goal) {
    double currentProgress = goal.progress * 100; // Convert to 0-100 scale

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: Text('Update Progress: ${goal.title}'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Current Progress: ${currentProgress.round()}%',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Slider(
                        value: currentProgress,
                        min: 0,
                        max: 100,
                        divisions: 20,
                        label: '${currentProgress.round()}%',
                        activeColor: Colors.orange,
                        onChanged: (value) {
                          setState(() {
                            currentProgress = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      LinearProgressIndicator(
                        value: currentProgress / 100,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getProgressColor(currentProgress / 100),
                        ),
                        minHeight: 10,
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);

                        // Use our ViewModel to update the goal progress
                        final success = await ref
                            .read(studyGoalsViewModelProvider.notifier)
                            .updateGoalProgress(
                              goal.id,
                              currentProgress / 100.0,
                            );

                        if (mounted) {
                          ScaffoldMessenger.of(this.context).showSnackBar(
                            SnackBar(
                              content: Text(
                                success
                                    ? 'Progress updated to ${currentProgress.round()}%!'
                                    : 'Failed to update progress',
                              ),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Update'),
                    ),
                  ],
                ),
          ),
    );
  }

  Future<void> _markGoalCompleted(StudyGoalEntity goal) async {
    final success = await ref
        .read(studyGoalsViewModelProvider.notifier)
        .markGoalCompleted(goal.id);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Goal marked as ${goal.isCompleted ? 'incomplete' : 'completed'}!'
                : 'Failed to update goal status',
          ),
        ),
      );
    }
  }

  void _showDeleteGoalConfirmation(BuildContext context, StudyGoalEntity goal) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Goal'),
            content: Text('Are you sure you want to delete "${goal.title}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);

                  final success = await ref
                      .read(studyGoalsViewModelProvider.notifier)
                      .deleteGoal(goal.id);

                  if (mounted) {
                    ScaffoldMessenger.of(this.context).showSnackBar(
                      SnackBar(
                        content: Text(
                          success
                              ? 'Goal deleted successfully!'
                              : 'Failed to delete goal',
                        ),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  Future<void> _toggleSessionCompletion(StudySessionEntity session) async {
    final isCompleted = session.status == StudySessionStatus.completed;
    final success =
        isCompleted
            ? await ref
                .read(studySessionsViewModelProvider.notifier)
                .updateSession(
                  session.copyWith(
                    status: StudySessionStatus.scheduled,
                    updatedAt: DateTime.now(),
                  ),
                )
            : await ref
                .read(studySessionsViewModelProvider.notifier)
                .completeSession(session.id);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Session marked as ${isCompleted ? 'scheduled' : 'completed'}!'
                : 'Failed to update session status',
          ),
        ),
      );
    }
  }

  void _showEditSessionDialog(
    BuildContext context,
    StudySessionEntity session,
  ) {
    final titleController = TextEditingController(text: session.title);
    final descriptionController = TextEditingController(text: session.notes);
    final subjectController = TextEditingController(text: session.subject);
    DateTime selectedDate = DateTime(
      session.startTime.year,
      session.startTime.month,
      session.startTime.day,
    );
    TimeOfDay startTime = TimeOfDay.fromDateTime(session.startTime);
    TimeOfDay endTime = TimeOfDay.fromDateTime(session.endTime);

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: const Text('Edit Study Session'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: titleController,
                          decoration: const InputDecoration(
                            labelText: 'Session Title *',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Notes',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: subjectController,
                          decoration: const InputDecoration(
                            labelText: 'Subject',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          title: Text(
                            'Date: ${DateFormat('MMM d, y').format(selectedDate)}',
                          ),
                          leading: const Icon(Icons.calendar_today),
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: TimezoneUtils.nowInMalaysia().subtract(
                                const Duration(days: 365),
                              ),
                              lastDate: TimezoneUtils.nowInMalaysia().add(
                                const Duration(days: 365),
                              ),
                            );
                            if (date != null) {
                              setState(() {
                                selectedDate = date;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: ListTile(
                                title: Text(
                                  'Start: ${startTime.format(context)}',
                                ),
                                leading: const Icon(Icons.access_time),
                                onTap: () async {
                                  final time = await showTimePicker(
                                    context: context,
                                    initialTime: startTime,
                                  );
                                  if (time != null) {
                                    setState(() {
                                      startTime = time;
                                      // Auto-adjust end time to be 1 hour later if needed
                                      if (endTime.hour * 60 + endTime.minute <=
                                          time.hour * 60 + time.minute) {
                                        final newEndTime = time.hour + 1;
                                        endTime = TimeOfDay(
                                          hour:
                                              newEndTime < 24 ? newEndTime : 23,
                                          minute: time.minute,
                                        );
                                      }
                                    });
                                  }
                                },
                              ),
                            ),
                            Expanded(
                              child: ListTile(
                                title: Text('End: ${endTime.format(context)}'),
                                leading: const Icon(Icons.access_time_filled),
                                onTap: () async {
                                  final time = await showTimePicker(
                                    context: context,
                                    initialTime: endTime,
                                  );
                                  if (time != null) {
                                    setState(() {
                                      endTime = time;
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (titleController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter a session title'),
                            ),
                          );
                          return;
                        }

                        // Validate time - Create in Malaysian timezone
                        final startDateTime = TimezoneUtils.createMalaysianTime(
                          selectedDate.year,
                          selectedDate.month,
                          selectedDate.day,
                          startTime.hour,
                          startTime.minute,
                        );
                        final endDateTime = TimezoneUtils.createMalaysianTime(
                          selectedDate.year,
                          selectedDate.month,
                          selectedDate.day,
                          endTime.hour,
                          endTime.minute,
                        );

                        if (endDateTime.isBefore(startDateTime) ||
                            endDateTime.isAtSameMomentAs(startDateTime)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'End time must be after start time',
                              ),
                            ),
                          );
                          return;
                        }

                        Navigator.pop(context);

                        // Update the session
                        final updatedSession = session.copyWith(
                          title: titleController.text.trim(),
                          notes:
                              descriptionController.text.trim().isEmpty
                                  ? null
                                  : descriptionController.text.trim(),
                          subject:
                              subjectController.text.trim().isEmpty
                                  ? null
                                  : subjectController.text.trim(),
                          startTime: startDateTime.toUtc(),
                          endTime: endDateTime.toUtc(),
                          updatedAt: TimezoneUtils.nowInMalaysia().toUtc(),
                        );

                        final success = await ref
                            .read(studySessionsViewModelProvider.notifier)
                            .updateSession(updatedSession);

                        if (mounted) {
                          ScaffoldMessenger.of(this.context).showSnackBar(
                            SnackBar(
                              content: Text(
                                success
                                    ? 'Session updated successfully!'
                                    : 'Failed to update session',
                              ),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Update'),
                    ),
                  ],
                ),
          ),
    );
  }

  void _showDeleteSessionConfirmation(
    BuildContext context,
    StudySessionEntity session,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Session'),
            content: Text(
              'Are you sure you want to delete "${session.title}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);

                  final success = await ref
                      .read(studySessionsViewModelProvider.notifier)
                      .deleteSession(session.id);

                  if (mounted) {
                    ScaffoldMessenger.of(this.context).showSnackBar(
                      SnackBar(
                        content: Text(
                          success
                              ? 'Session deleted successfully!'
                              : 'Failed to delete session',
                        ),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  void _showReminderSettings(BuildContext context, StudySessionEntity session) {
    // For now, show a dialog with reminder options
    // In a full implementation, this would connect to flutter_local_notifications
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Reminder Settings: ${session.title}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Reminder notifications will be available in a future update!',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Planned features:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text('• 15 minutes before session'),
                const Text('• 1 hour before session'),
                const Text('• 1 day before session'),
                const Text('• Custom reminder times'),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'This requires Flutter Local Notifications setup for platform-specific push notifications.',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }
}

// Dummy classes removed - now using real entities!
// StudyGoalEntity and StudySessionEntity are imported from domain layer

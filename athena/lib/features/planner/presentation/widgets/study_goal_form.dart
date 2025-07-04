
import 'package:athena/core/utils/timezone_utils.dart';
import 'package:athena/features/planner/presentation/viewmodel/study_goals_viewmodel.dart';
import 'package:athena/features/planner/domain/entities/study_goal_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Modern, beautiful study goal form with enhanced features
class StudyGoalForm extends ConsumerStatefulWidget {
  final StudyGoalEntity? initialGoal;
  final VoidCallback? onGoalSaved;

  const StudyGoalForm({
    super.key,
    this.initialGoal,
    this.onGoalSaved,
  });

  @override
  ConsumerState<StudyGoalForm> createState() => _StudyGoalFormState();
}

class _StudyGoalFormState extends ConsumerState<StudyGoalForm>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _subjectController = TextEditingController();

  DateTime? _targetDate;
  GoalType _selectedGoalType = GoalType.academic;
  PriorityLevel _selectedPriority = PriorityLevel.medium;
  bool _isSubmitting = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Goal types for better categorization
  final List<Map<String, dynamic>> _goalTypes = [
    {
      'type': GoalType.academic,
      'name': 'Academic',
      'icon': Icons.school,
      'color': Colors.blue,
      'description': 'Learning and study goals'
    },
    {
      'type': GoalType.skills,
      'name': 'Skills',
      'icon': Icons.build,
      'color': Colors.green,
      'description': 'Skill development goals'
    },
    {
      'type': GoalType.career,
      'name': 'Career',
      'icon': Icons.work,
      'color': Colors.purple,
      'description': 'Professional development'
    },
    {
      'type': GoalType.personal,
      'name': 'Personal',
      'icon': Icons.person,
      'color': Colors.orange,
      'description': 'Personal growth goals'
    },
    {
      'type': GoalType.research,
      'name': 'Research',
      'icon': Icons.science,
      'color': Colors.teal,
      'description': 'Research and exploration'
    },
  ];

  // Priority levels
  final List<Map<String, dynamic>> _priorityLevels = [
    {
      'level': PriorityLevel.high,
      'name': 'High',
      'color': Colors.red,
      'icon': Icons.priority_high,
      'description': 'Critical and urgent'
    },
    {
      'level': PriorityLevel.medium,
      'name': 'Medium',
      'color': Colors.orange,
      'icon': Icons.remove,
      'description': 'Important but not urgent'
    },
    {
      'level': PriorityLevel.low,
      'name': 'Low',
      'color': Colors.green,
      'icon': Icons.low_priority,
      'description': 'Nice to have'
    },
  ];

  // Popular subjects for quick selection
  final List<String> _popularSubjects = [
    'Mathematics',
    'Physics',
    'Chemistry',
    'Biology',
    'Computer Science',
    'History',
    'Literature',
    'Psychology',
    'Economics',
    'Engineering',
    'Medicine',
    'Law',
    'Philosophy',
    'Art',
    'Music',
  ];

  @override
  void initState() {
    super.initState();
    _initializeForm();
    _setupAnimations();
  }

  void _initializeForm() {
    if (widget.initialGoal != null) {
      final goal = widget.initialGoal!;
      _titleController.text = goal.title;
      _descriptionController.text = goal.description ?? '';
      _subjectController.text = goal.subject ?? '';
      _targetDate = goal.targetDate;
      _selectedGoalType = goal.goalType;
      _selectedPriority = goal.priorityLevel;
    } else {
      // Set smart defaults for new goals
      _targetDate = TimezoneUtils.nowInMalaysia().add(const Duration(days: 30));
    }
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _subjectController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTitleField(),
                            const SizedBox(height: 24),
                            _buildGoalTypeSelector(),
                            const SizedBox(height: 24),
                            _buildSubjectField(),
                            const SizedBox(height: 24),
                            _buildDescriptionField(),
                            const SizedBox(height: 24),
                            _buildPrioritySelector(),
                            const SizedBox(height: 24),
                            _buildTargetDateSection(),
                            const SizedBox(height: 32),
                            _buildActionButtons(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    final isEditing = widget.initialGoal != null;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.shade400,
            Colors.blue.shade600,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              isEditing ? Icons.edit_note : Icons.flag,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEditing ? 'Edit Study Goal' : 'Create Study Goal',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isEditing 
                      ? 'Update your learning objective'
                      : 'Set your learning objective',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.close,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Goal Title',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _titleController,
          decoration: InputDecoration(
            hintText: 'e.g., "Master Linear Algebra Concepts"',
            prefixIcon: const Icon(Icons.track_changes),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a goal title';
            }
            if (value.trim().length < 3) {
              return 'Title must be at least 3 characters';
            }
            return null;
          },
          textInputAction: TextInputAction.next,
        ),
      ],
    );
  }

  Widget _buildGoalTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Goal Type',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _goalTypes.length,
            itemBuilder: (context, index) {
              final type = _goalTypes[index];
              final isSelected = _selectedGoalType == type['type'];
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedGoalType = type['type'];
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(16),
                  width: 100,
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? type['color'].withValues(alpha: 0.15)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected 
                          ? type['color'] 
                          : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        type['icon'],
                        color: isSelected 
                            ? type['color']
                            : Colors.grey.shade600,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        type['name'],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected 
                              ? type['color']
                              : Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Subject',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _subjectController,
                decoration: InputDecoration(
                  hintText: 'Enter or select subject',
                  prefixIcon: const Icon(Icons.subject),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                textInputAction: TextInputAction.next,
              ),
            ),
            const SizedBox(width: 12),
            PopupMenuButton<String>(
              icon: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.arrow_drop_down,
                  color: Colors.blue.shade700,
                ),
              ),
              onSelected: (subject) {
                _subjectController.text = subject;
              },
              itemBuilder: (context) => _popularSubjects
                  .map((subject) => PopupMenuItem(
                        value: subject,
                        child: Text(subject),
                      ))
                  .toList(),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: _popularSubjects.take(6).map((subject) {
            return GestureDetector(
              onTap: () => _subjectController.text = subject,
              child: Chip(
                label: Text(
                  subject,
                  style: const TextStyle(fontSize: 12),
                ),
                backgroundColor: Colors.blue.shade50,
                side: BorderSide(color: Colors.blue.shade200),
                labelStyle: TextStyle(color: Colors.blue.shade700),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description (Optional)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _descriptionController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Describe your goal in detail...',
            prefixIcon: const Padding(
              padding: EdgeInsets.only(bottom: 60),
              child: Icon(Icons.description),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          textInputAction: TextInputAction.done,
        ),
      ],
    );
  }

  Widget _buildPrioritySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Priority Level',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: _priorityLevels.map((priority) {
            final isSelected = _selectedPriority == priority['level'];
            
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedPriority = priority['level'];
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? priority['color'].withValues(alpha: 0.15)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected 
                          ? priority['color'] 
                          : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        priority['icon'],
                        color: isSelected 
                            ? priority['color']
                            : Colors.grey.shade600,
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        priority['name'],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected 
                              ? priority['color']
                              : Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTargetDateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Target Date',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildDateSelector(),
        const SizedBox(height: 12),
        _buildDateInfo(),
      ],
    );
  }

  Widget _buildDateSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.green.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.event,
            color: Colors.green.shade700,
            size: 20,
          ),
        ),
        title: Text(
          _targetDate != null
              ? DateFormat('EEEE, MMMM d, y').format(_targetDate!)
              : 'Select Target Date',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.green.shade800,
          ),
        ),
        subtitle: Text(
          _targetDate != null
              ? _getDateDescription(_targetDate!)
              : 'When do you want to achieve this goal?',
          style: TextStyle(color: Colors.green.shade600),
        ),
        trailing: Icon(
          Icons.edit,
          color: Colors.green.shade600,
          size: 20,
        ),
        onTap: _selectTargetDate,
      ),
    );
  }

  Widget _buildDateInfo() {
    if (_targetDate == null) return const SizedBox.shrink();

    final now = TimezoneUtils.nowInMalaysia();
    final daysUntil = _targetDate!.difference(now).inDays;
    final isOverdue = daysUntil < 0;
    final isUrgent = daysUntil <= 7 && daysUntil > 0;

    Color statusColor;
    IconData statusIcon;
    String statusText;

    if (isOverdue) {
      statusColor = Colors.red;
      statusIcon = Icons.warning;
      statusText = 'Overdue by ${daysUntil.abs()} days';
    } else if (isUrgent) {
      statusColor = Colors.orange;
      statusIcon = Icons.schedule;
      statusText = 'Due in $daysUntil days';
    } else {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle_outline;
      statusText = '$daysUntil days to complete';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            statusIcon,
            color: statusColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              statusText,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final isEditing = widget.initialGoal != null;
    
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: FilledButton(
            onPressed: _isSubmitting ? null : _submitForm,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
            ),
            child: _isSubmitting
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isEditing ? Icons.update : Icons.flag,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isEditing ? 'Update Goal' : 'Create Goal',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: TextButton(
            onPressed: _isSubmitting ? null : () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey.shade600,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Cancel'),
          ),
        ),
      ],
    );
  }

  Future<void> _selectTargetDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _targetDate ?? TimezoneUtils.nowInMalaysia().add(const Duration(days: 30)),
      firstDate: TimezoneUtils.nowInMalaysia(),
      lastDate: TimezoneUtils.nowInMalaysia().add(const Duration(days: 1095)), // 3 years
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Colors.blue,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _targetDate = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final isEditing = widget.initialGoal != null;
      
      if (isEditing) {
        // Update existing goal
        final updatedGoal = widget.initialGoal!.copyWith(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isEmpty 
              ? null 
              : _descriptionController.text.trim(),
          subject: _subjectController.text.trim().isEmpty 
              ? null 
              : _subjectController.text.trim(),
          targetDate: _targetDate,
          goalType: _selectedGoalType,
          priorityLevel: _selectedPriority,
          updatedAt: TimezoneUtils.nowInMalaysia().toUtc(),
        );

        final success = await ref
            .read(studyGoalsViewModelProvider.notifier)
            .updateGoal(updatedGoal);

        if (mounted) {
          _showFeedback(
            success: success,
            successMessage: 'Goal updated successfully!',
            errorMessage: 'Failed to update goal. Please try again.',
          );
        }
      } else {
        // Create new goal
        final success = await ref
            .read(studyGoalsViewModelProvider.notifier)
            .createGoal(
              title: _titleController.text.trim(),
              description: _descriptionController.text.trim().isEmpty 
                  ? null 
                  : _descriptionController.text.trim(),
              subject: _subjectController.text.trim().isEmpty 
                  ? null 
                  : _subjectController.text.trim(),
              targetDate: _targetDate,
              goalType: _selectedGoalType,
              priorityLevel: _selectedPriority,
            );

        if (mounted) {
          _showFeedback(
            success: success,
            successMessage: 'Goal created successfully!',
            errorMessage: 'Failed to create goal. Please try again.',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        _showFeedback(
          success: false,
          errorMessage: 'Error: $e',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showFeedback({
    required bool success,
    String? successMessage,
    String? errorMessage,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              success ? Icons.check_circle : Icons.error,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Text(success ? successMessage! : errorMessage!),
          ],
        ),
        backgroundColor: success ? Colors.green.shade600 : Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );

    if (success) {
      Navigator.pop(context);
      widget.onGoalSaved?.call();
    }
  }

  // Helper methods
  String _getDateDescription(DateTime date) {
    final now = TimezoneUtils.nowInMalaysia();
    final difference = date.difference(now).inDays;
    
    if (difference == 0) return 'Today';
    if (difference == 1) return 'Tomorrow';
    if (difference == -1) return 'Yesterday';
    if (difference > 1) return 'In $difference days';
    return '${difference.abs()} days ago';
  }
} 
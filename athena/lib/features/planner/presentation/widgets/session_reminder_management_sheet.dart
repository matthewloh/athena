import 'package:athena/core/providers/auth_provider.dart';
import 'package:athena/core/theme/app_colors.dart';
import 'package:athena/core/utils/timezone_utils.dart';
import 'package:athena/features/planner/domain/entities/session_reminder_entity.dart';
import 'package:athena/features/planner/domain/entities/reminder_template_entity.dart';
import 'package:athena/features/planner/domain/entities/study_session_entity.dart';
import 'package:athena/features/planner/domain/entities/user_reminder_preferences_entity.dart'
    hide TimeOfDay;
import 'package:athena/features/planner/domain/usecases/manage_user_reminder_preferences_usecase.dart';
import 'package:athena/features/planner/presentation/providers/reminder_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Bottom sheet for managing session reminders
class SessionReminderManagementSheet extends ConsumerStatefulWidget {
  final StudySessionEntity session;

  const SessionReminderManagementSheet({super.key, required this.session});

  @override
  ConsumerState<SessionReminderManagementSheet> createState() =>
      _SessionReminderManagementSheetState();
}

class _SessionReminderManagementSheetState
    extends ConsumerState<SessionReminderManagementSheet> {
  @override
  void initState() {
    super.initState();
    // Load data when the sheet opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(reminderTemplatesViewModelProvider.notifier)
          .loadDefaultReminderTemplates();
      ref
          .read(sessionRemindersViewModelProvider.notifier)
          .loadSessionReminders(widget.session.id);

      final currentUser = ref.read(appAuthProvider.notifier).currentUser;
      if (currentUser != null) {
        ref
            .read(userReminderPreferencesViewModelProvider.notifier)
            .loadUserPreferences(currentUser.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final remindersState = ref.watch(sessionRemindersViewModelProvider);
    final templatesState = ref.watch(reminderTemplatesViewModelProvider);
    final preferencesState = ref.watch(
      userReminderPreferencesViewModelProvider,
    );
    final currentUser = ref.watch(appAuthProvider.notifier).currentUser;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.notifications_active,
                      color: AppColors.athenaPurple,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Session Reminders',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            widget.session.title,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  DateFormat(
                    'EEEE, MMM d, y • h:mm a',
                  ).format(TimezoneUtils.toMalaysianTime(widget.session.startTime)),
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick Setup Section
                  if (remindersState.reminders.isEmpty &&
                      !remindersState.isLoading)
                    _buildQuickSetupSection(templatesState, currentUser?.id),

                  // Existing Reminders Section
                  if (remindersState.reminders.isNotEmpty)
                    _buildExistingRemindersSection(remindersState),

                  const SizedBox(height: 16),

                  // Add New Reminder Section
                  _buildAddNewReminderSection(templatesState, currentUser?.id),

                  const SizedBox(height: 16),

                  // Preferences Section
                  _buildPreferencesSection(preferencesState, currentUser?.id),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSetupSection(dynamic templatesState, String? userId) {
    if (userId == null) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.flash_on, color: Colors.orange, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Quick Setup',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Set up commonly used reminders for this session:',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  templatesState.defaultTemplates.map<Widget>((template) {
                    return _QuickSetupChip(
                      template: template,
                      onTap:
                          () => _createReminderFromTemplate(template, userId),
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExistingRemindersSection(dynamic remindersState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.schedule, color: AppColors.athenaPurple, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Active Reminders',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...remindersState.reminders.map<Widget>((reminder) {
          return _ReminderCard(
            reminder: reminder,
            onToggle: (enabled) => _toggleReminder(reminder.id, enabled),
            onEdit: () => _editReminder(reminder),
            onDelete: () => _deleteReminder(reminder.id),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildAddNewReminderSection(dynamic templatesState, String? userId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.add_circle_outline, color: Colors.green, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Add Reminder',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed:
                () => _showAddReminderDialog(templatesState.templates, userId),
            icon: const Icon(Icons.add),
            label: const Text('Add Custom Reminder'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreferencesSection(dynamic preferencesState, String? userId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.settings, color: Colors.grey[700], size: 20),
            const SizedBox(width: 8),
            const Text(
              'Reminder Settings',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListTile(
          leading: Icon(Icons.bedtime, color: Colors.indigo),
          title: const Text('Quiet Hours'),
          subtitle: Text(
            preferencesState.preferences?.quietHoursStart != null
                ? '${preferencesState.preferences!.quietHoursStart} - ${preferencesState.preferences!.quietHoursEnd}'
                : 'Not set',
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap:
              () => _showQuietHoursDialog(preferencesState.preferences, userId),
        ),
        // ListTile(
        //   leading: Icon(Icons.timer, color: Colors.orange),
        //   title: const Text('Default Reminder Time'),
        //   subtitle: const Text(
        //     '15 minutes before',
        //   ), // Use hardcoded default for now
        //   trailing: const Icon(Icons.chevron_right),
        //   onTap:
        //       () =>
        //           _showDefaultTimeDialog(preferencesState.preferences, userId),
        // ),
      ],
    );
  }

  Future<void> _createReminderFromTemplate(
    ReminderTemplateEntity template,
    String userId,
  ) async {
    final reminder = SessionReminderEntity(
      id: '', // Will be generated
      sessionId: widget.session.id,
      userId: userId,
      templateId: template.id,
      offsetMinutes: template.offsetMinutes,
      isEnabled: true,
      deliveryStatus: ReminderDeliveryStatus.pending,
    );

    final success = await ref
        .read(sessionRemindersViewModelProvider.notifier)
        .createReminder(reminder);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Reminder added successfully!' : 'Failed to add reminder',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  Future<void> _toggleReminder(String reminderId, bool enabled) async {
    final success = await ref
        .read(sessionRemindersViewModelProvider.notifier)
        .toggleReminderEnabled(reminderId, enabled);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Reminder ${enabled ? 'enabled' : 'disabled'}'
                : 'Failed to update reminder',
          ),
        ),
      );
    }
  }

  Future<void> _editReminder(SessionReminderEntity reminder) async {
    showDialog(
      context: context,
      builder:
          (context) => _EditReminderDialog(
            reminder: reminder,
            sessionTitle: widget.session.title,
            onReminderUpdated: () {
              ref
                  .read(sessionRemindersViewModelProvider.notifier)
                  .loadSessionReminders(widget.session.id);
            },
          ),
    );
  }

  Future<void> _deleteReminder(String reminderId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Reminder'),
            content: const Text(
              'Are you sure you want to delete this reminder?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      final success = await ref
          .read(sessionRemindersViewModelProvider.notifier)
          .deleteReminder(reminderId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Reminder deleted successfully!'
                  : 'Failed to delete reminder',
            ),
          ),
        );
      }
    }
  }

  Future<void> _showAddReminderDialog(
    List<ReminderTemplateEntity> templates,
    String? userId,
  ) async {
    if (userId == null) return;

    showDialog(
      context: context,
      builder:
          (context) => _CustomReminderDialog(
            sessionId: widget.session.id,
            userId: userId,
            templates: templates,
            onReminderCreated: () {
              ref
                  .read(sessionRemindersViewModelProvider.notifier)
                  .loadSessionReminders(widget.session.id);
            },
          ),
    );
  }

  Future<void> _showQuietHoursDialog(
    dynamic preferences,
    String? userId,
  ) async {
    if (userId == null) return;

    showDialog(
      context: context,
      builder:
          (context) => _QuietHoursDialog(
            currentPreferences: preferences,
            userId: userId,
            onSaved: () {
              ref
                  .read(userReminderPreferencesViewModelProvider.notifier)
                  .loadUserPreferences(userId);
            },
          ),
    );
  }

  Future<void> _showDefaultTimeDialog(
    dynamic preferences,
    String? userId,
  ) async {
    if (userId == null) return;

    showDialog(
      context: context,
      builder:
          (context) => _DefaultReminderTimeDialog(
            currentPreferences: preferences,
            userId: userId,
            onSaved: () {
              ref
                  .read(userReminderPreferencesViewModelProvider.notifier)
                  .loadUserPreferences(userId);
            },
          ),
    );
  }
}

class _QuickSetupChip extends StatelessWidget {
  final ReminderTemplateEntity template;
  final VoidCallback onTap;

  const _QuickSetupChip({required this.template, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(
        template.name,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),
      avatar: Icon(_getTemplateIcon(template.offsetMinutes), size: 16),
      onSelected: (_) => onTap(),
      backgroundColor: AppColors.athenaPurple.withValues(alpha: 0.1),
      selectedColor: AppColors.athenaPurple.withValues(alpha: 0.2),
      checkmarkColor: AppColors.athenaPurple,
      labelStyle: TextStyle(color: AppColors.athenaPurple),
      side: BorderSide(color: AppColors.athenaPurple.withValues(alpha: 0.3)),
    );
  }

  IconData _getTemplateIcon(int offsetMinutes) {
    if (offsetMinutes <= 15) return Icons.alarm;
    if (offsetMinutes <= 60) return Icons.access_time;
    return Icons.schedule;
  }
}

class _ReminderCard extends StatelessWidget {
  final SessionReminderEntity reminder;
  final Function(bool) onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ReminderCard({
    required this.reminder,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final timeText = _formatReminderTime(reminder.offsetMinutes);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        reminder.isEnabled
                            ? AppColors.athenaPurple.withValues(alpha: 0.1)
                            : Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getTemplateIcon(reminder.offsetMinutes),
                    color:
                        reminder.isEnabled
                            ? AppColors.athenaPurple
                            : Colors.grey,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        timeText,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      if (reminder.customMessage != null)
                        Text(
                          reminder.customMessage!,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      if (reminder.scheduledTime != null)
                        Text(
                          'Scheduled: ${DateFormat('MMM d, h:mm a').format(TimezoneUtils.toMalaysianTime(reminder.scheduledTime!))}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                    ],
                  ),
                ),
                Switch(
                  value: reminder.isEnabled,
                  onChanged: onToggle,
                  activeColor: AppColors.athenaPurple,
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        onEdit();
                        break;
                      case 'delete':
                        onDelete();
                        break;
                    }
                  },
                  itemBuilder:
                      (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 16),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 16, color: Colors.red),
                              SizedBox(width: 8),
                              Text(
                                'Delete',
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

  String _formatReminderTime(int offsetMinutes) {
    if (offsetMinutes < 60) {
      return '$offsetMinutes minutes before';
    } else {
      final hours = offsetMinutes ~/ 60;
      final remainingMinutes = offsetMinutes % 60;
      if (remainingMinutes == 0) {
        return '${hours}h before';
      } else {
        return '${hours}h ${remainingMinutes}m before';
      }
    }
  }

  IconData _getTemplateIcon(int offsetMinutes) {
    if (offsetMinutes <= 15) return Icons.alarm;
    if (offsetMinutes <= 60) return Icons.access_time;
    return Icons.schedule;
  }
}

// Custom Reminder Creation Dialog
class _CustomReminderDialog extends ConsumerStatefulWidget {
  final String sessionId;
  final String userId;
  final List<ReminderTemplateEntity> templates;
  final VoidCallback onReminderCreated;

  const _CustomReminderDialog({
    required this.sessionId,
    required this.userId,
    required this.templates,
    required this.onReminderCreated,
  });

  @override
  ConsumerState<_CustomReminderDialog> createState() =>
      _CustomReminderDialogState();
}

class _CustomReminderDialogState extends ConsumerState<_CustomReminderDialog> {
  final _messageController = TextEditingController();
  int _selectedMinutes = 15;
  String? _selectedTemplateId;
  bool _isLoading = false;

  final List<int> _commonTimes = [5, 10, 15, 30, 60, 120, 1440]; // minutes
  final TextEditingController _customMinutesController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    _customMinutesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Custom Reminder'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Template selection
            if (widget.templates.isNotEmpty) ...[
              const Text(
                'Use template (optional):',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              DropdownButton<String?>(
                value: _selectedTemplateId,
                isExpanded: true,
                hint: const Text('Select a template'),
                onChanged: (templateId) {
                  setState(() {
                    _selectedTemplateId = templateId;
                    if (templateId != null) {
                      final template = widget.templates.firstWhere(
                        (t) => t.id == templateId,
                      );
                      _selectedMinutes = template.offsetMinutes;
                    }
                  });
                },
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('Custom timing'),
                  ),
                  ...widget.templates.map(
                    (template) => DropdownMenuItem<String?>(
                      value: template.id,
                      child: Text(template.name),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            const Text(
              'Remind me:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            // Time selection chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  _commonTimes.map((minutes) {
                    final isSelected = _selectedMinutes == minutes;
                    return FilterChip(
                      label: Text(_formatTimeLabel(minutes)),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedMinutes = minutes;
                          _selectedTemplateId =
                              null; // Clear template selection when custom time is chosen
                        });
                      },
                      selectedColor: AppColors.athenaPurple.withValues(
                        alpha: 0.2,
                      ),
                      checkmarkColor: AppColors.athenaPurple,
                    );
                  }).toList(),
            ),

            const SizedBox(height: 12),

            // Custom minutes input
            TextField(
              controller: _customMinutesController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Custom minutes before session',
                hintText: 'Enter minutes (e.g. 1, 5, 90)',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                final minutes = int.tryParse(value);
                if (minutes != null && minutes > 0) {
                  setState(() {
                    _selectedMinutes = minutes;
                    _selectedTemplateId = null;
                  });
                }
              },
            ),

            const SizedBox(height: 20),

            const Text(
              'Custom message (optional):',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Your study session starts soon!',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              maxLength: 200,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _createReminder,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.athenaPurple,
            foregroundColor: Colors.white,
          ),
          child:
              _isLoading
                  ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                  : const Text('Add Reminder'),
        ),
      ],
    );
  }

  String _formatTimeLabel(int minutes) {
    if (minutes < 60) {
      return '${minutes}m before';
    } else if (minutes == 60) {
      return '1h before';
    } else if (minutes == 120) {
      return '2h before';
    } else if (minutes == 1440) {
      return '1 day before';
    } else {
      final hours = minutes ~/ 60;
      return '${hours}h before';
    }
  }

  Future<void> _createReminder() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final reminder = SessionReminderEntity(
        id: '', // Will be generated
        sessionId: widget.sessionId,
        userId: widget.userId,
        templateId: _selectedTemplateId,
        offsetMinutes: _selectedMinutes,
        customMessage:
            _messageController.text.trim().isEmpty
                ? null
                : _messageController.text.trim(),
        isEnabled: true,
        deliveryStatus: ReminderDeliveryStatus.pending,
      );

      final success = await ref
          .read(sessionRemindersViewModelProvider.notifier)
          .createReminder(reminder);

      if (success && mounted) {
        Navigator.pop(context);
        widget.onReminderCreated();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Custom reminder added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

// Edit Reminder Dialog
class _EditReminderDialog extends ConsumerStatefulWidget {
  final SessionReminderEntity reminder;
  final String sessionTitle;
  final VoidCallback onReminderUpdated;

  const _EditReminderDialog({
    required this.reminder,
    required this.sessionTitle,
    required this.onReminderUpdated,
  });

  @override
  ConsumerState<_EditReminderDialog> createState() =>
      _EditReminderDialogState();
}

class _EditReminderDialogState extends ConsumerState<_EditReminderDialog> {
  late final TextEditingController _messageController;
  late int _selectedMinutes;
  bool _isLoading = false;

  final List<int> _commonTimes = [5, 10, 15, 30, 60, 120, 1440];

  @override
  void initState() {
    super.initState();
    _selectedMinutes = widget.reminder.offsetMinutes;
    _messageController = TextEditingController(
      text: widget.reminder.customMessage ?? '',
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Reminder'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Remind me:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            // Time selection chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  _commonTimes.map((minutes) {
                    final isSelected = _selectedMinutes == minutes;
                    return FilterChip(
                      label: Text(_formatTimeLabel(minutes)),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedMinutes = minutes;
                        });
                      },
                      selectedColor: AppColors.athenaPurple.withValues(
                        alpha: 0.2,
                      ),
                      checkmarkColor: AppColors.athenaPurple,
                    );
                  }).toList(),
            ),

            const SizedBox(height: 20),

            const Text(
              'Custom message (optional):',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Your study session starts soon!',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              maxLength: 200,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _updateReminder,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.athenaPurple,
            foregroundColor: Colors.white,
          ),
          child:
              _isLoading
                  ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                  : const Text('Update'),
        ),
      ],
    );
  }

  String _formatTimeLabel(int minutes) {
    if (minutes < 60) {
      return '${minutes}m before';
    } else if (minutes == 60) {
      return '1h before';
    } else if (minutes == 120) {
      return '2h before';
    } else if (minutes == 1440) {
      return '1 day before';
    } else {
      final hours = minutes ~/ 60;
      return '${hours}h before';
    }
  }

  Future<void> _updateReminder() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final updatedReminder = widget.reminder.copyWith(
        offsetMinutes: _selectedMinutes,
        customMessage:
            _messageController.text.trim().isEmpty
                ? null
                : _messageController.text.trim(),
      );

      final success = await ref
          .read(sessionRemindersViewModelProvider.notifier)
          .updateReminder(updatedReminder);

      if (success && mounted) {
        Navigator.pop(context);
        widget.onReminderUpdated();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reminder updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

// Quiet Hours Configuration Dialog
class _QuietHoursDialog extends ConsumerStatefulWidget {
  final dynamic currentPreferences;
  final String userId;
  final VoidCallback onSaved;

  const _QuietHoursDialog({
    required this.currentPreferences,
    required this.userId,
    required this.onSaved,
  });

  @override
  ConsumerState<_QuietHoursDialog> createState() => _QuietHoursDialogState();
}

class _QuietHoursDialogState extends ConsumerState<_QuietHoursDialog> {
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  bool _isEnabled = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.currentPreferences?.quietHoursStart != null &&
        widget.currentPreferences?.quietHoursEnd != null) {
      _isEnabled = true;
      _startTime = _parseTimeString(
        widget.currentPreferences!.quietHoursStart!,
      );
      _endTime = _parseTimeString(widget.currentPreferences!.quietHoursEnd!);
    }
  }

  /// Parses a time string in HH:MM format to TimeOfDay
  TimeOfDay? _parseTimeString(String timeString) {
    try {
      final parts = timeString.split(':');
      if (parts.length >= 2) {
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        return TimeOfDay(hour: hour, minute: minute);
      }
    } catch (e) {
      // If parsing fails, return null
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Quiet Hours'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'During quiet hours, reminder notifications will be silenced.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),

          SwitchListTile(
            title: const Text('Enable Quiet Hours'),
            value: _isEnabled,
            onChanged: (value) {
              setState(() {
                _isEnabled = value;
                if (!value) {
                  _startTime = null;
                  _endTime = null;
                }
              });
            },
            activeColor: AppColors.athenaPurple,
          ),

          if (_isEnabled) ...[
            const SizedBox(height: 16),

            // Start Time
            ListTile(
              title: const Text('Start Time'),
              subtitle: Text(_startTime?.format(context) ?? 'Not set'),
              trailing: const Icon(Icons.access_time),
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime:
                      _startTime ?? const TimeOfDay(hour: 22, minute: 0),
                );
                if (time != null) {
                  setState(() {
                    _startTime = time;
                  });
                }
              },
            ),

            // End Time
            ListTile(
              title: const Text('End Time'),
              subtitle: Text(_endTime?.format(context) ?? 'Not set'),
              trailing: const Icon(Icons.access_time),
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: _endTime ?? const TimeOfDay(hour: 8, minute: 0),
                );
                if (time != null) {
                  setState(() {
                    _endTime = time;
                  });
                }
              },
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveQuietHours,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.athenaPurple,
            foregroundColor: Colors.white,
          ),
          child:
              _isLoading
                  ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                  : const Text('Save'),
        ),
      ],
    );
  }

  Future<void> _saveQuietHours() async {
    if (_isEnabled && (_startTime == null || _endTime == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please set both start and end times'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final preferences = UserReminderPreferencesEntity(
        id: widget.currentPreferences?.id ?? '', // Empty string for new records
        userId: widget.userId,
        quietHoursStart:
            _isEnabled
                ? '${_startTime!.hour.toString().padLeft(2, '0')}:${_startTime!.minute.toString().padLeft(2, '0')}:00'
                : null,
        quietHoursEnd:
            _isEnabled
                ? '${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}:00'
                : null,
        defaultReminderTemplateIds:
            widget.currentPreferences?.defaultReminderTemplateIds ?? [],
        notificationsEnabled:
            widget.currentPreferences?.notificationsEnabled ?? true,
        timezone: widget.currentPreferences?.timezone ?? 'Asia/Kuala_Lumpur',
        sessionRemindersEnabled:
            widget.currentPreferences?.sessionRemindersEnabled ?? true,
        goalRemindersEnabled:
            widget.currentPreferences?.goalRemindersEnabled ?? true,
        dailyCheckinsEnabled:
            widget.currentPreferences?.dailyCheckinsEnabled ?? false,
        streakRemindersEnabled:
            widget.currentPreferences?.streakRemindersEnabled ?? true,
        createdAt: widget.currentPreferences?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final success = await ref
          .read(userReminderPreferencesViewModelProvider.notifier)
          .updateUserPreferences(preferences);

      if (mounted) {
        if (success) {
          Navigator.pop(context);
          widget.onSaved();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Quiet hours updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          // Get the actual error message from the ViewModel state
          final errorMessage =
              ref.read(userReminderPreferencesViewModelProvider).errorMessage ??
              'Failed to update quiet hours. Please try again.';

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
              duration: const Duration(
                seconds: 5,
              ), // Longer duration to read the error
            ),
          );
        }
      }
    } catch (e) {
      print('Error saving quiet hours: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

// Default Reminder Time Dialog
class _DefaultReminderTimeDialog extends ConsumerStatefulWidget {
  final dynamic currentPreferences;
  final String userId;
  final VoidCallback onSaved;

  const _DefaultReminderTimeDialog({
    required this.currentPreferences,
    required this.userId,
    required this.onSaved,
  });

  @override
  ConsumerState<_DefaultReminderTimeDialog> createState() =>
      _DefaultReminderTimeDialogState();
}

class _DefaultReminderTimeDialogState
    extends ConsumerState<_DefaultReminderTimeDialog> {
  late int _selectedMinutes;
  bool _isLoading = false;

  final List<int> _commonTimes = [5, 10, 15, 30, 60];

  @override
  void initState() {
    super.initState();
    _selectedMinutes = 15; // Use hardcoded default for now
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Default Reminder Time'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'This will be the default reminder time when creating new study sessions.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),

          const Text(
            'Default reminder:',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                _commonTimes.map((minutes) {
                  final isSelected = _selectedMinutes == minutes;
                  return FilterChip(
                    label: Text('${minutes}m before'),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedMinutes = minutes;
                      });
                    },
                    selectedColor: AppColors.athenaPurple.withValues(
                      alpha: 0.2,
                    ),
                    checkmarkColor: AppColors.athenaPurple,
                  );
                }).toList(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveDefaultTime,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.athenaPurple,
            foregroundColor: Colors.white,
          ),
          child:
              _isLoading
                  ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                  : const Text('Save'),
        ),
      ],
    );
  }

  Future<void> _saveDefaultTime() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // For now, just show a message that this feature is not yet implemented
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Default reminder time feature coming soon!'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

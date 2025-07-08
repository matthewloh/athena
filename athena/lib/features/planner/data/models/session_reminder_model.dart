import 'package:athena/features/planner/domain/entities/reminder_template_entity.dart';
import 'package:athena/features/planner/domain/entities/session_reminder_entity.dart';
import 'package:athena/features/planner/data/models/reminder_template_model.dart';

class SessionReminderModel extends SessionReminderEntity {
  const SessionReminderModel({
    required super.id,
    required super.sessionId,
    required super.userId,
    super.templateId,
    required super.offsetMinutes,
    super.customMessage,
    required super.isEnabled,
    super.scheduledTime,
    super.deliveryStatus = ReminderDeliveryStatus.pending,
    super.sentAt,
    super.errorMessage,
    super.notificationId,
    super.createdAt,
    super.updatedAt,
    super.template,
  });

  factory SessionReminderModel.fromJson(Map<String, dynamic> json) {
    return SessionReminderModel(
      id: json['id'] as String,
      sessionId: json['session_id'] as String,
      userId: json['user_id'] as String,
      templateId: json['template_id'] as String?,
      offsetMinutes: json['offset_minutes'] as int,
      customMessage: json['custom_message'] as String?,
      isEnabled: json['is_enabled'] as bool,
      scheduledTime:
          json['scheduled_time'] != null
              ? DateTime.parse(json['scheduled_time'] as String)
              : null,
      deliveryStatus:
          json['delivery_status'] != null
              ? ReminderDeliveryStatus.values.firstWhere(
                (e) => e.name == json['delivery_status'],
                orElse: () => ReminderDeliveryStatus.pending,
              )
              : ReminderDeliveryStatus.pending,
      sentAt:
          json['sent_at'] != null
              ? DateTime.parse(json['sent_at'] as String)
              : null,
      errorMessage: json['error_message'] as String?,
      notificationId: json['notification_id'] as String?,
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'] as String)
              : null,
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'] as String)
              : null,
      template:
          json['reminder_templates'] != null
              ? ReminderTemplateModel.fromJson(
                json['reminder_templates'] as Map<String, dynamic>,
              )
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'session_id': sessionId,
      'user_id': userId,
      'template_id': templateId,
      'offset_minutes': offsetMinutes,
      'custom_message': customMessage,
      'is_enabled': isEnabled,
      'scheduled_time': scheduledTime?.toIso8601String(),
      'delivery_status': deliveryStatus.name,
      'sent_at': sentAt?.toIso8601String(),
      'error_message': errorMessage,
      'notification_id': notificationId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory SessionReminderModel.fromEntity(SessionReminderEntity entity) {
    return SessionReminderModel(
      id: entity.id,
      sessionId: entity.sessionId,
      userId: entity.userId,
      templateId: entity.templateId,
      offsetMinutes: entity.offsetMinutes,
      customMessage: entity.customMessage,
      isEnabled: entity.isEnabled,
      scheduledTime: entity.scheduledTime,
      deliveryStatus: entity.deliveryStatus,
      sentAt: entity.sentAt,
      errorMessage: entity.errorMessage,
      notificationId: entity.notificationId,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      template:
          entity.template != null
              ? ReminderTemplateModel.fromEntity(entity.template!)
              : null,
    );
  }

  @override
  SessionReminderModel copyWith({
    String? id,
    String? sessionId,
    String? userId,
    String? templateId,
    int? offsetMinutes,
    String? customMessage,
    bool? isEnabled,
    DateTime? scheduledTime,
    ReminderDeliveryStatus? deliveryStatus,
    DateTime? sentAt,
    String? errorMessage,
    String? notificationId,
    DateTime? createdAt,
    DateTime? updatedAt,
    ReminderTemplateEntity? template,
  }) {
    return SessionReminderModel(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      userId: userId ?? this.userId,
      templateId: templateId ?? this.templateId,
      offsetMinutes: offsetMinutes ?? this.offsetMinutes,
      customMessage: customMessage ?? this.customMessage,
      isEnabled: isEnabled ?? this.isEnabled,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      deliveryStatus: deliveryStatus ?? this.deliveryStatus,
      sentAt: sentAt ?? this.sentAt,
      errorMessage: errorMessage ?? this.errorMessage,
      notificationId: notificationId ?? this.notificationId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      template: template ?? this.template,
    );
  }
}
 
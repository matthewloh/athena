import 'package:athena/features/planner/domain/entities/reminder_template_entity.dart';

class ReminderTemplateModel extends ReminderTemplateEntity {
  const ReminderTemplateModel({
    required super.id,
    required super.name,
    super.description,
    required super.offsetMinutes,
    required super.messageTemplate,
    required super.isDefault,
    required super.isActive,
    super.createdAt,
    super.updatedAt,
  });

  factory ReminderTemplateModel.fromJson(Map<String, dynamic> json) {
    return ReminderTemplateModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      offsetMinutes: json['offset_minutes'] as int,
      messageTemplate: json['message_template'] as String,
      isDefault: json['is_default'] as bool,
      isActive: json['is_active'] as bool,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'offset_minutes': offsetMinutes,
      'message_template': messageTemplate,
      'is_default': isDefault,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory ReminderTemplateModel.fromEntity(ReminderTemplateEntity entity) {
    return ReminderTemplateModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      offsetMinutes: entity.offsetMinutes,
      messageTemplate: entity.messageTemplate,
      isDefault: entity.isDefault,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  ReminderTemplateModel copyWith({
    String? id,
    String? name,
    String? description,
    int? offsetMinutes,
    String? messageTemplate,
    bool? isDefault,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReminderTemplateModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      offsetMinutes: offsetMinutes ?? this.offsetMinutes,
      messageTemplate: messageTemplate ?? this.messageTemplate,
      isDefault: isDefault ?? this.isDefault,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 
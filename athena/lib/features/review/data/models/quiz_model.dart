import 'package:athena/core/enums/subject.dart';
import 'package:athena/features/review/domain/entities/quiz_entity.dart';

class QuizModel extends QuizEntity {
  /// Creates a [QuizModel] instance.
  const QuizModel({
    required super.id,
    required super.userId,
    required super.title,
    super.studyMaterialId,
    super.subject,
    super.description,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Factory constructor to create a [QuizModel] from a [QuizEntity].
  factory QuizModel.fromEntity(QuizEntity entity) {
    return QuizModel(
      id: entity.id,
      userId: entity.userId,
      title: entity.title,
      studyMaterialId: entity.studyMaterialId,
      subject: entity.subject,
      description: entity.description,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Converts the [QuizModel] to a [QuizEntity].
  QuizEntity toEntity() {
    return QuizEntity(
      id: id,
      userId: userId,
      title: title,
      studyMaterialId: studyMaterialId,
      subject: subject,
      description: description,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Factory constructor to create a [QuizModel] from JSON.
  factory QuizModel.fromJson(Map<String, dynamic> json) {
    return QuizModel(
      id: json['id'],
      userId: json['userId'],
      title: json['title'],
      studyMaterialId: json['studyMaterialId'],
      subject: Subject.values.firstWhere(
        (e) => e.toString() == 'Subject.${json['subject']}',
      ),
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  /// Converts the [QuizModel] to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'studyMaterialId': studyMaterialId,
      'subject': subject?.toString().split('.').last, // Convert enum to string
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Converts the [QuizModel] to a JSON object suitable for insertion into a database.
  Map<String, dynamic> toInsertJson() {
    final json = toJson();
    json.remove('id');
    json.remove('created_at');
    json.remove('updated_at');
    return json;
  }

  /// Converts the [QuizModel] to a JSON object suitable for updating in a database.
  Map<String, dynamic> toUpdateJson() {
    final json = toJson();
    json.remove('id');
    json.remove('createdAt');
    json.remove('updatedAt');
    return json;
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    title,
    studyMaterialId,
    subject,
    description,
    createdAt,
    updatedAt,
  ];

  @override
  QuizModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? studyMaterialId,
    Subject? subject,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return QuizModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      studyMaterialId: studyMaterialId ?? this.studyMaterialId,
      subject: subject ?? this.subject,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

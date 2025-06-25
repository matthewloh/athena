import 'package:athena/core/enums/subject.dart';
import 'package:athena/features/review/domain/entities/quiz_entity.dart';

class QuizModel extends QuizEntity {
  /// Creates a [QuizModel] instance.
  const QuizModel({
    required super.id,
    required super.userId,
    required super.title,
    required super.quizType,
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
      quizType: entity.quizType,
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
      quizType: quizType,
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
      userId: json['user_id'],
      title: json['title'],
      quizType:
          json['quiz_type'] != null
              ? QuizType.values.firstWhere(
                (e) => e.name == json['quiz_type'],
                orElse: () => QuizType.flashcard,
              )
              : QuizType.flashcard,
      studyMaterialId: json['study_material_id'],
      subject:
          json['subject'] != null
              ? Subject.values.firstWhere(
                (e) => e.name == json['subject'],
                orElse: () => Subject.none,
              )
              : null,
      description: json['description'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  /// Converts the [QuizModel] to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'quiz_type': quizType.name,
      'study_material_id': studyMaterialId,
      'subject': subject?.name,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
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
    json.remove('created_at');
    json.remove('updated_at');
    return json;
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    title,
    quizType,
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
    QuizType? quizType,
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
      quizType: quizType ?? this.quizType,
      studyMaterialId: studyMaterialId ?? this.studyMaterialId,
      subject: subject ?? this.subject,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

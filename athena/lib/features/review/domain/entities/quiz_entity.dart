import 'package:athena/core/enums/subject.dart';
import 'package:equatable/equatable.dart';

enum QuizType { flashcard, multipleChoice }

class QuizEntity extends Equatable {
  final String id;
  final String userId;
  final String title;
  final QuizType quizType;
  final String? studyMaterialId;
  final Subject? subject;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  const QuizEntity({
    required this.id,
    required this.userId,
    required this.title,
    required this.quizType,
    this.studyMaterialId,
    this.subject,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });

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

  QuizEntity copyWith({
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
    return QuizEntity(
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

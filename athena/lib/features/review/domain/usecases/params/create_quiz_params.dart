import 'package:athena/core/enums/subject.dart';
import 'package:athena/features/review/domain/entities/quiz_item_entity.dart';
import 'package:equatable/equatable.dart';

class CreateQuizParams extends Equatable {
  final String userId;
  final String title;
  final String? studyMaterialId;
  final Subject? subject;
  final String? description;
  final List<CreateQuizItemParams> quizItems;

  const CreateQuizParams({
    required this.userId,
    required this.title,
    this.studyMaterialId,
    this.subject,
    this.description,
    required this.quizItems,
  });

  @override
  List<Object?> get props => [
    userId,
    title,
    studyMaterialId,
    subject,
    description,
    quizItems,
  ];

  CreateQuizParams copyWith({
    String? userId,
    String? title,
    String? studyMaterialId,
    Subject? subject,
    String? description,
    List<CreateQuizItemParams>? quizItems,
  }) {
    return CreateQuizParams(
      userId: userId ?? this.userId,
      title: title ?? this.title,
      studyMaterialId: studyMaterialId ?? this.studyMaterialId,
      subject: subject ?? this.subject,
      description: description ?? this.description,
      quizItems: quizItems ?? this.quizItems,
    );
  }
  
  const CreateQuizParams.fromUserInput({
    required this.userId,
    required this.title,
    this.studyMaterialId,
    this.subject,
    this.description,
    required this.quizItems,
  });
}

class CreateQuizItemParams extends Equatable {
  final String quizId;
  final String userId;
  final QuizItemType itemType;
  final String questionText;
  final String answerText;
  final Map<String, dynamic>? mcqOptions;
  final String? mcqCorrectOptionKey;
  final double easinessFactor;
  final int intervalDays;
  final int repetitions;
  final DateTime lastReviewedAt;
  final DateTime nextReviewDate;
  final Map<String, dynamic>? metadata;

  const CreateQuizItemParams({
    required this.quizId,
    required this.userId,
    required this.itemType,
    required this.questionText,
    required this.answerText,
    this.mcqOptions,
    this.mcqCorrectOptionKey,
    required this.easinessFactor,
    required this.intervalDays,
    required this.repetitions,
    required this.lastReviewedAt,
    required this.nextReviewDate,
    this.metadata,
  });

  @override
  List<Object?> get props => [
    quizId,
    userId,
    itemType,
    questionText,
    answerText,
    mcqOptions,
    mcqCorrectOptionKey,
    easinessFactor,
    intervalDays,
    repetitions,
    lastReviewedAt,
    nextReviewDate,
    metadata,
  ];

  CreateQuizItemParams copyWith({
    String? quizId,
    String? userId,
    QuizItemType? itemType,
    String? questionText,
    String? answerText,
    Map<String, dynamic>? mcqOptions,
    String? mcqCorrectOptionKey,
    double? easinessFactor,
    int? intervalDays,
    int? repetitions,
    DateTime? lastReviewedAt,
    DateTime? nextReviewDate,
    Map<String, dynamic>? metadata,
  }) {
    return CreateQuizItemParams(
      quizId: quizId ?? this.quizId,
      userId: userId ?? this.userId,
      itemType: itemType ?? this.itemType,
      questionText: questionText ?? this.questionText,
      answerText: answerText ?? this.answerText,
      mcqOptions: mcqOptions ?? this.mcqOptions,
      mcqCorrectOptionKey: mcqCorrectOptionKey ?? this.mcqCorrectOptionKey,
      easinessFactor: easinessFactor ?? this.easinessFactor,
      intervalDays: intervalDays ?? this.intervalDays,
      repetitions: repetitions ?? this.repetitions,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
      metadata: metadata ?? this.metadata,
    );
  }

  const CreateQuizItemParams.fromUserInput({
    required this.quizId,
    required this.userId,
    required this.itemType,
    required this.questionText,
    required this.answerText,
    this.mcqOptions,
    this.mcqCorrectOptionKey,
    required this.easinessFactor,
    required this.intervalDays,
    required this.repetitions,
    required this.lastReviewedAt,
    required this.nextReviewDate,
    this.metadata,
  });
}

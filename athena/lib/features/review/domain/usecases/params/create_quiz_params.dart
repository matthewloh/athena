import 'package:athena/core/enums/subject.dart';
import 'package:equatable/equatable.dart';

class CreateQuizParams extends Equatable {
  final String userId;
  final String title;
  final String? studyMaterialId;
  final Subject? subject;
  final String? description;

  const CreateQuizParams({
    required this.userId,
    required this.title,
    this.studyMaterialId,
    this.subject,
    this.description,
  });

  @override
  List<Object?> get props => [
    userId,
    title,
    studyMaterialId,
    subject,
    description,
  ];

  CreateQuizParams copyWith({
    String? userId,
    String? title,
    String? studyMaterialId,
    Subject? subject,
    String? description,
  }) {
    return CreateQuizParams(
      userId: userId ?? this.userId,
      title: title ?? this.title,
      studyMaterialId: studyMaterialId ?? this.studyMaterialId,
      subject: subject ?? this.subject,
      description: description ?? this.description,
    );
  }
  
  const CreateQuizParams.fromUserInput({
    required this.userId,
    required this.title,
    this.studyMaterialId,
    this.subject,
    this.description,
  });
}

import 'package:athena/core/enums/subject.dart';
import 'package:equatable/equatable.dart';

class UpdateQuizParams extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String? studyMaterialId;
  final Subject? subject;
  final String? description;

  const UpdateQuizParams({
    required this.id,
    required this.userId,
    required this.title,
    this.studyMaterialId,
    this.subject,
    this.description,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    title,
    studyMaterialId,
    subject,
    description,
  ];

  UpdateQuizParams copyWith({
    String? id,
    String? userId,
    String? title,
    String? studyMaterialId,
    Subject? subject,
    String? description,
  }) {
    return UpdateQuizParams(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      studyMaterialId: studyMaterialId ?? this.studyMaterialId,
      subject: subject ?? this.subject,
      description: description ?? this.description,
    );
  }

  const UpdateQuizParams.fromUserInput({
    required this.id,
    required this.userId,
    required this.title,
    this.studyMaterialId,
    this.subject,
    this.description,
  });
}

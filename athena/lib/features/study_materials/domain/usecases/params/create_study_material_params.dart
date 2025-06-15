import 'package:athena/features/study_materials/domain/entities/study_material_entity.dart';
import 'package:equatable/equatable.dart';

class CreateStudyMaterialParams extends Equatable {
  final String userId;
  final String title;
  final String? description;
  final Subject? subject;
  final ContentType contentType;
  final String? originalContentText;
  final String? fileStoragePath;
  final String? ocrExtractedText;
  final String? summaryText;
  final bool hasAiSummary;

  const CreateStudyMaterialParams({
    required this.userId,
    required this.title,
    this.description,
    this.subject,
    required this.contentType,
    this.originalContentText,
    this.fileStoragePath,
    this.ocrExtractedText,
    this.summaryText,
    this.hasAiSummary = false,
  });

  @override
  List<Object?> get props => [
        userId,
        title,
        description,
        subject,
        contentType,
        originalContentText,
        fileStoragePath,
        ocrExtractedText,
        summaryText,
        hasAiSummary,
      ];
}

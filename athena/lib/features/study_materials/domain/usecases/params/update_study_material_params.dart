import 'package:athena/features/study_materials/domain/entities/study_material_entity.dart';
import 'package:equatable/equatable.dart';

class UpdateStudyMaterialParams extends Equatable {
  final String id;
  final String? title;
  final String? description;
  final Subject? subject;
  final String? originalContentText;
  final String? fileStoragePath;
  final String? ocrExtractedText;
  final String? summaryText;
  final bool hasAiSummary;

  const UpdateStudyMaterialParams({
    required this.id,
    this.title,
    this.description,
    this.subject,
    this.originalContentText,
    this.fileStoragePath,
    this.ocrExtractedText,
    this.summaryText,
    this.hasAiSummary = false,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        subject,
        originalContentText,
        fileStoragePath,
        ocrExtractedText,
        summaryText,
        hasAiSummary,
      ];
}
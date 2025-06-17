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

  /// Factory constructor for creating params from the presentation layer
  /// without specifying user ID (will be injected by the viewmodel).
  const CreateStudyMaterialParams.fromUserInput({
    required this.title,
    this.description,
    this.subject,
    required this.contentType,
    this.originalContentText,
    this.fileStoragePath,
    this.ocrExtractedText,
    this.summaryText,
    this.hasAiSummary = false,
  }) : userId = ''; // Temporary placeholder, will be replaced by copyWithUserId

  /// Creates a new CreateStudyMaterialParams with the user ID populated.
  /// This is a convenience method for the presentation layer.
  CreateStudyMaterialParams copyWithUserId(String userId) {
    return CreateStudyMaterialParams(
      userId: userId,
      title: title,
      description: description,
      subject: subject,
      contentType: contentType,
      originalContentText: originalContentText,
      fileStoragePath: fileStoragePath,
      ocrExtractedText: ocrExtractedText,
      summaryText: summaryText,
      hasAiSummary: hasAiSummary,
    );
  }

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

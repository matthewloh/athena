import 'package:equatable/equatable.dart';

class StudyMaterialEntity extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String subject;
  final String contentType;
  final String? originalContentText;
  final String? imageStoragePath;
  final String? ocrExtractedText;
  final String? summaryText;
  final bool hasAiSummary;
  final DateTime createdAt;
  final DateTime updatedAt;

  const StudyMaterialEntity({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.subject,
    required this.contentType,
    this.originalContentText,
    this.imageStoragePath,
    this.ocrExtractedText,
    this.summaryText,
    this.hasAiSummary = false,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        description,
        subject,
        contentType,
        originalContentText,
        imageStoragePath,
        ocrExtractedText,
        summaryText,
        hasAiSummary,
        createdAt,
        updatedAt,
      ];

  StudyMaterialEntity copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? subject,
    String? contentType,
    String? originalContentText,
    String? imageStoragePath,
    String? ocrExtractedText,
    String? summaryText,
    bool? hasAiSummary,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StudyMaterialEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      subject: subject ?? this.subject,
      contentType: contentType ?? this.contentType,
      originalContentText: originalContentText ?? this.originalContentText,
      imageStoragePath: imageStoragePath ?? this.imageStoragePath,
      ocrExtractedText: ocrExtractedText ?? this.ocrExtractedText,
      summaryText: summaryText ?? this.summaryText,
      hasAiSummary: hasAiSummary ?? this.hasAiSummary,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
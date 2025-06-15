import 'package:equatable/equatable.dart';

enum ContentType {
  typedText,
  textFile,
  imageFile,
}

enum Subject {
  none,

  // STEM Subjects
  mathematics,
  physics,
  chemistry,
  biology,
  computerScience,
  engineering,
  statistics,
  dataScience,
  informationTechnology,
  cybersecurity,

  // Languages & Literature
  englishLiterature,
  englishLanguage,
  spanish,
  french,
  german,
  chinese,
  japanese,
  linguistics,
  creativeWriting,

  // Social Sciences
  history,
  geography,
  psychology,
  sociology,
  politicalScience,
  economics,
  anthropology,
  internationalRelations,
  philosophy,
  ethics,

  // Business & Management
  businessStudies,
  marketing,
  finance,
  accounting,
  management,
  humanResources,
  operationsManagement,
  entrepreneurship,

  // Arts & Creative
  art,
  music,
  drama,
  filmStudies,
  photography,
  graphicDesign,
  architecture,

  // Health & Medical
  medicine,
  nursing,
  publicHealth,
  nutrition,
  physicalEducation,
  sportsScience,

  // Law & Legal Studies
  law,
  criminalJustice,
  legalStudies,

  // Environmental & Earth Sciences
  environmentalScience,
  geology,
  climateScience,
  marineBiology,

  // Education & Teaching
  education,
  pedagogy,
  educationalPsychology,
}

class StudyMaterialEntity extends Equatable {
  final String id;
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
  final DateTime createdAt;
  final DateTime updatedAt;

  const StudyMaterialEntity({
    required this.id,
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
        fileStoragePath,
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
    Subject? subject,
    ContentType? contentType,
    String? originalContentText,
    String? fileStoragePath,
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
      fileStoragePath: fileStoragePath ?? this.fileStoragePath,
      ocrExtractedText: ocrExtractedText ?? this.ocrExtractedText,
      summaryText: summaryText ?? this.summaryText,
      hasAiSummary: hasAiSummary ?? this.hasAiSummary,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
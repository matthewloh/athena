import 'package:athena/domain/enums/subject.dart';
import 'package:athena/features/study_materials/domain/entities/study_material_entity.dart';

class StudyMaterialModel extends StudyMaterialEntity {
  /// Constructs a StudyMaterialModel instance.
  const StudyMaterialModel({
    required super.id,
    required super.userId,
    required super.title,
    required super.description,
    required super.subject,
    required super.contentType,
    super.originalContentText,
    super.fileStoragePath,
    super.ocrExtractedText,
    super.summaryText,
    super.hasAiSummary = false,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Converts a StudyMaterialEntity to a StudyMaterialModel.
  factory StudyMaterialModel.fromEntity(StudyMaterialEntity entity) {
    return StudyMaterialModel(
      id: entity.id,
      userId: entity.userId,
      title: entity.title,
      description: entity.description,
      subject: entity.subject,
      contentType: entity.contentType,
      originalContentText: entity.originalContentText,
      fileStoragePath: entity.fileStoragePath,
      ocrExtractedText: entity.ocrExtractedText,
      summaryText: entity.summaryText,
      hasAiSummary: entity.hasAiSummary,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Converts a StudyMaterialModel to a StudyMaterialEntity.
  StudyMaterialEntity toEntity() {
    return StudyMaterialEntity(
      id: id,
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
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Converts a JSON map to a StudyMaterialModel instance.
  factory StudyMaterialModel.fromJson(Map<String, dynamic> json) {
    return StudyMaterialModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      subject:
          json['subject'] != null
              ? Subject.values.firstWhere(
                (e) => e.name == json['subject'],
                orElse: () => Subject.none,
              )
              : null,
      contentType: ContentType.values.firstWhere(
        (e) => e.name == json['content_type'],
        orElse: () => ContentType.typedText,
      ),
      originalContentText: json['original_content_text'] as String?,
      fileStoragePath: json['file_storage_path'] as String?,
      ocrExtractedText: json['ocr_extracted_text'] as String?,
      summaryText: json['summary_text'] as String?,
      hasAiSummary: json['has_ai_summary'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Converts a StudyMaterialModel instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'subject': subject?.name,
      'content_type': contentType.name,
      'original_content_text': originalContentText,
      'file_storage_path': fileStoragePath,
      'ocr_extracted_text': ocrExtractedText,
      'summary_text': summaryText,
      'has_ai_summary': hasAiSummary,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
  Map<String, dynamic> toInsertJson() {
    final json = toJson();
    json.remove('id');
    json.remove('created_at');
    json.remove('updated_at');
    return json;
  }

  Map<String, dynamic> toUpdateJson() {
    final json = toJson();
    json.remove('id');
    json.remove('created_at');
    json['updated_at'] = DateTime.now().toIso8601String();
    return json;
  }

  @override
  StudyMaterialModel copyWith({
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
    return StudyMaterialModel(
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
}

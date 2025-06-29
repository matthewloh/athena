import 'package:athena/features/chatbot/domain/entities/chat_message_entity.dart';

class FileAttachmentModel extends FileAttachment {
  const FileAttachmentModel({
    required super.id,
    required super.fileName,
    required super.fileSize,
    required super.mimeType,
    required super.storagePath,
    super.thumbnailPath,
    required super.uploadStatus,
    required super.createdAt,
  });

  factory FileAttachmentModel.fromJson(Map<String, dynamic> json) {
    return FileAttachmentModel(
      id: json['id'] as String,
      fileName: json['file_name'] as String,
      fileSize: json['file_size'] as int,
      mimeType: json['mime_type'] as String,
      storagePath: json['storage_path'] as String,
      thumbnailPath: json['thumbnail_path'] as String?,
      uploadStatus: json['upload_status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'file_name': fileName,
      'file_size': fileSize,
      'mime_type': mimeType,
      'storage_path': storagePath,
      'thumbnail_path': thumbnailPath,
      'upload_status': uploadStatus,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson(String messageId) {
    return {
      'message_id': messageId,
      'file_name': fileName,
      'file_size': fileSize,
      'mime_type': mimeType,
      'storage_path': storagePath,
      'thumbnail_path': thumbnailPath,
      'upload_status': uploadStatus,
    };
  }

  @override
  FileAttachmentModel copyWith({
    String? id,
    String? fileName,
    int? fileSize,
    String? mimeType,
    String? storagePath,
    String? thumbnailPath,
    String? uploadStatus,
    DateTime? createdAt,
  }) {
    return FileAttachmentModel(
      id: id ?? this.id,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      mimeType: mimeType ?? this.mimeType,
      storagePath: storagePath ?? this.storagePath,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      uploadStatus: uploadStatus ?? this.uploadStatus,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

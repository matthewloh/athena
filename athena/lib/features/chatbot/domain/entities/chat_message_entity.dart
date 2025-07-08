import 'package:equatable/equatable.dart';
import 'package:athena/features/chatbot/domain/entities/chat_navigation_action.dart';

enum MessageSender { user, ai, system }

class FileAttachment extends Equatable {
  final String id;
  final String fileName;
  final int fileSize;
  final String mimeType;
  final String storagePath;
  final String? thumbnailPath;
  final String uploadStatus;
  final DateTime createdAt;

  const FileAttachment({
    required this.id,
    required this.fileName,
    required this.fileSize,
    required this.mimeType,
    required this.storagePath,
    this.thumbnailPath,
    required this.uploadStatus,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    fileName,
    fileSize,
    mimeType,
    storagePath,
    thumbnailPath,
    uploadStatus,
    createdAt,
  ];

  FileAttachment copyWith({
    String? id,
    String? fileName,
    int? fileSize,
    String? mimeType,
    String? storagePath,
    String? thumbnailPath,
    String? uploadStatus,
    DateTime? createdAt,
  }) {
    return FileAttachment(
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

class ChatMessageEntity extends Equatable {
  final String id;
  final String conversationId;
  final String text;
  final MessageSender sender;
  final DateTime timestamp;
  final Map<String, dynamic>?
  metadata; // For potential future use (e.g., sources, tool calls)
  final List<FileAttachment> attachments;
  final bool hasAttachments;
  final List<ChatNavigationAction> navigationActions;

  const ChatMessageEntity({
    required this.id,
    required this.conversationId,
    required this.text,
    required this.sender,
    required this.timestamp,
    this.metadata,
    this.attachments = const [],
    this.hasAttachments = false,
    this.navigationActions = const [],
  });

  @override
  List<Object?> get props => [
    id,
    conversationId,
    text,
    sender,
    timestamp,
    metadata,
    attachments,
    hasAttachments,
    navigationActions,
  ];

  //copyWith
  ChatMessageEntity copyWith({
    String? id,
    String? conversationId,
    String? text,
    MessageSender? sender,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
    List<FileAttachment>? attachments,
    bool? hasAttachments,
    List<ChatNavigationAction>? navigationActions,
  }) {
    return ChatMessageEntity(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      text: text ?? this.text,
      sender: sender ?? this.sender,
      timestamp: timestamp ?? this.timestamp,
      metadata: metadata ?? this.metadata,
      attachments: attachments ?? this.attachments,
      hasAttachments: hasAttachments ?? this.hasAttachments,
      navigationActions: navigationActions ?? this.navigationActions,
    );
  }
}

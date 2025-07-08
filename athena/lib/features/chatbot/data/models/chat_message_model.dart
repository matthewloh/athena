import 'package:athena/features/chatbot/domain/entities/chat_message_entity.dart';
import 'package:athena/features/chatbot/domain/entities/chat_navigation_action.dart';
import 'package:athena/features/chatbot/data/models/file_attachment_model.dart';

class ChatMessageModel extends ChatMessageEntity {
  final bool isStreaming;
  final bool isComplete;

  const ChatMessageModel({
    required super.id,
    required super.conversationId,
    required super.text,
    required super.sender,
    required super.timestamp,
    super.metadata,
    super.attachments,
    super.hasAttachments,
    super.navigationActions,
    this.isStreaming = false,
    this.isComplete = true,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    MessageSender sender;
    final senderStr = json['sender'] as String?;

    switch (senderStr?.toLowerCase()) {
      case 'user':
        sender = MessageSender.user;
        break;
      case 'ai':
      case 'assistant':
        sender = MessageSender.ai;
        break;
      case 'system':
        sender = MessageSender.system;
        break;
      default:
        throw ArgumentError('Invalid sender type: $senderStr');
    }

    // Parse attachments if present
    final List<FileAttachment> attachments = [];
    if (json['attachments'] != null) {
      final attachmentsList = json['attachments'] as List<dynamic>;
      for (final attachmentJson in attachmentsList) {
        attachments.add(
          FileAttachmentModel.fromJson(attachmentJson as Map<String, dynamic>),
        );
      }
    }

    // Parse navigation actions from direct property or metadata
    final List<ChatNavigationAction> navigationActions = [];
    
    // Check direct property first
    if (json['navigation_actions'] != null) {
      final actionsList = json['navigation_actions'] as List<dynamic>;
      for (final actionJson in actionsList) {
        navigationActions.add(
          ChatNavigationAction.fromJson(actionJson as Map<String, dynamic>),
        );
      }
    } 
    // Check metadata for navigation actions
    else if (json['metadata'] != null) {
      final metadata = json['metadata'] as Map<String, dynamic>;
      if (metadata['navigation_actions'] != null) {
        final actionsList = metadata['navigation_actions'] as List<dynamic>;
        for (final actionJson in actionsList) {
          navigationActions.add(
            ChatNavigationAction.fromJson(actionJson as Map<String, dynamic>),
          );
        }
      }
    }

    return ChatMessageModel(
      id: json['id'] as String,
      conversationId: json['conversation_id'] as String,
      text: json['content'] as String? ?? json['text'] as String,
      sender: sender,
      timestamp: DateTime.parse(json['timestamp'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
      attachments: attachments,
      hasAttachments:
          json['has_attachments'] as bool? ?? attachments.isNotEmpty,
      navigationActions: navigationActions,
      isStreaming: json['is_streaming'] as bool? ?? false,
      isComplete: json['is_complete'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    String senderStr;
    switch (sender) {
      case MessageSender.user:
        senderStr = 'user';
        break;
      case MessageSender.ai:
        senderStr = 'ai';
        break;
      case MessageSender.system:
        senderStr = 'system';
        break;
    }

    return {
      'id': id,
      'conversation_id': conversationId,
      'content': text,
      'sender': senderStr,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata ?? {},
    };
  }

  Map<String, dynamic> toInsertJson() {
    final json = toJson();
    json.remove('id'); // Let database generate ID
    json.remove('timestamp'); // Let database set timestamp
    return json;
  }

  // Factory for creating streaming messages
  factory ChatMessageModel.streaming({
    required String id,
    required String conversationId,
    required String text,
    required MessageSender sender,
    Map<String, dynamic>? metadata,
    List<ChatNavigationAction>? navigationActions,
  }) {
    return ChatMessageModel(
      id: id,
      conversationId: conversationId,
      text: text,
      sender: sender,
      timestamp: DateTime.now(),
      metadata: metadata,
      navigationActions: navigationActions ?? [],
      isStreaming: true,
      isComplete: false,
    );
  }

  // Factory for creating temporary user messages
  factory ChatMessageModel.temporary({
    required String conversationId,
    required String text,
    Map<String, dynamic>? metadata,
    List<FileAttachment>? attachments,
  }) {
    return ChatMessageModel(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      conversationId: conversationId,
      text: text,
      sender: MessageSender.user,
      timestamp: DateTime.now(),
      metadata: metadata,
      attachments: attachments ?? [],
      hasAttachments: (attachments?.isNotEmpty) ?? false,
      navigationActions: [],
      isComplete: false,
    );
  }

  @override
  ChatMessageModel copyWith({
    String? id,
    String? conversationId,
    String? text,
    MessageSender? sender,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
    List<FileAttachment>? attachments,
    bool? hasAttachments,
    List<ChatNavigationAction>? navigationActions,
    bool? isStreaming,
    bool? isComplete,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      text: text ?? this.text,
      sender: sender ?? this.sender,
      timestamp: timestamp ?? this.timestamp,
      metadata: metadata ?? this.metadata,
      attachments: attachments ?? this.attachments,
      hasAttachments: hasAttachments ?? this.hasAttachments,
      navigationActions: navigationActions ?? this.navigationActions,
      isStreaming: isStreaming ?? this.isStreaming,
      isComplete: isComplete ?? this.isComplete,
    );
  }

  // Mark message as complete (stop streaming)
  ChatMessageModel markComplete() {
    return copyWith(isStreaming: false, isComplete: true);
  }

  // Update streaming content
  ChatMessageModel updateStreamingContent(String newText) {
    return copyWith(text: newText, timestamp: DateTime.now());
  }

  @override
  List<Object?> get props => [...super.props, isStreaming, isComplete];
}

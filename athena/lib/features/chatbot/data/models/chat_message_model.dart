import 'package:athena/features/chatbot/domain/entities/chat_message_entity.dart';

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

    return ChatMessageModel(
      id: json['id'] as String,
      conversationId: json['conversation_id'] as String,
      text: json['content'] as String? ?? json['text'] as String,
      sender: sender,
      timestamp: DateTime.parse(json['timestamp'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
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
  }) {
    return ChatMessageModel(
      id: id,
      conversationId: conversationId,
      text: text,
      sender: sender,
      timestamp: DateTime.now(),
      metadata: metadata,
      isStreaming: true,
      isComplete: false,
    );
  }

  // Factory for creating temporary user messages
  factory ChatMessageModel.temporary({
    required String conversationId,
    required String text,
    Map<String, dynamic>? metadata,
  }) {
    return ChatMessageModel(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      conversationId: conversationId,
      text: text,
      sender: MessageSender.user,
      timestamp: DateTime.now(),
      metadata: metadata,
      isComplete: false,
    );
  }

  ChatMessageModel copyWith({
    String? id,
    String? conversationId,
    String? text,
    MessageSender? sender,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
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
      isStreaming: isStreaming ?? this.isStreaming,
      isComplete: isComplete ?? this.isComplete,
    );
  }

  // Mark message as complete (stop streaming)
  ChatMessageModel markComplete() {
    return copyWith(
      isStreaming: false,
      isComplete: true,
    );
  }

  // Update streaming content
  ChatMessageModel updateStreamingContent(String newText) {
    return copyWith(
      text: newText,
      timestamp: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        ...super.props,
        isStreaming,
        isComplete,
      ];
}

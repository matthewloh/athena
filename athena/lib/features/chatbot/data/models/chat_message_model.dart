import 'package:athena/features/chatbot/domain/entities/chat_message_entity.dart';

class ChatMessageModel extends ChatMessageEntity {
  const ChatMessageModel({
    required super.id,
    required super.conversationId,
    required super.text,
    required super.sender,
    required super.timestamp,
    super.metadata,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    MessageSender sender;
    switch (json['sender'] as String?) {
      case 'user':
        sender = MessageSender.user;
        break;
      case 'ai':
        sender = MessageSender.ai;
        break;
      case 'system':
      default:
        sender = MessageSender.system;
        break;
    }

    return ChatMessageModel(
      id: json['id'] as String,
      conversationId: json['conversation_id'] as String,
      text: json['text'] as String,
      sender: sender,
      timestamp: DateTime.parse(json['timestamp'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
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
      'text': text,
      'sender': senderStr,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }
}

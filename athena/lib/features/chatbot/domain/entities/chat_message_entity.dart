import 'package:equatable/equatable.dart';

enum MessageSender { user, ai, system }

class ChatMessageEntity extends Equatable {
  final String id;
  final String conversationId;
  final String text;
  final MessageSender sender;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata; // For potential future use (e.g., sources, tool calls)

  const ChatMessageEntity({
    required this.id,
    required this.conversationId,
    required this.text,
    required this.sender,
    required this.timestamp,
    this.metadata,
  });

  @override
  List<Object?> get props => [id, conversationId, text, sender, timestamp, metadata];

  //copyWith
  ChatMessageEntity copyWith({
    String? id,
    String? conversationId,
    String? text,
    MessageSender? sender,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
  }) {
    return ChatMessageEntity(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      text: text ?? this.text,
      sender: sender ?? this.sender,
      timestamp: timestamp ?? this.timestamp,
      metadata: metadata ?? this.metadata,
    );
  }
} 
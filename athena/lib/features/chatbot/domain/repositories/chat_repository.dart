import 'dart:async';
import 'package:athena/core/errors/failures.dart';
import 'package:athena/features/chatbot/domain/entities/chat_message_entity.dart';
import 'package:athena/features/chatbot/domain/entities/conversation_entity.dart';
import 'package:dartz/dartz.dart';

abstract class ChatRepository {
  // Stream for real-time messages in a specific conversation - Streams typically emit data or errors directly.
  Stream<List<ChatMessageEntity>> getMessagesStream(String conversationId);

  // Send a message (user to AI)
  Future<Either<Failure, void>> sendMessage({
    required String userId,
    required String conversationId,
    required String text,
    Map<String, dynamic>? metadata,
  });

  // Stream for AI responses.
  Stream<Either<Failure, String>> getAiResponseStream(
    String conversationId,
    String lastUserMessage,
  );

  // Get all conversations for the current user
  Future<Either<Failure, List<ConversationEntity>>> getConversations(
    String userId,
  );

  // Create a new conversation
  Future<Either<Failure, ConversationEntity>> createConversation({
    required String userId,
    String? title,
    String? firstMessageText,
  });

  // Get historical messages for a conversation
  Future<Either<Failure, List<ChatMessageEntity>>> getChatHistory(
    String conversationId, {
    DateTime? before,
    int? limit,
  });

  // Update conversation (e.g., title)
  Future<Either<Failure, void>> updateConversation(
    ConversationEntity conversation,
  );

  // Delete conversation
  Future<Either<Failure, void>> deleteConversation(String conversationId);
}

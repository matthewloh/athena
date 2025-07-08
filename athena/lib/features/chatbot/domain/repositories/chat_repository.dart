import 'dart:async';
import 'dart:typed_data';
import 'package:athena/core/errors/failures.dart';
import 'package:athena/features/chatbot/domain/entities/chat_message_entity.dart';
import 'package:athena/features/chatbot/domain/entities/conversation_entity.dart';
import 'package:dartz/dartz.dart';
import 'package:file_picker/file_picker.dart';

abstract class ChatRepository {
  // Stream for real-time messages in a specific conversation - Streams typically emit data or errors directly.
  Stream<List<ChatMessageEntity>> getMessagesStream(String conversationId);

  // Send a message (user to AI)
  Future<Either<Failure, void>> sendMessage({
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
  Future<Either<Failure, List<ConversationEntity>>> getConversations();

  // Create a new conversation
  Future<Either<Failure, ConversationEntity>> createConversation({
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

  // Update conversation title specifically
  Future<Either<Failure, void>> updateConversationTitle(
    String conversationId,
    String newTitle,
  );

  // Delete conversation
  Future<Either<Failure, void>> deleteConversation(String conversationId);

  // File upload methods
  Future<Either<Failure, FileAttachment>> uploadFile({
    required String messageId,
    required PlatformFile file,
  });

  Future<Either<Failure, String>> getFileDownloadUrl(String storagePath);

  Future<Either<Failure, void>> deleteFile(String storagePath);

  Future<Either<Failure, Uint8List?>> generateThumbnail(String storagePath);
}

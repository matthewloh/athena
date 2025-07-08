import 'dart:async';
import 'dart:typed_data';
import 'package:athena/features/chatbot/data/models/chat_message_model.dart';
import 'package:athena/features/chatbot/data/models/conversation_model.dart';
import 'package:athena/features/chatbot/data/models/file_attachment_model.dart';
import 'package:file_picker/file_picker.dart';

abstract class ChatRemoteDataSource {
  Stream<List<ChatMessageModel>> getMessagesStream(String conversationId);
  Future<void> sendMessage({
    required String conversationId,
    required String userId,
    required String text,
    Map<String, dynamic>? metadata,
  });
  Stream<String> getAiResponseStream(
    String conversationId,
    String prompt,
  ); // Prompt for the Edge Function
  Future<List<ConversationModel>> getConversations(String userId);
  Future<ConversationModel> createConversation(
    String userId, {
    String? title,
    String? firstMessageText,
  });
  Future<List<ChatMessageModel>> getChatHistory(
    String conversationId, {
    DateTime? before,
    int? limit,
  });
  Future<void> updateConversation(ConversationModel conversation);
  Future<void> updateConversationTitle(String conversationId, String newTitle);
  Future<void> deleteConversation(String conversationId);

  // File upload methods
  Future<FileAttachmentModel> uploadFile({
    required String messageId,
    required PlatformFile file,
    required String userId,
  });

  Future<String> getFileDownloadUrl(String storagePath);

  Future<void> deleteFile(String storagePath);

  Future<Uint8List?> generateThumbnail(String storagePath);
}

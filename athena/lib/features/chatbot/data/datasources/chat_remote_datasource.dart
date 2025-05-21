import 'dart:async';
import 'package:athena/features/chatbot/data/models/chat_message_model.dart';
import 'package:athena/features/chatbot/data/models/conversation_model.dart';

abstract class ChatRemoteDataSource {
  Stream<List<ChatMessageModel>> getMessagesStream(String conversationId);
  Future<void> sendMessage({
    required String conversationId,
    required String userId,
    required String text,
    Map<String, dynamic>? metadata,
  });
  Stream<String> getAiResponseStream(String conversationId, String prompt); // Prompt for the Edge Function
  Future<List<ConversationModel>> getConversations(String userId);
  Future<ConversationModel> createConversation(String userId, {String? title, String? firstMessageText});
  Future<List<ChatMessageModel>> getChatHistory(String conversationId, {DateTime? before, int? limit});
  Future<void> updateConversation(ConversationModel conversation);
  Future<void> deleteConversation(String conversationId);
} 
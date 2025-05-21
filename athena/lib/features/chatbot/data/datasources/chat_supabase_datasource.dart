// ignore_for_file: avoid_print

import 'dart:async';

import 'package:athena/features/chatbot/data/datasources/chat_remote_datasource.dart';
import 'package:athena/features/chatbot/data/models/chat_message_model.dart';
import 'package:athena/features/chatbot/data/models/conversation_model.dart';

class ChatSupabaseDataSourceImpl implements ChatRemoteDataSource {
  ChatSupabaseDataSourceImpl();

  @override
  Stream<List<ChatMessageModel>> getMessagesStream(String conversationId) {
    // Placeholder: Implement actual Supabase Realtime stream for messages
    // Example: _client.from('chat_messages').stream(primaryKey: ['id']).eq('conversation_id', conversationId).order('timestamp').map((event) => event.map((e) => ChatMessageModel.fromJson(e)).toList());
    print(
      '[ChatSupabaseDataSource] getMessagesStream called for $conversationId',
    );
    return Stream.value([]); // Placeholder
  }

  @override
  Future<void> sendMessage({
    required String conversationId,
    required String userId,
    required String text,
    Map<String, dynamic>? metadata,
  }) async {
    // Placeholder: Insert user message into Supabase 'chat_messages' table
    // This will then trigger the Edge Function to process and respond.
    // await _client.from('chat_messages').insert(messageData);
    print(
      '[ChatSupabaseDataSource] sendMessage called: $text in $conversationId',
    );
  }

  @override
  Stream<String> getAiResponseStream(String conversationId, String prompt) {
    // Placeholder: This will involve invoking a Supabase Edge Function that uses Vercel AI SDK
    // The Edge Function will return a stream of text chunks.
    // For client-side, this might use supabase-dart's functions.invoke with a streaming response type if available,
    // or a custom WebSocket/SSE connection if the Edge Function exposes that.
    // For now, returning a simple stream of the prompt for testing.
    print(
      '[ChatSupabaseDataSource] getAiResponseStream called for $conversationId with prompt: "$prompt"',
    );
    return Stream.periodic(
      const Duration(milliseconds: 100),
      (i) => '$prompt chunk $i',
    ).take(5);
  }

  @override
  Future<List<ConversationModel>> getConversations(String userId) async {
    // Placeholder: Fetch conversations for the user from Supabase 'conversations' table
    // final response = await _client.from('conversations').select().eq('user_id', userId).order('updated_at', ascending: false);
    // return response.map((e) => ConversationModel.fromJson(e)).toList();
    print('[ChatSupabaseDataSource] getConversations called for user $userId');
    return []; // Placeholder
  }

  @override
  Future<ConversationModel> createConversation(
    String userId, {
    String? title,
    String? firstMessageText,
  }) async {
    // Placeholder: Create a new conversation in Supabase 'conversations' table
    // final response = await _client.from('conversations').insert({
    //   'user_id': userId,
    //   'title': title,
    //   // other fields...
    // }).select().single();
    // return ConversationModel.fromJson(response);
    print(
      '[ChatSupabaseDataSource] createConversation called for user $userId with title: $title',
    );
    // Dummy response
    return ConversationModel(
      id: 'new_conv_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      title: title ?? 'New Chat',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<List<ChatMessageModel>> getChatHistory(
    String conversationId, {
    DateTime? before,
    int? limit,
  }) async {
    // Placeholder: Fetch historical messages from Supabase 'chat_messages' table
    // Query query = _client.from('chat_messages').select().eq('conversation_id', conversationId).order('timestamp', ascending: false);
    // if (before != null) query = query.lt('timestamp', before.toIso8601String());
    // if (limit != null) query = query.limit(limit);
    // final response = await query;
    // return response.map((e) => ChatMessageModel.fromJson(e)).toList();
    print('[ChatSupabaseDataSource] getChatHistory called for $conversationId');
    return []; // Placeholder
  }

  @override
  Future<void> updateConversation(ConversationModel conversation) async {
    // Placeholder: Update a conversation in Supabase
    // await _client.from('conversations').update(conversation.toJson()).eq('id', conversation.id);
    print(
      '[ChatSupabaseDataSource] updateConversation called for ${conversation.id}',
    );
  }

  @override
  Future<void> deleteConversation(String conversationId) async {
    // Placeholder: Delete a conversation and its messages (consider cascading delete or a function)
    // await _client.from('conversations').delete().eq('id', conversationId);
    print(
      '[ChatSupabaseDataSource] deleteConversation called for $conversationId',
    );
  }
}

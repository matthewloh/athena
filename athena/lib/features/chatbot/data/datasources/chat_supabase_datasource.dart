// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';

import 'package:athena/core/errors/exceptions.dart';
import 'package:athena/features/chatbot/data/datasources/chat_remote_datasource.dart';
import 'package:athena/features/chatbot/data/models/chat_message_model.dart';
import 'package:athena/features/chatbot/data/models/conversation_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatSupabaseDataSourceImpl implements ChatRemoteDataSource {
  final SupabaseClient _client;

  ChatSupabaseDataSourceImpl(this._client);

  @override
  Stream<List<ChatMessageModel>> getMessagesStream(String conversationId) {
    try {
      return _client
          .from('chat_messages')
          .stream(primaryKey: ['id'])
          .eq('conversation_id', conversationId)
          .order('timestamp', ascending: true)
          .map(
            (data) =>
                data.map((json) => ChatMessageModel.fromJson(json)).toList(),
          );
    } catch (e) {
      throw ServerException('Failed to stream messages: ${e.toString()}');
    }
  }

  @override
  Future<void> sendMessage({
    required String conversationId,
    required String userId,
    required String text,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final messageData =
          ChatMessageModel.temporary(
            conversationId: conversationId,
            text: text,
            metadata: metadata,
          ).toInsertJson();

      await _client.from('chat_messages').insert(messageData).select().single();
    } on PostgrestException catch (e) {
      throw ServerException('Database error: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to send message: ${e.toString()}');
    }
  }

  @override
  Stream<String> getAiResponseStream(String conversationId, String prompt) {
    final controller = StreamController<String>();

    _streamAiResponse(conversationId, prompt, controller);

    return controller.stream;
  }

  Future<void> _streamAiResponse(
    String conversationId,
    String prompt,
    StreamController<String> controller,
  ) async {
    try {
      // Get auth headers from the client
      final authHeaders = <String, String>{
        'Content-Type': 'application/json',
        if (_client.auth.currentSession?.accessToken != null)
          'Authorization': 'Bearer ${_client.auth.currentSession!.accessToken}',
      };

      final response = await _client.functions.invoke(
        'chat-stream',
        body: {
          'conversationId': conversationId,
          'message': prompt,
          'includeContext': true,
          'maxContextMessages': 10,
        },
        headers: authHeaders,
      );

      if (response.status != 200) {
        throw ServerException('Edge function error: ${response.status}');
      }

      // Handle different response types
      final responseData = response.data;

      if (responseData is String) {
        // Parse Server-Sent Events format
        final lines = responseData.split('\n');

        for (final line in lines) {
          if (line.startsWith('data: ')) {
            final jsonStr = line.substring(6).trim();
            if (jsonStr.isEmpty) continue;

            try {
              final data = json.decode(jsonStr) as Map<String, dynamic>;
              final type = data['type'] as String;

              switch (type) {
                case 'chunk':
                  final content = data['content'] as String;
                  controller.add(content);
                  break;
                case 'complete':
                  controller.close();
                  return;
                case 'error':
                  final error = data['error'] as String;
                  controller.addError(
                    ServerException('AI response error: $error'),
                  );
                  return;
              }
            } catch (e) {
              // Skip malformed JSON lines
              continue;
            }
          }
        }
      } else if (responseData is Map<String, dynamic>) {
        // Handle single response (fallback for non-streaming)
        final message = responseData['message'] as String?;
        if (message != null) {
          controller.add(message);
        }
      }

      controller.close();
    } catch (e) {
      // Log error for debugging
      controller.addError(
        ServerException('Failed to stream AI response: ${e.toString()}'),
      );
    }
  }

  @override
  Future<List<ConversationModel>> getConversations(String userId) async {
    try {
      final response = await _client.rpc(
        'get_conversations_with_stats',
        params: {'user_uuid': userId},
      );

      if (response == null) {
        return [];
      }

      return (response as List)
          .map((json) => ConversationModel.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException('Database error: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to get conversations: ${e.toString()}');
    }
  }

  @override
  Future<ConversationModel> createConversation(
    String userId, {
    String? title,
    String? firstMessageText,
  }) async {
    try {
      final conversationData =
          ConversationModel(
            id: '', // Will be generated by database
            userId: userId,
            title: title ?? _generateConversationTitle(firstMessageText),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            metadata: {'created_from_message': firstMessageText != null},
          ).toInsertJson();

      final response =
          await _client
              .from('conversations')
              .insert(conversationData)
              .select()
              .single();

      return ConversationModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException('Database error: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to create conversation: ${e.toString()}');
    }
  }

  @override
  Future<List<ChatMessageModel>> getChatHistory(
    String conversationId, {
    DateTime? before,
    int? limit,
  }) async {
    try {
      var filterQuery = _client
          .from('chat_messages')
          .select()
          .eq('conversation_id', conversationId);

      if (before != null) {
        filterQuery = filterQuery.lt('timestamp', before.toIso8601String());
      }

      var transformQuery = filterQuery.order('timestamp', ascending: false);

      if (limit != null) {
        transformQuery = transformQuery.limit(limit);
      }

      final response = await transformQuery;

      return (response as List)
          .map((json) => ChatMessageModel.fromJson(json))
          .toList()
          .reversed // Return in chronological order
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException('Database error: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to get chat history: ${e.toString()}');
    }
  }

  @override
  Future<void> updateConversation(ConversationModel conversation) async {
    try {
      final updateData = {
        'title': conversation.title,
        'updated_at': DateTime.now().toIso8601String(),
        'metadata': conversation.metadata ?? {},
      };

      await _client
          .from('conversations')
          .update(updateData)
          .eq('id', conversation.id);
    } on PostgrestException catch (e) {
      throw ServerException('Database error: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to update conversation: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteConversation(String conversationId) async {
    try {
      // Messages will be deleted automatically due to CASCADE constraint
      await _client.from('conversations').delete().eq('id', conversationId);
    } on PostgrestException catch (e) {
      throw ServerException('Database error: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to delete conversation: ${e.toString()}');
    }
  }

  // Helper method to generate conversation titles
  String _generateConversationTitle(String? firstMessage) {
    if (firstMessage == null || firstMessage.isEmpty) {
      return 'New Conversation';
    }

    // Extract first few words as title
    final words = firstMessage.split(' ').take(5).join(' ');
    return words.length > 30 ? '${words.substring(0, 27)}...' : words;
  }

  // Additional helper methods for advanced features

  /// Search conversations by title or content
  Future<List<ConversationModel>> searchConversations(
    String userId,
    String query,
  ) async {
    try {
      final response = await _client
          .from('conversations')
          .select()
          .eq('user_id', userId)
          .or('title.ilike.%$query%,last_message_snippet.ilike.%$query%')
          .order('updated_at', ascending: false);

      return (response as List)
          .map((json) => ConversationModel.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException('Database error: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to search conversations: ${e.toString()}');
    }
  }

  /// Get conversation statistics
  Future<Map<String, dynamic>> getConversationStats(String userId) async {
    try {
      final response = await _client.rpc(
        'get_user_chat_stats',
        params: {'user_uuid': userId},
      );

      return response as Map<String, dynamic>;
    } on PostgrestException catch (e) {
      throw ServerException('Database error: ${e.message}');
    } catch (e) {
      throw ServerException(
        'Failed to get conversation stats: ${e.toString()}',
      );
    }
  }
}

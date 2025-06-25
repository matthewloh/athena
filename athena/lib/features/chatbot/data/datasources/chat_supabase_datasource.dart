// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';

import 'package:athena/core/errors/exceptions.dart';
import 'package:athena/features/chatbot/data/datasources/chat_remote_datasource.dart';
import 'package:athena/features/chatbot/data/models/chat_message_model.dart';
import 'package:athena/features/chatbot/data/models/conversation_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;

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
      // Note: We don't save the user message here anymore because
      // the Edge Function will handle saving it when processing the AI response.
      // This prevents the race condition that was causing duplicate messages.

      // The Edge Function is the single source of truth for message persistence.
      // This method now just validates the request and returns success.

      print(
        'SendMessage called - message will be saved by Edge Function: $text',
      );
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
      print('Starting AI response stream for conversation: $conversationId');

      // Get the auth token
      final authToken = _client.auth.currentSession?.accessToken;
      if (authToken == null) {
        throw ServerException('No authentication token available');
      }

      final request = http.Request(
        'POST',
        Uri.parse(
          'https://rbxlzltxpymgioxnhivo.supabase.co/functions/v1/chat-stream',
        ),
      );

      request.headers.addAll({
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      });

      request.body = json.encode({
        'conversationId': conversationId,
        'message': prompt,
        'includeContext': true,
        'maxContextMessages': 10,
      });

      final streamedResponse = await http.Client().send(request);

      print('Edge function response status: ${streamedResponse.statusCode}');

      if (streamedResponse.statusCode != 200) {
        throw ServerException(
          'Edge function error: ${streamedResponse.statusCode}',
        );
      }

      // Handle the streaming response
      String accumulatedData = '';

      await streamedResponse.stream
          .listen(
            (List<int> bytes) {
              final chunk = utf8.decode(bytes);
              accumulatedData += chunk;

              // Process complete lines
              final lines = accumulatedData.split('\n');
              accumulatedData = lines.removeLast(); // Keep incomplete line

              for (final line in lines) {
                _processServerSentEventLine(line, controller);
              }
            },
            onError: (error) {
              print('Stream error: $error');
              controller.addError(
                ServerException('Stream processing error: $error'),
              );
            },
            onDone: () {
              // Process any remaining data
              if (accumulatedData.isNotEmpty) {
                _processServerSentEventLine(accumulatedData, controller);
              }
              if (!controller.isClosed) {
                controller.close();
              }
            },
          )
          .asFuture();
    } catch (e) {
      print('Error in AI response stream: $e');
      controller.addError(
        ServerException('Failed to stream AI response: ${e.toString()}'),
      );
    }
  }

  void _processServerSentEventLine(
    String line,
    StreamController<String> controller,
  ) {
    if (line.startsWith('data: ')) {
      final jsonStr = line.substring(6).trim();
      if (jsonStr.isEmpty) return;

      try {
        final data = json.decode(jsonStr) as Map<String, dynamic>;
        final type = data['type'] as String;

        switch (type) {
          case 'chunk':
            final content = data['content'] as String;
            print('Received chunk: $content');
            controller.add(content);
            break;
          case 'complete':
            print('Stream completed');
            if (!controller.isClosed) {
              controller.close();
            }
            break;
          case 'error':
            final error = data['error'] as String;
            print('Stream error: $error');
            controller.addError(ServerException('AI response error: $error'));
            break;
        }
      } catch (e) {
        print('Failed to parse SSE line: $line, error: $e');
        // Skip malformed JSON lines
      }
    }
  }

  @override
  Future<List<ConversationModel>> getConversations(String userId) async {
    try {
      print(
        'ChatSupabaseDataSourceImpl: Calling RPC get_conversations_with_stats for userId: $userId',
      );
      final response = await _client.rpc(
        'get_conversations_with_stats',
        params: {'user_uuid': userId},
      );

      print('ChatSupabaseDataSourceImpl: RPC response raw: $response');

      if (response == null) {
        print('ChatSupabaseDataSourceImpl: RPC response is null.');
        return [];
      }

      if (response is! List) {
        print(
          'ChatSupabaseDataSourceImpl: RPC response is not a List. Type: ${response.runtimeType}',
        );
        throw ServerException(
          'Unexpected response type from RPC: ${response.runtimeType}',
        );
      }

      if (response.isEmpty) {
        print('ChatSupabaseDataSourceImpl: RPC response is an empty list.');
        return [];
      }

      final List<ConversationModel> conversations = [];
      for (var jsonItem in response) {
        try {
          if (jsonItem is Map<String, dynamic>) {
            // Crucial check: Ensure user_id is present before parsing, or handle its absence
            // For now, we'll let fromJson handle it and catch, but this is where you'd know it's missing
            if (jsonItem['user_id'] == null) {
              print(
                'ChatSupabaseDataSourceImpl: item JSON is missing user_id: $jsonItem',
              );
            }
            conversations.add(ConversationModel.fromJson(jsonItem));
          } else {
            print(
              'ChatSupabaseDataSourceImpl: Skipping non-map item in RPC response: $jsonItem',
            );
          }
        } catch (e, s) {
          print(
            'ChatSupabaseDataSourceImpl: Error parsing conversation JSON item: $jsonItem. Error: $e. Stacktrace: $s',
          );
          // Decide if you want to skip this item or rethrow
        }
      }
      print(
        'ChatSupabaseDataSourceImpl: Successfully parsed ${conversations.length} conversations.',
      );
      return conversations;
    } on PostgrestException catch (e) {
      print(
        'ChatSupabaseDataSourceImpl: PostgrestException: ${e.message}, details: ${e.details}, code: ${e.code}',
      );
      throw ServerException('Database error: ${e.message}');
    } catch (e, s) {
      print(
        'ChatSupabaseDataSourceImpl: Generic error in getConversations: $e. Stacktrace: $s',
      );
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
      var query = _client
          .from('chat_messages')
          .select()
          .eq('conversation_id', conversationId)
          .order('timestamp', ascending: false);

      if (limit != null) {
        query = query.limit(limit);
      }

      final response = await query;

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

import 'dart:async';

import 'package:athena/core/errors/exceptions.dart';
import 'package:athena/core/errors/failures.dart';
import 'package:athena/core/providers/auth_provider.dart';
import 'package:athena/features/chatbot/data/datasources/chat_remote_datasource.dart';
import 'package:athena/features/chatbot/data/models/conversation_model.dart'; // Required for casting
import 'package:athena/features/chatbot/domain/entities/chat_message_entity.dart';
import 'package:athena/features/chatbot/domain/entities/conversation_entity.dart';
import 'package:athena/features/chatbot/domain/repositories/chat_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartz/dartz.dart';
// ignore: depend_on_referenced_packages

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource _remoteDataSource;
  final Ref _ref; // For accessing current user ID

  ChatRepositoryImpl(this._remoteDataSource, this._ref);

  String _getCurrentUserId() {
    final user = _ref.read(appAuthProvider).valueOrNull;
    if (user == null) {
      throw const AuthException('User not authenticated.', statusCode: '401');
    }
    return user.id;
  }

  @override
  Stream<List<ChatMessageEntity>> getMessagesStream(String conversationId) {
    try {
      return _remoteDataSource.getMessagesStream(conversationId);
    } catch (e) {
      // Convert to a stream of error if direct stream throwing isn't handled well by UI
      return Stream.error(
        ServerFailure('Failed to stream messages: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> sendMessage({
    required String conversationId,
    required String text,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final userId = _getCurrentUserId();
      await _remoteDataSource.sendMessage(
        conversationId: conversationId,
        userId: userId,
        text: text,
        metadata: metadata,
      );
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(
        ServerFailure('An unexpected error occurred: ${e.toString()}'),
      );
    }
  }

  @override
  Stream<Either<Failure, String>> getAiResponseStream(
    String conversationId,
    String lastUserMessage,
  ) {
    // Note: Changed signature to include lastUserMessage which will be the prompt
    try {
      // The remote data source should handle invoking the edge function
      // The edge function takes the conversationId (for context) and the lastUserMessage as prompt
      return _remoteDataSource
          .getAiResponseStream(conversationId, lastUserMessage)
          .map((chunk) => Right<Failure, String>(chunk))
          .handleError((error) {
            // It's better to catch specific errors if possible
            if (error is ServerException) {
              return Left<Failure, String>(ServerFailure(error.message));
            }
            return Left<Failure, String>(
              ServerFailure('Streaming error: ${error.toString()}'),
            );
          });
    } catch (e) {
      // This catch is for immediate errors during stream setup
      return Stream.value(
        Left<Failure, String>(
          ServerFailure('Failed to setup AI response stream: ${e.toString()}'),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<ConversationEntity>>> getConversations() async {
    try {
      final userId = _getCurrentUserId();
      final conversations = await _remoteDataSource.getConversations(userId);
      return Right(conversations);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(
        ServerFailure('An unexpected error occurred: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, ConversationEntity>> createConversation({
    String? title,
    String? firstMessageText,
  }) async {
    try {
      final userId = _getCurrentUserId();
      final conversation = await _remoteDataSource.createConversation(
        userId,
        title: title,
        firstMessageText:
            firstMessageText, // This might be sent to Edge Function
      );
      // If there's a firstMessageText, send it after creating the conversation
      if (firstMessageText != null && firstMessageText.isNotEmpty) {
        await sendMessage(
          conversationId: conversation.id,
          text: firstMessageText,
        );
      }
      return Right(conversation);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(
        ServerFailure('An unexpected error occurred: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, List<ChatMessageEntity>>> getChatHistory(
    String conversationId, {
    DateTime? before,
    int? limit,
  }) async {
    try {
      final messages = await _remoteDataSource.getChatHistory(
        conversationId,
        before: before,
        limit: limit,
      );
      return Right(messages);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(
        ServerFailure('An unexpected error occurred: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> updateConversation(
    ConversationEntity conversation,
  ) async {
    try {
      if (conversation is! ConversationModel) {
         //This is a simplistic conversion, real one might need more logic or a factory in model
        final model = ConversationModel(
          id: conversation.id,
          userId: conversation.userId,
          title: conversation.title,
          createdAt: conversation.createdAt,
          updatedAt: conversation.updatedAt,
          lastMessageSnippet: conversation.lastMessageSnippet
        );
        await _remoteDataSource.updateConversation(model);
      } else {
        await _remoteDataSource.updateConversation(conversation);
      }
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(
        ServerFailure('An unexpected error occurred: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> deleteConversation(
    String conversationId,
  ) async {
    try {
      await _remoteDataSource.deleteConversation(conversationId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(
        ServerFailure('An unexpected error occurred: ${e.toString()}'),
      );
    }
  }

  // getAiResponseStream needs to be adapted if the ChatRepository interface changes.
  // For now, assuming ChatRepository expects Stream<String> directly for AI responses.
  // If it needs to return Either<Failure, Stream<String>>, this implementation would need adjustment.
}

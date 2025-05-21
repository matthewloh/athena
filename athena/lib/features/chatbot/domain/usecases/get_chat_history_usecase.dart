import 'package:athena/core/errors/failures.dart';
import 'package:athena/features/chatbot/domain/entities/chat_message_entity.dart';
import 'package:athena/features/chatbot/domain/repositories/chat_repository.dart';
import 'package:dartz/dartz.dart';

class GetChatHistoryUseCase {
  final ChatRepository repository;

  GetChatHistoryUseCase(this.repository);

  Future<Either<Failure, List<ChatMessageEntity>>> call(String conversationId, {DateTime? before, int? limit}) {
    return repository.getChatHistory(conversationId, before: before, limit: limit);
  }
} 
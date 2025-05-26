import 'package:athena/core/errors/failures.dart';
import 'package:athena/features/chatbot/domain/entities/conversation_entity.dart';
import 'package:athena/features/chatbot/domain/repositories/chat_repository.dart';
import 'package:dartz/dartz.dart';

class GetConversationsUseCase {
  final ChatRepository repository;

  GetConversationsUseCase(this.repository);

  Future<Either<Failure, List<ConversationEntity>>> call(String userId) {
    return repository.getConversations(userId);
  }
}

import 'package:athena/core/errors/failures.dart';
import 'package:athena/features/chatbot/domain/entities/conversation_entity.dart';
import 'package:athena/features/chatbot/domain/repositories/chat_repository.dart';
import 'package:dartz/dartz.dart';

class CreateConversationUseCase {
  final ChatRepository repository;

  CreateConversationUseCase(this.repository);

  Future<Either<Failure, ConversationEntity>> call({
    String? title,
    String? firstMessageText,
  }) {
    return repository.createConversation(
      title: title,
      firstMessageText: firstMessageText,
    );
  }
}

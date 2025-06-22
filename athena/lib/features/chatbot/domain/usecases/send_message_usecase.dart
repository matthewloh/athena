import 'package:athena/core/errors/failures.dart';
import 'package:athena/features/chatbot/domain/repositories/chat_repository.dart';
import 'package:dartz/dartz.dart';

class SendMessageUseCase {
  final ChatRepository repository;

  SendMessageUseCase(this.repository);

  Future<Either<Failure, void>> call({
<<<<<<< HEAD
    required String userId,
=======
>>>>>>> 5c773fd1b1b3cf86226be86f597a1f7c26919e81
    required String conversationId,
    required String text,
    Map<String, dynamic>? metadata,
  }) {
    return repository.sendMessage(
      userId: userId,
      conversationId: conversationId,
      text: text,
      metadata: metadata,
    );
  }
}

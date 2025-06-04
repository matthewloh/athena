import 'package:athena/core/errors/failures.dart';
import 'package:athena/features/chatbot/domain/repositories/chat_repository.dart';
import 'package:dartz/dartz.dart';

class SendMessageUseCase {
  final ChatRepository repository;

  SendMessageUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String conversationId,
    required String text,
    Map<String, dynamic>? metadata,
  }) {
    return repository.sendMessage(
      conversationId: conversationId,
      text: text,
      metadata: metadata,
    );
  }
} 
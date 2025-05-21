import 'package:athena/features/chatbot/domain/repositories/chat_repository.dart';

class SendMessageUseCase {
  final ChatRepository repository;

  SendMessageUseCase(this.repository);

  Future<void> call({
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
import 'package:athena/features/chatbot/data/datasources/chat_supabase_datasource.dart';
import 'package:athena/features/chatbot/data/repositories/chat_repository_impl.dart';
import 'package:athena/features/chatbot/domain/repositories/chat_repository.dart';
import 'package:athena/features/chatbot/domain/usecases/create_conversation_usecase.dart';
import 'package:athena/features/chatbot/domain/usecases/get_chat_history_usecase.dart';
import 'package:athena/features/chatbot/domain/usecases/get_conversations_usecase.dart';
import 'package:athena/features/chatbot/domain/usecases/send_message_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'chat_providers.g.dart';

// DataSources
@riverpod
ChatSupabaseDataSourceImpl chatSupabaseDataSource(Ref ref) {
  return ChatSupabaseDataSourceImpl();
}

// Repositories
@riverpod
ChatRepository chatRepository(Ref ref) {
  return ChatRepositoryImpl(ref.watch(chatSupabaseDataSourceProvider), ref);
}

// Usecases
@riverpod
SendMessageUseCase sendMessageUseCase(Ref ref) {
  return SendMessageUseCase(ref.watch(chatRepositoryProvider));
}

@riverpod
GetChatHistoryUseCase getChatHistoryUseCase(Ref ref) {
  return GetChatHistoryUseCase(ref.watch(chatRepositoryProvider));
}

@riverpod
GetConversationsUseCase getConversationsUseCase(Ref ref) {
  return GetConversationsUseCase(ref.watch(chatRepositoryProvider));
}

@riverpod
CreateConversationUseCase createConversationUseCase(Ref ref) {
  return CreateConversationUseCase(ref.watch(chatRepositoryProvider));
}

// ViewModel
@riverpod
class ChatViewModel extends _$ChatViewModel {
  // TODO: Implement ChatViewModel logic
  @override
  Future<void> build() async {
    // Initial data loading if any
  }

  // Example method
  // Future<void> sendMessage(String text) async {
  //   state = const AsyncValue.loading();
  //   state = await AsyncValue.guard(() async {
  //     // Call usecase
  //   });
  // }
}

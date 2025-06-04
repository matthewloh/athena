import 'package:athena/core/providers/supabase_providers.dart';
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
  final supabaseClient = ref.watch(supabaseClientProvider);
  return ChatSupabaseDataSourceImpl(supabaseClient);
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

// Additional Use Cases for enhanced functionality

@riverpod
Future<void> updateConversation(Ref ref, String conversationId, {String? title}) async {
  // Implementation would go here - for now just a placeholder
  // This would call repository.updateConversation with the new data
}

@riverpod
Future<void> deleteConversation(Ref ref, String conversationId) async {
  final result = await ref.read(chatRepositoryProvider).deleteConversation(conversationId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (_) => null,
  );
}

@riverpod
Future<List<dynamic>> searchConversations(Ref ref, String query) async {
  // Implementation would use the enhanced data source search method
  return [];
}

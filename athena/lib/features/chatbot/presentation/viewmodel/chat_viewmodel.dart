import 'dart:async'; // Added for StreamSubscription
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:athena/features/chatbot/domain/entities/chat_message_entity.dart';
import 'package:athena/features/chatbot/domain/entities/conversation_entity.dart';
import 'package:athena/features/chatbot/presentation/providers/chat_providers.dart';
import 'package:athena/core/errors/failures.dart'; // For Failure type
import 'package:dartz/dartz.dart'; // For Either type

part 'chat_viewmodel.g.dart';

@riverpod
class ChatViewModel extends _$ChatViewModel {
  // Holds the current active conversation ID
  String? _activeConversationId;

  // Stream subscription for AI responses
  StreamSubscription<Either<Failure, String>>? _aiResponseSubscription;

  @override
  Future<ChatState> build() async {
    // Assuming getConversationsUseCaseProvider.call() returns Future<Either<Failure, List<ConversationEntity>>>
    final Either<Failure, List<ConversationEntity>> result =
        await ref.read(getConversationsUseCaseProvider).call();

    return result.fold(
      (Failure failure) {
        // Construct a valid ChatState indicating an error, Riverpod will wrap it in AsyncError if build throws.
        // Or, if we want build to succeed but ChatState to hold the error:
        return ChatState(
          conversations: [],
          currentMessages: [],
          isLoading: false,
          error: ChatError(
            'Failed to load initial conversations: ${failure.message}',
          ),
          isReceivingAiResponse: false,
        );
      },
      (List<ConversationEntity> conversations) => ChatState(
        conversations: conversations,
        currentMessages: [],
        isLoading: false,
        error: null,
        isReceivingAiResponse: false,
      ),
    );
    // The outer try-catch might be removed if all errors are handled by Either
    // and we want build to throw for Riverpod to catch.
    // For now, if fold results in a state that represents an error, that's fine.
    // If fold itself throws an unhandled error, Riverpod catches it.
  }

  Future<void> loadConversations() async {
    final previousState = state.valueOrNull ?? _initialChatState();
    state = AsyncLoading<ChatState>().copyWithPrevious(
      AsyncData(previousState.copyWith(isLoading: true, clearError: true)),
    );
    try {
      final Either<Failure, List<ConversationEntity>> result =
          await ref.read(getConversationsUseCaseProvider).call();

      result.fold(
        (Failure failure) {
          state = AsyncData(
            previousState.copyWith(
              isLoading: false,
              error: ChatError(
                'Failed to load conversations: ${failure.message}',
              ),
            ),
          );
        },
        (List<ConversationEntity> data) {
          state = AsyncData(
            previousState.copyWith(conversations: data, isLoading: false),
          );
        },
      );
    } catch (e) {
      state = AsyncData(
        previousState.copyWith(
          isLoading: false,
          error: ChatError('Failed to load conversations: ${e.toString()}'),
        ),
      );
    }
  }

  ChatState _initialChatState() {
    return ChatState(
      conversations: [],
      currentMessages: [],
      isLoading: false,
      isReceivingAiResponse: false,
    );
  }

  Future<void> createNewConversation({
    String? title,
    String? firstMessageText,
  }) async {
    final previousState = state.valueOrNull ?? _initialChatState();
    state = AsyncLoading<ChatState>().copyWithPrevious(
      AsyncData(previousState.copyWith(isLoading: true, clearError: true)),
    );

    try {
      final Either<Failure, ConversationEntity> result = await ref
          .read(createConversationUseCaseProvider)
          .call(title: title, firstMessageText: firstMessageText);

      result.fold(
        (Failure failure) {
          state = AsyncData(
            previousState.copyWith(
              isLoading: false,
              error: ChatError(
                'Failed to create conversation: ${failure.message}',
              ),
            ),
          );
        },
        (ConversationEntity newConversation) {
          final updatedConversations = [
            newConversation,
            ...previousState.conversations,
          ];
          setActiveConversation(
            newConversation.id,
            newConversationsList: updatedConversations,
          );
          // Optionally, update state here if setActiveConversation doesn't cover all immediate changes
          // For example, to stop a global loading indicator for 'creating' specifically.
          // For now, relying on setActiveConversation to update the broader state.
        },
      );
    } catch (e) {
      state = AsyncData(
        previousState.copyWith(
          isLoading: false,
          error: ChatError('Failed to create conversation: ${e.toString()}'),
        ),
      );
    }
  }

  Future<void> setActiveConversation(
    String conversationId, {
    List<ConversationEntity>? newConversationsList,
  }) async {
    _activeConversationId = conversationId;
    _aiResponseSubscription?.cancel();

    ChatState initialData;
    if (newConversationsList != null) {
      initialData = (state.valueOrNull?.copyWith(
                conversations: newConversationsList,
              ) ??
              _initialChatState().copyWith(conversations: newConversationsList))
          .copyWith(
            isLoading: true,
            currentMessages: [],
            error: null,
            clearError: true,
          );
    } else {
      initialData = (state.valueOrNull ?? _initialChatState()).copyWith(
        isLoading: true,
        currentMessages: [],
        error: null,
        clearError: true,
      );
    }
    state = AsyncData(initialData);

    // Assuming getChatHistoryUseCaseProvider.call() returns Future<Either<Failure, List<ChatMessageEntity>>>
    final Either<Failure, List<ChatMessageEntity>> result = await ref
        .read(getChatHistoryUseCaseProvider)
        .call(conversationId);

    result.fold(
      (Failure failure) {
        state = AsyncData(
          initialData.copyWith(
            // Use initialData as base to avoid losing conversation list if it was just updated
            isLoading: false,
            error: ChatError('Failed to load messages: ${failure.message}'),
          ),
        );
      },
      (List<ChatMessageEntity> messages) {
        state = AsyncData(
          initialData.copyWith(
            currentMessages: messages,
            isLoading: false,
            error: null,
          ),
        );
        if (messages.isNotEmpty &&
            messages.last.sender == MessageSender.user &&
            !(state.valueOrNull?.isReceivingAiResponse ?? false)) {
          _listenToAiResponse(conversationId, messages.last.text);
        }
      },
    );
    // Removed try-catch as Either should handle failure cases
  }

  Future<void> sendMessage(String text) async {
    if (_activeConversationId == null) {
      state = AsyncData(
        (state.valueOrNull ?? _initialChatState()).copyWith(
          error: ChatError('No active conversation selected'),
        ),
      );
      return;
    }
    final tempId = DateTime.now().millisecondsSinceEpoch.toString();
    final userMessage = ChatMessageEntity(
      id: tempId,
      conversationId: _activeConversationId!,
      text: text,
      sender: MessageSender.user,
      timestamp: DateTime.now(),
    );

    final previousStateValue = state.valueOrNull ?? _initialChatState();
    state = AsyncData(
      previousStateValue.copyWith(
        currentMessages: [...previousStateValue.currentMessages, userMessage],
        clearError: true,
      ),
    );

    try {
      await ref
          .read(sendMessageUseCaseProvider)
          .call(conversationId: _activeConversationId!, text: text);
      // If successful, listen to AI response
      _listenToAiResponse(_activeConversationId!, text);
    } catch (e) {
      final revertedMessages =
          state.valueOrNull?.currentMessages
              .where((m) => m.id != tempId)
              .toList() ??
          [];
      state = AsyncData(
        (state.valueOrNull ?? _initialChatState()).copyWith(
          currentMessages: revertedMessages,
          error: ChatError('Failed to send message: ${e.toString()}'),
        ),
      );
    }
  }

  void _listenToAiResponse(String conversationId, String lastUserMessage) {
    _aiResponseSubscription?.cancel();
    final previousStateValue = state.valueOrNull ?? _initialChatState();
    state = AsyncData(
      previousStateValue.copyWith(
        isReceivingAiResponse: true,
        clearError: true,
      ),
    );

    final aiStream = ref
        .read(chatRepositoryProvider)
        .getAiResponseStream(conversationId, lastUserMessage);

    String currentAiText = '';
    String? aiMessageId;

    _aiResponseSubscription = aiStream.listen(
      (Either<Failure, String> eitherChunk) {
        final currentChatState = state.valueOrNull ?? _initialChatState();
        eitherChunk.fold(
          (Failure failure) {
            state = AsyncData(
              currentChatState.copyWith(
                isReceivingAiResponse: false,
                error: ChatError('AI response error: ${failure.message}'),
              ),
            );
            _aiResponseSubscription?.cancel();
          },
          (String chunk) {
            currentAiText += chunk;
            List<ChatMessageEntity> updatedMessages;
            if (aiMessageId == null) {
              aiMessageId =
                  'ai_${DateTime.now().millisecondsSinceEpoch.toString()}';
              final aiMessage = ChatMessageEntity(
                id: aiMessageId!,
                conversationId: conversationId,
                text: currentAiText,
                sender: MessageSender.ai,
                timestamp: DateTime.now(),
              );
              updatedMessages = [
                ...currentChatState.currentMessages,
                aiMessage,
              ];
            } else {
              updatedMessages =
                  currentChatState.currentMessages.map((m) {
                    return m.id == aiMessageId
                        ? m.copyWith(
                          text: currentAiText,
                          timestamp: DateTime.now(),
                        )
                        : m;
                  }).toList();
            }
            state = AsyncData(
              currentChatState.copyWith(currentMessages: updatedMessages),
            );
          },
        );
      },
      onError: (error, stackTrace) {
        final currentChatState = state.valueOrNull ?? _initialChatState();
        state = AsyncData(
          currentChatState.copyWith(
            isReceivingAiResponse: false,
            error: ChatError('AI stream error: ${error.toString()}'),
          ),
        );
      },
      onDone: () {
        final currentChatState = state.valueOrNull ?? _initialChatState();
        state = AsyncData(
          currentChatState.copyWith(isReceivingAiResponse: false),
        );
        if (currentAiText.isNotEmpty) {
          _updateConversationDetails(conversationId, currentAiText);
        }
      },
      cancelOnError: true,
    );
  }

  Future<void> _updateConversationDetails(
    String conversationId,
    String lastMessageText,
  ) async {
    final currentChatState = state.valueOrNull;
    if (currentChatState == null) return;

    final targetConversationIndex = currentChatState.conversations.indexWhere(
      (c) => c.id == conversationId,
    );
    if (targetConversationIndex == -1) return;

    final targetConversation =
        currentChatState.conversations[targetConversationIndex];
    final updatedConversation = targetConversation.copyWith(
      lastMessageSnippet:
          lastMessageText.length > 100
              ? '${lastMessageText.substring(0, 97)}...'
              : lastMessageText,
      updatedAt: DateTime.now(),
    );

    final newList = List<ConversationEntity>.from(
      currentChatState.conversations,
    );
    newList[targetConversationIndex] = updatedConversation;
    state = AsyncData(currentChatState.copyWith(conversations: newList));
  }
}

// Helper class for state
class ChatState {
  final List<ConversationEntity> conversations;
  final List<ChatMessageEntity> currentMessages;
  final bool isLoading;
  final ChatError? error;
  final bool isReceivingAiResponse;

  ChatState({
    required this.conversations,
    required this.currentMessages,
    this.isLoading = false,
    this.error,
    this.isReceivingAiResponse = false,
  });

  ChatState copyWith({
    List<ConversationEntity>? conversations,
    List<ChatMessageEntity>? currentMessages,
    bool? isLoading,
    ChatError? error,
    bool? clearError,
    bool? isReceivingAiResponse,
  }) {
    return ChatState(
      conversations: conversations ?? this.conversations,
      currentMessages: currentMessages ?? this.currentMessages,
      isLoading: isLoading ?? this.isLoading,
      error: clearError == true ? null : error ?? this.error,
      isReceivingAiResponse:
          isReceivingAiResponse ?? this.isReceivingAiResponse,
    );
  }
}

class ChatError {
  final String message;
  ChatError(this.message);

  @override
  String toString() => message;
}

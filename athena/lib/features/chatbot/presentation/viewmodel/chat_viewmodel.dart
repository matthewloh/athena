import 'dart:async'; // Added for StreamSubscription
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:athena/features/chatbot/domain/entities/chat_message_entity.dart';
import 'package:athena/features/chatbot/domain/entities/conversation_entity.dart';
import 'package:athena/features/chatbot/presentation/providers/chat_providers.dart';
import 'package:athena/core/errors/failures.dart'; // For Failure type
import 'package:athena/core/providers/auth_provider.dart'; // For getting current user
import 'package:dartz/dartz.dart'; // For Either type
import 'package:flutter/foundation.dart'; // For debugPrint

part 'chat_viewmodel.g.dart';

@riverpod
class ChatViewModel extends _$ChatViewModel {
  // Holds the current active conversation ID
  String? _activeConversationId;

  // Stream subscription for AI responses
  StreamSubscription<Either<Failure, String>>? _aiResponseSubscription;

  // Stream subscription for real-time message updates
  StreamSubscription<List<ChatMessageEntity>>? _messagesSubscription;

  // Helper method to get current user ID
  String? _getCurrentUserId() {
    final user = ref.read(appAuthProvider).valueOrNull;
    return user?.id;
  }

  @override
  Future<ChatState> build() async {
    // Clean up subscriptions when the provider is disposed
    ref.onDispose(() {
      _aiResponseSubscription?.cancel();
      _messagesSubscription?.cancel();
    });

    // Assuming getConversationsUseCaseProvider.call() returns Future<Either<Failure, List<ConversationEntity>>>
    final userId = _getCurrentUserId();
    if (userId == null) {
      return ChatState(
        conversations: [],
        currentMessages: [],
        isLoading: false,
        error: ChatError('User not authenticated'),
        isReceivingAiResponse: false,
      );
    }

    final Either<Failure, List<ConversationEntity>> result = await ref
        .read(getConversationsUseCaseProvider)
        .call(userId);

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
      final userId = _getCurrentUserId();
      if (userId == null) {
        state = AsyncData(
          previousState.copyWith(
            isLoading: false,
            error: ChatError('User not authenticated'),
          ),
        );
        return;
      }

      final Either<Failure, List<ConversationEntity>> result = await ref
          .read(getConversationsUseCaseProvider)
          .call(userId);

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
      final userId = _getCurrentUserId();
      if (userId == null) {
        state = AsyncData(
          previousState.copyWith(
            isLoading: false,
            error: ChatError('User not authenticated'),
          ),
        );
        return;
      }

      final Either<Failure, ConversationEntity> result = await ref
          .read(createConversationUseCaseProvider)
          .call(
            userId: userId,
            title: title,
            firstMessageText: firstMessageText,
          );

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
    _messagesSubscription?.cancel();

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

        // Start listening to real-time message updates
        _startMessagesStream(conversationId);

        if (messages.isNotEmpty &&
            messages.last.sender == MessageSender.user &&
            !(state.valueOrNull?.isReceivingAiResponse ?? false)) {
          _listenToAiResponse(conversationId, messages.last.text);
        }
      },
    );
    // Removed try-catch as Either should handle failure cases
  }

  Future<void> sendMessageOrCreateConversation(String text) async {
    debugPrint('🚀 sendMessageOrCreateConversation called with: "$text"');
    debugPrint('🔍 _activeConversationId: $_activeConversationId');

    if (text.trim().isEmpty) {
      debugPrint('❌ Message is empty, ignoring');
      return;
    }

    if (_activeConversationId == null) {
      debugPrint('💬 No active conversation, creating new one...');
      // Auto-create conversation and send message - industry standard UX
      await _createConversationAndSendMessage(text);
    } else {
      debugPrint('💬 Sending to existing conversation: $_activeConversationId');
      // Send message to existing conversation
      await sendMessage(text);
    }
  }

  Future<void> _createConversationAndSendMessage(String text) async {
    debugPrint('🏗️ Creating conversation and sending message: "$text"');

    final userId = _getCurrentUserId();
    debugPrint('👤 User ID: $userId');

    if (userId == null) {
      debugPrint('❌ User not authenticated');
      state = AsyncData(
        (state.valueOrNull ?? _initialChatState()).copyWith(
          error: ChatError('User not authenticated'),
        ),
      );
      return;
    }

    // Show loading state
    final previousStateValue = state.valueOrNull ?? _initialChatState();
    state = AsyncData(
      previousStateValue.copyWith(isLoading: true, clearError: true),
    );

    // Create conversation with the first message
    final result = await ref
        .read(createConversationUseCaseProvider)
        .call(
          userId: userId,
          title: _generateConversationTitle(text),
          firstMessageText: text,
        );

    result.fold(
      (failure) {
        debugPrint('❌ Failed to create conversation: ${failure.message}');
        state = AsyncData(
          previousStateValue.copyWith(
            isLoading: false,
            error: ChatError(
              'Failed to create conversation: ${failure.message}',
            ),
          ),
        );
      },
      (conversation) {
        debugPrint('✅ Conversation created successfully: ${conversation.id}');
        // Set as active conversation and load messages
        _activeConversationId = conversation.id;
        final updatedConversations = [
          conversation,
          ...previousStateValue.conversations,
        ];

        // Update state with new conversation and clear loading
        state = AsyncData(
          previousStateValue.copyWith(
            conversations: updatedConversations,
            isLoading: false,
            clearError: true,
          ),
        );

        debugPrint('🔄 Setting active conversation: ${conversation.id}');
        // Load messages for the new conversation
        setActiveConversation(
          conversation.id,
          newConversationsList: updatedConversations,
        );
      },
    );
  }

  String _generateConversationTitle(String firstMessage) {
    if (firstMessage.isEmpty) return 'New Conversation';

    // Extract first few words as title
    final words = firstMessage.split(' ').take(5).join(' ');
    return words.length > 30 ? '${words.substring(0, 27)}...' : words;
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

    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final userMessage = ChatMessageEntity(
      id: tempId,
      conversationId: _activeConversationId!,
      text: text,
      sender: MessageSender.user,
      timestamp: DateTime.now(),
    );

    // Immediately show user message for instant feedback
    final previousStateValue = state.valueOrNull ?? _initialChatState();
    state = AsyncData(
      previousStateValue.copyWith(
        currentMessages: [...previousStateValue.currentMessages, userMessage],
        clearError: true,
      ),
    );

    final userId = _getCurrentUserId();
    if (userId == null) {
      state = AsyncData(
        (state.valueOrNull ?? _initialChatState()).copyWith(
          error: ChatError('User not authenticated'),
        ),
      );
      return;
    }

    final result = await ref
        .read(sendMessageUseCaseProvider)
        .call(
          userId: userId,
          conversationId: _activeConversationId!,
          text: text,
        );

    result.fold(
      (failure) {
        // Remove temp message on failure
        final revertedMessages =
            state.valueOrNull?.currentMessages
                .where((m) => m.id != tempId)
                .toList() ??
            [];
        state = AsyncData(
          (state.valueOrNull ?? _initialChatState()).copyWith(
            currentMessages: revertedMessages,
            error: ChatError('Failed to send message: ${failure.message}'),
          ),
        );
      },
      (_) {
        // Replace temp message with permanent ID and start AI response
        _listenToAiResponse(_activeConversationId!, text);
      },
    );
  }

  void _startMessagesStream(String conversationId) {
    _messagesSubscription?.cancel();

    final messagesStream = ref
        .read(chatRepositoryProvider)
        .getMessagesStream(conversationId);

    _messagesSubscription = messagesStream.listen(
      (messages) {
        final currentChatState = state.valueOrNull;
        if (currentChatState != null &&
            !currentChatState.isReceivingAiResponse) {
          // Only update if not currently receiving AI response to avoid conflicts
          state = AsyncData(
            currentChatState.copyWith(currentMessages: messages),
          );
        }
      },
      onError: (error) {
        // Log error for debugging
        debugPrint('Messages stream error: $error');
        // Don't update state on stream errors to avoid interrupting user experience
      },
    );
  }

  void _listenToAiResponse(String conversationId, String lastUserMessage) {
    _aiResponseSubscription?.cancel();
    final previousStateValue = state.valueOrNull ?? _initialChatState();

    // Add typing indicator immediately
    final typingIndicatorId = 'typing_${DateTime.now().millisecondsSinceEpoch}';
    final typingMessage = ChatMessageEntity(
      id: typingIndicatorId,
      conversationId: conversationId,
      text: '●●●', // Typing indicator
      sender: MessageSender.ai,
      timestamp: DateTime.now(),
    );

    state = AsyncData(
      previousStateValue.copyWith(
        currentMessages: [...previousStateValue.currentMessages, typingMessage],
        isReceivingAiResponse: true,
        clearError: true,
      ),
    );

    final aiStream = ref
        .read(chatRepositoryProvider)
        .getAiResponseStream(conversationId, lastUserMessage);

    String currentAiText = '';
    String? aiMessageId;
    bool hasStartedStreaming = false;

    _aiResponseSubscription = aiStream.listen(
      (Either<Failure, String> eitherChunk) {
        final currentChatState = state.valueOrNull ?? _initialChatState();
        eitherChunk.fold(
          (Failure failure) {
            // Remove typing indicator and show error
            final messagesWithoutTyping =
                currentChatState.currentMessages
                    .where((m) => m.id != typingIndicatorId)
                    .toList();

            state = AsyncData(
              currentChatState.copyWith(
                currentMessages: messagesWithoutTyping,
                isReceivingAiResponse: false,
                error: ChatError('AI response error: ${failure.message}'),
              ),
            );
            _aiResponseSubscription?.cancel();
          },
          (String chunk) {
            currentAiText += chunk;

            List<ChatMessageEntity> updatedMessages;
            if (!hasStartedStreaming) {
              // Replace typing indicator with actual AI message
              hasStartedStreaming = true;
              aiMessageId = 'ai_${DateTime.now().millisecondsSinceEpoch}';

              final aiMessage = ChatMessageEntity(
                id: aiMessageId!,
                conversationId: conversationId,
                text: currentAiText,
                sender: MessageSender.ai,
                timestamp: DateTime.now(),
              );

              // Replace typing indicator with AI message
              updatedMessages =
                  currentChatState.currentMessages
                      .map((m) => m.id == typingIndicatorId ? aiMessage : m)
                      .toList();
            } else {
              // Update existing AI message
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
        // Remove typing indicator on error
        final messagesWithoutTyping =
            currentChatState.currentMessages
                .where((m) => m.id != typingIndicatorId)
                .toList();

        state = AsyncData(
          currentChatState.copyWith(
            currentMessages: messagesWithoutTyping,
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

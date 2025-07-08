import 'dart:async'; // Added for StreamSubscription
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:athena/features/chatbot/domain/entities/chat_message_entity.dart';
import 'package:athena/features/chatbot/domain/entities/conversation_entity.dart';
import 'package:athena/features/chatbot/presentation/providers/chat_providers.dart';
import 'package:athena/core/errors/failures.dart'; // For Failure type
import 'package:dartz/dartz.dart'; // For Either type
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';

part 'chat_viewmodel.g.dart';

@riverpod
class ChatViewModel extends _$ChatViewModel {
  // Holds the current active conversation ID
  String? _activeConversationId;

  // Stream subscription for AI responses
  StreamSubscription<Either<Failure, String>>? _aiResponseSubscription;

  @override
  Future<ChatState> build() async {
    try {
      // Load conversations on initial build
      final Either<Failure, List<ConversationEntity>> result =
          await ref.read(getConversationsUseCaseProvider).call();

      return result.fold(
        (Failure failure) {
          return ChatState(
            conversations: [],
            currentMessages: [],
            isLoading: false,
            error: ChatError(
              'Failed to load conversations: ${failure.message}',
            ),
            isReceivingAiResponse: false,
          );
        },
        (List<ConversationEntity> conversations) {
          // If no conversations exist, we'll create one via initializeChatbot
          return ChatState(
            conversations: conversations,
            currentMessages: [],
            isLoading: false,
            error: null,
            isReceivingAiResponse: false,
          );
        },
      );
    } catch (e) {
      return ChatState(
        conversations: [],
        currentMessages: [],
        isLoading: false,
        error: ChatError('Initialization error: ${e.toString()}'),
        isReceivingAiResponse: false,
      );
    }
  }

  Future<void> loadConversations() async {
    final previousState = state.valueOrNull ?? _initialChatState();
    state = AsyncData(
      previousState.copyWith(isLoading: true, clearError: true),
    );

    final getConversations = ref.read(getConversationsUseCaseProvider);
    final result = await getConversations.call();

    result.fold(
      (failure) {
        state = AsyncData(
          previousState.copyWith(
            isLoading: false,
            error: ChatError(
              'Failed to load conversations: ${failure.message}',
            ),
          ),
        );
      },
      (conversations) {
        state = AsyncData(
          previousState.copyWith(
            conversations: conversations,
            isLoading: false,
          ),
        );
      },
    );
  }

  Future<void> deleteConversation(String conversationId) async {
    final previousState = state.valueOrNull ?? _initialChatState();
    state = AsyncData(
      previousState.copyWith(isLoading: true, clearError: true),
    );

    final chatRepo = ref.read(chatRepositoryProvider);
    final result = await chatRepo.deleteConversation(conversationId);

    result.fold(
      (failure) {
        state = AsyncData(
          previousState.copyWith(
            isLoading: false,
            error: ChatError(
              'Failed to delete conversation: ${failure.message}',
            ),
          ),
        );
      },
      (_) async {
        await loadConversations();

        final currentState = state.valueOrNull;
        if (currentState != null &&
            previousState.activeConversationId == conversationId) {
          if (currentState.conversations.isNotEmpty) {
            await setActiveConversation(currentState.conversations.first.id);
          } else {
            _activeConversationId = null; // Clear backing field
            state = AsyncData(
              currentState.copyWith(
                activeConversationId: null,
                currentMessages: [],
                isLoading: false,
              ),
            );
          }
        } else if (currentState != null) {
          state = AsyncData(currentState.copyWith(isLoading: false));
        } else {
          // Fallback if current state is somehow null after loading
          state = AsyncData(
            previousState.copyWith(
              isLoading: false,
              error: ChatError('State error after deletion.'),
            ),
          );
        }
      },
    );
  }

  Future<void> updateConversationTitle(String conversationId, String newTitle) async {
    final previousState = state.valueOrNull ?? _initialChatState();
    state = AsyncData(
      previousState.copyWith(isLoading: true, clearError: true),
    );

    final chatRepo = ref.read(chatRepositoryProvider);
    final result = await chatRepo.updateConversationTitle(conversationId, newTitle);

    result.fold(
      (failure) {
        state = AsyncData(
          previousState.copyWith(
            isLoading: false,
            error: ChatError(
              'Failed to update conversation title: ${failure.message}',
            ),
          ),
        );
      },
      (_) async {
        // Reload conversations to get the updated title
        await loadConversations();
        
        // Keep the loading state false after reload
        final currentState = state.valueOrNull;
        if (currentState != null) {
          state = AsyncData(currentState.copyWith(isLoading: false));
        }
      },
    );
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
    state = AsyncData(
      previousState.copyWith(isLoading: true, clearError: true),
    );

    final createUseCase = ref.read(createConversationUseCaseProvider);
    final result = await createUseCase.call(
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
        // Set the active conversation ID in the backing field first
        _activeConversationId = newConversation.id;

        // Create user message if there's first message text
        List<ChatMessageEntity> initialMessages = [];
        if (firstMessageText != null && firstMessageText.isNotEmpty) {
          final userMessage = ChatMessageEntity(
            id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
            conversationId: newConversation.id,
            text: firstMessageText,
            sender: MessageSender.user,
            timestamp: DateTime.now(),
          );
          initialMessages = [userMessage];
        }

        // Update state with the new conversation list and initial messages
        state = AsyncData(
          previousState.copyWith(
            conversations: updatedConversations,
            currentMessages: initialMessages,
            isLoading: false, // Creation is done
            error: null, // Clear any previous error
            activeConversationId: newConversation.id,
          ),
        );

        // If there's a first message, trigger the AI response
        if (firstMessageText != null && firstMessageText.isNotEmpty) {
          _listenToAiResponse(newConversation.id, firstMessageText);
        }
      },
    );
  }

  /// Starts a new chat session without creating a backend conversation
  /// The conversation will be created when the user sends their first message
  void startNewChat() {
    final previousState = state.valueOrNull ?? _initialChatState();
    _activeConversationId = null;

    state = AsyncData(
      previousState.copyWith(
        currentMessages: [],
        isLoading: false,
        isReceivingAiResponse: false,
        clearError: true,
        clearActiveConversationId: true, // This explicitly clears the activeConversationId
      ),
    );
  }

  Future<void> setActiveConversation(String? conversationId) async {
    final previousState = state.valueOrNull ?? _initialChatState();

    if (conversationId == null) {
      _activeConversationId = null;
      state = AsyncData(
        previousState.copyWith(
          currentMessages: [],
          isLoading: false,
          clearError: true,
          clearActiveConversationId: true,
        ),
      );
      return;
    }

    if (previousState.activeConversationId == conversationId &&
        previousState.currentMessages.isNotEmpty &&
        !previousState.isLoading) {
      return;
    }

    _activeConversationId = conversationId;
    state = AsyncData(
      previousState.copyWith(
        activeConversationId: conversationId,
        isLoading: true,
        currentMessages: [],
        clearError: true,
      ),
    );

    final getHistory = ref.read(getChatHistoryUseCaseProvider);
    // Corrected: call with positional conversationId
    final result = await getHistory.call(conversationId);

    final mostRecentState = state.valueOrNull ?? _initialChatState();

    if (mostRecentState.activeConversationId != conversationId &&
        _activeConversationId != conversationId) {
      return;
    }

    result.fold(
      (failure) {
        state = AsyncData(
          mostRecentState.copyWith(
            isLoading: false,
            activeConversationId: _activeConversationId,
            error: ChatError('Failed to load chat history: ${failure.message}'),
          ),
        );
      },
      (messages) {
        state = AsyncData(
          mostRecentState.copyWith(
            currentMessages: messages,
            isLoading: false,
            activeConversationId: _activeConversationId,
          ),
        );
        if (messages.isNotEmpty &&
            messages.last.sender == MessageSender.user &&
            !(_activeConversationId == null ||
                (state.valueOrNull?.isReceivingAiResponse ?? false))) {
          _listenToAiResponse(_activeConversationId!, messages.last.text);
        }
      },
    );
  }

  Future<void> sendMessage(
    String text, {
    List<PlatformFile>? attachments,
  }) async {
    if (_activeConversationId == null) {
      // If no active conversation, create one first with the user's message
      await createNewConversation(
        title: _generateTitleFromMessage(text),
        firstMessageText: text,
      );
      return;
    }

    // Generate a proper UUID for the message ID
    const uuid = Uuid();
    final tempId = uuid.v4();

    // Handle file attachments - upload files to storage and create FileAttachment entities
    final List<FileAttachment> fileAttachments = [];
    if (attachments != null && attachments.isNotEmpty) {
      // Show loading state for file uploads
      final previousStateValue = state.valueOrNull ?? _initialChatState();
      state = AsyncData(
        previousStateValue.copyWith(isLoading: true, clearError: true),
      );

      try {
        // Upload each file and create FileAttachment entities
        for (int i = 0; i < attachments.length; i++) {
          final file = attachments[i];

          final uploadResult = await ref
              .read(chatRepositoryProvider)
              .uploadFile(messageId: tempId, file: file);

          await uploadResult.fold(
            (failure) {
              // Handle upload failure
              state = AsyncData(
                (state.valueOrNull ?? _initialChatState()).copyWith(
                  isLoading: false,
                  error: ChatError(
                    'Failed to upload ${file.name}: ${failure.message}',
                  ),
                ),
              );
              throw Exception('File upload failed: ${failure.message}');
            },
            (fileAttachment) async {
              fileAttachments.add(fileAttachment);
            },
          );
        }

        // Clear loading state after successful uploads
        print(
          'All files uploaded successfully! Total: ${fileAttachments.length}',
        );
        state = AsyncData(
          (state.valueOrNull ?? _initialChatState()).copyWith(
            isLoading: false,
            clearError: true,
          ),
        );
      } catch (e) {
        // Handle any upload errors
        print('File upload failed: ${e.toString()}');
        state = AsyncData(
          (state.valueOrNull ?? _initialChatState()).copyWith(
            isLoading: false,
            error: ChatError('File upload failed: ${e.toString()}'),
          ),
        );
        return; // Don't send message if file upload failed
      }
    } else {
      print('No files to upload, proceeding with text message only');
    }

    final userMessage = ChatMessageEntity(
      id: tempId,
      conversationId: _activeConversationId!,
      text: text,
      sender: MessageSender.user,
      timestamp: DateTime.now(),
      attachments: fileAttachments,
      hasAttachments: fileAttachments.isNotEmpty,
    );

    final previousStateValue = state.valueOrNull ?? _initialChatState();
    state = AsyncData(
      previousStateValue.copyWith(
        currentMessages: [...previousStateValue.currentMessages, userMessage],
        clearError: true,
      ),
    );

    try {
      final result = await ref
          .read(sendMessageUseCaseProvider)
          .call(conversationId: _activeConversationId!, text: text);

      result.fold(
        (failure) {
          // Revert the optimistic update on failure
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
          // On success, listen to AI response
          _listenToAiResponse(_activeConversationId!, text);
        },
      );
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
      onDone: () async {
        final currentChatState = state.valueOrNull ?? _initialChatState();
        state = AsyncData(
          currentChatState.copyWith(isReceivingAiResponse: false),
        );
        if (currentAiText.isNotEmpty) {
          _updateConversationDetails(conversationId, currentAiText);
        }

        // Refresh messages from database to get the final saved message with navigation actions
        await _refreshMessagesFromDatabase(conversationId);
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

  /// Refresh messages from database to get latest saved messages with navigation actions
  Future<void> _refreshMessagesFromDatabase(String conversationId) async {
    final currentChatState = state.valueOrNull;
    if (currentChatState == null) return;

    try {
      final getHistory = ref.read(getChatHistoryUseCaseProvider);
      final result = await getHistory.call(conversationId);

      result.fold(
        (failure) {
          print('Failed to refresh messages: ${failure.message}');
          // Don't update state on error - keep current messages
        },
        (messages) {
          // Only update if we're still on the same conversation
          final latestState = state.valueOrNull;
          if (latestState?.activeConversationId == conversationId) {
            state = AsyncData(
              latestState!.copyWith(currentMessages: messages),
            );
            print('Successfully refreshed ${messages.length} messages with navigation actions');
          }
        },
      );
    } catch (e) {
      print('Error refreshing messages: $e');
      // Don't update state on error - keep current messages
    }
  }

  // This method is not needed in the ViewModel since it's handled in the screen
  // Removing to avoid confusion

  String _generateTitleFromMessage(String message) {
    final words = message.split(' ').take(4).join(' ');
    return words.length > 30 ? '${words.substring(0, 27)}...' : words;
  }
}

// Helper class for state
class ChatState {
  final List<ConversationEntity> conversations;
  final List<ChatMessageEntity> currentMessages;
  final bool isLoading;
  final ChatError? error;
  final bool isReceivingAiResponse;
  final String? activeConversationId;

  ChatState({
    required this.conversations,
    required this.currentMessages,
    this.isLoading = false,
    this.error,
    this.isReceivingAiResponse = false,
    this.activeConversationId,
  });

  ChatState copyWith({
    List<ConversationEntity>? conversations,
    List<ChatMessageEntity>? currentMessages,
    bool? isLoading,
    ChatError? error,
    bool? clearError,
    bool? isReceivingAiResponse,
    String? activeConversationId,
    bool clearActiveConversationId = false,
  }) {
    return ChatState(
      conversations: conversations ?? this.conversations,
      currentMessages: currentMessages ?? this.currentMessages,
      isLoading: isLoading ?? this.isLoading,
      error: clearError == true ? null : error ?? this.error,
      isReceivingAiResponse:
          isReceivingAiResponse ?? this.isReceivingAiResponse,
      activeConversationId: clearActiveConversationId 
          ? null 
          : activeConversationId ?? this.activeConversationId,
    );
  }
}

class ChatError {
  final String message;
  ChatError(this.message);

  @override
  String toString() => message;
}

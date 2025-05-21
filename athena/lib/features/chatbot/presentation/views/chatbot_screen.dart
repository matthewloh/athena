import 'package:athena/core/theme/app_colors.dart';
import 'package:athena/features/chatbot/domain/entities/chat_message_entity.dart';
import 'package:athena/features/chatbot/presentation/viewmodel/chat_viewmodel.dart'
    as vm;
import 'package:athena/features/chatbot/presentation/widgets/chat_bubble.dart';
import 'package:athena/features/chatbot/presentation/widgets/message_input_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatbotScreen extends ConsumerStatefulWidget {
  const ChatbotScreen({super.key});

  @override
  ConsumerState<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends ConsumerState<ChatbotScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Optional: Load initial data or set active conversation if needed
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   ref.read(chatViewModelProvider.notifier).loadConversations();
    //   // or ref.read(chatViewModelProvider.notifier).setActiveConversation('some_default_id');
    // });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatStateAsync = ref.watch(vm.chatViewModelProvider);

    // Listen to state changes for scrolling
    ref.listen<AsyncValue<vm.ChatState>>(vm.chatViewModelProvider, (_, next) {
      if (next.hasValue &&
          next.value != null &&
          (next.value!.currentMessages.isNotEmpty ||
              next.value!.isReceivingAiResponse)) {
        _scrollToBottom();
      }
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.athenaBlue,
        title: const Text(
          'AI Chatbot',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded),
            onPressed: () => _showChatInfoDialog(context),
          ),
          // Placeholder for conversation list/management
          // IconButton(
          //   icon: const Icon(Icons.list_alt_rounded),
          //   onPressed: () { /* TODO: Show conversation list */ },
          // ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: chatStateAsync.when(
              data: (chatState) {
                if (chatState.isLoading && chatState.currentMessages.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (chatState.currentMessages.isEmpty) {
                  return _buildEmptyChatView(context);
                }
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16.0),
                  itemCount:
                      chatState.currentMessages.length +
                      (chatState.isReceivingAiResponse ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (chatState.isReceivingAiResponse &&
                        index == chatState.currentMessages.length - 1 &&
                        chatState.currentMessages.last.sender ==
                            MessageSender.ai) {
                      // Already handled by the last message if it's AI and being streamed
                    } else if (chatState.isReceivingAiResponse &&
                        index == chatState.currentMessages.length) {
                      // This case indicates that a new AI message is being received but not yet in currentMessages
                      // We can show a generic typing indicator if the partial message isn't in currentMessages yet.
                      // However, the current ViewModel logic adds partial AI message to currentMessages immediately.
                      // So this explicit typing indicator might not be needed if the last message is already the streaming AI one.
                    }
                    final message = chatState.currentMessages[index];
                    return ChatBubble(message: message);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error:
                  (err, stack) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Error: ${err is vm.ChatError ? err.message : err.toString()}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  ),
            ),
          ),
          chatStateAsync.maybeWhen(
            data:
                (chatState) => MessageInputBar(
                  onSendMessage: (text) {
                    ref
                        .read(vm.chatViewModelProvider.notifier)
                        .sendMessage(text);
                  },
                  isSending:
                      chatState.isLoading || chatState.isReceivingAiResponse,
                  // onMicPressed: () { /* TODO: Implement voice input */ },
                ),
            orElse:
                () =>
                    const SizedBox.shrink(), // Don't show input bar during initial load/error screen
          ),
        ],
      ),
      // Example: Floating action button to start a new conversation
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     ref.read(chatViewModelProvider.notifier).createNewConversation(title: 'New Chat');
      //   },
      //   backgroundColor: AppColors.athenaPurple,
      //   child: const Icon(Icons.add_comment_rounded, color: Colors.white),
      // ),
    );
  }

  Widget _buildEmptyChatView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            size: 80,
            color: AppColors.athenaMediumGrey,
          ),
          const SizedBox(height: 20),
          Text(
            'Ask me anything!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.athenaDarkGrey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'I can help you with your studies, explain concepts, or just chat.',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.athenaMediumGrey),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            icon: const Icon(Icons.add_circle_outline_rounded),
            label: const Text('Start New Conversation'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.athenaPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: () {
              // TODO: Implement a proper way to start/select conversations
              // For now, this might just clear messages or point to a default one
              ref
                  .read(vm.chatViewModelProvider.notifier)
                  .createNewConversation(title: 'New Chat from Empty');
            },
          ),
        ],
      ),
    );
  }

  void _showChatInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('About Athena AI Chatbot'),
            content: const SingleChildScrollView(
              child: Text(
                'Athena is your AI-powered study companion. Ask questions, get explanations, and explore topics. \n\nThis chatbot is currently under development. Response quality and features will improve over time.',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }
}

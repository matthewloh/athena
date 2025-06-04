import 'package:athena/core/theme/app_colors.dart';
// import 'package:athena/features/chatbot/domain/entities/conversation_entity.dart'; // Not directly used here
import 'package:athena/features/chatbot/presentation/viewmodel/chat_viewmodel.dart'
    as vm;
import 'package:athena/features/chatbot/presentation/widgets/chat_bubble.dart';
import 'package:athena/features/chatbot/presentation/widgets/conversation_list_drawer.dart';
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
  bool _isInitialized = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeChatbot();
    });
  }

  Future<void> _initializeChatbot() async {
    if (_isInitialized) return;
    _isInitialized = true;

    final chatViewModel = ref.read(vm.chatViewModelProvider.notifier);
    
    await chatViewModel.loadConversations();
    
    final currentState = ref.read(vm.chatViewModelProvider).valueOrNull;
    if (currentState != null && currentState.conversations.isNotEmpty) {
      // If there's no active conversation ID in the state yet, set one.
      if (currentState.activeConversationId == null) {
         await chatViewModel.setActiveConversation(currentState.conversations.first.id);
      }
    }
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

    ref.listen<AsyncValue<vm.ChatState>>(vm.chatViewModelProvider, (_, next) {
      if (next.hasValue &&
          next.value != null &&
          (next.value!.currentMessages.isNotEmpty ||
              next.value!.isReceivingAiResponse)) {
        _scrollToBottom();
      }
    });

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: AppColors.athenaBlue,
        leading: IconButton(
          icon: const Icon(Icons.history_rounded, color: Colors.white),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          tooltip: 'View Conversations',
        ),
        title: Text(
          chatStateAsync.maybeWhen(
            data: (data) {
              if (data.activeConversationId == null || 
                  data.conversations.where((c) => c.id == data.activeConversationId).isEmpty) {
                return 'AI Chatbot'; // Default title if no active or not found
              }
              final activeConversation = data.conversations
                  .firstWhere((c) => c.id == data.activeConversationId);
              return activeConversation.title ?? 'AI Chatbot';
            },
            orElse: () => 'AI Chatbot',
          ),
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_comment_rounded, color: Colors.white),
            onPressed: () {
              ref
                  .read(vm.chatViewModelProvider.notifier)
                  .createNewConversation(title: 'New Chat');
            },
            tooltip: 'New Conversation',
          ),
          IconButton(
            icon: const Icon(Icons.info_outline_rounded, color: Colors.white),
            onPressed: () => _showChatInfoDialog(context),
            tooltip: 'About Chatbot',
          ),
        ],
      ),
      drawer: const ConversationListDrawer(),
      body: Column(
        children: [
          Expanded(
            child: chatStateAsync.when(
              data: (chatState) {
                // Show loading for initial state
                if (chatState.isLoading && chatState.currentMessages.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Initializing chat...'),
                      ],
                    ),
                  );
                }

                // Always show chat area - either with messages or empty and ready
                if (chatState.currentMessages.isEmpty && !chatState.isReceivingAiResponse) {
                  return _buildReadyToChatView(context);
                }

                // Build message list with proper bounds checking
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16.0),
                  itemCount: chatState.currentMessages.length,
                  itemBuilder: (context, index) {
                    if (index >= chatState.currentMessages.length) {
                      return const SizedBox.shrink(); // Safety check
                    }
                    
                    final message = chatState.currentMessages[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: ChatBubble(message: message),
                    );
                  },
                );
              },
              loading: () => const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading conversations...'),
                  ],
                ),
              ),
              error: (err, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Something went wrong',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        err is vm.ChatError ? err.message : err.toString(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => _initializeChatbot(),
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Show typing indicator when AI is responding
          chatStateAsync.maybeWhen(
            data: (chatState) {
              if (chatState.isReceivingAiResponse) {
                return Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Athena is typing...',
                        style: TextStyle(
                          color: AppColors.athenaMediumGrey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
            orElse: () => const SizedBox.shrink(),
          ),
          
          // ALWAYS show message input bar - this is the key fix!
          chatStateAsync.maybeWhen(
            data: (chatState) => MessageInputBar(
              onSendMessage: (text) {
                if (text.trim().isNotEmpty) {
                  ref
                      .read(vm.chatViewModelProvider.notifier)
                      .sendMessage(text.trim());
                }
              },
              isSending: chatState.isLoading || chatState.isReceivingAiResponse,
            ),
            loading: () => MessageInputBar(
              onSendMessage: (text) {
                // Even during loading, allow message input
                if (text.trim().isNotEmpty) {
                  ref
                      .read(vm.chatViewModelProvider.notifier)
                      .sendMessage(text.trim());
                }
              },
              isSending: true,
            ),
            error: (_, __) => MessageInputBar(
              onSendMessage: (text) {
                // Allow retry by sending message even in error state
                if (text.trim().isNotEmpty) {
                  ref
                      .read(vm.chatViewModelProvider.notifier)
                      .sendMessage(text.trim());
                }
              },
              isSending: false,
            ),
            orElse: () => MessageInputBar(
              onSendMessage: (text) {
                if (text.trim().isNotEmpty) {
                  ref
                      .read(vm.chatViewModelProvider.notifier)
                      .sendMessage(text.trim());
                }
              },
              isSending: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadyToChatView(BuildContext context) {
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
            'Hi! I\'m Athena',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.athenaDarkGrey,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ask me anything to get started!',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.athenaMediumGrey),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(horizontal: 32),
            decoration: BoxDecoration(
              color: AppColors.athenaPurple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.athenaPurple.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              'I can help you with your studies, explain concepts, solve problems, or just have a conversation. Just type your message below!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.athenaDarkGrey,
              ),
            ),
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

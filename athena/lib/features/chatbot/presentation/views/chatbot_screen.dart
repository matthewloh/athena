import 'package:athena/core/theme/app_colors.dart';
import 'package:athena/features/chatbot/domain/entities/chat_message_entity.dart';
import 'package:athena/features/chatbot/presentation/viewmodel/chat_viewmodel.dart'
    as vm;
import 'package:athena/features/chatbot/presentation/widgets/chat_bubble.dart';
import 'package:athena/features/chatbot/presentation/widgets/message_input_bar.dart';
import 'package:athena/features/chatbot/presentation/views/conversation_list_screen.dart';
import 'package:athena/features/chatbot/presentation/providers/chat_providers.dart';
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
      backgroundColor: AppColors.athenaOffWhite,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.athenaBlue,
        foregroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.psychology_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Athena AI',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Your Study Companion',
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              icon: const Icon(Icons.list_alt_rounded, color: Colors.white),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ConversationListScreen(),
                  ),
                );
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              icon: const Icon(Icons.info_outline_rounded, color: Colors.white),
              onPressed: () => _showChatInfoDialog(context),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.athenaPurple, AppColors.athenaBlue],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.psychology_rounded, color: Colors.white, size: 40),
                  const SizedBox(height: 8),
                  const Text(
                    'Athena AI',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Debug Menu',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.bug_report, color: AppColors.athenaPurple),
              title: const Text('Debug Edge Function'),
              subtitle: const Text('Test chat functionality'),
              onTap: () {
                Navigator.pop(context);
                _showEdgeFunctionDebug(context, ref);
              },
            ),
            ListTile(
              leading: Icon(Icons.list_alt, color: AppColors.athenaBlue),
              title: const Text('View Conversations'),
              subtitle: const Text('Manage chat history'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ConversationListScreen(),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(
                Icons.info_outline,
                color: AppColors.athenaMediumGrey,
              ),
              title: const Text('About Athena AI'),
              onTap: () {
                Navigator.pop(context);
                _showChatInfoDialog(context);
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: chatStateAsync.when(
                data: (chatState) {
                  if (chatState.isLoading &&
                      chatState.currentMessages.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (chatState.currentMessages.isEmpty) {
                    return _buildEmptyChatView(context);
                  }
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.athenaOffWhite,
                          Colors.white.withValues(alpha: 0.8),
                        ],
                      ),
                    ),
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      itemCount: chatState.currentMessages.length,
                      itemBuilder: (context, index) {
                        // Ensure index is within bounds
                        if (index >= chatState.currentMessages.length) {
                          return const SizedBox.shrink();
                        }

                        final message = chatState.currentMessages[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: ChatBubble(message: message),
                        );
                      },
                    ),
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
            // Always show input bar for better UX
            chatStateAsync.when(
              data:
                  (chatState) => MessageInputBar(
                    onSendMessage: (text) {
                      ref
                          .read(vm.chatViewModelProvider.notifier)
                          .sendMessageOrCreateConversation(text);
                    },
                    isSending:
                        chatState.isLoading || chatState.isReceivingAiResponse,
                    // onMicPressed: () { /* TODO: Implement voice input */ },
                  ),
              loading:
                  () => MessageInputBar(
                    onSendMessage: (text) {
                      ref
                          .read(vm.chatViewModelProvider.notifier)
                          .sendMessageOrCreateConversation(text);
                    },
                    isSending: true,
                  ),
              error:
                  (err, stack) => MessageInputBar(
                    onSendMessage: (text) {
                      ref
                          .read(vm.chatViewModelProvider.notifier)
                          .sendMessageOrCreateConversation(text);
                    },
                    isSending: false,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyChatView(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.athenaOffWhite,
            Colors.white.withValues(alpha: 0.8),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.athenaPurple.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.athenaPurple.withValues(alpha: 0.2),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Icon(
                Icons.psychology_rounded,
                size: 60,
                color: AppColors.athenaPurple,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Ask me anything!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.athenaDarkGrey,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'I can help you with your studies, explain concepts, solve problems, or just have a conversation about any topic.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.athenaMediumGrey,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.athenaPurple.withValues(alpha: 0.2),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.athenaPurple.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.chat_rounded,
                        color: AppColors.athenaPurple,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Just start typing below!',
                          style: TextStyle(
                            color: AppColors.athenaPurple,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your first message will automatically create a new conversation',
                    style: TextStyle(
                      color: AppColors.athenaMediumGrey,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.athenaLightGrey.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline_rounded,
                    color: AppColors.athenaPurple,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Try asking: "Explain photosynthesis" or "Help me with calculus"',
                      style: TextStyle(
                        color: AppColors.athenaMediumGrey,
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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

  void _showEdgeFunctionDebug(BuildContext context, WidgetRef ref) {
    final textController = TextEditingController(
      text: 'Hello, can you help me with my studies?',
    );
    String streamedResponse = '';
    bool isLoading = false;
    String? errorMessage;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.athenaPurple.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.psychology_rounded,
                            color: AppColors.athenaPurple,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Chat Edge Function Debug',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: textController,
                      decoration: InputDecoration(
                        labelText: 'Test Message',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        suffixIcon: IconButton(
                          icon:
                              isLoading
                                  ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : const Icon(Icons.send),
                          onPressed:
                              isLoading
                                  ? null
                                  : () {
                                    final message = textController.text.trim();
                                    if (message.isNotEmpty) {
                                      _testEdgeFunction(
                                        message,
                                        setState,
                                        (response) {
                                          setState(() {
                                            streamedResponse = response;
                                          });
                                        },
                                        (loading) {
                                          setState(() {
                                            isLoading = loading;
                                          });
                                        },
                                        (error) {
                                          setState(() {
                                            errorMessage = error;
                                          });
                                        },
                                        ref,
                                      );
                                    }
                                  },
                        ),
                      ),
                      maxLines: 3,
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed:
                          isLoading
                              ? null
                              : () {
                                final message = textController.text.trim();
                                if (message.isNotEmpty) {
                                  _testEdgeFunction(
                                    message,
                                    setState,
                                    (response) {
                                      setState(() {
                                        streamedResponse = response;
                                      });
                                    },
                                    (loading) {
                                      setState(() {
                                        isLoading = loading;
                                      });
                                    },
                                    (error) {
                                      setState(() {
                                        errorMessage = error;
                                      });
                                    },
                                    ref,
                                  );
                                }
                              },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 45),
                        backgroundColor: AppColors.athenaPurple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        isLoading ? 'Testing...' : 'Test Edge Function',
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      constraints: const BoxConstraints(
                        minHeight: 120,
                        maxHeight: 300,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Edge Function Response:',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey,
                                ),
                              ),
                              const Spacer(),
                              if (isLoading)
                                const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: SingleChildScrollView(
                              child: _buildDebugResponseContent(
                                streamedResponse,
                                errorMessage,
                                isLoading,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Debug Info:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '• Tests the chat-stream edge function directly\n'
                      '• Uses a debug conversation ID for testing\n'
                      '• Shows real-time streaming response\n'
                      '• Displays authentication and network errors\n'
                      '• Helps identify mobile-specific issues',
                      style: TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDebugResponseContent(
    String response,
    String? error,
    bool isLoading,
  ) {
    if (error != null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red[200]!),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.error_outline, color: Colors.red[700]),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Error: $error',
                style: TextStyle(
                  color: Colors.red[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (response.isEmpty && !isLoading) {
      return Text(
        'No response yet. Test the edge function above.',
        style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic),
      );
    }

    if (response.isEmpty && isLoading) {
      return const Text(
        'Waiting for response...',
        style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.athenaPurple.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.athenaPurple.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, color: AppColors.athenaPurple),
              const SizedBox(width: 8),
              Text(
                'Streaming Response:',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: AppColors.athenaPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(response, style: const TextStyle(fontWeight: FontWeight.w400)),
        ],
      ),
    );
  }

  void _testEdgeFunction(
    String message,
    StateSetter setState,
    Function(String) onResponse,
    Function(bool) onLoadingChange,
    Function(String) onError,
    WidgetRef ref,
  ) async {
    try {
      onLoadingChange(true);
      onError(''); // Clear previous errors
      onResponse(''); // Clear previous response

      // Use a debug conversation ID for testing
      final debugConversationId =
          'debug-conversation-${DateTime.now().millisecondsSinceEpoch}';

      // Get the chat repository to test the edge function
      final repository = ref.read(chatRepositoryProvider);

      // Get the AI response stream
      final responseStream = repository.getAiResponseStream(
        debugConversationId,
        message,
      );

      String accumulatedResponse = '';

      await for (final eitherChunk in responseStream) {
        eitherChunk.fold(
          (failure) {
            onError('AI response error: ${failure.message}');
            onLoadingChange(false);
          },
          (chunk) {
            accumulatedResponse += chunk;
            onResponse(accumulatedResponse);
          },
        );
      }

      onLoadingChange(false);
    } catch (e) {
      onError('Test failed: ${e.toString()}');
      onLoadingChange(false);
    }
  }
}

import 'package:athena/core/theme/app_colors.dart';
// import 'package:athena/features/chatbot/domain/entities/conversation_entity.dart'; // Not directly used here
import 'package:athena/features/chatbot/presentation/viewmodel/chat_viewmodel.dart'
    as vm;
import 'package:athena/features/chatbot/presentation/widgets/chat_bubble.dart';
import 'package:athena/features/chatbot/presentation/widgets/conversation_list_drawer.dart';
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

class _ChatbotScreenState extends ConsumerState<ChatbotScreen>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  bool _isInitialized = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  // Animation controllers for ChatGPT-style animations
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  // Gesture tracking
  bool _isDrawerOpen = false;

  @override
  void initState() {
    super.initState();
    
    // Initialize animations
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
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
    
    // Start animations
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
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

  void _toggleDrawer() {
    if (_scaffoldKey.currentState?.isDrawerOpen == true) {
      Navigator.of(context).pop();
      setState(() => _isDrawerOpen = false);
    } else {
      _scaffoldKey.currentState?.openDrawer();
      setState(() => _isDrawerOpen = true);
    }
  }

  void _handleHorizontalDragStart(DragStartDetails details) {
    // Only respond to edge swipes
    const edgeThreshold = 20.0;
    
    if (details.globalPosition.dx < edgeThreshold) {
      // Starting from left edge - prepare to open drawer
    }
  }

  void _handleHorizontalDragUpdate(DragUpdateDetails details) {
    // Handle swipe to open/close drawer
    const sensitivity = 4.0;
    
    if (details.primaryDelta! > sensitivity) {
      // Swiping right - open drawer
      if (!_isDrawerOpen && details.globalPosition.dx < 100) {
        _scaffoldKey.currentState?.openDrawer();
        setState(() => _isDrawerOpen = true);
      }
    } else if (details.primaryDelta! < -sensitivity) {
      // Swiping left - close drawer
      if (_isDrawerOpen) {
        Navigator.of(context).pop();
        setState(() => _isDrawerOpen = false);
      }
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

<<<<<<< HEAD
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
=======
    return GestureDetector(
      onHorizontalDragStart: _handleHorizontalDragStart,
      onHorizontalDragUpdate: _handleHorizontalDragUpdate,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: _buildChatGPTStyleAppBar(chatStateAsync),
        drawer: const ConversationListDrawer(),
        onDrawerChanged: (isOpen) {
          setState(() => _isDrawerOpen = isOpen);
        },
        body: Column(
>>>>>>> 5c773fd1b1b3cf86226be86f597a1f7c26919e81
          children: [
            Expanded(
              child: chatStateAsync.when(
                data: (chatState) {
<<<<<<< HEAD
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
=======
                  // Show loading for initial state
                  if (chatState.isLoading && chatState.currentMessages.isEmpty) {
                    return _buildLoadingView();
                  }

                  // Always show chat area - either with messages or empty and ready
                  if (chatState.currentMessages.isEmpty && !chatState.isReceivingAiResponse) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: _buildReadyToChatView(context),
>>>>>>> 5c773fd1b1b3cf86226be86f597a1f7c26919e81
                      ),
                    );
                  }

                  // Build message list with proper bounds checking
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                      itemCount: chatState.currentMessages.length,
                      itemBuilder: (context, index) {
                        if (index >= chatState.currentMessages.length) {
                          return const SizedBox.shrink(); // Safety check
                        }
                        
                        final message = chatState.currentMessages[index];
                        return AnimatedOpacity(
                          opacity: 1.0,
                          duration: Duration(milliseconds: 200 + (index * 50)),
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: Offset(message.sender.name == 'user' ? 0.3 : -0.3, 0),
                              end: Offset.zero,
                            ).animate(CurvedAnimation(
                              parent: _slideController,
                              curve: Interval(
                                (index * 0.1).clamp(0.0, 1.0),
                                1.0,
                                curve: Curves.easeOutCubic,
                              ),
                            )),
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: ChatBubble(message: message),
                            ),
                          ),
                        );
                      },
                    ),
<<<<<<< HEAD
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
=======
                  );
                },
                loading: () => _buildLoadingView(),
                error: (err, stack) => _buildErrorView(context, err),
              ),
            ),
            _buildChatGPTStyleInputArea(chatStateAsync),
>>>>>>> 5c773fd1b1b3cf86226be86f597a1f7c26919e81
          ],
        ),
      ),
    );
  }

<<<<<<< HEAD
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
=======
  PreferredSizeWidget _buildChatGPTStyleAppBar(AsyncValue<vm.ChatState> chatStateAsync) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: Container(
        margin: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: AppColors.athenaBlue.withValues(alpha: 0.1),
        ),
        child: IconButton(
          icon: Icon(
            _isDrawerOpen ? Icons.close : Icons.menu_rounded,
            color: AppColors.athenaBlue,
            size: 20,
          ),
          onPressed: _toggleDrawer,
          tooltip: _isDrawerOpen ? 'Close Menu' : 'Open Conversations',
        ),
      ),
      title: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.athenaBlue, AppColors.athenaPurple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.psychology_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chatStateAsync.maybeWhen(
                    data: (data) {
                      if (data.activeConversationId == null || 
                          data.conversations.where((c) => c.id == data.activeConversationId).isEmpty) {
                        return 'Athena'; // Default title if no active or not found
                      }
                      final activeConversation = data.conversations
                          .firstWhere((c) => c.id == data.activeConversationId);
                      return activeConversation.title ?? 'Athena';
                    },
                    orElse: () => 'Athena',
                  ),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    fontSize: 18,
                  ),
                ),
                Text(
                  'AI Study Companion',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 8.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: AppColors.athenaBlue.withValues(alpha: 0.1),
          ),
          child: IconButton(
            icon: Icon(
              Icons.add_rounded,
              color: AppColors.athenaBlue,
              size: 20,
            ),
            onPressed: () {
              ref
                  .read(vm.chatViewModelProvider.notifier)
                  .startNewChat();
            },
            tooltip: 'New Conversation',
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                Colors.black.withValues(alpha: 0.1),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChatGPTStyleInputArea(AsyncValue<vm.ChatState> chatStateAsync) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: chatStateAsync.maybeWhen(
            data: (data) => MessageInputBar(
              onSend: (String message) {
                ref.read(vm.chatViewModelProvider.notifier).sendMessage(message);
              },
              isLoading: data.isReceivingAiResponse,
            ),
            orElse: () => MessageInputBar(
              onSend: (String message) {
                ref.read(vm.chatViewModelProvider.notifier).sendMessage(message);
              },
              isLoading: false,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.athenaBlue, AppColors.athenaPurple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Icon(
              Icons.psychology_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          const Text(
            'Initializing Athena...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
>>>>>>> 5c773fd1b1b3cf86226be86f597a1f7c26919e81
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, Object err) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              err is vm.ChatError ? err.message : err.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _initializeChatbot(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadyToChatView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppColors.athenaBlue, AppColors.athenaPurple],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.athenaBlue.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.psychology_rounded,
                size: 40,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Hi! I\'m Athena',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.athenaDarkGrey,
                fontWeight: FontWeight.w700,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Your AI Study Companion',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.athenaMediumGrey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.athenaBlue.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.athenaBlue.withValues(alpha: 0.1),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'I can help you with your studies, explain concepts, solve problems, or just have a conversation. Just type your message below!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.athenaDarkGrey,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _buildSuggestionChip('Explain a concept', '💡'),
                      _buildSuggestionChip('Help with homework', '📚'),
                      _buildSuggestionChip('Study tips', '🎯'),
                      _buildSuggestionChip('Quick question', '❓'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionChip(String label, String emoji) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          ref.read(vm.chatViewModelProvider.notifier).sendMessage(label);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.athenaBlue.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 12)),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.athenaBlue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
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

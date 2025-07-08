import 'package:athena/core/theme/app_colors.dart';
// import 'package:athena/features/chatbot/domain/entities/conversation_entity.dart'; // Not directly used here
import 'package:athena/features/chatbot/presentation/viewmodel/chat_viewmodel.dart'
    as vm;
import 'package:athena/features/chatbot/presentation/widgets/athena_logo.dart';
import 'package:athena/features/chatbot/presentation/widgets/chat_bubble.dart';
import 'package:athena/features/chatbot/presentation/widgets/conversation_list_drawer.dart';
import 'package:athena/features/chatbot/presentation/widgets/message_input_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';

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
  late AnimationController _chipsController;
  late AnimationController _floatingController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _floatingAnimation;

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

    _chipsController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _floatingController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _floatingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeChatbot();
    });
  }

  Future<void> _initializeChatbot() async {
    if (_isInitialized) return;
    _isInitialized = true;

    final chatViewModel = ref.read(vm.chatViewModelProvider.notifier);

    // Load conversations but don't auto-select any
    await chatViewModel.loadConversations();

    // Don't automatically set active conversation - always show landing screen
    // Users can manually select a conversation from the drawer if they want

    // Start animations
    _fadeController.forward();
    _slideController.forward();
    
    // Start chips animation with a slight delay
    Future.delayed(const Duration(milliseconds: 400), () {
      _chipsController.forward();
    });
    
    // Start floating animation as repeating
    _floatingController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _chipsController.dispose();
    _floatingController.dispose();
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
          children: [
            Expanded(
              child: chatStateAsync.when(
                data: (chatState) {
                  // Show loading for initial state
                  if (chatState.isLoading &&
                      chatState.currentMessages.isEmpty) {
                    return _buildLoadingView();
                  }

                  // Show landing screen when no active conversation or no messages
                  if (chatState.activeConversationId == null ||
                      (chatState.currentMessages.isEmpty &&
                          !chatState.isReceivingAiResponse)) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: _buildReadyToChatView(context),
                      ),
                    );
                  }

                  // Build message list with proper bounds checking
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 4.0,
                      ),
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
                              begin: Offset(
                                message.sender.name == 'user' ? 0.3 : -0.3,
                                0,
                              ),
                              end: Offset.zero,
                            ).animate(
                              CurvedAnimation(
                                parent: _slideController,
                                curve: Interval(
                                  (index * 0.1).clamp(0.0, 1.0),
                                  1.0,
                                  curve: Curves.easeOutCubic,
                                ),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: ChatBubble(message: message),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
                loading: () => _buildLoadingView(),
                error: (err, stack) => _buildErrorView(context, err),
              ),
            ),
            _buildChatGPTStyleInputArea(chatStateAsync),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildChatGPTStyleAppBar(
    AsyncValue<vm.ChatState> chatStateAsync,
  ) {
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
            child: const AthenaLogo.small(showBackground: false),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () {
                // Only allow editing if there's an active conversation
                chatStateAsync.maybeWhen(
                  data: (data) {
                    if (data.activeConversationId != null &&
                        data.conversations
                            .where((c) => c.id == data.activeConversationId)
                            .isNotEmpty) {
                      final activeConversation = data.conversations.firstWhere(
                        (c) => c.id == data.activeConversationId,
                      );
                      _showEditTitleDialog(context, activeConversation);
                    }
                  },
                  orElse: () {},
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chatStateAsync.maybeWhen(
                            data: (data) {
                              if (data.activeConversationId == null ||
                                  data.conversations
                                      .where((c) => c.id == data.activeConversationId)
                                      .isEmpty) {
                                return 'Athena'; // Default title if no active or not found
                              }
                              final activeConversation = data.conversations.firstWhere(
                                (c) => c.id == data.activeConversationId,
                              );
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
                      ),
                      // Show edit icon only when there's an active conversation
                      chatStateAsync.maybeWhen(
                        data: (data) {
                          if (data.activeConversationId != null &&
                              data.conversations
                                  .where((c) => c.id == data.activeConversationId)
                                  .isNotEmpty) {
                            return Icon(
                              Icons.edit,
                              size: 14,
                              color: AppColors.athenaBlue.withValues(alpha: 0.6),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                        orElse: () => const SizedBox.shrink(),
                      ),
                    ],
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
              ref.read(vm.chatViewModelProvider.notifier).startNewChat();
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
            data:
                (data) => MessageInputBar(
                  onSend: (String message, List<PlatformFile>? attachments) {
                    ref
                        .read(vm.chatViewModelProvider.notifier)
                        .sendMessage(message, attachments: attachments);
                  },
                  isLoading: data.isReceivingAiResponse,
                ),
            orElse:
                () => MessageInputBar(
                  onSend: (String message, List<PlatformFile>? attachments) {
                    ref
                        .read(vm.chatViewModelProvider.notifier)
                        .sendMessage(message, attachments: attachments);
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
            child: const AthenaLogo.medium(showBackground: false),
          ),
          const SizedBox(height: 16),
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          const Text(
            'Initializing Athena...',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
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
                color: Theme.of(
                  context,
                ).colorScheme.error.withValues(alpha: 0.1),
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
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              err is vm.ChatError ? err.message : err.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _initializeChatbot(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadyToChatView(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40), // Top spacing
              AnimatedBuilder(
                animation: _floatingAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, -8 * _floatingAnimation.value),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [AppColors.athenaBlue, AppColors.athenaPurple],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.athenaBlue.withValues(alpha: 0.3 + 0.1 * _floatingAnimation.value),
                            blurRadius: 20 + 5 * _floatingAnimation.value,
                            offset: Offset(0, 8 + 2 * _floatingAnimation.value),
                          ),
                        ],
                      ),
                      child: const AthenaLogo.extraLarge(
                        showBackground: false,
                        padding: EdgeInsets.all(20),
                      ),
                    ),
                  );
                },
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
                    _buildAnimatedSuggestionChips(),
                  ],
                ),
              ),
              const SizedBox(height: 40), // Bottom spacing
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedSuggestionChips() {
    // Organized for better visual balance: 2 top, 3 bottom
    final topRowSuggestions = [
      {'label': 'Show my study progress', 'emoji': '📊'},
      {'label': 'Search my materials', 'emoji': '🔍'},
    ];
    
    final bottomRowSuggestions = [
      {'label': 'Help with homework', 'emoji': '📚'},
      {'label': 'Study tips', 'emoji': '🎯'},
      {'label': 'Quick question', 'emoji': '❓'},
    ];

    return AnimatedBuilder(
      animation: _chipsController,
      builder: (context, child) {
        return Column(
          children: [
            // Top row - 2 chips, horizontally scrollable
            SizedBox(
              height: 32, // Fixed height for consistency
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Add padding to center content when not scrolled
                    SizedBox(width: MediaQuery.of(context).size.width * 0.1),
                    ...topRowSuggestions.asMap().entries.map((entry) {
                      final index = entry.key;
                      final suggestion = entry.value;
                      
                      return Padding(
                        padding: EdgeInsets.only(
                          right: index < topRowSuggestions.length - 1 ? 8 : 0,
                        ),
                        child: _buildAnimatedChip(suggestion, index),
                      );
                    }).toList(),
                    // Add padding to center content when not scrolled
                    SizedBox(width: MediaQuery.of(context).size.width * 0.1),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Bottom row - 3 chips, horizontally scrollable
            SizedBox(
              height: 32, // Fixed height for consistency
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    // Add padding for visual balance
                    const SizedBox(width: 16),
                    ...bottomRowSuggestions.asMap().entries.map((entry) {
                      final index = entry.key + 2; // Continue index from top row
                      final suggestion = entry.value;
                      
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _buildAnimatedChip(suggestion, index),
                      );
                    }).toList(),
                    // Add padding at the end
                    const SizedBox(width: 16),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAnimatedChip(Map<String, String> suggestion, int index) {
    // Calculate staggered animation progress
    final delayFactor = index * 0.12; // Slightly faster for better flow
    final rawProgress = (_chipsController.value - delayFactor).clamp(0.0, 1.0);
    final scaleProgress = Curves.easeOutBack.transform(rawProgress);
    final opacityProgress = Curves.easeOut.transform(rawProgress).clamp(0.0, 1.0);
    
    return Transform.scale(
      scale: scaleProgress.clamp(0.0, 1.15), // Slightly less bounce for cleaner look
      child: AnimatedOpacity(
        opacity: opacityProgress,
        duration: Duration.zero,
        child: _buildSuggestionChip(suggestion['label']!, suggestion['emoji']!, index),
      ),
    );
  }

  Widget _buildSuggestionChip(String label, String emoji, int index) {
    return _SuggestionChipWidget(
      label: label,
      emoji: emoji,
      onTap: () {
        ref.read(vm.chatViewModelProvider.notifier).sendMessage(label);
      },
    );
  }

  Future<void> _showEditTitleDialog(BuildContext context, conversation) async {
    final TextEditingController titleController = TextEditingController(
      text: conversation.title ?? 'New Conversation',
    );

    final newTitle = await showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.edit_outlined,
                color: AppColors.athenaBlue,
              ),
              const SizedBox(width: 8),
              const Text('Edit Title'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter a new title for this conversation:',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: titleController,
                autofocus: true,
                maxLength: 50,
                decoration: InputDecoration(
                  hintText: 'Conversation title...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.athenaBlue),
                  ),
                ),
                onSubmitted: (value) {
                  Navigator.of(dialogContext).pop(value.trim());
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.athenaBlue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Save'),
              onPressed: () {
                Navigator.of(dialogContext).pop(titleController.text.trim());
              },
            ),
          ],
        );
      },
    );

    if (newTitle != null && newTitle.isNotEmpty && newTitle != conversation.title) {
      await ref
          .read(vm.chatViewModelProvider.notifier)
          .updateConversationTitle(conversation.id, newTitle);
    }
  }
}

class _SuggestionChipWidget extends StatefulWidget {
  final String label;
  final String emoji;
  final VoidCallback onTap;

  const _SuggestionChipWidget({
    required this.label,
    required this.emoji,
    required this.onTap,
  });

  @override
  State<_SuggestionChipWidget> createState() => _SuggestionChipWidgetState();
}

class _SuggestionChipWidgetState extends State<_SuggestionChipWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOut),
    );
    
    _elevationAnimation = Tween<double>(begin: 0.0, end: 4.0).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  void _onHover(bool hovering) {
    setState(() => _isHovered = hovering);
    if (hovering) {
      _hoverController.forward();
    } else {
      _hoverController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _hoverController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            elevation: _elevationAnimation.value,
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () {
                // Add haptic feedback
                HapticFeedback.selectionClick();
                widget.onTap();
              },
              onHover: _onHover,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: _isHovered 
                        ? AppColors.athenaBlue.withValues(alpha: 0.4)
                        : AppColors.athenaBlue.withValues(alpha: 0.2),
                    width: _isHovered ? 1.5 : 1.0,
                  ),
                  gradient: _isHovered 
                      ? LinearGradient(
                          colors: [
                            AppColors.athenaBlue.withValues(alpha: 0.05),
                            AppColors.athenaPurple.withValues(alpha: 0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 150),
                      style: TextStyle(
                        fontSize: _isHovered ? 13 : 12,
                      ),
                      child: Text(widget.emoji),
                    ),
                    const SizedBox(width: 4),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 150),
                      style: TextStyle(
                        fontSize: 13,
                        color: _isHovered 
                            ? AppColors.athenaPurple
                            : AppColors.athenaBlue,
                        fontWeight: _isHovered ? FontWeight.w600 : FontWeight.w500,
                      ),
                      child: Text(widget.label),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

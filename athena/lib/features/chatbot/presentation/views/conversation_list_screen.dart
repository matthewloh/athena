import 'package:athena/core/theme/app_colors.dart';
import 'package:athena/features/chatbot/domain/entities/conversation_entity.dart';

import 'package:athena/features/chatbot/presentation/viewmodel/chat_viewmodel.dart'
    as vm;
import 'package:athena/features/chatbot/presentation/views/chatbot_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConversationListScreen extends ConsumerStatefulWidget {
  const ConversationListScreen({super.key});

  @override
  ConsumerState<ConversationListScreen> createState() =>
      _ConversationListScreenState();
}

class _ConversationListScreenState
    extends ConsumerState<ConversationListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Load conversations when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(vm.chatViewModelProvider.notifier).loadConversations();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatStateAsync = ref.watch(vm.chatViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.athenaBlue,
        title: const Text(
          'Conversations',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_comment_rounded),
            onPressed: () => _showNewConversationDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search conversations...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: AppColors.athenaLightGrey.withValues(alpha: 0.1),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          // Conversations list
          Expanded(
            child: chatStateAsync.when(
              data: (chatState) {
                if (chatState.isLoading && chatState.conversations.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                final filteredConversations =
                    _searchQuery.isEmpty
                        ? chatState.conversations
                        : chatState.conversations.where((conv) {
                          final title = conv.title?.toLowerCase() ?? '';
                          final snippet =
                              conv.lastMessageSnippet?.toLowerCase() ?? '';
                          return title.contains(_searchQuery) ||
                              snippet.contains(_searchQuery);
                        }).toList();

                if (filteredConversations.isEmpty) {
                  return _buildEmptyState(context);
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await ref
                        .read(vm.chatViewModelProvider.notifier)
                        .loadConversations();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: filteredConversations.length,
                    itemBuilder: (context, index) {
                      final conversation = filteredConversations[index];
                      return _buildConversationCard(context, conversation);
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error:
                  (err, stack) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: AppColors.athenaMediumGrey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Failed to load conversations',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          err.toString(),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.athenaMediumGrey),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            ref
                                .read(vm.chatViewModelProvider.notifier)
                                .loadConversations();
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNewConversationDialog(context),
        backgroundColor: AppColors.athenaPurple,
        child: const Icon(Icons.add_comment_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildConversationCard(
    BuildContext context,
    ConversationEntity conversation,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.athenaPurple.withValues(alpha: 0.1),
          child: Icon(Icons.chat_bubble_outline, color: AppColors.athenaPurple),
        ),
        title: Text(
          conversation.title ?? 'Untitled Conversation',
          style: const TextStyle(fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (conversation.lastMessageSnippet != null)
              Text(
                conversation.lastMessageSnippet!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: AppColors.athenaMediumGrey),
              ),
            const SizedBox(height: 4),
            Text(
              _formatDateTime(conversation.updatedAt),
              style: TextStyle(fontSize: 12, color: AppColors.athenaMediumGrey),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected:
              (value) =>
                  _handleConversationAction(context, conversation, value),
          itemBuilder:
              (context) => [
                const PopupMenuItem(
                  value: 'rename',
                  child: ListTile(
                    leading: Icon(Icons.edit),
                    title: Text('Rename'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete, color: Colors.red),
                    title: Text('Delete', style: TextStyle(color: Colors.red)),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
        ),
        onTap: () => _openConversation(context, conversation),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
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
            _searchQuery.isEmpty
                ? 'No conversations yet'
                : 'No conversations found',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.athenaDarkGrey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty
                ? 'Start a new conversation with Athena'
                : 'Try a different search term',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.athenaMediumGrey),
          ),
          if (_searchQuery.isEmpty) ...[
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.add_circle_outline_rounded),
              label: const Text('Start New Conversation'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.athenaPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              onPressed: () => _showNewConversationDialog(context),
            ),
          ],
        ],
      ),
    );
  }

  void _openConversation(
    BuildContext context,
    ConversationEntity conversation,
  ) {
    // Set the active conversation and navigate to chat screen
    ref
        .read(vm.chatViewModelProvider.notifier)
        .setActiveConversation(conversation.id);

    // Navigate to chat screen
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const ChatbotScreen()));
  }

  void _handleConversationAction(
    BuildContext context,
    ConversationEntity conversation,
    String action,
  ) {
    switch (action) {
      case 'rename':
        _showRenameDialog(context, conversation);
        break;
      case 'delete':
        _showDeleteConfirmation(context, conversation);
        break;
    }
  }

  void _showNewConversationDialog(BuildContext context) {
    final titleController = TextEditingController();
    final messageController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('New Conversation'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Conversation Title (Optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: messageController,
                  decoration: const InputDecoration(
                    labelText: 'First Message (Optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final navigator = Navigator.of(context);
                  navigator.pop();
                  ref
                      .read(vm.chatViewModelProvider.notifier)
                      .createNewConversation(
                        title:
                            titleController.text.trim().isEmpty
                                ? null
                                : titleController.text.trim(),
                        firstMessageText:
                            messageController.text.trim().isEmpty
                                ? null
                                : messageController.text.trim(),
                      );

                  // Navigate to chat screen after creation
                  Future.delayed(const Duration(milliseconds: 500), () {
                    navigator.push(
                      MaterialPageRoute(
                        builder: (context) => const ChatbotScreen(),
                      ),
                    );
                  });
                },
                child: const Text('Create'),
              ),
            ],
          ),
    );
  }

  void _showRenameDialog(
    BuildContext context,
    ConversationEntity conversation,
  ) {
    final controller = TextEditingController(text: conversation.title);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Rename Conversation'),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'New Title',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // TODO: Implement conversation update
                  // ref.read(vm.chatViewModelProvider.notifier).updateConversation(
                  //   conversation.copyWith(title: controller.text.trim()),
                  // );
                },
                child: const Text('Rename'),
              ),
            ],
          ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    ConversationEntity conversation,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Conversation'),
            content: Text(
              'Are you sure you want to delete "${conversation.title ?? 'Untitled Conversation'}"? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  Navigator.of(context).pop();
                  // TODO: Implement conversation deletion
                  // ref.read(deleteConversationProvider(conversation.id));
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}

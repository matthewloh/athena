import 'package:athena/core/theme/app_colors.dart';
// import 'package:athena/features/chatbot/domain/entities/conversation_entity.dart'; // Not directly used here, ViewModel provides it
import 'package:athena/features/chatbot/presentation/viewmodel/chat_viewmodel.dart' as vm;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart'; // For date formatting

class ConversationListDrawer extends ConsumerWidget {
  const ConversationListDrawer({super.key});

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays == 0) {
      return DateFormat.jm().format(timestamp); // e.g., 5:30 PM
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return DateFormat.EEEE().format(timestamp); // e.g., Monday
    } else {
      return DateFormat.yMd().format(timestamp); // e.g., 10/05/2023
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatStateAsync = ref.watch(vm.chatViewModelProvider);

    return Drawer(
      child: Column(
        children: [
          AppBar(
            title: const Text('Conversations', style: TextStyle(color: Colors.white)),
            automaticallyImplyLeading: false,
            backgroundColor: AppColors.athenaBlue,
            elevation: 1,
            actions: [
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          Expanded(
            child: chatStateAsync.when(
              data: (chatState) {
                if (chatState.conversations.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 60,
                            color: AppColors.athenaMediumGrey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No conversations yet.',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: AppColors.athenaDarkGrey,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Start chatting to see your conversations here!',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.athenaMediumGrey,
                                ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  itemCount: chatState.conversations.length,
                  separatorBuilder: (context, index) => const Divider(height: 1, indent: 16, endIndent: 16),
                  itemBuilder: (context, index) {
                    final conversation = chatState.conversations[index];
                    final bool isActive = chatState.activeConversationId == conversation.id;
                    return ListTile(
                      tileColor: isActive ? AppColors.athenaBlue.withAlpha(26) : null, // ~10% opacity (255 * 0.1 = 25.5)
                      leading: Icon(
                        Icons.chat_bubble_outline_rounded,
                        color: isActive ? AppColors.athenaBlue : AppColors.athenaMediumGrey,
                      ),
                      title: Text(
                        conversation.title ?? 'New Conversation',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                          color: isActive ? AppColors.athenaBlue : AppColors.athenaDarkGrey,
                        ),
                      ),
                      subtitle: Text(
                        _formatTimestamp(conversation.updatedAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.athenaMediumGrey,
                        ),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete_outline_rounded, color: AppColors.athenaMediumGrey),
                        tooltip: 'Delete "${conversation.title ?? 'this conversation'}"',
                        onPressed: () async {
                          final confirmDelete = await showDialog<bool>(
                            context: context,
                            builder: (BuildContext dialogContext) {
                              return AlertDialog(
                                title: const Text('Delete Conversation?'),
                                content: Text('Are you sure you want to delete "${conversation.title ?? 'this conversation'}"? This action cannot be undone.'),
                                actions: <Widget>[
                                  TextButton(
                                    child: const Text('Cancel'),
                                    onPressed: () {
                                      Navigator.of(dialogContext).pop(false);
                                    },
                                  ),
                                  TextButton(
                                    style: TextButton.styleFrom(foregroundColor: AppColors.error),
                                    child: const Text('Delete'),
                                    onPressed: () {
                                      Navigator.of(dialogContext).pop(true);
                                    },
                                  ),
                                ],
                              );
                            },
                          );

                          if (confirmDelete == true) {
                            await ref.read(vm.chatViewModelProvider.notifier).deleteConversation(conversation.id);
                          }
                        },
                      ),
                      onTap: () {
                        ref.read(vm.chatViewModelProvider.notifier).setActiveConversation(conversation.id);
                        Navigator.of(context).pop(); // Close the drawer
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Error loading conversations: ${err is vm.ChatError ? err.message : err.toString()}',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 
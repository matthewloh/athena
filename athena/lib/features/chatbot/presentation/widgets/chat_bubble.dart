import 'package:athena/core/theme/app_colors.dart';
import 'package:athena/features/chatbot/domain/entities/chat_message_entity.dart';
import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessageEntity message;
  final String? userAvatarUrl; // Optional: for future use
  final String? aiAvatarAssetPath; // Optional: for future use

  const ChatBubble({
    super.key,
    required this.message,
    this.userAvatarUrl,
    this.aiAvatarAssetPath,
  });

  @override
  Widget build(BuildContext context) {
    final bool isUser = message.sender == MessageSender.user;
    final bool isSystem = message.sender == MessageSender.system;

    if (isSystem) {
      return _buildSystemMessage(context);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) _buildAvatar(context, isUser),
          if (!isUser) const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isUser ? AppColors.athenaBlue : AppColors.athenaLightGrey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: isUser ? Colors.white : AppColors.athenaDarkGrey,
                      fontSize: 15,
                      fontWeight: FontWeight.w500
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      color: isUser ? Colors.white.withValues(alpha: 0.7) : AppColors.athenaMediumGrey,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
          if (isUser) _buildAvatar(context, isUser),
        ],
      ),
    );
  }

  Widget _buildAvatar(BuildContext context, bool isUser) {
    // Placeholder for user/AI avatar logic
    if (isUser) {
      return CircleAvatar(
        radius: 16,
        backgroundColor: AppColors.primary.withValues(alpha: 0.8),
        child: const Icon(Icons.person, size: 18, color: Colors.white),
      );
    } else { // AI
      return CircleAvatar(
        radius: 16,
        backgroundColor: AppColors.athenaPurple.withValues(alpha: 0.1),
        child: Padding(
          padding: const EdgeInsets.all(4.0), // Adjust padding to control logo size within circle
          child: Image.asset(aiAvatarAssetPath ?? 'assets/images/logo.png'),
        ),
      );
    }
  }

  Widget _buildSystemMessage(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 40.0),
      decoration: BoxDecoration(
        color: AppColors.athenaLightGrey.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        message.text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.athenaMediumGrey,
          fontSize: 12,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    // Basic time formatting, consider using intl package for more robust formatting
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
} 
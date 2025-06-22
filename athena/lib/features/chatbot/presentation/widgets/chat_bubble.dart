import 'package:athena/core/theme/app_colors.dart';
import 'package:athena/features/auth/domain/entities/profile_entity.dart';
import 'package:athena/features/auth/presentation/providers/profile_providers.dart';
import 'package:athena/features/chatbot/domain/entities/chat_message_entity.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:markdown/markdown.dart' as md;

class ChatBubble extends ConsumerWidget {
  final ChatMessageEntity message;
  final String? aiAvatarAssetPath;

  const ChatBubble({super.key, required this.message, this.aiAvatarAssetPath});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isUser = message.sender == MessageSender.user;
    final bool isSystem = message.sender == MessageSender.system;

    if (isSystem) {
      return _buildSystemMessage(context);
    }

    final AsyncValue<ProfileEntity?> userProfileAsyncValue =
        isUser
            ? ref.watch(currentUserProfileProvider)
            : const AsyncValue.data(null);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) _buildAvatar(context, const AsyncValue.data(null)),
          if (!isUser) const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? AppColors.athenaBlue : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
                border:
                    !isUser
                        ? Border.all(
                          color: AppColors.athenaLightGrey.withValues(
                            alpha: 0.3,
                          ),
                          width: 1,
                        )
                        : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isUser)
                    Text(
                      message.text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  else
                    _buildMarkdownContent(context),
                  const SizedBox(height: 8),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      color:
                          isUser
                              ? Colors.white.withValues(alpha: 0.7)
                              : AppColors.athenaMediumGrey,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
          if (isUser) _buildAvatar(context, userProfileAsyncValue),
        ],
      ),
    );
  }

  Widget _buildMarkdownContent(BuildContext context) {
    return MarkdownBody(
      data: message.text,
      styleSheet: MarkdownStyleSheet(
        h1: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.athenaDarkGrey,
          height: 1.3,
        ),
        h2: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.athenaDarkGrey,
          height: 1.3,
        ),
        h3: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.athenaDarkGrey,
          height: 1.3,
        ),
        p: TextStyle(
          fontSize: 15,
          color: AppColors.athenaDarkGrey,
          height: 1.4,
        ),
        listBullet: TextStyle(
          fontSize: 15,
          color: AppColors.athenaBlue,
          fontWeight: FontWeight.bold,
        ),
        strong: TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.athenaDarkGrey,
        ),
        em: TextStyle(
          fontStyle: FontStyle.italic,
          color: AppColors.athenaDarkGrey,
        ),
        code: TextStyle(
          fontSize: 14,
          fontFamily: 'monospace',
          backgroundColor: AppColors.athenaLightGrey.withValues(alpha: 0.2),
          color: AppColors.athenaBlue,
        ),
        codeblockDecoration: BoxDecoration(
          color: AppColors.athenaLightGrey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.athenaLightGrey.withValues(alpha: 0.3),
          ),
        ),
        codeblockPadding: const EdgeInsets.all(12),
        a: TextStyle(
          color: AppColors.athenaBlue,
          decoration: TextDecoration.underline,
        ),
        blockquote: TextStyle(
          fontSize: 15,
          color: AppColors.athenaMediumGrey,
          fontStyle: FontStyle.italic,
        ),
        blockquoteDecoration: BoxDecoration(
          color: AppColors.athenaLightGrey.withValues(alpha: 0.1),
          border: Border(
            left: BorderSide(color: AppColors.athenaBlue, width: 4),
          ),
        ),
        blockquotePadding: const EdgeInsets.all(12),
        horizontalRuleDecoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.athenaLightGrey, width: 1),
          ),
        ),
      ),
      extensionSet: md.ExtensionSet(
        md.ExtensionSet.gitHubFlavored.blockSyntaxes,
        [md.EmojiSyntax(), ...md.ExtensionSet.gitHubFlavored.inlineSyntaxes],
      ),
      selectable: true,
    );
  }

  Widget _buildAvatar(
    BuildContext context,
    AsyncValue<ProfileEntity?> profileAsyncValue,
  ) {
    Widget avatarContent;
    Color avatarBackgroundColor;
    bool isUserMessage = message.sender == MessageSender.user;

    if (isUserMessage) {
      avatarBackgroundColor = AppColors.athenaBlue;
      avatarContent = profileAsyncValue.when(
        data: (ProfileEntity? profile) {
          if (profile?.avatarUrl != null && profile!.avatarUrl!.isNotEmpty) {
            return CachedNetworkImage(
              imageUrl: profile.avatarUrl!,
              imageBuilder:
                  (context, imageProvider) => Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
              placeholder:
                  (context, url) => SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
              errorWidget:
                  (context, url, error) => const Icon(
                    Icons.person_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
            );
          } else {
            return const Icon(
              Icons.person_rounded,
              size: 18,
              color: Colors.white,
            );
          }
        },
        loading:
            () => SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
        error: (err, stack) {
          print('Error loading user profile for avatar: $err');
          return const Icon(
            Icons.person_rounded,
            size: 18,
            color: Colors.white,
          );
        },
      );
    } else {
      avatarBackgroundColor = AppColors.athenaPurple.withValues(alpha: 0.1);
      avatarContent = Padding(
        padding: const EdgeInsets.all(6.0),
        child: Image.asset(
          aiAvatarAssetPath ?? 'assets/images/logo.png',
          fit: BoxFit.contain,
        ),
      );
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: avatarBackgroundColor,
        shape: BoxShape.circle,
        border:
            !isUserMessage
                ? Border.all(
                  color: AppColors.athenaPurple.withValues(alpha: 0.3),
                  width: 1,
                )
                : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(child: Center(child: avatarContent)),
    );
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
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}

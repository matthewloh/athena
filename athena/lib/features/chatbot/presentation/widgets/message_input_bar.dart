import 'package:athena/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class MessageInputBar extends StatefulWidget {
  final Function(String) onSendMessage;
  final bool isSending;
  final VoidCallback? onMicPressed; // Optional, for voice input

  const MessageInputBar({
    super.key,
    required this.onSendMessage,
    this.isSending = false,
    this.onMicPressed,
  });

  @override
  State<MessageInputBar> createState() => _MessageInputBarState();
}

class _MessageInputBarState extends State<MessageInputBar> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleSend() {
    if (_textController.text.trim().isNotEmpty) {
      widget.onSendMessage(_textController.text.trim());
      _textController.clear();
      // _focusNode.requestFocus(); // Optionally keep focus
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 5.0, // Add shadow to the top of the container
      color: Theme.of(context).cardColor, // Use cardColor for better theme adaptation
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor, // Use scaffoldBackgroundColor for contrast
                    borderRadius: BorderRadius.circular(24.0),
                    border: Border.all(color: AppColors.athenaLightGrey.withValues(alpha: 0.5))
                  ),
                  child: Row(
                    children: <Widget>[
                      const SizedBox(width: 16), // Padding for hint text
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          focusNode: _focusNode,
                          textCapitalization: TextCapitalization.sentences,
                          minLines: 1,
                          maxLines: 5, // Allow multi-line input
                          decoration: InputDecoration(
                            hintText: 'Ask Athena anything...',
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: AppColors.athenaMediumGrey)
                          ),
                          onSubmitted: widget.isSending ? null : (_) => _handleSend(),
                          enabled: !widget.isSending,
                        ),
                      ),
                      if (widget.onMicPressed != null)
                        IconButton(
                          icon: Icon(Icons.mic_none_rounded, color: AppColors.athenaMediumGrey),
                          onPressed: widget.isSending ? null : widget.onMicPressed,
                        ),
                      if (widget.onMicPressed == null) const SizedBox(width: 12), // Ensure consistent padding if mic is not there
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8.0),
              Container(
                 decoration: BoxDecoration(
                    color: widget.isSending || _textController.text.trim().isEmpty 
                           ? AppColors.athenaMediumGrey.withValues(alpha: 0.5)
                           : AppColors.athenaBlue,
                    shape: BoxShape.circle,
                  ),
                child: IconButton(
                  icon: widget.isSending
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.send_rounded, color: Colors.white),
                  onPressed: widget.isSending || _textController.text.trim().isEmpty ? null : _handleSend,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 
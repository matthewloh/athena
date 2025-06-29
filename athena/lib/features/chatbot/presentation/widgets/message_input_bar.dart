import 'package:athena/core/theme/app_colors.dart';
import 'package:athena/features/chatbot/presentation/widgets/file_upload_widget.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class MessageInputBar extends StatefulWidget {
  final Function(String, List<PlatformFile>?) onSend;
  final bool isLoading;
  final VoidCallback? onMicPressed; // Optional, for voice input

  const MessageInputBar({
    super.key,
    required this.onSend,
    this.isLoading = false,
    this.onMicPressed,
  });

  @override
  State<MessageInputBar> createState() => _MessageInputBarState();
}

class _MessageInputBarState extends State<MessageInputBar>
    with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _hasText = false;
  bool _isFocused = false;
  final List<PlatformFile> _attachedFiles = [];

  late AnimationController _sendButtonController;
  late AnimationController _focusController;
  late Animation<double> _sendButtonScale;
  late Animation<double> _borderOpacity;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);

    _sendButtonController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _focusController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _sendButtonScale = Tween<double>(begin: 1.0, end: 1.0).animate(
      CurvedAnimation(parent: _sendButtonController, curve: Curves.elasticOut),
    );

    _borderOpacity = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _focusController, curve: Curves.easeInOut),
    );
  }

  void _onTextChanged() {
    _updateSendButtonState();
  }

  void _onFocusChanged() {
    final isFocused = _focusNode.hasFocus;
    if (isFocused != _isFocused) {
      setState(() {
        _isFocused = isFocused;
      });

      if (isFocused) {
        _focusController.forward();
      } else {
        _focusController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChanged);
    _textController.dispose();
    _focusNode.dispose();
    _sendButtonController.dispose();
    _focusController.dispose();
    super.dispose();
  }

  void _handleSend() {
    if ((_textController.text.trim().isNotEmpty || _attachedFiles.isNotEmpty) &&
        !widget.isLoading) {
      widget.onSend(
        _textController.text.trim(),
        _attachedFiles.isNotEmpty ? _attachedFiles : null,
      );
      _textController.clear();
      setState(() {
        _hasText = false;
        _attachedFiles.clear();
      });
      _sendButtonController.reverse();
    }
  }

  void _onFilesSelected(List<PlatformFile> files) {
    setState(() {
      _attachedFiles.addAll(files);
    });
    _updateSendButtonState();
  }

  void _removeFile(int index) {
    setState(() {
      _attachedFiles.removeAt(index);
    });
    _updateSendButtonState();
  }

  void _updateSendButtonState() {
    final hasContent =
        _textController.text.trim().isNotEmpty || _attachedFiles.isNotEmpty;
    if (hasContent != _hasText) {
      setState(() {
        _hasText = hasContent;
      });

      if (hasContent) {
        _sendButtonController.forward();
      } else {
        _sendButtonController.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_sendButtonController, _focusController]),
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // File attachments preview
              if (_attachedFiles.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children:
                          _attachedFiles.asMap().entries.map((entry) {
                            final index = entry.key;
                            final file = entry.value;
                            return FileAttachmentPreview(
                              file: file,
                              onRemove: () => _removeFile(index),
                            );
                          }).toList(),
                    ),
                  ),
                ),
              // Input row
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Container(
                      constraints: const BoxConstraints(
                        minHeight: 48,
                        maxHeight: 120,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color:
                              _isFocused
                                  ? AppColors.athenaBlue.withValues(
                                    alpha: _borderOpacity.value,
                                  )
                                  : Colors.black.withValues(alpha: 0.1),
                          width: _isFocused ? 2 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                                _isFocused
                                    ? AppColors.athenaBlue.withValues(
                                      alpha: 0.1,
                                    )
                                    : Colors.black.withValues(alpha: 0.05),
                            blurRadius: _isFocused ? 20 : 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const SizedBox(width: 18),
                          Expanded(
                            child: TextField(
                              controller: _textController,
                              focusNode: _focusNode,
                              textCapitalization: TextCapitalization.sentences,
                              minLines: 1,
                              maxLines: 4,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                height: 1.4,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Message Athena...',
                                hintStyle: TextStyle(
                                  color: Colors.black.withValues(alpha: 0.4),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                              onSubmitted:
                                  widget.isLoading
                                      ? null
                                      : (_) => _handleSend(),
                              enabled: !widget.isLoading,
                            ),
                          ),
                          // File upload button - always show
                          FileUploadWidget(
                            onFilesSelected: _onFilesSelected,
                            isEnabled: !widget.isLoading,
                          ),
                          // Microphone button
                          if (widget.onMicPressed != null && !_hasText)
                            Container(
                              margin: const EdgeInsets.only(
                                bottom: 4,
                                right: 4,
                              ),
                              child: IconButton(
                                icon: Icon(
                                  Icons.mic_none_rounded,
                                  color: Colors.black.withValues(alpha: 0.6),
                                  size: 20,
                                ),
                                onPressed:
                                    widget.isLoading
                                        ? null
                                        : widget.onMicPressed,
                                padding: const EdgeInsets.all(6),
                                constraints: const BoxConstraints(
                                  minWidth: 36,
                                  minHeight: 36,
                                ),
                              ),
                            ),
                          const SizedBox(width: 6),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    margin: const EdgeInsets.only(bottom: 4),
                    child: ScaleTransition(
                      scale: _sendButtonScale,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient:
                              _hasText && !widget.isLoading
                                  ? LinearGradient(
                                    colors: [
                                      AppColors.athenaBlue,
                                      AppColors.athenaPurple,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                  : null,
                          color:
                              _hasText && !widget.isLoading
                                  ? null
                                  : Colors.black.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                          boxShadow:
                              _hasText && !widget.isLoading
                                  ? [
                                    BoxShadow(
                                      color: AppColors.athenaBlue.withValues(
                                        alpha: 0.3,
                                      ),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                  : null,
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(24),
                            onTap:
                                (_hasText && !widget.isLoading)
                                    ? _handleSend
                                    : null,
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                              child:
                                  widget.isLoading
                                      ? Container(
                                        padding: const EdgeInsets.all(10),
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                _hasText
                                                    ? Colors.white
                                                    : AppColors.athenaBlue,
                                              ),
                                        ),
                                      )
                                      : Icon(
                                        _hasText
                                            ? Icons.send_rounded
                                            : Icons.arrow_upward_rounded,
                                        color:
                                            _hasText
                                                ? Colors.white
                                                : Colors.black.withValues(
                                                  alpha: 0.4,
                                                ),
                                        size: 20,
                                      ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

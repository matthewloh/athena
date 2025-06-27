import 'package:athena/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Widget for displaying flashcard-style quiz items during review sessions.
///
/// This widget provides an interactive flashcard interface where users can:
/// - View the question/term on the front
/// - Flip to reveal the answer/definition
/// - Use smooth animations for card flipping
class FlashcardWidget extends StatefulWidget {
  /// The question or term to display on the front of the card
  final String question;

  /// The answer or definition to display on the back of the card
  final String answer;

  /// Whether the answer is currently being shown
  final bool isShowingAnswer;

  /// Callback triggered when the user wants to flip the card
  final VoidCallback onFlip;

  const FlashcardWidget({
    super.key,
    required this.question,
    required this.answer,
    required this.isShowingAnswer,
    required this.onFlip,
  });

  @override
  State<FlashcardWidget> createState() => _FlashcardWidgetState();
}

class _FlashcardWidgetState extends State<FlashcardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _flipAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(FlashcardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isShowingAnswer != widget.isShowingAnswer) {
      if (widget.isShowingAnswer) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: widget.onFlip,
        child: AnimatedBuilder(
          animation: _flipAnimation,
          builder: (context, child) {
            final isShowingFront = _flipAnimation.value < 0.5;
            return Transform(
              alignment: Alignment.center,
              transform:
                  Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(_flipAnimation.value * 3.14159),
              child:
                  isShowingFront
                      ? _buildFrontCard(context)
                      : Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()..rotateY(3.14159),
                        child: _buildBackCard(context),
                      ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFrontCard(BuildContext context) {
    return _buildCard(
      context: context,
      content: widget.question,
      backgroundColor: Colors.white,
      textColor: AppColors.athenaDarkGrey,
      subtitle: 'Tap to reveal answer',
      subtitleColor: AppColors.athenaMediumGrey,
      icon: Icons.help_outline,
      iconColor: AppColors.athenaSupportiveGreen,
    );
  }

  Widget _buildBackCard(BuildContext context) {
    return _buildCard(
      context: context,
      content: widget.answer,
      backgroundColor: AppColors.athenaSupportiveGreen,
      textColor: Colors.white,
      subtitle: 'How well did you know this?',
      subtitleColor: Colors.white.withOpacity(0.8),
      icon: Icons.lightbulb_outline,
      iconColor: Colors.white,
    );
  }

  Widget _buildCard({
    required BuildContext context,
    required String content,
    required Color backgroundColor,
    required Color textColor,
    required String subtitle,
    required Color subtitleColor,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 300, maxHeight: 500),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 32),
          ),
          const SizedBox(height: 24),

          // Content
          Flexible(
            child: SingleChildScrollView(
              child: Text(
                content,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Subtitle
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.isShowingAnswer ? Icons.psychology : Icons.touch_app,
                color: subtitleColor,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: subtitleColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

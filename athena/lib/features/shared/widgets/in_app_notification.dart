import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

class InAppNotificationOverlay {
  static OverlayEntry? _currentOverlay;

  /// Show an in-app notification banner
  static void show(
    BuildContext context,
    RemoteMessage message, {
    Duration duration = const Duration(seconds: 4),
  }) {
    // Remove any existing overlay
    hide();

    final overlay = Overlay.of(context);
    if (overlay == null) return;

    _currentOverlay = OverlayEntry(
      builder: (context) => _InAppNotificationBanner(
        message: message,
        onDismiss: hide,
        onTap: () {
          hide();
          _handleNotificationTap(context, message);
        },
      ),
    );

    overlay.insert(_currentOverlay!);

    // Auto-dismiss after duration
    Future.delayed(duration, () {
      hide();
    });
  }

  /// Hide the current notification overlay
  static void hide() {
    _currentOverlay?.remove();
    _currentOverlay = null;
  }

  /// Handle notification tap navigation
  static void _handleNotificationTap(BuildContext context, RemoteMessage message) {
    final data = message.data;
    
    switch (data['type']) {
      case 'goal_created':
      case 'goal_completed':
      case 'goal_progress':
        // Navigate to planner screen
        context.go('/planner');
        break;
      case 'session_created':
      case 'session_completed':
        // Navigate to planner screen (schedule tab)
        context.go('/planner');
        break;
      default:
        // Navigate to home for unknown types
        context.go('/home');
    }
  }
}

class _InAppNotificationBanner extends StatefulWidget {
  final RemoteMessage message;
  final VoidCallback onDismiss;
  final VoidCallback onTap;

  const _InAppNotificationBanner({
    required this.message,
    required this.onDismiss,
    required this.onTap,
  });

  @override
  State<_InAppNotificationBanner> createState() => _InAppNotificationBannerState();
}

class _InAppNotificationBannerState extends State<_InAppNotificationBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  IconData _getNotificationIcon() {
    final type = widget.message.data['type'] ?? '';
    switch (type) {
      case 'goal_created':
        return Icons.flag;
      case 'goal_completed':
        return Icons.celebration;
      case 'goal_progress':
        return Icons.trending_up;
      case 'session_created':
        return Icons.schedule;
      case 'session_completed':
        return Icons.check_circle;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor() {
    final type = widget.message.data['type'] ?? '';
    switch (type) {
      case 'goal_completed':
      case 'session_completed':
        return Colors.green;
      case 'goal_progress':
        return AppColors.athenaPurple;
      case 'goal_created':
      case 'session_created':
        return Colors.blue;
      default:
        return AppColors.athenaPurple;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  margin: const EdgeInsets.all(16),
                  child: Material(
                    elevation: 8,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      onTap: widget.onTap,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _getNotificationColor(),
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            // Icon
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _getNotificationColor().withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                _getNotificationIcon(),
                                color: _getNotificationColor(),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            
                            // Content
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    widget.message.notification?.title ?? 'Notification',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (widget.message.notification?.body != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      widget.message.notification!.body!,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            
                            // Dismiss button
                            IconButton(
                              onPressed: widget.onDismiss,
                              icon: const Icon(Icons.close),
                              iconSize: 20,
                              color: Colors.grey[400],
                              splashRadius: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Helper class for showing quick snackbar-style notifications
class QuickNotification {
  static void show(
    BuildContext context,
    String message, {
    IconData? icon,
    Color? color,
    Duration duration = const Duration(seconds: 2),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: color ?? AppColors.athenaPurple,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
} 
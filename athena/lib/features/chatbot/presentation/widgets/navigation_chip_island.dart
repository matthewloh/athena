import 'package:athena/core/theme/app_colors.dart';
import 'package:athena/features/chatbot/domain/entities/chat_navigation_action.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NavigationChipIsland extends StatefulWidget {
  final List<ChatNavigationAction> actions;
  final String? title;

  const NavigationChipIsland({super.key, required this.actions, this.title});

  @override
  State<NavigationChipIsland> createState() => _NavigationChipIslandState();
}

class _NavigationChipIslandState extends State<NavigationChipIsland> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.actions.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 6.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.athenaBlue.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title and expand/collapse button
          Row(
            children: [
              if (widget.title != null) ...[
                Icon(Icons.link, size: 14, color: AppColors.athenaBlue),
                const SizedBox(width: 4),
                Text(
                  widget.title!,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.athenaDarkGrey,
                  ),
                ),
                const Spacer(),
              ] else
                const Spacer(),
              // Toggle button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => setState(() => _isExpanded = !_isExpanded),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: AppColors.athenaBlue.withValues(alpha: 0.1),
                    ),
                    child: Icon(
                      _isExpanded ? Icons.unfold_less : Icons.unfold_more,
                      size: 16,
                      color: AppColors.athenaBlue,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Chips layout based on expanded state
          _isExpanded ? _buildExpandedView() : _buildCompactView(),
        ],
      ),
    );
  }

  Widget _buildCompactView() {
    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: widget.actions.length,
        separatorBuilder: (context, index) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final action = widget.actions[index];
          return _NavigationChip(
            action: action,
            showTooltip: true,
            isCompact: true,
          );
        },
      ),
    );
  }

  Widget _buildExpandedView() {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: widget.actions
          .map((action) => _NavigationChip(
                action: action,
                showTooltip: false,
                isCompact: false,
              ))
          .toList(),
    );
  }
}

class _NavigationChip extends StatelessWidget {
  final ChatNavigationAction action;
  final bool showTooltip;
  final bool isCompact;

  const _NavigationChip({
    required this.action,
    this.showTooltip = false,
    this.isCompact = true,
  });

  Color _getChipColor(ChatNavigationActionType type) {
    switch (type) {
      case ChatNavigationActionType.primary:
        return AppColors.athenaBlue;
      case ChatNavigationActionType.material:
        return Colors.green;
      case ChatNavigationActionType.quiz:
        return Colors.orange;
      case ChatNavigationActionType.review:
        return AppColors.athenaPurple;
      case ChatNavigationActionType.planner:
        return Colors.teal;
      case ChatNavigationActionType.insights:
        return Colors.indigo;
      case ChatNavigationActionType.action:
        return Colors.red;
    }
  }

  void _handleNavigation(BuildContext context) {
    try {
      if (action.pathParameters != null && action.pathParameters!.isNotEmpty) {
        // Use named route with path parameters
        context.pushNamed(
          action.routeName,
          pathParameters: action.pathParameters!.cast<String, String>(),
          queryParameters: action.queryParameters!.cast<String, dynamic>(),
        );
      } else if (action.queryParameters != null &&
          action.queryParameters!.isNotEmpty) {
        // Use named route with query parameters only
        context.pushNamed(
          action.routeName,
          queryParameters: action.queryParameters!.cast<String, String>(),
        );
      } else {
        // Simple named route
        context.pushNamed(action.routeName);
      }
    } catch (e) {
      // Fallback to push by route name if pushNamed fails
      print('Navigation error: $e, falling back to go()');
      try {
        String path = _buildPath();
        context.go(path);
      } catch (fallbackError) {
        print('Fallback navigation error: $fallbackError');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Navigation failed: ${action.label}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _buildPath() {
    String path = '/${action.routeName}';

    // Add path parameters
    if (action.pathParameters != null) {
      action.pathParameters!.forEach((key, value) {
        path = path.replaceAll(':$key', value.toString());
      });
    }

    // Add query parameters
    if (action.queryParameters != null && action.queryParameters!.isNotEmpty) {
      final queryString = action.queryParameters!.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value.toString())}')
          .join('&');
      path += '?$queryString';
    }

    return path;
  }

  @override
  Widget build(BuildContext context) {
    final chipColor = _getChipColor(action.type);
    
    Widget chip = Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _handleNavigation(context),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isCompact ? 10 : 12,
            vertical: isCompact ? 6 : 8,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: chipColor.withValues(alpha: 0.25),
              width: 1,
            ),
            color: chipColor.withValues(alpha: 0.05),
          ),
          child: isCompact ? _buildCompactContent(chipColor) : _buildExpandedContent(chipColor),
        ),
      ),
    );

    // Wrap with tooltip if needed
    if (showTooltip && action.description != null) {
      return Tooltip(
        message: action.description!,
        decoration: BoxDecoration(
          color: chipColor.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
        child: chip,
      );
    }

    return chip;
  }

  Widget _buildCompactContent(Color chipColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (action.icon != null) ...[
          Text(action.icon!, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
        ],
        Flexible(
          child: Text(
            action.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: chipColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 3),
        Icon(
          Icons.arrow_forward_ios,
          size: 10,
          color: chipColor.withValues(alpha: 0.6),
        ),
      ],
    );
  }

  Widget _buildExpandedContent(Color chipColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (action.icon != null) ...[
          Text(action.icon!, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
        ],
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                action.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: chipColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (action.description != null) ...[
                const SizedBox(height: 2),
                Text(
                  action.description!,
                  style: TextStyle(
                    fontSize: 11,
                    color: chipColor.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 4),
        Icon(
          Icons.arrow_forward_ios,
          size: 12,
          color: chipColor.withValues(alpha: 0.7),
        ),
      ],
    );
  }
}

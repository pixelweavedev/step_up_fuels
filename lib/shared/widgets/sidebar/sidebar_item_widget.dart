import 'package:flutter/material.dart';
import 'package:step_up_fuels/core/constants/ui_constants.dart';
import 'package:step_up_fuels/core/theme/app_colors.dart';
import 'package:step_up_fuels/shared/widgets/sidebar/sidebar_item_model.dart';

/// A single navigation item in the sidebar.
class SidebarItemWidget extends StatefulWidget {
  const SidebarItemWidget({
    super.key,
    required this.item,
    required this.isActive,
    required this.onTap,
    this.isCollapsed = false,
  });

  final SidebarItemModel item;
  final bool isActive;
  final VoidCallback onTap;
  final bool isCollapsed;

  @override
  State<SidebarItemWidget> createState() => _SidebarItemWidgetState();
}

class _SidebarItemWidgetState extends State<SidebarItemWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: UiConstants.animFast,
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          padding: EdgeInsets.symmetric(
            horizontal: widget.isCollapsed ? 0 : 12,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: _isHovered
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: widget.isCollapsed
              ? _buildCollapsedItem()
              : _buildExpandedItem(),
        ),
      ),
    );
  }

  Widget _buildExpandedItem() {
    return Row(
      children: [
        // Active indicator bar
        AnimatedContainer(
          duration: UiConstants.animFast,
          width: 3,
          height: 18,
          margin: const EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            color: widget.isActive
                ? AppColors.sidebarActiveIndicator
                : Colors.transparent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        // Icon
        Icon(
          widget.isActive ? widget.item.activeIcon : widget.item.icon,
          size: UiConstants.sidebarIconSize,
          color: widget.isActive
              ? AppColors.sidebarIconActive
              : AppColors.sidebarIconInactive,
        ),
        const SizedBox(width: 10),
        // Label
        Expanded(
          child: Text(
            widget.item.label,
            style: TextStyle(
              fontSize: 13,
              fontWeight:
                  widget.isActive ? FontWeight.w600 : FontWeight.w400,
              color: widget.isActive
                  ? AppColors.sidebarTextActive
                  : AppColors.sidebarTextInactive,
            ),
          ),
        ),
        // Badge
        if (widget.item.badge != null && widget.item.badge! > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.brandAmber.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${widget.item.badge}',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.brandAmber,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCollapsedItem() {
    return Tooltip(
      message: widget.item.label,
      preferBelow: false,
      child: Center(
        child: Icon(
          widget.isActive ? widget.item.activeIcon : widget.item.icon,
          size: UiConstants.sidebarIconSize,
          color: widget.isActive
              ? AppColors.sidebarIconActive
              : AppColors.sidebarIconInactive,
        ),
      ),
    );
  }
}

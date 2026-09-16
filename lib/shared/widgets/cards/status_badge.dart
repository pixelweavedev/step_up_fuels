import 'package:flutter/material.dart';

enum StatusBadgeType { success, warning, error, info, neutral }

/// Unified, accessible status badge component for ERP entities.
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    this.type = StatusBadgeType.neutral,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.showDot = true,
  });

  final String label;
  final StatusBadgeType type;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final (defaultBg, defaultFg) = switch (type) {
      StatusBadgeType.success => (
        const Color(0xFF2E7D32).withValues(alpha: isDark ? 0.25 : 0.12),
        isDark ? const Color(0xFF81C784) : const Color(0xFF1B5E20),
      ),
      StatusBadgeType.warning => (
        const Color(0xFFD58B18).withValues(alpha: isDark ? 0.25 : 0.12),
        isDark ? const Color(0xFFFFB74D) : const Color(0xFFB05F19),
      ),
      StatusBadgeType.error => (
        const Color(0xFFB3261E).withValues(alpha: isDark ? 0.25 : 0.12),
        isDark ? const Color(0xFFEF9A9A) : const Color(0xFF8C1D18),
      ),
      StatusBadgeType.info => (
        const Color(0xFF2563EB).withValues(alpha: isDark ? 0.25 : 0.12),
        isDark ? const Color(0xFF93C5FD) : const Color(0xFF1D4ED8),
      ),
      StatusBadgeType.neutral => (
        isDark
            ? const Color(0xFF334155).withValues(alpha: 0.5)
            : const Color(0xFFE2E8F0),
        isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
      ),
    };

    final bg = backgroundColor ?? defaultBg;
    final fg = textColor ?? defaultFg;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: fg),
            const SizedBox(width: 4),
          ] else if (showDot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
            ),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: fg,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

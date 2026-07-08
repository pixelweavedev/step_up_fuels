import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:step_up_fuels/core/constants/ui_constants.dart';
import 'package:step_up_fuels/core/theme/app_colors.dart';
import 'package:step_up_fuels/shared/providers/theme_provider.dart';
import 'package:step_up_fuels/shared/widgets/sidebar/sidebar_widget.dart';

/// The root desktop shell: sidebar (left) + content area (right).
///
/// Used as the builder for GoRouter's [ShellRoute].
/// The [child] is the currently active feature screen.
class AppScaffold extends ConsumerStatefulWidget {
  const AppScaffold({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends ConsumerState<AppScaffold> {
  bool _isSidebarCollapsed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Row(
        children: [
          // ── Sidebar ──────────────────────────────────────────────────────
          SidebarWidget(
            isCollapsed: _isSidebarCollapsed,
            onToggleCollapse: () =>
                setState(() => _isSidebarCollapsed = !_isSidebarCollapsed),
          ),

          // ── Vertical Divider ─────────────────────────────────────────────
          VerticalDivider(
            width: 1,
            thickness: 1,
            color: theme.colorScheme.outline,
          ),

          // ── Content Area ─────────────────────────────────────────────────
          Expanded(
            child: Column(
              children: [
                _TopBar(isSidebarCollapsed: _isSidebarCollapsed),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: theme.colorScheme.outline,
                ),
                Expanded(child: widget.child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Top bar showing current time, company name, and quick actions.
class _TopBar extends ConsumerWidget {
  const _TopBar({required this.isSidebarCollapsed});

  final bool isSidebarCollapsed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: UiConstants.topBarHeight,
      color: AppColors.darkSurface,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Breadcrumb / current section label
          Text(
            _currentLabel(context),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.darkTextPrimary,
            ),
          ),
          const Spacer(),

          // Quick Actions
          _TopBarAction(
            icon: Icons.search_rounded,
            tooltip: 'Search',
            onTap: () {}, // Phase 2+
          ),
          const SizedBox(width: 4),
          _TopBarAction(
            icon: Icons.notifications_outlined,
            tooltip: 'Notifications',
            onTap: () {}, // Future
          ),
          const SizedBox(width: 4),
          // Theme Toggle
          _TopBarAction(
            icon: isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
            onTap: () => ref.toggleTheme(),
          ),
          const SizedBox(width: 4),
          _TopBarAction(
            icon: Icons.help_outline_rounded,
            tooltip: 'Help',
            onTap: () {}, // Future
          ),
          const SizedBox(width: 12),

          // User avatar placeholder
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.brandAmber.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.brandAmber.withValues(alpha: 0.4),
              ),
            ),
            child: const Icon(
              Icons.person_rounded,
              size: 18,
              color: AppColors.brandAmber,
            ),
          ),
        ],
      ),
    );
  }

  String _currentLabel(BuildContext context) {
    // In a real implementation, derive from GoRouterState or a provider.
    // For now, this is a placeholder.
    return 'Step Up Fuels ERP';
  }
}

class _TopBarAction extends StatelessWidget {
  const _TopBarAction({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 20, color: AppColors.darkTextSecondary),
        ),
      ),
    );
  }
}

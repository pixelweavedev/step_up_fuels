import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:step_up_fuels/app/router/route_names.dart';
import 'package:step_up_fuels/core/constants/ui_constants.dart';
import 'package:step_up_fuels/core/responsive/responsive_layout.dart';
import 'package:step_up_fuels/core/theme/app_colors.dart';
import 'package:step_up_fuels/shared/providers/theme_provider.dart';
import 'package:step_up_fuels/shared/widgets/navigation/app_bottom_nav.dart';
import 'package:step_up_fuels/shared/widgets/navigation/app_nav_items.dart';
import 'package:step_up_fuels/shared/widgets/navigation/app_navigation_rail.dart';
import 'package:step_up_fuels/shared/widgets/sidebar/sidebar_widget.dart';

/// Root application shell — chooses the correct navigation chrome based on
/// screen width and delegates content to the GoRouter [child].
///
/// Desktop  (≥ 1100 px): collapsible [SidebarWidget] + top bar + content.
/// Tablet   (900–1100 px): [AppNavigationRail] (icon + label) + content.
/// SmTablet (600–900 px): [AppNavigationRail] (icon only) + content.
/// Mobile   (<  600 px): AppBar + [AppBottomNav] + full-width content;
///                        Drawer holds all secondary nav items.
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
    final device = ResponsiveLayout.device(context);

    switch (device) {
      case DeviceType.desktop:
        return _buildDesktopShell(context);
      case DeviceType.tablet:
      case DeviceType.smallTablet:
        return _buildRailShell(context);
      case DeviceType.mobile:
        return _buildMobileShell(context);
    }
  }

  // ── Desktop Shell ──────────────────────────────────────────────────────────

  Widget _buildDesktopShell(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Row(
        children: [
          SidebarWidget(
            isCollapsed: _isSidebarCollapsed,
            onToggleCollapse: () =>
                setState(() => _isSidebarCollapsed = !_isSidebarCollapsed),
          ),
          VerticalDivider(
            width: 1,
            thickness: 1,
            color: theme.colorScheme.outline,
          ),
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

  // ── Tablet / Small-Tablet Shell (NavigationRail) ───────────────────────────

  Widget _buildRailShell(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Row(
        children: [
          // Navigation Rail
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkThemeSidebar : Colors.white,
              border: Border(
                right: BorderSide(color: AppColors.darkBorder, width: 1),
              ),
            ),
            child: const AppNavigationRail(),
          ),
          // Content
          Expanded(
            child: Column(
              children: [
                _TopBar(isSidebarCollapsed: true),
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

  // ── Mobile Shell ───────────────────────────────────────────────────────────

  Widget _buildMobileShell(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _MobileAppBar(ref: ref),
      drawer: _buildDrawer(context, isDark),
      body: widget.child,
      bottomNavigationBar: const AppBottomNav(),
    );
  }

  /// Drawer with all navigation items — used on mobile.
  Widget _buildDrawer(BuildContext context, bool isDark) {
    final location = GoRouterState.of(context).uri.toString();

    return Drawer(
      backgroundColor: isDark ? AppColors.darkThemeSidebar : Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.brandAmber, AppColors.brandAmberDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.local_gas_station_rounded,
                      color: AppColors.brandNavy,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Step Up Fuels',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkTextPrimary,
                        ),
                      ),
                      Text(
                        'ERP System',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.darkTextTertiary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Divider(color: AppColors.darkBorder, height: 1),
            // All nav items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: _buildDrawerItems(context, location),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDrawerItems(BuildContext context, String location) {
    final List<Widget> widgets = [];
    String? lastSection;

    for (final item in AppNavItems.all) {
      if (item.section != null && item.section != lastSection) {
        lastSection = item.section;
        widgets.add(
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 16, 4),
            child: Text(
              item.section!,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.sidebarTextInactive,
                letterSpacing: 1.0,
              ),
            ),
          ),
        );
      }

      final isActive = item.route == RouteNames.dashboard
          ? location == item.route
          : location.startsWith(item.route);

      widgets.add(
        ListTile(
          dense: true,
          leading: Icon(
            isActive ? item.activeIcon : item.icon,
            size: 20,
            color: isActive ? AppColors.brandAmber : AppColors.sidebarIconInactive,
          ),
          title: Text(
            item.label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              color: isActive ? AppColors.brandAmber : AppColors.darkTextSecondary,
            ),
          ),
          selected: isActive,
          selectedTileColor: AppColors.brandAmber.withValues(alpha: 0.08),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          onTap: () {
            Navigator.of(context).pop(); // close drawer
            context.go(item.route);
          },
        ),
      );
    }
    return widgets;
  }
}

// ── Top Bar ────────────────────────────────────────────────────────────────

/// Top bar shown on desktop and tablet layouts.
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
          Text(
            'Step Up Fuels ERP',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.darkTextPrimary,
            ),
          ),
          const Spacer(),
          _TopBarAction(
            icon: Icons.search_rounded,
            tooltip: 'Search',
            onTap: () {},
          ),
          const SizedBox(width: 4),
          _TopBarAction(
            icon: Icons.notifications_outlined,
            tooltip: 'Notifications',
            onTap: () {},
          ),
          const SizedBox(width: 4),
          _TopBarAction(
            icon: isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
            onTap: () => ref.toggleTheme(),
          ),
          const SizedBox(width: 4),
          _TopBarAction(
            icon: Icons.help_outline_rounded,
            tooltip: 'Help',
            onTap: () {},
          ),
          const SizedBox(width: 12),
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
}

// ── Mobile AppBar ──────────────────────────────────────────────────────────

class _MobileAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const _MobileAppBar({required this.ref});

  final WidgetRef ref;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      backgroundColor: AppColors.darkSurface,
      foregroundColor: AppColors.darkTextPrimary,
      elevation: 0,
      titleSpacing: 0,
      title: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            margin: const EdgeInsets.only(left: 4),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.brandAmber, AppColors.brandAmberDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(7),
            ),
            child: const Icon(
              Icons.local_gas_station_rounded,
              color: AppColors.brandNavy,
              size: 16,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Step Up Fuels',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.darkTextPrimary,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(
            isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            color: AppColors.darkTextSecondary,
          ),
          tooltip: isDark ? 'Light Mode' : 'Dark Mode',
          onPressed: () => ref.toggleTheme(),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Container(
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
        ),
      ],
    );
  }
}

// ── Top Bar Action Button ──────────────────────────────────────────────────

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

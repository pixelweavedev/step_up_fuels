import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:step_up_fuels/app/router/route_names.dart';
import 'package:step_up_fuels/core/constants/ui_constants.dart';
import 'package:step_up_fuels/core/responsive/adaptive_scaffold.dart';
import 'package:step_up_fuels/core/theme/app_colors.dart';
import 'package:step_up_fuels/shared/providers/theme_provider.dart';
import 'package:step_up_fuels/shared/widgets/navigation/app_bottom_nav.dart';
import 'package:step_up_fuels/shared/widgets/navigation/app_nav_items.dart';
import 'package:step_up_fuels/shared/widgets/navigation/app_navigation_rail.dart';
import 'package:step_up_fuels/shared/widgets/sidebar/sidebar_widget.dart';

/// Root application shell — chooses the correct navigation chrome based on
/// screen width and delegates content to the GoRouter [child].
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
    final isDark = theme.brightness == Brightness.dark;

    final navContainerDecoration = BoxDecoration(
      color: isDark ? AppColors.darkThemeSidebar : Colors.white,
      border: Border(right: BorderSide(color: AppColors.darkBorder)),
    );

    return AdaptiveScaffold(
      body: widget.child,
      desktopSidebar: SidebarWidget(
        isCollapsed: _isSidebarCollapsed,
        onToggleCollapse: () =>
            setState(() => _isSidebarCollapsed = !_isSidebarCollapsed),
      ),
      tabletNavigationRail: Container(
        decoration: navContainerDecoration,
        child: const AppNavigationRail(),
      ),
      smallTabletNavigationRail: Container(
        decoration: navContainerDecoration,
        child: const AppNavigationRail(),
      ),
      mobileBottomNavBar: const AppBottomNav(),
      mobileAppBar: _MobileAppBar(ref: ref),
      mobileDrawer: _buildDrawer(context, isDark),
      topBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _TopBar(isSidebarCollapsed: _isSidebarCollapsed),
          Divider(height: 1, thickness: 1, color: theme.colorScheme.outline),
        ],
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
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
                        colors: [
                          AppColors.brandAmber,
                          AppColors.brandAmberDark,
                        ],
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
            color: isActive
                ? AppColors.brandAmber
                : AppColors.sidebarIconInactive,
          ),
          title: Text(
            item.label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              color: isActive
                  ? AppColors.brandAmber
                  : AppColors.darkTextSecondary,
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
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppBar(
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      foregroundColor:
          isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
      elevation: 0,
      titleSpacing: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          height: 1,
        ),
      ),
      title: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(left: 2),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.brandAmber, AppColors.brandAmberDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: AppColors.brandAmber.withValues(alpha: 0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.local_gas_station_rounded,
              color: AppColors.brandNavy,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Step Up Fuels',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
              Text(
                'ERP • Main Terminal',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? AppColors.darkTextTertiary
                      : AppColors.lightTextTertiary,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(
            isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
            size: 20,
          ),
          tooltip: isDark ? 'Light Mode' : 'Dark Mode',
          onPressed: () => ref.toggleTheme(),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.brandAmber.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.brandAmber.withValues(alpha: 0.3),
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

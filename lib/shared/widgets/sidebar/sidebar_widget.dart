import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:step_up_fuels/app/router/route_names.dart';
import 'package:step_up_fuels/core/constants/app_constants.dart';
import 'package:step_up_fuels/core/constants/ui_constants.dart';
import 'package:step_up_fuels/core/theme/app_colors.dart';
import 'package:step_up_fuels/shared/widgets/navigation/app_nav_items.dart';
import 'package:step_up_fuels/shared/widgets/sidebar/sidebar_item_model.dart';
import 'package:step_up_fuels/shared/widgets/sidebar/sidebar_item_widget.dart';

/// The application sidebar — desktop navigation.
///
/// Navigation items are sourced from [AppNavItems.all] (single source of
/// truth).  The sidebar converts each [AppNavItem] to a [SidebarItemModel]
/// for rendering via [SidebarItemWidget].
///
/// Supports expanded and collapsed modes.
class SidebarWidget extends ConsumerWidget {
  const SidebarWidget({
    super.key,
    this.isCollapsed = false,
    this.onToggleCollapse,
  });

  final bool isCollapsed;
  final VoidCallback? onToggleCollapse;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final location = GoRouterState.of(context).uri.toString();
    final width = isCollapsed
        ? UiConstants.sidebarCollapsedWidth
        : UiConstants.sidebarWidth;

    return AnimatedContainer(
      duration: UiConstants.animMedium,
      width: width,
      color: isDark ? AppColors.darkThemeSidebar : Colors.white,
      child: Column(
        children: [
          _buildHeader(context),
          Divider(color: theme.colorScheme.outline, height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: _buildNavItems(context, location),
            ),
          ),
          Divider(color: theme.colorScheme.outline, height: 1),
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SizedBox(
      height: UiConstants.sidebarLogoHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.brandAmber, AppColors.brandAmberDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.local_gas_station_rounded,
                color: AppColors.brandNavy,
                size: 18,
              ),
            ),
            if (!isCollapsed) ...[
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppConstants.companyName,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkTextPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'ERP System',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.darkTextTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _buildNavItems(BuildContext context, String location) {
    final List<Widget> widgets = [];
    String? lastSection;

    for (final navItem in AppNavItems.all) {
      // Section header
      if (navItem.section != null && navItem.section != lastSection) {
        lastSection = navItem.section;
        if (!isCollapsed) {
          widgets.add(
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 16, 6),
              child: Text(
                navItem.section!,
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
      }

      // Convert AppNavItem → SidebarItemModel for the existing SidebarItemWidget
      final sidebarItem = SidebarItemModel(
        label: navItem.label,
        icon: navItem.icon,
        activeIcon: navItem.activeIcon,
        route: navItem.route,
        badge: navItem.badge,
        section: navItem.section,
      );

      widgets.add(
        SidebarItemWidget(
          item: sidebarItem,
          isActive: _isItemActive(location, navItem.route),
          isCollapsed: isCollapsed,
          onTap: () => context.go(navItem.route),
        ),
      );
    }

    return widgets;
  }

  Widget _buildFooter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: InkWell(
        onTap: onToggleCollapse,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisAlignment: isCollapsed
                ? MainAxisAlignment.center
                : MainAxisAlignment.end,
            children: [
              Icon(
                isCollapsed
                    ? Icons.chevron_right_rounded
                    : Icons.chevron_left_rounded,
                color: AppColors.sidebarIconInactive,
                size: 20,
              ),
              if (!isCollapsed)
                Text(
                  ' Collapse',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.sidebarTextInactive,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isItemActive(String location, String route) {
    if (route == RouteNames.dashboard) return location == route;
    return location.startsWith(route);
  }
}

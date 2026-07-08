/// Bottom navigation bar built from the shared [AppNavItems] primary list.
///
/// Used in the [AppScaffold] on mobile (< 600 px).
/// Only the 5 primary destinations (Dashboard, Customers, Invoices,
/// Purchases, Settings) appear here.  All other items live in the Drawer.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:step_up_fuels/app/router/route_names.dart';
import 'package:step_up_fuels/core/theme/app_colors.dart';
import 'package:step_up_fuels/shared/widgets/navigation/app_nav_items.dart';

/// [BottomNavigationBar] for the mobile layout.
///
/// Reads from [AppNavItems.primary] — the 5 flagged primary destinations.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final items = AppNavItems.primary;

    int selectedIndex = items.indexWhere(
      (item) => item.route == RouteNames.dashboard
          ? location == item.route
          : location.startsWith(item.route),
    );
    if (selectedIndex < 0) selectedIndex = 0;

    return NavigationBar(
      backgroundColor: isDark ? AppColors.darkThemeSidebar : Colors.white,
      selectedIndex: selectedIndex,
      indicatorColor: AppColors.brandAmber.withValues(alpha: 0.15),
      labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
      onDestinationSelected: (index) => context.go(items[index].route),
      destinations: items.map((item) {
        return NavigationDestination(
          icon: Icon(
            item.icon,
            color: AppColors.sidebarIconInactive,
          ),
          selectedIcon: Icon(
            item.activeIcon,
            color: AppColors.brandAmber,
          ),
          label: item.label,
          tooltip: item.label,
        );
      }).toList(),
    );
  }
}

/// Flutter NavigationRail built from the shared [AppNavItems] list.
///
/// Used in the [AppScaffold] for tablet and small-tablet breakpoints.
/// Shows icons only on small tablet, icons + labels on tablet.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:step_up_fuels/app/router/route_names.dart';
import 'package:step_up_fuels/core/responsive/responsive_layout.dart';
import 'package:step_up_fuels/core/theme/app_colors.dart';
import 'package:step_up_fuels/shared/widgets/navigation/app_nav_items.dart';

/// Navigation rail used on tablet and small-tablet screen sizes.
///
/// Consumes [AppNavItems.all] — adding a route there automatically
/// appears here without any further changes.
class AppNavigationRail extends StatelessWidget {
  const AppNavigationRail({super.key});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSmall = ResponsiveLayout.isSmallTablet(context);

    const items = AppNavItems.all;

    // Resolve selected index from the current route.
    int selectedIndex = items.indexWhere(
      (item) => item.route == RouteNames.dashboard
          ? location == item.route
          : location.startsWith(item.route),
    );
    if (selectedIndex < 0) selectedIndex = 0;

    return NavigationRail(
      backgroundColor: isDark ? AppColors.darkThemeSidebar : Colors.white,
      selectedIndex: selectedIndex,
      // Icon-only on small tablet; icon + selected-label on regular tablet.
      labelType: isSmall
          ? NavigationRailLabelType.none
          : NavigationRailLabelType.selected,
      selectedIconTheme: const IconThemeData(color: AppColors.brandAmber),
      unselectedIconTheme: IconThemeData(color: AppColors.sidebarIconInactive),
      selectedLabelTextStyle: const TextStyle(
        color: AppColors.brandAmber,
        fontWeight: FontWeight.w600,
        fontSize: 11,
      ),
      unselectedLabelTextStyle: TextStyle(
        color: AppColors.sidebarTextInactive,
        fontSize: 11,
      ),
      indicatorColor: AppColors.brandAmber.withValues(alpha: 0.12),
      leading: _buildLogo(),
      destinations: items.map((item) {
        return NavigationRailDestination(
          icon: Tooltip(
            message: item.label,
            preferBelow: false,
            child: Icon(item.icon),
          ),
          selectedIcon: Tooltip(
            message: item.label,
            preferBelow: false,
            child: Icon(item.activeIcon),
          ),
          label: Text(item.label),
        );
      }).toList(),
      onDestinationSelected: (index) => context.go(items[index].route),
    );
  }

  Widget _buildLogo() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Container(
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
    );
  }
}

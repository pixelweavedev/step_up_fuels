import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:step_up_fuels/app/router/route_names.dart';
import 'package:step_up_fuels/core/constants/app_constants.dart';
import 'package:step_up_fuels/core/constants/ui_constants.dart';
import 'package:step_up_fuels/core/theme/app_colors.dart';
import 'package:step_up_fuels/shared/widgets/sidebar/sidebar_item_model.dart';
import 'package:step_up_fuels/shared/widgets/sidebar/sidebar_item_widget.dart';

/// The application sidebar with all navigation items.
///
/// Supports expanded and collapsed modes. The active item is derived
/// from the current GoRouter location.
class SidebarWidget extends ConsumerWidget {
  const SidebarWidget({
    super.key,
    this.isCollapsed = false,
    this.onToggleCollapse,
  });

  final bool isCollapsed;
  final VoidCallback? onToggleCollapse;

  static const List<SidebarItemModel> _navItems = [
    // ── Overview ───────────────────────────────────────────────────────────
    SidebarItemModel(
      label: 'Dashboard',
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard_rounded,
      route: RouteNames.dashboard,
      section: 'OVERVIEW',
    ),

    // ── Operations ─────────────────────────────────────────────────────────
    SidebarItemModel(
      label: 'Customers',
      icon: Icons.people_outline_rounded,
      activeIcon: Icons.people_rounded,
      route: RouteNames.customers,
      section: 'OPERATIONS',
    ),
    SidebarItemModel(
      label: 'Products',
      icon: Icons.inventory_2_outlined,
      activeIcon: Icons.inventory_2_rounded,
      route: RouteNames.products,
    ),
    SidebarItemModel(
      label: 'Inventory',
      icon: Icons.local_gas_station_outlined,
      activeIcon: Icons.local_gas_station_rounded,
      route: RouteNames.inventory,
    ),
    SidebarItemModel(
      label: 'Purchases',
      icon: Icons.shopping_cart_outlined,
      activeIcon: Icons.shopping_cart_rounded,
      route: RouteNames.purchases,
    ),

    // ── Finance ────────────────────────────────────────────────────────────
    SidebarItemModel(
      label: 'Invoices',
      icon: Icons.receipt_long_outlined,
      activeIcon: Icons.receipt_long_rounded,
      route: RouteNames.invoices,
      section: 'FINANCE',
    ),
    SidebarItemModel(
      label: 'Payments',
      icon: Icons.payments_outlined,
      activeIcon: Icons.payments_rounded,
      route: RouteNames.payments,
    ),
    SidebarItemModel(
      label: 'Ledger',
      icon: Icons.account_balance_outlined,
      activeIcon: Icons.account_balance_rounded,
      route: RouteNames.ledger,
    ),

    // ── Analytics ──────────────────────────────────────────────────────────
    SidebarItemModel(
      label: 'Reports',
      icon: Icons.bar_chart_outlined,
      activeIcon: Icons.bar_chart_rounded,
      route: RouteNames.reports,
      section: 'ANALYTICS',
    ),

    // ── System ─────────────────────────────────────────────────────────────
    SidebarItemModel(
      label: 'Settings',
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings_rounded,
      route: RouteNames.settings,
      section: 'SYSTEM',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.toString();
    final width = isCollapsed
        ? UiConstants.sidebarCollapsedWidth
        : UiConstants.sidebarWidth;

    return AnimatedContainer(
      duration: UiConstants.animMedium,
      width: width,
      color: AppColors.darkSidebar,
      child: Column(
        children: [
          _buildHeader(context),
          const Divider(color: AppColors.darkBorder, height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: _buildNavItems(context, location),
            ),
          ),
          const Divider(color: AppColors.darkBorder, height: 1),
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
              const Expanded(
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

    for (final item in _navItems) {
      if (item.section != null && item.section != lastSection) {
        lastSection = item.section;
        if (!isCollapsed) {
          widgets.add(
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 16, 6),
              child: Text(
                item.section!,
                style: const TextStyle(
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

      widgets.add(
        SidebarItemWidget(
          item: item,
          isActive: _isItemActive(location, item.route),
          isCollapsed: isCollapsed,
          onTap: () => context.go(item.route),
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
                const Text(
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

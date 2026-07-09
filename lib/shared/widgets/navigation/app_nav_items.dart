/// Single source of truth for all application navigation destinations.
///
/// [AppNavItem] replaces [SidebarItemModel] and is consumed by:
///   - [SidebarWidget]        (desktop)
///   - [AppNavigationRail]    (tablet / small tablet)
///   - [AppBottomNav]         (mobile)
///
/// Adding a new route only requires editing [AppNavItems.all].
library;

import 'package:flutter/material.dart';
import 'package:step_up_fuels/app/router/route_names.dart';

/// A single navigation destination descriptor.
class AppNavItem {
  const AppNavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.route,
    this.section,
    this.badge,
  });

  /// Human-readable label shown in sidebar and rail.
  final String label;

  /// Icon when inactive.
  final IconData icon;

  /// Icon when this destination is active.
  final IconData activeIcon;

  /// GoRouter path (e.g. '/dashboard').
  final String route;

  /// Optional section header (sidebar only — 'OVERVIEW', 'OPERATIONS', …).
  final String? section;

  /// Optional notification badge count.
  final int? badge;

  /// Whether this item should appear in the bottom navigation bar.
  bool get isPrimaryDestination => _primaryRoutes.contains(route);
}

// ── Primary bottom-nav destinations (5 max) ───────────────────────────────

const _primaryRoutes = {
  RouteNames.dashboard,
  RouteNames.customers,
  RouteNames.invoices,
  RouteNames.purchases,
  RouteNames.settings,
};

// ── All navigation items ───────────────────────────────────────────────────

/// The complete ordered list of navigation items for the application.
///
/// Change this list to add, remove, or reorder navigation entries.
/// All navigation widgets (Sidebar, Rail, BottomNav, Drawer) read from here.
class AppNavItems {
  AppNavItems._();

  static const List<AppNavItem> all = [
    // ── Overview ──────────────────────────────────────────────────────────
    AppNavItem(
      label: 'Dashboard',
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard_rounded,
      route: RouteNames.dashboard,
      section: 'OVERVIEW',
    ),

    // ── Operations ────────────────────────────────────────────────────────
    AppNavItem(
      label: 'Customers',
      icon: Icons.people_outline_rounded,
      activeIcon: Icons.people_rounded,
      route: RouteNames.customers,
      section: 'OPERATIONS',
    ),
    AppNavItem(
      label: 'Vehicles',
      icon: Icons.local_shipping_outlined,
      activeIcon: Icons.local_shipping_rounded,
      route: RouteNames.vehicles,
    ),
    AppNavItem(
      label: 'Drivers',
      icon: Icons.badge_outlined,
      activeIcon: Icons.badge_rounded,
      route: RouteNames.drivers,
    ),
    AppNavItem(
      label: 'Products',
      icon: Icons.inventory_2_outlined,
      activeIcon: Icons.inventory_2_rounded,
      route: RouteNames.products,
    ),
    AppNavItem(
      label: 'Inventory',
      icon: Icons.local_gas_station_outlined,
      activeIcon: Icons.local_gas_station_rounded,
      route: RouteNames.inventory,
    ),
    AppNavItem(
      label: 'Purchases',
      icon: Icons.shopping_cart_outlined,
      activeIcon: Icons.shopping_cart_rounded,
      route: RouteNames.purchases,
    ),

    // ── Finance ───────────────────────────────────────────────────────────
    AppNavItem(
      label: 'Invoices',
      icon: Icons.receipt_long_outlined,
      activeIcon: Icons.receipt_long_rounded,
      route: RouteNames.invoices,
      section: 'FINANCE',
    ),
    AppNavItem(
      label: 'Payments',
      icon: Icons.payments_outlined,
      activeIcon: Icons.payments_rounded,
      route: RouteNames.payments,
    ),
    AppNavItem(
      label: 'Ledger',
      icon: Icons.account_balance_outlined,
      activeIcon: Icons.account_balance_rounded,
      route: RouteNames.ledger,
    ),

    // ── Analytics ─────────────────────────────────────────────────────────
    AppNavItem(
      label: 'Reports',
      icon: Icons.bar_chart_outlined,
      activeIcon: Icons.bar_chart_rounded,
      route: RouteNames.reports,
      section: 'ANALYTICS',
    ),

    // ── System ────────────────────────────────────────────────────────────
    AppNavItem(
      label: 'Data Import & Export',
      icon: Icons.swap_horizontal_circle_outlined,
      activeIcon: Icons.swap_horizontal_circle_rounded,
      route: RouteNames.importExport,
      section: 'SYSTEM',
    ),
    AppNavItem(
      label: 'Settings',
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings_rounded,
      route: RouteNames.settings,
    ),
  ];

  /// The 5 primary items shown in the bottom navigation bar on mobile.
  static List<AppNavItem> get primary =>
      all.where((item) => item.isPrimaryDestination).toList();
}

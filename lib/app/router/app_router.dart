import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:step_up_fuels/app/router/route_names.dart';
import 'package:step_up_fuels/features/customers/presentation/screens/customers_screen.dart';
import 'package:step_up_fuels/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:step_up_fuels/features/drivers/presentation/screens/drivers_screen.dart';
import 'package:step_up_fuels/features/inventory/presentation/screens/inventory_screen.dart';
import 'package:step_up_fuels/features/invoices/presentation/screens/invoices_screen.dart';
import 'package:step_up_fuels/features/ledger/presentation/screens/ledger_screen.dart';
import 'package:step_up_fuels/features/payments/presentation/screens/payments_screen.dart';
import 'package:step_up_fuels/features/reports/presentation/screens/reports_screen.dart';
import 'package:step_up_fuels/features/products/presentation/screens/products_screen.dart';
import 'package:step_up_fuels/features/purchases/presentation/screens/purchases_screen.dart';
import 'package:step_up_fuels/features/vehicles/presentation/screens/vehicles_screen.dart';
import 'package:step_up_fuels/shared/widgets/app_scaffold.dart';

/// Global router provider — accessible from anywhere via ref.read/watch.
final routerProvider = Provider<GoRouter>((ref) {
  return AppRouter.router;
});

/// Configures the application's GoRouter with shell route and all feature routes.
class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: RouteNames.dashboard,
    debugLogDiagnostics: true,
    routes: [
      ShellRoute(
        builder: (context, state, child) => AppScaffold(child: child),
        routes: [
          // ── Dashboard ─────────────────────────────────────────────────────
          GoRoute(
            path: RouteNames.dashboard,
            name: 'dashboard',
            pageBuilder: (context, state) => _fadeTransitionPage(
              state: state,
              child: const DashboardScreen(),
            ),
          ),

          // ── Customers ────────────────────────────────────────────────────
          GoRoute(
            path: RouteNames.customers,
            name: 'customers',
            pageBuilder: (context, state) => _fadeTransitionPage(
              state: state,
              child: const CustomersScreen(),
            ),
          ),

          // ── Products ─────────────────────────────────────────────────────
          GoRoute(
            path: RouteNames.products,
            name: 'products',
            pageBuilder: (context, state) => _fadeTransitionPage(
              state: state,
              child: const ProductsScreen(),
            ),
          ),

          // ── Inventory ────────────────────────────────────────────────────
          GoRoute(
            path: RouteNames.inventory,
            name: 'inventory',
            pageBuilder: (context, state) => _fadeTransitionPage(
              state: state,
              child: const InventoryScreen(),
            ),
          ),

          // ── Vehicles ─────────────────────────────────────────────────────
          GoRoute(
            path: RouteNames.vehicles,
            name: 'vehicles',
            pageBuilder: (context, state) => _fadeTransitionPage(
              state: state,
              child: const VehiclesScreen(),
            ),
          ),

          // ── Drivers ──────────────────────────────────────────────────────
          GoRoute(
            path: RouteNames.drivers,
            name: 'drivers',
            pageBuilder: (context, state) => _fadeTransitionPage(
              state: state,
              child: const DriversScreen(),
            ),
          ),

          // ── Purchases ────────────────────────────────────────────────────
          GoRoute(
            path: RouteNames.purchases,
            name: 'purchases',
            pageBuilder: (context, state) => _fadeTransitionPage(
              state: state,
              child: const PurchasesScreen(),
            ),
          ),

          // ── Invoices ─────────────────────────────────────────────────────
          GoRoute(
            path: RouteNames.invoices,
            name: 'invoices',
            pageBuilder: (context, state) => _fadeTransitionPage(
              state: state,
              child: const InvoicesScreen(),
            ),
          ),

          // ── Payments ─────────────────────────────────────────────────────
          GoRoute(
            path: RouteNames.payments,
            name: 'payments',
            pageBuilder: (context, state) => _fadeTransitionPage(
              state: state,
              child: const PaymentsScreen(),
            ),
          ),

          // ── Ledger ───────────────────────────────────────────────────────
          GoRoute(
            path: RouteNames.ledger,
            name: 'ledger',
            pageBuilder: (context, state) =>
                _fadeTransitionPage(state: state, child: const LedgerScreen()),
          ),

          // ── Reports ──────────────────────────────────────────────────────
          GoRoute(
            path: RouteNames.reports,
            name: 'reports',
            pageBuilder: (context, state) =>
                _fadeTransitionPage(state: state, child: const ReportsScreen()),
          ),

          // ── Settings ─────────────────────────────────────────────────────
          GoRoute(
            path: RouteNames.settings,
            name: 'settings',
            pageBuilder: (context, state) => _fadeTransitionPage(
              state: state,
              child: const SettingsScreen(),
            ),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Page not found: ${state.uri}'),
          ],
        ),
      ),
    ),
  );

  /// Smooth fade transition between routes (no jarring slide animations in desktop).
  static CustomTransitionPage<void> _fadeTransitionPage({
    required GoRouterState state,
    required Widget child,
  }) => CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 180),
    reverseTransitionDuration: const Duration(milliseconds: 120),
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        FadeTransition(opacity: animation, child: child),
  );
}

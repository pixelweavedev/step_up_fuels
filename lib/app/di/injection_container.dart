import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:step_up_fuels/app/database/app_database.dart';
import 'package:step_up_fuels/core/logging/app_logger.dart';

/// Global service locator instance.
final GetIt sl = GetIt.instance;

/// Riverpod provider exposing the AppDatabase from GetIt.
///
/// Use this in feature providers instead of calling sl<AppDatabase>() directly.
/// This makes providers testable — you can override this in tests.
final databaseProvider = Provider<AppDatabase>((ref) {
  return sl<AppDatabase>();
});

/// Sets up all dependencies in the GetIt service locator.
///
/// Call this once in [main()] before running the app.
/// Feature-specific registrations will be added as each phase is implemented.
Future<void> configureDependencies() async {
  AppLogger.info('Configuring dependencies...');

  // ── Database ───────────────────────────────────────────────────────────────
  sl.registerSingleton<AppDatabase>(AppDatabase());
  AppLogger.info('AppDatabase registered');

  // ── Phase 2: Customer Dependencies ─────────────────────────────────────────
  // sl.registerSingleton<CustomersDao>(CustomersDao(sl()));
  // sl.registerSingleton<CustomerRepository>(CustomerRepositoryImpl(sl()));

  // ── Phase 3: Inventory Dependencies ────────────────────────────────────────
  // sl.registerSingleton<ProductsDao>(ProductsDao(sl()));
  // sl.registerSingleton<InventoryService>(InventoryServiceImpl(sl()));

  // ── Phase 4: Invoice Dependencies ──────────────────────────────────────────
  // sl.registerSingleton<InvoicesDao>(InvoicesDao(sl()));
  // sl.registerSingleton<GstCalculationService>(GstCalculationServiceImpl());
  // sl.registerSingleton<InvoiceService>(InvoiceServiceImpl(sl(), sl(), sl()));

  // ── Phase 5: Purchase Dependencies ─────────────────────────────────────────
  // sl.registerSingleton<PurchasesDao>(PurchasesDao(sl()));

  // ── Phase 6: Payment + Ledger Dependencies ─────────────────────────────────
  // sl.registerSingleton<LedgerService>(LedgerServiceImpl(sl()));
  // sl.registerSingleton<PaymentService>(PaymentServiceImpl(sl(), sl()));

  AppLogger.info('All dependencies configured successfully');
}

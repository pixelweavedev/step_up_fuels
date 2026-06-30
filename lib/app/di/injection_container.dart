import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:step_up_fuels/app/database/app_database.dart';
import 'package:step_up_fuels/core/logging/app_logger.dart';
import 'package:step_up_fuels/features/customers/application/usecases/create_customer_usecase.dart';
import 'package:step_up_fuels/features/customers/application/usecases/get_customer_detail_usecase.dart';
import 'package:step_up_fuels/features/customers/application/usecases/get_customers_usecase.dart';
import 'package:step_up_fuels/features/customers/application/usecases/restore_customer_usecase.dart';
import 'package:step_up_fuels/features/customers/application/usecases/soft_delete_customer_usecase.dart';
import 'package:step_up_fuels/features/customers/application/usecases/update_customer_usecase.dart';
import 'package:step_up_fuels/features/customers/data/daos/customers_dao.dart';
import 'package:step_up_fuels/features/customers/data/repositories/customer_repository_impl.dart';
import 'package:step_up_fuels/features/customers/domain/repositories/customer_repository.dart';
import 'package:step_up_fuels/features/customers/domain/services/customer_credit_service.dart';

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
  final customersDao = CustomersDao(sl<AppDatabase>());
  sl.registerSingleton<CustomersDao>(customersDao);
  sl.registerSingleton<CustomerRepository>(
    CustomerRepositoryImpl(sl<CustomersDao>()),
  );
  sl.registerSingleton<CustomerCreditService>(
    CustomerCreditService(sl<CustomerRepository>()),
  );

  sl.registerSingleton<CreateCustomerUseCase>(
    CreateCustomerUseCase(sl<CustomerRepository>()),
  );
  sl.registerSingleton<UpdateCustomerUseCase>(
    UpdateCustomerUseCase(sl<CustomerRepository>()),
  );
  sl.registerSingleton<SoftDeleteCustomerUseCase>(
    SoftDeleteCustomerUseCase(sl<CustomerRepository>()),
  );
  sl.registerSingleton<RestoreCustomerUseCase>(
    RestoreCustomerUseCase(sl<CustomerRepository>()),
  );
  sl.registerSingleton<GetCustomersUseCase>(
    GetCustomersUseCase(sl<CustomerRepository>()),
  );
  sl.registerSingleton<GetCustomerDetailUseCase>(
    GetCustomerDetailUseCase(sl<CustomerRepository>()),
  );

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

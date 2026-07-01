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
import 'package:step_up_fuels/features/drivers/application/usecases/assign_driver_usecase.dart';
import 'package:step_up_fuels/features/drivers/application/usecases/get_assignments_usecase.dart';
import 'package:step_up_fuels/features/drivers/application/usecases/get_drivers_usecase.dart';
import 'package:step_up_fuels/features/drivers/application/usecases/save_driver_usecase.dart';
import 'package:step_up_fuels/features/drivers/data/daos/drivers_dao.dart';
import 'package:step_up_fuels/features/drivers/data/repositories/driver_repository_impl.dart';
import 'package:step_up_fuels/features/drivers/domain/repositories/driver_repository.dart';
import 'package:step_up_fuels/features/inventory/application/usecases/get_current_stock_usecase.dart';
import 'package:step_up_fuels/features/inventory/application/usecases/get_movements_usecase.dart';
import 'package:step_up_fuels/features/inventory/application/usecases/get_storage_locations_usecase.dart';
import 'package:step_up_fuels/features/inventory/application/usecases/record_adjustment_usecase.dart';
import 'package:step_up_fuels/features/inventory/application/usecases/save_storage_location_usecase.dart';
import 'package:step_up_fuels/features/inventory/data/daos/inventory_dao.dart';
import 'package:step_up_fuels/features/inventory/data/repositories/inventory_repository_impl.dart';
import 'package:step_up_fuels/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:step_up_fuels/features/inventory/domain/services/inventory_service.dart';
import 'package:step_up_fuels/features/products/application/usecases/delete_product_usecase.dart';
import 'package:step_up_fuels/features/products/application/usecases/get_products_usecase.dart';
import 'package:step_up_fuels/features/products/application/usecases/save_product_usecase.dart';
import 'package:step_up_fuels/features/products/data/daos/products_dao.dart';
import 'package:step_up_fuels/features/products/data/repositories/product_repository_impl.dart';
import 'package:step_up_fuels/features/products/domain/repositories/product_repository.dart';
import 'package:step_up_fuels/features/invoices/application/usecases/cancel_invoice_usecase.dart';
import 'package:step_up_fuels/features/invoices/application/usecases/get_invoice_detail_usecase.dart';
import 'package:step_up_fuels/features/invoices/application/usecases/get_invoices_usecase.dart';
import 'package:step_up_fuels/features/invoices/application/usecases/post_invoice_usecase.dart';
import 'package:step_up_fuels/features/invoices/application/usecases/save_invoice_usecase.dart';
import 'package:step_up_fuels/features/invoices/data/daos/invoices_dao.dart';
import 'package:step_up_fuels/features/invoices/data/repositories/invoice_repository_impl.dart';
import 'package:step_up_fuels/features/invoices/domain/repositories/invoice_repository.dart';
import 'package:step_up_fuels/features/vehicles/application/usecases/get_service_records_usecase.dart';
import 'package:step_up_fuels/features/vehicles/application/usecases/get_vehicles_usecase.dart';
import 'package:step_up_fuels/features/vehicles/application/usecases/save_service_record_usecase.dart';
import 'package:step_up_fuels/features/vehicles/application/usecases/save_vehicle_usecase.dart';
import 'package:step_up_fuels/features/vehicles/data/daos/vehicles_dao.dart';
import 'package:step_up_fuels/features/vehicles/data/repositories/vehicle_repository_impl.dart';
import 'package:step_up_fuels/features/vehicles/domain/repositories/vehicle_repository.dart';

/// Global service locator instance.
final GetIt sl = GetIt.instance;

/// Riverpod provider exposing the AppDatabase from GetIt.
///
/// Use this in feature providers instead of calling `sl<AppDatabase>()` directly.
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

  // ── Phase 3: Inventory & Products Dependencies ──────────────────────────────
  final productsDao = ProductsDao(sl<AppDatabase>());
  sl.registerSingleton<ProductsDao>(productsDao);
  sl.registerSingleton<ProductRepository>(
    ProductRepositoryImpl(sl<ProductsDao>()),
  );
  sl.registerSingleton<GetProductsUseCase>(
    GetProductsUseCase(sl<ProductRepository>()),
  );
  sl.registerSingleton<SaveProductUseCase>(
    SaveProductUseCase(sl<ProductRepository>()),
  );
  sl.registerSingleton<DeleteProductUseCase>(
    DeleteProductUseCase(sl<ProductRepository>()),
  );

  final inventoryDao = InventoryDao(sl<AppDatabase>());
  sl.registerSingleton<InventoryDao>(inventoryDao);
  sl.registerSingleton<InventoryRepository>(
    InventoryRepositoryImpl(sl<InventoryDao>()),
  );
  sl.registerSingleton<InventoryService>(
    InventoryService(sl<InventoryRepository>()),
  );
  sl.registerSingleton<GetStorageLocationsUseCase>(
    GetStorageLocationsUseCase(sl<InventoryRepository>()),
  );
  sl.registerSingleton<SaveStorageLocationUseCase>(
    SaveStorageLocationUseCase(sl<InventoryRepository>()),
  );
  sl.registerSingleton<GetCurrentStockUseCase>(
    GetCurrentStockUseCase(sl<InventoryService>()),
  );
  sl.registerSingleton<RecordAdjustmentUseCase>(
    RecordAdjustmentUseCase(sl<InventoryService>()),
  );
  sl.registerSingleton<GetMovementsUseCase>(
    GetMovementsUseCase(sl<InventoryRepository>()),
  );

  // ── Phase 4: Vehicles & Drivers Dependencies ──────────────────────────────
  final vehiclesDao = VehiclesDao(sl<AppDatabase>());
  sl.registerSingleton<VehiclesDao>(vehiclesDao);
  sl.registerSingleton<VehicleRepository>(
    VehicleRepositoryImpl(sl<VehiclesDao>()),
  );
  sl.registerSingleton<GetVehiclesUseCase>(
    GetVehiclesUseCase(sl<VehicleRepository>()),
  );
  sl.registerSingleton<SaveVehicleUseCase>(
    SaveVehicleUseCase(sl<VehicleRepository>()),
  );
  sl.registerSingleton<GetServiceRecordsUseCase>(
    GetServiceRecordsUseCase(sl<VehicleRepository>()),
  );
  sl.registerSingleton<SaveServiceRecordUseCase>(
    SaveServiceRecordUseCase(sl<VehicleRepository>()),
  );

  final driversDao = DriversDao(sl<AppDatabase>());
  sl.registerSingleton<DriversDao>(driversDao);
  sl.registerSingleton<DriverRepository>(
    DriverRepositoryImpl(sl<DriversDao>()),
  );
  sl.registerSingleton<GetDriversUseCase>(
    GetDriversUseCase(sl<DriverRepository>()),
  );
  sl.registerSingleton<SaveDriverUseCase>(
    SaveDriverUseCase(sl<DriverRepository>()),
  );
  sl.registerSingleton<GetAssignmentsUseCase>(
    GetAssignmentsUseCase(sl<DriverRepository>()),
  );
  sl.registerSingleton<AssignDriverUseCase>(
    AssignDriverUseCase(sl<DriverRepository>()),
  );

  // ── Phase 4: Invoice Dependencies ──────────────────────────────────────────
  // sl.registerSingleton<InvoicesDao>(InvoicesDao(sl()));
  // sl.registerSingleton<GstCalculationService>(GstCalculationServiceImpl());
  // sl.registerSingleton<InvoiceService>(InvoiceServiceImpl(sl(), sl(), sl()));

  // ── Phase 5: Billing & Invoicing Dependencies ──────────────────────────────
  final invoicesDao = InvoicesDao(sl<AppDatabase>());
  sl.registerSingleton<InvoicesDao>(invoicesDao);
  sl.registerSingleton<InvoiceRepository>(
    InvoiceRepositoryImpl(sl<InvoicesDao>()),
  );
  sl.registerSingleton<GetInvoicesUseCase>(
    GetInvoicesUseCase(sl<InvoiceRepository>()),
  );
  sl.registerSingleton<GetInvoiceDetailUseCase>(
    GetInvoiceDetailUseCase(sl<InvoiceRepository>()),
  );
  sl.registerSingleton<SaveInvoiceUseCase>(
    SaveInvoiceUseCase(sl<InvoiceRepository>()),
  );
  sl.registerSingleton<PostInvoiceUseCase>(
    PostInvoiceUseCase(sl<InvoiceRepository>()),
  );
  sl.registerSingleton<CancelInvoiceUseCase>(
    CancelInvoiceUseCase(sl<InvoiceRepository>()),
  );

  // ── Phase 6: Purchase Dependencies ─────────────────────────────────────────
  // sl.registerSingleton<PurchasesDao>(PurchasesDao(sl()));

  // ── Phase 7: Payment + Ledger Dependencies ─────────────────────────────────
  // sl.registerSingleton<LedgerService>(LedgerServiceImpl(sl()));
  // sl.registerSingleton<PaymentService>(PaymentServiceImpl(sl(), sl()));

  AppLogger.info('All dependencies configured successfully');
}

import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:step_up_fuels/core/constants/app_constants.dart';
import 'package:step_up_fuels/features/customers/data/tables/customer_contacts_table.dart';
import 'package:step_up_fuels/features/customers/data/tables/customer_credit_limits_table.dart';
import 'package:step_up_fuels/features/customers/data/tables/customer_documents_table.dart';
import 'package:step_up_fuels/features/customers/data/tables/customer_notes_table.dart';
import 'package:step_up_fuels/features/customers/data/tables/customer_sites_table.dart';
import 'package:step_up_fuels/features/customers/data/tables/customers_table.dart';
import 'package:step_up_fuels/features/deliveries/data/tables/fuel_deliveries_table.dart';
import 'package:step_up_fuels/features/drivers/data/tables/driver_assignments_table.dart';
import 'package:step_up_fuels/features/drivers/data/tables/drivers_table.dart';
import 'package:step_up_fuels/features/expenses/data/tables/expenses_table.dart';
import 'package:step_up_fuels/features/inventory/data/tables/daily_stock_reconciliations_table.dart';
import 'package:step_up_fuels/features/inventory/data/tables/inventory_movements_table.dart';
import 'package:step_up_fuels/features/inventory/data/tables/stock_adjustments_table.dart';
import 'package:step_up_fuels/features/inventory/data/tables/storage_locations_table.dart';
import 'package:step_up_fuels/features/invoices/data/tables/invoice_items_table.dart';
import 'package:step_up_fuels/features/invoices/data/tables/invoices_table.dart';
import 'package:step_up_fuels/features/ledger/data/tables/ledger_accounts_table.dart';
import 'package:step_up_fuels/features/ledger/data/tables/ledger_entries_table.dart';
import 'package:step_up_fuels/features/payments/data/tables/payments_table.dart';
import 'package:step_up_fuels/features/products/data/tables/products_table.dart';
import 'package:step_up_fuels/features/purchases/data/tables/purchase_items_table.dart';
import 'package:step_up_fuels/features/purchases/data/tables/purchases_table.dart';
import 'package:step_up_fuels/features/purchases/data/tables/suppliers_table.dart';
import 'package:step_up_fuels/features/settings/data/tables/documents_table.dart';
import 'package:step_up_fuels/features/settings/data/tables/users_table.dart';
import 'package:step_up_fuels/features/vehicles/data/tables/vehicle_service_records_table.dart';
import 'package:step_up_fuels/features/vehicles/data/tables/vehicles_table.dart';

part 'app_database.g.dart';

// ─── Settings Table ──────────────────────────────────────────────────────────

/// Simple key-value store for application configuration.
/// Used for: company profile references, invoice counters, theme preferences.
@DataClassName('AppSettingRow')
class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

// ─── Database Root ────────────────────────────────────────────────────────────

/// The central Drift database.
@DriftDatabase(
  tables: [
    AppSettings,
    Customers,
    CustomerSites,
    CustomerContacts,
    CustomerCreditLimits,
    CustomerDocuments,
    CustomerNotes,
    Products,
    StorageLocations,
    InventoryMovements,
    StockAdjustments,
    DailyStockReconciliations,
    Vehicles,
    VehicleServiceRecords,
    Drivers,
    DriverAssignments,
    FuelDeliveries,
    Invoices,
    InvoiceItems,
    Suppliers,
    FuelPurchases,
    FuelPurchaseItems,
    Expenses,
    Payments,
    LedgerAccounts,
    LedgerEntries,
    Users,
    Documents,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.connection);

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _seedDefaultSettings();
    },
    onUpgrade: (m, from, to) async {
      if (from < 3) {
        await _createTableIfNotExists(m, customers);
        await _createTableIfNotExists(m, customerSites);
        await _createTableIfNotExists(m, customerContacts);
        await _createTableIfNotExists(m, customerCreditLimits);
        await _createTableIfNotExists(m, customerDocuments);
        await _createTableIfNotExists(m, customerNotes);
      }
      if (from < 4) {
        await _createTableIfNotExists(m, products);
        await _createTableIfNotExists(m, storageLocations);
        await _createTableIfNotExists(m, inventoryMovements);
        await _createTableIfNotExists(m, stockAdjustments);
        await _createTableIfNotExists(m, dailyStockReconciliations);
        await _createTableIfNotExists(m, vehicles);
        await _createTableIfNotExists(m, vehicleServiceRecords);
        await _createTableIfNotExists(m, drivers);
        await _createTableIfNotExists(m, driverAssignments);
        await _createTableIfNotExists(m, fuelDeliveries);
        await _createTableIfNotExists(m, invoices);
        await _createTableIfNotExists(m, invoiceItems);
        await _createTableIfNotExists(m, suppliers);
        await _createTableIfNotExists(m, fuelPurchases);
        await _createTableIfNotExists(m, fuelPurchaseItems);
        await _createTableIfNotExists(m, expenses);
        await _createTableIfNotExists(m, payments);
        await _createTableIfNotExists(m, ledgerAccounts);
        await _createTableIfNotExists(m, ledgerEntries);
        await _createTableIfNotExists(m, users);
        await _createTableIfNotExists(m, documents);
      }
    },
  );

  Future<void> _createTableIfNotExists(
    Migrator m,
    TableInfo<Table, Object?> table,
  ) async {
    try {
      await m.createTable(table);
    } catch (_) {
      // Table already exists, ignore exception
    }
  }

  // ── Settings Helpers ────────────────────────────────────────────────────────

  Future<void> _seedDefaultSettings() async {
    await into(appSettings).insert(
      AppSettingsCompanion.insert(
        key: AppConstants.settingsKeyThemeMode,
        value: 'dark',
      ),
    );
    await into(appSettings).insert(
      AppSettingsCompanion.insert(
        key: AppConstants.settingsKeyInvoiceCounter,
        value: '0',
      ),
    );
  }

  Future<String?> getSetting(String key) async {
    final row = await (select(
      appSettings,
    )..where((t) => t.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<void> setSetting(String key, String value) async {
    await into(appSettings).insertOnConflictUpdate(
      AppSettingsCompanion.insert(key: key, value: value),
    );
  }
}

// ─── Connection ──────────────────────────────────────────────────────────────

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final dbDir = Directory(p.join(dbFolder.path, 'StepUpFuels'));
    if (!dbDir.existsSync()) {
      await dbDir.create(recursive: true);
    }
    final file = File(p.join(dbDir.path, AppConstants.databaseName));
    return NativeDatabase.createInBackground(file);
  });
}

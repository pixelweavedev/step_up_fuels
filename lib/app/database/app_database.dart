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
///
/// Phase 1 contains only the [AppSettings] table.
/// Each phase will add feature tables here as they are implemented:
///
/// Phase 2 → CustomersTable, CustomerSitesTable, CustomerContactsTable
/// Phase 3 → ProductsTable, InventoryMovementsTable, StockAdjustmentsTable
/// Phase 4 → InvoicesTable, InvoiceItemsTable
/// Phase 5 → PurchasesTable, PurchaseItemsTable, SuppliersTable
/// Phase 6 → PaymentsTable, LedgerAccountsTable, LedgerEntriesTable
@DriftDatabase(
  tables: [
    AppSettings,
    Customers,
    CustomerSites,
    CustomerContacts,
    CustomerCreditLimits,
    CustomerDocuments,
    CustomerNotes,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.connection);

  @override
  int get schemaVersion => 3;

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
        },
      );

  Future<void> _createTableIfNotExists(Migrator m, TableInfo<Table, Object?> table) async {
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

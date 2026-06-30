import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:step_up_fuels/core/constants/app_constants.dart';

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
    // Feature tables will be added here as each phase is implemented.
    // Example (Phase 2):
    //   Customers,
    //   CustomerSites,
    //   CustomerContacts,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.connection);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _seedDefaultSettings();
        },
        onUpgrade: (m, from, to) async {
          // Schema migrations will be added here for each version bump.
        },
      );

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
    final row = await (select(appSettings)
          ..where((t) => t.key.equals(key)))
        .getSingleOrNull();
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

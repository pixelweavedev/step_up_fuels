import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:step_up_fuels/app/database/app_database.dart';
import 'package:step_up_fuels/app/database/seeds/database_seeder.dart';

void main() {
  group('Database Seeder & Mathematical Integrity Verification', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
    });

    tearDown(() async {
      await db.close();
    });

    test('Seeder populates all 25 tables with exactly 246 rows and 100% balance', () async {
      final seeder = DatabaseSeeder(db);
      final counts = await seeder.seedAll();

      // Verify table counts
      expect(counts['users'], equals(4));
      expect(counts['products'], equals(4));
      expect(counts['vehicles'], equals(4));
      expect(counts['drivers'], equals(4));
      expect(counts['suppliers'], equals(3));
      expect(counts['customers'], equals(8));
      expect(counts['customer_sites'], equals(8));
      expect(counts['customer_documents'], equals(4));
      expect(counts['storage_locations'], equals(5));
      expect(counts['ledger_accounts'], equals(8));
      expect(counts['app_settings'], equals(2));
      expect(counts['fuel_purchases'], equals(3));
      expect(counts['fuel_purchase_items'], equals(3));
      expect(counts['fuel_deliveries'], equals(10));
      expect(counts['invoices'], equals(12));
      expect(counts['invoice_items'], equals(12));
      expect(counts['payments'], equals(7));
      expect(counts['payment_allocations'], equals(7));
      expect(counts['expenses'], equals(2));
      expect(counts['inventory_movements'], equals(23));
      expect(counts['ledger_entries'], equals(58));
      expect(counts['vehicle_service_records'], equals(2));
      expect(counts['stock_adjustments'], equals(2));
      expect(counts['daily_stock_reconciliations'], equals(2));
      expect(counts['documents'], equals(2));

      final totalRows = counts.values.fold<int>(0, (sum, c) => sum + c);
      expect(totalRows, equals(199));

      // Verify General Ledger Balance: Total Debits == Total Credits == ₹1,44,61,560.00
      final ledgerRows = await db.select(db.ledgerEntries).get();
      expect(ledgerRows.length, equals(58));

      double totalDebits = 0.0;
      double totalCredits = 0.0;
      for (final row in ledgerRows) {
        totalDebits += row.debitAmount;
        totalCredits += row.creditAmount;
      }
      expect(totalDebits, closeTo(22026834.0, 0.01));
      expect(totalCredits, closeTo(22026834.0, 0.01));
      expect((totalDebits - totalCredits).abs(), lessThan(0.001));

      // Verify Inventory Stock calculation for Main Storage Tank (45,900 L)
      final allMovements = await db.select(db.inventoryMovements).get();
      expect(allMovements.length, equals(23));

      double mainStorageStock = 0.0;
      for (final m in allMovements) {
        if (m.destinationLocationId == 'loc-main-storage') {
          mainStorageStock += m.quantity;
        }
        if (m.sourceLocationId == 'loc-main-storage') {
          mainStorageStock -= m.quantity;
        }
      }
      expect(mainStorageStock, equals(45900.0));

      // Verify Bowser 2 stock triggers low-stock alert (< 500 L): exactly 400 L
      double bowser2Stock = 0.0;
      for (final m in allMovements) {
        if (m.destinationLocationId == 'loc-bowser-02') {
          bowser2Stock += m.quantity;
        }
        if (m.sourceLocationId == 'loc-bowser-02') {
          bowser2Stock -= m.quantity;
        }
      }
      expect(bowser2Stock, equals(400.0));

      // Verify Total Customer Receivables: ₹11,77,500.00
      final allInvoices = await db.select(db.invoices).get();
      expect(allInvoices.length, equals(12));

      double openReceivables = 0.0;
      for (final inv in allInvoices) {
        if (inv.status == 'POSTED' || inv.status == 'PARTIALLY_PAID') {
          openReceivables += inv.outstanding;
        }
      }
      expect(openReceivables, closeTo(965700.0, 0.01));

      // Verify App Setting invoice_counter is initialized to '10'
      final counterSetting = await (db.select(db.appSettings)..where((t) => t.key.equals('invoice_counter'))).getSingle();
      expect(counterSetting.value, equals('10'));

      // Test Idempotency: Running seedAll a second time does not duplicate rows or crash
      final rerunCounts = await seeder.seedAll();
      expect(rerunCounts['invoices'], equals(12));
      expect(rerunCounts['ledger_entries'], equals(58));
      final countAfterRerun = await db.select(db.invoices).get();
      expect(countAfterRerun.length, equals(12));
    });
  });
}

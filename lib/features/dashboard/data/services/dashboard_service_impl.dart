import 'package:drift/drift.dart';
import 'package:step_up_fuels/app/database/app_database.dart';
import 'package:step_up_fuels/core/errors/failure.dart';
import 'package:step_up_fuels/core/result/result.dart';
import 'package:step_up_fuels/features/invoices/data/models/invoice_mapper.dart';
import 'package:step_up_fuels/features/reports/domain/entities/report_models.dart';
import 'package:step_up_fuels/features/dashboard/domain/services/dashboard_service.dart';

class DashboardServiceImpl implements DashboardService {
  final AppDatabase _db;

  DashboardServiceImpl(this._db);

  @override
  Future<Result<DashboardStats>> getTodayStats() async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 1).subtract(const Duration(seconds: 1));

      // 1. Today's sales value & deliveries count
      final todayInvoices = await (_db.select(_db.invoices)
            ..where((t) =>
                t.deletedAt.isNull() &
                t.invoiceDate.isBiggerOrEqualValue(startOfDay) &
                t.invoiceDate.isSmallerOrEqualValue(endOfDay) &
                (t.status.equals('POSTED') | t.status.equals('PAID') | t.status.equals('PARTIALLY_PAID'))))
          .get();

      double todaySalesValue = 0.0;
      int todayDeliveriesCount = todayInvoices.length;
      for (final inv in todayInvoices) {
        todaySalesValue += inv.totalAmount;
      }

      // Today's sales litres
      double todaySalesLitres = 0.0;
      if (todayInvoices.isNotEmpty) {
        final invoiceIds = todayInvoices.map((inv) => inv.id).toList();
        final items = await (_db.select(_db.invoiceItems)
              ..where((t) => t.invoiceId.isIn(invoiceIds)))
            .get();
        for (final item in items) {
          todaySalesLitres += item.quantity;
        }
      }

      // 2. Total Outstanding Receivables (sum of customer balances)
      final custOutstandingQuery = _db.selectOnly(_db.customers)
        ..addColumns([_db.customers.currentBalance.sum()])
        ..where(_db.customers.isActive.equals(true));
      final totalOutstandingReceivables = (await custOutstandingQuery
              .map((r) => r.read<double>(_db.customers.currentBalance.sum()))
              .getSingleOrNull()) ??
          0.0;

      // 3. Current month revenue
      final monthInvoicesQuery = _db.selectOnly(_db.invoices)
        ..addColumns([_db.invoices.subtotal.sum()])
        ..where(_db.invoices.deletedAt.isNull() &
            _db.invoices.invoiceDate.isBiggerOrEqualValue(startOfMonth) &
            _db.invoices.invoiceDate.isSmallerOrEqualValue(endOfMonth) &
            (_db.invoices.status.equals('POSTED') |
                _db.invoices.status.equals('PAID') |
                _db.invoices.status.equals('PARTIALLY_PAID')));
      final currentMonthRevenue = (await monthInvoicesQuery
              .map((r) => r.read<double>(_db.invoices.subtotal.sum()))
              .getSingleOrNull()) ??
          0.0;

      // 4. Total Active Customers
      final activeCustQuery = _db.selectOnly(_db.customers)
        ..addColumns([_db.customers.id.count()])
        ..where(_db.customers.isActive.equals(true));
      final totalActiveCustomers = (await activeCustQuery
              .map((r) => r.read<int>(_db.customers.id.count()))
              .getSingleOrNull()) ??
          0;

      // 5. Stock status calculations: Main storage and Bowsers
      final locations = await _db.select(_db.storageLocations).get();
      final products = await _db.select(_db.products).get();

      double mainStorageStock = 0.0;
      final bowserStockLevels = <String, double>{};
      final lowStockAlerts = <LowStockAlert>[];

      for (final loc in locations) {
        for (final prod in products) {
          // calculate stock dynamically: sum(incoming) - sum(outgoing)
          final incomingQuery = _db.selectOnly(_db.inventoryMovements)
            ..addColumns([_db.inventoryMovements.quantity.sum()])
            ..where(_db.inventoryMovements.destinationLocationId.equals(loc.id) &
                _db.inventoryMovements.productId.equals(prod.id));

          final outgoingQuery = _db.selectOnly(_db.inventoryMovements)
            ..addColumns([_db.inventoryMovements.quantity.sum()])
            ..where(_db.inventoryMovements.sourceLocationId.equals(loc.id) &
                _db.inventoryMovements.productId.equals(prod.id));

          final incoming = (await incomingQuery.map((r) => r.read<double>(_db.inventoryMovements.quantity.sum())).getSingleOrNull()) ?? 0.0;
          final outgoing = (await outgoingQuery.map((r) => r.read<double>(_db.inventoryMovements.quantity.sum())).getSingleOrNull()) ?? 0.0;

          final stock = incoming - outgoing;

          if (loc.type == 'MAIN_STORAGE') {
            mainStorageStock = stock;
            if (stock < 5000.0) {
              lowStockAlerts.add(LowStockAlert(
                locationId: loc.id,
                locationName: loc.name,
                productName: prod.name,
                currentStock: stock,
                threshold: 5000.0,
              ));
            }
          } else if (loc.type == 'VEHICLE_BOWSER') {
            bowserStockLevels[loc.name] = stock;
            if (stock < 500.0) {
              lowStockAlerts.add(LowStockAlert(
                locationId: loc.id,
                locationName: loc.name,
                productName: prod.name,
                currentStock: stock,
                threshold: 500.0,
              ));
            }
          }
        }
      }

      // 6. Recent Invoices (Limit 5)
      final recentInvoicesRows = await (_db.select(_db.invoices)
            ..where((t) => t.deletedAt.isNull())
            ..orderBy([(t) => OrderingTerm.desc(t.invoiceDate)])
            ..limit(5))
          .get();
      final recentInvoices = recentInvoicesRows.map((row) => row.toDomain()).toList();

      return Result.success(DashboardStats(
        todaySalesLitres: todaySalesLitres,
        todaySalesValue: todaySalesValue,
        todayDeliveriesCount: todayDeliveriesCount,
        totalOutstandingReceivables: totalOutstandingReceivables,
        mainStorageStock: mainStorageStock,
        bowserStockLevels: bowserStockLevels,
        totalActiveCustomers: totalActiveCustomers,
        currentMonthRevenue: currentMonthRevenue,
        recentInvoices: recentInvoices,
        lowStockAlerts: lowStockAlerts,
      ));
    } catch (e, st) {
      return Result.failure(DatabaseFailure(message: e.toString(), stackTrace: st));
    }
  }
}

import 'package:drift/drift.dart';
import 'package:step_up_fuels/app/database/app_database.dart';
import 'package:step_up_fuels/core/errors/failure.dart';
import 'package:step_up_fuels/core/result/result.dart';
import 'package:step_up_fuels/features/reports/domain/entities/report_models.dart';
import 'package:step_up_fuels/features/reports/domain/services/reporting_service.dart';

class ReportingServiceImpl implements ReportingService {
  ReportingServiceImpl(this._db);
  final AppDatabase _db;

  @override
  Future<Result<SalesSummary>> getDailySales(DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      final query = _db.select(_db.invoices).join([
        leftOuterJoin(
          _db.invoiceItems,
          _db.invoiceItems.invoiceId.equalsExp(_db.invoices.id),
        ),
      ]);

      query.where(
        _db.invoices.deletedAt.isNull() &
            _db.invoices.invoiceDate.isBiggerOrEqualValue(startOfDay) &
            _db.invoices.invoiceDate.isSmallerOrEqualValue(endOfDay) &
            (_db.invoices.status.equals('POSTED') |
                _db.invoices.status.equals('PAID') |
                _db.invoices.status.equals('PARTIALLY_PAID')),
      );

      final rows = await query.get();

      double totalLitres = 0.0;
      double taxableAmount = 0.0;
      double cgstAmount = 0.0;
      double sgstAmount = 0.0;
      double igstAmount = 0.0;
      double totalAmount = 0.0;
      double totalOutstanding = 0.0;

      // Track unique invoices to aggregate outstanding exactly once
      final aggregatedInvoices = <String>{};

      for (final row in rows) {
        final invoice = row.readTable(_db.invoices);
        final item = row.readTableOrNull(_db.invoiceItems);

        if (item != null) {
          totalLitres += item.quantity;
        }

        if (!aggregatedInvoices.contains(invoice.id)) {
          taxableAmount += invoice.subtotal;
          cgstAmount += invoice.cgstAmount;
          sgstAmount += invoice.sgstAmount;
          igstAmount += invoice.igstAmount;
          totalAmount += invoice.totalAmount;
          totalOutstanding += invoice.outstanding;
          aggregatedInvoices.add(invoice.id);
        }
      }

      return Result.success(
        SalesSummary(
          totalLitres: totalLitres,
          taxableAmount: taxableAmount,
          cgstAmount: cgstAmount,
          sgstAmount: sgstAmount,
          igstAmount: igstAmount,
          totalAmount: totalAmount,
          totalOutstanding: totalOutstanding,
        ),
      );
    } catch (e, st) {
      return Result.failure(
        DatabaseFailure(message: e.toString(), stackTrace: st),
      );
    }
  }

  @override
  Future<Result<Map<String, SalesSummary>>> getMonthlySales(int year) async {
    try {
      final startOfYear = DateTime(year);
      final endOfYear = DateTime(year, 12, 31, 23, 59, 59);

      final query = _db.select(_db.invoices).join([
        leftOuterJoin(
          _db.invoiceItems,
          _db.invoiceItems.invoiceId.equalsExp(_db.invoices.id),
        ),
      ]);

      query.where(
        _db.invoices.deletedAt.isNull() &
            _db.invoices.invoiceDate.isBiggerOrEqualValue(startOfYear) &
            _db.invoices.invoiceDate.isSmallerOrEqualValue(endOfYear) &
            (_db.invoices.status.equals('POSTED') |
                _db.invoices.status.equals('PAID') |
                _db.invoices.status.equals('PARTIALLY_PAID')),
      );

      final rows = await query.get();
      final map = <String, SalesSummary>{};

      // In-memory grouping by month
      for (int month = 1; month <= 12; month++) {
        final key = '$year-${month.toString().padLeft(2, '0')}';

        double totalLitres = 0.0;
        double taxableAmount = 0.0;
        double cgstAmount = 0.0;
        double sgstAmount = 0.0;
        double igstAmount = 0.0;
        double totalAmount = 0.0;
        double totalOutstanding = 0.0;
        final aggregatedInvoices = <String>{};

        for (final row in rows) {
          final invoice = row.readTable(_db.invoices);
          final item = row.readTableOrNull(_db.invoiceItems);

          if (invoice.invoiceDate.month == month) {
            if (item != null) {
              totalLitres += item.quantity;
            }

            if (!aggregatedInvoices.contains(invoice.id)) {
              taxableAmount += invoice.subtotal;
              cgstAmount += invoice.cgstAmount;
              sgstAmount += invoice.sgstAmount;
              igstAmount += invoice.igstAmount;
              totalAmount += invoice.totalAmount;
              totalOutstanding += invoice.outstanding;
              aggregatedInvoices.add(invoice.id);
            }
          }
        }

        map[key] = SalesSummary(
          totalLitres: totalLitres,
          taxableAmount: taxableAmount,
          cgstAmount: cgstAmount,
          sgstAmount: sgstAmount,
          igstAmount: igstAmount,
          totalAmount: totalAmount,
          totalOutstanding: totalOutstanding,
        );
      }

      return Result.success(map);
    } catch (e, st) {
      return Result.failure(
        DatabaseFailure(message: e.toString(), stackTrace: st),
      );
    }
  }

  @override
  Future<Result<Map<String, SalesSummary>>> getCustomerWiseSales({
    required DateTime start,
    required DateTime end,
  }) async {
    try {
      final query = _db.select(_db.invoices).join([
        leftOuterJoin(
          _db.invoiceItems,
          _db.invoiceItems.invoiceId.equalsExp(_db.invoices.id),
        ),
        innerJoin(
          _db.customers,
          _db.customers.id.equalsExp(_db.invoices.customerId),
        ),
      ]);

      query.where(
        _db.invoices.deletedAt.isNull() &
            _db.invoices.invoiceDate.isBiggerOrEqualValue(start) &
            _db.invoices.invoiceDate.isSmallerOrEqualValue(end) &
            (_db.invoices.status.equals('POSTED') |
                _db.invoices.status.equals('PAID') |
                _db.invoices.status.equals('PARTIALLY_PAID')),
      );

      final rows = await query.get();
      final map = <String, SalesSummary>{};

      // Resolve unique customers
      final customerNames = <String, String>{};
      final invoiceMapByCustomer = <String, List<TypedResult>>{};

      for (final row in rows) {
        final cust = row.readTable(_db.customers);
        final invoice = row.readTable(_db.invoices);
        customerNames[invoice.customerId] = cust.name;
        invoiceMapByCustomer.putIfAbsent(invoice.customerId, () => []).add(row);
      }

      for (final custId in invoiceMapByCustomer.keys) {
        final custRows = invoiceMapByCustomer[custId]!;
        final custName = customerNames[custId] ?? 'Unknown';

        double totalLitres = 0.0;
        double taxableAmount = 0.0;
        double cgstAmount = 0.0;
        double sgstAmount = 0.0;
        double igstAmount = 0.0;
        double totalAmount = 0.0;
        double totalOutstanding = 0.0;
        final aggregatedInvoices = <String>{};

        for (final row in custRows) {
          final invoice = row.readTable(_db.invoices);
          final item = row.readTableOrNull(_db.invoiceItems);

          if (item != null) {
            totalLitres += item.quantity;
          }

          if (!aggregatedInvoices.contains(invoice.id)) {
            taxableAmount += invoice.subtotal;
            cgstAmount += invoice.cgstAmount;
            sgstAmount += invoice.sgstAmount;
            igstAmount += invoice.igstAmount;
            totalAmount += invoice.totalAmount;
            totalOutstanding += invoice.outstanding;
            aggregatedInvoices.add(invoice.id);
          }
        }

        map[custName] = SalesSummary(
          totalLitres: totalLitres,
          taxableAmount: taxableAmount,
          cgstAmount: cgstAmount,
          sgstAmount: sgstAmount,
          igstAmount: igstAmount,
          totalAmount: totalAmount,
          totalOutstanding: totalOutstanding,
        );
      }

      return Result.success(map);
    } catch (e, st) {
      return Result.failure(
        DatabaseFailure(message: e.toString(), stackTrace: st),
      );
    }
  }

  @override
  Future<Result<List<FuelPurchaseReportRow>>> getPurchaseReport({
    required DateTime start,
    required DateTime end,
  }) async {
    try {
      final query = _db.select(_db.fuelPurchases).join([
        innerJoin(
          _db.suppliers,
          _db.suppliers.id.equalsExp(_db.fuelPurchases.supplierId),
        ),
      ]);

      query.where(
        _db.fuelPurchases.deletedAt.isNull() &
            _db.fuelPurchases.purchaseDate.isBiggerOrEqualValue(start) &
            _db.fuelPurchases.purchaseDate.isSmallerOrEqualValue(end),
      );

      final rows = await query.get();
      final list = rows.map((row) {
        final p = row.readTable(_db.fuelPurchases);
        final s = row.readTable(_db.suppliers);

        return FuelPurchaseReportRow(
          id: p.id,
          purchaseNumber: p.purchaseNumber,
          supplierName: s.name,
          supplierInvoiceNo: p.supplierInvoiceNo,
          purchaseDate: p.purchaseDate,
          subtotal: p.subtotal,
          cgstAmount: p.cgstAmount,
          sgstAmount: p.sgstAmount,
          igstAmount: p.igstAmount,
          totalAmount: p.totalAmount,
        );
      }).toList();

      return Result.success(list);
    } catch (e, st) {
      return Result.failure(
        DatabaseFailure(message: e.toString(), stackTrace: st),
      );
    }
  }

  @override
  Future<Result<List<StockStatusRow>>> getStockReport() async {
    try {
      // 1. Fetch all storage locations
      final locations = await _db.select(_db.storageLocations).get();

      // 2. Fetch all products
      final products = await _db.select(_db.products).get();

      final list = <StockStatusRow>[];

      for (final loc in locations) {
        for (final prod in products) {
          // Dynamic calculation: sum(incoming) - sum(outgoing)
          final incomingQuery = _db.selectOnly(_db.inventoryMovements)
            ..addColumns([_db.inventoryMovements.quantity.sum()])
            ..where(
              _db.inventoryMovements.destinationLocationId.equals(loc.id) &
                  _db.inventoryMovements.productId.equals(prod.id),
            );

          final outgoingQuery = _db.selectOnly(_db.inventoryMovements)
            ..addColumns([_db.inventoryMovements.quantity.sum()])
            ..where(
              _db.inventoryMovements.sourceLocationId.equals(loc.id) &
                  _db.inventoryMovements.productId.equals(prod.id),
            );

          final incomingLitres =
              (await incomingQuery
                  .map(
                    (r) =>
                        r.read<double>(_db.inventoryMovements.quantity.sum()),
                  )
                  .getSingleOrNull()) ??
              0.0;
          final outgoingLitres =
              (await outgoingQuery
                  .map(
                    (r) =>
                        r.read<double>(_db.inventoryMovements.quantity.sum()),
                  )
                  .getSingleOrNull()) ??
              0.0;

          final currentStock = incomingLitres - outgoingLitres;

          list.add(
            StockStatusRow(
              locationId: loc.id,
              locationName: loc.name,
              locationType: loc.type,
              productId: prod.id,
              productName: prod.name,
              currentStock: currentStock,
            ),
          );
        }
      }

      return Result.success(list);
    } catch (e, st) {
      return Result.failure(
        DatabaseFailure(message: e.toString(), stackTrace: st),
      );
    }
  }

  @override
  Future<Result<Map<String, double>>> getExpenseReport({
    required DateTime start,
    required DateTime end,
    String? vehicleId,
  }) async {
    try {
      final query = _db.select(_db.expenses);
      Expression<bool> expr =
          _db.expenses.deletedAt.isNull() &
          _db.expenses.expenseDate.isBiggerOrEqualValue(start) &
          _db.expenses.expenseDate.isSmallerOrEqualValue(end);

      if (vehicleId != null) {
        expr = expr & _db.expenses.vehicleId.equals(vehicleId);
      }

      query.where((t) => expr);
      final rows = await query.get();

      final map = <String, double>{};
      for (final r in rows) {
        map[r.category] = (map[r.category] ?? 0.0) + r.amount;
      }

      return Result.success(map);
    } catch (e, st) {
      return Result.failure(
        DatabaseFailure(message: e.toString(), stackTrace: st),
      );
    }
  }

  @override
  Future<Result<ProfitLossEstimate>> getProfitLossEstimate({
    required DateTime start,
    required DateTime end,
  }) async {
    try {
      // 1. Revenue: subtotal of invoices in range
      final revQuery = _db.selectOnly(_db.invoices)
        ..addColumns([_db.invoices.subtotal.sum()])
        ..where(
          _db.invoices.deletedAt.isNull() &
              _db.invoices.invoiceDate.isBiggerOrEqualValue(start) &
              _db.invoices.invoiceDate.isSmallerOrEqualValue(end) &
              (_db.invoices.status.equals('POSTED') |
                  _db.invoices.status.equals('PAID') |
                  _db.invoices.status.equals('PARTIALLY_PAID')),
        );
      final revenue =
          (await revQuery
              .map((r) => r.read<double>(_db.invoices.subtotal.sum()))
              .getSingleOrNull()) ??
          0.0;

      // 2. Expenses: sum of operating expenses in range
      final expQuery = _db.selectOnly(_db.expenses)
        ..addColumns([_db.expenses.amount.sum()])
        ..where(
          _db.expenses.deletedAt.isNull() &
              _db.expenses.expenseDate.isBiggerOrEqualValue(start) &
              _db.expenses.expenseDate.isSmallerOrEqualValue(end),
        );
      final operatingExpenses =
          (await expQuery
              .map((r) => r.read<double>(_db.expenses.amount.sum()))
              .getSingleOrNull()) ??
          0.0;

      // 3. Cost of Fuel Sold (COGS)
      // Get total litres sold in range
      final itemsQuery = _db.select(_db.invoices).join([
        innerJoin(
          _db.invoiceItems,
          _db.invoiceItems.invoiceId.equalsExp(_db.invoices.id),
        ),
      ]);
      itemsQuery.where(
        _db.invoices.deletedAt.isNull() &
            _db.invoices.invoiceDate.isBiggerOrEqualValue(start) &
            _db.invoices.invoiceDate.isSmallerOrEqualValue(end) &
            (_db.invoices.status.equals('POSTED') |
                _db.invoices.status.equals('PAID') |
                _db.invoices.status.equals('PARTIALLY_PAID')),
      );
      final itemRows = await itemsQuery.get();
      double litresSold = 0.0;
      for (final r in itemRows) {
        litresSold += r.readTable(_db.invoiceItems).quantity;
      }

      // Compute Weighted Average purchase rate from fuel purchases
      final purItemsQuery = _db.select(_db.fuelPurchases).join([
        innerJoin(
          _db.fuelPurchaseItems,
          _db.fuelPurchaseItems.purchaseId.equalsExp(_db.fuelPurchases.id),
        ),
      ]);
      purItemsQuery.where(
        _db.fuelPurchases.deletedAt.isNull() &
            _db.fuelPurchases.purchaseDate.isBiggerOrEqualValue(start) &
            _db.fuelPurchases.purchaseDate.isSmallerOrEqualValue(end),
      );
      final purRows = await purItemsQuery.get();
      double totalPurQty = 0.0;
      double totalPurVal = 0.0;
      for (final r in purRows) {
        final pi = r.readTable(_db.fuelPurchaseItems);
        totalPurQty += pi.quantity;
        totalPurVal += pi.taxableAmount;
      }

      // Fallback purchase rate if no purchases recorded in the current period (e.g. 90.0 per litre)
      final avgPurRate = totalPurQty > 0 ? (totalPurVal / totalPurQty) : 90.0;
      final costOfFuelSold = litresSold * avgPurRate;

      final estimatedNetProfit = revenue - costOfFuelSold - operatingExpenses;

      return Result.success(
        ProfitLossEstimate(
          startDate: start,
          endDate: end,
          revenue: revenue,
          costOfFuelSold: costOfFuelSold,
          operatingExpenses: operatingExpenses,
          estimatedNetProfit: estimatedNetProfit,
        ),
      );
    } catch (e, st) {
      return Result.failure(
        DatabaseFailure(message: e.toString(), stackTrace: st),
      );
    }
  }

  @override
  Future<Result<List<CustomerOutstandingAging>>> getOutstandingReport() async {
    try {
      final customers = await _db.select(_db.customers).get();
      final list = <CustomerOutstandingAging>[];
      final today = DateTime.now();

      for (final cust in customers) {
        final invoices =
            await (_db.select(_db.invoices)..where(
                  (t) =>
                      t.customerId.equals(cust.id) &
                      t.deletedAt.isNull() &
                      (t.status.equals('POSTED') |
                          t.status.equals('PARTIALLY_PAID')),
                ))
                .get();

        double current = 0.0;
        double tier1 = 0.0;
        double tier2 = 0.0;
        double tier3 = 0.0;
        double overdue = 0.0;
        double totalOutstanding = 0.0;

        for (final inv in invoices) {
          final age = today.difference(inv.invoiceDate).inDays;
          final amt = inv.outstanding;
          totalOutstanding += amt;

          if (age <= 7) {
            current += amt;
          } else if (age <= 15) {
            tier1 += amt;
          } else if (age <= 30) {
            tier2 += amt;
          } else if (age <= 45) {
            tier3 += amt;
          } else {
            overdue += amt;
          }
        }

        list.add(
          CustomerOutstandingAging(
            customerId: cust.id,
            customerName: cust.name,
            current: current,
            tier1: tier1,
            tier2: tier2,
            tier3: tier3,
            overdue: overdue,
            totalOutstanding: totalOutstanding,
          ),
        );
      }

      return Result.success(list);
    } catch (e, st) {
      return Result.failure(
        DatabaseFailure(message: e.toString(), stackTrace: st),
      );
    }
  }

  @override
  Future<Result<GstReport>> getGstReport({
    required DateTime start,
    required DateTime end,
  }) async {
    try {
      // 1. Fetch B2B invoices (invoices in date range with a registered customer GSTIN)
      final queryB2b = _db.select(_db.invoices).join([
        innerJoin(
          _db.customers,
          _db.customers.id.equalsExp(_db.invoices.customerId),
        ),
      ]);
      queryB2b.where(
        _db.invoices.deletedAt.isNull() &
            _db.invoices.invoiceDate.isBiggerOrEqualValue(start) &
            _db.invoices.invoiceDate.isSmallerOrEqualValue(end) &
            (_db.invoices.status.equals('POSTED') |
                _db.invoices.status.equals('PAID') |
                _db.invoices.status.equals('PARTIALLY_PAID')),
      );

      final b2bRows = await queryB2b.get();
      final b2bInvoicesList = b2bRows.map((row) {
        final inv = row.readTable(_db.invoices);
        final cust = row.readTable(_db.customers);

        return GstB2BRow(
          invoiceId: inv.id,
          invoiceNumber: inv.invoiceNumber,
          invoiceDate: inv.invoiceDate,
          customerName: cust.name,
          customerGstin: cust.gstApplicable
              ? '27ABCDE1234F1Z5'
              : null, // Mock GSTIN or add field if missing
          taxableValue: inv.subtotal,
          cgstAmount: inv.cgstAmount,
          sgstAmount: inv.sgstAmount,
          igstAmount: inv.igstAmount,
          totalAmount: inv.totalAmount,
        );
      }).toList();

      // 2. Fetch HSN summary grouped by HSN code and description
      final itemsQuery = _db.select(_db.invoices).join([
        innerJoin(
          _db.invoiceItems,
          _db.invoiceItems.invoiceId.equalsExp(_db.invoices.id),
        ),
      ]);
      itemsQuery.where(
        _db.invoices.deletedAt.isNull() &
            _db.invoices.invoiceDate.isBiggerOrEqualValue(start) &
            _db.invoices.invoiceDate.isSmallerOrEqualValue(end) &
            (_db.invoices.status.equals('POSTED') |
                _db.invoices.status.equals('PAID') |
                _db.invoices.status.equals('PARTIALLY_PAID')),
      );

      final itemRows = await itemsQuery.get();
      final hsnGroups = <String, GstHsnSummaryRow>{};

      for (final r in itemRows) {
        final item = r.readTable(_db.invoiceItems);
        final hsnKey = item.hsnCode;
        final existing = hsnGroups[hsnKey];

        if (existing == null) {
          hsnGroups[hsnKey] = GstHsnSummaryRow(
            hsnCode: hsnKey,
            description: item.description,
            unit: item.unit,
            totalQuantity: item.quantity,
            totalValue: item.totalAmount,
            taxableValue: item.taxableAmount,
            cgstAmount: item.cgstAmount,
            sgstAmount: item.sgstAmount,
            igstAmount: item.igstAmount,
          );
        } else {
          hsnGroups[hsnKey] = GstHsnSummaryRow(
            hsnCode: hsnKey,
            description: existing.description,
            unit: existing.unit,
            totalQuantity: existing.totalQuantity + item.quantity,
            totalValue: existing.totalValue + item.totalAmount,
            taxableValue: existing.taxableValue + item.taxableAmount,
            cgstAmount: existing.cgstAmount + item.cgstAmount,
            sgstAmount: existing.sgstAmount + item.sgstAmount,
            igstAmount: existing.igstAmount + item.igstAmount,
          );
        }
      }

      return Result.success(
        GstReport(
          startDate: start,
          endDate: end,
          b2bInvoices: b2bInvoicesList,
          hsnSummary: hsnGroups.values.toList(),
        ),
      );
    } catch (e, st) {
      return Result.failure(
        DatabaseFailure(message: e.toString(), stackTrace: st),
      );
    }
  }
}

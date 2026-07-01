import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:step_up_fuels/app/database/app_database.dart';
import 'package:step_up_fuels/features/customers/data/daos/customers_dao.dart';
import 'package:step_up_fuels/features/customers/data/repositories/customer_repository_impl.dart';
import 'package:step_up_fuels/features/customers/domain/entities/customer.dart';
import 'package:step_up_fuels/features/customers/domain/entities/customer_type.dart';
import 'package:step_up_fuels/features/dashboard/data/services/dashboard_service_impl.dart';
import 'package:step_up_fuels/features/expenses/data/repositories/expense_repository_impl.dart';
import 'package:step_up_fuels/features/expenses/domain/entities/expense.dart';
import 'package:step_up_fuels/features/invoices/data/repositories/invoice_repository_impl.dart';
import 'package:step_up_fuels/features/invoices/domain/entities/invoice.dart';
import 'package:step_up_fuels/features/invoices/domain/entities/invoice_item.dart';
import 'package:step_up_fuels/features/ledger/data/repositories/ledger_repository_impl.dart';
import 'package:step_up_fuels/features/purchases/data/repositories/purchase_repository_impl.dart';
import 'package:step_up_fuels/features/purchases/domain/entities/fuel_purchase.dart';
import 'package:step_up_fuels/features/purchases/domain/entities/fuel_purchase_item.dart';
import 'package:step_up_fuels/features/purchases/domain/entities/supplier.dart';
import 'package:step_up_fuels/features/reports/data/exporters/excel_exporter.dart';
import 'package:step_up_fuels/features/reports/data/exporters/pdf_report_generator.dart';
import 'package:step_up_fuels/features/reports/data/services/reporting_service_impl.dart';

void main() {
  late AppDatabase db;
  late CustomerRepositoryImpl customerRepository;
  late LedgerRepositoryImpl ledgerRepository;
  late InvoiceRepositoryImpl invoiceRepository;
  late PurchaseRepositoryImpl purchaseRepository;
  late ExpenseRepositoryImpl expenseRepository;
  late ReportingServiceImpl reportingService;
  late DashboardServiceImpl dashboardService;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    customerRepository = CustomerRepositoryImpl(CustomersDao(db));
    ledgerRepository = LedgerRepositoryImpl(db.ledgerDao);
    invoiceRepository = InvoiceRepositoryImpl(db.invoicesDao, ledgerRepository);
    purchaseRepository = PurchaseRepositoryImpl(
      db.purchasesDao,
      ledgerRepository,
    );
    expenseRepository = ExpenseRepositoryImpl(db.expensesDao, ledgerRepository);
    reportingService = ReportingServiceImpl(db);
    dashboardService = DashboardServiceImpl(db);

    // Seed fuel products
    await db
        .into(db.products)
        .insert(
          ProductsCompanion(
            id: const Value('fuel-diesel'),
            productCode: const Value('D-50'),
            name: const Value('High Speed Diesel'),
            hsnCode: const Value('2710'),
            unitOfMeasure: const Value('LTRS'),
            isActive: const Value(true),
            createdAt: Value(DateTime.now()),
            updatedAt: Value(DateTime.now()),
            version: const Value(1),
          ),
        );

    // Seed Storage locations
    await db
        .into(db.storageLocations)
        .insert(
          StorageLocationsCompanion(
            id: const Value('main-storage-terminal'),
            name: const Value('Main Terminal Storage'),
            type: const Value('MAIN_STORAGE'),
            isActive: const Value(true),
            createdAt: Value(DateTime.now()),
            updatedAt: Value(DateTime.now()),
            version: const Value(1),
          ),
        );
  });

  tearDown(() async {
    await db.close();
  });

  group('Reports & Dashboard Analytics Integration Tests', () {
    test(
      'should compile live stats, low stock warnings, and transaction logs correctly',
      () async {
        // 1. Arrange: Create customer, suppliers
        final customer = Customer(
          id: 'cust-10',
          customerCode: 'C-010',
          name: 'Infra Corp',
          type: CustomerType.company,
          isActive: true,
          creditLimit: 500000,
          creditDays: 30,
          securityDeposit: 0,
          defaultGstRate: 0.18,
          emailInvoice: false,
          whatsappInvoice: false,
          requirePo: false,
          requireDc: false,
          requireSignature: false,
          gstApplicable: true,
          eInvoiceRequired: false,
          eWayBillRequired: false,
          openingBalance: 0.0,
          currentBalance: 0.0,
          createdBy: 'test',
          createdAt: DateTime.now(),
          updatedBy: 'test',
          updatedAt: DateTime.now(),
          version: 1,
        );
        await customerRepository.save(customer);

        final supplier = Supplier(
          id: 'supp-10',
          supplierCode: 'S-010',
          name: 'HPCL Terminal',
          contactPerson: 'Manager',
          phone: '9876543210',
          isActive: true,
          createdBy: 'test',
          createdAt: DateTime.now(),
          updatedBy: 'test',
          updatedAt: DateTime.now(),
          version: 1,
        );
        await purchaseRepository.saveSupplier(supplier);

        // 2. Register Purchase (10,000 Litres Diesel @ 80.00 / Litre)
        final purchase = FuelPurchase(
          id: 'pur-10',
          purchaseNumber: 'PENDING',
          supplierId: 'supp-10',
          supplierInvoiceNo: 'HP-881',
          purchaseDate: DateTime.now().subtract(const Duration(days: 2)),
          subtotal: 800000.0,
          cgstAmount: 0.0,
          sgstAmount: 0.0,
          igstAmount: 0.0,
          totalAmount: 800000.0,
          paymentStatus: 'UNPAID',
          createdBy: 'test',
          createdAt: DateTime.now(),
          updatedBy: 'test',
          updatedAt: DateTime.now(),
          version: 1,
        );
        const purItem = FuelPurchaseItem(
          id: 'pur-item-10',
          purchaseId: 'pur-10',
          productId: 'fuel-diesel',
          description: 'Diesel bulk purchase',
          quantity: 10000.0,
          unit: 'LTRS',
          rate: 80.0,
          taxableAmount: 800000.0,
          gstRate: 0.0,
          cgstRate: 0.0,
          sgstRate: 0.0,
          igstRate: 0.0,
          cgstAmount: 0.0,
          sgstAmount: 0.0,
          igstAmount: 0.0,
          totalAmount: 800000.0,
          sortOrder: 1,
        );
        await purchaseRepository.savePurchase(purchase, [purItem]);

        // 3. Post Invoice (1,000 Litres Diesel @ 100.00 / Litre = 1,00,000 + 18% GST = 1,18,000)
        final invoice = Invoice(
          id: 'inv-10',
          invoiceNumber: 'DRAFT',
          customerId: 'cust-10',
          invoiceDate: DateTime.now(),
          dueDate: DateTime.now().add(const Duration(days: 30)),
          supplyType: 'B2B',
          placeOfSupply: '27',
          isInterstate: false,
          subtotal: 100000.0,
          cgstAmount: 9000.0,
          sgstAmount: 9000.0,
          igstAmount: 0.0,
          totalAmount: 118000.0,
          amountPaid: 0.0,
          outstanding: 118000.0,
          status: InvoiceStatus.draft,
          createdBy: 'test',
          createdAt: DateTime.now(),
          updatedBy: 'test',
          updatedAt: DateTime.now(),
          version: 1,
        );
        final item = InvoiceItem(
          id: 'item-10',
          invoiceId: 'inv-10',
          productId: 'fuel-diesel',
          hsnCode: '2710',
          description: 'Diesel sales',
          quantity: 1000.0,
          unit: 'LTRS',
          rate: 100.0,
          taxableAmount: 100000.0,
          gstRate: 0.18,
          cgstRate: 0.09,
          sgstRate: 0.09,
          igstRate: 0.0,
          cgstAmount: 9000.0,
          sgstAmount: 9000.0,
          igstAmount: 0.0,
          totalAmount: 118000.0,
          sortOrder: 1,
        );
        await invoiceRepository.save(invoice, [item]);
        await invoiceRepository.post('inv-10');

        // Update customer balance to match posted invoice
        await (db.update(db.customers)..where((t) => t.id.equals('cust-10')))
            .write(const CustomersCompanion(currentBalance: Value(118000.0)));

        // 4. Log operating expense (Salary = 20,000)
        final expense = Expense(
          id: 'exp-10',
          expenseNumber: 'PENDING',
          category: 'DRIVER_SALARY',
          amount: 20000.0,
          expenseDate: DateTime.now(),
          paymentMode: 'BANK_TRANSFER',
          createdBy: 'test',
          createdAt: DateTime.now(),
          updatedBy: 'test',
          updatedAt: DateTime.now(),
          version: 1,
        );
        await expenseRepository.save(expense);

        // ── Act & Assert Dashboard Stats ───────────────────────────────────────
        final dashStatsRes = await dashboardService.getTodayStats();
        expect(dashStatsRes.isSuccess, isTrue);

        final stats = dashStatsRes.dataOrThrow;
        expect(stats.todaySalesLitres, 1000.0);
        expect(stats.todaySalesValue, 118000.0);
        expect(stats.todayDeliveriesCount, 1);
        expect(stats.totalOutstandingReceivables, 118000.0);
        expect(stats.totalActiveCustomers, 1);
        expect(stats.currentMonthRevenue, 100000.0); // Subtotal MTD
        // Stock: 10,000 purchased - 1,000 sold = 9,000 litres
        expect(stats.mainStorageStock, 9000.0);
        expect(stats.recentInvoices.length, 1);
        expect(stats.recentInvoices.first.id, 'inv-10');

        // ── Act & Assert Reporting Queries ─────────────────────────────────────
        final salesRes = await reportingService.getDailySales(DateTime.now());
        expect(salesRes.isSuccess, isTrue);
        expect(salesRes.dataOrThrow.totalLitres, 1000.0);
        expect(salesRes.dataOrThrow.totalAmount, 118000.0);
        expect(salesRes.dataOrThrow.totalOutstanding, 118000.0);

        final stockRes = await reportingService.getStockReport();
        expect(stockRes.isSuccess, isTrue);
        expect(stockRes.dataOrThrow.first.currentStock, 9000.0);

        final expenseRes = await reportingService.getExpenseReport(
          start: DateTime.now().subtract(const Duration(days: 3)),
          end: DateTime.now().add(const Duration(days: 1)),
        );
        expect(expenseRes.isSuccess, isTrue);
        expect(expenseRes.dataOrThrow['DRIVER_SALARY'], 20000.0);

        // Profit & Loss calculation:
        // Revenue = 1,00,000 (Subtotal)
        // COGS = 1,000 (Litres) * 80.00 (Weighted Avg Purchase rate) = 80,000
        // Expenses = 20,000
        // Net Profit = 1,00,000 - 80,000 - 20,000 = 0.00
        final plRes = await reportingService.getProfitLossEstimate(
          start: DateTime.now().subtract(const Duration(days: 3)),
          end: DateTime.now().add(const Duration(days: 1)),
        );
        expect(plRes.isSuccess, isTrue);
        expect(plRes.dataOrThrow.revenue, 100000.0);
        expect(plRes.dataOrThrow.costOfFuelSold, 80000.0);
        expect(plRes.dataOrThrow.operatingExpenses, 20000.0);
        expect(plRes.dataOrThrow.estimatedNetProfit, 0.0);

        final agingRes = await reportingService.getOutstandingReport();
        expect(agingRes.isSuccess, isTrue);
        expect(agingRes.dataOrThrow.first.current, 118000.0);
        expect(agingRes.dataOrThrow.first.totalOutstanding, 118000.0);

        final gstRes = await reportingService.getGstReport(
          start: DateTime.now().subtract(const Duration(days: 1)),
          end: DateTime.now().add(const Duration(days: 1)),
        );
        expect(gstRes.isSuccess, isTrue);
        expect(gstRes.dataOrThrow.b2bInvoices.length, 1);
        expect(gstRes.dataOrThrow.b2bInvoices.first.taxableValue, 100000.0);
        expect(gstRes.dataOrThrow.hsnSummary.first.hsnCode, '2710');
        expect(gstRes.dataOrThrow.hsnSummary.first.totalQuantity, 1000.0);

        // ── Act & Assert Export Document Pipelines ─────────────────────────────
        final excelBytes = ExcelExporter.exportGstReport(gstRes.dataOrThrow);
        expect(excelBytes, isNotNull);
        expect(excelBytes!.isNotEmpty, isTrue);

        final pdfBytes = await PdfReportGenerator.generateGenericReport(
          title: 'Sales Summary',
          subtitle: 'Test Run',
          headers: ['Customer', 'Total'],
          rows: [
            ['Infra Corp', '118000'],
          ],
        );
        expect(pdfBytes.isNotEmpty, isTrue);
      },
    );
  });
}

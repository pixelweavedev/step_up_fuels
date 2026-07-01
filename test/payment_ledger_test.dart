import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:step_up_fuels/app/database/app_database.dart';
import 'package:step_up_fuels/features/customers/data/daos/customers_dao.dart';
import 'package:step_up_fuels/features/customers/data/repositories/customer_repository_impl.dart';
import 'package:step_up_fuels/features/customers/domain/entities/customer.dart';
import 'package:step_up_fuels/features/customers/domain/entities/customer_type.dart';
import 'package:step_up_fuels/features/expenses/data/repositories/expense_repository_impl.dart';
import 'package:step_up_fuels/features/expenses/domain/entities/expense.dart';
import 'package:step_up_fuels/features/invoices/data/models/invoice_mapper.dart';
import 'package:step_up_fuels/features/invoices/data/repositories/invoice_repository_impl.dart';
import 'package:step_up_fuels/features/invoices/domain/entities/invoice.dart';
import 'package:step_up_fuels/features/invoices/domain/entities/invoice_item.dart';
import 'package:step_up_fuels/features/ledger/data/repositories/ledger_repository_impl.dart';
import 'package:step_up_fuels/features/payments/data/repositories/payment_repository_impl.dart';
import 'package:step_up_fuels/features/payments/domain/entities/payment.dart';
import 'package:step_up_fuels/features/purchases/data/repositories/purchase_repository_impl.dart';
import 'package:step_up_fuels/features/purchases/domain/entities/fuel_purchase.dart';
import 'package:step_up_fuels/features/purchases/domain/entities/fuel_purchase_item.dart';
import 'package:step_up_fuels/features/purchases/domain/entities/supplier.dart';

void main() {
  late AppDatabase db;
  late CustomerRepositoryImpl customerRepository;
  late LedgerRepositoryImpl ledgerRepository;
  late InvoiceRepositoryImpl invoiceRepository;
  late PaymentRepositoryImpl paymentRepository;
  late PurchaseRepositoryImpl purchaseRepository;
  late ExpenseRepositoryImpl expenseRepository;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    customerRepository = CustomerRepositoryImpl(CustomersDao(db));
    ledgerRepository = LedgerRepositoryImpl(db.ledgerDao);
    invoiceRepository = InvoiceRepositoryImpl(db.invoicesDao, ledgerRepository);
    paymentRepository = PaymentRepositoryImpl(
      db.paymentsDao,
      ledgerRepository,
      invoiceRepository,
    );
    purchaseRepository = PurchaseRepositoryImpl(
      db.purchasesDao,
      ledgerRepository,
    );
    expenseRepository = ExpenseRepositoryImpl(db.expensesDao, ledgerRepository);
  });

  tearDown(() async {
    await db.close();
  });

  group('Payments & Double-Entry Ledger Integration Tests', () {
    test(
      'should lazily create system accounts and register correct entries upon posting invoice',
      () async {
        // 1. Arrange: Create customer
        final customer = Customer(
          id: 'cust-1',
          customerCode: 'C-001',
          name: 'Tata Motors',
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

        // Create draft invoice
        final invoice = Invoice(
          id: 'inv-1',
          invoiceNumber: 'DRAFT',
          customerId: 'cust-1',
          invoiceDate: DateTime.now(),
          dueDate: DateTime.now().add(const Duration(days: 30)),
          supplyType: 'B2B',
          placeOfSupply: '27',
          isInterstate: false,
          subtotal: 10000.0,
          cgstAmount: 900.0,
          sgstAmount: 900.0,
          igstAmount: 0.0,
          totalAmount: 11800.0,
          amountPaid: 0.0,
          outstanding: 11800.0,
          status: InvoiceStatus.draft,
          createdBy: 'test',
          createdAt: DateTime.now(),
          updatedBy: 'test',
          updatedAt: DateTime.now(),
          version: 1,
        );
        final item = InvoiceItem(
          id: 'item-1',
          invoiceId: 'inv-1',
          productId: 'fuel-diesel',
          hsnCode: '2710',
          description: 'Diesel',
          quantity: 100.0,
          unit: 'LTRS',
          rate: 100.0,
          taxableAmount: 10000.0,
          gstRate: 0.18,
          cgstRate: 0.09,
          sgstRate: 0.09,
          igstRate: 0.0,
          cgstAmount: 900.0,
          sgstAmount: 900.0,
          igstAmount: 0.0,
          totalAmount: 11800.0,
          sortOrder: 1,
        );
        await invoiceRepository.save(invoice, [item]);

        // 2. Act: Post the invoice
        final postRes = await invoiceRepository.post('inv-1');
        expect(postRes.isSuccess, isTrue);

        // 3. Assert: Verify customer balance was updated
        final updatedCust = await customerRepository.getById('cust-1');
        expect(updatedCust.dataOrThrow.currentBalance, 11800.0);

        // Verify ledger entries were created
        final customerAcc = await ledgerRepository.getOrCreateCustomerAccount(
          'cust-1',
          'Tata Motors',
          'C-001',
        );
        final salesAcc = await ledgerRepository.getOrCreateSystemAccount(
          'ACT-SALES',
          'Sales Account',
          'SALES',
        );

        final customerEntries = await ledgerRepository.getEntries(
          customerAcc.dataOrThrow.id,
        );
        expect(customerEntries.dataOrThrow.length, 1);
        expect(customerEntries.dataOrThrow.first.debitAmount, 11800.0);
        expect(customerEntries.dataOrThrow.first.runningBalance, 11800.0);

        final salesEntries = await ledgerRepository.getEntries(
          salesAcc.dataOrThrow.id,
        );
        expect(salesEntries.dataOrThrow.length, 1);
        expect(salesEntries.dataOrThrow.first.creditAmount, 11800.0);
        expect(salesEntries.dataOrThrow.first.runningBalance, 11800.0);

        // Verify stock movement (DELIVERY_OUT)
        final movements = await db.select(db.inventoryMovements).get();
        expect(movements.length, 1);
        expect(movements.first.type, 'DELIVERY_OUT');
        expect(movements.first.quantity, 100.0);
      },
    );

    test(
      'should apply payment receipt, allocate to oldest outstanding invoices, and post correct ledger entries',
      () async {
        // 1. Arrange: Create customer & post two invoices
        final customer = Customer(
          id: 'cust-2',
          customerCode: 'C-002',
          name: 'HP Limited',
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

        final inv1 = Invoice(
          id: 'inv-2a',
          invoiceNumber: 'SUF/2026-27/0002',
          customerId: 'cust-2',
          invoiceDate: DateTime.now().subtract(const Duration(days: 5)),
          dueDate: DateTime.now().add(const Duration(days: 25)),
          supplyType: 'B2B',
          placeOfSupply: '27',
          isInterstate: false,
          subtotal: 5000.0,
          cgstAmount: 0.0,
          sgstAmount: 0.0,
          igstAmount: 0.0,
          totalAmount: 5000.0,
          amountPaid: 0.0,
          outstanding: 5000.0,
          status: InvoiceStatus.posted,
          createdBy: 'test',
          createdAt: DateTime.now(),
          updatedBy: 'test',
          updatedAt: DateTime.now(),
          version: 1,
        );
        final inv2 = Invoice(
          id: 'inv-2b',
          invoiceNumber: 'SUF/2026-27/0003',
          customerId: 'cust-2',
          invoiceDate: DateTime.now().subtract(const Duration(days: 2)),
          dueDate: DateTime.now().add(const Duration(days: 28)),
          supplyType: 'B2B',
          placeOfSupply: '27',
          isInterstate: false,
          subtotal: 7000.0,
          cgstAmount: 0.0,
          sgstAmount: 0.0,
          igstAmount: 0.0,
          totalAmount: 7000.0,
          amountPaid: 0.0,
          outstanding: 7000.0,
          status: InvoiceStatus.posted,
          createdBy: 'test',
          createdAt: DateTime.now(),
          updatedBy: 'test',
          updatedAt: DateTime.now(),
          version: 1,
        );

        // Force save as posted for payments testing
        await db.into(db.invoices).insert(inv1.toCompanion());
        await db.into(db.invoices).insert(inv2.toCompanion());

        // Update customer balance to reflect posted invoices
        await (db.update(db.customers)..where((t) => t.id.equals('cust-2')))
            .write(const CustomersCompanion(currentBalance: Value(12000.0)));

        // 2. Act: Receive payment of 8000
        final payment = Payment(
          id: 'pmt-1',
          paymentNumber: 'PENDING',
          customerId: 'cust-2',
          amount: 8000.0,
          paymentDate: DateTime.now(),
          paymentMode: 'BANK_TRANSFER',
          referenceNumber: 'TXN-999',
          bankName: 'HDFC Bank',
          createdBy: 'test',
          createdAt: DateTime.now(),
          updatedBy: 'test',
          updatedAt: DateTime.now(),
          version: 1,
        );

        final pmtRes = await paymentRepository.receivePayment(payment);
        expect(pmtRes.isSuccess, isTrue);

        // 3. Assert: Check customer balance is updated (12000 - 8000 = 4000)
        final customerAfter = await customerRepository.getById('cust-2');
        expect(customerAfter.dataOrThrow.currentBalance, 4000.0);

        // Check invoices: inv1 should be fully PAID (5000), inv2 partially PAID (3000 applied, 4000 outstanding)
        final updatedInv1 = await invoiceRepository.getById('inv-2a');
        final updatedInv2 = await invoiceRepository.getById('inv-2b');

        expect(updatedInv1.dataOrThrow.status, InvoiceStatus.paid);
        expect(updatedInv1.dataOrThrow.outstanding, 0.0);

        expect(updatedInv2.dataOrThrow.status, InvoiceStatus.partiallyPaid);
        expect(updatedInv2.dataOrThrow.outstanding, 4000.0);

        // Verify double-entry ledger rows
        final bankAcc = await ledgerRepository.getOrCreateSystemAccount(
          'ACT-BANK',
          'Bank Account',
          'BANK',
        );
        final custAcc = await ledgerRepository.getOrCreateCustomerAccount(
          'cust-2',
          'HP Limited',
          'C-002',
        );

        final bankEntries = await ledgerRepository.getEntries(
          bankAcc.dataOrThrow.id,
        );
        expect(bankEntries.dataOrThrow.length, 1);
        expect(bankEntries.dataOrThrow.first.debitAmount, 8000.0);

        final custEntries = await ledgerRepository.getEntries(
          custAcc.dataOrThrow.id,
        );
        expect(custEntries.dataOrThrow.length, 1);
        expect(custEntries.dataOrThrow.first.creditAmount, 8000.0);
      },
    );

    test(
      'should create reversing ledger entries and inventory movements when posted invoice is cancelled',
      () async {
        // 1. Arrange: Create customer, post invoice
        final customer = Customer(
          id: 'cust-3',
          customerCode: 'C-003',
          name: 'Mahindra',
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

        final invoice = Invoice(
          id: 'inv-3',
          invoiceNumber: 'SUF/2026-27/0004',
          customerId: 'cust-3',
          invoiceDate: DateTime.now(),
          dueDate: DateTime.now().add(const Duration(days: 30)),
          supplyType: 'B2B',
          placeOfSupply: '27',
          isInterstate: false,
          subtotal: 5000.0,
          cgstAmount: 0.0,
          sgstAmount: 0.0,
          igstAmount: 0.0,
          totalAmount: 5000.0,
          amountPaid: 0.0,
          outstanding: 5000.0,
          status: InvoiceStatus.posted,
          createdBy: 'test',
          createdAt: DateTime.now(),
          updatedBy: 'test',
          updatedAt: DateTime.now(),
          version: 1,
        );
        final item = InvoiceItem(
          id: 'item-3',
          invoiceId: 'inv-3',
          productId: 'fuel-diesel',
          hsnCode: '2710',
          description: 'Diesel',
          quantity: 50.0,
          unit: 'LTRS',
          rate: 100.0,
          taxableAmount: 5000.0,
          gstRate: 0.0,
          cgstRate: 0.0,
          sgstRate: 0.0,
          igstRate: 0.0,
          cgstAmount: 0.0,
          sgstAmount: 0.0,
          igstAmount: 0.0,
          totalAmount: 5000.0,
          sortOrder: 1,
        );

        // Force save as posted for reversal testing
        await db.into(db.invoices).insert(invoice.toCompanion());
        await db.into(db.invoiceItems).insert(item.toCompanion());

        // Update customer balance to reflect posted invoice
        await (db.update(db.customers)..where((t) => t.id.equals('cust-3')))
            .write(const CustomersCompanion(currentBalance: Value(5000.0)));

        // 2. Act: Cancel the posted invoice
        final cancelRes = await invoiceRepository.cancel(
          'inv-3',
          'Wrong pricing entered',
        );
        expect(cancelRes.isSuccess, isTrue);

        // 3. Assert: Verify customer balance returned to 0
        final updatedCust = await customerRepository.getById('cust-3');
        expect(updatedCust.dataOrThrow.currentBalance, 0.0);

        // Verify invoice status is CANCELLED
        final updatedInv = await invoiceRepository.getById('inv-3');
        expect(updatedInv.dataOrThrow.status, InvoiceStatus.cancelled);

        // Verify reversing ledger entries exist
        final custAcc = await ledgerRepository.getOrCreateCustomerAccount(
          'cust-3',
          'Mahindra',
          'C-003',
        );
        final salesAcc = await ledgerRepository.getOrCreateSystemAccount(
          'ACT-SALES',
          'Sales Account',
          'SALES',
        );

        final custEntries = await ledgerRepository.getEntries(
          custAcc.dataOrThrow.id,
        );
        expect(custEntries.dataOrThrow.length, 1);
        expect(custEntries.dataOrThrow.first.creditAmount, 5000.0);

        final salesEntries = await ledgerRepository.getEntries(
          salesAcc.dataOrThrow.id,
        );
        expect(salesEntries.dataOrThrow.length, 1);
        expect(salesEntries.dataOrThrow.first.debitAmount, 5000.0);

        // Verify stock movement (DELIVERY_RETURN)
        final movements = await db.select(db.inventoryMovements).get();
        expect(movements.length, 1);
        expect(movements.first.type, 'DELIVERY_RETURN');
        expect(movements.first.quantity, 50.0);
      },
    );

    test(
      'should register purchases and expenses ledger transactions correctly',
      () async {
        // 1. Register purchase
        final supplier = Supplier(
          id: 'supp-1',
          supplierCode: 'S-001',
          name: 'HPCL Supplier',
          contactPerson: 'Mr. HP',
          phone: '1234567890',
          isActive: true,
          createdBy: 'test',
          createdAt: DateTime.now(),
          updatedBy: 'test',
          updatedAt: DateTime.now(),
          version: 1,
        );
        await purchaseRepository.saveSupplier(supplier);

        final purchase = FuelPurchase(
          id: 'pur-1',
          purchaseNumber: 'PENDING',
          supplierId: 'supp-1',
          supplierInvoiceNo: 'SUP-991',
          purchaseDate: DateTime.now(),
          subtotal: 10000.0,
          cgstAmount: 0.0,
          sgstAmount: 0.0,
          igstAmount: 0.0,
          totalAmount: 10000.0,
          paymentStatus: 'UNPAID',
          createdBy: 'test',
          createdAt: DateTime.now(),
          updatedBy: 'test',
          updatedAt: DateTime.now(),
          version: 1,
        );
        const purItem = FuelPurchaseItem(
          id: 'pur-item-1',
          purchaseId: 'pur-1',
          productId: 'fuel-diesel',
          description: 'Diesel',
          quantity: 100.0,
          unit: 'LTRS',
          rate: 100.0,
          taxableAmount: 10000.0,
          gstRate: 0.0,
          cgstRate: 0.0,
          sgstRate: 0.0,
          igstRate: 0.0,
          cgstAmount: 0.0,
          sgstAmount: 0.0,
          igstAmount: 0.0,
          totalAmount: 10000.0,
          sortOrder: 1,
        );

        final purRes = await purchaseRepository.savePurchase(purchase, [
          purItem,
        ]);
        expect(purRes.isSuccess, isTrue);

        final purchaseAcc = await ledgerRepository.getOrCreateSystemAccount(
          'ACT-PURCHASE',
          'Purchase Account',
          'PURCHASE',
        );
        final suppAcc = await ledgerRepository.getOrCreateSupplierAccount(
          'supp-1',
          'HPCL Supplier',
          'S-001',
        );

        final purchaseEntries = await ledgerRepository.getEntries(
          purchaseAcc.dataOrThrow.id,
        );
        expect(purchaseEntries.dataOrThrow.length, 1);
        expect(purchaseEntries.dataOrThrow.first.debitAmount, 10000.0);

        final suppEntries = await ledgerRepository.getEntries(
          suppAcc.dataOrThrow.id,
        );
        expect(suppEntries.dataOrThrow.length, 1);
        expect(suppEntries.dataOrThrow.first.creditAmount, 10000.0);

        // 2. Register expense
        final expense = Expense(
          id: 'exp-1',
          expenseNumber: 'PENDING',
          category: 'OFFICE_RENT',
          amount: 2500.0,
          expenseDate: DateTime.now(),
          paymentMode: 'BANK_TRANSFER',
          createdBy: 'test',
          createdAt: DateTime.now(),
          updatedBy: 'test',
          updatedAt: DateTime.now(),
          version: 1,
        );

        final expRes = await expenseRepository.save(expense);
        expect(expRes.isSuccess, isTrue);

        final expAcc = await ledgerRepository.getOrCreateSystemAccount(
          'ACT-EXP-OFFICE_RENT',
          'OFFICE RENT Expense',
          'EXPENSE',
        );
        final bankAcc = await ledgerRepository.getOrCreateSystemAccount(
          'ACT-BANK',
          'Bank Account',
          'BANK',
        );

        final expEntries = await ledgerRepository.getEntries(
          expAcc.dataOrThrow.id,
        );
        expect(expEntries.dataOrThrow.length, 1);
        expect(expEntries.dataOrThrow.first.debitAmount, 2500.0);

        final bankEntries = await ledgerRepository.getEntries(
          bankAcc.dataOrThrow.id,
        );
        expect(bankEntries.dataOrThrow.length, 1);
        expect(bankEntries.dataOrThrow.first.creditAmount, 2500.0);
      },
    );
  });
}

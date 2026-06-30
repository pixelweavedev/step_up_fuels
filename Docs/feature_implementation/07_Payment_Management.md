# 07 — Payment Management Design

## Overview
Payment Management processes incoming receipts from customers. It supports full, partial, and advance payments. Every payment updates outstanding invoice amounts and writes to the double-entry ledger.

---

## Domain Entities

### Payment
```dart
class Payment {
  final String id;                    // UUID
  final String paymentNumber;         // Auto-generated e.g. PMT/2026-27/001
  final String customerId;            // FK to Customers
  final String? invoiceId;            // FK to Invoices (nullable if advance payment)
  final double amount;
  final DateTime paymentDate;
  final String paymentMode;           // CASH, UPI, NEFT, RTGS, CHEQUE
  final String? referenceNumber;      // Bank txn ID, UTR, cheque number
  final String? bankName;             // Depositing bank name
  final String? notes;

  // Auditing & SaaS Scope
  final String createdBy;
  final DateTime createdAt;
  final String updatedBy;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int version;
  final String? tenantId;
}
```

### LedgerAccount
```dart
class LedgerAccount {
  final String id;                    // UUID
  final String accountCode;           // e.g. ACT-1001 (Unique)
  final String name;                  // e.g. "Tata Motors A/c", "HDFC Bank A/c"
  final String accountType;           // CUSTOMER, SUPPLIER, CASH, BANK, SALES, EXPENSE, TAX
  final String? referenceId;          // FK to Customers / Suppliers (if account is linked)
  final String? referenceType;        // CUSTOMER, SUPPLIER
  final bool isSystem;                // System accounts cannot be deleted
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

### LedgerEntry
```dart
class LedgerEntry {
  final String id;                    // UUID
  final String ledgerAccountId;       // FK to LedgerAccounts
  final DateTime entryDate;
  final String description;           // e.g. "Invoice generated SUF/2026-27/001"
  final double debitAmount;           // Always >= 0
  final double creditAmount;          // Always >= 0
  final String? referenceId;          // FK to Invoice, Payment, Purchase, or Expense
  final String? referenceType;        // INVOICE, PAYMENT, PURCHASE, EXPENSE
  final double runningBalance;        // Running total for performance
  final DateTime createdAt;
  final String createdBy;
}
```

---

## Database Drift Schema Details

```dart
@DataClassName('PaymentRow')
class Payments extends Table {
  TextColumn get id => text()();
  TextColumn get paymentNumber => text().unique()();
  TextColumn get customerId => text()();
  TextColumn get invoiceId => text().nullable()();
  RealColumn get amount => real()();
  DateTimeColumn get paymentDate => dateTime()();
  TextColumn get paymentMode => text()(); // CASH, UPI, BANK_TRANSFER, etc.
  TextColumn get referenceNumber => text().nullable()();
  TextColumn get bankName => text().nullable()();
  TextColumn get notes => text().nullable()();

  // Auditing & SaaS
  TextColumn get createdBy => text().withDefault(const Constant('system'))();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get updatedBy => text().withDefault(const Constant('system'))();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  TextColumn get tenantId => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('LedgerAccountRow')
class LedgerAccounts extends Table {
  TextColumn get id => text()();
  TextColumn get accountCode => text().unique()();
  TextColumn get name => text()();
  TextColumn get accountType => text()(); // CUSTOMER, SUPPLIER, CASH, BANK, SALES, EXPENSE, TAX
  TextColumn get referenceId => text().nullable()();
  TextColumn get referenceType => text().nullable()();
  BoolColumn get isSystem => boolean().withDefault(const Constant(false))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('LedgerEntryRow')
class LedgerEntries extends Table {
  TextColumn get id => text()();
  TextColumn get ledgerAccountId => text()();
  DateTimeColumn get entryDate => dateTime()();
  TextColumn get description => text()();
  RealColumn get debitAmount => real().withDefault(const Constant(0.0))();
  RealColumn get creditAmount => real().withDefault(const Constant(0.0))();
  TextColumn get referenceId => text().nullable()();
  TextColumn get referenceType => text().nullable()();
  RealColumn get runningBalance => real().withDefault(const Constant(0.0))();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get createdBy => text().withDefault(const Constant('system'))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
```

---

## Processing Payments (Logic)

### Receipt Allocation Algorithm
When a payment $P$ of value $A$ is received for Customer $C$:
- **Case 1: Direct Invoice Link** (User selected a specific invoice $I$ to pay):
  1. Increment invoice's `amountPaid` by $A$, recalculate `outstanding` = `totalAmount - amountPaid`.
  2. If `outstanding == 0`, status = `PAID`. If `outstanding > 0`, status = `PARTIALLY_PAID`.
  3. Create Ledger Entries:
     - Debit Cash/Bank Account: $A$.
     - Credit Customer Account: $A$.
- **Case 2: Auto-Allocate to Oldest Invoices** (User enters payment without selection):
  1. Fetch all unpaid/partially paid posted invoices of $C$ ordered by `invoiceDate ASC`.
  2. For each invoice:
     - Apply remaining payment balance. Update invoice status accordingly.
     - Continue until payment is fully allocated.
  3. If there is leftover payment, record it as an **Advance Payment** (unallocated `invoiceId = null`).
  4. Create Ledger Entries as above.

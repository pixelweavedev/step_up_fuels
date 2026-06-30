# 01 — Billing & Invoicing Design

## Overview
The Billing & Invoicing module handles the lifecycle of customer tax invoices. Invoices must comply with Indian GST rules (taxable value, CGST, SGST, IGST, place of supply) and support future e-Invoicing/e-Way bill integrations.

---

## Domain Entities

### Invoice
```dart
class Invoice {
  final String id;                    // UUID
  final String invoiceNumber;         // e.g. SUF/2026-27/001
  final String customerId;            // FK to Customers
  final String? customerSiteId;       // FK to CustomerSites
  final DateTime invoiceDate;
  final DateTime dueDate;
  final String supplyType;            // B2B, B2C
  final String placeOfSupply;         // State code (e.g. "27")
  final bool isInterstate;            // True if seller_state != buyer_state
  final double subtotal;              // Taxable amount before GST
  final double cgstAmount;
  final double sgstAmount;
  final double igstAmount;
  final double totalAmount;           // Total after taxes
  final double amountPaid;            // Total payments applied
  final double outstanding;           // totalAmount - amountPaid
  final InvoiceStatus status;         // DRAFT, VERIFIED, POSTED, PAID, PARTIALLY_PAID, OVERDUE, CANCELLED
  final String? notes;
  final DateTime? cancelledAt;
  final String? cancelledReason;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final String updatedBy;
  final int version;
  final String? tenantId;             // Multi-tenancy
}
```

### InvoiceItem
```dart
class InvoiceItem {
  final String id;
  final String invoiceId;
  final String productId;
  final String hsnCode;
  final String description;
  final double quantity;              // Litres or KL
  final String unit;                  // LTRS, KL
  final double rate;                  // Rate per unit (exclusive of GST)
  final double taxableAmount;         // quantity * rate
  final double gstRate;               // e.g., 0.18
  final double cgstRate;              // e.g., 0.09
  final double sgstRate;              // e.g., 0.09
  final double igstRate;              // e.g., 0.18
  final double cgstAmount;
  final double sgstAmount;
  final double igstAmount;
  final double totalAmount;           // taxableAmount + taxes
  final int sortOrder;
}
```

### CreditDebitNote (Future Scope)
```dart
class CreditDebitNote {
  final String id;
  final String noteNumber;            // e.g. CDN/2026-27/001
  final String invoiceId;             // Reference invoice
  final String customerId;
  final String noteType;              // CREDIT, DEBIT
  final DateTime noteDate;
  final double subtotal;
  final double cgstAmount;
  final double sgstAmount;
  final double igstAmount;
  final double totalAmount;
  final String reason;                // Sales return, price diff, etc.
  final String status;                // DRAFT, POSTED, CANCELLED
  final DateTime createdAt;
}
```

---

## State Machine: InvoiceStatus
Valid transitions:
- `DRAFT` ➔ `VERIFIED`
- `VERIFIED` ➔ `POSTED`
- `POSTED` ➔ `PARTIALLY_PAID` or `PAID` or `OVERDUE`
- `PARTIALLY_PAID` ➔ `PAID` or `OVERDUE`
- `OVERDUE` ➔ `PARTIALLY_PAID` or `PAID`
- `DRAFT` / `VERIFIED` / `POSTED` / `OVERDUE` ➔ `CANCELLED` (requires a reason)

---

## Database Drift Schema Details

```dart
@DataClassName('InvoiceRow')
class Invoices extends Table {
  TextColumn get id => text()();
  TextColumn get invoiceNumber => text().unique()();
  TextColumn get customerId => text()();
  TextColumn get customerSiteId => text().nullable()();
  DateTimeColumn get invoiceDate => dateTime()();
  DateTimeColumn get dueDate => dateTime()();
  TextColumn get supplyType => text()();
  TextColumn get placeOfSupply => text()();
  BoolColumn get isInterstate => boolean().withDefault(const Constant(false))();
  RealColumn get subtotal => real()();
  RealColumn get cgstAmount => real().withDefault(const Constant(0.0))();
  RealColumn get sgstAmount => real().withDefault(const Constant(0.0))();
  RealColumn get igstAmount => real().withDefault(const Constant(0.0))();
  RealColumn get totalAmount => real()();
  RealColumn get amountPaid => real().withDefault(const Constant(0.0))();
  RealColumn get outstanding => real()();
  TextColumn get status => text()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get cancelledAt => dateTime().nullable()();
  TextColumn get cancelledReason => text().nullable()();
  
  // Auditing & SaaS Scope
  TextColumn get createdBy => text().withDefault(const Constant('system'))();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get updatedBy => text().withDefault(const Constant('system'))();
  DateTimeColumn get updatedAt => dateTime()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  TextColumn get tenantId => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('InvoiceItemRow')
class InvoiceItems extends Table {
  TextColumn get id => text()();
  TextColumn get invoiceId => text()();
  TextColumn get productId => text()();
  TextColumn get hsnCode => text()();
  TextColumn get description => text()();
  RealColumn get quantity => real()();
  TextColumn get unit => text()();
  RealColumn get rate => real()();
  RealColumn get taxableAmount => real()();
  RealColumn get gstRate => real()();
  RealColumn get cgstRate => real().withDefault(const Constant(0.0))();
  RealColumn get sgstRate => real().withDefault(const Constant(0.0))();
  RealColumn get igstRate => real().withDefault(const Constant(0.0))();
  RealColumn get cgstAmount => real().withDefault(const Constant(0.0))();
  RealColumn get sgstAmount => real().withDefault(const Constant(0.0))();
  RealColumn get igstAmount => real().withDefault(const Constant(0.0))();
  RealColumn get totalAmount => real()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
```

---

## Business Logic & Services

### InvoiceService
- **`generateInvoiceNumber`**: Reads setting `invoice_prefix` (defaults to `SUF`) and counter, parses current financial year (April-March), increments atomically in database transaction on invoice posting.
- **`postInvoice`**: Executes in a transaction:
  1. Sets invoice status to `POSTED`.
  2. Increments the invoice counter.
  3. Records `InventoryMovement` (type: `invoiceOut`) for each product.
  4. Creates `LedgerEntry` (debit Customer Account, credit Sales Account).
  5. If CGST/SGST/IGST are non-zero, creates `LedgerEntry` (credit GST Account).
  6. Emits `InvoicePosted` domain event.
- **`cancelInvoice`**: Enforces cancellation. If already posted, creates offsetting `InventoryMovement` (type: `adjustmentIn`) to return stock, and offsets `LedgerEntry` entries or creates counter-entries in a database transaction.

### GstCalculationService
Calculates GST based on:
- Seller State Code (defined in Company Settings)
- Customer Site State Code / Billing State Code (determines Place of Supply)
- If codes match, applies CGST + SGST (each = `gstRate / 2`).
- If mismatch, applies IGST (`gstRate`).

---

## PDF Generation & Print
- Utilizes `pdf` and `printing` packages.
- Layout styled exactly according to the standard Indian tax invoice:
  - Supplier Header (GSTIN, PAN, Address, Bank details).
  - Bill To / Ship To details with customer GSTIN and state codes.
  - Itemized table with tax breakdown.
  - Taxable vs Tax breakdown summary table.
  - Amount in words (using Indian Number formatting e.g., Lakhs, Crores).
  - Terms & Signature section.

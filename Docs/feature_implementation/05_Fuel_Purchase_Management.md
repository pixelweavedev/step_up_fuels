# 05 — Fuel Purchase Management Design

## Overview
Fuel Purchase Management tracks fuel purchases from external suppliers (OMCs or distributors). When a fuel purchase is recorded, the system automatically registers the inventory addition (into Main Storage) and handles accounts payable entries in the double-entry ledger.

---

## Domain Entities

### Supplier
```dart
class Supplier {
  final String id;                    // UUID
  final String supplierCode;          // e.g. SPL-001
  final String name;                  // Company Name
  final String? tradeName;
  final String? gstin;
  final String? pan;
  final String? billingAddressLine1;
  final String? billingAddressLine2;
  final String? billingCity;
  final String? billingState;
  final String? billingPincode;
  final String contactPerson;
  final String phone;
  final String? email;
  final bool isActive;
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

### FuelPurchase
```dart
class FuelPurchase {
  final String id;                    // UUID
  final String purchaseNumber;        // Auto-generated e.g. PUR/2026-27/001
  final String supplierId;            // FK to Suppliers
  final String supplierInvoiceNo;     // Supplier's printed invoice number
  final DateTime purchaseDate;
  final double subtotal;              // Taxable amount before GST
  final double cgstAmount;
  final double sgstAmount;
  final double igstAmount;
  final double totalAmount;           // Total amount paid/payable
  final String paymentStatus;         // UNPAID, PARTIALLY_PAID, PAID
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

### FuelPurchaseItem
```dart
class FuelPurchaseItem {
  final String id;                    // UUID
  final String purchaseId;            // FK to FuelPurchases
  final String productId;             // FK to Products
  final String description;           // HSD, Petrol, etc.
  final double quantity;
  final String unit;                  // LTRS, KL
  final double rate;                  // Purchase rate per unit (exclusive of GST)
  final double taxableAmount;         // quantity * rate
  final double gstRate;
  final double cgstRate;
  final double sgstRate;
  final double igstRate;
  final double cgstAmount;
  final double sgstAmount;
  final double igstAmount;
  final double totalAmount;
  final int sortOrder;
}
```

---

## Database Drift Schema Details

```dart
@DataClassName('SupplierRow')
class Suppliers extends Table {
  TextColumn get id => text()();
  TextColumn get supplierCode => text().unique()();
  TextColumn get name => text()();
  TextColumn get tradeName => text().nullable()();
  TextColumn get gstin => text().nullable()();
  TextColumn get pan => text().nullable()();
  TextColumn get billingAddressLine1 => text().nullable()();
  TextColumn get billingAddressLine2 => text().nullable()();
  TextColumn get billingCity => text().nullable()();
  TextColumn get billingState => text().nullable()();
  TextColumn get billingPincode => text().nullable()();
  TextColumn get contactPerson => text()();
  TextColumn get phone => text()();
  TextColumn get email => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
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

@DataClassName('FuelPurchaseRow')
class FuelPurchases extends Table {
  TextColumn get id => text()();
  TextColumn get purchaseNumber => text().unique()();
  TextColumn get supplierId => text()();
  TextColumn get supplierInvoiceNo => text()();
  DateTimeColumn get purchaseDate => dateTime()();
  RealColumn get subtotal => real()();
  RealColumn get cgstAmount => real().withDefault(const Constant(0.0))();
  RealColumn get sgstAmount => real().withDefault(const Constant(0.0))();
  RealColumn get igstAmount => real().withDefault(const Constant(0.0))();
  RealColumn get totalAmount => real()();
  TextColumn get paymentStatus => text()(); // UNPAID, PARTIALLY_PAID, PAID
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

@DataClassName('FuelPurchaseItemRow')
class FuelPurchaseItems extends Table {
  TextColumn get id => text()();
  TextColumn get purchaseId => text()();
  TextColumn get productId => text()();
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

## Purchase Workflows & Inventory Hook

Saving a fuel purchase updates multiple features in a single transaction:
1. Insert `FuelPurchase` and `FuelPurchaseItem` records.
2. Insert an `InventoryMovement`:
   - `source_location_id` = `null` (External purchase)
   - `destination_location_id` = `MAIN_STORAGE_ID` (Added to Main Terminal Storage)
   - `type` = `purchaseIn`
   - `quantity` = Total purchase quantity
3. Create `LedgerEntry` entries:
   - Debit Purchase Account (Total taxable subtotal)
   - Debit Input GST Account (CGST, SGST, IGST)
   - Credit Supplier Account (Total amount payable)
4. Emit `FuelPurchaseRecorded` domain event.

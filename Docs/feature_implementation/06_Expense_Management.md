# 06 — Expense Management Design

## Overview
Expense Management tracks company-level operational costs. Expenses can be general office overhead or direct variable costs associated with a specific vehicle (service, insurance, road tax, FASTag) or driver (salary, allowance). 

---

## Domain Entities

### ExpenseCategory
An extensible list of operational categories:
- `DRIVER_SALARY`
- `VEHICLE_MAINTENANCE`
- `VEHICLE_REPAIR`
- `VEHICLE_INSURANCE`
- `ROAD_TAX`
- `FASTAG`
- `TOLL_CHARGES`
- `OFFICE_RENT`
- `OFFICE_EXPENSES`
- `MISCELLANEOUS`

### Expense
```dart
class Expense {
  final String id;                    // UUID
  final String expenseNumber;         // Auto-generated e.g. EXP/2026-27/001
  final String category;              // Enum/Text
  final double amount;
  final DateTime expenseDate;
  final String paymentMode;           // CASH, UPI, BANK_TRANSFER
  final String? paymentReference;     // Transaction ID, cheque number
  final String? vehicleId;            // FK to Vehicles (optional)
  final String? driverId;             // FK to Drivers (optional)
  final String? billDocumentId;       // FK to Documents (optional)
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

---

## Database Drift Schema Details

```dart
@DataClassName('ExpenseRow')
class Expenses extends Table {
  TextColumn get id => text()();
  TextColumn get expenseNumber => text().unique()();
  TextColumn get category => text()(); // DRIVER_SALARY, VEHICLE_MAINTENANCE, etc.
  RealColumn get amount => real()();
  DateTimeColumn get expenseDate => dateTime()();
  TextColumn get paymentMode => text()(); // CASH, UPI, BANK_TRANSFER, etc.
  TextColumn get paymentReference => text().nullable()();
  TextColumn get vehicleId => text().nullable()();
  TextColumn get driverId => text().nullable()();
  TextColumn get billDocumentId => text().nullable()();
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
```

---

## Financial Workflows (Ledger Integration)
When an expense is recorded:
1. Insert the `Expense` row in the database.
2. Generate corresponding double-entry `LedgerEntry` records:
   - **Debit**: Operational Expense Account (specific to category, e.g. "Vehicle Maintenance Expense").
   - **Credit**: Asset Account (Cash or Bank depending on `paymentMode`).
3. If `vehicleId` is specified, it allows the Reports module to query profitability per Bowser (Deliveries Revenue - Bowser-specific Expenses).

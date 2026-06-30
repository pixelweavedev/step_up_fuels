# 02 — Fuel Stock Management Design

## Overview
Fuel stock is calculated on-demand from inventory movements. The ERP must track stock in the main fuel terminal (storage tank) as well as inside each portable Bowser (vehicle tank). 

We model this using a multi-location warehouse structure:
1. **Storage Locations**: Main Storage Terminal or specific Bowsers.
2. **Movements**: Double-entry stock transfers between locations or exterior interfaces (suppliers/customers).

---

## Domain Entities

### StorageLocation
```dart
class StorageLocation {
  final String id;
  final String name;                  // e.g. "Main Terminal Tank", "Bowser MH-12-Q-4532"
  final StorageLocationType type;     // MAIN_STORAGE, BOWSER
  final String? vehicleId;            // FK to Vehicles (if type is BOWSER)
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
}
enum StorageLocationType { mainStorage, bowser }
```

### InventoryMovement
```dart
class InventoryMovement {
  final String id;
  final String productId;
  final String? sourceLocationId;      // Null if external (Purchase, Opening Stock, Gain)
  final String? destinationLocationId; // Null if external (Invoice delivery, Leakage loss)
  final MovementType type;             // PURCHASE_IN, BOWSER_LOAD, DELIVERY_OUT, ADJUSTMENT_GAIN, ADJUSTMENT_LOSS, OPENING_STOCK
  final double quantity;               // Always positive
  final String? referenceId;           // Purchase ID, Invoice ID, Delivery ID, or Adjustment ID
  final String? referenceType;         // PURCHASE, INVOICE, DELIVERY, ADJUSTMENT
  final DateTime movementDate;
  final String? notes;
  final DateTime createdAt;
}

enum MovementType {
  purchaseIn,    // Supplier -> Main Storage
  bowserLoad,    // Main Storage -> Bowser
  deliveryOut,   // Bowser -> Customer Site
  adjustmentIn,  // Gain
  adjustmentOut, // Loss/Leakage
  openingStock,  // Initial seed
}
```

### StockAdjustment
```dart
class StockAdjustment {
  final String id;
  final String storageLocationId;      // Main Storage or specific Bowser
  final String productId;
  final String adjustmentType;        // GAIN, LOSS
  final double quantity;
  final String reason;                // e.g., "Temperature shrinkage", "Leakage", "Physical verification"
  final DateTime adjustmentDate;
  final String approvedBy;
  final DateTime createdAt;
}
```

### DailyStockReconciliation
```dart
class DailyStockReconciliation {
  final String id;
  final String storageLocationId;
  final DateTime reconciliationDate;
  final double openingStock;
  final double quantityReceived;      // Transfers in
  final double quantityDispensed;     // Deliveries/Transfers out
  final double bookStock;             // opening + received - dispensed
  final double physicalStock;         // Dipped rod / flow meter reading
  final double variance;              // physical - book (loss/gain)
  final String status;                // RECONCILED, UNRECONCILED
  final String performedBy;
  final DateTime createdAt;
}
```

---

## Database Drift Schema Details

```dart
@DataClassName('StorageLocationRow')
class StorageLocations extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get type => text()(); // MAIN_STORAGE, BOWSER
  TextColumn get vehicleId => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('InventoryMovementRow')
class InventoryMovements extends Table {
  TextColumn get id => text()();
  TextColumn get productId => text()();
  TextColumn get sourceLocationId => text().nullable()();
  TextColumn get destinationLocationId => text().nullable()();
  TextColumn get type => text()();
  RealColumn get quantity => real()();
  TextColumn get referenceId => text().nullable()();
  TextColumn get referenceType => text().nullable()();
  DateTimeColumn get movementDate => dateTime()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('StockAdjustmentRow')
class StockAdjustments extends Table {
  TextColumn get id => text()();
  TextColumn get storageLocationId => text()();
  TextColumn get productId => text()();
  TextColumn get adjustmentType => text()(); // GAIN, LOSS
  RealColumn get quantity => real()();
  TextColumn get reason => text()();
  DateTimeColumn get adjustmentDate => dateTime()();
  TextColumn get approvedBy => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('DailyStockReconciliationRow')
class DailyStockReconciliations extends Table {
  TextColumn get id => text()();
  TextColumn get storageLocationId => text()();
  DateTimeColumn get reconciliationDate => dateTime()();
  RealColumn get openingStock => real()();
  RealColumn get quantityReceived => real()();
  RealColumn get quantityDispensed => real()();
  RealColumn get bookStock => real()();
  RealColumn get physicalStock => real()();
  RealColumn get variance => real()();
  TextColumn get status => text()(); // DRAFT, SUBMITTED
  TextColumn get performedBy => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
```

---

## Calculations (SQL & DAOs)

### 1. Stock Balance for a Location
To find the current stock of product $P$ in location $L$:
```sql
SELECT 
  (SELECT COALESCE(SUM(quantity), 0.0) FROM inventory_movements WHERE destination_location_id = :locationId AND product_id = :productId)
  -
  (SELECT COALESCE(SUM(quantity), 0.0) FROM inventory_movements WHERE source_location_id = :locationId AND product_id = :productId)
  AS current_stock;
```

### 2. Loading Fuel into Bowser
When loading $Q$ litres of diesel from Main Storage ($M$) to Bowser ($B$):
- Record an `inventory_movements` record:
  - `source_location_id` = $M$
  - `destination_location_id` = $B$
  - `type` = `bowserLoad`
  - `quantity` = $Q$
  - `reference_type` = `VEHICLE_DISPATCH` / `LOAD_ENTRY`

This immediately decrements the Main Terminal stock and increments the Bowser tank stock in one unified record.

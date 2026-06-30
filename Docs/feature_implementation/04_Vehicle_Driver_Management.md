# 04 — Vehicle & Driver Management Design

## Overview
Vehicles (Fuel Bowsers) are mobile fuel storage locations. Drivers operate vehicles and dispense fuel. Tracking vehicle capacity, service records, license details, and assignments is essential for compliance and operations.

---

## Domain Entities

### Vehicle
```dart
class Vehicle {
  final String id;
  final String registrationNumber;    // e.g. MH-12-Q-4532
  final String model;
  final double capacity;              // Total capacity in litres
  final String status;                // ACTIVE, MAINTENANCE, INACTIVE
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

### Driver
```dart
class Driver {
  final String id;
  final String name;
  final String licenseNumber;
  final DateTime licenseExpiry;
  final String phone;
  final String? email;
  final String status;                // ACTIVE, SUSPENDED, INACTIVE
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

### DriverAssignment
```dart
class DriverAssignment {
  final String id;
  final String driverId;
  final String vehicleId;
  final DateTime assignedAt;
  final DateTime? releasedAt;
  final bool isActive;
}
```

### VehicleServiceRecord
```dart
class VehicleServiceRecord {
  final String id;
  final String vehicleId;
  final DateTime serviceDate;
  final String serviceType;           // ROUTINE, REPAIR, TYRE, INSURANCE, ACCIDENT
  final double cost;
  final String details;               // Description of work done
  final String serviceCenter;
  final String? billDocumentId;       // Link to document attachment
}
```

---

## Database Drift Schema Details

```dart
@DataClassName('VehicleRow')
class Vehicles extends Table {
  TextColumn get id => text()();
  TextColumn get registrationNumber => text().unique()();
  TextColumn get model => text()();
  RealColumn get capacity => real()();
  TextColumn get status => text()(); // ACTIVE, MAINTENANCE, INACTIVE
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('DriverRow')
class Drivers extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get licenseNumber => text().unique()();
  DateTimeColumn get licenseExpiry => dateTime()();
  TextColumn get phone => text()();
  TextColumn get email => text().nullable()();
  TextColumn get status => text()(); // ACTIVE, SUSPENDED, INACTIVE
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('DriverAssignmentRow')
class DriverAssignments extends Table {
  TextColumn get id => text()();
  TextColumn get driverId => text()();
  TextColumn get vehicleId => text()();
  DateTimeColumn get assignedAt => dateTime()();
  DateTimeColumn get releasedAt => dateTime().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('VehicleServiceRecordRow')
class VehicleServiceRecords extends Table {
  TextColumn get id => text()();
  TextColumn get vehicleId => text()();
  DateTimeColumn get serviceDate => dateTime()();
  TextColumn get serviceType => text()();
  RealColumn get cost => real()();
  TextColumn get details => text()();
  TextColumn get serviceCenter => text()();
  TextColumn get billDocumentId => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
```

---

## Calculation & Auditing Scope
- **Current Bowser Fuel Level**: Calculated dynamically using `InventoryMovement` queries on the storage location associated with the vehicle.
- **Service Expense Hook**: Saving a `VehicleServiceRecord` automatically triggers an entry in the `expenses` table of category `Vehicle maintenance` or `Repairs` to maintain complete financial records.

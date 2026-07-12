import 'package:drift/drift.dart';
import 'package:step_up_fuels/features/inventory/data/tables/storage_locations_table.dart';
import 'package:step_up_fuels/features/products/data/tables/products_table.dart';

/// Drift table representing a physical inventory movement or stock transfer.
@DataClassName('InventoryMovementRow')
class InventoryMovements extends Table {
  TextColumn get id => text()();
  TextColumn get productId => text().references(Products, #id)();
  TextColumn get sourceLocationId =>
      text().nullable().references(StorageLocations, #id)();
  TextColumn get destinationLocationId =>
      text().nullable().references(StorageLocations, #id)();
  TextColumn get type =>
      text()(); // PURCHASE_IN, BOWSER_LOAD, DELIVERY_OUT, ADJUSTMENT_GAIN, ADJUSTMENT_LOSS, OPENING_STOCK
  RealColumn get quantity => real()(); // Always positive quantity
  TextColumn get referenceId =>
      text().nullable()(); // FK to invoice, purchase, delivery, etc.
  TextColumn get referenceType =>
      text().nullable()(); // INVOICE, PURCHASE, DELIVERY, ADJUSTMENT
  DateTimeColumn get movementDate => dateTime()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get createdBy => text().withDefault(const Constant('system'))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

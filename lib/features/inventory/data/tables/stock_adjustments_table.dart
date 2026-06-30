import 'package:drift/drift.dart';
import 'package:step_up_fuels/features/inventory/data/tables/storage_locations_table.dart';
import 'package:step_up_fuels/features/products/data/tables/products_table.dart';

/// Drift table representing a physical inventory stock adjustment (leakage, gain, loss).
@DataClassName('StockAdjustmentRow')
class StockAdjustments extends Table {
  TextColumn get id => text()();
  TextColumn get storageLocationId => text().references(StorageLocations, #id)();
  TextColumn get productId => text().references(Products, #id)();
  TextColumn get adjustmentType => text()(); // GAIN, LOSS
  RealColumn get quantity => real()();
  TextColumn get reason => text()(); // e.g. Temperature shrinkage, Leakage, Physical dip rod check
  DateTimeColumn get adjustmentDate => dateTime()();
  TextColumn get approvedBy => text().withDefault(const Constant('system'))();

  // Audits
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

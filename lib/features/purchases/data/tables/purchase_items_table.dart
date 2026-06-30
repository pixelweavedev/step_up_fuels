import 'package:drift/drift.dart';
import 'package:step_up_fuels/features/products/data/tables/products_table.dart';
import 'package:step_up_fuels/features/purchases/data/tables/purchases_table.dart';

/// Drift table representing a line item in a Purchase.
@DataClassName('FuelPurchaseItemRow')
class FuelPurchaseItems extends Table {
  TextColumn get id => text()();
  TextColumn get purchaseId => text().references(FuelPurchases, #id)();
  TextColumn get productId => text().references(Products, #id)();
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

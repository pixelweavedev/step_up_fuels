import 'package:drift/drift.dart';
import 'package:step_up_fuels/features/inventory/data/tables/storage_locations_table.dart';

/// Drift table representing a daily stock reconciliation record for a storage location.
@DataClassName('DailyStockReconciliationRow')
class DailyStockReconciliations extends Table {
  TextColumn get id => text()();
  TextColumn get storageLocationId =>
      text().references(StorageLocations, #id)();
  DateTimeColumn get reconciliationDate => dateTime()();
  RealColumn get openingStock => real()();
  RealColumn get quantityReceived => real()(); // Transfers in
  RealColumn get quantityDispensed => real()(); // Deliveries / transfers out
  RealColumn get bookStock => real()(); // opening + received - dispensed
  RealColumn get physicalStock => real()(); // Dip rod check / flow meter
  RealColumn get variance => real()(); // physical - book
  TextColumn get status => text()(); // DRAFT, SUBMITTED
  TextColumn get performedBy => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

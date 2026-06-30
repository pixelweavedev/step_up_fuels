import 'package:drift/drift.dart';
import 'package:step_up_fuels/features/drivers/data/tables/drivers_table.dart';
import 'package:step_up_fuels/features/vehicles/data/tables/vehicles_table.dart';

/// Drift table representing a Driver Assignment to a specific Bowser.
@DataClassName('DriverAssignmentRow')
class DriverAssignments extends Table {
  TextColumn get id => text()();
  TextColumn get driverId => text().references(Drivers, #id)();
  TextColumn get vehicleId => text().references(Vehicles, #id)();
  DateTimeColumn get assignedAt => dateTime()();
  DateTimeColumn get releasedAt => dateTime().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

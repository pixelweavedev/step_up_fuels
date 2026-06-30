import 'package:drift/drift.dart';
import 'package:step_up_fuels/features/drivers/data/tables/drivers_table.dart';
import 'package:step_up_fuels/features/vehicles/data/tables/vehicles_table.dart';

/// Drift table representing a general business Expense.
@DataClassName('ExpenseRow')
class Expenses extends Table {
  TextColumn get id => text()();
  TextColumn get expenseNumber => text().unique()(); // e.g. EXP/2026-27/001
  TextColumn get category => text()(); // DRIVER_SALARY, VEHICLE_MAINTENANCE, REPAIRS, INSURANCE, ROAD_TAX, FASTAG, TOLL_CHARGES, OFFICE_EXPENSES, MISCELLANEOUS
  RealColumn get amount => real()();
  DateTimeColumn get expenseDate => dateTime()();
  TextColumn get paymentMode => text()(); // CASH, UPI, BANK_TRANSFER
  TextColumn get paymentReference => text().nullable()();
  TextColumn get vehicleId => text().nullable().references(Vehicles, #id)(); // Link to a bowser
  TextColumn get driverId => text().nullable().references(Drivers, #id)(); // Link to a driver
  TextColumn get billDocumentId => text().nullable()(); // Link to attachments
  TextColumn get notes => text().nullable()();

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

import 'package:drift/drift.dart';
import 'package:step_up_fuels/features/customers/data/tables/customers_table.dart';

/// Drift table representing notes/special instructions log history for customers.
@DataClassName('CustomerNoteRow')
class CustomerNotes extends Table {
  TextColumn get id => text()();
  TextColumn get customerId => text().references(Customers, #id)();
  TextColumn get notes => text()();

  // Audits
  TextColumn get createdBy => text().withDefault(const Constant('system'))();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get updatedBy => text().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get tenantId => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

import 'package:drift/drift.dart';
import 'package:step_up_fuels/features/customers/data/tables/customers_table.dart';

/// Drift table representing a customer's contact person.
@DataClassName('CustomerContactRow')
class CustomerContacts extends Table {
  TextColumn get id => text()();
  TextColumn get customerId => text().references(Customers, #id)();
  TextColumn get name => text()();
  TextColumn get designation => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get whatsapp => text().nullable()();
  BoolColumn get isPrimary => boolean().withDefault(const Constant(false))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

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

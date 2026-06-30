import 'package:drift/drift.dart';

/// Drift table representing user credentials and role.
@DataClassName('UserRow')
class Users extends Table {
  TextColumn get id => text()();
  TextColumn get username => text().unique()();
  TextColumn get email => text().unique()();
  TextColumn get phone => text().nullable()();
  TextColumn get role => text()(); // ADMIN, ACCOUNTANT, OPERATOR, DRIVER
  TextColumn get pinHash => text().nullable()();
  TextColumn get passwordHash => text().nullable()();
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

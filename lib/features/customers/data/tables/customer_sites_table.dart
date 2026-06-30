import 'package:drift/drift.dart';
import 'package:step_up_fuels/features/customers/data/tables/customers_table.dart';

/// Drift table representing a customer's delivery site.
@DataClassName('CustomerSiteRow')
class CustomerSites extends Table {
  TextColumn get id => text()();
  TextColumn get customerId => text().references(Customers, #id)();
  TextColumn get name => text()();
  TextColumn get addressLine1 => text().nullable()();
  TextColumn get addressLine2 => text().nullable()();
  TextColumn get city => text().nullable()();
  TextColumn get state => text().nullable()();
  TextColumn get stateCode => text().nullable()();
  TextColumn get pincode => text().nullable()();
  TextColumn get country => text().nullable()();

  // GPS Coordinates
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();

  // Site Contacts
  TextColumn get contactPerson => text().nullable()();
  TextColumn get contactNumber => text().nullable()();

  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
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

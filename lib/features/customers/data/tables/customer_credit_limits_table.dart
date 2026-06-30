import 'package:drift/drift.dart';
import 'package:step_up_fuels/features/customers/data/tables/customers_table.dart';

/// Drift table representing historical changes in customer credit limits.
@DataClassName('CustomerCreditLimitRow')
class CustomerCreditLimits extends Table {
  TextColumn get id => text()();
  TextColumn get customerId => text().references(Customers, #id)();
  RealColumn get creditLimit => real()();
  DateTimeColumn get effectiveFrom => dateTime()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get createdBy => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

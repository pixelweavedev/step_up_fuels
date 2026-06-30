import 'package:drift/drift.dart';

/// Drift table representing a Ledger Chart of Accounts.
@DataClassName('LedgerAccountRow')
class LedgerAccounts extends Table {
  TextColumn get id => text()();
  TextColumn get accountCode => text().unique()(); // e.g. ACT-1001
  TextColumn get name => text()(); // e.g. Tata Motors Account
  TextColumn get accountType => text()(); // CUSTOMER, SUPPLIER, CASH, BANK, SALES, EXPENSE, TAX
  TextColumn get referenceId => text().nullable()(); // FK to Customer/Supplier
  TextColumn get referenceType => text().nullable()(); // CUSTOMER, SUPPLIER
  BoolColumn get isSystem => boolean().withDefault(const Constant(false))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

import 'package:drift/drift.dart';
import 'package:step_up_fuels/features/ledger/data/tables/ledger_accounts_table.dart';

/// Drift table representing a double-entry ledger debit or credit entry.
@DataClassName('LedgerEntryRow')
class LedgerEntries extends Table {
  TextColumn get id => text()();
  TextColumn get ledgerAccountId => text().references(LedgerAccounts, #id)();
  DateTimeColumn get entryDate => dateTime()();
  TextColumn get description => text()();
  RealColumn get debitAmount => real().withDefault(const Constant(0.0))();
  RealColumn get creditAmount => real().withDefault(const Constant(0.0))();
  TextColumn get referenceId => text().nullable()(); // FK to invoice, payment, purchase, etc.
  TextColumn get referenceType => text().nullable()(); // INVOICE, PAYMENT, PURCHASE, EXPENSE
  RealColumn get runningBalance => real().withDefault(const Constant(0.0))();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get createdBy => text().withDefault(const Constant('system'))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

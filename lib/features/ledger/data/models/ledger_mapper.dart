import 'package:drift/drift.dart';
import 'package:step_up_fuels/app/database/app_database.dart';
import 'package:step_up_fuels/features/ledger/domain/entities/ledger_account.dart';
import 'package:step_up_fuels/features/ledger/domain/entities/ledger_entry.dart';

extension LedgerAccountRowMapper on LedgerAccountRow {
  LedgerAccount toDomain() {
    return LedgerAccount(
      id: id,
      accountCode: accountCode,
      name: name,
      accountType: accountType,
      referenceId: referenceId,
      referenceType: referenceType,
      isSystem: isSystem,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

extension LedgerAccountDomainMapper on LedgerAccount {
  LedgerAccountsCompanion toCompanion() {
    return LedgerAccountsCompanion(
      id: Value(id),
      accountCode: Value(accountCode),
      name: Value(name),
      accountType: Value(accountType),
      referenceId: Value(referenceId),
      referenceType: Value(referenceType),
      isSystem: Value(isSystem),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }
}

extension LedgerEntryRowMapper on LedgerEntryRow {
  LedgerEntry toDomain() {
    return LedgerEntry(
      id: id,
      ledgerAccountId: ledgerAccountId,
      entryDate: entryDate,
      description: description,
      debitAmount: debitAmount,
      creditAmount: creditAmount,
      referenceId: referenceId,
      referenceType: referenceType,
      runningBalance: runningBalance,
      createdAt: createdAt,
      createdBy: createdBy,
    );
  }
}

extension LedgerEntryDomainMapper on LedgerEntry {
  LedgerEntriesCompanion toCompanion() {
    return LedgerEntriesCompanion(
      id: Value(id),
      ledgerAccountId: Value(ledgerAccountId),
      entryDate: Value(entryDate),
      description: Value(description),
      debitAmount: Value(debitAmount),
      creditAmount: Value(creditAmount),
      referenceId: Value(referenceId),
      referenceType: Value(referenceType),
      runningBalance: Value(runningBalance),
      createdAt: Value(createdAt),
      createdBy: Value(createdBy),
    );
  }
}

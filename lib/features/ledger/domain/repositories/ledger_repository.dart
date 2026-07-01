import 'package:step_up_fuels/core/result/result.dart';
import 'package:step_up_fuels/features/ledger/domain/entities/ledger_account.dart';
import 'package:step_up_fuels/features/ledger/domain/entities/ledger_entry.dart';

/// Repository interface for double-entry Ledger bookkeeping.
abstract class LedgerRepository {
  /// Retrieves all ledger accounts.
  Future<Result<List<LedgerAccount>>> getAccounts({
    String? typeFilter,
    String? searchQuery,
  });

  /// Retrieves a specific ledger account by ID.
  Future<Result<LedgerAccount>> getAccountById(String id);

  /// Retrieves a specific ledger account by account code (e.g. system accounts).
  Future<Result<LedgerAccount>> getAccountByCode(String accountCode);

  /// Retrieves or lazily registers a ledger account for a Customer.
  Future<Result<LedgerAccount>> getOrCreateCustomerAccount(
    String customerId,
    String customerName,
    String customerCode,
  );

  /// Retrieves or lazily registers a ledger account for a Supplier.
  Future<Result<LedgerAccount>> getOrCreateSupplierAccount(
    String supplierId,
    String supplierName,
    String supplierCode,
  );

  /// Retrieves or lazily registers a system-level ledger account.
  Future<Result<LedgerAccount>> getOrCreateSystemAccount(
    String accountCode,
    String name,
    String accountType,
  );

  /// Retrieves ledger entry statement rows for a given account.
  Future<Result<List<LedgerEntry>>> getEntries(
    String accountId, {
    DateTime? fromDate,
    DateTime? toDate,
  });

  /// Records a new ledger entry.
  Future<Result<void>> postEntry({
    required String accountId,
    required DateTime entryDate,
    required String description,
    required double debit,
    required double credit,
    String? referenceId,
    String? referenceType,
    required String createdBy,
  });
}

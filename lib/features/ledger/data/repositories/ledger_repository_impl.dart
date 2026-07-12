import 'package:drift/drift.dart';
import 'package:step_up_fuels/app/database/app_database.dart';
import 'package:step_up_fuels/core/errors/failure.dart';
import 'package:step_up_fuels/core/result/result.dart';
import 'package:step_up_fuels/features/ledger/data/daos/ledger_dao.dart';
import 'package:step_up_fuels/features/ledger/data/models/ledger_mapper.dart';
import 'package:step_up_fuels/features/ledger/domain/entities/ledger_account.dart';
import 'package:step_up_fuels/features/ledger/domain/entities/ledger_entry.dart';
import 'package:step_up_fuels/features/ledger/domain/repositories/ledger_repository.dart';
import 'package:uuid/uuid.dart';

class LedgerRepositoryImpl implements LedgerRepository {
  LedgerRepositoryImpl(this._dao);
  final LedgerDao _dao;
  final _uuid = const Uuid();

  @override
  Future<Result<List<LedgerAccount>>> getAccounts({
    String? typeFilter,
    String? searchQuery,
  }) async {
    try {
      final rows = await _dao.getAllAccounts(
        typeFilter: typeFilter,
        searchQuery: searchQuery,
      );
      return Result.success(rows.map((r) => r.toDomain()).toList());
    } catch (e, st) {
      return Result.failure(
        DatabaseFailure(message: e.toString(), stackTrace: st),
      );
    }
  }

  @override
  Future<Result<LedgerAccount>> getAccountById(String id) async {
    try {
      final row = await _dao.getAccountById(id);
      if (row == null) {
        return const Result.failure(
          NotFoundFailure(message: 'Ledger account not found'),
        );
      }
      return Result.success(row.toDomain());
    } catch (e, st) {
      return Result.failure(
        DatabaseFailure(message: e.toString(), stackTrace: st),
      );
    }
  }

  @override
  Future<Result<LedgerAccount>> getAccountByCode(String accountCode) async {
    try {
      final row = await _dao.getAccountByCode(accountCode);
      if (row == null) {
        return const Result.failure(
          NotFoundFailure(message: 'Ledger account not found'),
        );
      }
      return Result.success(row.toDomain());
    } catch (e, st) {
      return Result.failure(
        DatabaseFailure(message: e.toString(), stackTrace: st),
      );
    }
  }

  @override
  Future<Result<LedgerAccount>> getOrCreateCustomerAccount(
    String customerId,
    String customerName,
    String customerCode,
  ) async {
    try {
      final existing = await _dao.getAccountByReference(customerId, 'CUSTOMER');
      if (existing != null) {
        return Result.success(existing.toDomain());
      }

      final accountId = _uuid.v4();
      final companion = LedgerAccountsCompanion(
        id: Value(accountId),
        accountCode: Value('ACT-CUST-$customerCode'),
        name: Value('$customerName Account'),
        accountType: const Value('CUSTOMER'),
        referenceId: Value(customerId),
        referenceType: const Value('CUSTOMER'),
        isSystem: const Value(false),
        isActive: const Value(true),
        createdAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      );

      await _dao.saveAccount(companion);
      final created = await _dao.getAccountById(accountId);
      return Result.success(created!.toDomain());
    } catch (e, st) {
      return Result.failure(
        DatabaseFailure(message: e.toString(), stackTrace: st),
      );
    }
  }

  @override
  Future<Result<LedgerAccount>> getOrCreateSupplierAccount(
    String supplierId,
    String supplierName,
    String supplierCode,
  ) async {
    try {
      final existing = await _dao.getAccountByReference(supplierId, 'SUPPLIER');
      if (existing != null) {
        return Result.success(existing.toDomain());
      }

      final accountId = _uuid.v4();
      final companion = LedgerAccountsCompanion(
        id: Value(accountId),
        accountCode: Value('ACT-SUP-$supplierCode'),
        name: Value('$supplierName Account'),
        accountType: const Value('SUPPLIER'),
        referenceId: Value(supplierId),
        referenceType: const Value('SUPPLIER'),
        isSystem: const Value(false),
        isActive: const Value(true),
        createdAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      );

      await _dao.saveAccount(companion);
      final created = await _dao.getAccountById(accountId);
      return Result.success(created!.toDomain());
    } catch (e, st) {
      return Result.failure(
        DatabaseFailure(message: e.toString(), stackTrace: st),
      );
    }
  }

  @override
  Future<Result<LedgerAccount>> getOrCreateSystemAccount(
    String accountCode,
    String name,
    String accountType,
  ) async {
    try {
      final existing = await _dao.getAccountByCode(accountCode);
      if (existing != null) {
        return Result.success(existing.toDomain());
      }

      final accountId = _uuid.v4();
      final companion = LedgerAccountsCompanion(
        id: Value(accountId),
        accountCode: Value(accountCode),
        name: Value(name),
        accountType: Value(accountType),
        isSystem: const Value(true),
        isActive: const Value(true),
        createdAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      );

      await _dao.saveAccount(companion);
      final created = await _dao.getAccountById(accountId);
      return Result.success(created!.toDomain());
    } catch (e, st) {
      return Result.failure(
        DatabaseFailure(message: e.toString(), stackTrace: st),
      );
    }
  }

  @override
  Future<Result<List<LedgerEntry>>> getEntries(
    String accountId, {
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      final rows = await _dao.getEntriesForAccount(
        accountId,
        fromDate: fromDate,
        toDate: toDate,
      );
      return Result.success(rows.map((r) => r.toDomain()).toList());
    } catch (e, st) {
      return Result.failure(
        DatabaseFailure(message: e.toString(), stackTrace: st),
      );
    }
  }

  @override
  Future<Result<void>> postEntry({
    required String accountId,
    required DateTime entryDate,
    required String description,
    required double debit,
    required double credit,
    String? referenceId,
    String? referenceType,
    required String createdBy,
  }) async {
    try {
      final companion = LedgerEntriesCompanion(
        id: Value(_uuid.v4()),
        ledgerAccountId: Value(accountId),
        entryDate: Value(entryDate),
        description: Value(description),
        debitAmount: Value(debit),
        creditAmount: Value(credit),
        referenceId: Value(referenceId),
        referenceType: Value(referenceType),
        createdAt: Value(DateTime.now()),
        createdBy: Value(createdBy),
      );
      await _dao.saveEntry(companion);
      return const Result.success(null);
    } catch (e, st) {
      return Result.failure(
        DatabaseFailure(message: e.toString(), stackTrace: st),
      );
    }
  }
}

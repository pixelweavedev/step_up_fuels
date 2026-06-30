import 'package:step_up_fuels/app/database/app_database.dart';
import 'package:step_up_fuels/core/errors/failure.dart';
import 'package:step_up_fuels/core/result/result.dart';
import 'package:step_up_fuels/features/customers/data/daos/customers_dao.dart';
import 'package:step_up_fuels/features/customers/data/models/customer_mapper.dart';
import 'package:step_up_fuels/features/customers/domain/entities/customer.dart';
import 'package:step_up_fuels/features/customers/domain/entities/customer_contact.dart';
import 'package:step_up_fuels/features/customers/domain/entities/customer_document.dart';
import 'package:step_up_fuels/features/customers/domain/entities/customer_note.dart';
import 'package:step_up_fuels/features/customers/domain/entities/customer_site.dart';
import 'package:step_up_fuels/features/customers/domain/repositories/customer_repository.dart';
import 'package:uuid/uuid.dart';

/// Concrete implementation of the [CustomerRepository] interface using Drift.
class CustomerRepositoryImpl implements CustomerRepository {
  CustomerRepositoryImpl(this._dao);
  final CustomersDao _dao;
  final _uuid = const Uuid();

  @override
  Future<Result<List<Customer>>> getAll({bool includeDeleted = false}) async {
    try {
      final rows = await _dao.getAllCustomers(includeDeleted: includeDeleted);
      final domainList = rows.map((row) => row.toDomain()).toList();
      return Result.success(domainList);
    } catch (e, st) {
      return Result.failure(
        DatabaseFailure(message: e.toString(), stackTrace: st),
      );
    }
  }

  @override
  Future<Result<List<Customer>>> search(String query) async {
    try {
      final rows = await _dao.searchCustomers(query);
      final domainList = rows.map((row) => row.toDomain()).toList();
      return Result.success(domainList);
    } catch (e, st) {
      return Result.failure(
        DatabaseFailure(message: e.toString(), stackTrace: st),
      );
    }
  }

  @override
  Future<Result<Customer>> getById(String id) async {
    try {
      final row = await _dao.getCustomerById(id);
      if (row == null) {
        return const Result.failure(
          NotFoundFailure(message: 'Customer not found'),
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
  Future<Result<void>> save(Customer customer) async {
    try {
      final existing = await _dao.getCustomerById(customer.id);
      final isCreditLimitChanged =
          existing == null || existing.creditLimit != customer.creditLimit;

      await _dao.saveCustomer(customer.toCompanion());

      if (isCreditLimitChanged) {
        final historyEntry = CustomerCreditLimitRow(
          id: _uuid.v4(),
          customerId: customer.id,
          creditLimit: customer.creditLimit,
          effectiveFrom: DateTime.now(),
          notes: existing == null
              ? 'Initial credit limit registration'
              : 'Credit limit updated',
          createdAt: DateTime.now(),
          createdBy: customer.updatedBy,
        );
        await _dao.saveCreditLimitHistory(historyEntry);
      }
      return const Result.success(null);
    } catch (e, st) {
      return Result.failure(
        DatabaseFailure(message: e.toString(), stackTrace: st),
      );
    }
  }

  @override
  Future<Result<void>> softDelete(String id) async {
    try {
      await _dao.softDeleteCustomer(id);
      return const Result.success(null);
    } catch (e, st) {
      return Result.failure(
        DatabaseFailure(message: e.toString(), stackTrace: st),
      );
    }
  }

  @override
  Future<Result<void>> restore(String id) async {
    try {
      await _dao.restoreCustomer(id);
      return const Result.success(null);
    } catch (e, st) {
      return Result.failure(
        DatabaseFailure(message: e.toString(), stackTrace: st),
      );
    }
  }

  // ── Delivery Sites ──────────────────────────────────────────────────────────

  @override
  Future<Result<List<CustomerSite>>> getSitesForCustomer(
    String customerId,
  ) async {
    try {
      final rows = await _dao.getSitesForCustomer(customerId);
      final domainList = rows.map((row) => row.toDomain()).toList();
      return Result.success(domainList);
    } catch (e, st) {
      return Result.failure(
        DatabaseFailure(message: e.toString(), stackTrace: st),
      );
    }
  }

  @override
  Future<Result<void>> saveSite(CustomerSite site) async {
    try {
      await _dao.saveSite(site.toCompanion());
      return const Result.success(null);
    } catch (e, st) {
      return Result.failure(
        DatabaseFailure(message: e.toString(), stackTrace: st),
      );
    }
  }

  @override
  Future<Result<void>> deleteSite(String id) async {
    try {
      await _dao.deleteSite(id);
      return const Result.success(null);
    } catch (e, st) {
      return Result.failure(
        DatabaseFailure(message: e.toString(), stackTrace: st),
      );
    }
  }

  // ── Contact Persons ─────────────────────────────────────────────────────────

  @override
  Future<Result<List<CustomerContact>>> getContactsForCustomer(
    String customerId,
  ) async {
    try {
      final rows = await _dao.getContactsForCustomer(customerId);
      final domainList = rows.map((row) => row.toDomain()).toList();
      return Result.success(domainList);
    } catch (e, st) {
      return Result.failure(
        DatabaseFailure(message: e.toString(), stackTrace: st),
      );
    }
  }

  @override
  Future<Result<void>> saveContact(CustomerContact contact) async {
    try {
      await _dao.saveContact(contact.toCompanion());
      return const Result.success(null);
    } catch (e, st) {
      return Result.failure(
        DatabaseFailure(message: e.toString(), stackTrace: st),
      );
    }
  }

  @override
  Future<Result<void>> deleteContact(String id) async {
    try {
      await _dao.deleteContact(id);
      return const Result.success(null);
    } catch (e, st) {
      return Result.failure(
        DatabaseFailure(message: e.toString(), stackTrace: st),
      );
    }
  }

  // ── Documents ───────────────────────────────────────────────────────────────

  @override
  Future<Result<List<CustomerDocument>>> getDocumentsForCustomer(
    String customerId,
  ) async {
    try {
      final rows = await _dao.getDocumentsForCustomer(customerId);
      final domainList = rows.map((row) => row.toDomain()).toList();
      return Result.success(domainList);
    } catch (e, st) {
      return Result.failure(
        DatabaseFailure(message: e.toString(), stackTrace: st),
      );
    }
  }

  @override
  Future<Result<void>> saveDocument(CustomerDocument document) async {
    try {
      await _dao.saveDocument(document.toCompanion());
      return const Result.success(null);
    } catch (e, st) {
      return Result.failure(
        DatabaseFailure(message: e.toString(), stackTrace: st),
      );
    }
  }

  @override
  Future<Result<void>> deleteDocument(String id) async {
    try {
      await _dao.deleteDocument(id);
      return const Result.success(null);
    } catch (e, st) {
      return Result.failure(
        DatabaseFailure(message: e.toString(), stackTrace: st),
      );
    }
  }

  // ── Notes Logs ─────────────────────────────────────────────────────────────

  @override
  Future<Result<List<CustomerNote>>> getNotesForCustomer(
    String customerId,
  ) async {
    try {
      final rows = await _dao.getNotesForCustomer(customerId);
      final domainList = rows.map((row) => row.toDomain()).toList();
      return Result.success(domainList);
    } catch (e, st) {
      return Result.failure(
        DatabaseFailure(message: e.toString(), stackTrace: st),
      );
    }
  }

  @override
  Future<Result<void>> saveNote(CustomerNote note) async {
    try {
      await _dao.saveNote(note.toCompanion());
      return const Result.success(null);
    } catch (e, st) {
      return Result.failure(
        DatabaseFailure(message: e.toString(), stackTrace: st),
      );
    }
  }

  @override
  Future<Result<void>> deleteNote(String id) async {
    try {
      await _dao.deleteNote(id);
      return const Result.success(null);
    } catch (e, st) {
      return Result.failure(
        DatabaseFailure(message: e.toString(), stackTrace: st),
      );
    }
  }
}

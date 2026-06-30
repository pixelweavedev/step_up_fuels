import 'package:drift/drift.dart';
import 'package:step_up_fuels/app/database/app_database.dart';
import 'package:step_up_fuels/features/customers/data/tables/customer_contacts_table.dart';
import 'package:step_up_fuels/features/customers/data/tables/customer_credit_limits_table.dart';
import 'package:step_up_fuels/features/customers/data/tables/customer_documents_table.dart';
import 'package:step_up_fuels/features/customers/data/tables/customer_notes_table.dart';
import 'package:step_up_fuels/features/customers/data/tables/customer_sites_table.dart';
import 'package:step_up_fuels/features/customers/data/tables/customers_table.dart';

part 'customers_dao.g.dart';

/// Database accessor for Customer features.
@DriftAccessor(
  tables: [
    Customers,
    CustomerSites,
    CustomerContacts,
    CustomerCreditLimits,
    CustomerDocuments,
    CustomerNotes,
  ],
)
class CustomersDao extends DatabaseAccessor<AppDatabase>
    with _$CustomersDaoMixin {
  CustomersDao(super.db);

  /// Fetch all customers, optionally including soft deleted ones.
  Future<List<CustomerRow>> getAllCustomers({
    bool includeDeleted = false,
  }) async {
    if (includeDeleted) {
      return select(customers).get();
    } else {
      return (select(customers)..where((t) => t.deletedAt.isNull())).get();
    }
  }

  /// Search active customers by name, customer code, or trade name.
  Future<List<CustomerRow>> searchCustomers(String query) async {
    final lowercaseQuery = '%${query.toLowerCase()}%';
    return (select(customers)..where(
          (t) =>
              t.deletedAt.isNull() &
              (t.name.lower().like(lowercaseQuery) |
                  t.customerCode.lower().like(lowercaseQuery) |
                  t.tradeName.lower().like(lowercaseQuery)),
        ))
        .get();
  }

  /// Fetch a customer by its ID.
  Future<CustomerRow?> getCustomerById(String id) async {
    return (select(customers)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Inserts or updates a customer.
  Future<void> saveCustomer(CustomersCompanion companion) async {
    await into(customers).insertOnConflictUpdate(companion);
  }

  /// Soft deletes a customer by marking [deletedAt] field.
  Future<void> softDeleteCustomer(String id) async {
    await (update(customers)..where((t) => t.id.equals(id))).write(
      CustomersCompanion(deletedAt: Value(DateTime.now())),
    );
  }

  /// Restores a soft-deleted customer by clearing [deletedAt] field.
  Future<void> restoreCustomer(String id) async {
    await (update(customers)..where((t) => t.id.equals(id))).write(
      const CustomersCompanion(deletedAt: Value(null)),
    );
  }

  // ── Delivery Sites ──────────────────────────────────────────────────────────

  /// Get all active delivery sites for a customer.
  Future<List<CustomerSiteRow>> getSitesForCustomer(String customerId) async {
    return (select(
          customerSites,
        )..where((t) => t.customerId.equals(customerId) & t.deletedAt.isNull()))
        .get();
  }

  /// Inserts or updates a delivery site.
  Future<void> saveSite(CustomerSitesCompanion site) async {
    final isDefaultVal = site.isDefault.value;
    if (isDefaultVal == true) {
      final custId = site.customerId.value;
      await (update(customerSites)..where((t) => t.customerId.equals(custId)))
          .write(const CustomerSitesCompanion(isDefault: Value(false)));
    }
    await into(customerSites).insertOnConflictUpdate(site);
  }

  /// Soft deletes a delivery site.
  Future<void> deleteSite(String id) async {
    await (update(customerSites)..where((t) => t.id.equals(id))).write(
      CustomerSitesCompanion(deletedAt: Value(DateTime.now())),
    );
  }

  // ── Contact Persons ─────────────────────────────────────────────────────────

  /// Get all active contacts for a customer.
  Future<List<CustomerContactRow>> getContactsForCustomer(
    String customerId,
  ) async {
    return (select(
          customerContacts,
        )..where((t) => t.customerId.equals(customerId) & t.deletedAt.isNull()))
        .get();
  }

  /// Inserts or updates a contact person.
  Future<void> saveContact(CustomerContactsCompanion contact) async {
    final isPrimaryVal = contact.isPrimary.value;
    if (isPrimaryVal == true) {
      final custId = contact.customerId.value;
      await (update(customerContacts)
            ..where((t) => t.customerId.equals(custId)))
          .write(const CustomerContactsCompanion(isPrimary: Value(false)));
    }
    await into(customerContacts).insertOnConflictUpdate(contact);
  }

  /// Soft deletes a contact person.
  Future<void> deleteContact(String id) async {
    await (update(customerContacts)..where((t) => t.id.equals(id))).write(
      CustomerContactsCompanion(deletedAt: Value(DateTime.now())),
    );
  }

  // ── Credit Limit History ────────────────────────────────────────────────────

  /// Records an entry in credit limit history.
  Future<void> saveCreditLimitHistory(CustomerCreditLimitRow limit) async {
    await into(customerCreditLimits).insertOnConflictUpdate(limit);
  }

  /// Fetches history of credit limit changes for a customer.
  Future<List<CustomerCreditLimitRow>> getCreditLimitHistory(
    String customerId,
  ) async {
    return (select(customerCreditLimits)
          ..where((t) => t.customerId.equals(customerId))
          ..orderBy([(t) => OrderingTerm.desc(t.effectiveFrom)]))
        .get();
  }

  // ── Documents ───────────────────────────────────────────────────────────────

  /// Get all active documents for a customer.
  Future<List<CustomerDocumentRow>> getDocumentsForCustomer(
    String customerId,
  ) async {
    return (select(
          customerDocuments,
        )..where((t) => t.customerId.equals(customerId) & t.deletedAt.isNull()))
        .get();
  }

  /// Inserts or updates a customer document.
  Future<void> saveDocument(CustomerDocumentsCompanion doc) async {
    await into(customerDocuments).insertOnConflictUpdate(doc);
  }

  /// Soft deletes a customer document.
  Future<void> deleteDocument(String id) async {
    await (update(customerDocuments)..where((t) => t.id.equals(id))).write(
      CustomerDocumentsCompanion(deletedAt: Value(DateTime.now())),
    );
  }

  // ── Notes ──────────────────────────────────────────────────────────────────

  /// Get all active notes for a customer.
  Future<List<CustomerNoteRow>> getNotesForCustomer(String customerId) async {
    return (select(customerNotes)
          ..where((t) => t.customerId.equals(customerId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  /// Inserts or updates a customer note log.
  Future<void> saveNote(CustomerNotesCompanion note) async {
    await into(customerNotes).insertOnConflictUpdate(note);
  }

  /// Soft deletes a customer note log.
  Future<void> deleteNote(String id) async {
    await (update(customerNotes)..where((t) => t.id.equals(id))).write(
      CustomerNotesCompanion(deletedAt: Value(DateTime.now())),
    );
  }
}

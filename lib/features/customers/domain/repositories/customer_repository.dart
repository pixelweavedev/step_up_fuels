import 'package:step_up_fuels/core/result/result.dart';
import 'package:step_up_fuels/features/customers/domain/entities/customer.dart';
import 'package:step_up_fuels/features/customers/domain/entities/customer_contact.dart';
import 'package:step_up_fuels/features/customers/domain/entities/customer_document.dart';
import 'package:step_up_fuels/features/customers/domain/entities/customer_note.dart';
import 'package:step_up_fuels/features/customers/domain/entities/customer_site.dart';

/// Abstract repository interface for Customer feature.
abstract class CustomerRepository {
  Future<Result<List<Customer>>> getAll({bool includeDeleted = false});
  Future<Result<List<Customer>>> search(String query);
  Future<Result<Customer>> getById(String id);
  Future<Result<void>> save(Customer customer);
  Future<Result<void>> softDelete(String id);
  Future<Result<void>> restore(String id);

  Future<Result<List<CustomerSite>>> getSitesForCustomer(String customerId);
  Future<Result<void>> saveSite(CustomerSite site);
  Future<Result<void>> deleteSite(String id);

  Future<Result<List<CustomerContact>>> getContactsForCustomer(
    String customerId,
  );
  Future<Result<void>> saveContact(CustomerContact contact);
  Future<Result<void>> deleteContact(String id);

  // Documents
  Future<Result<List<CustomerDocument>>> getDocumentsForCustomer(
    String customerId,
  );
  Future<Result<void>> saveDocument(CustomerDocument document);
  Future<Result<void>> deleteDocument(String id);

  // Notes Logs
  Future<Result<List<CustomerNote>>> getNotesForCustomer(String customerId);
  Future<Result<void>> saveNote(CustomerNote note);
  Future<Result<void>> deleteNote(String id);
}

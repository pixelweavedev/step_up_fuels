import 'package:step_up_fuels/core/result/result.dart';
import 'package:step_up_fuels/features/invoices/domain/entities/invoice.dart';
import 'package:step_up_fuels/features/invoices/domain/repositories/invoice_repository.dart';

class GetInvoicesUseCase {
  GetInvoicesUseCase(this._repo);
  final InvoiceRepository _repo;

  Future<Result<List<Invoice>>> call({
    InvoiceStatus? status,
    String? customerId,
    String? searchQuery,
    DateTime? fromDate,
    DateTime? toDate,
    bool includeDeleted = false,
  }) {
    return _repo.getAll(
      status: status,
      customerId: customerId,
      searchQuery: searchQuery,
      fromDate: fromDate,
      toDate: toDate,
      includeDeleted: includeDeleted,
    );
  }
}

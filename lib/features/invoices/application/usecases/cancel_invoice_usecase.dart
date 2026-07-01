import 'package:step_up_fuels/core/result/result.dart';
import 'package:step_up_fuels/features/invoices/domain/repositories/invoice_repository.dart';

/// Cancels a posted invoice with a mandatory reason.
class CancelInvoiceUseCase {
  CancelInvoiceUseCase(this._repo);
  final InvoiceRepository _repo;

  Future<Result<void>> call(String invoiceId, String reason) {
    return _repo.cancel(invoiceId, reason);
  }
}

import 'package:step_up_fuels/core/result/result.dart';
import 'package:step_up_fuels/features/invoices/domain/entities/invoice.dart';
import 'package:step_up_fuels/features/invoices/domain/repositories/invoice_repository.dart';

/// Posts an invoice — transitions status to POSTED and stamps the invoice number.
class PostInvoiceUseCase {
  PostInvoiceUseCase(this._repo);
  final InvoiceRepository _repo;

  Future<Result<Invoice>> call(String invoiceId) {
    return _repo.post(invoiceId);
  }
}

import 'package:step_up_fuels/core/result/result.dart';
import 'package:step_up_fuels/features/invoices/domain/entities/invoice.dart';
import 'package:step_up_fuels/features/invoices/domain/entities/invoice_item.dart';
import 'package:step_up_fuels/features/invoices/domain/repositories/invoice_repository.dart';

class SaveInvoiceUseCase {
  SaveInvoiceUseCase(this._repo);
  final InvoiceRepository _repo;

  Future<Result<void>> call(Invoice invoice, List<InvoiceItem> items) {
    return _repo.save(invoice, items);
  }
}

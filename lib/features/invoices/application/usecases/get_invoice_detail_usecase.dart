import 'package:step_up_fuels/core/result/result.dart';
import 'package:step_up_fuels/features/invoices/domain/entities/invoice.dart';
import 'package:step_up_fuels/features/invoices/domain/entities/invoice_item.dart';
import 'package:step_up_fuels/features/invoices/domain/repositories/invoice_repository.dart';

class GetInvoiceDetailUseCase {
  GetInvoiceDetailUseCase(this._repo);
  final InvoiceRepository _repo;

  Future<Result<({Invoice invoice, List<InvoiceItem> items})>> call(
    String id,
  ) async {
    final invoiceResult = await _repo.getById(id);
    return invoiceResult.when(
      success: (invoice) async {
        final itemsResult = await _repo.getItems(id);
        return itemsResult.when(
          success: (items) => Result.success((invoice: invoice, items: items)),
          failure: Result.failure,
        );
      },
      failure: Result.failure,
    );
  }
}

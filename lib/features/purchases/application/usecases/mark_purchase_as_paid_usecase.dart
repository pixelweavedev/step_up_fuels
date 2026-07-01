import 'package:step_up_fuels/core/result/result.dart';
import 'package:step_up_fuels/features/purchases/domain/repositories/purchase_repository.dart';

class MarkPurchaseAsPaidUseCase {
  MarkPurchaseAsPaidUseCase(this._repository);
  final PurchaseRepository _repository;

  Future<Result<void>> call(
    String purchaseId, {
    required String paymentMode,
    required DateTime paymentDate,
    String? notes,
  }) {
    return _repository.markPurchaseAsPaid(
      purchaseId,
      paymentMode: paymentMode,
      paymentDate: paymentDate,
      notes: notes,
    );
  }
}

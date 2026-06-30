import 'package:step_up_fuels/core/result/result.dart';
import 'package:step_up_fuels/features/customers/domain/repositories/customer_repository.dart';

/// Service to handle customer credit operations in the domain layer.
class CustomerCreditService {
  CustomerCreditService(this._repository);
  final CustomerRepository _repository;

  /// Checks if a customer has exceeded their credit limit after applying [newInvoiceAmount].
  Future<Result<bool>> isWithinCreditLimit({
    required String customerId,
    required double newInvoiceAmount,
  }) async {
    final customerResult = await _repository.getById(customerId);
    return customerResult.when(
      success: (customer) async {
        final outstandingResult = await getOutstanding(customerId);
        return outstandingResult.when(
          success: (outstanding) {
            final isWithin =
                (outstanding + newInvoiceAmount) <= customer.creditLimit;
            return Result.success(isWithin);
          },
          failure: (f) => Result.failure(f),
        );
      },
      failure: (f) => Result.failure(f),
    );
  }

  /// Calculates outstanding balance for a customer.
  ///
  /// In Phase 2, this is mocked to 0.0 because invoice tracking is in Phase 4.
  Future<Result<double>> getOutstanding(String customerId) async {
    // In later phases, this will check outstanding invoices in the DB.
    return const Result.success(0.0);
  }
}

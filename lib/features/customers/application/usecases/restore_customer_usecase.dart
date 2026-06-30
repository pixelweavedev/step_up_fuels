import 'package:step_up_fuels/core/result/result.dart';
import 'package:step_up_fuels/features/customers/domain/repositories/customer_repository.dart';

/// Usecase to handle restoration of a soft-deleted customer.
class RestoreCustomerUseCase {
  RestoreCustomerUseCase(this._repository);
  final CustomerRepository _repository;

  /// Executes the restore action.
  Future<Result<void>> call(String id) async {
    return _repository.restore(id);
  }
}

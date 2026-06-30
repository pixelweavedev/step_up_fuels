import 'package:step_up_fuels/core/result/result.dart';
import 'package:step_up_fuels/features/customers/domain/repositories/customer_repository.dart';

/// Usecase to handle soft deletion of a customer.
class SoftDeleteCustomerUseCase {
  SoftDeleteCustomerUseCase(this._repository);
  final CustomerRepository _repository;

  /// Executes the soft delete action.
  Future<Result<void>> call(String id) async {
    return _repository.softDelete(id);
  }
}

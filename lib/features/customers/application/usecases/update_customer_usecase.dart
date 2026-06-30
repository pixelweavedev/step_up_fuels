import 'package:step_up_fuels/core/result/result.dart';
import 'package:step_up_fuels/features/customers/domain/entities/customer.dart';
import 'package:step_up_fuels/features/customers/domain/repositories/customer_repository.dart';

/// Usecase to handle updates to an existing customer.
class UpdateCustomerUseCase {
  UpdateCustomerUseCase(this._repository);
  final CustomerRepository _repository;

  /// Executes the update.
  Future<Result<void>> call(Customer customer) async {
    return _repository.save(customer);
  }
}

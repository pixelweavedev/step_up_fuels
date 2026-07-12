import 'package:step_up_fuels/core/result/result.dart';
import 'package:step_up_fuels/features/customers/domain/entities/customer.dart';
import 'package:step_up_fuels/features/customers/domain/repositories/customer_repository.dart';

/// Usecase to handle registration of a new customer.
class CreateCustomerUseCase {
  CreateCustomerUseCase(this._repository);
  final CustomerRepository _repository;

  /// Executes the creation of a new customer.
  /// Auto-generates the customer code based on the current database count.
  Future<Result<void>> call(Customer customer) async {
    final listResult = await _repository.getAll(includeDeleted: true);
    return listResult.when(
      success: (list) async {
        final nextNum = list.length + 1;
        final nextCode = 'CUST-${nextNum.toString().padLeft(3, '0')}';
        final toSave = customer.copyWith(customerCode: nextCode);
        return _repository.save(toSave);
      },
      failure: (f) => Result.failure(f),
    );
  }
}

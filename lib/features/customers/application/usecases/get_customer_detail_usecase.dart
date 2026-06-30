import 'package:step_up_fuels/core/result/result.dart';
import 'package:step_up_fuels/features/customers/domain/entities/customer.dart';
import 'package:step_up_fuels/features/customers/domain/repositories/customer_repository.dart';

/// Usecase to retrieve detailed info for a single customer.
class GetCustomerDetailUseCase {
  GetCustomerDetailUseCase(this._repository);
  final CustomerRepository _repository;

  /// Executes the retrieval.
  Future<Result<Customer>> call(String id) async {
    return _repository.getById(id);
  }
}

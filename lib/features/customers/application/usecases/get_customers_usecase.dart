import 'package:step_up_fuels/core/result/result.dart';
import 'package:step_up_fuels/features/customers/domain/entities/customer.dart';
import 'package:step_up_fuels/features/customers/domain/repositories/customer_repository.dart';

/// Usecase to retrieve the customer list.
///
/// Supports query filtering if search text is provided.
class GetCustomersUseCase {
  GetCustomersUseCase(this._repository);
  final CustomerRepository _repository;

  /// Executes the retrieval of customer list.
  Future<Result<List<Customer>>> call({
    String? query,
    bool includeDeleted = false,
  }) async {
    if (query != null && query.trim().isNotEmpty) {
      return _repository.search(query.trim());
    }
    return _repository.getAll(includeDeleted: includeDeleted);
  }
}

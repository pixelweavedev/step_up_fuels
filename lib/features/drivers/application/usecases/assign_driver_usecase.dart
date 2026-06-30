import 'package:step_up_fuels/core/result/result.dart';
import 'package:step_up_fuels/features/drivers/domain/entities/driver_assignment.dart';
import 'package:step_up_fuels/features/drivers/domain/repositories/driver_repository.dart';

class AssignDriverUseCase {
  AssignDriverUseCase(this._repository);
  final DriverRepository _repository;

  Future<Result<void>> call(DriverAssignment assignment) async {
    return _repository.assignDriver(assignment);
  }
}

import 'package:step_up_fuels/core/result/result.dart';
import 'package:step_up_fuels/features/drivers/domain/entities/driver_assignment.dart';
import 'package:step_up_fuels/features/drivers/domain/repositories/driver_repository.dart';

class GetAssignmentsUseCase {
  GetAssignmentsUseCase(this._repository);
  final DriverRepository _repository;

  Future<Result<List<DriverAssignment>>> call({
    String? driverId,
    String? vehicleId,
  }) async {
    return _repository.getAssignments(driverId: driverId, vehicleId: vehicleId);
  }
}

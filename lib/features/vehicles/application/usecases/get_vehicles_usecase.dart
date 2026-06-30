import 'package:step_up_fuels/core/result/result.dart';
import 'package:step_up_fuels/features/vehicles/domain/entities/vehicle.dart';
import 'package:step_up_fuels/features/vehicles/domain/repositories/vehicle_repository.dart';

class GetVehiclesUseCase {
  GetVehiclesUseCase(this._repository);
  final VehicleRepository _repository;

  Future<Result<List<Vehicle>>> call({bool includeDeleted = false}) async {
    return _repository.getAll(includeDeleted: includeDeleted);
  }
}

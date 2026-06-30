import 'package:step_up_fuels/core/result/result.dart';
import 'package:step_up_fuels/features/vehicles/domain/entities/vehicle.dart';
import 'package:step_up_fuels/features/vehicles/domain/repositories/vehicle_repository.dart';

class SaveVehicleUseCase {
  SaveVehicleUseCase(this._repository);
  final VehicleRepository _repository;

  Future<Result<void>> call(Vehicle vehicle) async {
    return _repository.save(vehicle);
  }
}

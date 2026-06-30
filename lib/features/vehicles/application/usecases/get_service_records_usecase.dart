import 'package:step_up_fuels/core/result/result.dart';
import 'package:step_up_fuels/features/vehicles/domain/entities/vehicle_service_record.dart';
import 'package:step_up_fuels/features/vehicles/domain/repositories/vehicle_repository.dart';

class GetServiceRecordsUseCase {
  GetServiceRecordsUseCase(this._repository);
  final VehicleRepository _repository;

  Future<Result<List<VehicleServiceRecord>>> call(String vehicleId) async {
    return _repository.getServiceRecords(vehicleId);
  }
}

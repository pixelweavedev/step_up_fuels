import 'package:step_up_fuels/core/result/result.dart';
import 'package:step_up_fuels/features/vehicles/domain/entities/vehicle.dart';
import 'package:step_up_fuels/features/vehicles/domain/entities/vehicle_service_record.dart';

abstract class VehicleRepository {
  Future<Result<List<Vehicle>>> getAll({bool includeDeleted = false});
  Future<Result<Vehicle>> getById(String id);
  Future<Result<void>> save(Vehicle vehicle);
  Future<Result<void>> softDelete(String id);
  Future<Result<List<VehicleServiceRecord>>> getServiceRecords(String vehicleId);
  Future<Result<void>> saveServiceRecord(VehicleServiceRecord record);
}

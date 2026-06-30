import 'package:step_up_fuels/core/result/result.dart';
import 'package:step_up_fuels/features/drivers/domain/entities/driver.dart';
import 'package:step_up_fuels/features/drivers/domain/repositories/driver_repository.dart';

class GetDriversUseCase {
  GetDriversUseCase(this._repository);
  final DriverRepository _repository;

  Future<Result<List<Driver>>> call({bool includeDeleted = false}) async {
    return _repository.getAll(includeDeleted: includeDeleted);
  }
}

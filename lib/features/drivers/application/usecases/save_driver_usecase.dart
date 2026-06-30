import 'package:step_up_fuels/core/result/result.dart';
import 'package:step_up_fuels/features/drivers/domain/entities/driver.dart';
import 'package:step_up_fuels/features/drivers/domain/repositories/driver_repository.dart';

class SaveDriverUseCase {
  SaveDriverUseCase(this._repository);
  final DriverRepository _repository;

  Future<Result<void>> call(Driver driver) async {
    return _repository.save(driver);
  }
}

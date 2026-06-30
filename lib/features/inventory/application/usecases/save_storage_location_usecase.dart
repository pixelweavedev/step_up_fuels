import 'package:step_up_fuels/core/result/result.dart';
import 'package:step_up_fuels/features/inventory/domain/entities/storage_location.dart';
import 'package:step_up_fuels/features/inventory/domain/repositories/inventory_repository.dart';

class SaveStorageLocationUseCase {
  SaveStorageLocationUseCase(this._repository);
  final InventoryRepository _repository;

  Future<Result<void>> call(StorageLocation location) async {
    return _repository.saveStorageLocation(location);
  }
}

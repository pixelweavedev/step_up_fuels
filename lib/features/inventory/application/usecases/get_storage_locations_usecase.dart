import 'package:step_up_fuels/core/result/result.dart';
import 'package:step_up_fuels/features/inventory/domain/entities/storage_location.dart';
import 'package:step_up_fuels/features/inventory/domain/repositories/inventory_repository.dart';

class GetStorageLocationsUseCase {
  GetStorageLocationsUseCase(this._repository);
  final InventoryRepository _repository;

  Future<Result<List<StorageLocation>>> call({bool includeDeleted = false}) async {
    return _repository.getStorageLocations(includeDeleted: includeDeleted);
  }
}

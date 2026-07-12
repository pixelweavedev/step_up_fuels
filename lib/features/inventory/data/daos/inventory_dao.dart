import 'package:drift/drift.dart';
import 'package:step_up_fuels/app/database/app_database.dart';
import 'package:step_up_fuels/features/inventory/data/tables/daily_stock_reconciliations_table.dart';
import 'package:step_up_fuels/features/inventory/data/tables/inventory_movements_table.dart';
import 'package:step_up_fuels/features/inventory/data/tables/stock_adjustments_table.dart';
import 'package:step_up_fuels/features/inventory/data/tables/storage_locations_table.dart';

part 'inventory_dao.g.dart';

@DriftAccessor(
  tables: [
    StorageLocations,
    InventoryMovements,
    StockAdjustments,
    DailyStockReconciliations,
  ],
)
class InventoryDao extends DatabaseAccessor<AppDatabase>
    with _$InventoryDaoMixin {
  InventoryDao(super.db);

  // ── Storage Locations ──────────────────────────────────────────────────────

  Future<List<StorageLocationRow>> getStorageLocations({
    bool includeDeleted = false,
  }) async {
    if (includeDeleted) {
      return select(storageLocations).get();
    } else {
      return (select(
        storageLocations,
      )..where((t) => t.deletedAt.isNull())).get();
    }
  }

  Future<StorageLocationRow?> getStorageLocationById(String id) async {
    return (select(
      storageLocations,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<void> saveStorageLocation(StorageLocationsCompanion companion) async {
    await into(storageLocations).insertOnConflictUpdate(companion);
  }

  Future<void> softDeleteStorageLocation(String id) async {
    await (update(storageLocations)..where((t) => t.id.equals(id))).write(
      StorageLocationsCompanion(deletedAt: Value(DateTime.now())),
    );
  }

  Future<void> restoreStorageLocation(String id) async {
    await (update(storageLocations)..where((t) => t.id.equals(id))).write(
      const StorageLocationsCompanion(deletedAt: Value(null)),
    );
  }

  // ── Movements ──────────────────────────────────────────────────────────────

  Future<void> recordMovement(InventoryMovementsCompanion companion) async {
    await into(inventoryMovements).insert(companion);
  }

  Future<List<InventoryMovementRow>> getMovements({
    String? locationId,
    String? productId,
    DateTime? start,
    DateTime? end,
  }) async {
    final query = select(inventoryMovements);
    if (locationId != null) {
      query.where(
        (t) =>
            t.sourceLocationId.equals(locationId) |
            t.destinationLocationId.equals(locationId),
      );
    }
    if (productId != null) {
      query.where((t) => t.productId.equals(productId));
    }
    if (start != null) {
      query.where((t) => t.movementDate.isBiggerOrEqualValue(start));
    }
    if (end != null) {
      query.where((t) => t.movementDate.isSmallerOrEqualValue(end));
    }
    query.orderBy([(t) => OrderingTerm.desc(t.movementDate)]);
    return query.get();
  }

  Future<double> getCurrentStock({
    required String locationId,
    required String productId,
  }) async {
    // 1. Sum of all incoming stock
    final incomingQuery = selectOnly(inventoryMovements)
      ..addColumns([inventoryMovements.quantity.sum()])
      ..where(
        inventoryMovements.destinationLocationId.equals(locationId) &
            inventoryMovements.productId.equals(productId),
      );
    final incomingRow = await incomingQuery.getSingle();
    final incoming = incomingRow.read(inventoryMovements.quantity.sum()) ?? 0.0;

    // 2. Sum of all outgoing stock
    final outgoingQuery = selectOnly(inventoryMovements)
      ..addColumns([inventoryMovements.quantity.sum()])
      ..where(
        inventoryMovements.sourceLocationId.equals(locationId) &
            inventoryMovements.productId.equals(productId),
      );
    final outgoingRow = await outgoingQuery.getSingle();
    final outgoing = outgoingRow.read(inventoryMovements.quantity.sum()) ?? 0.0;

    return incoming - outgoing;
  }

  // ── Adjustments ────────────────────────────────────────────────────────────

  Future<void> saveStockAdjustment(StockAdjustmentsCompanion companion) async {
    await into(stockAdjustments).insertOnConflictUpdate(companion);
  }

  Future<List<StockAdjustmentRow>> getAdjustments({
    String? locationId,
    String? productId,
  }) async {
    final query = select(stockAdjustments);
    if (locationId != null) {
      query.where((t) => t.storageLocationId.equals(locationId));
    }
    if (productId != null) {
      query.where((t) => t.productId.equals(productId));
    }
    query.orderBy([(t) => OrderingTerm.desc(t.adjustmentDate)]);
    return query.get();
  }

  // ── Reconciliations ────────────────────────────────────────────────────────

  Future<void> saveReconciliation(
    DailyStockReconciliationsCompanion companion,
  ) async {
    await into(dailyStockReconciliations).insertOnConflictUpdate(companion);
  }

  Future<List<DailyStockReconciliationRow>> getReconciliations({
    String? locationId,
    DateTime? start,
    DateTime? end,
  }) async {
    final query = select(dailyStockReconciliations);
    if (locationId != null) {
      query.where((t) => t.storageLocationId.equals(locationId));
    }
    if (start != null) {
      query.where((t) => t.reconciliationDate.isBiggerOrEqualValue(start));
    }
    if (end != null) {
      query.where((t) => t.reconciliationDate.isSmallerOrEqualValue(end));
    }
    query.orderBy([(t) => OrderingTerm.desc(t.reconciliationDate)]);
    return query.get();
  }
}

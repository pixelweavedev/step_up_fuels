import 'package:drift/drift.dart';
import 'package:step_up_fuels/app/database/app_database.dart';
import 'package:step_up_fuels/features/inventory/domain/entities/daily_stock_reconciliation.dart';
import 'package:step_up_fuels/features/inventory/domain/entities/inventory_movement.dart';
import 'package:step_up_fuels/features/inventory/domain/entities/stock_adjustment.dart';
import 'package:step_up_fuels/features/inventory/domain/entities/storage_location.dart';

extension StorageLocationRowMapper on StorageLocationRow {
  StorageLocation toDomain() {
    return StorageLocation(
      id: id,
      name: name,
      type: StorageLocationTypeExtension.fromString(type),
      vehicleId: vehicleId,
      isActive: isActive,
      createdBy: createdBy,
      createdAt: createdAt,
      updatedBy: updatedBy,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
      version: version,
      tenantId: tenantId,
    );
  }
}

extension StorageLocationMapper on StorageLocation {
  StorageLocationsCompanion toCompanion() {
    return StorageLocationsCompanion(
      id: Value(id),
      name: Value(name),
      type: Value(type.value),
      vehicleId: Value(vehicleId),
      isActive: Value(isActive),
      createdBy: Value(createdBy),
      createdAt: Value(createdAt),
      updatedBy: Value(updatedBy),
      updatedAt: Value(updatedAt),
      deletedAt: Value(deletedAt),
      version: Value(version),
      tenantId: Value(tenantId),
    );
  }
}

extension InventoryMovementRowMapper on InventoryMovementRow {
  InventoryMovement toDomain() {
    return InventoryMovement(
      id: id,
      productId: productId,
      sourceLocationId: sourceLocationId,
      destinationLocationId: destinationLocationId,
      type: MovementTypeExtension.fromString(type),
      quantity: quantity,
      referenceId: referenceId,
      referenceType: referenceType,
      movementDate: movementDate,
      notes: notes,
      createdAt: createdAt,
      createdBy: createdBy,
    );
  }
}

extension InventoryMovementMapper on InventoryMovement {
  InventoryMovementsCompanion toCompanion() {
    return InventoryMovementsCompanion(
      id: Value(id),
      productId: Value(productId),
      sourceLocationId: Value(sourceLocationId),
      destinationLocationId: Value(destinationLocationId),
      type: Value(type.value),
      quantity: Value(quantity),
      referenceId: Value(referenceId),
      referenceType: Value(referenceType),
      movementDate: Value(movementDate),
      notes: Value(notes),
      createdAt: Value(createdAt),
      createdBy: Value(createdBy),
    );
  }
}

extension StockAdjustmentRowMapper on StockAdjustmentRow {
  StockAdjustment toDomain() {
    return StockAdjustment(
      id: id,
      storageLocationId: storageLocationId,
      productId: productId,
      adjustmentType: adjustmentType,
      quantity: quantity,
      reason: reason,
      adjustmentDate: adjustmentDate,
      approvedBy: approvedBy,
      createdBy: createdBy,
      createdAt: createdAt,
      updatedBy: updatedBy,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
      version: version,
      tenantId: tenantId,
    );
  }
}

extension StockAdjustmentMapper on StockAdjustment {
  StockAdjustmentsCompanion toCompanion() {
    return StockAdjustmentsCompanion(
      id: Value(id),
      storageLocationId: Value(storageLocationId),
      productId: Value(productId),
      adjustmentType: Value(adjustmentType),
      quantity: Value(quantity),
      reason: Value(reason),
      adjustmentDate: Value(adjustmentDate),
      approvedBy: Value(approvedBy),
      createdBy: Value(createdBy),
      createdAt: Value(createdAt),
      updatedBy: Value(updatedBy),
      updatedAt: Value(updatedAt),
      deletedAt: Value(deletedAt),
      version: Value(version),
      tenantId: Value(tenantId),
    );
  }
}

extension DailyStockReconciliationRowMapper on DailyStockReconciliationRow {
  DailyStockReconciliation toDomain() {
    return DailyStockReconciliation(
      id: id,
      storageLocationId: storageLocationId,
      reconciliationDate: reconciliationDate,
      openingStock: openingStock,
      quantityReceived: quantityReceived,
      quantityDispensed: quantityDispensed,
      bookStock: bookStock,
      physicalStock: physicalStock,
      variance: variance,
      status: status,
      performedBy: performedBy,
      createdAt: createdAt,
    );
  }
}

extension DailyStockReconciliationMapper on DailyStockReconciliation {
  DailyStockReconciliationsCompanion toCompanion() {
    return DailyStockReconciliationsCompanion(
      id: Value(id),
      storageLocationId: Value(storageLocationId),
      reconciliationDate: Value(reconciliationDate),
      openingStock: Value(openingStock),
      quantityReceived: Value(quantityReceived),
      quantityDispensed: Value(quantityDispensed),
      bookStock: Value(bookStock),
      physicalStock: Value(physicalStock),
      variance: Value(variance),
      status: Value(status),
      performedBy: Value(performedBy),
      createdAt: Value(createdAt),
    );
  }
}

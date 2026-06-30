import 'package:equatable/equatable.dart';

enum MovementType {
  purchaseIn,
  bowserLoad,
  deliveryOut,
  adjustmentIn,
  adjustmentOut,
  openingStock,
}

extension MovementTypeExtension on MovementType {
  String get value {
    switch (this) {
      case MovementType.purchaseIn:
        return 'PURCHASE_IN';
      case MovementType.bowserLoad:
        return 'BOWSER_LOAD';
      case MovementType.deliveryOut:
        return 'DELIVERY_OUT';
      case MovementType.adjustmentIn:
        return 'ADJUSTMENT_IN';
      case MovementType.adjustmentOut:
        return 'ADJUSTMENT_OUT';
      case MovementType.openingStock:
        return 'OPENING_STOCK';
    }
  }

  static MovementType fromString(String val) {
    switch (val) {
      case 'PURCHASE_IN':
        return MovementType.purchaseIn;
      case 'BOWSER_LOAD':
        return MovementType.bowserLoad;
      case 'DELIVERY_OUT':
        return MovementType.deliveryOut;
      case 'ADJUSTMENT_IN':
        return MovementType.adjustmentIn;
      case 'ADJUSTMENT_OUT':
        return MovementType.adjustmentOut;
      case 'OPENING_STOCK':
      default:
        return MovementType.openingStock;
    }
  }
}

class InventoryMovement extends Equatable {
  const InventoryMovement({
    required this.id,
    required this.productId,
    this.sourceLocationId,
    this.destinationLocationId,
    required this.type,
    required this.quantity,
    this.referenceId,
    this.referenceType,
    required this.movementDate,
    this.notes,
    required this.createdAt,
    required this.createdBy,
  });

  final String id;
  final String productId;
  final String? sourceLocationId;
  final String? destinationLocationId;
  final MovementType type;
  final double quantity;
  final String? referenceId;
  final String? referenceType;
  final DateTime movementDate;
  final String? notes;
  final DateTime createdAt;
  final String createdBy;

  @override
  List<Object?> get props => [
        id,
        productId,
        sourceLocationId,
        destinationLocationId,
        type,
        quantity,
        referenceId,
        referenceType,
        movementDate,
        notes,
        createdAt,
        createdBy,
      ];
}

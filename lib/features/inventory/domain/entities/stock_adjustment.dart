import 'package:equatable/equatable.dart';

class StockAdjustment extends Equatable {
  const StockAdjustment({
    required this.id,
    required this.storageLocationId,
    required this.productId,
    required this.adjustmentType, // GAIN, LOSS
    required this.quantity,
    required this.reason,
    required this.adjustmentDate,
    required this.approvedBy,
    required this.createdBy,
    required this.createdAt,
    required this.updatedBy,
    required this.updatedAt,
    this.deletedAt,
    required this.version,
    this.tenantId,
  });

  final String id;
  final String storageLocationId;
  final String productId;
  final String adjustmentType; // GAIN, LOSS
  final double quantity;
  final String reason;
  final DateTime adjustmentDate;
  final String approvedBy;

  // Audits
  final String createdBy;
  final DateTime createdAt;
  final String updatedBy;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int version;
  final String? tenantId;

  @override
  List<Object?> get props => [
    id,
    storageLocationId,
    productId,
    adjustmentType,
    quantity,
    reason,
    adjustmentDate,
    approvedBy,
    createdBy,
    createdAt,
    updatedBy,
    updatedAt,
    deletedAt,
    version,
    tenantId,
  ];
}

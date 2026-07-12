import 'package:equatable/equatable.dart';

class DailyStockReconciliation extends Equatable {
  const DailyStockReconciliation({
    required this.id,
    required this.storageLocationId,
    required this.reconciliationDate,
    required this.openingStock,
    required this.quantityReceived,
    required this.quantityDispensed,
    required this.bookStock,
    required this.physicalStock,
    required this.variance,
    required this.status, // DRAFT, SUBMITTED
    required this.performedBy,
    required this.createdAt,
  });

  final String id;
  final String storageLocationId;
  final DateTime reconciliationDate;
  final double openingStock;
  final double quantityReceived;
  final double quantityDispensed;
  final double bookStock;
  final double physicalStock;
  final double variance;
  final String status;
  final String performedBy;
  final DateTime createdAt;

  @override
  List<Object?> get props => [
    id,
    storageLocationId,
    reconciliationDate,
    openingStock,
    quantityReceived,
    quantityDispensed,
    bookStock,
    physicalStock,
    variance,
    status,
    performedBy,
    createdAt,
  ];
}

import 'package:equatable/equatable.dart';

class FuelPurchaseItem extends Equatable {
  const FuelPurchaseItem({
    required this.id,
    required this.purchaseId,
    required this.productId,
    required this.description,
    required this.quantity,
    required this.unit,
    required this.rate,
    required this.taxableAmount,
    required this.gstRate,
    required this.cgstRate,
    required this.sgstRate,
    required this.igstRate,
    required this.cgstAmount,
    required this.sgstAmount,
    required this.igstAmount,
    required this.totalAmount,
    required this.sortOrder,
  });

  final String id;
  final String purchaseId;
  final String productId;
  final String description;
  final double quantity;
  final String unit;
  final double rate;
  final double taxableAmount;
  final double gstRate;
  final double cgstRate;
  final double sgstRate;
  final double igstRate;
  final double cgstAmount;
  final double sgstAmount;
  final double igstAmount;
  final double totalAmount;
  final int sortOrder;

  @override
  List<Object?> get props => [
    id,
    purchaseId,
    productId,
    description,
    quantity,
    unit,
    rate,
    taxableAmount,
    gstRate,
    cgstRate,
    sgstRate,
    igstRate,
    cgstAmount,
    sgstAmount,
    igstAmount,
    totalAmount,
    sortOrder,
  ];
}

import 'package:equatable/equatable.dart';

class FuelPurchase extends Equatable {
  const FuelPurchase({
    required this.id,
    required this.purchaseNumber,
    required this.supplierId,
    required this.supplierInvoiceNo,
    required this.purchaseDate,
    required this.subtotal,
    required this.cgstAmount,
    required this.sgstAmount,
    required this.igstAmount,
    required this.totalAmount,
    required this.paymentStatus,
    this.notes,
    required this.createdBy,
    required this.createdAt,
    required this.updatedBy,
    required this.updatedAt,
    this.deletedAt,
    required this.version,
    this.tenantId,
  });

  final String id;
  final String purchaseNumber; // e.g. PUR/2026-27/001
  final String supplierId;
  final String supplierInvoiceNo;
  final DateTime purchaseDate;
  final double subtotal; // Taxable amount before GST
  final double cgstAmount;
  final double sgstAmount;
  final double igstAmount;
  final double totalAmount; // Total purchase amount
  final String paymentStatus; // UNPAID, PARTIALLY_PAID, PAID
  final String? notes;

  // Audits
  final String createdBy;
  final DateTime createdAt;
  final String updatedBy;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int version;
  final String? tenantId;

  FuelPurchase copyWith({
    String? purchaseNumber,
    String? supplierId,
    String? supplierInvoiceNo,
    DateTime? purchaseDate,
    double? subtotal,
    double? cgstAmount,
    double? sgstAmount,
    double? igstAmount,
    double? totalAmount,
    String? paymentStatus,
    String? notes,
    String? updatedBy,
    DateTime? deletedAt,
    int? version,
    String? tenantId,
  }) {
    return FuelPurchase(
      id: id,
      purchaseNumber: purchaseNumber ?? this.purchaseNumber,
      supplierId: supplierId ?? this.supplierId,
      supplierInvoiceNo: supplierInvoiceNo ?? this.supplierInvoiceNo,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      subtotal: subtotal ?? this.subtotal,
      cgstAmount: cgstAmount ?? this.cgstAmount,
      sgstAmount: sgstAmount ?? this.sgstAmount,
      igstAmount: igstAmount ?? this.igstAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      notes: notes ?? this.notes,
      createdBy: createdBy,
      createdAt: createdAt,
      updatedBy: updatedBy ?? this.updatedBy,
      updatedAt: DateTime.now(),
      deletedAt: deletedAt ?? this.deletedAt,
      version: version ?? this.version,
      tenantId: tenantId ?? this.tenantId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        purchaseNumber,
        supplierId,
        supplierInvoiceNo,
        purchaseDate,
        subtotal,
        cgstAmount,
        sgstAmount,
        igstAmount,
        totalAmount,
        paymentStatus,
        notes,
        createdBy,
        createdAt,
        updatedBy,
        updatedAt,
        deletedAt,
        version,
        tenantId,
      ];
}

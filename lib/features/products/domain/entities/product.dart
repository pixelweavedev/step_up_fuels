import 'package:equatable/equatable.dart';

/// Represents a Product in the system (e.g. HSD - High Speed Diesel).
class Product extends Equatable {
  const Product({
    required this.id,
    required this.productCode,
    required this.name,
    this.description,
    required this.hsnCode,
    required this.unitOfMeasure,
    required this.gstRate,
    required this.cgstRate,
    required this.sgstRate,
    required this.igstRate,
    this.currentSellingPrice,
    required this.isActive,
    required this.createdBy,
    required this.createdAt,
    required this.updatedBy,
    required this.updatedAt,
    this.deletedAt,
    required this.version,
    this.tenantId,
  });

  final String id;
  final String productCode;
  final String name;
  final String? description;
  final String hsnCode;
  final String unitOfMeasure;
  final double gstRate;
  final double cgstRate;
  final double sgstRate;
  final double igstRate;
  final double? currentSellingPrice;
  final bool isActive;

  // Audits
  final String createdBy;
  final DateTime createdAt;
  final String updatedBy;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int version;
  final String? tenantId;

  Product copyWith({
    String? productCode,
    String? name,
    String? description,
    String? hsnCode,
    String? unitOfMeasure,
    double? gstRate,
    double? cgstRate,
    double? sgstRate,
    double? igstRate,
    double? currentSellingPrice,
    bool? isActive,
    String? updatedBy,
    DateTime? deletedAt,
    int? version,
    String? tenantId,
  }) {
    return Product(
      id: id,
      productCode: productCode ?? this.productCode,
      name: name ?? this.name,
      description: description ?? this.description,
      hsnCode: hsnCode ?? this.hsnCode,
      unitOfMeasure: unitOfMeasure ?? this.unitOfMeasure,
      gstRate: gstRate ?? this.gstRate,
      cgstRate: cgstRate ?? this.cgstRate,
      sgstRate: sgstRate ?? this.sgstRate,
      igstRate: igstRate ?? this.igstRate,
      currentSellingPrice: currentSellingPrice ?? this.currentSellingPrice,
      isActive: isActive ?? this.isActive,
      createdBy: createdBy,
      createdAt: createdAt,
      updatedBy: updatedBy ?? this.updatedBy,
      updatedAt: DateTime.now(),
      deletedAt: deletedAt ?? this.deletedAt,
      version: version ?? (this.version + 1),
      tenantId: tenantId ?? this.tenantId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        productCode,
        name,
        description,
        hsnCode,
        unitOfMeasure,
        gstRate,
        cgstRate,
        sgstRate,
        igstRate,
        currentSellingPrice,
        isActive,
        createdBy,
        createdAt,
        updatedBy,
        updatedAt,
        deletedAt,
        version,
        tenantId,
      ];
}

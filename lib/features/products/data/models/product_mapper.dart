import 'package:drift/drift.dart';
import 'package:step_up_fuels/app/database/app_database.dart';
import 'package:step_up_fuels/features/products/domain/entities/product.dart';

extension ProductRowMapper on ProductRow {
  Product toDomain() {
    return Product(
      id: id,
      productCode: productCode,
      name: name,
      description: description,
      hsnCode: hsnCode,
      unitOfMeasure: unitOfMeasure,
      gstRate: gstRate,
      cgstRate: cgstRate,
      sgstRate: sgstRate,
      igstRate: igstRate,
      currentSellingPrice: currentSellingPrice,
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

extension ProductMapper on Product {
  ProductsCompanion toCompanion() {
    return ProductsCompanion(
      id: Value(id),
      productCode: Value(productCode),
      name: Value(name),
      description: Value(description),
      hsnCode: Value(hsnCode),
      unitOfMeasure: Value(unitOfMeasure),
      gstRate: Value(gstRate),
      cgstRate: Value(cgstRate),
      sgstRate: Value(sgstRate),
      igstRate: Value(igstRate),
      currentSellingPrice: Value(currentSellingPrice),
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

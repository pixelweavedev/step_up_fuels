import 'package:drift/drift.dart';
import 'package:step_up_fuels/app/database/app_database.dart';
import 'package:step_up_fuels/features/purchases/domain/entities/fuel_purchase.dart';
import 'package:step_up_fuels/features/purchases/domain/entities/fuel_purchase_item.dart';

extension FuelPurchaseRowMapper on FuelPurchaseRow {
  FuelPurchase toDomain() => FuelPurchase(
    id: id,
    purchaseNumber: purchaseNumber,
    supplierId: supplierId,
    supplierInvoiceNo: supplierInvoiceNo,
    purchaseDate: purchaseDate,
    subtotal: subtotal,
    cgstAmount: cgstAmount,
    sgstAmount: sgstAmount,
    igstAmount: igstAmount,
    totalAmount: totalAmount,
    paymentStatus: paymentStatus,
    notes: notes,
    destinationLocationId: destinationLocationId,
    createdBy: createdBy,
    createdAt: createdAt,
    updatedBy: updatedBy,
    updatedAt: updatedAt,
    deletedAt: deletedAt,
    version: version,
    tenantId: tenantId,
  );
}

extension FuelPurchaseDomainMapper on FuelPurchase {
  FuelPurchasesCompanion toCompanion() => FuelPurchasesCompanion(
    id: Value(id),
    purchaseNumber: Value(purchaseNumber),
    supplierId: Value(supplierId),
    supplierInvoiceNo: Value(supplierInvoiceNo),
    purchaseDate: Value(purchaseDate),
    subtotal: Value(subtotal),
    cgstAmount: Value(cgstAmount),
    sgstAmount: Value(sgstAmount),
    igstAmount: Value(igstAmount),
    totalAmount: Value(totalAmount),
    paymentStatus: Value(paymentStatus),
    notes: Value(notes),
    destinationLocationId: Value(destinationLocationId),
    createdBy: Value(createdBy),
    createdAt: Value(createdAt),
    updatedBy: Value(updatedBy),
    updatedAt: Value(updatedAt),
    deletedAt: Value(deletedAt),
    version: Value(version),
    tenantId: Value(tenantId),
  );
}

extension FuelPurchaseItemRowMapper on FuelPurchaseItemRow {
  FuelPurchaseItem toDomain() => FuelPurchaseItem(
    id: id,
    purchaseId: purchaseId,
    productId: productId,
    description: description,
    quantity: quantity,
    unit: unit,
    rate: rate,
    taxableAmount: taxableAmount,
    gstRate: gstRate,
    cgstRate: cgstRate,
    sgstRate: sgstRate,
    igstRate: igstRate,
    cgstAmount: cgstAmount,
    sgstAmount: sgstAmount,
    igstAmount: igstAmount,
    totalAmount: totalAmount,
    sortOrder: sortOrder,
  );
}

extension FuelPurchaseItemDomainMapper on FuelPurchaseItem {
  FuelPurchaseItemsCompanion toCompanion() => FuelPurchaseItemsCompanion(
    id: Value(id),
    purchaseId: Value(purchaseId),
    productId: Value(productId),
    description: Value(description),
    quantity: Value(quantity),
    unit: Value(unit),
    rate: Value(rate),
    taxableAmount: Value(taxableAmount),
    gstRate: Value(gstRate),
    cgstRate: Value(cgstRate),
    sgstRate: Value(sgstRate),
    igstRate: Value(igstRate),
    cgstAmount: Value(cgstAmount),
    sgstAmount: Value(sgstAmount),
    igstAmount: Value(igstAmount),
    totalAmount: Value(totalAmount),
    sortOrder: Value(sortOrder),
  );
}

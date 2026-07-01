import 'package:drift/drift.dart';
import 'package:step_up_fuels/app/database/app_database.dart';
import 'package:step_up_fuels/features/purchases/domain/entities/supplier.dart';

extension SupplierRowMapper on SupplierRow {
  Supplier toDomain() => Supplier(
        id: id,
        supplierCode: supplierCode,
        name: name,
        tradeName: tradeName,
        gstin: gstin,
        pan: pan,
        billingAddressLine1: billingAddressLine1,
        billingAddressLine2: billingAddressLine2,
        billingCity: billingCity,
        billingState: billingState,
        billingPincode: billingPincode,
        contactPerson: contactPerson,
        phone: phone,
        email: email,
        isActive: isActive,
        notes: notes,
        createdBy: createdBy,
        createdAt: createdAt,
        updatedBy: updatedBy,
        updatedAt: updatedAt,
        deletedAt: deletedAt,
        version: version,
        tenantId: tenantId,
      );
}

extension SupplierDomainMapper on Supplier {
  SuppliersCompanion toCompanion() => SuppliersCompanion(
        id: Value(id),
        supplierCode: Value(supplierCode),
        name: Value(name),
        tradeName: Value(tradeName),
        gstin: Value(gstin),
        pan: Value(pan),
        billingAddressLine1: Value(billingAddressLine1),
        billingAddressLine2: Value(billingAddressLine2),
        billingCity: Value(billingCity),
        billingState: Value(billingState),
        billingPincode: Value(billingPincode),
        contactPerson: Value(contactPerson),
        phone: Value(phone),
        email: Value(email),
        isActive: Value(isActive),
        notes: Value(notes),
        createdBy: Value(createdBy),
        createdAt: Value(createdAt),
        updatedBy: Value(updatedBy),
        updatedAt: Value(updatedAt),
        deletedAt: Value(deletedAt),
        version: Value(version),
        tenantId: Value(tenantId),
      );
}

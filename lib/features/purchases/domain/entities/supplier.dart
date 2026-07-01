import 'package:equatable/equatable.dart';

class Supplier extends Equatable {
  const Supplier({
    required this.id,
    required this.supplierCode,
    required this.name,
    this.tradeName,
    this.gstin,
    this.pan,
    this.billingAddressLine1,
    this.billingAddressLine2,
    this.billingCity,
    this.billingState,
    this.billingPincode,
    required this.contactPerson,
    required this.phone,
    this.email,
    required this.isActive,
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
  final String supplierCode;
  final String name;
  final String? tradeName;
  final String? gstin;
  final String? pan;
  final String? billingAddressLine1;
  final String? billingAddressLine2;
  final String? billingCity;
  final String? billingState;
  final String? billingPincode;
  final String contactPerson;
  final String phone;
  final String? email;
  final bool isActive;
  final String? notes;

  // Audits
  final String createdBy;
  final DateTime createdAt;
  final String updatedBy;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int version;
  final String? tenantId;

  Supplier copyWith({
    String? supplierCode,
    String? name,
    String? tradeName,
    String? gstin,
    String? pan,
    String? billingAddressLine1,
    String? billingAddressLine2,
    String? billingCity,
    String? billingState,
    String? billingPincode,
    String? contactPerson,
    String? phone,
    String? email,
    bool? isActive,
    String? notes,
    String? updatedBy,
    DateTime? deletedAt,
    int? version,
    String? tenantId,
  }) {
    return Supplier(
      id: id,
      supplierCode: supplierCode ?? this.supplierCode,
      name: name ?? this.name,
      tradeName: tradeName ?? this.tradeName,
      gstin: gstin ?? this.gstin,
      pan: pan ?? this.pan,
      billingAddressLine1: billingAddressLine1 ?? this.billingAddressLine1,
      billingAddressLine2: billingAddressLine2 ?? this.billingAddressLine2,
      billingCity: billingCity ?? this.billingCity,
      billingState: billingState ?? this.billingState,
      billingPincode: billingPincode ?? this.billingPincode,
      contactPerson: contactPerson ?? this.contactPerson,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      isActive: isActive ?? this.isActive,
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
        supplierCode,
        name,
        tradeName,
        gstin,
        pan,
        billingAddressLine1,
        billingAddressLine2,
        billingCity,
        billingState,
        billingPincode,
        contactPerson,
        phone,
        email,
        isActive,
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

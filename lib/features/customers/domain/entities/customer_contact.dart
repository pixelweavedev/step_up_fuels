import 'package:equatable/equatable.dart';

/// Represents a customer's contact person with designation and social preferences.
class CustomerContact extends Equatable {
  const CustomerContact({
    required this.id,
    required this.customerId,
    required this.name,
    this.designation,
    this.phone,
    this.email,
    this.whatsapp,
    required this.isPrimary,
    required this.isActive,
    required this.createdBy,
    required this.createdAt,
    required this.updatedBy,
    required this.updatedAt,
    this.deletedAt,
    required this.version,
    this.tenantId,
  });

  /// Factory constructor for creating a new CustomerContact with defaults.
  factory CustomerContact.newContact({
    required String id,
    required String customerId,
    required String name,
    String? designation,
    String? phone,
    String? email,
    String? whatsapp,
    bool isPrimary = false,
  }) {
    final now = DateTime.now();
    return CustomerContact(
      id: id,
      customerId: customerId,
      name: name,
      designation: designation,
      phone: phone,
      email: email,
      whatsapp: whatsapp,
      isPrimary: isPrimary,
      isActive: true,
      createdBy: 'system',
      createdAt: now,
      updatedBy: 'system',
      updatedAt: now,
      version: 1,
    );
  }
  final String id;
  final String customerId;
  final String name;
  final String? designation;
  final String? phone;
  final String? email;
  final String? whatsapp;
  final bool isPrimary;
  final bool isActive;

  // Audit Fields
  final String createdBy;
  final DateTime createdAt;
  final String updatedBy;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int version;
  final String? tenantId;

  /// Creates a copy of this CustomerContact with the given fields replaced.
  CustomerContact copyWith({
    String? name,
    String? designation,
    String? phone,
    String? email,
    String? whatsapp,
    bool? isPrimary,
    bool? isActive,
    String? updatedBy,
    DateTime? deletedAt,
    int? version,
    String? tenantId,
  }) {
    return CustomerContact(
      id: id,
      customerId: customerId,
      name: name ?? this.name,
      designation: designation ?? this.designation,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      whatsapp: whatsapp ?? this.whatsapp,
      isPrimary: isPrimary ?? this.isPrimary,
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
    customerId,
    name,
    designation,
    phone,
    email,
    whatsapp,
    isPrimary,
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

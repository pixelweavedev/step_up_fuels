import 'package:equatable/equatable.dart';

/// Represents a customer's delivery site with GPS coordinates and contact details.
class CustomerSite extends Equatable {
  const CustomerSite({
    required this.id,
    required this.customerId,
    required this.name,
    this.addressLine1,
    this.addressLine2,
    this.city,
    this.state,
    this.stateCode,
    this.pincode,
    this.country,
    this.latitude,
    this.longitude,
    this.contactPerson,
    this.contactNumber,
    required this.isDefault,
    required this.isActive,
    required this.createdBy,
    required this.createdAt,
    required this.updatedBy,
    required this.updatedAt,
    this.deletedAt,
    required this.version,
    this.tenantId,
  });

  /// Factory constructor for creating a new CustomerSite with defaults.
  factory CustomerSite.newSite({
    required String id,
    required String customerId,
    required String name,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? state,
    String? stateCode,
    String? pincode,
    String? country,
    double? latitude,
    double? longitude,
    String? contactPerson,
    String? contactNumber,
    bool isDefault = false,
  }) {
    final now = DateTime.now();
    return CustomerSite(
      id: id,
      customerId: customerId,
      name: name,
      addressLine1: addressLine1,
      addressLine2: addressLine2,
      city: city,
      state: state,
      stateCode: stateCode,
      pincode: pincode,
      country: country,
      latitude: latitude,
      longitude: longitude,
      contactPerson: contactPerson,
      contactNumber: contactNumber,
      isDefault: isDefault,
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
  final String? addressLine1;
  final String? addressLine2;
  final String? city;
  final String? state;
  final String? stateCode;
  final String? pincode;
  final String? country;

  // GPS Coordinates
  final double? latitude;
  final double? longitude;

  // Site Contacts
  final String? contactPerson;
  final String? contactNumber;

  final bool isDefault;
  final bool isActive;

  // Audit Fields
  final String createdBy;
  final DateTime createdAt;
  final String updatedBy;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int version;
  final String? tenantId;

  /// Creates a copy of this CustomerSite with the given fields replaced.
  CustomerSite copyWith({
    String? name,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? state,
    String? stateCode,
    String? pincode,
    String? country,
    double? latitude,
    double? longitude,
    String? contactPerson,
    String? contactNumber,
    bool? isDefault,
    bool? isActive,
    String? updatedBy,
    DateTime? deletedAt,
    int? version,
    String? tenantId,
  }) {
    return CustomerSite(
      id: id,
      customerId: customerId,
      name: name ?? this.name,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      city: city ?? this.city,
      state: state ?? this.state,
      stateCode: stateCode ?? this.stateCode,
      pincode: pincode ?? this.pincode,
      country: country ?? this.country,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      contactPerson: contactPerson ?? this.contactPerson,
      contactNumber: contactNumber ?? this.contactNumber,
      isDefault: isDefault ?? this.isDefault,
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
    addressLine1,
    addressLine2,
    city,
    state,
    stateCode,
    pincode,
    country,
    latitude,
    longitude,
    contactPerson,
    contactNumber,
    isDefault,
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

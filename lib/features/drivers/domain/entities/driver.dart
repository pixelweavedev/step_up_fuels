enum DriverStatus {
  active,
  suspended,
  inactive;

  String get displayName {
    switch (this) {
      case DriverStatus.active:
        return 'Active';
      case DriverStatus.suspended:
        return 'Suspended';
      case DriverStatus.inactive:
        return 'Inactive';
    }
  }
}

class Driver {
  Driver({
    required this.id,
    required this.name,
    required this.licenseNumber,
    required this.licenseExpiry,
    required this.phone,
    this.email,
    required this.status,
    required this.createdBy,
    required this.createdAt,
    required this.updatedBy,
    required this.updatedAt,
    this.deletedAt,
    required this.version,
    this.tenantId,
  });

  final String id;
  final String name;
  final String licenseNumber;
  final DateTime licenseExpiry;
  final String phone;
  final String? email;
  final DriverStatus status;

  // Audits
  final String createdBy;
  final DateTime createdAt;
  final String updatedBy;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int version;
  final String? tenantId;
}

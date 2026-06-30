enum VehicleStatus {
  active,
  maintenance,
  inactive;

  String get displayName {
    switch (this) {
      case VehicleStatus.active:
        return 'Active';
      case VehicleStatus.maintenance:
        return 'Maintenance';
      case VehicleStatus.inactive:
        return 'Inactive';
    }
  }
}

class Vehicle {
  Vehicle({
    required this.id,
    required this.registrationNumber,
    required this.model,
    required this.capacity,
    required this.status,
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
  final String registrationNumber;
  final String model;
  final double capacity;
  final VehicleStatus status;
  final String? notes;

  // Audits
  final String createdBy;
  final DateTime createdAt;
  final String updatedBy;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int version;
  final String? tenantId;
}

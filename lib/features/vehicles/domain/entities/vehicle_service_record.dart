enum VehicleServiceType {
  routine,
  repair,
  tyre,
  insurance,
  roadTax,
  other;

  String get displayName {
    switch (this) {
      case VehicleServiceType.routine:
        return 'Routine Service';
      case VehicleServiceType.repair:
        return 'Repair';
      case VehicleServiceType.tyre:
        return 'Tyre Change';
      case VehicleServiceType.insurance:
        return 'Insurance';
      case VehicleServiceType.roadTax:
        return 'Road Tax / RTO';
      case VehicleServiceType.other:
        return 'Other';
    }
  }
}

class VehicleServiceRecord {
  VehicleServiceRecord({
    required this.id,
    required this.vehicleId,
    required this.serviceDate,
    required this.serviceType,
    required this.cost,
    required this.details,
    required this.serviceCenter,
    this.billDocumentId,
    required this.createdBy,
    required this.createdAt,
    required this.updatedBy,
    required this.updatedAt,
    this.deletedAt,
    required this.version,
    this.tenantId,
  });

  final String id;
  final String vehicleId;
  final DateTime serviceDate;
  final VehicleServiceType serviceType;
  final double cost;
  final String details;
  final String serviceCenter;
  final String? billDocumentId;

  // Audits
  final String createdBy;
  final DateTime createdAt;
  final String updatedBy;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int version;
  final String? tenantId;
}

class DriverAssignment {
  DriverAssignment({
    required this.id,
    required this.driverId,
    required this.vehicleId,
    required this.assignedAt,
    this.releasedAt,
    required this.isActive,
  });

  final String id;
  final String driverId;
  final String vehicleId;
  final DateTime assignedAt;
  final DateTime? releasedAt;
  final bool isActive;
}

import 'package:drift/drift.dart';
import 'package:step_up_fuels/app/database/app_database.dart';
import 'package:step_up_fuels/features/drivers/domain/entities/driver.dart';
import 'package:step_up_fuels/features/drivers/domain/entities/driver_assignment.dart';

extension DriverRowMapper on DriverRow {
  Driver toDomain() {
    return Driver(
      id: id,
      name: name,
      licenseNumber: licenseNumber,
      licenseExpiry: licenseExpiry,
      phone: phone,
      email: email,
      status: DriverStatus.values.firstWhere(
        (e) => e.name.toUpperCase() == status.toUpperCase(),
        orElse: () => DriverStatus.active,
      ),
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

extension DriverMapper on Driver {
  DriversCompanion toCompanion() {
    return DriversCompanion(
      id: Value(id),
      name: Value(name),
      licenseNumber: Value(licenseNumber),
      licenseExpiry: Value(licenseExpiry),
      phone: Value(phone),
      email: Value(email),
      status: Value(status.name.toUpperCase()),
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

extension DriverAssignmentRowMapper on DriverAssignmentRow {
  DriverAssignment toDomain() {
    return DriverAssignment(
      id: id,
      driverId: driverId,
      vehicleId: vehicleId,
      assignedAt: assignedAt,
      releasedAt: releasedAt,
      isActive: isActive,
    );
  }
}

extension DriverAssignmentMapper on DriverAssignment {
  DriverAssignmentsCompanion toCompanion() {
    return DriverAssignmentsCompanion(
      id: Value(id),
      driverId: Value(driverId),
      vehicleId: Value(vehicleId),
      assignedAt: Value(assignedAt),
      releasedAt: Value(releasedAt),
      isActive: Value(isActive),
    );
  }
}

import 'package:drift/drift.dart';
import 'package:step_up_fuels/app/database/app_database.dart';
import 'package:step_up_fuels/features/vehicles/domain/entities/vehicle.dart';
import 'package:step_up_fuels/features/vehicles/domain/entities/vehicle_service_record.dart';

extension VehicleRowMapper on VehicleRow {
  Vehicle toDomain() {
    return Vehicle(
      id: id,
      registrationNumber: registrationNumber,
      model: model,
      capacity: capacity,
      status: VehicleStatus.values.firstWhere(
        (e) => e.name.toUpperCase() == status.toUpperCase(),
        orElse: () => VehicleStatus.active,
      ),
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
}

extension VehicleMapper on Vehicle {
  VehiclesCompanion toCompanion() {
    return VehiclesCompanion(
      id: Value(id),
      registrationNumber: Value(registrationNumber),
      model: Value(model),
      capacity: Value(capacity),
      status: Value(status.name.toUpperCase()),
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
}

extension VehicleServiceRecordRowMapper on VehicleServiceRecordRow {
  VehicleServiceRecord toDomain() {
    return VehicleServiceRecord(
      id: id,
      vehicleId: vehicleId,
      serviceDate: serviceDate,
      serviceType: VehicleServiceType.values.firstWhere(
        (e) => e.name.toUpperCase() == serviceType.toUpperCase(),
        orElse: () => VehicleServiceType.other,
      ),
      cost: cost,
      details: details,
      serviceCenter: serviceCenter,
      billDocumentId: billDocumentId,
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

extension VehicleServiceRecordMapper on VehicleServiceRecord {
  VehicleServiceRecordsCompanion toCompanion() {
    return VehicleServiceRecordsCompanion(
      id: Value(id),
      vehicleId: Value(vehicleId),
      serviceDate: Value(serviceDate),
      serviceType: Value(serviceType.name.toUpperCase()),
      cost: Value(cost),
      details: Value(details),
      serviceCenter: Value(serviceCenter),
      billDocumentId: Value(billDocumentId),
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

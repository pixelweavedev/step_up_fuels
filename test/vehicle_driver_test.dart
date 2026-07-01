import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:step_up_fuels/app/database/app_database.dart';
import 'package:step_up_fuels/features/drivers/data/daos/drivers_dao.dart';
import 'package:step_up_fuels/features/drivers/data/repositories/driver_repository_impl.dart';
import 'package:step_up_fuels/features/drivers/domain/entities/driver.dart';
import 'package:step_up_fuels/features/drivers/domain/entities/driver_assignment.dart';
import 'package:step_up_fuels/features/vehicles/data/daos/vehicles_dao.dart';
import 'package:step_up_fuels/features/vehicles/data/repositories/vehicle_repository_impl.dart';
import 'package:step_up_fuels/features/vehicles/domain/entities/vehicle.dart';
import 'package:step_up_fuels/features/vehicles/domain/entities/vehicle_service_record.dart';

void main() {
  group('Vehicle & Driver Management Integration Tests', () {
    late AppDatabase db;
    late VehiclesDao vehiclesDao;
    late VehicleRepositoryImpl vehicleRepository;
    late DriversDao driversDao;
    late DriverRepositoryImpl driverRepository;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      vehiclesDao = VehiclesDao(db);
      vehicleRepository = VehicleRepositoryImpl(vehiclesDao);
      driversDao = DriversDao(db);
      driverRepository = DriverRepositoryImpl(driversDao);
    });

    tearDown(() async {
      await db.close();
    });

    test('should auto-register a mobile StorageLocation when a Vehicle is created', () async {
      // 1. Arrange: Create a new vehicle
      final vehicle = Vehicle(
        id: 'vehicle-1',
        registrationNumber: 'MH-12-Q-1111',
        model: 'Tata Bowser 6KL',
        capacity: 6000.0,
        status: VehicleStatus.active,
        createdBy: 'test_user',
        createdAt: DateTime.now(),
        updatedBy: 'test_user',
        updatedAt: DateTime.now(),
        version: 1,
      );

      // 2. Act: Save the vehicle
      final saveResult = await vehicleRepository.save(vehicle);
      expect(saveResult.isSuccess, isTrue);

      // 3. Assert: Verify the vehicle exists in database
      final fetchResult = await vehicleRepository.getById('vehicle-1');
      expect(fetchResult.isSuccess, isTrue);
      expect(fetchResult.dataOrThrow.registrationNumber, 'MH-12-Q-1111');

      // 4. Assert: Check if matching StorageLocation was created
      final locRow = await (db.select(db.storageLocations)
            ..where((t) => t.id.equals('vehicle-1')))
          .getSingleOrNull();

      expect(locRow, isNotNull);
      expect(locRow!.name, 'MH-12-Q-1111');
      expect(locRow.type, 'BOWSER');
    });

    test('should auto-log a corresponding Expense when a Service Record is added', () async {
      // 1. Arrange: Register vehicle first
      final vehicle = Vehicle(
        id: 'vehicle-1',
        registrationNumber: 'MH-12-Q-1111',
        model: 'Tata Bowser 6KL',
        capacity: 6000.0,
        status: VehicleStatus.active,
        createdBy: 'test_user',
        createdAt: DateTime.now(),
        updatedBy: 'test_user',
        updatedAt: DateTime.now(),
        version: 1,
      );
      await vehicleRepository.save(vehicle);

      // 2. Act: Record service log
      final record = VehicleServiceRecord(
        id: 'srv-record-1',
        vehicleId: 'vehicle-1',
        serviceDate: DateTime.now(),
        serviceType: VehicleServiceType.routine,
        cost: 4500.0,
        details: 'Engine oil replacement and filters cleanup',
        serviceCenter: 'Tata Service Terminal MH',
        createdBy: 'test_user',
        createdAt: DateTime.now(),
        updatedBy: 'test_user',
        updatedAt: DateTime.now(),
        version: 1,
      );
      final srvResult = await vehicleRepository.saveServiceRecord(record);
      expect(srvResult.isSuccess, isTrue);

      // 3. Assert: Check service record saved
      final records = await vehicleRepository.getServiceRecords('vehicle-1');
      expect(records.isSuccess, isTrue);
      expect(records.dataOrThrow.length, 1);
      expect(records.dataOrThrow.first.details, 'Engine oil replacement and filters cleanup');

      // 4. Assert: Check if Expense was auto-logged
      final expenseRow = await (db.select(db.expenses)
            ..where((t) => t.vehicleId.equals('vehicle-1')))
          .getSingleOrNull();

      expect(expenseRow, isNotNull);
      expect(expenseRow!.amount, 4500.0);
      expect(expenseRow.category, 'VEHICLE_MAINTENANCE');
      expect(expenseRow.notes, contains('srv-record-1'));
    });

    test('should release old assignments and enforce exclusivity in driver-vehicle assignments', () async {
      // 1. Arrange: Create vehicles and drivers
      final vehicle1 = Vehicle(
        id: 'v-1',
        registrationNumber: 'MH-12-Q-1001',
        model: ' टाटा ',
        capacity: 5000.0,
        status: VehicleStatus.active,
        createdBy: 'system',
        createdAt: DateTime.now(),
        updatedBy: 'system',
        updatedAt: DateTime.now(),
        version: 1,
      );
      final vehicle2 = Vehicle(
        id: 'v-2',
        registrationNumber: 'MH-12-Q-1002',
        model: ' टाटा ',
        capacity: 5000.0,
        status: VehicleStatus.active,
        createdBy: 'system',
        createdAt: DateTime.now(),
        updatedBy: 'system',
        updatedAt: DateTime.now(),
        version: 1,
      );
      await vehicleRepository.save(vehicle1);
      await vehicleRepository.save(vehicle2);

      final driverA = Driver(
        id: 'd-a',
        name: 'Driver A',
        licenseNumber: 'DL-1111',
        licenseExpiry: DateTime.now().add(const Duration(days: 365)),
        phone: '1234',
        status: DriverStatus.active,
        createdBy: 'system',
        createdAt: DateTime.now(),
        updatedBy: 'system',
        updatedAt: DateTime.now(),
        version: 1,
      );
      final driverB = Driver(
        id: 'd-b',
        name: 'Driver B',
        licenseNumber: 'DL-2222',
        licenseExpiry: DateTime.now().add(const Duration(days: 365)),
        phone: '5678',
        status: DriverStatus.active,
        createdBy: 'system',
        createdAt: DateTime.now(),
        updatedBy: 'system',
        updatedAt: DateTime.now(),
        version: 1,
      );
      await driverRepository.save(driverA);
      await driverRepository.save(driverB);

      // 2. Act: Assign Driver A to Vehicle 1
      final asg1 = DriverAssignment(
        id: 'asg-1',
        driverId: 'd-a',
        vehicleId: 'v-1',
        assignedAt: DateTime.now(),
        isActive: true,
      );
      await driverRepository.assignDriver(asg1);

      // Verify active assignment
      var assignments = await driverRepository.getAssignments(driverId: 'd-a');
      expect(assignments.dataOrThrow.length, 1);
      expect(assignments.dataOrThrow.first.isActive, isTrue);
      expect(assignments.dataOrThrow.first.vehicleId, 'v-1');

      // 3. Act: Assign Driver A to Vehicle 2 (Driver A moves to Vehicle 2, releases Vehicle 1)
      final asg2 = DriverAssignment(
        id: 'asg-2',
        driverId: 'd-a',
        vehicleId: 'v-2',
        assignedAt: DateTime.now().add(const Duration(seconds: 1)),
        isActive: true,
      );
      await driverRepository.assignDriver(asg2);

      // Verify Driver A's active vehicle is now v-2, and asg-1 is released
      assignments = await driverRepository.getAssignments(driverId: 'd-a');
      expect(assignments.dataOrThrow.length, 2);
      
      final activeForA = assignments.dataOrThrow.firstWhere((a) => a.isActive);
      expect(activeForA.vehicleId, 'v-2');
      expect(activeForA.id, 'asg-2');

      final inactiveForA = assignments.dataOrThrow.firstWhere((a) => !a.isActive);
      expect(inactiveForA.vehicleId, 'v-1');
      expect(inactiveForA.id, 'asg-1');
      expect(inactiveForA.releasedAt, isNotNull);

      // 4. Act: Assign Driver B to Vehicle 2 (Driver B takes Vehicle 2, releases Driver A from Vehicle 2)
      final asg3 = DriverAssignment(
        id: 'asg-3',
        driverId: 'd-b',
        vehicleId: 'v-2',
        assignedAt: DateTime.now().add(const Duration(seconds: 2)),
        isActive: true,
      );
      await driverRepository.assignDriver(asg3);

      // Verify Driver B is active on v-2
      final bAssignments = await driverRepository.getAssignments(driverId: 'd-b');
      expect(bAssignments.dataOrThrow.length, 1);
      expect(bAssignments.dataOrThrow.first.isActive, isTrue);
      expect(bAssignments.dataOrThrow.first.vehicleId, 'v-2');

      // Verify Driver A is now completely released (no active assignments anymore)
      assignments = await driverRepository.getAssignments(driverId: 'd-a');
      final activeForAAfterB = assignments.dataOrThrow.where((a) => a.isActive);
      expect(activeForAAfterB, isEmpty);
    });
  });
}

import 'package:drift/drift.dart';
import 'package:step_up_fuels/features/customers/data/tables/customer_sites_table.dart';
import 'package:step_up_fuels/features/customers/data/tables/customers_table.dart';
import 'package:step_up_fuels/features/drivers/data/tables/drivers_table.dart';
import 'package:step_up_fuels/features/vehicles/data/tables/vehicles_table.dart';

/// Drift table representing a physical Fuel Delivery (Delivery Challan).
@DataClassName('FuelDeliveryRow')
class FuelDeliveries extends Table {
  TextColumn get id => text()();
  TextColumn get deliverySlipNumber => text().unique()(); // Auto-generated e.g. DC-2026-0001
  TextColumn get customerId => text().references(Customers, #id)();
  TextColumn get customerSiteId => text().references(CustomerSites, #id)();
  TextColumn get vehicleId => text().references(Vehicles, #id)();
  TextColumn get driverId => text().references(Drivers, #id)();
  RealColumn get quantity => real()(); // Litres delivered
  RealColumn get ratePerLitre => real()();
  RealColumn get totalAmount => real()();
  DateTimeColumn get deliveryDate => dateTime()();
  TextColumn get invoiceId => text().nullable()(); // Linked Invoice ID (null if pending billing)
  TextColumn get billingStatus => text()(); // PENDING_BILLING, BILLED, EXEMPT
  TextColumn get paymentStatus => text().withDefault(const Constant('UNPAID'))(); // UNPAID, PARTIAL, PAID
  TextColumn get notes => text().nullable()();

  // Audits & SaaS Scope
  TextColumn get createdBy => text().withDefault(const Constant('system'))();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get updatedBy => text().withDefault(const Constant('system'))();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  TextColumn get tenantId => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

# 03 — Fuel Delivery History Design

## Overview
A Fuel Delivery represents the physical dispatch and delivery of fuel to a customer's site. It is recorded as a Delivery Challan (DC) or delivery slip. In invoicing workflows, a delivery slip might be billed immediately, or multiple slips might be consolidated into a single monthly invoice.

---

## Domain Entities

### FuelDelivery
```dart
class FuelDelivery {
  final String id;
  final String deliverySlipNumber;    // Auto-generated e.g. DC-2026-0001
  final String customerId;            // FK to Customers
  final String customerSiteId;        // FK to CustomerSites (Delivery location)
  final String vehicleId;             // FK to Vehicles (Bowser used)
  final String driverId;              // FK to Drivers
  final double quantity;              // Litres delivered
  final double ratePerLitre;          // Agreed rate per litre
  final double totalAmount;           // quantity * ratePerLitre
  final DateTime deliveryDate;
  final String? invoiceId;            // FK to Invoices (nullable if not yet billed)
  final DeliveryBillingStatus billingStatus; // PENDING_BILLING, BILLED, EXEMPT
  final String paymentStatus;         // UNPAID, PARTIAL, PAID (mirrors invoice status if billed)
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
}

enum DeliveryBillingStatus { pendingBilling, billed, exempt }
```

---

## Database Drift Schema Details

```dart
@DataClassName('FuelDeliveryRow')
class FuelDeliveries extends Table {
  TextColumn get id => text()();
  TextColumn get deliverySlipNumber => text().unique()();
  TextColumn get customerId => text()();
  TextColumn get customerSiteId => text()();
  TextColumn get vehicleId => text()();
  TextColumn get driverId => text()();
  RealColumn get quantity => real()();
  RealColumn get ratePerLitre => real()();
  RealColumn get totalAmount => real()();
  DateTimeColumn get deliveryDate => dateTime()();
  TextColumn get invoiceId => text().nullable()();
  TextColumn get billingStatus => text()(); // PENDING_BILLING, BILLED, EXEMPT
  TextColumn get paymentStatus => text().withDefault(const Constant('UNPAID'))();
  TextColumn get notes => text().nullable()();
  
  // Auditing & Audit Trails
  TextColumn get createdBy => text().withDefault(const Constant('system'))();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get updatedBy => text().withDefault(const Constant('system'))();
  DateTimeColumn get updatedAt => dateTime()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  TextColumn get tenantId => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
```

---

## Workflows

### 1. Recording a Delivery
When a Bowser operator delivers fuel at a site:
1. Operator records quantity, rate, customer, site, driver, and vehicle.
2. In the database transaction:
   - Create `FuelDelivery` record with `billingStatus = PENDING_BILLING`.
   - Create `InventoryMovement` (type: `deliveryOut`, source: `Bowser_Location_ID`, destination: `null`, reference: `FuelDelivery`).
   - If configured for instant billing, invoke `InvoiceService.createInvoiceFromDelivery(delivery)`.

### 2. Billing / Invoicing
When an invoice is generated from one or more delivery slips:
1. Set the delivery slips' `invoiceId` to the newly generated invoice's ID.
2. Set `billingStatus = BILLED`.
3. Invoices verify customer credit days and limits prior to completion.

import 'package:drift/drift.dart';

/// Drift table representing an enterprise Customer.
@DataClassName('CustomerRow')
class Customers extends Table {
  TextColumn get id => text()();
  TextColumn get customerCode => text().unique()();
  TextColumn get name => text()(); // Company Name
  TextColumn get displayName => text().nullable()();
  TextColumn get tradeName => text().nullable()();
  TextColumn get legalBusinessName => text().nullable()();
  TextColumn get customerType => text()(); // CORPORATE, CONSTRUCTION, INDUSTRIAL, GOVERNMENT, INDIVIDUAL
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  // GST & Compliance
  TextColumn get gstin => text().nullable()();
  TextColumn get pan => text().nullable()();
  TextColumn get state => text().nullable()();
  TextColumn get placeOfSupply => text().nullable()();
  TextColumn get gstRegistrationType => text().nullable()();
  TextColumn get tan => text().nullable()();

  // Billing Address
  TextColumn get billingAddressLine1 => text().nullable()();
  TextColumn get billingAddressLine2 => text().nullable()();
  TextColumn get billingArea => text().nullable()();
  TextColumn get billingCity => text().nullable()();
  TextColumn get billingState => text().nullable()();
  TextColumn get billingPincode => text().nullable()();
  TextColumn get billingCountry => text().nullable()();

  // Credit Info
  TextColumn get paymentTerms => text().nullable()(); // ADVANCE, DAYS7, DAYS15, DAYS30, DAYS45
  RealColumn get creditLimit => real().withDefault(const Constant(0.0))();
  IntColumn get creditDays => integer().withDefault(const Constant(30))();
  RealColumn get securityDeposit => real().withDefault(const Constant(0.0))();

  // Fuel Preferences
  TextColumn get fuelType => text().nullable()(); // DIESEL, PETROL
  RealColumn get defaultGstRate => real().withDefault(const Constant(0.18))();
  RealColumn get defaultPrice => real().nullable()();

  // PO Details
  TextColumn get poNumber => text().nullable()();
  DateTimeColumn get poDate => dateTime().nullable()();
  DateTimeColumn get poValidTill => dateTime().nullable()();
  RealColumn get poValue => real().nullable()();
  RealColumn get poRemainingBalance => real().nullable()();

  // Invoice Preferences
  TextColumn get invoicePrefix => text().nullable()();
  BoolColumn get emailInvoice => boolean().withDefault(const Constant(true))();
  BoolColumn get whatsappInvoice => boolean().withDefault(const Constant(false))();
  BoolColumn get requirePo => boolean().withDefault(const Constant(false))();
  BoolColumn get requireDc => boolean().withDefault(const Constant(false))();
  BoolColumn get requireSignature => boolean().withDefault(const Constant(false))();

  // Compliance Flags
  BoolColumn get gstApplicable => boolean().withDefault(const Constant(true))();
  BoolColumn get eInvoiceRequired => boolean().withDefault(const Constant(false))();
  BoolColumn get eWayBillRequired => boolean().withDefault(const Constant(false))();

  // Accounting
  RealColumn get openingBalance => real().withDefault(const Constant(0.0))();
  RealColumn get currentBalance => real().withDefault(const Constant(0.0))();
  DateTimeColumn get lastPaymentDate => dateTime().nullable()();
  DateTimeColumn get lastInvoiceDate => dateTime().nullable()();

  // Notes
  TextColumn get notes => text().nullable()();

  // Enterprise Auditing & Multi-Tenancy
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

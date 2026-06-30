import 'package:drift/drift.dart';

/// Drift table representing uploaded document attachments (Purchase bills, expense receipts, etc.)
@DataClassName('DocumentRow')
class Documents extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()(); // Filename e.g. "bill_123.jpg"
  TextColumn get localPath => text()(); // Local absolute file path
  TextColumn get fileExtension => text()(); // e.g. pdf, png, jpg
  IntColumn get sizeInBytes => integer()();
  TextColumn get category => text()(); // GST_CERTIFICATE, PAN_CARD, MSME_CERTIFICATE, AGREEMENT, PURCHASE_INVOICE, SALES_INVOICE, EXPENSE_BILL, OTHER
  TextColumn get parentType => text()(); // CUSTOMER, PURCHASE, INVOICE, EXPENSE, VEHICLE, DRIVER
  TextColumn get parentId => text()(); // FK to the corresponding parent UUID

  // Audits
  TextColumn get createdBy => text().withDefault(const Constant('system'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get tenantId => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

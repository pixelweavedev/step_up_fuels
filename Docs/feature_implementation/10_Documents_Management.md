# 10 — Document Management Design

## Overview
The Document Management module manages attachments and PDF generation outputs. Files are stored locally in the application's secure documents directory (`StepUpFuels/Documents/`) and mapped in the SQLite database to their parent entities (Customers, Purchases, Invoices, Expenses).

---

## Domain Entities

### DocumentAttachment
```dart
class DocumentAttachment {
  final String id;                    // UUID
  final String name;                  // File name e.g., "gst_certificate.pdf"
  final String localPath;             // Absolute path in the local filesystem
  final String fileExtension;         // pdf, png, jpg, jpeg
  final int sizeInBytes;
  final String category;              // GST_CERTIFICATE, PAN_CARD, MSME_CERTIFICATE, AGREEMENT, PURCHASE_INVOICE, SALES_INVOICE, EXPENSE_BILL, OTHER
  final String parentType;            // CUSTOMER, PURCHASE, INVOICE, EXPENSE
  final String parentId;              // FK (UUID of parent customer, invoice, etc.)

  // Auditing & SaaS Scope
  final String createdBy;
  final DateTime createdAt;
  final DateTime? deletedAt;
  final String? tenantId;
}
```

---

## Database Drift Schema Details

```dart
@DataClassName('DocumentRow')
class Documents extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get localPath => text()();
  TextColumn get fileExtension => text()();
  IntColumn get sizeInBytes => integer()();
  TextColumn get category => text()(); // GST_CERTIFICATE, PAN_CARD, etc.
  TextColumn get parentType => text()(); // CUSTOMER, PURCHASE, INVOICE, EXPENSE
  TextColumn get parentId => text()();

  // Auditing & SaaS
  TextColumn get createdBy => text().withDefault(const Constant('system'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get tenantId => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
```

---

## File Storage & Operations Pipeline

### DocumentStorageService
```dart
abstract class DocumentStorageService {
  /// Copies file from temp/user selection path into app's secure directory, then inserts database mapping.
  Future<Result<DocumentAttachment>> uploadDocument({
    required File file,
    required String category,
    required String parentType,
    required String parentId,
    required String userId,
  });

  /// Deletes reference from database and deletes physical file from local storage.
  Future<Result<void>> deleteDocument(String id);

  /// Retrieves document binary content.
  Future<Result<File>> getDocumentFile(String id);
}
```

### Storage Location Structure
Files are organized in sub-directories locally:
```
StepUpFuels/
└── Documents/
    ├── Customers/
    │   └── {customer_id}/
    │       ├── gst_cert.pdf
    │       └── pan_card.jpg
    ├── Invoices/
    │   └── {invoice_id}.pdf
    ├── Purchases/
    │   └── {purchase_id}/
    │       └── invoice_copy.pdf
    └── Expenses/
        └── {expense_id}/
            └── taxi_bill.png
```
This partition enables smooth cloud synchronization (e.g., uploading directory trees directly to AWS S3 / MinIO storage) in future enterprise SaaS iterations.

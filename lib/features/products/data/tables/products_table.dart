import 'package:drift/drift.dart';

/// Drift table representing a Product in the catalog.
@DataClassName('ProductRow')
class Products extends Table {
  TextColumn get id => text()();
  TextColumn get productCode => text().unique()(); // e.g. HSD-001
  TextColumn get name => text()(); // High Speed Diesel
  TextColumn get description => text().nullable()();
  TextColumn get hsnCode => text()(); // e.g. 2710
  TextColumn get unitOfMeasure => text()(); // KL, LTRS
  RealColumn get gstRate => real().withDefault(const Constant(0.18))(); // e.g. 0.18 for 18%
  RealColumn get cgstRate => real().withDefault(const Constant(0.09))();
  RealColumn get sgstRate => real().withDefault(const Constant(0.09))();
  RealColumn get igstRate => real().withDefault(const Constant(0.18))();
  RealColumn get currentSellingPrice => real().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  // Audits
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

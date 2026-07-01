import 'package:drift/drift.dart';
import 'package:step_up_fuels/app/database/app_database.dart';
import 'package:step_up_fuels/features/purchases/data/tables/purchase_items_table.dart';
import 'package:step_up_fuels/features/purchases/data/tables/purchases_table.dart';
import 'package:step_up_fuels/features/purchases/data/tables/suppliers_table.dart';

part 'purchases_dao.g.dart';

@DriftAccessor(tables: [Suppliers, FuelPurchases, FuelPurchaseItems])
class PurchasesDao extends DatabaseAccessor<AppDatabase> with _$PurchasesDaoMixin {
  PurchasesDao(super.db);

  // ── Suppliers CRUD ──────────────────────────────────────────────────────────

  Future<List<SupplierRow>> getAllSuppliers({bool includeDeleted = false}) async {
    if (includeDeleted) {
      return select(suppliers).get();
    } else {
      return (select(suppliers)..where((t) => t.deletedAt.isNull())).get();
    }
  }

  Future<SupplierRow?> getSupplierById(String id) async {
    return (select(suppliers)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<void> saveSupplier(SuppliersCompanion companion) async {
    await into(suppliers).insertOnConflictUpdate(companion);
  }

  Future<void> softDeleteSupplier(String id) async {
    await (update(suppliers)..where((t) => t.id.equals(id))).write(
      SuppliersCompanion(deletedAt: Value(DateTime.now())),
    );
  }

  // ── Fuel Purchases CRUD ──────────────────────────────────────────────────────

  Future<List<FuelPurchaseRow>> getAllPurchases({
    String? supplierId,
    DateTime? fromDate,
    DateTime? toDate,
    bool includeDeleted = false,
  }) async {
    final query = select(fuelPurchases);
    query.where((t) {
      Expression<bool> expr = const Constant(true);
      if (!includeDeleted) expr = expr & t.deletedAt.isNull();
      if (supplierId != null) expr = expr & t.supplierId.equals(supplierId);
      if (fromDate != null) expr = expr & t.purchaseDate.isBiggerOrEqualValue(fromDate);
      if (toDate != null) expr = expr & t.purchaseDate.isSmallerOrEqualValue(toDate);
      return expr;
    });
    query.orderBy([(t) => OrderingTerm.desc(t.purchaseDate)]);
    return query.get();
  }

  Future<FuelPurchaseRow?> getPurchaseById(String id) async {
    return (select(fuelPurchases)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<void> savePurchase(FuelPurchasesCompanion companion) async {
    await into(fuelPurchases).insertOnConflictUpdate(companion);
  }

  Future<void> softDeletePurchase(String id) async {
    await (update(fuelPurchases)..where((t) => t.id.equals(id))).write(
      FuelPurchasesCompanion(deletedAt: Value(DateTime.now())),
    );
  }

  // ── Fuel Purchase Items CRUD ─────────────────────────────────────────────────

  Future<List<FuelPurchaseItemRow>> getItemsByPurchaseId(String purchaseId) async {
    return (select(fuelPurchaseItems)
          ..where((t) => t.purchaseId.equals(purchaseId))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();
  }

  Future<void> savePurchaseItem(FuelPurchaseItemsCompanion companion) async {
    await into(fuelPurchaseItems).insertOnConflictUpdate(companion);
  }

  Future<void> deleteItemsByPurchaseId(String purchaseId) async {
    await (delete(fuelPurchaseItems)..where((t) => t.purchaseId.equals(purchaseId))).go();
  }

  // ── Serial Number Management ────────────────────────────────────────────────

  Future<int> readAndIncrementCounter() async {
    final row = await (select(db.appSettings)
          ..where((t) => t.key.equals('purchase_counter')))
        .getSingleOrNull();

    final current = int.tryParse(row?.value ?? '0') ?? 0;
    final next = current + 1;

    await into(db.appSettings).insertOnConflictUpdate(
      AppSettingsCompanion(
        key: const Value('purchase_counter'),
        value: Value(next.toString()),
      ),
    );

    return next;
  }
}

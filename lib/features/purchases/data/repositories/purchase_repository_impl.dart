import 'package:drift/drift.dart';
import 'package:step_up_fuels/app/database/app_database.dart';
import 'package:step_up_fuels/core/errors/failure.dart';
import 'package:step_up_fuels/core/result/result.dart';
import 'package:step_up_fuels/features/ledger/domain/repositories/ledger_repository.dart';
import 'package:step_up_fuels/features/purchases/data/daos/purchases_dao.dart';
import 'package:step_up_fuels/features/purchases/data/models/purchase_mapper.dart';
import 'package:step_up_fuels/features/purchases/data/models/supplier_mapper.dart';
import 'package:step_up_fuels/features/purchases/domain/entities/fuel_purchase.dart';
import 'package:step_up_fuels/features/purchases/domain/entities/fuel_purchase_item.dart';
import 'package:step_up_fuels/features/purchases/domain/entities/supplier.dart';
import 'package:step_up_fuels/features/purchases/domain/repositories/purchase_repository.dart';
import 'package:uuid/uuid.dart';

class PurchaseRepositoryImpl implements PurchaseRepository {
  PurchaseRepositoryImpl(this._dao, this._ledgerRepo);
  final PurchasesDao _dao;
  final LedgerRepository _ledgerRepo;
  final _uuid = const Uuid();

  @override
  Future<Result<List<Supplier>>> getSuppliers({
    bool includeDeleted = false,
  }) async {
    try {
      final rows = await _dao.getAllSuppliers(includeDeleted: includeDeleted);
      return Result.success(rows.map((r) => r.toDomain()).toList());
    } catch (e, st) {
      return Result.failure(
        DatabaseFailure(message: e.toString(), stackTrace: st),
      );
    }
  }

  Future<Result<Supplier>> getSupplierById(String id) async {
    try {
      final row = await _dao.getSupplierById(id);
      if (row == null) {
        return const Result.failure(
          DatabaseFailure(message: 'Supplier not found'),
        );
      }
      return Result.success(row.toDomain());
    } catch (e, st) {
      return Result.failure(
        DatabaseFailure(message: e.toString(), stackTrace: st),
      );
    }
  }

  @override
  Future<Result<void>> saveSupplier(Supplier supplier) async {
    try {
      await _dao.saveSupplier(supplier.toCompanion());
      return const Result.success(null);
    } catch (e, st) {
      return Result.failure(
        DatabaseFailure(message: e.toString(), stackTrace: st),
      );
    }
  }

  @override
  Future<Result<void>> softDeleteSupplier(String id) async {
    try {
      await _dao.softDeleteSupplier(id);
      return const Result.success(null);
    } catch (e, st) {
      return Result.failure(
        DatabaseFailure(message: e.toString(), stackTrace: st),
      );
    }
  }

  @override
  Future<Result<List<FuelPurchase>>> getPurchases({
    String? supplierId,
    DateTime? fromDate,
    DateTime? toDate,
    bool includeDeleted = false,
  }) async {
    try {
      final rows = await _dao.getAllPurchases(
        supplierId: supplierId,
        fromDate: fromDate,
        toDate: toDate,
        includeDeleted: includeDeleted,
      );
      return Result.success(rows.map((r) => r.toDomain()).toList());
    } catch (e, st) {
      return Result.failure(
        DatabaseFailure(message: e.toString(), stackTrace: st),
      );
    }
  }

  @override
  Future<Result<FuelPurchase>> getPurchaseById(String id) async {
    try {
      final row = await _dao.getPurchaseById(id);
      if (row == null) {
        return const Result.failure(
          DatabaseFailure(message: 'Purchase not found'),
        );
      }
      return Result.success(row.toDomain());
    } catch (e, st) {
      return Result.failure(
        DatabaseFailure(message: e.toString(), stackTrace: st),
      );
    }
  }

  @override
  Future<Result<List<FuelPurchaseItem>>> getPurchaseItems(
    String purchaseId,
  ) async {
    try {
      final rows = await _dao.getItemsByPurchaseId(purchaseId);
      return Result.success(rows.map((r) => r.toDomain()).toList());
    } catch (e, st) {
      return Result.failure(
        DatabaseFailure(message: e.toString(), stackTrace: st),
      );
    }
  }

  @override
  Future<Result<void>> savePurchase(
    FuelPurchase purchase,
    List<FuelPurchaseItem> items,
  ) async {
    try {
      final db = _dao.attachedDatabase;
      await db.transaction(() async {
        // 1. Resolve or generate purchase number if it is a new purchase and empty
        final existing = await _dao.getPurchaseById(purchase.id);
        final isNew = existing == null;

        String purchaseNumber = purchase.purchaseNumber;
        if (isNew && (purchaseNumber.isEmpty || purchaseNumber == 'PENDING')) {
          final counter = await _dao.readAndIncrementCounter();
          final now = DateTime.now();
          final fy = now.month >= 4
              ? '${now.year}-${(now.year + 1).toString().substring(2)}'
              : '${now.year - 1}-${now.year.toString().substring(2)}';
          purchaseNumber = 'PUR/$fy/${counter.toString().padLeft(4, '0')}';
        }

        final purchaseToSave = purchase.copyWith(
          purchaseNumber: purchaseNumber,
        );

        // 2. Save the purchase header
        await _dao.savePurchase(purchaseToSave.toCompanion());

        // 3. Delete old items & save new items
        await _dao.deleteItemsByPurchaseId(purchase.id);
        for (final item in items) {
          await _dao.savePurchaseItem(item.toCompanion());
        }

        // 4. Hook: Auto-log inventory movements for new purchase entries
        if (isNew) {
          // Resolve main storage location
          final mainLoc = await (db.select(
            db.storageLocations,
          )..where((t) => t.type.equals('MAIN_STORAGE'))).getSingleOrNull();

          String mainLocId;
          if (mainLoc == null) {
            mainLocId = 'main-storage-terminal';
            await db
                .into(db.storageLocations)
                .insertOnConflictUpdate(
                  StorageLocationsCompanion(
                    id: const Value('main-storage-terminal'),
                    name: const Value('Main Terminal Storage'),
                    type: const Value('MAIN_STORAGE'),
                    isActive: const Value(true),
                    createdAt: Value(DateTime.now()),
                    createdBy: Value(purchase.createdBy),
                    updatedAt: Value(DateTime.now()),
                    updatedBy: Value(purchase.createdBy),
                    version: const Value(1),
                  ),
                );
          } else {
            mainLocId = mainLoc.id;
          }

          // Record a movement for each item purchased
          for (final item in items) {
            final movementCompanion = InventoryMovementsCompanion(
              id: Value(_uuid.v4()),
              productId: Value(item.productId),
              sourceLocationId: const Value(null),
              destinationLocationId: Value(mainLocId),
              type: const Value('PURCHASE_IN'),
              quantity: Value(item.quantity),
              referenceId: Value(purchase.id),
              referenceType: const Value('PURCHASE'),
              movementDate: Value(purchase.purchaseDate),
              notes: Value(
                'Fuel Purchase: $purchaseNumber from ${purchase.supplierId}',
              ),
              createdAt: Value(DateTime.now()),
              createdBy: Value(purchase.createdBy),
            );
            await db
                .into(db.inventoryMovements)
                .insertOnConflictUpdate(movementCompanion);
          }

          // Double-entry postings
          final supplierRow = await (db.select(
            db.suppliers,
          )..where((t) => t.id.equals(purchase.supplierId))).getSingleOrNull();
          if (supplierRow == null) throw Exception('Supplier not found');

          final supplierLedgerRes = await _ledgerRepo
              .getOrCreateSupplierAccount(
                supplierRow.id,
                supplierRow.name,
                supplierRow.supplierCode,
              );
          final supplierLedger = supplierLedgerRes.dataOrThrow;

          final purchaseLedgerRes = await _ledgerRepo.getOrCreateSystemAccount(
            'ACT-PURCHASE',
            'Purchase Account',
            'PURCHASE',
          );
          final purchaseLedger = purchaseLedgerRes.dataOrThrow;

          // Debit Purchase Account
          final debitRes = await _ledgerRepo.postEntry(
            accountId: purchaseLedger.id,
            entryDate: purchase.purchaseDate,
            description:
                'Fuel Purchase Recorded: $purchaseNumber from ${supplierRow.name}',
            debit: purchase.totalAmount,
            credit: 0.0,
            referenceId: purchase.id,
            referenceType: 'PURCHASE',
            createdBy: purchase.createdBy,
          );
          if (debitRes.isFailure) {
            throw Exception(debitRes.failureOrNull?.message);
          }

          // Credit Supplier Account
          final creditRes = await _ledgerRepo.postEntry(
            accountId: supplierLedger.id,
            entryDate: purchase.purchaseDate,
            description:
                'Fuel Purchase Recorded: $purchaseNumber from ${supplierRow.name}',
            debit: 0.0,
            credit: purchase.totalAmount,
            referenceId: purchase.id,
            referenceType: 'PURCHASE',
            createdBy: purchase.createdBy,
          );
          if (creditRes.isFailure) {
            throw Exception(creditRes.failureOrNull?.message);
          }
        }
      });
      return const Result.success(null);
    } catch (e, st) {
      return Result.failure(
        DatabaseFailure(message: e.toString(), stackTrace: st),
      );
    }
  }

  @override
  Future<Result<void>> softDeletePurchase(String id) async {
    try {
      await _dao.softDeletePurchase(id);
      return const Result.success(null);
    } catch (e, st) {
      return Result.failure(
        DatabaseFailure(message: e.toString(), stackTrace: st),
      );
    }
  }
}

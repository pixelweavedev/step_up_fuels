import 'package:step_up_fuels/core/result/result.dart';
import 'package:step_up_fuels/features/purchases/domain/entities/fuel_purchase.dart';
import 'package:step_up_fuels/features/purchases/domain/entities/fuel_purchase_item.dart';
import 'package:step_up_fuels/features/purchases/domain/entities/supplier.dart';

abstract class PurchaseRepository {
  // Suppliers
  Future<Result<List<Supplier>>> getSuppliers({bool includeDeleted = false});
  Future<Result<void>> saveSupplier(Supplier supplier);
  Future<Result<void>> softDeleteSupplier(String id);

  // Fuel Purchases
  Future<Result<List<FuelPurchase>>> getPurchases({
    String? supplierId,
    DateTime? fromDate,
    DateTime? toDate,
    bool includeDeleted = false,
  });
  Future<Result<FuelPurchase>> getPurchaseById(String id);
  Future<Result<List<FuelPurchaseItem>>> getPurchaseItems(String purchaseId);
  Future<Result<void>> savePurchase(FuelPurchase purchase, List<FuelPurchaseItem> items);
  Future<Result<void>> softDeletePurchase(String id);
}

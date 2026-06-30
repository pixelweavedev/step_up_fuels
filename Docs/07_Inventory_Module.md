# 07 — Inventory Module

## Overview

Inventory is calculated from movements — there is no raw quantity field.
This means the system always has a full audit trail and can answer questions
like "how much did we dispense in June?" or "when did stock drop below 5000 KL?"

---

## Entities

### Stock (computed, not stored)
```dart
class Stock {
  final String productId;
  final String productName;
  final String unit;
  final double currentQuantity;   // computed from movements
  final DateTime lastUpdated;
}
```

### InventoryMovement
```dart
class InventoryMovement {
  final String id;
  final String productId;
  final MovementType type;
  final double quantity;    // always positive
  final String? referenceId;
  final ReferenceType? referenceType;
  final DateTime movementDate;
  final String? notes;
}
```

### StockAdjustment
```dart
class StockAdjustment {
  final String id;
  final String productId;
  final AdjustmentType type;  // gain, loss, physicalCount
  final double quantity;
  final String reason;
  final DateTime adjustmentDate;
}
```

---

## Enums

```dart
enum MovementType {
  purchaseIn,       // Stock coming in from a purchase
  invoiceOut,       // Stock going out via an invoice
  adjustmentIn,     // Manual adjustment (gain)
  adjustmentOut,    // Manual adjustment (loss)
  openingStock,     // Initial stock entry
}

enum AdjustmentType { gain, loss, physicalCount }
```

---

## InventoryService (Domain Service)

```dart
abstract class InventoryService {
  /// Returns the current stock for a product.
  Future<Result<double>> getCurrentStock(String productId);

  /// Records a movement (called by PurchaseService and InvoiceService).
  Future<Result<void>> recordMovement(InventoryMovement movement);

  /// Records a manual adjustment (creates both adjustment record + movement).
  Future<Result<void>> recordAdjustment(StockAdjustment adjustment);

  /// Sets the opening stock for a product.
  Future<Result<void>> setOpeningStock({
    required String productId,
    required double quantity,
    required DateTime asOf,
  });
}
```

---

## Stock Calculation Query

```sql
SELECT 
  SUM(
    CASE 
      WHEN movement_type IN ('PURCHASE_IN', 'ADJUSTMENT_IN', 'OPENING_STOCK') 
        THEN quantity
      WHEN movement_type IN ('INVOICE_OUT', 'ADJUSTMENT_OUT') 
        THEN -quantity
    END
  ) AS current_stock
FROM inventory_movements
WHERE product_id = ?
```

---

## UI Screens

### Inventory Overview Screen
- Current stock per product (large number display)
- Low stock warnings (below configurable threshold)
- Quick action: Record Adjustment, Set Opening Stock

### Inventory Movement History Screen
- Filterable by product, movement type, date range
- Shows reference link (opens linked invoice/purchase)
- Export to Excel

### Stock Adjustment Screen
- Select product
- Adjustment type (Gain / Loss)
- Quantity and reason
- Confirmation with updated stock preview

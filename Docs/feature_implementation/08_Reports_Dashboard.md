# 08 — Reports & Dashboard Design

## Overview
Reports & Dashboard provides insights into operational metrics, sales performance, fuel stock levels, expenses, outstanding payments, and GST compliance. Data is computed on-demand directly from transactional tables (`invoices`, `payments`, `fuel_deliveries`, `inventory_movements`, `expenses`).

---

## Domain Analytics Models

### ReportModels

#### SalesSummary
```dart
class SalesSummary {
  final double totalLitres;
  final double taxableAmount;
  final double cgstAmount;
  final double sgstAmount;
  final double igstAmount;
  final double totalAmount;
  final double totalOutstanding;
}
```

#### ProfitLossEstimate
```dart
class ProfitLossEstimate {
  final DateTime startDate;
  final DateTime endDate;
  final double revenue;           // Sales Invoice Subtotal
  final double costOfFuelSold;    // Cost from purchases (FIFO/Weighted Average)
  final double operatingExpenses; // Direct + Indirect expenses (salary, maintenance, etc.)
  final double estimatedNetProfit;// revenue - costOfFuelSold - operatingExpenses
}
```

#### CustomerOutstandingAging
```dart
class CustomerOutstandingAging {
  final String customerId;
  final String customerName;
  final double current;           // 0-7 days
  final double tier1;              // 8-15 days
  final double tier2;              // 16-30 days
  final double tier3;              // 31-45 days
  final double overdue;           // 45+ days
  final double totalOutstanding;
}
```

---

## Business Logic Services

### ReportingService
Interface for compiling analytical reports:
```dart
abstract class ReportingService {
  Future<Result<SalesSummary>> getDailySales(DateTime date);
  Future<Result<Map<String, SalesSummary>>> getMonthlySales(int year);
  Future<Result<Map<String, SalesSummary>>> getCustomerWiseSales({required DateTime start, required DateTime end});
  Future<Result<List<FuelPurchaseReportRow>>> getPurchaseReport({required DateTime start, required DateTime end});
  Future<Result<List<StockStatusRow>>> getStockReport();
  Future<Result<Map<String, double>>> getExpenseReport({required DateTime start, required DateTime end, String? vehicleId});
  Future<Result<ProfitLossEstimate>> getProfitLossEstimate({required DateTime start, required DateTime end});
  Future<Result<List<CustomerOutstandingAging>>> getOutstandingReport();
  Future<Result<GstReport>> getGstReport({required DateTime start, required DateTime end});
}
```

### DashboardService
Interface for populating dashboard counters:
```dart
abstract class DashboardService {
  Future<Result<DashboardStats>> getTodayStats();
}

class DashboardStats {
  final double todaySalesLitres;
  final double todaySalesValue;
  final int todayDeliveriesCount;
  final double totalOutstandingReceivables;
  final double mainStorageStock;
  final Map<String, double> bowserStockLevels; // Bowser Name -> Litres
  final int totalActiveCustomers;
  final double currentMonthRevenue;
  final List<InvoiceListItem> recentInvoices;
  final List<LowStockAlert> lowStockAlerts;
}

class LowStockAlert {
  final String locationName;
  final String productName;
  final double currentStock;
  final double threshold;
}
```

---

## UI Components & Export Pipeline
- **Charts**: Built using `fl_chart` for visualizing sales trends (bar chart) and expense breakdown (pie chart).
- **Exporting**:
  - **Excel Export**: Powered by `excel` package for exporting GSTR-1 returns, customer ledger statement, and general reports.
  - **PDF Export**: Uses `pdf` and `printing` to compile clean, print-ready reports with tables and branding.

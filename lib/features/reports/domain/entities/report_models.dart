import 'package:step_up_fuels/features/invoices/domain/entities/invoice.dart';

class SalesSummary {
  final double totalLitres;
  final double taxableAmount;
  final double cgstAmount;
  final double sgstAmount;
  final double igstAmount;
  final double totalAmount;
  final double totalOutstanding;

  const SalesSummary({
    required this.totalLitres,
    required this.taxableAmount,
    required this.cgstAmount,
    required this.sgstAmount,
    required this.igstAmount,
    required this.totalAmount,
    required this.totalOutstanding,
  });
}

class ProfitLossEstimate {
  final DateTime startDate;
  final DateTime endDate;
  final double revenue;
  final double costOfFuelSold;
  final double operatingExpenses;
  final double estimatedNetProfit;

  const ProfitLossEstimate({
    required this.startDate,
    required this.endDate,
    required this.revenue,
    required this.costOfFuelSold,
    required this.operatingExpenses,
    required this.estimatedNetProfit,
  });
}

class CustomerOutstandingAging {
  final String customerId;
  final String customerName;
  final double current; // 0-7 days
  final double tier1; // 8-15 days
  final double tier2; // 16-30 days
  final double tier3; // 31-45 days
  final double overdue; // 45+ days
  final double totalOutstanding;

  const CustomerOutstandingAging({
    required this.customerId,
    required this.customerName,
    required this.current,
    required this.tier1,
    required this.tier2,
    required this.tier3,
    required this.overdue,
    required this.totalOutstanding,
  });
}

class FuelPurchaseReportRow {
  final String id;
  final String purchaseNumber;
  final String supplierName;
  final String supplierInvoiceNo;
  final DateTime purchaseDate;
  final double subtotal;
  final double cgstAmount;
  final double sgstAmount;
  final double igstAmount;
  final double totalAmount;

  const FuelPurchaseReportRow({
    required this.id,
    required this.purchaseNumber,
    required this.supplierName,
    required this.supplierInvoiceNo,
    required this.purchaseDate,
    required this.subtotal,
    required this.cgstAmount,
    required this.sgstAmount,
    required this.igstAmount,
    required this.totalAmount,
  });
}

class StockStatusRow {
  final String locationId;
  final String locationName;
  final String locationType;
  final String productId;
  final String productName;
  final double currentStock;

  const StockStatusRow({
    required this.locationId,
    required this.locationName,
    required this.locationType,
    required this.productId,
    required this.productName,
    required this.currentStock,
  });
}

class GstB2BRow {
  final String invoiceId;
  final String invoiceNumber;
  final DateTime invoiceDate;
  final String customerName;
  final String? customerGstin;
  final double taxableValue;
  final double cgstAmount;
  final double sgstAmount;
  final double igstAmount;
  final double totalAmount;

  const GstB2BRow({
    required this.invoiceId,
    required this.invoiceNumber,
    required this.invoiceDate,
    required this.customerName,
    this.customerGstin,
    required this.taxableValue,
    required this.cgstAmount,
    required this.sgstAmount,
    required this.igstAmount,
    required this.totalAmount,
  });
}

class GstHsnSummaryRow {
  final String hsnCode;
  final String description;
  final String unit;
  final double totalQuantity;
  final double totalValue;
  final double taxableValue;
  final double cgstAmount;
  final double sgstAmount;
  final double igstAmount;

  const GstHsnSummaryRow({
    required this.hsnCode,
    required this.description,
    required this.unit,
    required this.totalQuantity,
    required this.totalValue,
    required this.taxableValue,
    required this.cgstAmount,
    required this.sgstAmount,
    required this.igstAmount,
  });
}

class GstReport {
  final DateTime startDate;
  final DateTime endDate;
  final List<GstB2BRow> b2bInvoices;
  final List<GstHsnSummaryRow> hsnSummary;

  const GstReport({
    required this.startDate,
    required this.endDate,
    required this.b2bInvoices,
    required this.hsnSummary,
  });
}

class LowStockAlert {
  final String locationId;
  final String locationName;
  final String productName;
  final double currentStock;
  final double threshold;

  const LowStockAlert({
    required this.locationId,
    required this.locationName,
    required this.productName,
    required this.currentStock,
    required this.threshold,
  });
}

class DashboardStats {
  final double todaySalesLitres;
  final double todaySalesValue;
  final int todayDeliveriesCount;
  final double totalOutstandingReceivables;
  final double mainStorageStock;
  final Map<String, double> bowserStockLevels;
  final int totalActiveCustomers;
  final double currentMonthRevenue;
  final List<Invoice> recentInvoices;
  final List<LowStockAlert> lowStockAlerts;

  const DashboardStats({
    required this.todaySalesLitres,
    required this.todaySalesValue,
    required this.todayDeliveriesCount,
    required this.totalOutstandingReceivables,
    required this.mainStorageStock,
    required this.bowserStockLevels,
    required this.totalActiveCustomers,
    required this.currentMonthRevenue,
    required this.recentInvoices,
    required this.lowStockAlerts,
  });
}

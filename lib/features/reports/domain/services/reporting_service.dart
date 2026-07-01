import 'package:step_up_fuels/core/result/result.dart';
import 'package:step_up_fuels/features/reports/domain/entities/report_models.dart';

abstract class ReportingService {
  Future<Result<SalesSummary>> getDailySales(DateTime date);
  
  Future<Result<Map<String, SalesSummary>>> getMonthlySales(int year);
  
  Future<Result<Map<String, SalesSummary>>> getCustomerWiseSales({
    required DateTime start,
    required DateTime end,
  });
  
  Future<Result<List<FuelPurchaseReportRow>>> getPurchaseReport({
    required DateTime start,
    required DateTime end,
  });
  
  Future<Result<List<StockStatusRow>>> getStockReport();
  
  Future<Result<Map<String, double>>> getExpenseReport({
    required DateTime start,
    required DateTime end,
    String? vehicleId,
  });
  
  Future<Result<ProfitLossEstimate>> getProfitLossEstimate({
    required DateTime start,
    required DateTime end,
  });
  
  Future<Result<List<CustomerOutstandingAging>>> getOutstandingReport();
  
  Future<Result<GstReport>> getGstReport({
    required DateTime start,
    required DateTime end,
  });
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:step_up_fuels/app/di/injection_container.dart';
import 'package:step_up_fuels/features/reports/domain/entities/report_models.dart';
import 'package:step_up_fuels/features/reports/domain/services/reporting_service.dart';

// ── Date and Report Selectors ──────────────────────────────────────────────────

final reportDateFromProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month); // Start of current month
});

final reportDateToProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});

final reportSelectedTypeProvider = StateProvider<String>((ref) => 'sales');

final reportSelectedVehicleFilterProvider = StateProvider<String?>(
  (ref) => null,
);

// ── Reporting Future Providers ────────────────────────────────────────────────

final customerWiseSalesProvider = FutureProvider<Map<String, SalesSummary>>((
  ref,
) async {
  final start = ref.watch(reportDateFromProvider);
  final end = ref.watch(reportDateToProvider);

  final reportingService = sl<ReportingService>();
  final result = await reportingService.getCustomerWiseSales(
    start: start,
    end: end,
  );
  return result.when(
    success: (data) => data,
    failure: (f) => throw Exception(f.userMessage),
  );
});

final purchaseReportProvider = FutureProvider<List<FuelPurchaseReportRow>>((
  ref,
) async {
  final start = ref.watch(reportDateFromProvider);
  final end = ref.watch(reportDateToProvider);

  final reportingService = sl<ReportingService>();
  final result = await reportingService.getPurchaseReport(
    start: start,
    end: end,
  );
  return result.when(
    success: (data) => data,
    failure: (f) => throw Exception(f.userMessage),
  );
});

final stockReportProvider = FutureProvider<List<StockStatusRow>>((ref) async {
  final reportingService = sl<ReportingService>();
  final result = await reportingService.getStockReport();
  return result.when(
    success: (data) => data,
    failure: (f) => throw Exception(f.userMessage),
  );
});

final expenseReportProvider = FutureProvider<Map<String, double>>((ref) async {
  final start = ref.watch(reportDateFromProvider);
  final end = ref.watch(reportDateToProvider);
  final vehicleId = ref.watch(reportSelectedVehicleFilterProvider);

  final reportingService = sl<ReportingService>();
  final result = await reportingService.getExpenseReport(
    start: start,
    end: end,
    vehicleId: vehicleId,
  );
  return result.when(
    success: (data) => data,
    failure: (f) => throw Exception(f.userMessage),
  );
});

final profitLossEstimateProvider = FutureProvider<ProfitLossEstimate>((
  ref,
) async {
  final start = ref.watch(reportDateFromProvider);
  final end = ref.watch(reportDateToProvider);

  final reportingService = sl<ReportingService>();
  final result = await reportingService.getProfitLossEstimate(
    start: start,
    end: end,
  );
  return result.when(
    success: (data) => data,
    failure: (f) => throw Exception(f.userMessage),
  );
});

final outstandingReportProvider =
    FutureProvider<List<CustomerOutstandingAging>>((ref) async {
      final reportingService = sl<ReportingService>();
      final result = await reportingService.getOutstandingReport();
      return result.when(
        success: (data) => data,
        failure: (f) => throw Exception(f.userMessage),
      );
    });

final gstReportProvider = FutureProvider<GstReport>((ref) async {
  final start = ref.watch(reportDateFromProvider);
  final end = ref.watch(reportDateToProvider);

  final reportingService = sl<ReportingService>();
  final result = await reportingService.getGstReport(start: start, end: end);
  return result.when(
    success: (data) => data,
    failure: (f) => throw Exception(f.userMessage),
  );
});

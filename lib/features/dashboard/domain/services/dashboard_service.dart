import 'package:step_up_fuels/core/result/result.dart';
import 'package:step_up_fuels/features/reports/domain/entities/report_models.dart';

abstract class DashboardService {
  Future<Result<DashboardStats>> getTodayStats();
}

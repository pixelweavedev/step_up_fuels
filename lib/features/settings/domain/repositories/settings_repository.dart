import 'package:step_up_fuels/core/result/result.dart';
import 'package:step_up_fuels/features/settings/domain/entities/company_profile.dart';
import 'package:step_up_fuels/features/settings/domain/entities/invoice_settings.dart';
import 'package:step_up_fuels/features/settings/domain/entities/print_settings.dart';

abstract class SettingsRepository {
  Future<Result<CompanyProfile>> getCompanyProfile();
  Future<Result<void>> saveCompanyProfile(CompanyProfile profile);
  Future<Result<InvoiceSettings>> getInvoiceSettings();
  Future<Result<void>> saveInvoiceSettings(InvoiceSettings settings);
  Future<Result<PrintSettings>> getPrintSettings();
  Future<Result<void>> savePrintSettings(PrintSettings settings);
  Future<Result<void>> backupDatabase(String destinationPath);
  Future<Result<void>> restoreDatabase(String sourcePath);
}

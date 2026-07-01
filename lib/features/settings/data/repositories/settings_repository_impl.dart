import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:step_up_fuels/app/database/app_database.dart';
import 'package:step_up_fuels/core/errors/failure.dart';
import 'package:step_up_fuels/core/result/result.dart';
import 'package:step_up_fuels/features/settings/domain/entities/company_profile.dart';
import 'package:step_up_fuels/features/settings/domain/entities/invoice_settings.dart';
import 'package:step_up_fuels/features/settings/domain/entities/print_settings.dart';
import 'package:step_up_fuels/features/settings/domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final AppDatabase _db;

  SettingsRepositoryImpl(this._db);

  static const _keyCompanyProfile = 'company_profile_json';
  static const _keyInvoiceSettings = 'invoice_settings_json';
  static const _keyPrintSettings = 'print_settings_json';

  @override
  Future<Result<CompanyProfile>> getCompanyProfile() async {
    try {
      final jsonStr = await _db.getSetting(_keyCompanyProfile);
      if (jsonStr == null || jsonStr.trim().isEmpty) {
        return Result.success(CompanyProfile.empty());
      }
      final decoded = json.decode(jsonStr) as Map<String, dynamic>;
      return Result.success(CompanyProfile.fromJson(decoded));
    } catch (e) {
      return Result.failure(DatabaseFailure(message: 'Failed to load company profile settings: $e'));
    }
  }

  @override
  Future<Result<void>> saveCompanyProfile(CompanyProfile profile) async {
    try {
      final jsonStr = json.encode(profile.toJson());
      await _db.setSetting(_keyCompanyProfile, jsonStr);
      return const Result.success(null);
    } catch (e) {
      return Result.failure(DatabaseFailure(message: 'Failed to save company profile settings: $e'));
    }
  }

  @override
  Future<Result<InvoiceSettings>> getInvoiceSettings() async {
    try {
      final jsonStr = await _db.getSetting(_keyInvoiceSettings);
      if (jsonStr == null || jsonStr.trim().isEmpty) {
        return Result.success(InvoiceSettings.defaultSettings());
      }
      final decoded = json.decode(jsonStr) as Map<String, dynamic>;
      return Result.success(InvoiceSettings.fromJson(decoded));
    } catch (e) {
      return Result.failure(DatabaseFailure(message: 'Failed to load invoice settings: $e'));
    }
  }

  @override
  Future<Result<void>> saveInvoiceSettings(InvoiceSettings settings) async {
    try {
      final jsonStr = json.encode(settings.toJson());
      await _db.setSetting(_keyInvoiceSettings, jsonStr);
      return const Result.success(null);
    } catch (e) {
      return Result.failure(DatabaseFailure(message: 'Failed to save invoice settings: $e'));
    }
  }

  @override
  Future<Result<PrintSettings>> getPrintSettings() async {
    try {
      final jsonStr = await _db.getSetting(_keyPrintSettings);
      if (jsonStr == null || jsonStr.trim().isEmpty) {
        return Result.success(PrintSettings.defaultSettings());
      }
      final decoded = json.decode(jsonStr) as Map<String, dynamic>;
      return Result.success(PrintSettings.fromJson(decoded));
    } catch (e) {
      return Result.failure(DatabaseFailure(message: 'Failed to load print settings: $e'));
    }
  }

  @override
  Future<Result<void>> savePrintSettings(PrintSettings settings) async {
    try {
      final jsonStr = json.encode(settings.toJson());
      await _db.setSetting(_keyPrintSettings, jsonStr);
      return const Result.success(null);
    } catch (e) {
      return Result.failure(DatabaseFailure(message: 'Failed to save print settings: $e'));
    }
  }

  @override
  Future<Result<void>> backupDatabase(String destinationPath) async {
    try {
      final dbFolder = await getApplicationDocumentsDirectory();
      final activeDbFile = File(p.join(dbFolder.path, 'StepUpFuels', 'step_up_fuels.db'));
      if (!await activeDbFile.exists()) {
        return const Result.failure(UnexpectedFailure(message: 'Active database file does not exist at expected path.'));
      }
      // Ensure target directory exists
      final destFile = File(destinationPath);
      final destDir = destFile.parent;
      if (!await destDir.exists()) {
        await destDir.create(recursive: true);
      }
      await activeDbFile.copy(destinationPath);
      return const Result.success(null);
    } catch (e) {
      return Result.failure(UnexpectedFailure(message: 'Database backup operation failed: $e'));
    }
  }

  @override
  Future<Result<void>> restoreDatabase(String sourcePath) async {
    try {
      final sourceFile = File(sourcePath);
      if (!await sourceFile.exists()) {
        return Result.failure(UnexpectedFailure(message: 'Backup source file does not exist at: $sourcePath'));
      }
      final dbFolder = await getApplicationDocumentsDirectory();
      final activeDbFile = File(p.join(dbFolder.path, 'StepUpFuels', 'step_up_fuels.db'));
      
      // Close the database connection to release lock
      await _db.close();
      
      // Copy backup over active database
      await sourceFile.copy(activeDbFile.path);
      return const Result.success(null);
    } catch (e) {
      return Result.failure(UnexpectedFailure(message: 'Database restore operation failed: $e'));
    }
  }
}

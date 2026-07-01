import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:step_up_fuels/app/di/injection_container.dart';
import 'package:step_up_fuels/core/result/result.dart';
import 'package:step_up_fuels/features/settings/domain/entities/company_profile.dart';
import 'package:step_up_fuels/features/settings/domain/entities/invoice_settings.dart';
import 'package:step_up_fuels/features/settings/domain/entities/print_settings.dart';
import 'package:step_up_fuels/features/settings/domain/repositories/settings_repository.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return sl<SettingsRepository>();
});

class CompanyProfileNotifier extends AsyncNotifier<CompanyProfile> {
  @override
  FutureOr<CompanyProfile> build() async {
    final repo = ref.read(settingsRepositoryProvider);
    final res = await repo.getCompanyProfile();
    return res.dataOrNull ?? CompanyProfile.empty();
  }

  Future<Result<void>> saveProfile(CompanyProfile profile) async {
    final repo = ref.read(settingsRepositoryProvider);
    final res = await repo.saveCompanyProfile(profile);
    if (res.isSuccess) {
      ref.invalidateSelf();
      await future;
    }
    return res;
  }
}

final companyProfileProvider =
    AsyncNotifierProvider<CompanyProfileNotifier, CompanyProfile>(
  CompanyProfileNotifier.new,
);

class InvoiceSettingsNotifier extends AsyncNotifier<InvoiceSettings> {
  @override
  FutureOr<InvoiceSettings> build() async {
    final repo = ref.read(settingsRepositoryProvider);
    final res = await repo.getInvoiceSettings();
    return res.dataOrNull ?? InvoiceSettings.defaultSettings();
  }

  Future<Result<void>> saveSettings(InvoiceSettings settings) async {
    final repo = ref.read(settingsRepositoryProvider);
    final res = await repo.saveInvoiceSettings(settings);
    if (res.isSuccess) {
      ref.invalidateSelf();
      await future;
    }
    return res;
  }
}

final invoiceSettingsProvider =
    AsyncNotifierProvider<InvoiceSettingsNotifier, InvoiceSettings>(
  InvoiceSettingsNotifier.new,
);

class PrintSettingsNotifier extends AsyncNotifier<PrintSettings> {
  @override
  FutureOr<PrintSettings> build() async {
    final repo = ref.read(settingsRepositoryProvider);
    final res = await repo.getPrintSettings();
    return res.dataOrNull ?? PrintSettings.defaultSettings();
  }

  Future<Result<void>> saveSettings(PrintSettings settings) async {
    final repo = ref.read(settingsRepositoryProvider);
    final res = await repo.savePrintSettings(settings);
    if (res.isSuccess) {
      ref.invalidateSelf();
      await future;
    }
    return res;
  }
}

final printSettingsProvider =
    AsyncNotifierProvider<PrintSettingsNotifier, PrintSettings>(
  PrintSettingsNotifier.new,
);

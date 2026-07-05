import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:step_up_fuels/app/database/app_database.dart';
import 'package:step_up_fuels/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:step_up_fuels/features/settings/domain/entities/company_profile.dart';
import 'package:step_up_fuels/features/settings/domain/entities/invoice_settings.dart';
import 'package:step_up_fuels/features/settings/domain/entities/print_settings.dart';

void main() {
  late AppDatabase db;
  late SettingsRepositoryImpl repository;
  late Directory tempDir;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = SettingsRepositoryImpl(db);
    tempDir = await Directory.systemTemp.createTemp('step_up_fuels_test');

    // Register MethodChannel mock for path_provider
    TestWidgetsFlutterBinding.ensureInitialized();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (MethodCall methodCall) async {
            if (methodCall.method == 'getApplicationDocumentsDirectory') {
              return tempDir.path;
            }
            return null;
          },
        );
  });

  tearDown(() async {
    await db.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('Settings Module Integration Tests', () {
    test(
      'should save and load company profile configuration correctly',
      () async {
        // 1. Uninitialized state: should return empty profile
        final initialRes = await repository.getCompanyProfile();
        expect(initialRes.isSuccess, isTrue);
        expect(initialRes.dataOrThrow.companyName, isEmpty);

        // 2. Save new profile
        const profile = CompanyProfile(
          companyName: 'Giga Fuel Ltd',
          gstin: '27AAAAA1111A1Z1',
          pan: 'AAAAA1111A',
          email: 'info@gigafuel.com',
          phone: '9988776655',
          address: '12 Plot, Industrial Zone',
          bankName: 'HDFC Bank',
          bankBranch: 'Main Branch',
          bankAccountNo: '50100200300',
          bankIfsc: 'HDFC0000001',
        );

        final saveRes = await repository.saveCompanyProfile(profile);
        expect(saveRes.isSuccess, isTrue);

        // 3. Load profile back and assert match
        final loadRes = await repository.getCompanyProfile();
        expect(loadRes.isSuccess, isTrue);
        final loaded = loadRes.dataOrThrow;
        expect(loaded.companyName, 'Giga Fuel Ltd');
        expect(loaded.gstin, '27AAAAA1111A1Z1');
        expect(loaded.pan, 'AAAAA1111A');
        expect(loaded.bankIfsc, 'HDFC0000001');
      },
    );

    test('should save and load invoice sequence settings correctly', () async {
      // 1. Uninitialized state: should return defaults
      final initialRes = await repository.getInvoiceSettings();
      expect(initialRes.isSuccess, isTrue);
      expect(initialRes.dataOrThrow.prefix, 'SUF');
      expect(initialRes.dataOrThrow.startingNumber, 1);

      // 2. Save settings
      const settings = InvoiceSettings(
        prefix: 'EXP',
        startingNumber: 105,
        termsAndConditions: 'Rules of sales',
        authorizedSignatoryName: 'Super Manager',
      );

      final saveRes = await repository.saveInvoiceSettings(settings);
      expect(saveRes.isSuccess, isTrue);

      // 3. Load back
      final loadRes = await repository.getInvoiceSettings();
      expect(loadRes.isSuccess, isTrue);
      expect(loadRes.dataOrThrow.prefix, 'EXP');
      expect(loadRes.dataOrThrow.startingNumber, 105);
      expect(loadRes.dataOrThrow.authorizedSignatoryName, 'Super Manager');
    });

    test('should save and load print layout margins correctly', () async {
      // 1. Uninitialized state: should return defaults
      final initialRes = await repository.getPrintSettings();
      expect(initialRes.isSuccess, isTrue);
      expect(initialRes.dataOrThrow.paperSize, 'A4');
      expect(initialRes.dataOrThrow.marginTop, 20.0);

      // 2. Save settings
      const print = PrintSettings(
        paperSize: 'LETTER',
        marginTop: 15.0,
        marginBottom: 15.0,
        marginLeft: 10.0,
        marginRight: 10.0,
      );

      final saveRes = await repository.savePrintSettings(print);
      expect(saveRes.isSuccess, isTrue);

      // 3. Load back
      final loadRes = await repository.getPrintSettings();
      expect(loadRes.isSuccess, isTrue);
      expect(loadRes.dataOrThrow.paperSize, 'LETTER');
      expect(loadRes.dataOrThrow.marginTop, 15.0);
      expect(loadRes.dataOrThrow.marginLeft, 10.0);
    });

    test(
      'should execute database backup and restore operations correctly',
      () async {
        // 1. Write dummy key-value configuration setting in active DB
        await db.setSetting('test_active_key', 'Active Value');

        // 2. Build connection directory layout
        final dbFolder = tempDir.path;
        final dbDir = Directory(p.join(dbFolder, 'StepUpFuels'));
        await dbDir.create(recursive: true);

        // 3. Create active SQLite database mock file
        final activeFile = File(p.join(dbDir.path, 'step_up_fuels.db'));
        await activeFile.writeAsString('SQLITE DUMMY DATA HEADER');

        // 4. Trigger Backup
        final backupFilePath = p.join(tempDir.path, 'backup_store.db');
        final backupRes = await repository.backupDatabase(backupFilePath);
        expect(backupRes.isSuccess, isTrue);

        // Verify backup file was created and contains matches
        final backupFile = File(backupFilePath);
        expect(await backupFile.exists(), isTrue);
        expect(await backupFile.readAsString(), 'SQLITE DUMMY DATA HEADER');

        // 5. Modify active DB source file data
        await activeFile.writeAsString('SQLITE OVERWRITTEN DATA');

        // 6. Trigger Restore
        final restoreRes = await repository.restoreDatabase(backupFilePath);
        expect(restoreRes.isSuccess, isTrue);

        // Verify active file was restored back to the backup state
        expect(await activeFile.readAsString(), 'SQLITE DUMMY DATA HEADER');
      },
    );
  });
}

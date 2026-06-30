import 'dart:io';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:step_up_fuels/app/database/app_database.dart';
import 'package:step_up_fuels/features/customers/data/daos/customers_dao.dart';

void main() {
  group('Database Migration & Queries Test', () {
    late File dbFile;

    setUp(() {
      dbFile = File('test_database.db');
      if (dbFile.existsSync()) {
        dbFile.deleteSync();
      }
    });

    tearDown(() {
      if (dbFile.existsSync()) {
        dbFile.deleteSync();
      }
    });

    test('should successfully migrate database from version 1 to version 3', () async {
      // 1. Create a version 1 database on disk
      final v1Db = _InitialVersionDatabase(NativeDatabase(dbFile));
      await v1Db.customStatement('CREATE TABLE app_settings ("key" TEXT NOT NULL PRIMARY KEY, "value" TEXT NOT NULL, updated_at INTEGER NOT NULL);');
      await v1Db.close();

      // 2. Open the real AppDatabase (v3) on the same database file
      final v3Db = AppDatabase.forTesting(NativeDatabase(dbFile));
      final dao = CustomersDao(v3Db);

      // Verify we can query the app_settings and customers (created during upgrade)
      final settings = await v3Db.getSetting('theme_mode'); 
      expect(settings, isNull);

      final list = await dao.getAllCustomers();
      expect(list, isEmpty); 
      
      await v3Db.close();
    });

    test('should successfully migrate database from corrupted version 2 to version 3', () async {
      // 1. Create a corrupted version 2 database on disk (version 2, but only app_settings exists)
      final v2Db = _CorruptedVersion2Database(NativeDatabase(dbFile));
      await v2Db.customStatement('CREATE TABLE app_settings ("key" TEXT NOT NULL PRIMARY KEY, "value" TEXT NOT NULL, updated_at INTEGER NOT NULL);');
      // Ensure user_version is 2
      await v2Db.customStatement('PRAGMA user_version = 2;');
      await v2Db.close();

      // 2. Open the real AppDatabase (v3) on the same database file
      final v3Db = AppDatabase.forTesting(NativeDatabase(dbFile));
      final dao = CustomersDao(v3Db);

      // Verify we can query the app_settings and customers (created during upgrade from 2 to 3)
      final settings = await v3Db.getSetting('theme_mode'); 
      expect(settings, isNull);

      final list = await dao.getAllCustomers();
      expect(list, isEmpty); 
      
      await v3Db.close();
    });
  });
}

class _InitialVersionDatabase extends GeneratedDatabase {
  _InitialVersionDatabase(super.executor);

  @override
  List<TableInfo<Table, Object?>> get allTables => [];

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      // do nothing
    },
  );
}

class _CorruptedVersion2Database extends GeneratedDatabase {
  _CorruptedVersion2Database(super.executor);

  @override
  List<TableInfo<Table, Object?>> get allTables => [];

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      // do nothing
    },
  );
}

import 'dart:io';

import 'package:step_up_fuels/app/database/app_database.dart';
import 'package:step_up_fuels/app/database/seeds/database_seeder.dart';

/// Standalone CLI Seeding Script for Step Up Fuels ERP.
///
/// Can be executed directly or called from application maintenance screens.
///
/// Usage:
/// ```bash
/// flutter pub run tool/seed_database.dart
/// ```
Future<void> main() async {
  // ignore: avoid_print
  print('=====================================================');
  // ignore: avoid_print
  print('Step Up Fuels ERP - Realistic Test Data Seeder');
  // ignore: avoid_print
  print('=====================================================');

  final db = AppDatabase();
  try {
    // ignore: avoid_print
    print('Connecting to database and executing atomic seeding transaction...');
    final seeder = DatabaseSeeder(db);
    final counts = await seeder.seedAll();

    // ignore: avoid_print
    print('\nSeeded Tables & Row Counts:');
    // ignore: avoid_print
    print('-----------------------------------------------------');
    int total = 0;
    counts.forEach((table, count) {
      // ignore: avoid_print
      print('• ${table.padRight(30)} : $count rows');
      total += count;
    });
    // ignore: avoid_print
    print('-----------------------------------------------------');
    // ignore: avoid_print
    print('TOTAL PHYSICAL ROWS SEEDED     : $total rows');
    // ignore: avoid_print
    print('=====================================================');
    // ignore: avoid_print
    print('Database seeded successfully and fully reconciled!');
  } catch (e, st) {
    // ignore: avoid_print
    print('Error during seeding: $e\n$st');
    exit(1);
  } finally {
    await db.close();
  }
}

import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:step_up_fuels/core/constants/app_constants.dart';

DatabaseConnection connect() {
  return DatabaseConnection.delayed(Future.sync(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final dbDir = Directory(p.join(dbFolder.path, 'StepUpFuels'));
    if (!dbDir.existsSync()) {
      await dbDir.create(recursive: true);
    }
    final file = File(p.join(dbDir.path, AppConstants.databaseName));
    return NativeDatabase.createInBackground(file);
  }));
}

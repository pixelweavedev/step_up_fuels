import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:step_up_fuels/app/app.dart';
import 'package:step_up_fuels/app/di/injection_container.dart';
import 'package:step_up_fuels/core/logging/app_logger.dart';

/// Application entry point.
///
/// Initialisation order:
/// 1. Ensure Flutter bindings are initialised.
/// 2. Configure GetIt dependencies (database, services, repos).
/// 3. Wrap the app in Riverpod [ProviderScope].
/// 4. Launch [App].
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Enable Windows-specific configurations.
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    // Desktop-specific setup can go here (e.g., window size, title bar).
  }

  AppLogger.info('Starting Step Up Fuels ERP v1.0.0');

  try {
    await configureDependencies();
  } catch (e, st) {
    AppLogger.fatal(
      'Failed to configure dependencies',
      error: e,
      stackTrace: st,
    );
    exit(1);
  }

  runApp(const ProviderScope(child: App()));
}

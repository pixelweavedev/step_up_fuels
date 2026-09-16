import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marionette_flutter/marionette_flutter.dart';
import 'package:step_up_fuels/app/app.dart';
import 'package:step_up_fuels/app/di/injection_container.dart';
import 'package:step_up_fuels/core/logging/app_logger.dart';
import 'package:universal_io/io.dart';

/// Application entry point.
///
/// Initialisation order:
/// 1. Ensure Flutter / Marionette bindings are initialised.
/// 2. Configure GetIt dependencies (database, services, repos).
/// 3. Wrap the app in Riverpod [ProviderScope].
/// 4. Launch [App].
void main() async {
  if (kDebugMode && !kIsWeb) {
    MarionetteBinding.ensureInitialized();
  } else {
    WidgetsFlutterBinding.ensureInitialized();
  }

  // Enable Windows-specific configurations.
  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux ||
          defaultTargetPlatform == TargetPlatform.macOS)) {
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
    if (!kIsWeb) {
      exit(1);
    }
  }

  runApp(const ProviderScope(child: App()));
}

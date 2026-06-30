import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:step_up_fuels/app/router/app_router.dart';
import 'package:step_up_fuels/shared/providers/theme_provider.dart';

/// Root application widget.
///
/// Consumes [themeModeProvider] for live theme switching.
/// The [GoRouter] is provided via [routerProvider] (also from Riverpod).
class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Step Up Fuels ERP',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: themeDataForMode(ThemeMode.light),
      darkTheme: themeDataForMode(ThemeMode.dark),
      routerConfig: router,
    );
  }
}

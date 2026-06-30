import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:step_up_fuels/core/theme/app_colors.dart';
import 'package:step_up_fuels/core/theme/app_theme.dart';

/// Riverpod provider for the current ThemeMode.
///
/// Persisted to AppSettings in Phase 9 (Settings module).
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.dark);

/// Extension to easily toggle the theme.
extension ThemeModeProviderExt on WidgetRef {
  void toggleTheme() {
    final current = read(themeModeProvider);
    read(themeModeProvider.notifier).state = current == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
  }
}

/// Widget that rebuilds when the theme changes — useful in Settings.
class ThemeModeTile extends ConsumerWidget {
  const ThemeModeTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    return ListTile(
      leading: Icon(
        mode == ThemeMode.dark
            ? Icons.dark_mode_rounded
            : Icons.light_mode_rounded,
        color: AppColors.brandAmber,
      ),
      title: const Text('Theme'),
      subtitle: Text(mode == ThemeMode.dark ? 'Dark' : 'Light'),
      trailing: Switch(
        value: mode == ThemeMode.dark,
        activeThumbColor: AppColors.brandAmber,
        onChanged: (_) => ref.toggleTheme(),
      ),
    );
  }
}

/// Returns the correct AppTheme for a given ThemeMode.
ThemeData themeDataForMode(ThemeMode mode) => switch (mode) {
  ThemeMode.dark => AppTheme.dark,
  ThemeMode.light => AppTheme.light,
  ThemeMode.system => AppTheme.dark, // default to dark for this ERP
};

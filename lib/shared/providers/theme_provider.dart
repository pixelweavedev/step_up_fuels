import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:step_up_fuels/app/di/injection_container.dart';
import 'package:step_up_fuels/core/constants/app_constants.dart';
import 'package:step_up_fuels/core/theme/app_colors.dart';
import 'package:step_up_fuels/core/theme/app_theme.dart';

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    _loadTheme();
    return ThemeMode.light;
  }

  Future<void> _loadTheme() async {
    try {
      final db = ref.read(databaseProvider);
      final storedValue = await db.getSetting(
        AppConstants.settingsKeyThemeMode,
      );
      if (storedValue != null) {
        final mode = storedValue.toLowerCase() == 'light'
            ? ThemeMode.light
            : ThemeMode.dark;
        state = mode;
        AppColors.isDark = (mode == ThemeMode.dark);
      } else {
        AppColors.isDark = false;
      }
    } catch (_) {
      AppColors.isDark = false;
    }
  }

  Future<void> toggleTheme() async {
    final newMode = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    state = newMode;
    AppColors.isDark = (newMode == ThemeMode.dark);
    try {
      final db = ref.read(databaseProvider);
      await db.setSetting(
        AppConstants.settingsKeyThemeMode,
        newMode == ThemeMode.light ? 'light' : 'dark',
      );
    } catch (_) {
      // Keep in-memory update even if DB save fails
    }
  }
}

/// Riverpod provider for the current ThemeMode.
final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

/// Extension to easily toggle the theme.
extension ThemeModeProviderExt on WidgetRef {
  void toggleTheme() {
    read(themeModeProvider.notifier).toggleTheme();
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
  ThemeMode.system => AppTheme.light, // default to light for this ERP
};

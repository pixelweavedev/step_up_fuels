import 'package:flutter/material.dart';
import 'package:step_up_fuels/core/theme/app_colors.dart';
import 'package:step_up_fuels/core/services/import_export/models/export_adapter.dart';
import 'package:step_up_fuels/core/services/import_export/models/export_adapter_registry.dart';

class EntitySelectorGrid extends StatelessWidget {
  const EntitySelectorGrid({
    super.key,
    required this.selectedAdapter,
    required this.onSelect,
  });

  final ExportAdapter<dynamic> selectedAdapter;
  final ValueChanged<ExportAdapter<dynamic>> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 180,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.3,
      ),
      itemCount: ExportAdapterRegistry.all.length,
      itemBuilder: (context, index) {
        final adapter = ExportAdapterRegistry.all[index];
        final isSelected = adapter.entityName == selectedAdapter.entityName;

        // Parse hex colors for gradient
        final startColor = _parseColor(adapter.gradientStart);
        final endColor = _parseColor(adapter.gradientEnd);

        return InkWell(
          onTap: () => onSelect(adapter),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected
                  ? startColor.withValues(alpha: 0.08)
                  : (isDark ? AppColors.darkThemeCard : Colors.white),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? startColor
                    : (isDark
                          ? AppColors.darkThemeBorder
                          : AppColors.lightBorder),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: [
                if (!isSelected)
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [startColor, endColor],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        adapter.entityEmoji,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                    if (isSelected)
                      Icon(
                        Icons.check_circle_rounded,
                        color: startColor,
                        size: 20,
                      ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      adapter.entityLabel,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.darkThemeTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      adapter.supportsImport
                          ? 'Import & Export'
                          : 'Export Only',
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark
                            ? AppColors.darkThemeTextTertiary
                            : AppColors.lightTextTertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _parseColor(String hex) {
    try {
      final clean = hex.replaceAll('#', '');
      if (clean.length == 6) {
        return Color(int.parse('FF$clean', radix: 16));
      }
      return Color(int.parse(clean, radix: 16));
    } catch (_) {
      return AppColors.brandAmber;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:step_up_fuels/core/services/import_export/models/export_preset.dart';
import 'package:step_up_fuels/core/theme/app_colors.dart';

class PresetManager extends StatefulWidget {
  const PresetManager({
    super.key,
    required this.presets,
    required this.selectedPreset,
    required this.onSelect,
    required this.onSave,
    required this.onDelete,
  });

  final List<ExportPreset> presets;
  final ExportPreset? selectedPreset;
  final ValueChanged<ExportPreset> onSelect;
  final ValueChanged<String> onSave;
  final ValueChanged<String> onDelete;

  @override
  State<PresetManager> createState() => _PresetManagerState();
}

class _PresetManagerState extends State<PresetManager> {
  final _nameController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkThemeCard : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkThemeBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Export Presets',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkThemeTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              if (widget.presets.isNotEmpty)
                const Icon(Icons.bookmark_outline_rounded, size: 16, color: AppColors.brandAmber),
            ],
          ),
          const SizedBox(height: 12),
          if (widget.presets.isEmpty)
            Text(
              'No presets saved for this entity yet. Configure your columns & filters below and save them as a preset.',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.darkThemeTextSecondary : AppColors.lightTextSecondary,
              ),
            )
          else ...[
            DropdownButtonFormField<ExportPreset>(
              initialValue: widget.selectedPreset,
              hint: const Text('Select a Preset'),
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                border: OutlineInputBorder(),
              ),
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.darkThemeTextPrimary : AppColors.lightTextPrimary,
              ),
              items: widget.presets.map((preset) {
                return DropdownMenuItem<ExportPreset>(
                  value: preset,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(preset.name),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.error),
                        onPressed: () => widget.onDelete(preset.id),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (preset) {
                if (preset != null) widget.onSelect(preset);
              },
            ),
            const SizedBox(height: 12),
          ],
          if (!_isSaving)
            OutlinedButton.icon(
              onPressed: () {
                setState(() => _isSaving = true);
              },
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Save Current Configuration as Preset'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.brandAmber,
                side: const BorderSide(color: AppColors.brandAmber),
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 36,
                    child: TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        hintText: 'Preset Name (e.g. GST Report)',
                        hintStyle: TextStyle(fontSize: 12),
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        border: OutlineInputBorder(),
                      ),
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    final name = _nameController.text.trim();
                    if (name.isNotEmpty) {
                      widget.onSave(name);
                      _nameController.clear();
                      setState(() => _isSaving = false);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandAmber,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Save'),
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () {
                    setState(() => _isSaving = false);
                  },
                ),
              ],
            ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:step_up_fuels/core/theme/app_colors.dart';

/// Standard GST tax rates in India: 0%, 5%, 12%, 18%, 28%.
/// Rate is stored as decimal (e.g. 0.18 for 18%, 0.05 for 5%).
/// Also provides support for any custom tax percentage.
class GstRateField extends StatelessWidget {
  const GstRateField({
    super.key,
    required this.value,
    required this.onChanged,
    this.label = 'GST %',
  });

  final double value;
  final ValueChanged<double> onChanged;
  final String label;

  static const List<double> standardRates = [0.0, 0.05, 0.12, 0.18, 0.28];

  @override
  Widget build(BuildContext context) {
    // Normalize to decimal (0.18 instead of 18.0)
    final normalized = value > 1.0 ? value / 100.0 : value;

    // If current value is custom (not in standardRates), we include it in the dropdown list
    final allRates = <double>{...standardRates, normalized}.toList()..sort();

    final currentValue = allRates.firstWhere(
      (r) => (r - normalized).abs() < 0.0001,
      orElse: () => normalized,
    );

    return DropdownButtonFormField<double>(
      key: ValueKey(currentValue),
      initialValue: currentValue,
      dropdownColor: AppColors.darkCard,
      style: TextStyle(
        color: AppColors.darkTextPrimary,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: AppColors.darkTextSecondary,
          fontSize: 12,
        ),
        filled: true,
        fillColor: AppColors.darkSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.brandAmber, width: 1.5),
        ),
      ),
      items: [
        ...allRates.map((rate) {
          final isStandard = standardRates.contains(rate);
          final pct = rate * 100.0;
          final pctStr = pct == pct.roundToDouble()
              ? pct.toStringAsFixed(0)
              : pct.toStringAsFixed(1);

          final text = rate == 0.0
              ? '0% (Exempt)'
              : isStandard
                  ? '$pctStr%'
                  : '$pctStr% (Custom)';
          return DropdownMenuItem<double>(
            value: rate,
            child: Text(
              text,
              style: TextStyle(
                color: rate == currentValue
                    ? AppColors.brandAmber
                    : AppColors.darkTextPrimary,
                fontSize: 12,
                fontWeight: rate == currentValue
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          );
        }),
        const DropdownMenuItem<double>(
          value: -1.0, // Sentinel for custom
          child: Row(
            children: [
              Icon(Icons.edit_note_rounded, size: 16, color: AppColors.brandAmber),
              SizedBox(width: 4),
              Text(
                'Custom...',
                style: TextStyle(
                  color: AppColors.brandAmber,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
      onChanged: (selected) {
        if (selected == null) return;
        if (selected == -1.0) {
          _promptCustomRate(context, normalized);
        } else {
          onChanged(selected);
        }
      },
    );
  }

  void _promptCustomRate(BuildContext context, double currentNormalized) {
    final currentPct = currentNormalized * 100.0;
    final ctrl = TextEditingController(
      text: currentPct > 0
          ? (currentPct == currentPct.roundToDouble()
              ? currentPct.toStringAsFixed(0)
              : currentPct.toStringAsFixed(1))
          : '',
    );
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(
          'Set Custom GST Rate',
          style: TextStyle(color: AppColors.darkTextPrimary, fontSize: 16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter the applicable tax percentage for this item (e.g., 12.5 for VAT or Cess):',
              style: TextStyle(color: AppColors.darkTextSecondary, fontSize: 13),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: ctrl,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: TextStyle(color: AppColors.darkTextPrimary),
              decoration: InputDecoration(
                labelText: 'GST Rate (%)',
                hintText: 'e.g. 18',
                suffixText: '%',
                filled: true,
                fillColor: AppColors.darkSurface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.darkBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.brandAmber, width: 1.5),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brandAmber,
              foregroundColor: AppColors.darkBackground,
            ),
            onPressed: () {
              final parsed = double.tryParse(ctrl.text.trim());
              if (parsed != null && parsed >= 0) {
                Navigator.pop(ctx);
                // Return decimal (e.g. 18 -> 0.18)
                final decimalRate = parsed > 1.0 ? parsed / 100.0 : parsed;
                onChanged(decimalRate);
              }
            },
            child: const Text('Apply Rate'),
          ),
        ],
      ),
    );
  }
}

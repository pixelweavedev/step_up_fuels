import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:step_up_fuels/core/theme/app_colors.dart';
import 'package:step_up_fuels/core/services/import_export/models/export_filter.dart';

class ExportFilterPanel extends StatelessWidget {
  const ExportFilterPanel({
    super.key,
    required this.entityName,
    required this.filter,
    required this.onChange,
  });

  final String entityName;
  final ExportFilter filter;
  final ValueChanged<ExportFilter> onChange;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final showDateRange = [
      'invoices',
      'purchases',
      'payments',
      'expenses',
      'inventory',
    ].contains(entityName);
    final showActiveOnly = [
      'customers',
      'products',
      'drivers',
      'vehicles',
    ].contains(entityName);
    final showOutstandingOnly = [
      'customers',
      'invoices',
      'purchases',
    ].contains(entityName);
    final showStatus = [
      'invoices',
      'purchases',
      'payments',
      'expenses',
      'drivers',
      'vehicles',
    ].contains(entityName);
    final showPaymentMode = ['payments', 'expenses'].contains(entityName);
    final showVehicle = ['expenses'].contains(entityName);
    final showDriver = ['expenses'].contains(entityName);

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
          Text(
            'Customize Filters',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.darkThemeTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 12),
          if (showDateRange) ...[
            _buildDateRangeFilter(context),
            const SizedBox(height: 12),
          ],
          Wrap(
            spacing: 16,
            runSpacing: 12,
            children: [
              if (showActiveOnly)
                _buildSwitchFilter(
                  label: 'Active Records Only',
                  value: filter.activeOnly,
                  onChanged: (val) =>
                      onChange(filter.copyWith(activeOnly: val)),
                ),
              if (showOutstandingOnly)
                _buildSwitchFilter(
                  label: 'Outstanding Balance Only',
                  value: filter.outstandingOnly,
                  onChanged: (val) =>
                      onChange(filter.copyWith(outstandingOnly: val)),
                ),
            ],
          ),
          if (showStatus || showPaymentMode || showVehicle || showDriver) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if (showStatus)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: _buildTextFieldFilter(
                        label: 'Status',
                        value: filter.status,
                        hint: 'e.g. PAID, DRAFT',
                        onChanged: (val) => onChange(
                          val.isEmpty
                              ? filter.clearStatus()
                              : filter.copyWith(status: val),
                        ),
                      ),
                    ),
                  ),
                if (showPaymentMode)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: _buildTextFieldFilter(
                        label: 'Payment Mode',
                        value: filter.paymentMode,
                        hint: 'CASH, UPI, etc.',
                        onChanged: (val) => onChange(
                          val.isEmpty
                              ? filter.copyWith()
                              : filter.copyWith(paymentMode: val),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Row(
              children: [
                if (showVehicle)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0, top: 8.0),
                      child: _buildTextFieldFilter(
                        label: 'Vehicle ID',
                        value: filter.vehicleId,
                        hint: 'e.g. MH12AB1234',
                        onChanged: (val) => onChange(
                          val.isEmpty
                              ? filter.copyWith()
                              : filter.copyWith(vehicleId: val),
                        ),
                      ),
                    ),
                  ),
                if (showDriver)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0, top: 8.0),
                      child: _buildTextFieldFilter(
                        label: 'Driver ID',
                        value: filter.driverId,
                        hint: 'e.g. D008',
                        onChanged: (val) => onChange(
                          val.isEmpty
                              ? filter.copyWith()
                              : filter.copyWith(driverId: val),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDateRangeFilter(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateStr = filter.dateFrom != null && filter.dateTo != null
        ? '${DateFormat('dd/MM/yyyy').format(filter.dateFrom!)} - ${DateFormat('dd/MM/yyyy').format(filter.dateTo!)}'
        : 'All Time';

    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () async {
              final picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
                initialDateRange:
                    filter.dateFrom != null && filter.dateTo != null
                    ? DateTimeRange(
                        start: filter.dateFrom!,
                        end: filter.dateTo!,
                      )
                    : null,
              );
              if (picked != null) {
                onChange(
                  filter.copyWith(dateFrom: picked.start, dateTo: picked.end),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isDark
                      ? AppColors.darkThemeBorder
                      : AppColors.lightBorder,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.date_range_outlined, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    dateStr,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? AppColors.darkThemeTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (filter.dateFrom != null)
          IconButton(
            icon: const Icon(Icons.clear, size: 18),
            onPressed: () => onChange(filter.copyWith(dateTo: null)),
          ),
      ],
    );
  }

  Widget _buildSwitchFilter({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.brandAmber,
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 13)),
      ],
    );
  }

  Widget _buildTextFieldFilter({
    required String label,
    required String? value,
    required String hint,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 36,
          child: TextField(
            controller: TextEditingController(text: value)
              ..selection = TextSelection.fromPosition(
                TextPosition(offset: value?.length ?? 0),
              ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(fontSize: 12),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 8,
              ),
              border: const OutlineInputBorder(),
            ),
            style: const TextStyle(fontSize: 13),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

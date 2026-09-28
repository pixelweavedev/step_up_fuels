import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:step_up_fuels/core/theme/app_colors.dart';
import 'package:step_up_fuels/features/products/domain/entities/product.dart';
import 'package:step_up_fuels/features/products/presentation/providers/products_provider.dart';

/// Modal dialog allowing fuel station operators to quickly set and update
/// daily selling prices for all products in one place.
class DailySellingPriceDialog extends ConsumerStatefulWidget {
  const DailySellingPriceDialog({super.key});

  @override
  ConsumerState<DailySellingPriceDialog> createState() =>
      _DailySellingPriceDialogState();
}

class _DailySellingPriceDialogState
    extends ConsumerState<DailySellingPriceDialog> {
  final Map<String, TextEditingController> _controllers = {};
  bool _initialized = false;
  bool _isSaving = false;

  void _initControllers(List<Product> products) {
    if (_initialized) return;
    for (final p in products) {
      final currentPrice = p.currentSellingPrice ?? 0.0;
      _controllers[p.id] = TextEditingController(
        text: currentPrice > 0 ? currentPrice.toStringAsFixed(2) : '',
      );
    }
    _initialized = true;
  }

  @override
  void dispose() {
    for (final ctrl in _controllers.values) {
      ctrl.dispose();
    }
    super.dispose();
  }

  Future<void> _saveAll(List<Product> products) async {
    setState(() => _isSaving = true);
    int updatedCount = 0;
    try {
      final notifier = ref.read(productsListProvider.notifier);
      for (final p in products) {
        final ctrl = _controllers[p.id];
        if (ctrl == null) continue;
        final newPrice = double.tryParse(ctrl.text.trim());
        if (newPrice != null && (p.currentSellingPrice ?? 0.0) != newPrice) {
          final updated = p.copyWith(
            currentSellingPrice: newPrice,
            updatedBy: 'station_operator',
          );
          await notifier.saveProduct(updated);
          updatedCount++;
        }
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              updatedCount > 0
                  ? 'Updated daily rates for $updatedCount product(s) successfully!'
                  : 'Daily selling rates are up to date.',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update daily rates: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsListProvider);
    final todayStr = DateFormat('dd MMM yyyy').format(DateTime.now());

    return Dialog(
      backgroundColor: AppColors.darkCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.darkBorder),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640, maxHeight: 720),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.brandAmber.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.local_gas_station_rounded,
                      color: AppColors.brandAmber,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Daily Selling Rates',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkTextPrimary,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.brandAmber.withValues(
                                  alpha: 0.15,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.calendar_today_rounded,
                                    size: 12,
                                    color: AppColors.brandAmber,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    todayStr,
                                    style: const TextStyle(
                                      color: AppColors.brandAmber,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Update today\'s selling rates across the station. New rates automatically prefill when creating invoices and fuel sales.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.darkTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Divider(color: AppColors.darkBorder),
              const SizedBox(height: 12),

              // Product list
              Expanded(
                child: productsAsync.when(
                  data: (products) {
                    final activeProducts = products
                        .where((p) => p.isActive && p.deletedAt == null)
                        .toList();

                    if (activeProducts.isEmpty) {
                      return Center(
                        child: Text(
                          'No active products found to configure.',
                          style: TextStyle(color: AppColors.darkTextSecondary),
                        ),
                      );
                    }

                    _initControllers(activeProducts);

                    return ListView.separated(
                      itemCount: activeProducts.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final product = activeProducts[index];
                        final ctrl = _controllers[product.id]!;

                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.darkSurface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.darkBorder),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.brandAmber.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Icon(
                                    product.name.toLowerCase().contains(
                                          'diesel',
                                        )
                                        ? Icons.local_shipping_outlined
                                        : product.name.toLowerCase().contains(
                                            'cng',
                                          )
                                        ? Icons.energy_savings_leaf_outlined
                                        : Icons.local_gas_station_rounded,
                                    color: AppColors.brandAmber,
                                    size: 22,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.name,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.darkTextPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Code: ${product.productCode} • HSN: ${product.hsnCode} • GST: ${(product.gstRate * 100).toStringAsFixed(0)}%',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppColors.darkTextSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              SizedBox(
                                width: 140,
                                child: TextField(
                                  controller: ctrl,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  style: TextStyle(
                                    color: AppColors.darkTextPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  decoration: InputDecoration(
                                    labelText:
                                        'Price / ${product.unitOfMeasure}',
                                    labelStyle: TextStyle(
                                      color: AppColors.darkTextSecondary,
                                      fontSize: 11,
                                    ),
                                    prefixText: '₹ ',
                                    prefixStyle: const TextStyle(
                                      color: AppColors.brandAmber,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                    filled: true,
                                    fillColor: AppColors.darkCard,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 8,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: AppColors.darkBorder,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                        color: AppColors.brandAmber,
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.brandAmber,
                    ),
                  ),
                  error: (e, _) => Center(
                    child: Text(
                      'Failed to load products: $e',
                      style: const TextStyle(color: AppColors.error),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Divider(color: AppColors.darkBorder),
              const SizedBox(height: 12),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSaving ? null : () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: AppColors.darkTextSecondary),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brandAmber,
                      foregroundColor: AppColors.darkBackground,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: _isSaving
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.darkBackground,
                            ),
                          )
                        : const Icon(Icons.check_circle_rounded, size: 18),
                    label: Text(
                      _isSaving ? 'Updating...' : 'Save & Apply Rates',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onPressed: _isSaving
                        ? null
                        : () {
                            final products =
                                productsAsync.value
                                    ?.where(
                                      (p) => p.isActive && p.deletedAt == null,
                                    )
                                    .toList() ??
                                [];
                            _saveAll(products);
                          },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

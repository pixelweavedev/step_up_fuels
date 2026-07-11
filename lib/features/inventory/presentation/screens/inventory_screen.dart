import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:step_up_fuels/core/responsive/adaptive_master_detail.dart';
import 'package:step_up_fuels/core/responsive/breakpoints.dart';
import 'package:step_up_fuels/core/theme/app_colors.dart';
import 'package:step_up_fuels/core/theme/dimensions.dart';
import 'package:step_up_fuels/core/utils/date_utils.dart';
import 'package:step_up_fuels/features/inventory/domain/entities/stock_adjustment.dart';
import 'package:step_up_fuels/features/inventory/domain/entities/storage_location.dart';
import 'package:step_up_fuels/features/inventory/presentation/providers/inventory_provider.dart';
import 'package:step_up_fuels/features/products/domain/entities/product.dart';
import 'package:step_up_fuels/features/products/presentation/providers/products_provider.dart';
import 'package:step_up_fuels/shared/providers/theme_provider.dart';
import 'package:step_up_fuels/shared/widgets/buttons/primary_button.dart';
import 'package:step_up_fuels/shared/widgets/empty_states/empty_state_widget.dart';
import 'package:step_up_fuels/shared/widgets/inputs/app_text_field.dart';
import 'package:uuid/uuid.dart';

class InventoryScreen extends ConsumerWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeModeProvider);
    final locationsAsync = ref.watch(storageLocationsProvider);
    final selectedLocationId = ref.watch(selectedStorageLocationIdProvider);
    final isMobileOrSmall = context.isMobileOrSmallTablet;

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: locationsAsync.when(
        data: (locations) {
          if (locations.isEmpty) {
            return const Center(
              child: EmptyStateWidget(
                icon: Icons.local_gas_station_rounded,
                title: 'No Storage Locations Found',
                subtitle:
                    'Please seed default settings or register storage locations.',
              ),
            );
          }

          // Auto-select first location if none is selected
          if (selectedLocationId == null && locations.isNotEmpty && !isMobileOrSmall) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ref.read(selectedStorageLocationIdProvider.notifier).state =
                  locations.first.id;
            });
          }

          final masterWidget = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Locations',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkTextPrimary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.add_circle_outline,
                        color: AppColors.brandAmber,
                      ),
                      onPressed: () =>
                          _showAddLocationDialog(context, ref),
                    ),
                  ],
                ),
              ),
              Divider(color: AppColors.darkBorder, height: 1),
              Expanded(
                child: ListView.builder(
                  itemCount: locations.length,
                  itemBuilder: (context, index) {
                    final loc = locations[index];
                    final isSelected = loc.id == selectedLocationId;
                    return ListTile(
                      selected: isSelected,
                      selectedTileColor: AppColors.darkSurface,
                      leading: Icon(
                        loc.type == StorageLocationType.mainStorage
                            ? Icons.store_rounded
                            : Icons.local_shipping_rounded,
                        color: isSelected
                            ? AppColors.brandAmber
                            : AppColors.darkTextSecondary,
                      ),
                      title: Text(
                        loc.name,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? AppColors.brandAmber
                              : AppColors.darkTextPrimary,
                        ),
                      ),
                      subtitle: Text(
                        loc.type == StorageLocationType.mainStorage
                            ? 'Main Terminal'
                            : 'Mobile Bowser',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.darkTextSecondary,
                        ),
                      ),
                      onTap: () {
                        ref
                            .read(
                              selectedStorageLocationIdProvider.notifier,
                            )
                            .state = loc.id;
                        if (isMobileOrSmall) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (ctx) => Scaffold(
                                appBar: AppBar(
                                  title: Text(loc.name),
                                  backgroundColor: AppColors.darkSurface,
                                  foregroundColor: AppColors.darkTextPrimary,
                                ),
                                body: const _LocationDetailDashboard(),
                              ),
                            ),
                          ).then((_) {
                            ref
                                .read(
                                  selectedStorageLocationIdProvider.notifier,
                                )
                                .state = null;
                          });
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          );

          return AdaptiveMasterDetail(
            masterWidth: AppDimensions.masterListWidth(context),
            hasSelection: selectedLocationId != null,
            master: masterWidget,
            detail: const _LocationDetailDashboard(),
          );
        },
        error: (err, st) => Center(
          child: Text(
            'Error: $err',
            style: const TextStyle(color: AppColors.error),
          ),
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.brandAmber),
        ),
      ),
    );
  }

  void _showAddLocationDialog(BuildContext context, WidgetRef ref) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    StorageLocationType selectedType = StorageLocationType.mainStorage;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: AppColors.darkSurface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Register Storage Location',
                        style: TextStyle(
                          color: AppColors.darkTextPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: nameController,
                        label: 'Location Name *',
                        hint: 'e.g. Pune Terminal Tank 1',
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<StorageLocationType>(
                        initialValue: selectedType,
                        dropdownColor: AppColors.darkSurface,
                        decoration: const InputDecoration(labelText: 'Type'),
                        items: const [
                          DropdownMenuItem(
                            value: StorageLocationType.mainStorage,
                            child: Text('Main Storage'),
                          ),
                          DropdownMenuItem(
                            value: StorageLocationType.bowser,
                            child: Text('Bowser (Vehicle)'),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => selectedType = val);
                        },
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                color: AppColors.darkTextSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          PrimaryButton(
                            label: 'Save',
                            onPressed: () async {
                              if (!formKey.currentState!.validate()) return;
                              final location = StorageLocation(
                                id: const Uuid().v4(),
                                name: nameController.text.trim(),
                                type: selectedType,
                                isActive: true,
                                createdBy: 'system',
                                createdAt: DateTime.now(),
                                updatedBy: 'system',
                                updatedAt: DateTime.now(),
                                version: 1,
                              );
                              await ref
                                  .read(storageLocationsProvider.notifier)
                                  .saveLocation(location);
                              if (context.mounted) Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _LocationDetailDashboard extends ConsumerWidget {
  const _LocationDetailDashboard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationAsync = ref.watch(selectedStorageLocationProvider);
    final productsAsync = ref.watch(productsListProvider);

    return locationAsync.when(
      data: (location) {
        return productsAsync.when(
          data: (products) {
            if (products.isEmpty) {
              return const Center(
                child: EmptyStateWidget(
                  icon: Icons.inventory_2_outlined,
                  title: 'No Products Registered',
                  subtitle: 'Please add products first under the Products tab.',
                ),
              );
            }

            final firstProduct = products.first;

            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Block
                  Builder(
                    builder: (context) {
                      final isMobile = context.isMobileOrSmallTablet;
                      final titleBlock = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            location.name,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkTextPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Real-Time Balance & Historical Stock Ledger',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.darkTextSecondary,
                            ),
                          ),
                        ],
                      );

                      final actionButton = PrimaryButton(
                        label: isMobile ? 'Adjust Stock' : 'Record Stock Adjustment',
                        icon: Icons.tune_rounded,
                        onPressed: () => _showAdjustmentDialog(
                          context,
                          ref,
                          location,
                          firstProduct,
                        ),
                      );

                      return isMobile
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                titleBlock,
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: actionButton,
                                ),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(child: titleBlock),
                                const SizedBox(width: 16),
                                actionButton,
                              ],
                            );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Stock Balance Summary Card
                  _StockBalanceCard(
                    locationId: location.id,
                    productId: firstProduct.id,
                    product: firstProduct,
                  ),

                  const SizedBox(height: 24),
                  Text(
                    'Inventory Movements Logs',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Movements History List
                  Expanded(child: _MovementsList(locationId: location.id)),
                ],
              ),
            );
          },
          error: (err, st) => Center(child: Text('Error: $err')),
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.brandAmber),
          ),
        );
      },
      error: (err, st) =>
          const Center(child: Text('Please select a storage location.')),
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.brandAmber),
      ),
    );
  }

  void _showAdjustmentDialog(
    BuildContext context,
    WidgetRef ref,
    StorageLocation location,
    Product product,
  ) async {
    final formKey = GlobalKey<FormState>();
    final qtyController = TextEditingController();
    final reasonController = TextEditingController();
    String adjType = 'GAIN';

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: AppColors.darkSurface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Stock Adjustment (${location.name})',
                        style: TextStyle(
                          color: AppColors.darkTextPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: adjType,
                        dropdownColor: AppColors.darkSurface,
                        decoration: const InputDecoration(
                          labelText: 'Adjustment Type',
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'GAIN',
                            child: Text('Stock Gain (+)'),
                          ),
                          DropdownMenuItem(
                            value: 'LOSS',
                            child: Text('Stock Loss / Leakage (-)'),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => adjType = val);
                        },
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: qtyController,
                        label: 'Quantity (Litres) *',
                        hint: 'e.g. 500',
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Required';
                          if (double.tryParse(v) == null) {
                            return 'Must be a valid decimal';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: reasonController,
                        label: 'Reason / Explanation *',
                        hint: 'e.g. Temperature expansion, pipeline leakage',
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                color: AppColors.darkTextSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          PrimaryButton(
                            label: 'Save',
                            onPressed: () async {
                              if (!formKey.currentState!.validate()) return;
                              final qty = double.parse(
                                qtyController.text.trim(),
                              );
                              final adj = StockAdjustment(
                                id: const Uuid().v4(),
                                storageLocationId: location.id,
                                productId: product.id,
                                adjustmentType: adjType,
                                quantity: qty,
                                reason: reasonController.text.trim(),
                                adjustmentDate: DateTime.now(),
                                approvedBy: 'system',
                                createdBy: 'system',
                                createdAt: DateTime.now(),
                                updatedBy: 'system',
                                updatedAt: DateTime.now(),
                                version: 1,
                              );
                              await ref
                                  .read(stockAdjustmentProvider.notifier)
                                  .adjustStock(adj);
                              if (context.mounted) Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _StockBalanceCard extends ConsumerWidget {
  const _StockBalanceCard({
    required this.locationId,
    required this.productId,
    required this.product,
  });

  final String locationId;
  final String productId;
  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balanceAsync = ref.watch(
      stockBalanceProvider((locationId: locationId, productId: productId)),
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: balanceAsync.when(
        data: (stock) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CURRENT STOCK BALANCE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkTextTertiary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        stock.toStringAsFixed(2),
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          color: AppColors.brandAmber,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        product.unitOfMeasure,
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.darkTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'PRODUCT',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.darkTextTertiary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    product.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'HSN: ${product.hsnCode}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.darkTextSecondary,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
        error: (err, st) => Center(child: Text('Error: $err')),
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.brandAmber),
        ),
      ),
    );
  }
}

class _MovementsList extends ConsumerWidget {
  const _MovementsList({required this.locationId});
  final String locationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final movementsAsync = ref.watch(locationMovementsProvider(locationId));

    return movementsAsync.when(
      data: (list) {
        if (list.isEmpty) {
          return Center(
            child: Text(
              'No stock movements logged for this location.',
              style: TextStyle(
                color: AppColors.darkTextSecondary,
                fontSize: 13,
              ),
            ),
          );
        }

        return ListView.builder(
          itemCount: list.length,
          itemBuilder: (context, index) {
            final mov = list[index];
            final isIncoming = mov.destinationLocationId == locationId;
            final isInternalTransfer =
                mov.sourceLocationId != null &&
                mov.destinationLocationId != null;

            return Card(
              color: AppColors.darkCard,
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: AppColors.darkBorder),
              ),
              child: ListTile(
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isInternalTransfer
                        ? Colors.blue.withValues(alpha: 0.15)
                        : (isIncoming ? AppColors.success : AppColors.error)
                              .withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isInternalTransfer
                        ? Icons.swap_horiz_rounded
                        : (isIncoming
                              ? Icons.arrow_downward
                              : Icons.arrow_upward),
                    color: isInternalTransfer
                        ? Colors.blue
                        : (isIncoming ? AppColors.success : AppColors.error),
                    size: 18,
                  ),
                ),
                title: Text(
                  '${mov.type.name.toUpperCase()} (${mov.quantity} LTRS)',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkTextPrimary,
                  ),
                ),
                subtitle: Text(
                  mov.notes ?? 'Transaction ID: ${mov.referenceId ?? "N/A"}',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.darkTextSecondary,
                  ),
                ),
                trailing: Text(
                  AppDateUtils.toDisplay(mov.movementDate),
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.darkTextTertiary,
                  ),
                ),
              ),
            );
          },
        );
      },
      error: (err, st) => Center(child: Text('Error: $err')),
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.brandAmber),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:step_up_fuels/core/responsive/adaptive_grid.dart';
import 'package:step_up_fuels/core/responsive/adaptive_master_detail.dart';
import 'package:step_up_fuels/core/responsive/breakpoints.dart';
import 'package:step_up_fuels/core/theme/app_colors.dart';
import 'package:step_up_fuels/core/theme/dimensions.dart';
import 'package:step_up_fuels/features/products/domain/entities/product.dart';
import 'package:step_up_fuels/features/products/presentation/providers/products_provider.dart';
import 'package:step_up_fuels/shared/providers/theme_provider.dart';
import 'package:step_up_fuels/shared/widgets/buttons/primary_button.dart';
import 'package:step_up_fuels/shared/widgets/cards/mobile_card.dart';
import 'package:step_up_fuels/shared/widgets/dialogs/confirm_dialog.dart';
import 'package:step_up_fuels/shared/widgets/empty_states/app_error_widget.dart';
import 'package:step_up_fuels/shared/widgets/empty_states/empty_state_widget.dart';
import 'package:step_up_fuels/shared/widgets/inputs/app_text_field.dart';
import 'package:step_up_fuels/shared/widgets/layout/app_mobile_header.dart';
import 'package:uuid/uuid.dart';

class ProductsScreen extends ConsumerWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(themeModeProvider);
    final selectedId = ref.watch(selectedProductIdProvider);
    final isMobileOrSmall = context.isMobileOrSmallTablet;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: AdaptiveMasterDetail(
        masterWidth: AppDimensions.masterListWidth(context),
        hasSelection: selectedId != null,
        master: _ProductMasterList(
          onMobileTap: isMobileOrSmall
              ? (product) {
                  ref.read(selectedProductIdProvider.notifier).state =
                      product.id;
                  Navigator.of(context)
                      .push(
                        MaterialPageRoute<void>(
                          builder: (ctx) => const _ProductDetailView(),
                        ),
                      )
                      .then((_) {
                        ref.read(selectedProductIdProvider.notifier).state =
                            null;
                      });
                }
              : null,
        ),
        detail: const _ProductDetailView(),
      ),
    );
  }
}

class _ProductMasterList extends ConsumerWidget {
  const _ProductMasterList({this.onMobileTap});

  final void Function(Product product)? onMobileTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsListProvider);
    final selectedId = ref.watch(selectedProductIdProvider);
    final statusFilter = ref.watch(productStatusFilterProvider);
    final isMobile = context.isMobile;

    if (isMobile) {
      return _buildMobileProductList(
        context,
        ref,
        productsAsync,
        statusFilter,
        selectedId,
      );
    }

    return Column(
      children: [
        // Header & Search
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Products',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkTextPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.add_circle_outline,
                      color: AppColors.brandAmber,
                    ),
                    onPressed: () {
                      showDialog<void>(
                        context: context,
                        builder: (context) => const ProductFormDialog(),
                      );
                    },
                    tooltip: 'Add New Product',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              AppTextField(
                hint: 'Search code or name...',
                prefixIcon: Icons.search_rounded,
                onChanged: (val) {
                  ref.read(productSearchQueryProvider.notifier).state = val;
                },
              ),
            ],
          ),
        ),

        // Filters Panel
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Show Inactive/Deleted:',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.darkTextSecondary,
                ),
              ),
              Switch(
                value: statusFilter == null || statusFilter == false,
                activeThumbColor: AppColors.brandAmber,
                onChanged: (val) {
                  ref.read(productStatusFilterProvider.notifier).state = val
                      ? null
                      : true;
                },
              ),
            ],
          ),
        ),
        Divider(color: AppColors.darkBorder),

        // Product Cards List
        Expanded(
          child: productsAsync.when(
            data: (list) {
              if (list.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: EmptyStateWidget(
                      icon: Icons.inventory_2_outlined,
                      title: 'No Products Found',
                      subtitle: 'Add a new product to configure HSN/GST rates.',
                    ),
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final product = list[index];
                  final isSelected = product.id == selectedId;
                  final isDeleted = product.deletedAt != null;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: InkWell(
                      onTap: () {
                        ref.read(selectedProductIdProvider.notifier).state =
                            product.id;
                        if (onMobileTap != null) {
                          onMobileTap!(product);
                        }
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.darkSurface
                              : AppColors.darkCard,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.brandAmber
                                : (isDeleted
                                      ? AppColors.error.withValues(alpha: 0.3)
                                      : AppColors.darkBorder),
                            width: isSelected ? 1.5 : 1.0,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.brandNavyLight,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    product.productCode,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.brandAmber,
                                    ),
                                  ),
                                ),
                                Text(
                                  'GST: ${(product.gstRate * 100).toInt()}%',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.darkTextSecondary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              product.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.darkTextPrimary,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'HSN: ${product.hsnCode}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.darkTextTertiary,
                                  ),
                                ),
                                if (product.currentSellingPrice != null)
                                  Text(
                                    '₹${product.currentSellingPrice!.toStringAsFixed(2)} / ${product.unitOfMeasure}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.darkTextPrimary,
                                    ),
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
        ),
      ],
    );
  }

  Widget _buildMobileProductList(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<Product>> productsAsync,
    bool? statusFilter,
    String? selectedId,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.brandAmber,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'New Product',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        onPressed: () {
          showDialog<void>(
            context: context,
            builder: (context) => const ProductFormDialog(),
          );
        },
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Sticky Mobile Header (Search + KPI Bar + Sub-header Filter)
            productsAsync.maybeWhen(
              data: (list) {
                final total = list.length;
                final active = list.where((p) => p.deletedAt == null).length;
                final inactive = total - active;

                return AppMobileHeader(
                  searchWidget: AppTextField(
                    hint: 'Search code or name...',
                    prefixIcon: Icons.search_rounded,
                    showClearButton: true,
                    onChanged: (val) {
                      ref.read(productSearchQueryProvider.notifier).state = val;
                    },
                    onClear: () {
                      ref.read(productSearchQueryProvider.notifier).state = '';
                    },
                  ),
                  kpis: [
                    AppKpiItem(label: 'CATALOGUE', value: '$total Products'),
                    AppKpiItem(
                      label: 'ACTIVE',
                      value: '$active Items',
                      valueColor: AppColors.success,
                    ),
                    AppKpiItem(label: 'INACTIVE', value: '$inactive Items'),
                  ],
                  bottomWidget: Container(
                    color: isDark
                        ? AppColors.darkSurface
                        : AppColors.lightSurface,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Show Inactive / Archived',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                        Switch(
                          value: statusFilter == null || statusFilter == false,
                          activeThumbColor: AppColors.brandAmber,
                          onChanged: (val) {
                            ref
                                .read(productStatusFilterProvider.notifier)
                                .state = val
                                ? null
                                : true;
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
              orElse: () => AppMobileHeader(
                searchWidget: AppTextField(
                  hint: 'Search code or name...',
                  prefixIcon: Icons.search_rounded,
                  showClearButton: true,
                  onChanged: (val) {
                    ref.read(productSearchQueryProvider.notifier).state = val;
                  },
                  onClear: () {
                    ref.read(productSearchQueryProvider.notifier).state = '';
                  },
                ),
              ),
            ),

            // Products List
            Expanded(
              child: productsAsync.when(
                data: (list) {
                  if (list.isEmpty) {
                    return const Center(
                      child: EmptyStateWidget(
                        icon: Icons.inventory_2_outlined,
                        title: 'No Products Found',
                        subtitle:
                            'Add a new product or check your filter search.',
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final product = list[index];
                      final isDeleted = product.deletedAt != null;
                      final priceText = product.currentSellingPrice != null
                          ? '₹${product.currentSellingPrice!.toStringAsFixed(2)}'
                          : 'Not set';

                      return MobileCard(
                        title: product.name,
                        subtitle:
                            'Code: ${product.productCode} • HSN: ${product.hsnCode}',
                        statusBadge: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: isDeleted
                                ? AppColors.error.withValues(alpha: 0.15)
                                : AppColors.success.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            isDeleted ? 'ARCHIVED' : 'ACTIVE',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: isDeleted
                                  ? AppColors.error
                                  : AppColors.success,
                            ),
                          ),
                        ),
                        heroMetric: priceText,
                        heroLabel: '/ ${product.unitOfMeasure}',
                        attributes: [
                          MobileCardAttribute(
                            label: 'GST Rate',
                            value: '${(product.gstRate * 100).toInt()}%',
                          ),
                          MobileCardAttribute(
                            label: 'CGST / SGST',
                            value:
                                '${(product.cgstRate * 100).toInt()}% / ${(product.sgstRate * 100).toInt()}%',
                          ),
                          MobileCardAttribute(
                            label: 'Base Unit',
                            value: product.unitOfMeasure,
                          ),
                        ],
                        onTap: () {
                          ref.read(selectedProductIdProvider.notifier).state =
                              product.id;
                          if (onMobileTap != null) {
                            onMobileTap!(product);
                          }
                        },
                      );
                    },
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.brandAmber),
                ),
                error: (err, _) => Center(
                  child: AppErrorWidget(
                    title: 'Failed to load products',
                    message: err.toString(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductDetailView extends ConsumerWidget {
  const _ProductDetailView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMobile = context.isMobile;
    final selectedId = ref.watch(selectedProductIdProvider);

    if (selectedId == null) {
      const emptyWidget = Center(
        child: EmptyStateWidget(
          icon: Icons.inventory_2_rounded,
          title: 'Select a Product',
          subtitle:
              'Choose a product from the left list to view HSN, tax rates, and details.',
        ),
      );
      return isMobile
          ? Scaffold(
              appBar: AppBar(
                title: const Text('Product Details'),
                backgroundColor: AppColors.darkSurface,
                foregroundColor: AppColors.darkTextPrimary,
              ),
              body: const SafeArea(child: emptyWidget),
            )
          : emptyWidget;
    }

    final productAsync = ref.watch(selectedProductProvider);

    return productAsync.when(
      data: (product) => _ProductDetailCard(product: product),
      error: (err, st) {
        final errorWidget = AppErrorWidget(
          title: 'Product Unavailable',
          message: 'Unable to load product details. Please try again.',
          onRetry: () => ref.refresh(selectedProductProvider),
        );
        return isMobile
            ? Scaffold(
                appBar: AppBar(
                  title: const Text('Error'),
                  backgroundColor: AppColors.darkSurface,
                  foregroundColor: AppColors.darkTextPrimary,
                ),
                body: SafeArea(child: errorWidget),
              )
            : errorWidget;
      },
      loading: () {
        const loadingWidget = Center(
          child: CircularProgressIndicator(color: AppColors.brandAmber),
        );
        return isMobile
            ? Scaffold(
                appBar: AppBar(
                  title: const Text('Loading...'),
                  backgroundColor: AppColors.darkSurface,
                  foregroundColor: AppColors.darkTextPrimary,
                ),
                body: const SafeArea(child: loadingWidget),
              )
            : loadingWidget;
      },
    );
  }
}

class _ProductDetailCard extends ConsumerWidget {
  const _ProductDetailCard({required this.product});
  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDeleted = product.deletedAt != null;
    final isMobile = context.isMobile;

    if (isMobile) {
      return _buildMobileProductDetail(context, ref, product, isDeleted);
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.brandAmber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.inventory_2_rounded,
                  color: AppColors.brandAmber,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Code: ${product.productCode} • Unit: ${product.unitOfMeasure}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.darkTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  if (!isDeleted) ...[
                    IconButton(
                      icon: Icon(
                        Icons.edit_outlined,
                        color: AppColors.darkTextPrimary,
                      ),
                      onPressed: () {
                        showDialog<void>(
                          context: context,
                          builder: (context) =>
                              ProductFormDialog(product: product),
                        );
                      },
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: AppColors.error,
                      ),
                      onPressed: () async {
                        final confirm = await showConfirmDialog(
                          context: context,
                          title: 'Soft-Delete Product',
                          message:
                              'Are you sure you want to delete this product? Transactions using this product will remain intact.',
                        );
                        if (confirm == true) {
                          await ref
                              .read(productsListProvider.notifier)
                              .deleteProduct(product.id);
                        }
                      },
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Divider(color: AppColors.darkBorder),
          const SizedBox(height: 24),

          // Details Grid
          Expanded(
            child: AdaptiveGrid.fixed(
              columns: const {
                ScreenType.mobile: 1,
                ScreenType.smallTablet: 2,
                ScreenType.tablet: 2,
                ScreenType.desktop: 2,
                ScreenType.wideDesktop: 2,
              },
              childAspectRatio: context.responsiveValue(
                desktop: 2.5,
                tablet: 2.3,
                smallTablet: 2.2,
                mobile: 3.0,
              ),
              spacing: 24,
              runSpacing: 24,
              children: [
                _buildInfoTile('HSN Code', product.hsnCode, Icons.tag),
                _buildInfoTile(
                  'GST Rate',
                  '${(product.gstRate * 100).toInt()}%',
                  Icons.percent,
                ),
                _buildInfoTile(
                  'CGST Rate',
                  '${(product.cgstRate * 100).toInt()}%',
                  Icons.arrow_downward,
                ),
                _buildInfoTile(
                  'SGST Rate',
                  '${(product.sgstRate * 100).toInt()}%',
                  Icons.arrow_downward,
                ),
                _buildInfoTile(
                  'IGST Rate',
                  '${(product.igstRate * 100).toInt()}%',
                  Icons.arrow_upward,
                ),
                _buildInfoTile(
                  'Current Selling Price',
                  product.currentSellingPrice != null
                      ? '₹${product.currentSellingPrice!.toStringAsFixed(2)} / ${product.unitOfMeasure}'
                      : 'Not configured',
                  Icons.currency_rupee,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.brandAmber, size: 24),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.darkTextTertiary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkTextPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMobileProductDetail(
    BuildContext context,
    WidgetRef ref,
    Product product,
    bool isDeleted,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: isDark
            ? AppColors.darkSurface
            : AppColors.lightSurface,
        foregroundColor: isDark
            ? AppColors.darkTextPrimary
            : AppColors.lightTextPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            ref.read(selectedProductIdProvider.notifier).state = null;
            Navigator.of(context).pop();
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product.name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              'Code: ${product.productCode}',
              style: TextStyle(
                fontSize: 11,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
        actions: [
          if (!isDeleted)
            IconButton(
              icon: const Icon(
                Icons.edit_outlined,
                color: AppColors.brandAmber,
              ),
              tooltip: 'Edit Product',
              onPressed: () {
                showDialog<void>(
                  context: context,
                  builder: (ctx) => ProductFormDialog(product: product),
                );
              },
            ),
        ],
      ),
      bottomNavigationBar: !isDeleted
          ? SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSurface
                      : AppColors.lightSurface,
                  border: Border(
                    top: BorderSide(
                      color: isDark
                          ? AppColors.darkBorder
                          : AppColors.lightBorder,
                    ),
                  ),
                ),
                child: PrimaryButton(
                  label: 'Edit Product Details',
                  icon: Icons.edit_rounded,
                  onPressed: () {
                    showDialog<void>(
                      context: context,
                      builder: (ctx) => ProductFormDialog(product: product),
                    );
                  },
                ),
              ),
            )
          : null,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Price & Status Hero Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'SELLING PRICE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: isDark
                              ? AppColors.darkTextTertiary
                              : AppColors.lightTextTertiary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: isDeleted
                              ? AppColors.error.withValues(alpha: 0.15)
                              : AppColors.success.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          isDeleted ? 'ARCHIVED' : 'ACTIVE',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isDeleted
                                ? AppColors.error
                                : AppColors.success,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        product.currentSellingPrice != null
                            ? '₹${product.currentSellingPrice!.toStringAsFixed(2)}'
                            : 'Not Configured',
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: AppColors.brandAmber,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '/ ${product.unitOfMeasure}',
                        style: TextStyle(
                          fontSize: 15,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                  if (product.description != null &&
                      product.description!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      product.description!,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Tax Structure Card
            Text(
              'TAX STRUCTURE (GST)',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Column(
                children: [
                  _buildMobileDetailRow('HSN Code', product.hsnCode, isDark),
                  Divider(
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                    height: 20,
                  ),
                  _buildMobileDetailRow(
                    'Total GST Rate',
                    '${(product.gstRate * 100).toInt()}%',
                    isDark,
                    isHighlight: true,
                  ),
                  Divider(
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                    height: 20,
                  ),
                  _buildMobileDetailRow(
                    'CGST Rate (Intra-state)',
                    '${(product.cgstRate * 100).toInt()}%',
                    isDark,
                  ),
                  Divider(
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                    height: 20,
                  ),
                  _buildMobileDetailRow(
                    'SGST Rate (Intra-state)',
                    '${(product.sgstRate * 100).toInt()}%',
                    isDark,
                  ),
                  Divider(
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                    height: 20,
                  ),
                  _buildMobileDetailRow(
                    'IGST Rate (Inter-state)',
                    '${(product.igstRate * 100).toInt()}%',
                    isDark,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Product Specifications Card
            Text(
              'SPECIFICATIONS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Column(
                children: [
                  _buildMobileDetailRow(
                    'Product Code',
                    product.productCode,
                    isDark,
                  ),
                  Divider(
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                    height: 20,
                  ),
                  _buildMobileDetailRow(
                    'Base Unit of Measure',
                    product.unitOfMeasure,
                    isDark,
                  ),
                  Divider(
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                    height: 20,
                  ),
                  _buildMobileDetailRow(
                    'Status',
                    isDeleted ? 'Archived' : 'Active',
                    isDark,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileDetailRow(
    String label,
    String value,
    bool isDark, {
    bool isHighlight = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
            color: isHighlight
                ? AppColors.brandAmber
                : (isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary),
          ),
        ),
      ],
    );
  }
}

class ProductFormDialog extends ConsumerStatefulWidget {
  const ProductFormDialog({super.key, this.product});
  final Product? product;

  @override
  ConsumerState<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends ConsumerState<ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _codeController;
  late TextEditingController _descriptionController;
  late TextEditingController _hsnController;
  late TextEditingController _priceController;
  late double _gstRate;
  late String _unit;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameController = TextEditingController(text: p?.name ?? '');
    _codeController = TextEditingController(text: p?.productCode ?? '');
    _descriptionController = TextEditingController(text: p?.description ?? '');
    _hsnController = TextEditingController(text: p?.hsnCode ?? '');
    _priceController = TextEditingController(
      text: p?.currentSellingPrice?.toString() ?? '',
    );
    _gstRate = p?.gstRate ?? 0.18;
    _unit = p?.unitOfMeasure ?? 'LTRS';
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.product != null;

    return Dialog(
      backgroundColor: AppColors.darkSurface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEdit ? 'Edit Product' : 'Add Product',
                    style: TextStyle(
                      color: AppColors.darkTextPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _codeController,
                    label: 'Product Code *',
                    hint: 'e.g. HSD-001',
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _nameController,
                    label: 'Product Name *',
                    hint: 'e.g. High Speed Diesel',
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _descriptionController,
                    label: 'Description',
                    hint: 'Optional product overview',
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _hsnController,
                    label: 'HSN Code *',
                    hint: 'e.g. 2710',
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _unit,
                    dropdownColor: AppColors.darkSurface,
                    decoration: const InputDecoration(
                      labelText: 'Unit of Measure',
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'LTRS',
                        child: Text('Litres (LTRS)'),
                      ),
                      DropdownMenuItem(
                        value: 'KL',
                        child: Text('Kilolitres (KL)'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _unit = val);
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<double>(
                    initialValue: _gstRate,
                    dropdownColor: AppColors.darkSurface,
                    decoration: const InputDecoration(
                      labelText: 'GST Tax Rate',
                    ),
                    items: const [
                      DropdownMenuItem(value: 0.0, child: Text('Exempt (0%)')),
                      DropdownMenuItem(
                        value: 0.05,
                        child: Text('Standard (5%)'),
                      ),
                      DropdownMenuItem(
                        value: 0.12,
                        child: Text('Standard (12%)'),
                      ),
                      DropdownMenuItem(
                        value: 0.18,
                        child: Text('Standard (18%)'),
                      ),
                      DropdownMenuItem(
                        value: 0.28,
                        child: Text('Luxury (28%)'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _gstRate = val);
                    },
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _priceController,
                    label: 'Selling Price (optional)',
                    hint: 'e.g. 89.50',
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Cancel',
                          style: TextStyle(color: AppColors.darkTextSecondary),
                        ),
                      ),
                      const SizedBox(width: 12),
                      PrimaryButton(
                        label: 'Save',
                        onPressed: () async {
                          if (!_formKey.currentState!.validate()) return;
                          final price = double.tryParse(_priceController.text);
                          final product = Product(
                            id: widget.product?.id ?? const Uuid().v4(),
                            productCode: _codeController.text.trim(),
                            name: _nameController.text.trim(),
                            description:
                                _descriptionController.text.trim().isEmpty
                                ? null
                                : _descriptionController.text.trim(),
                            hsnCode: _hsnController.text.trim(),
                            unitOfMeasure: _unit,
                            gstRate: _gstRate,
                            cgstRate: _gstRate / 2,
                            sgstRate: _gstRate / 2,
                            igstRate: _gstRate,
                            currentSellingPrice: price,
                            isActive: widget.product?.isActive ?? true,
                            createdBy: widget.product?.createdBy ?? 'system',
                            createdAt:
                                widget.product?.createdAt ?? DateTime.now(),
                            updatedBy: 'system',
                            updatedAt: DateTime.now(),
                            version: widget.product?.version ?? 1,
                          );

                          await ref
                              .read(productsListProvider.notifier)
                              .saveProduct(product);
                          if (context.mounted) Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

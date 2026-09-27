import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:step_up_fuels/app/di/injection_container.dart';
import 'package:step_up_fuels/core/responsive/adaptive_form.dart';
import 'package:step_up_fuels/core/responsive/adaptive_master_detail.dart';
import 'package:step_up_fuels/core/responsive/breakpoints.dart';
import 'package:step_up_fuels/core/services/location/administrative_location_service.dart';
import 'package:step_up_fuels/core/theme/app_colors.dart';
import 'package:step_up_fuels/core/theme/dimensions.dart';
import 'package:step_up_fuels/features/customers/domain/entities/customer.dart';
import 'package:step_up_fuels/features/customers/domain/entities/customer_contact.dart';
import 'package:step_up_fuels/features/customers/domain/entities/customer_type.dart';
import 'package:step_up_fuels/features/customers/domain/entities/fuel_type.dart';
import 'package:step_up_fuels/features/customers/domain/entities/payment_terms.dart';
import 'package:step_up_fuels/features/customers/domain/repositories/customer_repository.dart';
import 'package:step_up_fuels/features/customers/presentation/providers/customers_provider.dart';
import 'package:step_up_fuels/features/customers/presentation/widgets/customer_form_dialog.dart';
import 'package:step_up_fuels/features/invoices/domain/entities/invoice.dart';
import 'package:step_up_fuels/features/invoices/domain/entities/invoice_item.dart';
import 'package:step_up_fuels/features/invoices/domain/services/gst_calculation_service.dart';
import 'package:step_up_fuels/features/invoices/domain/services/pdf_invoice_generator.dart';
import 'package:step_up_fuels/features/invoices/presentation/providers/invoices_provider.dart';
import 'package:step_up_fuels/features/payments/domain/entities/payment.dart';
import 'package:step_up_fuels/features/payments/domain/entities/payment_allocation.dart';
import 'package:step_up_fuels/features/payments/presentation/providers/payments_provider.dart';
import 'package:step_up_fuels/features/payments/presentation/screens/payments_screen.dart';
import 'package:step_up_fuels/features/products/domain/entities/product.dart';
import 'package:step_up_fuels/features/products/presentation/providers/products_provider.dart';
import 'package:step_up_fuels/shared/providers/theme_provider.dart';
import 'package:step_up_fuels/shared/widgets/cards/entity_status_presentation.dart';
import 'package:step_up_fuels/shared/widgets/cards/financial_breakdown.dart';
import 'package:step_up_fuels/shared/widgets/cards/mobile_card.dart';
import 'package:step_up_fuels/shared/widgets/dialogs/responsive_dialog.dart';
import 'package:step_up_fuels/shared/widgets/empty_states/app_error_widget.dart';
import 'package:step_up_fuels/shared/widgets/empty_states/empty_state_widget.dart';
import 'package:step_up_fuels/shared/widgets/inputs/app_date_picker.dart';
import 'package:step_up_fuels/shared/widgets/inputs/app_text_field.dart';
import 'package:step_up_fuels/shared/widgets/layout/adaptive_line_item_layout.dart';
import 'package:step_up_fuels/shared/widgets/layout/app_filter_chips_bar.dart';
import 'package:step_up_fuels/shared/widgets/layout/app_mobile_header.dart';
import 'package:step_up_fuels/shared/widgets/templates/detail_page_template.dart';
import 'package:uuid/uuid.dart';

class InvoicesScreen extends ConsumerStatefulWidget {
  const InvoicesScreen({super.key});

  @override
  ConsumerState<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends ConsumerState<InvoicesScreen> {
  final _searchCtrl = TextEditingController();
  static const _uuid = Uuid();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(themeModeProvider);
    final invoicesAsync = ref.watch(invoicesListProvider);
    final selectedId = ref.watch(selectedInvoiceIdProvider);
    final statusFilter = ref.watch(invoiceStatusFilterProvider);
    final isMobileOrSmall = context.isMobileOrSmallTablet;

    if (context.isMobile) {
      return _buildMobileInvoices(
        context: context,
        invoicesAsync: invoicesAsync,
        statusFilter: statusFilter,
      );
    }

    final masterWidget = Column(
      children: [
        _buildHeader(context, statusFilter),
        _buildSearchAndFilters(),
        Expanded(
          child: invoicesAsync.when(
            data: (invoices) =>
                _buildInvoiceList(invoices, selectedId, isMobileOrSmall),
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.brandAmber),
            ),
            error: (e, _) => AppErrorWidget(
              message: 'Failed to load invoices. Please try again.',
              onRetry: () => ref.refresh(invoicesListProvider),
            ),
          ),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: AdaptiveMasterDetail(
        masterWidth: AppDimensions.masterListWidth(context),
        hasSelection: selectedId != null,
        master: masterWidget,
        detail: _InvoiceDetailPanel(
          invoiceId: selectedId ?? '',
          onClose: () {
            ref.read(selectedInvoiceIdProvider.notifier).state = null;
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCreateInvoiceDialog(context),
        backgroundColor: AppColors.brandAmber,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'New Invoice',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, InvoiceStatus? statusFilter) {
    final isNarrow = context.isMobileOrSmallTablet;
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 0),
      child: isNarrow
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: AppColors.gradientInvoices,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.receipt_long_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Invoices',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkTextPrimary,
                            ),
                          ),
                          Text(
                            'GST-compliant tax invoices',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.darkTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildStatSummary(),
              ],
            )
          : Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: AppColors.gradientInvoices,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.receipt_long_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Invoices',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkTextPrimary,
                        ),
                      ),
                      Text(
                        'GST-compliant tax invoices',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.darkTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                _buildStatSummary(),
              ],
            ),
    );
  }

  Widget _buildStatSummary() {
    final invoicesAsync = ref.watch(invoicesListProvider);
    return invoicesAsync.when(
      data: (invoices) {
        final total = invoices.length;
        final outstanding = invoices
            .where(
              (i) =>
                  i.status == InvoiceStatus.posted ||
                  i.status == InvoiceStatus.partiallyPaid ||
                  i.status == InvoiceStatus.overdue,
            )
            .fold<double>(0, (s, i) => s + i.outstanding);

        return Row(
          children: [
            Text(
              '$total invoices',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.darkTextSecondary,
              ),
            ),
            if (outstanding > 0) ...[
              Text(
                '  •  ',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.darkTextTertiary,
                ),
              ),
              Text(
                '₹${_fmt(outstanding)} outstanding',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.statusOverdue,
                ),
              ),
            ],
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildSearchAndFilters() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 16, 28, 8),
      child: AdaptiveFormRow(
        spacing: 12,
        children: [
          // Search
          Container(
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.darkCard,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.darkBorder),
            ),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) =>
                  ref.read(invoiceSearchQueryProvider.notifier).state = v,
              style: TextStyle(color: AppColors.darkTextPrimary, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search by invoice number or customer…',
                hintStyle: TextStyle(
                  color: AppColors.darkTextTertiary,
                  fontSize: 14,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: AppColors.darkTextSecondary,
                  size: 20,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
            ),
          ),
          // Status filter
          _StatusFilterDropdown(),
        ],
      ),
    );
  }

  Widget _buildInvoiceList(
    List<Invoice> invoices,
    String? selectedId,
    bool isMobileOrSmall,
  ) {
    if (invoices.isEmpty) {
      return _EmptyInvoicesPlaceholder(
        onNew: () => _openCreateInvoiceDialog(context),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(28, 8, 28, 100),
      itemCount: invoices.length,
      separatorBuilder: (_, __) => const SizedBox(height: 6),
      itemBuilder: (context, i) {
        final inv = invoices[i];
        final isSelected = inv.id == selectedId;
        return _InvoiceListTile(
          invoice: inv,
          isSelected: isSelected,
          onTap: () {
            ref.read(selectedInvoiceIdProvider.notifier).state = inv.id;
            if (isMobileOrSmall) {
              Navigator.of(context)
                  .push(
                    MaterialPageRoute<void>(
                      builder: (ctx) => _InvoiceDetailPanel(
                        invoiceId: inv.id,
                        onClose: () {
                          Navigator.of(ctx).pop();
                        },
                      ),
                    ),
                  )
                  .then((_) {
                    ref.read(selectedInvoiceIdProvider.notifier).state = null;
                  });
            }
          },
        );
      },
    );
  }

  Widget _buildMobileInvoices({
    required BuildContext context,
    required AsyncValue<List<Invoice>> invoicesAsync,
    required InvoiceStatus? statusFilter,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCreateInvoiceDialog(context),
        backgroundColor: AppColors.brandAmber,
        foregroundColor: AppColors.brandNavy,
        elevation: 4,
        icon: const Icon(Icons.add_rounded),
        label: Text(
          'New Invoice',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Sticky Mobile Header (Search + KPI Bar + Filter Chips Bar)
            invoicesAsync.maybeWhen(
              data: (invoices) {
                final totalInvoiced = invoices.fold<double>(
                  0,
                  (s, i) => s + i.totalAmount,
                );
                final totalOutstanding = invoices
                    .where(
                      (i) =>
                          i.status == InvoiceStatus.posted ||
                          i.status == InvoiceStatus.partiallyPaid ||
                          i.status == InvoiceStatus.overdue,
                    )
                    .fold<double>(0, (s, i) => s + i.outstanding);

                return AppMobileHeader(
                  searchWidget: AppTextField(
                    controller: _searchCtrl,
                    hint: 'Search invoice # or customer...',
                    prefixIcon: Icons.search_rounded,
                    showClearButton: true,
                    onChanged: (v) =>
                        ref.read(invoiceSearchQueryProvider.notifier).state = v,
                    onClear: () {
                      _searchCtrl.clear();
                      ref.read(invoiceSearchQueryProvider.notifier).state = '';
                    },
                  ),
                  kpis: [
                    AppKpiItem(
                      label: 'TOTAL INVOICED',
                      value:
                          '₹${NumberFormat('#,##,###').format(totalInvoiced)}',
                    ),
                    AppKpiItem(
                      label: 'OUTSTANDING',
                      value:
                          '₹${NumberFormat('#,##,###').format(totalOutstanding)}',
                      labelColor: totalOutstanding > 0
                          ? AppColors.warning
                          : AppColors.success,
                      valueColor: totalOutstanding > 0
                          ? AppColors.warning
                          : AppColors.success,
                    ),
                  ],
                  filterWidget: _buildMobileStatusChips(invoices, statusFilter),
                );
              },
              orElse: () => AppMobileHeader(
                searchWidget: AppTextField(
                  controller: _searchCtrl,
                  hint: 'Search invoice # or customer...',
                  prefixIcon: Icons.search_rounded,
                  showClearButton: true,
                  onChanged: (v) =>
                      ref.read(invoiceSearchQueryProvider.notifier).state = v,
                  onClear: () {
                    _searchCtrl.clear();
                    ref.read(invoiceSearchQueryProvider.notifier).state = '';
                  },
                ),
              ),
            ),

            // Invoices List
            Expanded(
              child: invoicesAsync.when(
                data: (invoices) {
                  if (invoices.isEmpty) {
                    return RefreshIndicator(
                      color: AppColors.brandAmber,
                      onRefresh: () => ref.refresh(invoicesListProvider.future),
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          const SizedBox(height: 60),
                          Center(
                            child: EmptyStateWidget(
                              icon: Icons.receipt_long_outlined,
                              title: 'No Invoices Found',
                              subtitle:
                                  'Tap "New Invoice" to generate your first invoice.',
                              action: ElevatedButton.icon(
                                onPressed: () =>
                                    _openCreateInvoiceDialog(context),
                                icon: const Icon(Icons.add_rounded),
                                label: const Text('Create Invoice'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.brandAmber,
                                  foregroundColor: AppColors.brandNavy,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: AppColors.brandAmber,
                    onRefresh: () => ref.refresh(invoicesListProvider.future),
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                      itemCount: invoices.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final inv = invoices[index];
                        return _buildMobileInvoiceCard(context, inv, isDark);
                      },
                    ),
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.brandAmber),
                ),
                error: (e, _) => Center(
                  child: AppErrorWidget(
                    message: 'Failed to load invoices.',
                    onRetry: () => ref.refresh(invoicesListProvider),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileStatusChips(
    List<Invoice> invoices,
    InvoiceStatus? statusFilter,
  ) {
    final options = <FilterChipOption<InvoiceStatus?>>[
      FilterChipOption(
        value: null,
        label: 'All Invoices',
        count: invoices.length,
      ),
      FilterChipOption(
        value: InvoiceStatus.overdue,
        label: 'Overdue',
        count: invoices.where((i) => i.status == InvoiceStatus.overdue).length,
      ),
      FilterChipOption(
        value: InvoiceStatus.partiallyPaid,
        label: 'Partially Paid',
        count: invoices
            .where((i) => i.status == InvoiceStatus.partiallyPaid)
            .length,
      ),
      FilterChipOption(
        value: InvoiceStatus.posted,
        label: 'Posted',
        count: invoices.where((i) => i.status == InvoiceStatus.posted).length,
      ),
      FilterChipOption(
        value: InvoiceStatus.paid,
        label: 'Paid',
        count: invoices.where((i) => i.status == InvoiceStatus.paid).length,
      ),
      FilterChipOption(
        value: InvoiceStatus.verified,
        label: 'Verified',
        count: invoices.where((i) => i.status == InvoiceStatus.verified).length,
      ),
      FilterChipOption(
        value: InvoiceStatus.draft,
        label: 'Draft',
        count: invoices.where((i) => i.status == InvoiceStatus.draft).length,
      ),
    ];

    return AppFilterChipsBar<InvoiceStatus?>(
      options: options,
      selectedValue: statusFilter,
      onSelected: (val) {
        ref.read(invoiceStatusFilterProvider.notifier).state = val;
      },
    );
  }

  Widget _buildMobileInvoiceCard(
    BuildContext context,
    Invoice inv,
    bool isDark,
  ) {
    final customers = ref.watch(customersListProvider).value ?? [];
    final customer = customers.cast<Customer?>().firstWhere(
      (c) => c?.id == inv.customerId,
      orElse: () => null,
    );
    final customerTitle =
        customer?.name ??
        (inv.customerId.isNotEmpty
            ? 'Customer ID: ${inv.customerId.substring(0, 8)}...'
            : 'Walk-in Customer');

    return MobileCard(
      title: customerTitle,
      subtitle:
          '${inv.invoiceNumber} • ${DateFormat('dd MMM yyyy').format(inv.invoiceDate)}',
      statusBadge: EntityStatusPresentation.invoiceBadge(inv.status),
      heroMetric:
          '₹${NumberFormat('#,##,##0.00', 'en_IN').format(inv.totalAmount)}',
      heroLabel: 'Invoice Amount',
      heroColor: isDark
          ? AppColors.darkTextPrimary
          : AppColors.lightTextPrimary,
      leadingIcon: Icons.receipt_long_rounded,
      attributes: [
        MobileCardAttribute(
          label: 'Due',
          value: DateFormat('dd MMM').format(inv.dueDate),
        ),
        MobileCardAttribute(
          label: 'Balance',
          value: '₹${NumberFormat('#,##,###').format(inv.outstanding)}',
          isHighlighted: inv.outstanding > 0,
        ),
        MobileCardAttribute(label: 'Supply', value: inv.supplyType),
      ],
      actions: [
        if (inv.outstanding > 0)
          TextButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (ctx) => _InvoiceDetailPanel(
                    invoiceId: inv.id,
                    onClose: () => Navigator.of(ctx).pop(),
                  ),
                ),
              );
            },
            icon: const Icon(Icons.payment_rounded, size: 16),
            label: const Text('Record Payment'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.brandAmber,
              visualDensity: VisualDensity.compact,
            ),
          ),
      ],
      onTap: () {
        ref.read(selectedInvoiceIdProvider.notifier).state = inv.id;
        Navigator.of(context)
            .push(
              MaterialPageRoute<void>(
                builder: (ctx) => _InvoiceDetailPanel(
                  invoiceId: inv.id,
                  onClose: () => Navigator.of(ctx).pop(),
                ),
              ),
            )
            .then((_) {
              ref.read(selectedInvoiceIdProvider.notifier).state = null;
            });
      },
    );
  }

  void _openCreateInvoiceDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierColor: AppColors.scrim,
      builder: (_) => const _CreateInvoiceDialog(uuid: _uuid),
    );
  }
}

// ── Status Filter Dropdown ────────────────────────────────────────────────────

class _StatusFilterDropdown extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(invoiceStatusFilterProvider);

    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<InvoiceStatus?>(
          value: current,
          dropdownColor: AppColors.darkCard,
          style: TextStyle(color: AppColors.darkTextPrimary, fontSize: 13),
          hint: Text(
            'All Statuses',
            style: TextStyle(color: AppColors.darkTextSecondary, fontSize: 13),
          ),
          items: [
            const DropdownMenuItem<InvoiceStatus?>(child: Text('All Statuses')),
            ...InvoiceStatus.values.map(
              (s) => DropdownMenuItem(
                value: s,
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _statusColor(s),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(s.displayName),
                  ],
                ),
              ),
            ),
          ],
          onChanged: (v) =>
              ref.read(invoiceStatusFilterProvider.notifier).state = v,
        ),
      ),
    );
  }
}

// ── Invoice List Tile ─────────────────────────────────────────────────────────

class _InvoiceListTile extends ConsumerWidget {
  const _InvoiceListTile({
    required this.invoice,
    required this.isSelected,
    required this.onTap,
  });

  final Invoice invoice;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOverdue = !isSelected && invoice.status == InvoiceStatus.overdue;
    final customers = ref.watch(customersListProvider).value ?? [];
    final customer = customers.cast<Customer?>().firstWhere(
      (c) => c?.id == invoice.customerId,
      orElse: () => null,
    );
    final customerDisplay =
        customer?.name ?? (invoice.customerId.isNotEmpty ? 'Customer' : 'N/A');

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.darkCard : AppColors.darkSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSelected
              ? AppColors.brandAmber.withValues(alpha: 0.6)
              : isOverdue
              ? AppColors.error.withValues(alpha: 0.35)
              : AppColors.darkBorder,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Invoice info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            invoice.invoiceNumber,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.darkTextPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        EntityStatusPresentation.invoiceBadge(invoice.status),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      customerDisplay,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.darkTextSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${DateFormat('dd MMM yyyy').format(invoice.invoiceDate)}  •  Due: ${DateFormat('dd MMM yyyy').format(invoice.dueDate)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.darkTextTertiary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Amount
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '₹${_fmt(invoice.totalAmount)}',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        fontFeatures: const [FontFeature.tabularFigures()],
                        color: AppColors.darkTextPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (invoice.outstanding > 0)
                    Text(
                      'Due: ₹${_fmt(invoice.outstanding)}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        fontFeatures: [FontFeature.tabularFigures()],
                        color: AppColors.statusOverdue,
                      ),
                    )
                  else if (invoice.status == InvoiceStatus.paid)
                    const Text(
                      'Settled ✓',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.success,
                      ),
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

// ── Invoice Detail Panel ──────────────────────────────────────────────────────

class _InvoiceDetailPanel extends ConsumerWidget {
  const _InvoiceDetailPanel({required this.invoiceId, required this.onClose});

  final String invoiceId;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(invoiceDetailProvider(invoiceId));

    return detailAsync.when(
      data: (detail) => _DetailContent(detail: detail, onClose: onClose),
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.brandAmber),
      ),
      error: (e, _) => Center(
        child: Text(
          e.toString(),
          style: const TextStyle(color: AppColors.error),
        ),
      ),
    );
  }
}

class _DetailContent extends ConsumerWidget {
  const _DetailContent({required this.detail, required this.onClose});

  final ({Invoice invoice, List<InvoiceItem> items}) detail;
  final VoidCallback onClose;

  Future<void> _handleReceiveFullPayment(
    BuildContext context,
    WidgetRef ref,
    Invoice inv,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkCard,
        title: Text(
          'Receive Full Payment',
          style: TextStyle(color: AppColors.darkTextPrimary),
        ),
        content: Text(
          'Are you sure you want to record full receipt of ₹${_fmt(inv.outstanding)} for this invoice?',
          style: TextStyle(color: AppColors.darkTextSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brandAmber,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Confirm',
              style: TextStyle(color: AppColors.darkBackground),
            ),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final payment = Payment(
        id: const Uuid().v4(),
        paymentNumber: 'PENDING',
        customerId: inv.customerId,
        invoiceId: inv.id,
        amount: inv.outstanding,
        paymentDate: DateTime.now(),
        paymentMode: 'BANK_TRANSFER',
        notes: 'Full payment received directly from Invoice screen.',
        status: PaymentStatus.posted,
        createdBy: 'system',
        createdAt: DateTime.now(),
        updatedBy: 'system',
        updatedAt: DateTime.now(),
        version: 1,
      );
      try {
        await ref
            .read(paymentsListProvider.notifier)
            .receivePayment(payment, autoAllocate: false);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Full payment receipt saved successfully!'),
              backgroundColor: AppColors.success,
            ),
          );
          ref.invalidate(invoiceDetailProvider(inv.id));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to save receipt: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inv = detail.invoice;
    final items = detail.items;
    final isMobile = context.isMobile;
    final customers = ref.watch(customersListProvider).value ?? [];
    final customer = customers.cast<Customer?>().firstWhere(
      (c) => c?.id == inv.customerId,
      orElse: () => null,
    );

    final bodyWidgets = [
      FinancialBreakdown(
        subtotal: inv.subtotal,
        taxRows: [
          if (!inv.isInterstate) ...[
            FinancialTaxLine(label: 'CGST', amount: inv.cgstAmount),
            FinancialTaxLine(label: 'SGST', amount: inv.sgstAmount),
          ] else ...[
            FinancialTaxLine(label: 'IGST', amount: inv.igstAmount),
          ],
        ],
        total: inv.totalAmount,
        outstanding: inv.outstanding,
      ),

      const SizedBox(height: 20),
      const _SectionHeader('Invoice Details'),
      const SizedBox(height: 10),
      _MetaRow('Customer', customer?.name ?? 'Unknown Customer'),
      if (customer != null && customer.customerCode.isNotEmpty)
        _MetaRow('Customer Code', customer.customerCode),
      _MetaRow('Supply Type', inv.supplyType),
      _MetaRow('Place of Supply', inv.placeOfSupply),
      _MetaRow(
        'GST Type',
        inv.isInterstate ? 'Interstate (IGST)' : 'Intrastate (CGST+SGST)',
      ),
      _MetaRow(
        'Invoice Date',
        DateFormat('dd MMM yyyy').format(inv.invoiceDate),
      ),
      _MetaRow('Due Date', DateFormat('dd MMM yyyy').format(inv.dueDate)),
      if (inv.notes != null && inv.notes!.isNotEmpty)
        _MetaRow('Notes', inv.notes!),
      if (inv.cancelledReason != null)
        _MetaRow(
          'Cancel Reason',
          inv.cancelledReason!,
          valueColor: AppColors.error,
        ),

      const SizedBox(height: 20),
      const _SectionHeader('Payment Status'),
      const SizedBox(height: 10),
      _MetaRow(
        'Amount Paid',
        '₹${_fmt(inv.amountPaid)}',
        valueColor: AppColors.success,
      ),
      _MetaRow(
        'Outstanding',
        '₹${_fmt(inv.outstanding)}',
        valueColor: inv.outstanding > 0
            ? AppColors.statusOverdue
            : AppColors.success,
      ),

      if (inv.outstanding > 0 &&
          (inv.status == InvoiceStatus.posted ||
              inv.status == InvoiceStatus.partiallyPaid ||
              inv.status == InvoiceStatus.overdue)) ...[
        const SizedBox(height: 12),
        if (isMobile)
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandAmber,
                  foregroundColor: AppColors.darkBackground,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.payment_rounded, size: 16),
                label: const Text(
                  'Record Payment',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  showDialog<void>(
                    context: context,
                    builder: (context) => RecordPaymentDialog(
                      preSelectedCustomerId: inv.customerId,
                      preSelectedInvoiceId: inv.id,
                      preFilledAmount: inv.outstanding,
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.brandAmber,
                  side: const BorderSide(color: AppColors.brandAmber),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.done_all_rounded, size: 16),
                label: const Text(
                  'Receive Full Payment',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                onPressed: () => _handleReceiveFullPayment(context, ref, inv),
              ),
            ],
          )
        else
          Row(
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandAmber,
                  foregroundColor: AppColors.darkBackground,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.payment_rounded, size: 16),
                label: const Text(
                  'Record Payment',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  showDialog<void>(
                    context: context,
                    builder: (context) => RecordPaymentDialog(
                      preSelectedCustomerId: inv.customerId,
                      preSelectedInvoiceId: inv.id,
                      preFilledAmount: inv.outstanding,
                    ),
                  );
                },
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.brandAmber,
                  side: const BorderSide(color: AppColors.brandAmber),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.done_all_rounded, size: 16),
                label: const Text(
                  'Receive Full Payment',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                onPressed: () => _handleReceiveFullPayment(context, ref, inv),
              ),
            ],
          ),
      ],

      const SizedBox(height: 24),
      const _SectionHeader('Payment History'),
      const SizedBox(height: 10),
      ref
          .watch(paymentAllocationsForInvoiceProvider(inv.id))
          .when(
            data: (allocs) {
              if (allocs.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'No payments recorded yet for this invoice.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.darkTextSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                );
              }
              final allPayments = ref.watch(paymentsListProvider).value ?? [];
              return Column(
                children: allocs.map((alloc) {
                  final pmt = allPayments.firstWhere(
                    (p) => p.id == alloc.paymentId,
                    orElse: () => Payment(
                      id: '',
                      paymentNumber: 'Unknown PMT',
                      customerId: '',
                      amount: 0,
                      paymentDate: DateTime.now(),
                      paymentMode: '',
                      status: PaymentStatus.posted,
                      createdBy: '',
                      createdAt: DateTime.now(),
                      updatedBy: '',
                      updatedAt: DateTime.now(),
                      version: 1,
                    ),
                  );
                  return Card(
                    color: AppColors.darkSurface,
                    margin: const EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: AppColors.darkBorder),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle_outline_rounded,
                            color: AppColors.success,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  pmt.paymentNumber,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.darkTextPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Date: ${DateFormat('dd MMM yyyy').format(pmt.paymentDate)} • Mode: ${pmt.paymentMode}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppColors.darkTextSecondary,
                                  ),
                                ),
                                if (pmt.notes != null &&
                                    pmt.notes!.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'Note: ${pmt.notes}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: AppColors.darkTextTertiary,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '₹${_fmt(alloc.allocatedAmount)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkTextPrimary,
                                ),
                              ),
                              Text(
                                alloc.type.displayName,
                                style: TextStyle(
                                  fontSize: 9,
                                  color: alloc.type == AllocationType.advance
                                      ? AppColors.brandAmber
                                      : AppColors.darkTextSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.brandAmber,
              ),
            ),
            error: (e, _) => Text(
              'Error loading history: $e',
              style: const TextStyle(color: AppColors.error, fontSize: 11),
            ),
          ),

      const SizedBox(height: 20),
      _SectionHeader('Line Items (${items.length})'),
      const SizedBox(height: 10),
      ...items.map((item) => _LineItemCard(item: item)),
    ];

    if (isMobile) {
      return DetailPageTemplate(
        title: inv.invoiceNumber,
        subtitle: 'Due: ${DateFormat('dd MMM yyyy').format(inv.dueDate)}',
        statusWidget: EntityStatusPresentation.invoiceBadge(inv.status),
        onBack: onClose,
        actions: [
          if (inv.status == InvoiceStatus.draft ||
              inv.status == InvoiceStatus.verified)
            IconButton(
              icon: const Icon(
                Icons.publish_rounded,
                color: AppColors.statusPosted,
              ),
              tooltip: 'Post',
              onPressed: () async {
                try {
                  await ref
                      .read(invoicesListProvider.notifier)
                      .postInvoice(inv.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Invoice posted successfully!'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                    ref.invalidate(invoiceDetailProvider(inv.id));
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(e.toString()),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                }
              },
            ),
          if (inv.isCancellable)
            IconButton(
              icon: const Icon(Icons.cancel_outlined, color: AppColors.error),
              tooltip: 'Cancel',
              onPressed: () => _showCancelDialog(context, ref, inv),
            ),
          IconButton(
            icon: Icon(Icons.print_outlined, color: AppColors.darkTextPrimary),
            onPressed: () async {
              final customers = ref.read(customersListProvider).value ?? [];
              final customer = customers.firstWhere(
                (c) => c.id == inv.customerId,
                orElse: () => Customer(
                  id: inv.customerId,
                  customerCode: '',
                  name: 'Unknown Customer',
                  type: CustomerType.individual,
                  isActive: true,
                  creditLimit: 0,
                  creditDays: 0,
                  securityDeposit: 0,
                  defaultGstRate: 0,
                  emailInvoice: false,
                  whatsappInvoice: false,
                  requirePo: false,
                  requireDc: false,
                  requireSignature: false,
                  gstApplicable: false,
                  eInvoiceRequired: false,
                  eWayBillRequired: false,
                  openingBalance: 0,
                  currentBalance: 0,
                  createdBy: '',
                  createdAt: DateTime.now(),
                  updatedBy: '',
                  updatedAt: DateTime.now(),
                  version: 1,
                ),
              );
              await PdfInvoiceGenerator.printInvoice(
                invoice: inv,
                items: items,
                customer: customer,
              );
            },
            tooltip: 'Print Invoice',
          ),
          IconButton(
            icon: Icon(
              Icons.download_rounded,
              color: AppColors.darkTextPrimary,
            ),
            onPressed: () async {
              final customers = ref.read(customersListProvider).value ?? [];
              final customer = customers.firstWhere(
                (c) => c.id == inv.customerId,
                orElse: () => Customer(
                  id: inv.customerId,
                  customerCode: '',
                  name: 'Unknown Customer',
                  type: CustomerType.individual,
                  isActive: true,
                  creditLimit: 0,
                  creditDays: 0,
                  securityDeposit: 0,
                  defaultGstRate: 0,
                  emailInvoice: false,
                  whatsappInvoice: false,
                  requirePo: false,
                  requireDc: false,
                  requireSignature: false,
                  gstApplicable: false,
                  eInvoiceRequired: false,
                  eWayBillRequired: false,
                  openingBalance: 0,
                  currentBalance: 0,
                  createdBy: '',
                  createdAt: DateTime.now(),
                  updatedBy: '',
                  updatedAt: DateTime.now(),
                  version: 1,
                ),
              );
              await PdfInvoiceGenerator.downloadInvoice(
                invoice: inv,
                items: items,
                customer: customer,
              );
            },
            tooltip: 'Download PDF',
          ),
        ],
        sections: bodyWidgets,
      );
    }

    return Column(
      children: [
        // Header bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.darkBorder)),
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    inv.invoiceNumber,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  EntityStatusPresentation.invoiceBadge(inv.status),
                ],
              ),
              const Spacer(),
              // Action buttons
              if (inv.status == InvoiceStatus.draft ||
                  inv.status == InvoiceStatus.verified)
                _ActionButton(
                  icon: Icons.publish_rounded,
                  label: 'Post',
                  color: AppColors.statusPosted,
                  onTap: () async {
                    try {
                      await ref
                          .read(invoicesListProvider.notifier)
                          .postInvoice(inv.id);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Invoice posted successfully!'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                        ref.invalidate(invoiceDetailProvider(inv.id));
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(e.toString()),
                            backgroundColor: AppColors.error,
                          ),
                        );
                      }
                    }
                  },
                ),
              const SizedBox(width: 8),
              if (inv.isCancellable)
                _ActionButton(
                  icon: Icons.cancel_outlined,
                  label: 'Cancel',
                  color: AppColors.error,
                  onTap: () => _showCancelDialog(context, ref, inv),
                ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(
                  Icons.print_outlined,
                  color: AppColors.darkTextPrimary,
                ),
                onPressed: () async {
                  final customers = ref.read(customersListProvider).value ?? [];
                  final customer = customers.firstWhere(
                    (c) => c.id == inv.customerId,
                    orElse: () => Customer(
                      id: inv.customerId,
                      customerCode: '',
                      name: 'Unknown Customer',
                      type: CustomerType.individual,
                      isActive: true,
                      creditLimit: 0,
                      creditDays: 0,
                      securityDeposit: 0,
                      defaultGstRate: 0,
                      emailInvoice: false,
                      whatsappInvoice: false,
                      requirePo: false,
                      requireDc: false,
                      requireSignature: false,
                      gstApplicable: false,
                      eInvoiceRequired: false,
                      eWayBillRequired: false,
                      openingBalance: 0,
                      currentBalance: 0,
                      createdBy: '',
                      createdAt: DateTime.now(),
                      updatedBy: '',
                      updatedAt: DateTime.now(),
                      version: 1,
                    ),
                  );
                  await PdfInvoiceGenerator.printInvoice(
                    invoice: inv,
                    items: items,
                    customer: customer,
                  );
                },
                tooltip: 'Print Invoice',
              ),
              IconButton(
                icon: Icon(
                  Icons.download_rounded,
                  color: AppColors.darkTextPrimary,
                ),
                onPressed: () async {
                  final customers = ref.read(customersListProvider).value ?? [];
                  final customer = customers.firstWhere(
                    (c) => c.id == inv.customerId,
                    orElse: () => Customer(
                      id: inv.customerId,
                      customerCode: '',
                      name: 'Unknown Customer',
                      type: CustomerType.individual,
                      isActive: true,
                      creditLimit: 0,
                      creditDays: 0,
                      securityDeposit: 0,
                      defaultGstRate: 0,
                      emailInvoice: false,
                      whatsappInvoice: false,
                      requirePo: false,
                      requireDc: false,
                      requireSignature: false,
                      gstApplicable: false,
                      eInvoiceRequired: false,
                      eWayBillRequired: false,
                      openingBalance: 0,
                      currentBalance: 0,
                      createdBy: '',
                      createdAt: DateTime.now(),
                      updatedBy: '',
                      updatedAt: DateTime.now(),
                      version: 1,
                    ),
                  );
                  await PdfInvoiceGenerator.downloadInvoice(
                    invoice: inv,
                    items: items,
                    customer: customer,
                  );
                },
                tooltip: 'Download PDF',
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: onClose,
                icon: Icon(
                  Icons.close_rounded,
                  color: AppColors.darkTextSecondary,
                ),
                tooltip: 'Close',
              ),
            ],
          ),
        ),
        // Body
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: bodyWidgets,
            ),
          ),
        ),
      ],
    );
  }

  void _showCancelDialog(BuildContext context, WidgetRef ref, Invoice inv) {
    final reasonCtrl = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.darkCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Cancel Invoice',
          style: TextStyle(color: AppColors.darkTextPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter a reason for cancelling ${inv.invoiceNumber}',
              style: TextStyle(color: AppColors.darkTextSecondary),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonCtrl,
              style: TextStyle(color: AppColors.darkTextPrimary),
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Reason for cancellation…',
                hintStyle: TextStyle(color: AppColors.darkTextTertiary),
                filled: true,
                fillColor: AppColors.darkSurface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppColors.darkBorder),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Back'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              final reason = reasonCtrl.text.trim();
              if (reason.isEmpty) return;
              Navigator.pop(context);
              try {
                await ref
                    .read(invoicesListProvider.notifier)
                    .cancelInvoice(inv.id, reason);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Invoice cancelled'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  ref.invalidate(invoiceDetailProvider(inv.id));
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(e.toString())));
                }
              }
            },
            child: const Text(
              'Confirm Cancel',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Create Invoice Dialog ─────────────────────────────────────────────────────

class _CreateInvoiceDialog extends ConsumerStatefulWidget {
  const _CreateInvoiceDialog({required this.uuid});
  final Uuid uuid;

  @override
  ConsumerState<_CreateInvoiceDialog> createState() =>
      _CreateInvoiceDialogState();
}

class _CreateInvoiceDialogState extends ConsumerState<_CreateInvoiceDialog> {
  final _formKey = GlobalKey<FormState>();
  Customer? _selectedCustomer;
  final _customerSearchCtrl = TextEditingController();
  final _customerSearchFocus = FocusNode();
  final List<_LineItemDraft> _lineItems = [];
  final _notesCtrl = TextEditingController();
  String _supplyType = 'B2B';
  String _buyerStateCode = '27'; // Maharashtra default
  DateTime _invoiceDate = DateTime.now();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 30));

  // GST calculation service (MH seller by default)
  static const _gstService = GstCalculationService(sellerStateCode: '27');

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _customerSearchFocus.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    _customerSearchCtrl.dispose();
    _customerSearchFocus.dispose();
    super.dispose();
  }

  void _selectCustomer(Customer customer) {
    setState(() {
      _selectedCustomer = customer;
      _customerSearchCtrl.clear();
      _customerSearchFocus.unfocus();

      final state = customer.billingState ?? customer.state;
      if (state != null && state.isNotEmpty) {
        _buyerStateCode = _stateNameToCode(state);
      }

      if (customer.type == CustomerType.individual) {
        _supplyType = 'B2C';
      } else if (customer.gstin != null && customer.gstin!.isNotEmpty) {
        _supplyType = 'B2B';
      }
    });
  }

  void _clearCustomer() {
    setState(() {
      _selectedCustomer = null;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _customerSearchFocus.requestFocus();
      }
    });
  }

  Future<void> _openQuickAddDialog({String? initialQuery}) async {
    final customer = await showDialog<Customer?>(
      context: context,
      barrierColor: AppColors.scrim,
      builder: (_) => _QuickAddCustomerDialog(
        initialQuery: initialQuery,
        uuid: widget.uuid,
      ),
    );

    if (!mounted || customer == null) return;
    _selectCustomer(customer);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: AppColors.success,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Customer "${customer.name}" added & selected for billing!',
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.darkSurface,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final customersAsync = ref.watch(customersListProvider);
    final contactsMap = ref.watch(allPrimaryContactsMapProvider).value ?? {};
    final productsAsync = ref.watch(productsListProvider);

    return ResponsiveDialog(
      title: 'Create New Invoice',
      headerGradient: const LinearGradient(colors: AppColors.gradientInvoices),
      headerIcon: Icons.receipt_long_rounded,
      maxWidth: 780,
      actions: [
        ElevatedButton.icon(
          onPressed: _saving ? null : _saveAndPost,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.brandAmber,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          icon: Icon(Icons.publish_rounded, color: AppColors.darkBackground),
          label: Text(
            'Post Invoice',
            style: TextStyle(
              color: AppColors.darkBackground,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ElevatedButton.icon(
          onPressed: _saving ? null : _saveDraft,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.darkBorderLight,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          icon: _saving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Icon(Icons.save_outlined, color: AppColors.darkTextPrimary),
          label: Text(
            'Save Draft',
            style: TextStyle(color: AppColors.darkTextPrimary),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Smart Customer Selector & Instant Add
            _buildCustomerSelectorSection(customersAsync, contactsMap),
            const SizedBox(height: 16),

            // Dates & Supply Type row
            AdaptiveFormRow(
              children: [
                AppDatePickerField(
                  label: 'Invoice Date',
                  selectedDate: _invoiceDate,
                  onChanged: (d) => setState(() => _invoiceDate = d),
                ),
                AppDatePickerField(
                  label: 'Due Date',
                  selectedDate: _dueDate,
                  onChanged: (d) => setState(() => _dueDate = d),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _FieldLabel('Supply Type'),
                    _dialogDropdown(
                      value: _supplyType,
                      items: const ['B2B', 'B2C'],
                      onChanged: (v) => setState(() => _supplyType = v!),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Place of supply
            AdaptiveFormRow(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _FieldLabel('Buyer State Code'),
                    TextFormField(
                      initialValue: _buyerStateCode,
                      onChanged: (v) =>
                          setState(() => _buyerStateCode = v.trim()),
                      style: TextStyle(color: AppColors.darkTextPrimary),
                      decoration: _inputDecoration('e.g. 27'),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _FieldLabel('Notes (optional)'),
                    TextFormField(
                      controller: _notesCtrl,
                      style: TextStyle(color: AppColors.darkTextPrimary),
                      decoration: _inputDecoration('Additional notes'),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),
            // Line items section
            Row(
              children: [
                Text(
                  'Line Items',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkTextPrimary,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () =>
                      setState(() => _lineItems.add(_LineItemDraft())),
                  icon: const Icon(
                    Icons.add_rounded,
                    color: AppColors.brandAmber,
                    size: 18,
                  ),
                  label: const Text(
                    'Add Item',
                    style: TextStyle(color: AppColors.brandAmber),
                  ),
                ),
              ],
            ),
            if (_lineItems.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.darkSurface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.darkBorder),
                ),
                child: Text(
                  'No line items. Click "Add Item" to add fuel/products.',
                  style: TextStyle(
                    color: AppColors.darkTextSecondary,
                    fontSize: 13,
                  ),
                ),
              )
            else
              ...productsAsync.when(
                data: (products) => _lineItems
                    .asMap()
                    .entries
                    .map(
                      (e) => _LineItemRow(
                        key: ValueKey(e.key),
                        draft: e.value,
                        products: products,
                        gstService: _gstService,
                        buyerStateCode: _buyerStateCode,
                        index: e.key,
                        onRemove: () =>
                            setState(() => _lineItems.removeAt(e.key)),
                        onChanged: () => setState(() {}),
                      ),
                    )
                    .toList(),
                loading: () => [
                  const CircularProgressIndicator(color: AppColors.brandAmber),
                ],
                error: (e, _) => [Text(e.toString())],
              ),

            if (_lineItems.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildTotalsSummary(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerSelectorSection(
    AsyncValue<List<Customer>> customersAsync,
    Map<String, CustomerContact> contactsMap,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const _FieldLabel('Customer *'),
            const Spacer(),
            if (_selectedCustomer == null)
              InkWell(
                onTap: () => _openQuickAddDialog(
                  initialQuery: _customerSearchCtrl.text.trim(),
                ),
                borderRadius: BorderRadius.circular(6),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  child: Row(
                    children: [
                      Icon(
                        Icons.person_add_alt_1_rounded,
                        size: 15,
                        color: AppColors.brandAmber,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'New Customer',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.brandAmber,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        if (_selectedCustomer != null)
          _buildSelectedCustomerCard(contactsMap)
        else
          customersAsync.when(
            data: (customers) =>
                _buildCustomerSearchArea(customers, contactsMap),
            loading: () => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: LinearProgressIndicator(
                color: AppColors.brandAmber,
                backgroundColor: AppColors.darkSurface,
              ),
            ),
            error: (e, _) => Text(
              'Failed to load customers: $e',
              style: const TextStyle(color: AppColors.error),
            ),
          ),
      ],
    );
  }

  Widget _buildSelectedCustomerCard(Map<String, CustomerContact> contactsMap) {
    final customer = _selectedCustomer!;
    final contact = contactsMap[customer.id];
    final isIndividual = customer.type == CustomerType.individual;
    final phone = contact?.phone;
    final city = customer.billingCity;
    final state = customer.billingState ?? customer.state;
    final locationParts = <String>[];
    if (city != null && city.isNotEmpty) locationParts.add(city);
    if (state != null && state.isNotEmpty) locationParts.add(state);
    final locationText = locationParts.join(', ');

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.brandAmber.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon Avatar
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isIndividual
                  ? AppColors.brandAmber.withValues(alpha: 0.15)
                  : Colors.cyan.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isIndividual
                    ? AppColors.brandAmber.withValues(alpha: 0.3)
                    : Colors.cyan.withValues(alpha: 0.3),
              ),
            ),
            child: Icon(
              isIndividual ? Icons.person_rounded : Icons.business_rounded,
              color: isIndividual ? AppColors.brandAmber : Colors.cyanAccent,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        customer.name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkTextPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isIndividual
                            ? AppColors.brandAmber.withValues(alpha: 0.2)
                            : Colors.cyan.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isIndividual ? 'INDIVIDUAL' : 'B2B',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isIndividual
                              ? AppColors.brandAmber
                              : Colors.cyanAccent,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 12,
                  runSpacing: 4,
                  children: [
                    if (phone != null && phone.isNotEmpty)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.phone_outlined,
                            size: 13,
                            color: AppColors.darkTextSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            phone,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.darkTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    if (customer.gstin != null && customer.gstin!.isNotEmpty)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.verified_outlined,
                            size: 13,
                            color: AppColors.success,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            customer.gstin!,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.darkTextSecondary,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    if (locationText.isNotEmpty)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 13,
                            color: AppColors.darkTextSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            locationText,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.darkTextSecondary,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Actions
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 18),
                color: AppColors.darkTextSecondary,
                tooltip: 'Edit Customer Details',
                onPressed: () async {
                  final updated = await showDialog<Customer?>(
                    context: context,
                    builder: (_) => CustomerFormDialog(customer: customer),
                  );
                  if (updated != null && mounted) {
                    _selectCustomer(updated);
                  }
                },
              ),
              OutlinedButton.icon(
                onPressed: _clearCustomer,
                icon: const Icon(Icons.swap_horiz_rounded, size: 16),
                label: const Text('Change'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.darkTextPrimary,
                  side: BorderSide(color: AppColors.darkBorder),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  textStyle: const TextStyle(fontSize: 12),
                  minimumSize: Size.zero,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerSearchArea(
    List<Customer> customers,
    Map<String, CustomerContact> contactsMap,
  ) {
    final query = _customerSearchCtrl.text.trim();
    final queryLower = query.toLowerCase();
    final cleanDigits = query.replaceAll(RegExp(r'\D'), '');

    final List<Customer> matches;
    if (query.isNotEmpty) {
      matches = customers
          .where((c) {
            if (c.name.toLowerCase().contains(queryLower)) {
              return true;
            }
            if (c.displayName?.toLowerCase().contains(queryLower) == true) {
              return true;
            }
            if (c.tradeName?.toLowerCase().contains(queryLower) == true) {
              return true;
            }
            if (c.customerCode.toLowerCase().contains(queryLower)) {
              return true;
            }
            if (c.gstin?.toLowerCase().contains(queryLower) == true) {
              return true;
            }
            if (c.billingCity?.toLowerCase().contains(queryLower) == true) {
              return true;
            }

            if (cleanDigits.isNotEmpty) {
              final phone = contactsMap[c.id]?.phone;
              if (phone != null) {
                final pDigits = phone.replaceAll(RegExp(r'\D'), '');
                if (pDigits.contains(cleanDigits)) {
                  return true;
                }
              }
            }
            return false;
          })
          .take(6)
          .toList();
    } else {
      matches = [];
    }

    final isSearching = query.isNotEmpty || _customerSearchFocus.hasFocus;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search Input Box
        TextFormField(
          controller: _customerSearchCtrl,
          focusNode: _customerSearchFocus,
          style: TextStyle(color: AppColors.darkTextPrimary, fontSize: 14),
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'Type mobile number (e.g. 98765...) or customer name',
            hintStyle: TextStyle(
              color: AppColors.darkTextSecondary,
              fontSize: 13,
            ),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: AppColors.brandAmber,
              size: 20,
            ),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (query.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear_rounded, size: 18),
                    color: AppColors.darkTextSecondary,
                    onPressed: () {
                      _customerSearchCtrl.clear();
                      setState(() {});
                    },
                  ),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ElevatedButton.icon(
                    onPressed: () => _openQuickAddDialog(initialQuery: query),
                    icon: const Icon(Icons.add_rounded, size: 16),
                    label: const Text('Add'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brandAmber.withValues(
                        alpha: 0.2,
                      ),
                      foregroundColor: AppColors.brandAmber,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      minimumSize: Size.zero,
                      textStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            filled: true,
            fillColor: AppColors.darkCard,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.darkBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: isSearching
                    ? AppColors.brandAmber.withValues(alpha: 0.5)
                    : AppColors.darkBorder,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: AppColors.brandAmber,
                width: 1.5,
              ),
            ),
          ),
        ),

        // Live suggestions and Instant Add Option
        if (query.isNotEmpty || _customerSearchFocus.hasFocus) ...[
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.darkBorder),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // If matching customers found
                if (matches.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
                    child: Text(
                      'MATCHING CUSTOMERS',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: AppColors.darkTextTertiary,
                      ),
                    ),
                  ),
                  ...matches.map((c) {
                    final contact = contactsMap[c.id];
                    final phone = contact?.phone;
                    final isIndividual = c.type == CustomerType.individual;
                    return InkWell(
                      onTap: () => _selectCustomer(c),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: AppColors.darkBorder.withValues(
                                alpha: 0.5,
                              ),
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: isIndividual
                                  ? AppColors.brandAmber.withValues(alpha: 0.15)
                                  : Colors.cyan.withValues(alpha: 0.15),
                              child: Icon(
                                isIndividual
                                    ? Icons.person_outline
                                    : Icons.business_outlined,
                                size: 16,
                                color: isIndividual
                                    ? AppColors.brandAmber
                                    : Colors.cyanAccent,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          c.name,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.darkTextPrimary,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (c.customerCode.isNotEmpty) ...[
                                        const SizedBox(width: 6),
                                        Text(
                                          '(${c.customerCode})',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: AppColors.darkTextTertiary,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      if (phone != null &&
                                          phone.isNotEmpty) ...[
                                        Icon(
                                          Icons.phone_outlined,
                                          size: 11,
                                          color: AppColors.darkTextSecondary,
                                        ),
                                        const SizedBox(width: 3),
                                        Text(
                                          phone,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: AppColors.darkTextSecondary,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                      ],
                                      if (c.billingCity != null &&
                                          c.billingCity!.isNotEmpty)
                                        Text(
                                          c.billingCity!,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: AppColors.darkTextTertiary,
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 12,
                              color: AppColors.brandAmber,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ] else if (query.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: AppColors.darkTextSecondary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'No customer found matching "$query"',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.darkTextSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Prominent Quick Add Banner / Tile
                InkWell(
                  onTap: () => _openQuickAddDialog(initialQuery: query),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.brandAmber.withValues(alpha: 0.08),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.brandAmber.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person_add_alt_1_rounded,
                            size: 16,
                            color: AppColors.brandAmber,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                query.isNotEmpty
                                    ? '+ Add "$query" as New Customer'
                                    : '+ Add New Customer',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.brandAmber,
                                ),
                              ),
                              Text(
                                'Instant setup & select for this billing without leaving',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.darkTextSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.brandAmber,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTotalsSummary() {
    double subtotal = 0;
    double cgst = 0;
    double sgst = 0;
    double igst = 0;

    for (final item in _lineItems) {
      if (item.product != null && item.quantity > 0) {
        final gst = _gstService.compute(
          buyerStateCode: _buyerStateCode,
          taxableAmount: item.quantity * item.rate,
          gstRate: item.product!.gstRate,
        );
        subtotal += gst.taxableAmount;
        cgst += gst.cgstAmount;
        sgst += gst.sgstAmount;
        igst += gst.igstAmount;
      }
    }
    final total = subtotal + cgst + sgst + igst;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Column(
        children: [
          _TotalRow('Subtotal (Taxable)', subtotal),
          if (cgst > 0) _TotalRow('CGST', cgst),
          if (sgst > 0) _TotalRow('SGST', sgst),
          if (igst > 0) _TotalRow('IGST', igst),
          Divider(color: AppColors.darkBorder, height: 16),
          _TotalRow(
            'Total Amount',
            total,
            bold: true,
            color: AppColors.brandAmber,
          ),
        ],
      ),
    );
  }

  Widget _dialogDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      dropdownColor: AppColors.darkCard,
      style: TextStyle(color: AppColors.darkTextPrimary, fontSize: 14),
      decoration: _inputDecoration(''),
      items: items
          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
          .toList(),
      onChanged: onChanged,
    );
  }

  Future<void> _saveDraft() async {
    if (_selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please search and select or add a customer first.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    await _buildAndSave(post: false);
  }

  Future<void> _saveAndPost() async {
    if (_selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please search and select or add a customer first.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    if (_lineItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add at least one line item before posting.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    await _buildAndSave(post: true);
  }

  Future<void> _buildAndSave({required bool post}) async {
    setState(() => _saving = true);
    try {
      final customer = _selectedCustomer!;
      final invoiceId = widget.uuid.v4();
      final now = DateTime.now();

      // Build line items
      final items = <InvoiceItem>[];
      int sortIdx = 0;
      double subtotal = 0;
      double cgstTotal = 0;
      double sgstTotal = 0;
      double igstTotal = 0;

      for (final draft in _lineItems) {
        if (draft.product == null) continue;
        final taxable = draft.quantity * draft.rate;
        final gst = _gstService.compute(
          buyerStateCode: _buyerStateCode,
          taxableAmount: taxable,
          gstRate: draft.product!.gstRate,
        );
        subtotal += gst.taxableAmount;
        cgstTotal += gst.cgstAmount;
        sgstTotal += gst.sgstAmount;
        igstTotal += gst.igstAmount;

        items.add(
          InvoiceItem(
            id: widget.uuid.v4(),
            invoiceId: invoiceId,
            productId: draft.product!.id,
            hsnCode: draft.product!.hsnCode,
            description: draft.product!.name,
            quantity: draft.quantity,
            unit: draft.unit,
            rate: draft.rate,
            taxableAmount: gst.taxableAmount,
            gstRate: gst.gstRate,
            cgstRate: gst.cgstRate,
            sgstRate: gst.sgstRate,
            igstRate: gst.igstRate,
            cgstAmount: gst.cgstAmount,
            sgstAmount: gst.sgstAmount,
            igstAmount: gst.igstAmount,
            totalAmount: gst.totalAmount,
            sortOrder: sortIdx++,
          ),
        );
      }

      final total = subtotal + cgstTotal + sgstTotal + igstTotal;
      final invoice = Invoice(
        id: invoiceId,
        invoiceNumber: 'DRAFT', // Will be replaced on post
        customerId: customer.id,
        invoiceDate: _invoiceDate,
        dueDate: _dueDate,
        supplyType: _supplyType,
        placeOfSupply: _buyerStateCode,
        isInterstate: _gstService.sellerStateCode != _buyerStateCode,
        subtotal: subtotal,
        cgstAmount: cgstTotal,
        sgstAmount: sgstTotal,
        igstAmount: igstTotal,
        totalAmount: total,
        amountPaid: 0,
        outstanding: total,
        status: InvoiceStatus.draft,
        notes: _notesCtrl.text.trim().isNotEmpty
            ? _notesCtrl.text.trim()
            : null,
        createdBy: 'system',
        createdAt: now,
        updatedBy: 'system',
        updatedAt: now,
        version: 1,
      );

      await ref.read(invoicesListProvider.notifier).saveInvoice(invoice, items);

      if (post) {
        await ref.read(invoicesListProvider.notifier).postInvoice(invoiceId);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              post
                  ? 'Invoice posted successfully!'
                  : 'Draft saved successfully.',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _stateNameToCode(String stateName) {
    final code = AdministrativeLocationService.instance.getStateGstCode(
      stateName,
    );
    if (code != null) return code;
    final stateMap = {
      'maharashtra': '27',
      'delhi': '07',
      'karnataka': '29',
      'gujarat': '24',
      'tamil Nadu': '33',
      'rajasthan': '08',
      'uttar pradesh': '09',
    };
    return stateMap[stateName.toLowerCase()] ?? '27';
  }
}

// ── Quick Add Customer Dialog ────────────────────────────────────────────────

class _QuickAddCustomerDialog extends ConsumerStatefulWidget {
  const _QuickAddCustomerDialog({this.initialQuery, required this.uuid});

  final String? initialQuery;
  final Uuid uuid;

  @override
  ConsumerState<_QuickAddCustomerDialog> createState() =>
      _QuickAddCustomerDialogState();
}

class _QuickAddCustomerDialogState
    extends ConsumerState<_QuickAddCustomerDialog> {
  final _formKey = GlobalKey<FormState>();
  CustomerType _selectedType = CustomerType.individual;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  final _emailCtrl = TextEditingController();
  final _gstinCtrl = TextEditingController();

  String? _selectedState = 'Maharashtra';
  String? _selectedDistrict;
  List<String> _districts = [];

  bool _saving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final query = (widget.initialQuery ?? '').trim();
    final digitsOnly = query.replaceAll(RegExp(r'\D'), '');

    if (digitsOnly.length >= 6 && digitsOnly.length == query.length) {
      _phoneCtrl = TextEditingController(text: digitsOnly);
      _nameCtrl = TextEditingController();
      _selectedType = CustomerType.individual;
    } else {
      _phoneCtrl = TextEditingController();
      _nameCtrl = TextEditingController(text: query);
      _selectedType = CustomerType.individual;
    }

    _loadDistricts();
  }

  void _loadDistricts() {
    if (_selectedState != null) {
      _districts = AdministrativeLocationService.instance.getDistricts(
        _selectedState,
      );
      if (_districts.isNotEmpty && !_districts.contains(_selectedDistrict)) {
        _selectedDistrict = _districts.first;
      }
    } else {
      _districts = [];
      _selectedDistrict = null;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _gstinCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    setState(() {
      _saving = true;
      _errorMessage = null;
    });

    try {
      final name = _nameCtrl.text.trim();
      final phone = _phoneCtrl.text.trim();
      final email = _emailCtrl.text.trim();
      final gstin = _gstinCtrl.text.trim().toUpperCase();

      final customerName = name.isNotEmpty
          ? name
          : (phone.isNotEmpty ? 'Customer $phone' : 'Retail Customer');

      final customerId = widget.uuid.v4();
      final customer = Customer.newCustomer(
        id: customerId,
        customerCode: 'CUST-${DateTime.now().millisecondsSinceEpoch % 1000000}',
        name: customerName,
        displayName: customerName,
        type: _selectedType,
        gstin: gstin.isNotEmpty ? gstin : null,
        state: _selectedState,
        placeOfSupply: _selectedState,
        billingState: _selectedState,
        billingCity: _selectedDistrict,
        billingCountry: 'India',
        paymentTerms: PaymentTerms.advance,
        fuelType: FuelType.diesel,
        defaultGstRate: 0.18,
      );

      // Create Customer
      await ref.read(customersListProvider.notifier).createCustomer(customer);

      // Create Primary Contact if phone or email was provided
      if (phone.isNotEmpty || email.isNotEmpty) {
        try {
          final contact = CustomerContact.newContact(
            id: widget.uuid.v4(),
            customerId: customerId,
            name: customerName,
            phone: phone.isNotEmpty ? phone : null,
            email: email.isNotEmpty ? email : null,
            isPrimary: true,
          );
          await sl<CustomerRepository>().saveContact(contact);
          ref.invalidate(allPrimaryContactsMapProvider);
        } catch (_) {}
      }

      if (mounted) {
        Navigator.of(context).pop(customer);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _saving = false;
        });
      }
    }
  }

  Future<void> _openFullForm() async {
    final fullCustomer = await showDialog<Customer?>(
      context: context,
      builder: (_) => CustomerFormDialog(
        initialName: _nameCtrl.text.trim().isNotEmpty
            ? _nameCtrl.text.trim()
            : null,
        initialPhone: _phoneCtrl.text.trim().isNotEmpty
            ? _phoneCtrl.text.trim()
            : null,
        initialType: _selectedType,
      ),
    );
    if (fullCustomer != null && mounted) {
      Navigator.of(context).pop(fullCustomer);
    }
  }

  @override
  Widget build(BuildContext context) {
    final states = AdministrativeLocationService.instance.getStates();

    return Dialog(
      backgroundColor: AppColors.darkSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.darkBorder),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.brandAmber.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.person_add_alt_1_rounded,
                        color: AppColors.brandAmber,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Quick Add Customer',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.darkTextPrimary,
                            ),
                          ),
                          Text(
                            'Register instantly and proceed with billing',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.darkTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      color: AppColors.darkTextSecondary,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.error.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: AppColors.error,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Customer Type Selector
                SegmentedButton<CustomerType>(
                  segments: const [
                    ButtonSegment(
                      value: CustomerType.individual,
                      label: Text('Individual / Retail'),
                      icon: Icon(Icons.person_outline, size: 16),
                    ),
                    ButtonSegment(
                      value: CustomerType.company,
                      label: Text('Company / B2B'),
                      icon: Icon(Icons.business_outlined, size: 16),
                    ),
                  ],
                  selected: {_selectedType},
                  onSelectionChanged: (set) {
                    setState(() => _selectedType = set.first);
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.resolveWith(
                      (states) => states.contains(WidgetState.selected)
                          ? AppColors.brandAmber.withValues(alpha: 0.2)
                          : AppColors.darkCard,
                    ),
                    foregroundColor: WidgetStateProperty.resolveWith(
                      (states) => states.contains(WidgetState.selected)
                          ? AppColors.brandAmber
                          : AppColors.darkTextSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Name field
                TextFormField(
                  controller: _nameCtrl,
                  autofocus: _phoneCtrl.text.isNotEmpty,
                  style: TextStyle(
                    color: AppColors.darkTextPrimary,
                    fontSize: 14,
                  ),
                  decoration:
                      _inputDecoration(
                        _selectedType == CustomerType.individual
                            ? 'Customer Full Name (e.g. Ramesh Patil)'
                            : 'Company / Business Name',
                      ).copyWith(
                        labelText: _selectedType == CustomerType.individual
                            ? 'Customer Name'
                            : 'Company Name',
                        labelStyle: TextStyle(
                          color: AppColors.darkTextSecondary,
                          fontSize: 13,
                        ),
                        prefixIcon: Icon(
                          Icons.badge_outlined,
                          size: 18,
                          color: AppColors.darkTextSecondary,
                        ),
                      ),
                ),
                const SizedBox(height: 12),

                // Mobile Number & Email Row
                Row(
                  children: [
                    Expanded(
                      flex: 6,
                      child: TextFormField(
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.phone,
                        style: TextStyle(
                          color: AppColors.darkTextPrimary,
                          fontSize: 14,
                        ),
                        decoration: _inputDecoration('10-digit mobile')
                            .copyWith(
                              labelText: 'Mobile Number',
                              labelStyle: TextStyle(
                                color: AppColors.darkTextSecondary,
                                fontSize: 13,
                              ),
                              prefixIcon: Icon(
                                Icons.phone_outlined,
                                size: 18,
                                color: AppColors.darkTextSecondary,
                              ),
                            ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 5,
                      child: TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(
                          color: AppColors.darkTextPrimary,
                          fontSize: 14,
                        ),
                        decoration: _inputDecoration('Email (optional)')
                            .copyWith(
                              labelText: 'Email',
                              labelStyle: TextStyle(
                                color: AppColors.darkTextSecondary,
                                fontSize: 13,
                              ),
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // State & District Dropdowns
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedState,
                        isExpanded: true,
                        dropdownColor: AppColors.darkCard,
                        style: TextStyle(
                          color: AppColors.darkTextPrimary,
                          fontSize: 13,
                        ),
                        decoration: _inputDecoration('State').copyWith(
                          labelText: 'State',
                          labelStyle: TextStyle(
                            color: AppColors.darkTextSecondary,
                            fontSize: 12,
                          ),
                        ),
                        items: states
                            .map(
                              (s) => DropdownMenuItem(
                                value: s,
                                child: Text(s, overflow: TextOverflow.ellipsis),
                              ),
                            )
                            .toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedState = val;
                            _loadDistricts();
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedDistrict,
                        isExpanded: true,
                        dropdownColor: AppColors.darkCard,
                        style: TextStyle(
                          color: AppColors.darkTextPrimary,
                          fontSize: 13,
                        ),
                        decoration: _inputDecoration('District').copyWith(
                          labelText: 'District',
                          labelStyle: TextStyle(
                            color: AppColors.darkTextSecondary,
                            fontSize: 12,
                          ),
                        ),
                        items: _districts
                            .map(
                              (d) => DropdownMenuItem(
                                value: d,
                                child: Text(d, overflow: TextOverflow.ellipsis),
                              ),
                            )
                            .toList(),
                        onChanged: (val) {
                          setState(() => _selectedDistrict = val);
                        },
                      ),
                    ),
                  ],
                ),

                // If Company, show GSTIN
                if (_selectedType == CustomerType.company) ...[
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _gstinCtrl,
                    textCapitalization: TextCapitalization.characters,
                    style: TextStyle(
                      color: AppColors.darkTextPrimary,
                      fontSize: 14,
                    ),
                    decoration: _inputDecoration('e.g. 27AAAAA0000A1Z5')
                        .copyWith(
                          labelText: 'GSTIN (optional)',
                          labelStyle: TextStyle(
                            color: AppColors.darkTextSecondary,
                            fontSize: 13,
                          ),
                          prefixIcon: Icon(
                            Icons.verified_outlined,
                            size: 18,
                            color: AppColors.darkTextSecondary,
                          ),
                        ),
                  ),
                ],

                const SizedBox(height: 20),

                // Footer Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: _openFullForm,
                      icon: const Icon(Icons.open_in_new_rounded, size: 15),
                      label: const Text('Complete Form...'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.darkTextSecondary,
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                    ),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: _saving ? null : _handleSave,
                          icon: _saving
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.black,
                                  ),
                                )
                              : const Icon(Icons.check_rounded, size: 16),
                          label: const Text('Save & Select'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.brandAmber,
                            foregroundColor: AppColors.darkBackground,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Line Item Draft ───────────────────────────────────────────────────────────

class _LineItemDraft {
  Product? product;
  double quantity = 0;
  double rate = 0;
  String unit = 'LTRS';
}

class _LineItemRow extends ConsumerStatefulWidget {
  const _LineItemRow({
    super.key,
    required this.draft,
    required this.products,
    required this.gstService,
    required this.buyerStateCode,
    required this.index,
    required this.onRemove,
    required this.onChanged,
  });

  final _LineItemDraft draft;
  final List<Product> products;
  final GstCalculationService gstService;
  final String buyerStateCode;
  final int index;
  final VoidCallback onRemove;
  final VoidCallback onChanged;

  @override
  ConsumerState<_LineItemRow> createState() => _LineItemRowState();
}

class _LineItemRowState extends ConsumerState<_LineItemRow> {
  late final TextEditingController _qtyCtrl;
  late final TextEditingController _rateCtrl;

  @override
  void initState() {
    super.initState();
    _qtyCtrl = TextEditingController(
      text: widget.draft.quantity > 0 ? widget.draft.quantity.toString() : '',
    );
    _rateCtrl = TextEditingController(
      text: widget.draft.rate > 0 ? widget.draft.rate.toString() : '',
    );
  }

  @override
  void dispose() {
    _qtyCtrl.dispose();
    _rateCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = widget.draft;
    final gst = draft.product != null && draft.quantity > 0
        ? widget.gstService.compute(
            buyerStateCode: widget.buyerStateCode,
            taxableAmount: draft.quantity * draft.rate,
            gstRate: draft.product!.gstRate,
          )
        : null;

    return AdaptiveLineItemLayout(
      productSelector: DropdownButtonFormField<Product>(
        initialValue: draft.product,
        dropdownColor: AppColors.darkCard,
        style: TextStyle(color: AppColors.darkTextPrimary, fontSize: 13),
        decoration: _inputDecoration('Product'),
        items: widget.products
            .map((p) => DropdownMenuItem(value: p, child: Text(p.name)))
            .toList(),
        onChanged: (p) {
          setState(() {
            draft.product = p;
            if (p != null && draft.rate == 0) {
              final price = p.currentSellingPrice ?? 0.0;
              draft.rate = price;
              _rateCtrl.text = price.toString();
            }
          });
          widget.onChanged();
        },
      ),
      quantityField: TextField(
        controller: _qtyCtrl,
        keyboardType: TextInputType.number,
        style: TextStyle(color: AppColors.darkTextPrimary, fontSize: 13),
        decoration: _inputDecoration('Qty'),
        onChanged: (v) {
          draft.quantity = double.tryParse(v) ?? 0;
          widget.onChanged();
        },
      ),
      rateField: TextField(
        controller: _rateCtrl,
        keyboardType: TextInputType.number,
        style: TextStyle(color: AppColors.darkTextPrimary, fontSize: 13),
        decoration: _inputDecoration('Rate/L'),
        onChanged: (v) {
          draft.rate = double.tryParse(v) ?? 0;
          widget.onChanged();
        },
      ),
      unitSelector: DropdownButtonFormField<String>(
        initialValue: draft.unit,
        dropdownColor: AppColors.darkCard,
        style: TextStyle(color: AppColors.darkTextPrimary, fontSize: 13),
        decoration: _inputDecoration('Unit'),
        items: const [
          'LTRS',
          'KL',
        ].map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
        onChanged: (u) {
          setState(() => draft.unit = u!);
          widget.onChanged();
        },
      ),
      summary: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            gst != null ? '₹${_fmt(gst.totalAmount)}' : '₹0.00',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.darkTextPrimary,
              fontSize: 13,
            ),
          ),
          if (gst != null)
            Text(
              'GST: ₹${_fmt(gst.totalTax)}',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.darkTextSecondary,
              ),
            ),
        ],
      ),
      removeButton: IconButton(
        onPressed: widget.onRemove,
        icon: const Icon(
          Icons.remove_circle_outline_rounded,
          color: AppColors.error,
          size: 20,
        ),
        tooltip: 'Remove item',
      ),
    );
  }
}

// ── Reusable Widgets ──────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16, color: color),
      label: Text(label, style: TextStyle(color: color, fontSize: 13)),
      style: TextButton.styleFrom(
        backgroundColor: color.withValues(alpha: 0.1),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: AppColors.brandAmber,
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow(this.label, this.value, {this.valueColor});
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.darkTextSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                color: valueColor ?? AppColors.darkTextPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LineItemCard extends StatelessWidget {
  const _LineItemCard({required this.item});
  final InvoiceItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.description,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkTextPrimary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'HSN: ${item.hsnCode}  •  ${item.quantity} ${item.unit} × ₹${_fmt(item.rate)}/L',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.darkTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${_fmt(item.totalAmount)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkTextPrimary,
                ),
              ),
              Text(
                'Tax: ₹${_fmt(item.totalTax)}',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.darkTextSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyInvoicesPlaceholder extends StatelessWidget {
  const _EmptyInvoicesPlaceholder({required this.onNew});
  final VoidCallback onNew;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.darkCard,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.darkBorder),
            ),
            child: Icon(
              Icons.receipt_long_outlined,
              size: 48,
              color: AppColors.darkTextTertiary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No Invoices Found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.darkTextPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first GST-compliant tax invoice.',
            style: TextStyle(color: AppColors.darkTextSecondary, fontSize: 14),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onNew,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brandAmber,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            icon: Icon(Icons.add_rounded, color: AppColors.darkBackground),
            label: Text(
              'Create Invoice',
              style: TextStyle(
                color: AppColors.darkBackground,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.darkTextSecondary,
        ),
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow(this.label, this.amount, {this.bold = false, this.color});
  final String label;
  final double amount;
  final bool bold;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: bold ? 14 : 13,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              color: color ?? AppColors.darkTextSecondary,
            ),
          ),
          Text(
            '₹${_fmt(amount)}',
            style: TextStyle(
              fontSize: bold ? 14 : 13,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              color: color ?? AppColors.darkTextPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

Color _statusColor(InvoiceStatus status) {
  switch (status) {
    case InvoiceStatus.draft:
      return AppColors.statusDraft;
    case InvoiceStatus.verified:
      return AppColors.statusVerified;
    case InvoiceStatus.posted:
      return AppColors.statusPosted;
    case InvoiceStatus.partiallyPaid:
      return AppColors.statusPartiallyPaid;
    case InvoiceStatus.paid:
      return AppColors.statusPaid;
    case InvoiceStatus.overdue:
      return AppColors.statusOverdue;
    case InvoiceStatus.cancelled:
      return AppColors.statusCancelled;
  }
}

String _fmt(double v) {
  final f = NumberFormat('#,##,##0.00', 'en_IN');
  return f.format(v);
}

InputDecoration _inputDecoration(String hint) {
  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: AppColors.darkTextTertiary, fontSize: 13),
    filled: true,
    fillColor: AppColors.darkSurface,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
  );
}

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:step_up_fuels/core/theme/app_colors.dart';
import 'package:step_up_fuels/features/customers/domain/entities/customer.dart';
import 'package:step_up_fuels/features/customers/domain/entities/customer_type.dart';
import 'package:step_up_fuels/features/customers/presentation/providers/customers_provider.dart';
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
import 'package:uuid/uuid.dart';

class InvoicesScreen extends ConsumerStatefulWidget {
  const InvoicesScreen({super.key});

  @override
  ConsumerState<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends ConsumerState<InvoicesScreen>
    with TickerProviderStateMixin {
  final _searchCtrl = TextEditingController();
  late final AnimationController _panelAnim;
  late final Animation<double> _panelSlide;
  bool _showDetail = false;
  static const _uuid = Uuid();

  @override
  void initState() {
    super.initState();
    _panelAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _panelSlide = CurvedAnimation(
      parent: _panelAnim,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _panelAnim.dispose();
    super.dispose();
  }

  void _openDetail(String id) {
    ref.read(selectedInvoiceIdProvider.notifier).state = id;
    setState(() => _showDetail = true);
    _panelAnim.forward(from: 0);
  }

  void _closeDetail() {
    _panelAnim.reverse().then((_) {
      setState(() => _showDetail = false);
      ref.read(selectedInvoiceIdProvider.notifier).state = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final invoicesAsync = ref.watch(invoicesListProvider);
    final selectedId = ref.watch(selectedInvoiceIdProvider);
    final statusFilter = ref.watch(invoiceStatusFilterProvider);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Row(
        children: [
          // ── Left Panel: List ───────────────────────────────────────────────
          Expanded(
            flex: _showDetail ? 5 : 1,
            child: Column(
              children: [
                _buildHeader(context, statusFilter),
                _buildSearchAndFilters(),
                Expanded(
                  child: invoicesAsync.when(
                    data: (invoices) => _buildInvoiceList(invoices, selectedId),
                    loading: () => const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.brandAmber,
                      ),
                    ),
                    error: (e, _) => Center(
                      child: Text(
                        e.toString(),
                        style: const TextStyle(color: AppColors.error),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Right Panel: Detail ────────────────────────────────────────────
          if (_showDetail && selectedId != null)
            SizeTransition(
              axis: Axis.horizontal,
              sizeFactor: _panelSlide,
              child: Container(
                width: 520,
                decoration: BoxDecoration(
                  color: AppColors.darkCard,
                  border: Border(left: BorderSide(color: AppColors.darkBorder)),
                ),
                child: _InvoiceDetailPanel(
                  invoiceId: selectedId,
                  onClose: _closeDetail,
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCreateInvoiceDialog(context),
        backgroundColor: AppColors.brandAmber,
        foregroundColor: AppColors.darkBackground,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'New Invoice',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, InvoiceStatus? statusFilter) {
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 0),
      child: Row(
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
          Column(
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
          const Spacer(),
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
        final totalRevenue = invoices
            .where(
              (i) =>
                  i.status != InvoiceStatus.cancelled &&
                  i.status != InvoiceStatus.draft,
            )
            .fold<double>(0, (s, i) => s + i.totalAmount);

        return Row(
          children: [
            _statChip(
              'Total',
              total.toString(),
              Icons.description_outlined,
              AppColors.brandAmber,
            ),
            const SizedBox(width: 12),
            _statChip(
              'Outstanding',
              '₹${_fmt(outstanding)}',
              Icons.account_balance_wallet_outlined,
              AppColors.statusOverdue,
            ),
            const SizedBox(width: 12),
            _statChip(
              'Revenue',
              '₹${_fmt(totalRevenue)}',
              Icons.trending_up_rounded,
              AppColors.success,
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _statChip(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: color.withValues(alpha: 0.7),
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 16, 28, 8),
      child: Row(
        children: [
          // Search
          Expanded(
            child: Container(
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
                style: TextStyle(
                  color: AppColors.darkTextPrimary,
                  fontSize: 14,
                ),
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
          ),
          const SizedBox(width: 12),
          // Status filter
          _StatusFilterDropdown(),
        ],
      ),
    );
  }

  Widget _buildInvoiceList(List<Invoice> invoices, String? selectedId) {
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
          onTap: () => _openDetail(inv.id),
        );
      },
    );
  }

  void _openCreateInvoiceDialog(BuildContext context) {
    showDialog(
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
    final statusColor = _statusColor(invoice.status);
    final isOverdue = !isSelected && invoice.status == InvoiceStatus.overdue;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.darkCard : AppColors.darkSurface,
        borderRadius: BorderRadius.circular(12),
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
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // Status indicator
              Container(
                width: 4,
                height: 44,
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 16),

              // Invoice info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          invoice.invoiceNumber,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkTextPrimary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        _StatusBadge(invoice.status),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Customer: ${invoice.customerId}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.darkTextSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Date: ${DateFormat('dd MMM yyyy').format(invoice.invoiceDate)}  •  Due: ${DateFormat('dd MMM yyyy').format(invoice.dueDate)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.darkTextTertiary,
                      ),
                    ),
                  ],
                ),
              ),

              // Amount
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹${_fmt(invoice.totalAmount)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkTextPrimary,
                    ),
                  ),
                  if (invoice.outstanding > 0)
                    Text(
                      'Due: ₹${_fmt(invoice.outstanding)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.statusOverdue,
                      ),
                    )
                  else if (invoice.status == InvoiceStatus.paid)
                    const Text(
                      'Paid ✓',
                      style: TextStyle(fontSize: 12, color: AppColors.success),
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inv = detail.invoice;
    final items = detail.items;

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
                  const SizedBox(height: 4),
                  _StatusBadge(inv.status),
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
              children: [
                // Summary cards
                Row(
                  children: [
                    _DetailCard(
                      label: 'Subtotal',
                      value: '₹${_fmt(inv.subtotal)}',
                      icon: Icons.summarize_outlined,
                      color: AppColors.info,
                    ),
                    const SizedBox(width: 12),
                    _DetailCard(
                      label: 'GST',
                      value: '₹${_fmt(inv.totalGst)}',
                      icon: Icons.percent_rounded,
                      color: AppColors.brandAmber,
                    ),
                    const SizedBox(width: 12),
                    _DetailCard(
                      label: 'Total',
                      value: '₹${_fmt(inv.totalAmount)}',
                      icon: Icons.account_balance_wallet_outlined,
                      color: AppColors.success,
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // GST breakdown
                if (!inv.isInterstate) ...[
                  _GstBreakdownRow('CGST', inv.cgstAmount),
                  _GstBreakdownRow('SGST', inv.sgstAmount),
                ] else ...[
                  _GstBreakdownRow('IGST', inv.igstAmount),
                ],

                const SizedBox(height: 20),
                // Invoice meta
                const _SectionHeader('Invoice Details'),
                const SizedBox(height: 10),
                _MetaRow('Customer ID', inv.customerId),
                _MetaRow('Supply Type', inv.supplyType),
                _MetaRow('Place of Supply', inv.placeOfSupply),
                _MetaRow(
                  'GST Type',
                  inv.isInterstate
                      ? 'Interstate (IGST)'
                      : 'Intrastate (CGST+SGST)',
                ),
                _MetaRow(
                  'Invoice Date',
                  DateFormat('dd MMM yyyy').format(inv.invoiceDate),
                ),
                _MetaRow(
                  'Due Date',
                  DateFormat('dd MMM yyyy').format(inv.dueDate),
                ),
                if (inv.notes != null && inv.notes!.isNotEmpty)
                  _MetaRow('Notes', inv.notes!),
                if (inv.cancelledReason != null)
                  _MetaRow(
                    'Cancel Reason',
                    inv.cancelledReason!,
                    valueColor: AppColors.error,
                  ),

                const SizedBox(height: 20),
                // Payment status
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
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () {
                          showDialog(
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
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              backgroundColor: AppColors.darkCard,
                              title: Text(
                                'Receive Full Payment',
                                style: TextStyle(
                                  color: AppColors.darkTextPrimary,
                                ),
                              ),
                              content: Text(
                                'Are you sure you want to record full receipt of ₹${_fmt(inv.outstanding)} for this invoice?',
                                style: TextStyle(
                                  color: AppColors.darkTextSecondary,
                                ),
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
                                    style: TextStyle(
                                      color: AppColors.darkBackground,
                                    ),
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
                              notes:
                                  'Full payment received directly from Invoice screen.',
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
                                    content: Text(
                                      'Full payment receipt saved successfully!',
                                    ),
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
                        },
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
                        final allPayments =
                            ref.watch(paymentsListProvider).value ?? [];
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                              color:
                                                  AppColors.darkTextSecondary,
                                            ),
                                          ),
                                          if (pmt.notes != null &&
                                              pmt.notes!.isNotEmpty) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              'Note: ${pmt.notes}',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color:
                                                    AppColors.darkTextTertiary,
                                                fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
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
                                            color:
                                                alloc.type ==
                                                    AllocationType.advance
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
                        style: const TextStyle(
                          color: AppColors.error,
                          fontSize: 11,
                        ),
                      ),
                    ),

                const SizedBox(height: 20),
                // Line items
                _SectionHeader('Line Items (${items.length})'),
                const SizedBox(height: 10),
                ...items.map((item) => _LineItemCard(item: item)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showCancelDialog(BuildContext context, WidgetRef ref, Invoice inv) {
    final reasonCtrl = TextEditingController();
    showDialog(
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
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customersAsync = ref.watch(customersListProvider);
    final productsAsync = ref.watch(productsListProvider);

    return Dialog(
      backgroundColor: AppColors.darkCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SizedBox(
        width: 780,
        height: math.min(MediaQuery.of(context).size.height * 0.9, 720),
        child: Column(
          children: [
            // Dialog header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: AppColors.gradientInvoices),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.receipt_long_rounded, color: Colors.white),
                  const SizedBox(width: 12),
                  const Text(
                    'Create New Invoice',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white70),
                  ),
                ],
              ),
            ),

            // Form body
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Customer selector
                      const _FieldLabel('Customer *'),
                      customersAsync.when(
                        data: (customers) => _buildCustomerDropdown(customers),
                        loading: () => const CircularProgressIndicator(
                          color: AppColors.brandAmber,
                        ),
                        error: (e, _) => Text(e.toString()),
                      ),
                      const SizedBox(height: 16),

                      // Dates row
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const _FieldLabel('Invoice Date'),
                                _DatePickerField(
                                  date: _invoiceDate,
                                  onChanged: (d) =>
                                      setState(() => _invoiceDate = d),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const _FieldLabel('Due Date'),
                                _DatePickerField(
                                  date: _dueDate,
                                  onChanged: (d) =>
                                      setState(() => _dueDate = d),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const _FieldLabel('Supply Type'),
                                _dialogDropdown(
                                  value: _supplyType,
                                  items: ['B2B', 'B2C'],
                                  onChanged: (v) =>
                                      setState(() => _supplyType = v!),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Place of supply
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const _FieldLabel('Buyer State Code'),
                                TextFormField(
                                  initialValue: _buyerStateCode,
                                  onChanged: (v) => setState(
                                    () => _buyerStateCode = v.trim(),
                                  ),
                                  style: TextStyle(
                                    color: AppColors.darkTextPrimary,
                                  ),
                                  decoration: _inputDecoration('e.g. 27'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const _FieldLabel('Notes (optional)'),
                                TextFormField(
                                  controller: _notesCtrl,
                                  style: TextStyle(
                                    color: AppColors.darkTextPrimary,
                                  ),
                                  decoration: _inputDecoration(
                                    'Additional notes',
                                  ),
                                ),
                              ],
                            ),
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
                            onPressed: () => setState(
                              () => _lineItems.add(_LineItemDraft()),
                            ),
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
                                  onRemove: () => setState(
                                    () => _lineItems.removeAt(e.key),
                                  ),
                                  onChanged: () => setState(() {}),
                                ),
                              )
                              .toList(),
                          loading: () => [
                            const CircularProgressIndicator(
                              color: AppColors.brandAmber,
                            ),
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
              ),
            ),

            // Footer actions
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.darkBorder)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _saving ? null : _saveDraft,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkBorderLight,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
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
                        : Icon(
                            Icons.save_outlined,
                            color: AppColors.darkTextPrimary,
                          ),
                    label: Text(
                      'Save Draft',
                      style: TextStyle(color: AppColors.darkTextPrimary),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _saving ? null : _saveAndPost,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brandAmber,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    icon: Icon(
                      Icons.publish_rounded,
                      color: AppColors.darkBackground,
                    ),
                    label: Text(
                      'Post Invoice',
                      style: TextStyle(
                        color: AppColors.darkBackground,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerDropdown(List<Customer> customers) {
    return DropdownButtonFormField<Customer>(
      initialValue: _selectedCustomer,
      dropdownColor: AppColors.darkCard,
      style: TextStyle(color: AppColors.darkTextPrimary, fontSize: 14),
      decoration: _inputDecoration('Select customer'),
      items: customers
          .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
          .toList(),
      onChanged: (c) => setState(() {
        _selectedCustomer = c;
        if (c != null) {
          final state = c.billingState;
          _buyerStateCode = (state != null && state.isNotEmpty)
              ? _stateNameToCode(state)
              : '27';
        }
      }),
      validator: (v) => v == null ? 'Please select a customer' : null,
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
    if (!_formKey.currentState!.validate()) return;
    await _buildAndSave(post: false);
  }

  Future<void> _saveAndPost() async {
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

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Product selector
              Expanded(
                flex: 3,
                child: DropdownButtonFormField<Product>(
                  initialValue: draft.product,
                  dropdownColor: AppColors.darkCard,
                  style: TextStyle(
                    color: AppColors.darkTextPrimary,
                    fontSize: 13,
                  ),
                  decoration: _inputDecoration('Product'),
                  items: widget.products
                      .map(
                        (p) => DropdownMenuItem(value: p, child: Text(p.name)),
                      )
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
              ),
              const SizedBox(width: 8),

              // Quantity
              Expanded(
                child: TextField(
                  controller: _qtyCtrl,
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    color: AppColors.darkTextPrimary,
                    fontSize: 13,
                  ),
                  decoration: _inputDecoration('Qty'),
                  onChanged: (v) {
                    draft.quantity = double.tryParse(v) ?? 0;
                    widget.onChanged();
                  },
                ),
              ),
              const SizedBox(width: 8),

              // Rate
              Expanded(
                child: TextField(
                  controller: _rateCtrl,
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    color: AppColors.darkTextPrimary,
                    fontSize: 13,
                  ),
                  decoration: _inputDecoration('Rate/L'),
                  onChanged: (v) {
                    draft.rate = double.tryParse(v) ?? 0;
                    widget.onChanged();
                  },
                ),
              ),
              const SizedBox(width: 8),

              // Unit selector
              SizedBox(
                width: 80,
                child: DropdownButtonFormField<String>(
                  initialValue: draft.unit,
                  dropdownColor: AppColors.darkCard,
                  style: TextStyle(
                    color: AppColors.darkTextPrimary,
                    fontSize: 13,
                  ),
                  decoration: _inputDecoration('Unit'),
                  items: ['LTRS', 'KL']
                      .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                      .toList(),
                  onChanged: (u) {
                    setState(() => draft.unit = u!);
                    widget.onChanged();
                  },
                ),
              ),
              const SizedBox(width: 8),

              // Amount
              SizedBox(
                width: 90,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
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
              ),

              // Remove
              IconButton(
                onPressed: widget.onRemove,
                icon: const Icon(
                  Icons.remove_circle_outline_rounded,
                  color: AppColors.error,
                  size: 20,
                ),
                tooltip: 'Remove item',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Reusable Widgets ──────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  const _StatusBadge(this.status);
  final InvoiceStatus status;

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

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

class _DetailCard extends StatelessWidget {
  const _DetailCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: color.withValues(alpha: 0.7),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GstBreakdownRow extends StatelessWidget {
  const _GstBreakdownRow(this.label, this.amount);
  final String label;
  final double amount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 13, color: AppColors.darkTextSecondary),
          ),
          Text(
            '₹${_fmt(amount)}',
            style: TextStyle(fontSize: 13, color: AppColors.darkTextPrimary),
          ),
        ],
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

class _DatePickerField extends StatelessWidget {
  const _DatePickerField({required this.date, required this.onChanged});
  final DateTime date;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2020),
          lastDate: DateTime(2035),
          builder: (context, child) => Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.dark(
                primary: AppColors.brandAmber,
                surface: AppColors.darkCard,
              ),
            ),
            child: child!,
          ),
        );
        if (picked != null) onChanged(picked);
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.darkSurface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.darkBorder),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 16,
              color: AppColors.darkTextSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              DateFormat('dd MMM yyyy').format(date),
              style: TextStyle(color: AppColors.darkTextPrimary, fontSize: 13),
            ),
          ],
        ),
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

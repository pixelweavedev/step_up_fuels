import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:step_up_fuels/core/theme/app_colors.dart';
import 'package:step_up_fuels/features/customers/domain/entities/customer.dart';
import 'package:step_up_fuels/features/customers/domain/entities/customer_type.dart';
import 'package:step_up_fuels/features/customers/presentation/providers/customers_provider.dart';
import 'package:step_up_fuels/features/invoices/domain/entities/invoice.dart';
import 'package:step_up_fuels/features/invoices/presentation/providers/invoices_provider.dart';
import 'package:step_up_fuels/features/payments/domain/entities/payment.dart';
import 'package:step_up_fuels/features/payments/presentation/providers/payments_provider.dart';
import 'package:step_up_fuels/shared/widgets/buttons/primary_button.dart';
import 'package:step_up_fuels/shared/widgets/empty_states/empty_state_widget.dart';
import 'package:step_up_fuels/shared/widgets/inputs/app_text_field.dart';
import 'package:uuid/uuid.dart';

class PaymentsScreen extends ConsumerStatefulWidget {
  const PaymentsScreen({super.key});

  @override
  ConsumerState<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends ConsumerState<PaymentsScreen>
    with TickerProviderStateMixin {
  final _searchCtrl = TextEditingController();
  late final AnimationController _panelAnim;
  late final Animation<double> _panelSlide;
  bool _showDetail = false;

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
    ref.read(selectedPaymentIdProvider.notifier).state = id;
    setState(() => _showDetail = true);
    _panelAnim.forward(from: 0);
  }

  void _closeDetail() {
    _panelAnim.reverse().then((_) {
      setState(() => _showDetail = false);
      ref.read(selectedPaymentIdProvider.notifier).state = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final paymentsAsync = ref.watch(paymentsListProvider);
    final selectedId = ref.watch(selectedPaymentIdProvider);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Row(
        children: [
          // Left panel: payments list
          Expanded(
            flex: _showDetail ? 5 : 1,
            child: Column(
              children: [
                _buildHeader(context),
                _buildSearchAndFilters(),
                Expanded(
                  child: paymentsAsync.when(
                    data: (payments) =>
                        _buildPaymentsList(payments, selectedId),
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

          // Right panel: payment details
          if (_showDetail && selectedId != null)
            SizeTransition(
              axis: Axis.horizontal,
              sizeFactor: _panelSlide,
              child: Container(
                width: 480,
                decoration: BoxDecoration(
                  color: AppColors.darkSurface,
                  border: Border(left: BorderSide(color: AppColors.darkBorder)),
                ),
                child: _buildDetailPanel(selectedId),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Payments',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkTextPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Record and track customer receipts & allocations',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.darkTextSecondary,
                ),
              ),
            ],
          ),
          PrimaryButton(
            label: 'Record Receipt',
            icon: Icons.add_rounded,
            onPressed: () => _showRecordPaymentDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    final customerFilter = ref.watch(paymentCustomerFilterProvider);
    final customersAsync = ref.watch(customersListProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: AppTextField(
              hint: 'Search payment no. or transaction reference...',
              prefixIcon: Icons.search_rounded,
              controller: _searchCtrl,
              onChanged: (val) {
                ref.read(paymentSearchQueryProvider.notifier).state = val;
              },
            ),
          ),
          const SizedBox(width: 16),
          // Customer Filter Dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              border: Border.all(color: AppColors.darkBorder),
              borderRadius: BorderRadius.circular(8),
            ),
            child: customersAsync.when(
              data: (list) => DropdownButton<String?>(
                value: customerFilter,
                hint: Text(
                  'All Customers',
                  style: TextStyle(color: AppColors.darkTextSecondary),
                ),
                dropdownColor: AppColors.darkSurface,
                underline: const SizedBox(),
                items: [
                  DropdownMenuItem<String?>(
                    child: Text(
                      'All Customers',
                      style: TextStyle(color: AppColors.darkTextPrimary),
                    ),
                  ),
                  ...list.map(
                    (c) => DropdownMenuItem(
                      value: c.id,
                      child: Text(
                        c.name,
                        style: TextStyle(color: AppColors.darkTextPrimary),
                      ),
                    ),
                  ),
                ],
                onChanged: (val) {
                  ref.read(paymentCustomerFilterProvider.notifier).state = val;
                },
              ),
              loading: () => const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              error: (_, __) => const Text('Error loading customers'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentsList(List<Payment> payments, String? selectedId) {
    if (payments.isEmpty) {
      return const EmptyStateWidget(
        title: 'No Payments Found',
        subtitle:
            'Try modifying your filters or record a new customer receipt.',
        icon: Icons.payments_outlined,
      );
    }

    final customers = ref.watch(customersListProvider).value ?? [];

    return ListView.builder(
      itemCount: payments.length,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      itemBuilder: (context, index) {
        final payment = payments[index];
        final isSelected = payment.id == selectedId;
        final customerName = customers
            .firstWhere(
              (c) => c.id == payment.customerId,
              orElse: () => Customer(
                id: '',
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
            )
            .name;

        return Card(
          color: isSelected ? AppColors.brandNavyMid : AppColors.darkSurface,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isSelected ? AppColors.brandAmber : AppColors.darkBorder,
              width: 1.5,
            ),
          ),
          child: ListTile(
            onTap: () => _openDetail(payment.id),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 12,
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  payment.paymentNumber,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: AppColors.darkTextPrimary,
                  ),
                ),
                Text(
                  '₹${payment.amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: AppColors.brandAmber,
                  ),
                ),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customerName,
                        style: TextStyle(
                          color: AppColors.darkTextSecondary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Mode: ${payment.paymentMode} | Ref: ${payment.referenceNumber ?? "N/A"}',
                        style: TextStyle(
                          color: AppColors.darkTextTertiary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    DateFormat('dd MMM yyyy').format(payment.paymentDate),
                    style: TextStyle(
                      color: AppColors.darkTextTertiary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailPanel(String paymentId) {
    final paymentAsync = ref.watch(selectedPaymentProvider);
    final customers = ref.watch(customersListProvider).value ?? [];

    return paymentAsync.when(
      data: (payment) {
        final customer = customers.firstWhere(
          (c) => c.id == payment.customerId,
          orElse: () => Customer(
            id: '',
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

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Details Header
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        payment.paymentNumber,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Recorded on ${DateFormat('dd MMM yyyy, hh:mm a').format(payment.createdAt)}',
                        style: TextStyle(
                          color: AppColors.darkTextTertiary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      color: AppColors.darkTextSecondary,
                    ),
                    onPressed: _closeDetail,
                  ),
                ],
              ),
            ),
            Divider(color: AppColors.darkBorder),

            // Detail Fields
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  _buildDetailRow('Customer', customer.name),
                  _buildDetailRow('Customer Code', customer.customerCode),
                  _buildDetailRow(
                    'Amount Received',
                    '₹${payment.amount.toStringAsFixed(2)}',
                    valueColor: AppColors.brandAmber,
                  ),
                  _buildDetailRow(
                    'Payment Date',
                    DateFormat('dd MMM yyyy').format(payment.paymentDate),
                  ),
                  _buildDetailRow('Payment Mode', payment.paymentMode),
                  _buildDetailRow(
                    'Reference / Txn ID',
                    payment.referenceNumber ?? 'None',
                  ),
                  _buildDetailRow('Depositing Bank', payment.bankName ?? 'N/A'),
                  _buildDetailRow(
                    'Notes',
                    payment.notes ?? 'No notes recorded',
                  ),
                  _buildDetailRow(
                    'Allocated Invoice ID',
                    payment.invoiceId ?? 'Auto-Allocated / Advance Account',
                  ),
                  _buildDetailRow(
                    'Status',
                    payment.status.displayName,
                    valueColor: payment.status == PaymentStatus.reversed
                        ? AppColors.error
                        : AppColors.success,
                  ),
                  if (payment.status == PaymentStatus.posted) ...[
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error.withValues(alpha: 0.2),
                        foregroundColor: AppColors.error,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.undo_rounded),
                      label: const Text(
                        'Reverse Payment (Audit Rollback)',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            backgroundColor: AppColors.darkCard,
                            title: Text(
                              'Reverse Payment Receipt',
                              style: TextStyle(
                                color: AppColors.darkTextPrimary,
                              ),
                            ),
                            content: Text(
                              'Are you sure you want to reverse this payment? This will mark the receipt as REVERSED, reverse all invoice allocations, update customer outstanding, and post reversing ledger entries. This action cannot be undone.',
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
                                  backgroundColor: AppColors.error,
                                ),
                                onPressed: () => Navigator.pop(ctx, true),
                                child: Text(
                                  'Reverse',
                                  style: TextStyle(
                                    color: AppColors.darkTextPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          final messenger = ScaffoldMessenger.of(context);
                          try {
                            await ref
                                .read(paymentsListProvider.notifier)
                                .reversePayment(payment.id);
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('Payment reversed successfully!'),
                                backgroundColor: AppColors.success,
                              ),
                            );
                          } catch (e) {
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text('Failed to reverse payment: $e'),
                                backgroundColor: AppColors.error,
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.brandAmber),
      ),
      error: (err, _) => Center(
        child: Text(
          err.toString(),
          style: const TextStyle(color: AppColors.error),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.darkTextTertiary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? AppColors.darkTextPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showRecordPaymentDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => const RecordPaymentDialog(),
    );
  }
}

class RecordPaymentDialog extends ConsumerStatefulWidget {
  const RecordPaymentDialog({
    super.key,
    this.preSelectedCustomerId,
    this.preSelectedInvoiceId,
    this.preFilledAmount,
  });

  final String? preSelectedCustomerId;
  final String? preSelectedInvoiceId;
  final double? preFilledAmount;

  @override
  ConsumerState<RecordPaymentDialog> createState() =>
      _RecordPaymentDialogState();
}

class _RecordPaymentDialogState extends ConsumerState<RecordPaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _refCtrl = TextEditingController();
  final _bankCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  String? _selectedCustomerId;
  String? _selectedInvoiceId;
  String _paymentMode = 'BANK_TRANSFER';
  DateTime _paymentDate = DateTime.now();
  bool _autoAllocate = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedCustomerId = widget.preSelectedCustomerId;
    _selectedInvoiceId = widget.preSelectedInvoiceId;
    if (widget.preSelectedInvoiceId != null) {
      _autoAllocate = false;
    }
    if (widget.preFilledAmount != null) {
      _amountCtrl.text = widget.preFilledAmount!.toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _refCtrl.dispose();
    _bankCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _paymentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.brandAmber,
              onPrimary: AppColors.brandNavy,
              surface: AppColors.darkSurface,
              onSurface: AppColors.darkTextPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _paymentDate) {
      setState(() {
        _paymentDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final customers = ref.watch(customersListProvider).value ?? [];
    final invoices = ref.watch(invoicesListProvider).value ?? [];

    // Filter outstanding invoices for selected customer
    final customerInvoices = invoices
        .where(
          (inv) =>
              inv.customerId == _selectedCustomerId &&
              (inv.status == InvoiceStatus.posted ||
                  inv.status == InvoiceStatus.partiallyPaid),
        )
        .toList();

    return Dialog(
      backgroundColor: AppColors.darkSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 520,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Record Customer Receipt',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkTextPrimary,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: AppColors.darkTextSecondary,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Customer Selector
                Text(
                  'Customer',
                  style: TextStyle(
                    color: AppColors.darkTextSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: _selectedCustomerId,
                  dropdownColor: AppColors.darkSurface,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.darkBorder),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: AppColors.brandAmber),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: AppColors.error),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: AppColors.error),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: customers
                      .map(
                        (c) => DropdownMenuItem(
                          value: c.id,
                          child: Text(
                            c.name,
                            style: TextStyle(color: AppColors.darkTextPrimary),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedCustomerId = val;
                      _selectedInvoiceId = null;
                    });
                  },
                  validator: (val) =>
                      val == null ? 'Please select a customer' : null,
                ),
                const SizedBox(height: 16),

                // Amount and Date Row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Amount Received (₹)',
                            style: TextStyle(
                              color: AppColors.darkTextSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _amountCtrl,
                            onChanged: (val) => setState(() {}),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            style: TextStyle(color: AppColors.darkTextPrimary),
                            decoration: InputDecoration(
                              hintText: '0.00',
                              hintStyle: TextStyle(
                                color: AppColors.darkTextTertiary,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: AppColors.darkBorder,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: AppColors.brandAmber,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: AppColors.error,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: AppColors.error,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            validator: (val) {
                              if (val == null || val.isEmpty) return 'Required';
                              if (double.tryParse(val) == null ||
                                  double.parse(val) <= 0) {
                                return 'Invalid amount';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Payment Date',
                            style: TextStyle(
                              color: AppColors.darkTextSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          InkWell(
                            onTap: () => _selectDate(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.darkBorder),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    DateFormat(
                                      'dd/MM/yyyy',
                                    ).format(_paymentDate),
                                    style: TextStyle(
                                      color: AppColors.darkTextPrimary,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.calendar_month_rounded,
                                    color: AppColors.brandAmber,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Payment Mode Selector
                Text(
                  'Payment Mode',
                  style: TextStyle(
                    color: AppColors.darkTextSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: _paymentMode,
                  dropdownColor: AppColors.darkSurface,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.darkBorder),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: AppColors.brandAmber),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'CASH',
                      child: Text(
                        'CASH',
                        style: TextStyle(color: AppColors.darkTextPrimary),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'UPI',
                      child: Text(
                        'UPI',
                        style: TextStyle(color: AppColors.darkTextPrimary),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'BANK_TRANSFER',
                      child: Text(
                        'BANK TRANSFER / IMPS / NEFT',
                        style: TextStyle(color: AppColors.darkTextPrimary),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'CHEQUE',
                      child: Text(
                        'CHEQUE',
                        style: TextStyle(color: AppColors.darkTextPrimary),
                      ),
                    ),
                  ],
                  onChanged: (val) {
                    setState(() {
                      _paymentMode = val!;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Txn Reference & Bank Name Row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Reference / UTR No.',
                            style: TextStyle(
                              color: AppColors.darkTextSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _refCtrl,
                            style: TextStyle(color: AppColors.darkTextPrimary),
                            decoration: InputDecoration(
                              hintText: 'Txn ID / Cheque no.',
                              hintStyle: TextStyle(
                                color: AppColors.darkTextTertiary,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: AppColors.darkBorder,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: AppColors.brandAmber,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Depositing Bank',
                            style: TextStyle(
                              color: AppColors.darkTextSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _bankCtrl,
                            style: TextStyle(color: AppColors.darkTextPrimary),
                            decoration: InputDecoration(
                              hintText: 'e.g. HDFC Bank',
                              hintStyle: TextStyle(
                                color: AppColors.darkTextTertiary,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: AppColors.darkBorder,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: AppColors.brandAmber,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Allocation Controls
                Row(
                  children: [
                    Checkbox(
                      value: _autoAllocate,
                      activeColor: AppColors.brandAmber,
                      onChanged: (val) {
                        setState(() {
                          _autoAllocate = val!;
                          if (_autoAllocate) {
                            _selectedInvoiceId = null;
                          }
                        });
                      },
                    ),
                    Text(
                      'Auto-allocate to oldest outstanding invoices',
                      style: TextStyle(
                        color: AppColors.darkTextPrimary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),

                // Specific Invoice dropdown if auto-allocate is false
                if (!_autoAllocate) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Apply to Invoice',
                    style: TextStyle(
                      color: AppColors.darkTextSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String?>(
                    initialValue: _selectedInvoiceId,
                    dropdownColor: AppColors.darkSurface,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.darkBorder),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: AppColors.brandAmber,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items: [
                      DropdownMenuItem<String?>(
                        child: Text(
                          'Leave as Advance Payment',
                          style: TextStyle(color: AppColors.darkTextPrimary),
                        ),
                      ),
                      ...customerInvoices.map(
                        (inv) => DropdownMenuItem(
                          value: inv.id,
                          child: Text(
                            '${inv.invoiceNumber} (O/S: ₹${inv.outstanding.toStringAsFixed(2)})',
                            style: TextStyle(color: AppColors.darkTextPrimary),
                          ),
                        ),
                      ),
                    ],
                    onChanged: (val) {
                      setState(() {
                        _selectedInvoiceId = val;
                        if (val != null) {
                          final selectedInv = customerInvoices.firstWhere(
                            (inv) => inv.id == val,
                          );
                          _amountCtrl.text = selectedInv.outstanding
                              .toStringAsFixed(2);
                        }
                      });
                    },
                  ),
                  if (_selectedInvoiceId != null &&
                      _amountCtrl.text.isNotEmpty) ...[
                    Builder(
                      builder: (context) {
                        try {
                          final selectedInv = customerInvoices.firstWhere(
                            (inv) => inv.id == _selectedInvoiceId,
                          );
                          final amt = double.tryParse(_amountCtrl.text) ?? 0.0;
                          if (amt > selectedInv.outstanding) {
                            final diff = amt - selectedInv.outstanding;
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                'Note: ₹${selectedInv.outstanding.toStringAsFixed(2)} will be applied to this invoice. The remaining ₹${diff.toStringAsFixed(2)} will be saved as Customer Advance.',
                                style: const TextStyle(
                                  color: AppColors.brandAmber,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }
                        } catch (_) {}
                        return const SizedBox();
                      },
                    ),
                  ],
                ],
                const SizedBox(height: 16),

                // Notes
                Text(
                  'Notes / Remarks',
                  style: TextStyle(
                    color: AppColors.darkTextSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _notesCtrl,
                  maxLines: 2,
                  style: TextStyle(color: AppColors.darkTextPrimary),
                  decoration: InputDecoration(
                    hintText: 'Enter notes...',
                    hintStyle: TextStyle(color: AppColors.darkTextTertiary),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.darkBorder),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: AppColors.brandAmber),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: AppColors.darkTextSecondary),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 12),
                    _isSaving
                        ? const CircularProgressIndicator(
                            color: AppColors.brandAmber,
                          )
                        : PrimaryButton(
                            label: 'Save Receipt',
                            onPressed: _save,
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final amount = double.parse(_amountCtrl.text);
      final payment = Payment(
        id: const Uuid().v4(),
        paymentNumber: 'PENDING',
        customerId: _selectedCustomerId!,
        invoiceId: _selectedInvoiceId,
        amount: amount,
        paymentDate: _paymentDate,
        paymentMode: _paymentMode,
        referenceNumber: _refCtrl.text.isNotEmpty ? _refCtrl.text : null,
        bankName: _bankCtrl.text.isNotEmpty ? _bankCtrl.text : null,
        notes: _notesCtrl.text.isNotEmpty ? _notesCtrl.text : null,
        status: PaymentStatus.posted,
        createdBy: 'system',
        createdAt: DateTime.now(),
        updatedBy: 'system',
        updatedAt: DateTime.now(),
        version: 1,
      );

      await ref
          .read(paymentsListProvider.notifier)
          .receivePayment(payment, autoAllocate: _autoAllocate);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment receipt saved successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save receipt: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}

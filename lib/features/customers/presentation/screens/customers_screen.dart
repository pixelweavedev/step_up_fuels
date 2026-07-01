import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:step_up_fuels/core/theme/app_colors.dart';
import 'package:step_up_fuels/core/utils/date_utils.dart';
import 'package:step_up_fuels/core/utils/number_utils.dart';
import 'package:step_up_fuels/features/customers/domain/entities/customer.dart';
import 'package:step_up_fuels/features/customers/domain/entities/customer_document.dart';
import 'package:step_up_fuels/features/customers/domain/entities/customer_note.dart';
import 'package:step_up_fuels/features/customers/domain/entities/document_type.dart';
import 'package:step_up_fuels/features/customers/presentation/providers/customers_provider.dart';
import 'package:step_up_fuels/features/customers/presentation/widgets/customer_contact_form_dialog.dart';
import 'package:step_up_fuels/features/customers/presentation/widgets/customer_form_dialog.dart';
import 'package:step_up_fuels/features/customers/presentation/widgets/customer_site_form_dialog.dart';
import 'package:step_up_fuels/shared/widgets/buttons/primary_button.dart';
import 'package:step_up_fuels/shared/widgets/dialogs/confirm_dialog.dart';
import 'package:step_up_fuels/shared/widgets/empty_states/empty_state_widget.dart';
import 'package:step_up_fuels/shared/widgets/inputs/app_text_field.dart';
import 'package:uuid/uuid.dart';

/// Customers Screen implementing a premium Master-Detail layout.
class CustomersScreen extends ConsumerWidget {
  const CustomersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Row(
        children: [
          // Left side: Master list (380px wide)
          Container(
            width: 380,
            decoration: const BoxDecoration(
              border: Border(right: BorderSide(color: AppColors.darkBorder)),
            ),
            child: const _CustomerMasterList(),
          ),
          // Right side: Detail view
          const Expanded(child: _CustomerDetailView()),
        ],
      ),
    );
  }
}

class _CustomerMasterList extends ConsumerWidget {
  const _CustomerMasterList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customersAsync = ref.watch(customersListProvider);
    final selectedId = ref.watch(selectedCustomerIdProvider);
    final typeFilter = ref.watch(customerTypeFilterProvider);
    final statusFilter = ref.watch(customerStatusFilterProvider);

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
                  const Text(
                    'Customers',
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
                      showDialog(
                        context: context,
                        builder: (context) => const CustomerFormDialog(),
                      );
                    },
                    tooltip: 'Register New Customer',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              AppTextField(
                hint: 'Search code or name...',
                prefixIcon: Icons.search_rounded,
                onChanged: (val) {
                  ref.read(customerSearchQueryProvider.notifier).state = val;
                },
              ),
            ],
          ),
        ),

        // Filters Panel
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              // Type Filters
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Type:',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.darkTextSecondary,
                    ),
                  ),
                  DropdownButton<String?>(
                    value: typeFilter,
                    dropdownColor: AppColors.darkSurface,
                    underline: const SizedBox(),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.brandAmber,
                    ),
                    items: const [
                      DropdownMenuItem(child: Text('All Types')),
                      DropdownMenuItem(
                        value: 'COMPANY',
                        child: Text('Company'),
                      ),
                      DropdownMenuItem(
                        value: 'INDIVIDUAL',
                        child: Text('Individual'),
                      ),
                      DropdownMenuItem(
                        value: 'GOVERNMENT',
                        child: Text('Government'),
                      ),
                    ],
                    onChanged: (val) {
                      ref.read(customerTypeFilterProvider.notifier).state = val;
                    },
                  ),
                ],
              ),
              // Status Filter Toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Show Soft-Deleted:',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.darkTextSecondary,
                    ),
                  ),
                  Switch(
                    value: statusFilter == null || statusFilter == false,
                    activeThumbColor: AppColors.brandAmber,
                    onChanged: (val) {
                      ref.read(customerStatusFilterProvider.notifier).state =
                          val ? null : true;
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(color: AppColors.darkBorder),

        // Customer Cards List
        Expanded(
          child: customersAsync.when(
            data: (list) {
              if (list.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: EmptyStateWidget(
                      icon: Icons.people_outline_rounded,
                      title: 'No Customers Found',
                      subtitle: 'Register a new customer or adjust filters.',
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
                  final customer = list[index];
                  final isSelected = customer.id == selectedId;
                  final isDeleted = customer.deletedAt != null;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: InkWell(
                      onTap: () {
                        ref.read(selectedCustomerIdProvider.notifier).state =
                            customer.id;
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
                                    customer.customerCode.isEmpty
                                        ? 'CUST-TBD'
                                        : customer.customerCode,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.brandAmber,
                                    ),
                                  ),
                                ),
                                if (isDeleted)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.error.withValues(
                                        alpha: 0.15,
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'Deleted',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.error,
                                      ),
                                    ),
                                  )
                                else
                                  Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: customer.isActive
                                              ? AppColors.success
                                              : AppColors.darkTextTertiary,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        customer.type.displayName,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: AppColors.darkTextSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              customer.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.darkTextPrimary,
                              ),
                            ),
                            if (customer.tradeName != null &&
                                customer.tradeName!.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                customer.tradeName!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.darkTextSecondary,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Outstanding:',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.darkTextTertiary,
                                  ),
                                ),
                                Text(
                                  NumberUtils.formatCurrency(
                                    0.0,
                                  ), // Mocked to ₹0.00 in Phase 2
                                  style: const TextStyle(
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
}

class _CustomerDetailView extends ConsumerWidget {
  const _CustomerDetailView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedId = ref.watch(selectedCustomerIdProvider);
    if (selectedId == null) {
      return const Center(
        child: EmptyStateWidget(
          icon: Icons.people_outline_rounded,
          title: 'Select a Customer',
          subtitle:
              'Choose a customer from the left sidebar to view profile details, locations, contact lists, and transaction history.',
        ),
      );
    }

    final customerAsync = ref.watch(selectedCustomerProvider);

    return customerAsync.when(
      data: (customer) => _CustomerDetailScaffold(customer: customer),
      error: (err, st) => Center(
        child: Text(
          'Error loading details: $err',
          style: const TextStyle(color: AppColors.error),
        ),
      ),
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.brandAmber),
      ),
    );
  }
}

class _CustomerDetailScaffold extends ConsumerStatefulWidget {
  const _CustomerDetailScaffold({required this.customer});

  final Customer customer;

  @override
  ConsumerState<_CustomerDetailScaffold> createState() =>
      _CustomerDetailScaffoldState();
}

class _CustomerDetailScaffoldState
    extends ConsumerState<_CustomerDetailScaffold>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customer = widget.customer;
    final isDeleted = customer.deletedAt != null;

    return Column(
      children: [
        // Detail Header
        Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: AppColors.darkSurface,
            border: Border(bottom: BorderSide(color: AppColors.darkBorder)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar/Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.brandAmber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.business_rounded,
                  color: AppColors.brandAmber,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              // Name & Code
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          customer.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkTextPrimary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: isDeleted
                                ? AppColors.error.withValues(alpha: 0.15)
                                : AppColors.brandNavyLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isDeleted
                                ? 'Inactive (Deleted)'
                                : (customer.isActive ? 'Active' : 'Inactive'),
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
                    const SizedBox(height: 4),
                    Text(
                      'Customer Code: ${customer.customerCode.isEmpty ? 'CUST-TBD' : customer.customerCode} • Type: ${customer.type.displayName}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.darkTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Action buttons
              Row(
                children: [
                  if (!isDeleted) ...[
                    SecondaryButton(
                      label: 'Edit',
                      icon: Icons.edit_outlined,
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) =>
                              CustomerFormDialog(customer: customer),
                        );
                      },
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error.withValues(alpha: 0.2),
                        foregroundColor: AppColors.error,
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.delete_outline, size: 16),
                      label: const Text('Delete'),
                      onPressed: () async {
                        final confirmed = await showConfirmDialog(
                          context: context,
                          title: 'Soft-Delete Customer',
                          message:
                              'Are you sure you want to delete this customer? All transaction details will remain but the customer will be marked as inactive.',
                          confirmLabel: 'Delete',
                          isDangerous: true,
                        );
                        if (confirmed == true) {
                          await ref
                              .read(customersListProvider.notifier)
                              .deleteCustomer(customer.id);
                        }
                      },
                    ),
                  ] else ...[
                    PrimaryButton(
                      label: 'Restore Customer',
                      icon: Icons.restore_outlined,
                      onPressed: () async {
                        await ref
                            .read(customersListProvider.notifier)
                            .restoreCustomer(customer.id);
                      },
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),

        // Detail Content Split Pane
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Panel: Customer Summary Info Card (300px)
              Container(
                width: 300,
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  border: Border(
                    right: BorderSide(color: AppColors.darkBorder),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Overview Details',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildOverviewItem(
                      'GSTIN',
                      customer.gstin ?? 'Not Provided',
                      Icons.receipt_long_outlined,
                    ),
                    const SizedBox(height: 12),
                    _buildOverviewItem(
                      'PAN',
                      customer.pan ?? 'Not Provided',
                      Icons.payment_outlined,
                    ),
                    const SizedBox(height: 12),
                    _buildOverviewItem(
                      'Credit Limit',
                      NumberUtils.formatCurrency(customer.creditLimit),
                      Icons.currency_rupee_outlined,
                    ),
                    const SizedBox(height: 12),
                    _buildOverviewItem(
                      'Credit Days',
                      '${customer.creditDays} Days',
                      Icons.calendar_today_outlined,
                    ),
                    const SizedBox(height: 12),
                    _buildOverviewItem(
                      'Created On',
                      AppDateUtils.toDisplay(customer.createdAt),
                      Icons.calendar_month_outlined,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Internal Notes',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.darkCard,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.darkBorder),
                        ),
                        child: SingleChildScrollView(
                          child: Text(
                            customer.notes ??
                                'No internal notes saved for this customer.',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.darkTextSecondary,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Right Panel: Tabbed details
              Expanded(
                child: Column(
                  children: [
                    TabBar(
                      controller: _tabController,
                      indicatorColor: AppColors.brandAmber,
                      labelColor: AppColors.brandAmber,
                      unselectedLabelColor: AppColors.darkTextSecondary,
                      labelStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      tabs: const [
                        Tab(text: 'Sites'),
                        Tab(text: 'Contacts'),
                        Tab(text: 'Documents'),
                        Tab(text: 'Invoices'),
                        Tab(text: 'Payments'),
                        Tab(text: 'Notes'),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildSitesTab(),
                          _buildContactsTab(),
                          _buildDocumentsTab(),
                          _buildInvoicesTab(),
                          _buildPaymentsTab(),
                          _buildNotesTab(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewItem(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.darkTextTertiary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.darkTextTertiary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.darkTextPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSitesTab() {
    final customer = widget.customer;
    final sitesAsync = ref.watch(customerSitesProvider(customer.id));

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Delivery Locations',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkTextPrimary,
                ),
              ),
              if (customer.deletedAt == null)
                PrimaryButton(
                  label: 'Add Site',
                  icon: Icons.add_location_alt_outlined,
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) =>
                          CustomerSiteFormDialog(customerId: customer.id),
                    );
                  },
                ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: sitesAsync.when(
              data: (list) {
                if (list.isEmpty) {
                  return const Center(
                    child: EmptyStateWidget(
                      icon: Icons.place_outlined,
                      title: 'No Sites Registered',
                      subtitle:
                          'Add delivery sites where fuel dispatch bowsers deliver diesel.',
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final site = list[index];
                    return Card(
                      color: AppColors.darkCard,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: site.isDefault
                              ? AppColors.brandAmber
                              : AppColors.darkBorder,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.location_on_rounded,
                              color: site.isDefault
                                  ? AppColors.brandAmber
                                  : AppColors.darkTextSecondary,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        site.name,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.darkTextPrimary,
                                        ),
                                      ),
                                      if (site.isDefault) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.brandAmber
                                                .withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                            border: Border.all(
                                              color: AppColors.brandAmber
                                                  .withValues(alpha: 0.3),
                                            ),
                                          ),
                                          child: const Text(
                                            'Default',
                                            style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.brandAmber,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    [
                                          site.addressLine1,
                                          site.addressLine2,
                                          site.city,
                                          if (site.state != null &&
                                              site.stateCode != null)
                                            '${site.state} (${site.stateCode})'
                                          else if (site.state != null)
                                            site.state,
                                          site.pincode,
                                        ]
                                        .where((x) => x != null && x.isNotEmpty)
                                        .join(', '),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.darkTextSecondary,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (customer.deletedAt == null) ...[
                              IconButton(
                                icon: const Icon(
                                  Icons.edit_outlined,
                                  size: 18,
                                  color: AppColors.darkTextSecondary,
                                ),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) =>
                                        CustomerSiteFormDialog(
                                          customerId: customer.id,
                                          site: site,
                                        ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  size: 18,
                                  color: AppColors.error,
                                ),
                                onPressed: () async {
                                  final confirmed = await showConfirmDialog(
                                    context: context,
                                    title: 'Delete Delivery Site',
                                    message:
                                        'Are you sure you want to delete this delivery site?',
                                    confirmLabel: 'Delete',
                                    isDangerous: true,
                                  );
                                  if (confirmed) {
                                    final repo = ref.read(
                                      customerRepositoryProvider,
                                    );
                                    await repo.deleteSite(site.id);
                                    ref.invalidate(
                                      customerSitesProvider(customer.id),
                                    );
                                  }
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              error: (err, st) =>
                  Center(child: Text('Error loading sites: $err')),
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.brandAmber),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactsTab() {
    final customer = widget.customer;
    final contactsAsync = ref.watch(customerContactsProvider(customer.id));

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Contact Persons',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkTextPrimary,
                ),
              ),
              if (customer.deletedAt == null)
                PrimaryButton(
                  label: 'Add Contact',
                  icon: Icons.person_add_alt_1_outlined,
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) =>
                          CustomerContactFormDialog(customerId: customer.id),
                    );
                  },
                ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: contactsAsync.when(
              data: (list) {
                if (list.isEmpty) {
                  return const Center(
                    child: EmptyStateWidget(
                      icon: Icons.person_outline_rounded,
                      title: 'No Contacts Registered',
                      subtitle:
                          'Add representatives, purchase managers, or site agents.',
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final contact = list[index];
                    return Card(
                      color: AppColors.darkCard,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: contact.isPrimary
                              ? AppColors.brandAmber
                              : AppColors.darkBorder,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.contact_phone_rounded,
                              color: contact.isPrimary
                                  ? AppColors.brandAmber
                                  : AppColors.darkTextSecondary,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        contact.name,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.darkTextPrimary,
                                        ),
                                      ),
                                      if (contact.isPrimary) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.brandAmber
                                                .withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                            border: Border.all(
                                              color: AppColors.brandAmber
                                                  .withValues(alpha: 0.3),
                                            ),
                                          ),
                                          child: const Text(
                                            'Primary Contact',
                                            style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.brandAmber,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  if (contact.designation != null &&
                                      contact.designation!.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      contact.designation!,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.darkTextSecondary,
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      if (contact.phone != null &&
                                          contact.phone!.isNotEmpty) ...[
                                        const Icon(
                                          Icons.phone_iphone_rounded,
                                          size: 14,
                                          color: AppColors.darkTextTertiary,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          contact.phone!,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.darkTextPrimary,
                                          ),
                                        ),
                                        const SizedBox(width: 20),
                                      ],
                                      if (contact.email != null &&
                                          contact.email!.isNotEmpty) ...[
                                        const Icon(
                                          Icons.alternate_email_rounded,
                                          size: 14,
                                          color: AppColors.darkTextTertiary,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          contact.email!,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.darkTextPrimary,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            if (customer.deletedAt == null) ...[
                              IconButton(
                                icon: const Icon(
                                  Icons.edit_outlined,
                                  size: 18,
                                  color: AppColors.darkTextSecondary,
                                ),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) =>
                                        CustomerContactFormDialog(
                                          customerId: customer.id,
                                          contact: contact,
                                        ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  size: 18,
                                  color: AppColors.error,
                                ),
                                onPressed: () async {
                                  final confirmed = await showConfirmDialog(
                                    context: context,
                                    title: 'Delete Contact',
                                    message:
                                        'Are you sure you want to delete this contact person?',
                                    confirmLabel: 'Delete',
                                    isDangerous: true,
                                  );
                                  if (confirmed) {
                                    final repo = ref.read(
                                      customerRepositoryProvider,
                                    );
                                    await repo.deleteContact(contact.id);
                                    ref.invalidate(
                                      customerContactsProvider(customer.id),
                                    );
                                  }
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              error: (err, st) =>
                  Center(child: Text('Error loading contacts: $err')),
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.brandAmber),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoicesTab() {
    return const Center(
      child: EmptyStateWidget(
        icon: Icons.receipt_long_rounded,
        title: 'GST Invoice History',
        subtitle:
            'Invoice generation and history will be implemented in Phase 4.',
      ),
    );
  }

  Widget _buildPaymentsTab() {
    return const Center(
      child: EmptyStateWidget(
        icon: Icons.payments_rounded,
        title: 'Customer Payments & Receipts',
        subtitle:
            'Payment tracking and outstanding ledger balances will be implemented in Phase 6.',
      ),
    );
  }

  Widget _buildDocumentsTab() {
    final customer = widget.customer;
    final docsAsync = ref.watch(customerDocumentsProvider(customer.id));

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Customer Documents & Attachments',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkTextPrimary,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add, color: AppColors.brandAmber),
                onPressed: () => _showAddDocumentDialog(customer.id),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: docsAsync.when(
              data: (list) {
                if (list.isEmpty) {
                  return const Center(
                    child: Text(
                      'No compliance or contract documents uploaded.',
                      style: TextStyle(
                        color: AppColors.darkTextSecondary,
                        fontSize: 13,
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  itemCount: list.length,
                  separatorBuilder: (_, __) =>
                      const Divider(color: AppColors.darkBorder),
                  itemBuilder: (context, index) {
                    final doc = list[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.picture_as_pdf_outlined,
                        color: AppColors.error,
                      ),
                      title: Text(
                        doc.documentType.displayName,
                        style: const TextStyle(
                          color: AppColors.darkTextPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        doc.fileUrl,
                        style: const TextStyle(
                          color: AppColors.darkTextSecondary,
                          fontSize: 11,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: AppColors.error,
                          size: 20,
                        ),
                        onPressed: () =>
                            _handleDeleteDocument(doc.id, customer.id),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.brandAmber),
              ),
              error: (err, _) => Center(
                child: Text(
                  'Error: $err',
                  style: const TextStyle(color: AppColors.error),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddDocumentDialog(String customerId) async {
    final formKey = GlobalKey<FormState>();
    final fileUrlController = TextEditingController();
    DocumentType selectedType = DocumentType.gstCertificate;

    await showDialog(
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
                      const Text(
                        'Upload Document Details',
                        style: TextStyle(
                          color: AppColors.darkTextPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<DocumentType>(
                        initialValue: selectedType,
                        dropdownColor: AppColors.darkSurface,
                        decoration: const InputDecoration(
                          labelText: 'Document Type',
                        ),
                        items: DocumentType.values.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type.displayName),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => selectedType = val);
                        },
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: fileUrlController,
                        label: 'Document Name / File URL *',
                        hint: 'e.g. gst_certificate_2026.pdf',
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text(
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
                              final repo = ref.read(customerRepositoryProvider);
                              final doc = CustomerDocument(
                                id: const Uuid().v4(),
                                customerId: customerId,
                                documentType: selectedType,
                                fileUrl: fileUrlController.text.trim(),
                                createdBy: 'system',
                                createdAt: DateTime.now(),
                              );
                              final result = await repo.saveDocument(doc);
                              result.when(
                                success: (_) {
                                  ref.invalidate(
                                    customerDocumentsProvider(customerId),
                                  );
                                  Navigator.of(context).pop();
                                },
                                failure: (f) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(f.userMessage)),
                                  );
                                },
                              );
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

  Future<void> _handleDeleteDocument(String id, String customerId) async {
    final repo = ref.read(customerRepositoryProvider);
    final result = await repo.deleteDocument(id);
    result.when(
      success: (_) => ref.invalidate(customerDocumentsProvider(customerId)),
      failure: (f) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(f.userMessage))),
    );
  }

  Widget _buildNotesTab() {
    final customer = widget.customer;
    final notesAsync = ref.watch(customerNotesProvider(customer.id));

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'General Remarks & Notes',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.darkTextPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.darkCard,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.darkBorder),
            ),
            child: Text(
              customer.notes ?? 'No general remarks saved for this customer.',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.darkTextSecondary,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Notes Log & Instructions History',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkTextPrimary,
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.add_comment_outlined,
                  color: AppColors.brandAmber,
                  size: 20,
                ),
                onPressed: () => _showAddNoteDialog(customer.id),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: notesAsync.when(
              data: (list) {
                if (list.isEmpty) {
                  return const Center(
                    child: Text(
                      'No log entries recorded.',
                      style: TextStyle(
                        color: AppColors.darkTextSecondary,
                        fontSize: 13,
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  itemCount: list.length,
                  separatorBuilder: (_, __) =>
                      const Divider(color: AppColors.darkBorder),
                  itemBuilder: (context, index) {
                    final item = list[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        item.notes,
                        style: const TextStyle(
                          color: AppColors.darkTextPrimary,
                          fontSize: 13,
                        ),
                      ),
                      subtitle: Text(
                        'Logged by ${item.createdBy} on ${AppDateUtils.toDisplay(item.createdAt)}',
                        style: const TextStyle(
                          color: AppColors.darkTextSecondary,
                          fontSize: 11,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: AppColors.error,
                          size: 18,
                        ),
                        onPressed: () =>
                            _handleDeleteNote(item.id, customer.id),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.brandAmber),
              ),
              error: (err, _) => Center(
                child: Text(
                  'Error: $err',
                  style: const TextStyle(color: AppColors.error),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddNoteDialog(String customerId) async {
    final noteController = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: AppColors.darkSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add Note Log Entry',
                  style: TextStyle(
                    color: AppColors.darkTextPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: noteController,
                  label: 'Remarks / Special Directives *',
                  hint: 'e.g. Deliver only between 9 AM-5 PM.',
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: AppColors.darkTextSecondary),
                      ),
                    ),
                    const SizedBox(width: 12),
                    PrimaryButton(
                      label: 'Log Note',
                      onPressed: () async {
                        if (noteController.text.trim().isEmpty) return;
                        final repo = ref.read(customerRepositoryProvider);
                        final note = CustomerNote(
                          id: const Uuid().v4(),
                          customerId: customerId,
                          notes: noteController.text.trim(),
                          createdBy: 'system',
                          createdAt: DateTime.now(),
                        );
                        final result = await repo.saveNote(note);
                        result.when(
                          success: (_) {
                            ref.invalidate(customerNotesProvider(customerId));
                            Navigator.of(context).pop();
                          },
                          failure: (f) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(f.userMessage)),
                            );
                          },
                        );
                      },
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

  Future<void> _handleDeleteNote(String id, String customerId) async {
    final repo = ref.read(customerRepositoryProvider);
    final result = await repo.deleteNote(id);
    result.when(
      success: (_) => ref.invalidate(customerNotesProvider(customerId)),
      failure: (f) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(f.userMessage))),
    );
  }
}










/// Reports module — Phase 7 implementation target.
class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ModulePlaceholder(
      moduleName: 'Reports',
      description:
          'Sales report, GSTR-1 export, stock report, '
          'payment aging, and customer ledger reports.',
      icon: Icons.bar_chart_rounded,
      phase: 'Phase 7',
    );
  }
}

/// Settings module — Phase 9 implementation target.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ModulePlaceholder(
      moduleName: 'Settings',
      description:
          'Company profile, GSTIN, bank details, invoice prefix, '
          'print settings, and theme preferences.',
      icon: Icons.settings_rounded,
      phase: 'Phase 9',
    );
  }
}

// ─── Shared Placeholder Widget ─────────────────────────────────────────────

class _ModulePlaceholder extends StatelessWidget {
  const _ModulePlaceholder({
    required this.moduleName,
    required this.description,
    required this.icon,
    required this.phase,
  });

  final String moduleName;
  final String description;
  final IconData icon;
  final String phase;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page header
          Row(
            children: [
              Text(
                moduleName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkTextPrimary,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: AppColors.brandAmber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.brandAmber.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  phase,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.brandAmber,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Expanded(
            child: EmptyStateWidget(
              icon: icon,
              title: '$moduleName — Coming in $phase',
              subtitle: description,
            ),
          ),
        ],
      ),
    );
  }
}

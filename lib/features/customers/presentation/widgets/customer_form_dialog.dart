import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:step_up_fuels/core/theme/app_colors.dart';
import 'package:step_up_fuels/core/utils/date_utils.dart';
import 'package:step_up_fuels/features/customers/domain/entities/customer.dart';
import 'package:step_up_fuels/features/customers/domain/entities/customer_type.dart';
import 'package:step_up_fuels/features/customers/domain/entities/fuel_type.dart';
import 'package:step_up_fuels/features/customers/domain/entities/payment_terms.dart';
import 'package:step_up_fuels/features/customers/domain/validators/customer_validator.dart';
import 'package:step_up_fuels/features/customers/presentation/providers/customers_provider.dart';
import 'package:step_up_fuels/shared/widgets/buttons/primary_button.dart';
import 'package:step_up_fuels/shared/widgets/inputs/app_text_field.dart';
import 'package:uuid/uuid.dart';

/// Dialog to create or edit enterprise customer details.
class CustomerFormDialog extends ConsumerStatefulWidget {
  const CustomerFormDialog({super.key, this.customer});

  /// The customer to edit (null for creation mode).
  final Customer? customer;

  @override
  ConsumerState<CustomerFormDialog> createState() => _CustomerFormDialogState();
}

class _CustomerFormDialogState extends ConsumerState<CustomerFormDialog>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TabController _tabController;

  // Controllers — General & Address
  final _nameController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _billingAddress1Controller = TextEditingController();
  final _billingAddress2Controller = TextEditingController();
  final _billingAreaController = TextEditingController();
  final _billingCityController = TextEditingController();
  final _billingStateController = TextEditingController();
  final _billingPincodeController = TextEditingController();
  final _billingCountryController = TextEditingController();

  // Controllers — GST & Compliance
  final _gstinController = TextEditingController();
  final _panController = TextEditingController();
  final _legalNameController = TextEditingController();
  final _tradeNameController = TextEditingController();
  final _gstRegTypeController = TextEditingController();
  final _tanController = TextEditingController();

  // Controllers — Credit & Accounting
  final _creditLimitController = TextEditingController();
  final _creditDaysController = TextEditingController();
  final _securityDepositController = TextEditingController();
  final _openingBalanceController = TextEditingController();

  // Controllers — Prefs & PO Details
  final _defaultGstRateController = TextEditingController();
  final _defaultPriceController = TextEditingController();
  final _poNumberController = TextEditingController();
  final _poValueController = TextEditingController();

  // Controllers — Additional / Notes
  final _invoicePrefixController = TextEditingController();
  final _notesController = TextEditingController();

  // Selected State variables
  CustomerType _selectedType = CustomerType.company;
  PaymentTerms _selectedTerms = PaymentTerms.advance;
  FuelType _selectedFuel = FuelType.diesel;

  DateTime? _poDate;
  DateTime? _poValidTill;

  bool _isActive = true;
  bool _emailInvoice = true;
  bool _whatsappInvoice = false;
  bool _requirePo = false;
  bool _requireDc = false;
  bool _requireSignature = false;
  bool _gstApplicable = true;
  bool _eInvoiceRequired = false;
  bool _eWayBillRequired = false;

  bool _isLoading = false;
  String? _errorMessage;

  bool get _isEditMode => widget.customer != null;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);

    if (_isEditMode) {
      final cust = widget.customer!;
      _nameController.text = cust.name;
      _displayNameController.text = cust.displayName ?? cust.name;
      _billingAddress1Controller.text = cust.billingAddressLine1 ?? '';
      _billingAddress2Controller.text = cust.billingAddressLine2 ?? '';
      _billingAreaController.text = cust.billingArea ?? '';
      _billingCityController.text = cust.billingCity ?? '';
      _billingStateController.text = cust.billingState ?? '';
      _billingPincodeController.text = cust.billingPincode ?? '';
      _billingCountryController.text = cust.billingCountry ?? 'India';

      _gstinController.text = cust.gstin ?? '';
      _panController.text = cust.pan ?? '';
      _legalNameController.text = cust.legalBusinessName ?? '';
      _tradeNameController.text = cust.tradeName ?? '';
      _gstRegTypeController.text = cust.gstRegistrationType ?? '';
      _tanController.text = cust.tan ?? '';

      _creditLimitController.text = cust.creditLimit.toString();
      _creditDaysController.text = cust.creditDays.toString();
      _securityDepositController.text = cust.securityDeposit.toString();
      _openingBalanceController.text = cust.openingBalance.toString();

      _defaultGstRateController.text = cust.defaultGstRate.toString();
      _defaultPriceController.text = cust.defaultPrice?.toString() ?? '';
      _poNumberController.text = cust.poNumber ?? '';
      _poValueController.text = cust.poValue?.toString() ?? '';

      _invoicePrefixController.text = cust.invoicePrefix ?? '';
      _notesController.text = cust.notes ?? '';

      _selectedType = cust.type;
      _selectedTerms = cust.paymentTerms ?? PaymentTerms.advance;
      _selectedFuel = cust.fuelType ?? FuelType.diesel;
      _poDate = cust.poDate;
      _poValidTill = cust.poValidTill;

      _isActive = cust.isActive;
      _emailInvoice = cust.emailInvoice;
      _whatsappInvoice = cust.whatsappInvoice;
      _requirePo = cust.requirePo;
      _requireDc = cust.requireDc;
      _requireSignature = cust.requireSignature;
      _gstApplicable = cust.gstApplicable;
      _eInvoiceRequired = cust.eInvoiceRequired;
      _eWayBillRequired = cust.eWayBillRequired;
    } else {
      _billingCountryController.text = 'India';
      _creditLimitController.text = '0.0';
      _creditDaysController.text = '30';
      _securityDepositController.text = '0.0';
      _openingBalanceController.text = '0.0';
      _defaultGstRateController.text = '0.18';
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _displayNameController.dispose();
    _billingAddress1Controller.dispose();
    _billingAddress2Controller.dispose();
    _billingAreaController.dispose();
    _billingCityController.dispose();
    _billingStateController.dispose();
    _billingPincodeController.dispose();
    _billingCountryController.dispose();
    _gstinController.dispose();
    _panController.dispose();
    _legalNameController.dispose();
    _tradeNameController.dispose();
    _gstRegTypeController.dispose();
    _tanController.dispose();
    _creditLimitController.dispose();
    _creditDaysController.dispose();
    _securityDepositController.dispose();
    _openingBalanceController.dispose();
    _defaultGstRateController.dispose();
    _defaultPriceController.dispose();
    _poNumberController.dispose();
    _poValueController.dispose();
    _invoicePrefixController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final notifier = ref.read(customersListProvider.notifier);
      final double creditLimit =
          double.tryParse(_creditLimitController.text.trim()) ?? 0.0;
      final int creditDays =
          int.tryParse(_creditDaysController.text.trim()) ?? 30;
      final double securityDeposit =
          double.tryParse(_securityDepositController.text.trim()) ?? 0.0;
      final double openingBalance =
          double.tryParse(_openingBalanceController.text.trim()) ?? 0.0;
      final double defaultGstRate =
          double.tryParse(_defaultGstRateController.text.trim()) ?? 0.18;
      final double? defaultPrice = double.tryParse(
        _defaultPriceController.text.trim(),
      );
      final double? poValue = double.tryParse(_poValueController.text.trim());

      final customer = Customer(
        id: _isEditMode ? widget.customer!.id : const Uuid().v4(),
        customerCode: _isEditMode ? widget.customer!.customerCode : '',
        name: _nameController.text.trim(),
        displayName: _displayNameController.text.trim().isEmpty
            ? _nameController.text.trim()
            : _displayNameController.text.trim(),
        tradeName: _tradeNameController.text.trim().isEmpty
            ? null
            : _tradeNameController.text.trim(),
        legalBusinessName: _legalNameController.text.trim().isEmpty
            ? null
            : _legalNameController.text.trim(),
        type: _selectedType,
        isActive: _isActive,
        gstin: _gstinController.text.trim().isEmpty
            ? null
            : _gstinController.text.trim().toUpperCase(),
        pan: _panController.text.trim().isEmpty
            ? null
            : _panController.text.trim().toUpperCase(),
        state: _billingStateController.text.trim().isEmpty
            ? null
            : _billingStateController.text.trim(),
        placeOfSupply: _billingStateController.text.trim().isEmpty
            ? null
            : _billingStateController.text.trim(),
        gstRegistrationType: _gstRegTypeController.text.trim().isEmpty
            ? null
            : _gstRegTypeController.text.trim(),
        tan: _tanController.text.trim().isEmpty
            ? null
            : _tanController.text.trim().toUpperCase(),
        billingAddressLine1: _billingAddress1Controller.text.trim().isEmpty
            ? null
            : _billingAddress1Controller.text.trim(),
        billingAddressLine2: _billingAddress2Controller.text.trim().isEmpty
            ? null
            : _billingAddress2Controller.text.trim(),
        billingArea: _billingAreaController.text.trim().isEmpty
            ? null
            : _billingAreaController.text.trim(),
        billingCity: _billingCityController.text.trim().isEmpty
            ? null
            : _billingCityController.text.trim(),
        billingState: _billingStateController.text.trim().isEmpty
            ? null
            : _billingStateController.text.trim(),
        billingPincode: _billingPincodeController.text.trim().isEmpty
            ? null
            : _billingPincodeController.text.trim(),
        billingCountry: _billingCountryController.text.trim().isEmpty
            ? 'India'
            : _billingCountryController.text.trim(),
        paymentTerms: _selectedTerms,
        creditLimit: creditLimit,
        creditDays: creditDays,
        securityDeposit: securityDeposit,
        fuelType: _selectedFuel,
        defaultGstRate: defaultGstRate,
        defaultPrice: defaultPrice,
        poNumber: _poNumberController.text.trim().isEmpty
            ? null
            : _poNumberController.text.trim(),
        poDate: _poDate,
        poValidTill: _poValidTill,
        poValue: poValue,
        poRemainingBalance: _isEditMode
            ? widget.customer!.poRemainingBalance
            : poValue,
        invoicePrefix: _invoicePrefixController.text.trim().isEmpty
            ? null
            : _invoicePrefixController.text.trim(),
        emailInvoice: _emailInvoice,
        whatsappInvoice: _whatsappInvoice,
        requirePo: _requirePo,
        requireDc: _requireDc,
        requireSignature: _requireSignature,
        gstApplicable: _gstApplicable,
        eInvoiceRequired: _eInvoiceRequired,
        eWayBillRequired: _eWayBillRequired,
        openingBalance: openingBalance,
        currentBalance: _isEditMode
            ? widget.customer!.currentBalance
            : openingBalance,
        lastPaymentDate: _isEditMode ? widget.customer!.lastPaymentDate : null,
        lastInvoiceDate: _isEditMode ? widget.customer!.lastInvoiceDate : null,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        createdBy: _isEditMode ? widget.customer!.createdBy : 'system',
        createdAt: _isEditMode ? widget.customer!.createdAt : DateTime.now(),
        updatedBy: 'system',
        updatedAt: DateTime.now(),
        deletedAt: _isEditMode ? widget.customer!.deletedAt : null,
        version: _isEditMode ? widget.customer!.version : 1,
        tenantId: _isEditMode ? widget.customer!.tenantId : null,
      );

      if (_isEditMode) {
        await notifier.updateCustomer(customer);
      } else {
        await notifier.createCustomer(customer);
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.darkSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700, maxHeight: 650),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _isEditMode
                        ? 'Edit Enterprise Customer'
                        : 'Register Enterprise Customer',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkTextPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: AppColors.darkTextSecondary,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Tab Bar
            TabBar(
              controller: _tabController,
              indicatorColor: AppColors.brandAmber,
              labelColor: AppColors.brandAmber,
              unselectedLabelColor: AppColors.darkTextSecondary,
              labelStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              isScrollable: true,
              tabs: const [
                Tab(text: 'General & Address'),
                Tab(text: 'GST & Compliance'),
                Tab(text: 'Credit & Accounting'),
                Tab(text: 'Preferences & PO'),
                Tab(text: 'Additional Details'),
              ],
            ),

            // Error display
            if (_errorMessage != null)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: AppColors.error, fontSize: 13),
                ),
              ),

            // Form inputs view
            Expanded(
              child: Form(
                key: _formKey,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildGeneralAddressTab(),
                    _buildGstComplianceTab(),
                    _buildCreditAccountingTab(),
                    _buildPreferencesPoTab(),
                    _buildAdditionalNotesTab(),
                  ],
                ),
              ),
            ),

            // Actions footer
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SecondaryButton(
                    label: 'Cancel',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 12),
                  PrimaryButton(
                    label: _isEditMode ? 'Save Changes' : 'Create Customer',
                    isLoading: _isLoading,
                    onPressed: _handleSubmit,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneralAddressTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  controller: _nameController,
                  label: 'Company Legal Name *',
                  hint: 'e.g. Tata Motors Ltd',
                  prefixIcon: Icons.business_outlined,
                  validator: CustomerValidator.validateName,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppTextField(
                  controller: _displayNameController,
                  label: 'Display Name / Alias',
                  hint: 'e.g. Tata Motors',
                  prefixIcon: Icons.storefront_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Customer Category',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.darkTextSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: CustomerType.values.map((type) {
              final isSelected = _selectedType == type;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(type.displayName),
                  selected: isSelected,
                  onSelected: (val) {
                    if (val) setState(() => _selectedType = type);
                  },
                  backgroundColor: AppColors.darkCard,
                  selectedColor: AppColors.brandAmber.withValues(alpha: 0.2),
                  labelStyle: TextStyle(
                    color: isSelected
                        ? AppColors.brandAmber
                        : AppColors.darkTextSecondary,
                    fontSize: 12,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.brandAmber
                          : AppColors.darkBorder,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          const Text(
            'Billing Address Details',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.darkTextPrimary,
            ),
          ),
          const Divider(color: AppColors.darkBorder),
          const SizedBox(height: 12),
          AppTextField(
            controller: _billingAddress1Controller,
            label: 'Address Line 1',
            hint: 'Flat/Office No, Building name...',
            prefixIcon: Icons.location_on_outlined,
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: _billingAddress2Controller,
            label: 'Address Line 2',
            hint: 'Street, sector, landmark...',
            prefixIcon: Icons.map_outlined,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  controller: _billingAreaController,
                  label: 'Area / Locality',
                  hint: 'e.g. Akurdi',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppTextField(
                  controller: _billingCityController,
                  label: 'City',
                  hint: 'e.g. Pune',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  controller: _billingStateController,
                  label: 'State',
                  hint: 'e.g. Maharashtra',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppTextField(
                  controller: _billingPincodeController,
                  label: 'PIN Code',
                  hint: '6-digit code',
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppTextField(
                  controller: _billingCountryController,
                  label: 'Country',
                  hint: 'e.g. India',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGstComplianceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  controller: _gstinController,
                  label: 'GSTIN',
                  hint: 'e.g. 27AAAAA1111A1Z1',
                  prefixIcon: Icons.description_outlined,
                  textCapitalization: TextCapitalization.characters,
                  validator: CustomerValidator.validateGstin,
                  onChanged: (value) {
                    if (value.trim().length >= 12) {
                      final potentialPan = value
                          .trim()
                          .substring(2, 12)
                          .toUpperCase();
                      if (CustomerValidator.validatePan(potentialPan) == null) {
                        _panController.text = potentialPan;
                      }
                    }
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppTextField(
                  controller: _panController,
                  label: 'PAN',
                  hint: 'e.g. ABCDE1234F',
                  prefixIcon: Icons.payment_outlined,
                  textCapitalization: TextCapitalization.characters,
                  validator: CustomerValidator.validatePan,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  controller: _legalNameController,
                  label: 'Legal Business Name',
                  hint: 'Name registered in GST certificate',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppTextField(
                  controller: _tradeNameController,
                  label: 'Trade Name',
                  hint: 'Brand/trade title',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  controller: _gstRegTypeController,
                  label: 'GST Registration Type',
                  hint: 'e.g. Regular, Composition',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppTextField(
                  controller: _tanController,
                  label: 'TAN (Optional)',
                  hint: 'Tax deduction account number',
                  textCapitalization: TextCapitalization.characters,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Compliance Settings',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.darkTextPrimary,
            ),
          ),
          const Divider(color: AppColors.darkBorder),
          CheckboxListTile(
            title: const Text(
              'GST Applicable',
              style: TextStyle(color: AppColors.darkTextPrimary, fontSize: 13),
            ),
            subtitle: const Text(
              'Check if subject to standard GST billing rules',
              style: TextStyle(fontSize: 11),
            ),
            value: _gstApplicable,
            onChanged: (val) => setState(() => _gstApplicable = val ?? true),
            activeColor: AppColors.brandAmber,
            contentPadding: EdgeInsets.zero,
          ),
          CheckboxListTile(
            title: const Text(
              'e-Invoice Required',
              style: TextStyle(color: AppColors.darkTextPrimary, fontSize: 13),
            ),
            subtitle: const Text(
              'Auto-generate e-invoice payload via Government API',
              style: TextStyle(fontSize: 11),
            ),
            value: _eInvoiceRequired,
            onChanged: (val) =>
                setState(() => _eInvoiceRequired = val ?? false),
            activeColor: AppColors.brandAmber,
            contentPadding: EdgeInsets.zero,
          ),
          CheckboxListTile(
            title: const Text(
              'e-Way Bill Required',
              style: TextStyle(color: AppColors.darkTextPrimary, fontSize: 13),
            ),
            value: _eWayBillRequired,
            onChanged: (val) =>
                setState(() => _eWayBillRequired = val ?? false),
            activeColor: AppColors.brandAmber,
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildCreditAccountingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Payment Credit Terms',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.darkTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<PaymentTerms>(
                      initialValue: _selectedTerms,
                      dropdownColor: AppColors.darkSurface,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                      items: PaymentTerms.values.map((terms) {
                        return DropdownMenuItem(
                          value: terms,
                          child: Text(
                            terms.displayName,
                            style: const TextStyle(fontSize: 13),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedTerms = val;
                            // Set creditDays based on terms
                            _creditDaysController.text = switch (val) {
                              PaymentTerms.advance => '0',
                              PaymentTerms.days7 => '7',
                              PaymentTerms.days15 => '15',
                              PaymentTerms.days30 => '30',
                              PaymentTerms.days45 => '45',
                            };
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppTextField(
                  controller: _creditDaysController,
                  label: 'Credit Days Override',
                  hint: 'Days allowed',
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  controller: _creditLimitController,
                  label: 'Credit Limit (₹)',
                  hint: 'e.g. 500000',
                  prefixIcon: Icons.currency_rupee_outlined,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppTextField(
                  controller: _securityDepositController,
                  label: 'Security Deposit (₹)',
                  hint: 'e.g. 100000',
                  prefixIcon: Icons.lock_outline_rounded,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Accounting Details',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.darkTextPrimary,
            ),
          ),
          const Divider(color: AppColors.darkBorder),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  controller: _openingBalanceController,
                  label: 'Opening Ledger Balance (₹)',
                  hint: 'e.g. 0.00',
                  prefixIcon: Icons.account_balance_outlined,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  readOnly:
                      _isEditMode, // opening balance immutable after registration
                ),
              ),
              if (_isEditMode) ...[
                const SizedBox(width: 16),
                Expanded(
                  child: AppDisplayField(
                    label: 'Current Ledger Balance (₹)',
                    value: widget.customer!.currentBalance.toString(),
                    prefixIcon: Icons.wallet_outlined,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesPoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Fuel Type Preference',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.darkTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<FuelType>(
                      initialValue: _selectedFuel,
                      dropdownColor: AppColors.darkSurface,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                      items: FuelType.values.map((f) {
                        return DropdownMenuItem(
                          value: f,
                          child: Text(
                            f.displayName,
                            style: const TextStyle(fontSize: 13),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedFuel = val);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppTextField(
                  controller: _defaultGstRateController,
                  label: 'Default GST Rate (%)',
                  hint: 'e.g. 0.18 for 18%',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppTextField(
                  controller: _defaultPriceController,
                  label: 'Custom Selling Price (Optional)',
                  hint: 'Default flat rate/Ltr',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Active Purchase Order (PO) Details',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.darkTextPrimary,
            ),
          ),
          const Divider(color: AppColors.darkBorder),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  controller: _poNumberController,
                  label: 'PO Number',
                  hint: 'Enter active customer PO number',
                  prefixIcon: Icons.local_activity_outlined,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppTextField(
                  controller: _poValueController,
                  label: 'PO Value (₹)',
                  hint: 'e.g. 1000000',
                  prefixIcon: Icons.monetization_on_outlined,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _poDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2035),
                    );
                    if (date != null) setState(() => _poDate = date);
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'PO Issue Date',
                      prefixIcon: Icon(Icons.calendar_month_outlined),
                    ),
                    child: Text(
                      _poDate == null
                          ? 'Select Date'
                          : AppDateUtils.toDisplay(_poDate!),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate:
                          _poValidTill ??
                          DateTime.now().add(const Duration(days: 365)),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2035),
                    );
                    if (date != null) setState(() => _poValidTill = date);
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'PO Valid Till',
                      prefixIcon: Icon(Icons.calendar_today_outlined),
                    ),
                    child: Text(
                      _poValidTill == null
                          ? 'Select Expiry Date'
                          : AppDateUtils.toDisplay(_poValidTill!),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalNotesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  controller: _invoicePrefixController,
                  label: 'Invoice Prefix Override',
                  hint: 'e.g. TATA',
                ),
              ),
              const SizedBox(width: 16),
              const Text('Active Profile:'),
              Switch(
                value: _isActive,
                onChanged: (val) => setState(() => _isActive = val),
                activeThumbColor: AppColors.brandAmber,
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Communication & Print Settings',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.darkTextPrimary,
            ),
          ),
          const Divider(color: AppColors.darkBorder),
          Row(
            children: [
              Expanded(
                child: CheckboxListTile(
                  title: const Text(
                    'Email Invoice',
                    style: TextStyle(fontSize: 13),
                  ),
                  value: _emailInvoice,
                  onChanged: (val) =>
                      setState(() => _emailInvoice = val ?? true),
                  activeColor: AppColors.brandAmber,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              Expanded(
                child: CheckboxListTile(
                  title: const Text(
                    'WhatsApp Invoice',
                    style: TextStyle(fontSize: 13),
                  ),
                  value: _whatsappInvoice,
                  onChanged: (val) =>
                      setState(() => _whatsappInvoice = val ?? false),
                  activeColor: AppColors.brandAmber,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: CheckboxListTile(
                  title: const Text(
                    'Require PO for Invoices',
                    style: TextStyle(fontSize: 13),
                  ),
                  value: _requirePo,
                  onChanged: (val) => setState(() => _requirePo = val ?? false),
                  activeColor: AppColors.brandAmber,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              Expanded(
                child: CheckboxListTile(
                  title: const Text(
                    'Require Delivery Challan (DC)',
                    style: TextStyle(fontSize: 13),
                  ),
                  value: _requireDc,
                  onChanged: (val) => setState(() => _requireDc = val ?? false),
                  activeColor: AppColors.brandAmber,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
          CheckboxListTile(
            title: const Text(
              'Require Physical Signature',
              style: TextStyle(fontSize: 13),
            ),
            value: _requireSignature,
            onChanged: (val) =>
                setState(() => _requireSignature = val ?? false),
            activeColor: AppColors.brandAmber,
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: _notesController,
            label: 'General Remarks / Notes',
            hint: 'Security gate directives, specific dispatch instructions...',
            prefixIcon: Icons.note_alt_outlined,
            maxLines: 4,
          ),
        ],
      ),
    );
  }
}

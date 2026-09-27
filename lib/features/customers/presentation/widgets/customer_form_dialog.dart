import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:step_up_fuels/app/di/injection_container.dart';
import 'package:step_up_fuels/core/theme/app_colors.dart';
import 'package:step_up_fuels/core/theme/mobile_tokens.dart';
import 'package:step_up_fuels/core/utils/date_utils.dart';
import 'package:step_up_fuels/features/customers/domain/entities/customer.dart';
import 'package:step_up_fuels/features/customers/domain/entities/customer_contact.dart';
import 'package:step_up_fuels/features/customers/domain/entities/customer_type.dart';
import 'package:step_up_fuels/features/customers/domain/entities/fuel_type.dart';
import 'package:step_up_fuels/features/customers/domain/entities/payment_terms.dart';
import 'package:step_up_fuels/features/customers/domain/repositories/customer_repository.dart';
import 'package:step_up_fuels/features/customers/domain/validators/customer_validator.dart';
import 'package:step_up_fuels/features/customers/presentation/providers/customers_provider.dart';
import 'package:step_up_fuels/shared/widgets/buttons/primary_button.dart';
import 'package:step_up_fuels/shared/widgets/inputs/administrative_location_input.dart';
import 'package:step_up_fuels/shared/widgets/inputs/app_text_field.dart';
import 'package:uuid/uuid.dart';

/// Dialog to create or edit customer details.
///
/// Supports distinct workflows for:
/// - **Individual** (retail consumer / vehicle owner / contractor)
/// - **Corporate / Company** (B2B / enterprise client)
/// - **Government** (institutional)
///
/// All fields are completely optional (nothing is strictly mandatory).
class CustomerFormDialog extends ConsumerStatefulWidget {
  const CustomerFormDialog({
    super.key,
    this.customer,
    this.initialName,
    this.initialPhone,
    this.initialType,
  });

  /// The customer to edit (null for creation mode).
  final Customer? customer;

  /// Pre-filled customer name for fast creation from billing.
  final String? initialName;

  /// Pre-filled phone number for fast creation from billing.
  final String? initialPhone;

  /// Pre-filled customer category.
  final CustomerType? initialType;

  @override
  ConsumerState<CustomerFormDialog> createState() => _CustomerFormDialogState();
}

class _CustomerFormDialogState extends ConsumerState<CustomerFormDialog>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TabController _tabController;

  // Customer Category
  CustomerType _selectedType = CustomerType.company;
  bool get _isIndividual => _selectedType == CustomerType.individual;
  int get _tabCount => _isIndividual ? 3 : 5;

  // Controllers — Common / Identity
  final _nameController = TextEditingController();
  final _displayNameController = TextEditingController();

  // Controllers — Individual specific
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _panController = TextEditingController();
  final _aadhaarController = TextEditingController();
  final _vehicleNumberController = TextEditingController();

  // Controllers — Corporate / Compliance specific
  final _legalNameController = TextEditingController();
  final _tradeNameController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _gstinController = TextEditingController();
  final _gstRegTypeController = TextEditingController();
  final _tanController = TextEditingController();

  // Controllers — Address & Administrative Location
  final _billingAddress1Controller = TextEditingController();
  final _billingAddress2Controller = TextEditingController();
  final _billingStateController = TextEditingController();
  final _billingCityController =
      TextEditingController(); // Stores District / City
  final _billingAreaController =
      TextEditingController(); // Stores Taluka / Sub-district
  final _billingVillageController =
      TextEditingController(); // Stores Village / Town
  final _billingPincodeController = TextEditingController();
  final _billingCountryController = TextEditingController();

  // Controllers — Credit & Terms
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

  // Selected state variables
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

    if (_isEditMode) {
      final cust = widget.customer!;
      _selectedType = cust.type;
      _nameController.text = cust.name;
      _displayNameController.text = cust.displayName ?? cust.name;

      _billingAddress1Controller.text = cust.billingAddressLine1 ?? '';
      _billingAddress2Controller.text = cust.billingAddressLine2 ?? '';
      _billingStateController.text = cust.billingState ?? cust.state ?? '';
      _billingCityController.text = cust.billingCity ?? '';
      _billingAreaController.text = cust.billingArea ?? '';
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

      _loadExistingContacts(cust.id);
    } else {
      _billingCountryController.text = 'India';
      _creditLimitController.text = '0.0';
      _creditDaysController.text = '30';
      _securityDepositController.text = '0.0';
      _openingBalanceController.text = '0.0';
      _defaultGstRateController.text = '0.18';

      if (widget.initialType != null) {
        _selectedType = widget.initialType!;
      }
      if (widget.initialName != null && widget.initialName!.isNotEmpty) {
        _nameController.text = widget.initialName!;
        _displayNameController.text = widget.initialName!;
      }
      if (widget.initialPhone != null && widget.initialPhone!.isNotEmpty) {
        _phoneController.text = widget.initialPhone!;
      }
    }

    _initTabController();
  }

  void _initTabController({int initialIndex = 0}) {
    _tabController = TabController(
      length: _tabCount,
      vsync: this,
      initialIndex: initialIndex.clamp(0, _tabCount - 1),
    );
  }

  Future<void> _loadExistingContacts(String customerId) async {
    try {
      final repo = sl<CustomerRepository>();
      final result = await repo.getContactsForCustomer(customerId);
      result.when(
        success: (contacts) {
          if (contacts.isNotEmpty && mounted) {
            final primary = contacts.firstWhere(
              (c) => c.isPrimary,
              orElse: () => contacts.first,
            );
            setState(() {
              _contactPersonController.text = primary.name;
              _phoneController.text = primary.phone ?? '';
              _emailController.text = primary.email ?? '';
            });
          }
        },
        failure: (_) {},
      );
    } catch (_) {}
  }

  void _onCategoryChanged(CustomerType type) {
    if (_selectedType == type) return;
    final wasIndividual = _isIndividual;
    setState(() {
      _selectedType = type;
      if (type == CustomerType.individual) {
        _gstApplicable = false;
        _eInvoiceRequired = false;
        _eWayBillRequired = false;
        _requirePo = false;
        _requireDc = false;
      } else {
        _gstApplicable = true;
      }

      if (_isIndividual != wasIndividual) {
        _tabController.dispose();
        _initTabController(initialIndex: 0);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _displayNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _panController.dispose();
    _aadhaarController.dispose();
    _vehicleNumberController.dispose();
    _legalNameController.dispose();
    _tradeNameController.dispose();
    _contactPersonController.dispose();
    _billingAddress1Controller.dispose();
    _billingAddress2Controller.dispose();
    _billingStateController.dispose();
    _billingCityController.dispose();
    _billingAreaController.dispose();
    _billingVillageController.dispose();
    _billingPincodeController.dispose();
    _billingCountryController.dispose();
    _gstinController.dispose();
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
    // Form validate is non-blocking (nothing is mandatory)
    if (_formKey.currentState != null && !_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final notifier = ref.read(customersListProvider.notifier);

      // Safe numeric parsing with graceful defaults
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

      // Safe name fallback if left blank (since nothing is mandatory)
      final rawName = _nameController.text.trim();
      final name = rawName.isNotEmpty
          ? rawName
          : (_isIndividual ? 'Individual Customer' : 'Corporate Customer');

      final displayName = _displayNameController.text.trim().isNotEmpty
          ? _displayNameController.text.trim()
          : name;

      final customerId = _isEditMode ? widget.customer!.id : const Uuid().v4();

      // State and District resolution
      final stateValue = _billingStateController.text.trim().isNotEmpty
          ? _billingStateController.text.trim()
          : null;
      final districtValue = _billingCityController.text.trim().isNotEmpty
          ? _billingCityController.text.trim()
          : null;
      final talukaValue = _billingAreaController.text.trim().isNotEmpty
          ? _billingAreaController.text.trim()
          : null;

      // Compile notes with vehicle / ID if individual entered them
      final List<String> notesParts = [];
      if (_isIndividual && _vehicleNumberController.text.trim().isNotEmpty) {
        notesParts.add('Vehicle: ${_vehicleNumberController.text.trim()}');
      }
      if (_isIndividual && _aadhaarController.text.trim().isNotEmpty) {
        notesParts.add('ID/Aadhaar: ${_aadhaarController.text.trim()}');
      }
      if (_notesController.text.trim().isNotEmpty) {
        notesParts.add(_notesController.text.trim());
      }
      final finalNotes = notesParts.isNotEmpty ? notesParts.join('\n') : null;

      final customer = Customer(
        id: customerId,
        customerCode: _isEditMode ? widget.customer!.customerCode : '',
        name: name,
        displayName: displayName,
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
        state: stateValue,
        placeOfSupply: stateValue,
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
        billingArea: talukaValue,
        billingCity: districtValue,
        billingState: stateValue,
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
        notes: finalNotes,
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

      // Auto-save primary contact if phone or email was provided
      final phone = _phoneController.text.trim();
      final email = _emailController.text.trim();
      final contactPerson = _contactPersonController.text.trim();

      if (phone.isNotEmpty || email.isNotEmpty || contactPerson.isNotEmpty) {
        try {
          final contact = CustomerContact.newContact(
            id: const Uuid().v4(),
            customerId: customerId,
            name: contactPerson.isNotEmpty ? contactPerson : name,
            phone: phone.isNotEmpty ? phone : null,
            email: email.isNotEmpty ? email : null,
            whatsapp: _whatsappInvoice && phone.isNotEmpty ? phone : null,
            isPrimary: true,
          );
          await sl<CustomerRepository>().saveContact(contact);
        } catch (_) {
          // Contact saving is non-blocking
        }
      }

      if (mounted) {
        Navigator.of(context).pop(customer);
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
    final isMobile = MediaQuery.sizeOf(context).width < 650;

    final tabs = _isIndividual
        ? const [
            Tab(text: 'Personal & Contact'),
            Tab(text: 'Address & Location'),
            Tab(text: 'Fuel & Billing'),
          ]
        : const [
            Tab(text: 'Company Profile'),
            Tab(text: 'GST & Compliance'),
            Tab(text: 'Billing Address'),
            Tab(text: 'Credit & Terms'),
            Tab(text: 'PO & Preferences'),
          ];

    final tabViews = _isIndividual
        ? [
            _buildIndividualPersonalTab(),
            _buildAddressTab(),
            _buildIndividualBillingTab(),
          ]
        : [
            _buildCorporateProfileTab(),
            _buildGstComplianceTab(),
            _buildAddressTab(),
            _buildCreditAccountingTab(),
            _buildCorporatePreferencesTab(),
          ];

    if (isMobile) {
      return Scaffold(
        backgroundColor: AppColors.darkSurface,
        appBar: AppBar(
          backgroundColor: AppColors.darkSurface,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.close, color: AppColors.darkTextPrimary),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            _isEditMode
                ? 'Edit ${_selectedType.displayName}'
                : 'Register ${_selectedType.displayName}',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.darkTextPrimary,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(88),
            child: Column(
              children: [
                _buildCategorySelectorBar(),
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  indicatorColor: AppColors.brandAmber,
                  labelColor: AppColors.brandAmber,
                  unselectedLabelColor: AppColors.darkTextSecondary,
                  labelStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  tabs: tabs,
                ),
              ],
            ),
          ),
        ),
        body: Column(
          children: [
            if (_errorMessage != null) _buildErrorBanner(),
            Expanded(
              child: Form(
                key: _formKey,
                child: TabBarView(
                  controller: _tabController,
                  children: tabViews,
                ),
              ),
            ),
            _buildMobileFooter(),
          ],
        ),
      );
    }

    return Dialog(
      backgroundColor: AppColors.darkSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 750, maxHeight: 680),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isEditMode
                              ? 'Edit ${_selectedType.displayName} Customer'
                              : 'Register New ${_selectedType.displayName} Customer',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Fill in the customer details below. All fields are optional.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.darkTextTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildCategorySelectorBar(),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.close, color: AppColors.darkTextSecondary),
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
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              isScrollable: true,
              tabs: tabs,
            ),

            if (_errorMessage != null) _buildErrorBanner(),

            // Form inputs view
            Expanded(
              child: Form(
                key: _formKey,
                child: TabBarView(
                  controller: _tabController,
                  children: tabViews,
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

  Widget _buildCategorySelectorBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: CustomerType.values.map((type) {
          final isSelected = _selectedType == type;
          return InkWell(
            onTap: () => _onCategoryChanged(type),
            borderRadius: BorderRadius.circular(8),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.brandAmber.withValues(alpha: 0.25)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? AppColors.brandAmber : Colors.transparent,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    type == CustomerType.individual
                        ? Icons.person_outline
                        : (type == CustomerType.government
                              ? Icons.account_balance_outlined
                              : Icons.business_outlined),
                    size: 15,
                    color: isSelected
                        ? AppColors.brandAmber
                        : AppColors.darkTextSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    type.displayName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: isSelected
                          ? AppColors.brandAmber
                          : AppColors.darkTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Text(
        _errorMessage!,
        style: const TextStyle(color: AppColors.error, fontSize: 13),
      ),
    );
  }

  Widget _buildMobileFooter() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        MediaQuery.paddingOf(context).bottom + 12,
      ),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        border: Border(top: BorderSide(color: AppColors.darkBorder)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(
                  AppMobileTokens.preferredButtonHeight,
                ),
                side: BorderSide(color: AppColors.darkBorder),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppMobileTokens.radiusMD),
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: AppColors.darkTextSecondary),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: PrimaryButton(
              label: _isEditMode ? 'Save Changes' : 'Create Customer',
              isLoading: _isLoading,
              onPressed: _handleSubmit,
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // INDIVIDUAL SPECIFIC TABS
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildIndividualPersonalTab() {
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
                  label: 'Full Name',
                  hint: 'e.g. Ramesh Patil',
                  prefixIcon: Icons.person_outline,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppTextField(
                  controller: _displayNameController,
                  label: 'Nickname / Display Name',
                  hint: 'e.g. Ramesh',
                  prefixIcon: Icons.badge_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  controller: _phoneController,
                  label: 'Mobile Number',
                  hint: '10-digit mobile number',
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  validator: CustomerValidator.validatePhone,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppTextField(
                  controller: _emailController,
                  label: 'Email Address',
                  hint: 'e.g. ramesh@example.com',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: CustomerValidator.validateEmail,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  controller: _panController,
                  label: 'PAN Number (Optional)',
                  hint: 'e.g. ABCDE1234F',
                  prefixIcon: Icons.credit_card_outlined,
                  textCapitalization: TextCapitalization.characters,
                  validator: CustomerValidator.validatePan,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppTextField(
                  controller: _aadhaarController,
                  label: 'Aadhaar / ID Ref (Optional)',
                  hint: 'e.g. 12-digit Aadhaar / Voter ID',
                  prefixIcon: Icons.fingerprint_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.brandAmber.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.brandAmber.withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  size: 20,
                  color: AppColors.brandAmber,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Individual retail customers are treated as Unregistered Persons (URP) under GST. Business tax fields are omitted.',
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
      ),
    );
  }

  Widget _buildIndividualBillingTab() {
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
                    Text(
                      'Preferred Fuel Type',
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
                  controller: _vehicleNumberController,
                  label: 'Primary Vehicle / Equipment No',
                  hint: 'e.g. MH 12 AB 1234',
                  prefixIcon: Icons.directions_car_outlined,
                  textCapitalization: TextCapitalization.characters,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payment Arrangement',
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
                        if (val != null) setState(() => _selectedTerms = val);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppTextField(
                  controller: _creditLimitController,
                  label: 'Credit Limit (₹)',
                  hint: '0.00 for no credit',
                  prefixIcon: Icons.currency_rupee_outlined,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppTextField(
                  controller: _openingBalanceController,
                  label: 'Opening Balance (₹)',
                  hint: 'e.g. 0.00',
                  prefixIcon: Icons.account_balance_wallet_outlined,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  readOnly: _isEditMode,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Receipt & Notifications',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.darkTextPrimary,
            ),
          ),
          Divider(color: AppColors.darkBorder),
          Row(
            children: [
              Expanded(
                child: CheckboxListTile(
                  title: const Text(
                    'WhatsApp Invoice / Receipt',
                    style: TextStyle(fontSize: 13),
                  ),
                  subtitle: const Text(
                    'Send fuel receipts directly to mobile',
                    style: TextStyle(fontSize: 11),
                  ),
                  value: _whatsappInvoice,
                  onChanged: (val) =>
                      setState(() => _whatsappInvoice = val ?? false),
                  activeColor: AppColors.brandAmber,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              Expanded(
                child: CheckboxListTile(
                  title: const Text(
                    'Email Invoice',
                    style: TextStyle(fontSize: 13),
                  ),
                  subtitle: const Text(
                    'Send monthly statement via email',
                    style: TextStyle(fontSize: 11),
                  ),
                  value: _emailInvoice,
                  onChanged: (val) =>
                      setState(() => _emailInvoice = val ?? true),
                  activeColor: AppColors.brandAmber,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: _notesController,
            label: 'Remarks / Special Notes',
            hint: 'Customer preferences, farm/home delivery notes...',
            prefixIcon: Icons.note_alt_outlined,
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // COMMON ADDRESS TAB (State + District + Taluka Dropdown & TextFields)
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildAddressTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _isIndividual
                ? 'Residential / Delivery Address'
                : 'Billing Address',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.darkTextPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Select State, District, and Taluka from directory or type freely.',
            style: TextStyle(fontSize: 12, color: AppColors.darkTextTertiary),
          ),
          Divider(color: AppColors.darkBorder),
          const SizedBox(height: 12),
          AppTextField(
            controller: _billingAddress1Controller,
            label: 'Address Line 1',
            hint: 'Flat/Office/House No., Building, Street...',
            prefixIcon: Icons.location_on_outlined,
          ),
          const SizedBox(height: 16),
          AppTextField(
            controller: _billingAddress2Controller,
            label: 'Address Line 2',
            hint: 'Colony, Sector, Landmark, Road...',
            prefixIcon: Icons.map_outlined,
          ),
          const SizedBox(height: 16),

          // Coordinated Administrative Location: State -> District -> Taluka
          AdministrativeLocationGroup(
            stateController: _billingStateController,
            districtController: _billingCityController,
            talukaController: _billingAreaController,
            cityController: _billingVillageController,
            pincodeController: _billingPincodeController,
          ),

          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  controller: _billingCountryController,
                  label: 'Country',
                  hint: 'e.g. India',
                  prefixIcon: Icons.public_outlined,
                ),
              ),
              const SizedBox(width: 16),
              const Spacer(flex: 2),
            ],
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // CORPORATE / COMPANY SPECIFIC TABS
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildCorporateProfileTab() {
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
                  label: 'Company Legal Name',
                  hint: 'e.g. Tata Motors Ltd',
                  prefixIcon: Icons.business_outlined,
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
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  controller: _legalNameController,
                  label: 'Registered Business Name',
                  hint: 'As printed on GST registration certificate',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppTextField(
                  controller: _tradeNameController,
                  label: 'Trade / Brand Name',
                  hint: 'Trading division / operating name',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Primary Contact Person',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.darkTextPrimary,
            ),
          ),
          Divider(color: AppColors.darkBorder),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  controller: _contactPersonController,
                  label: 'Contact Person Name',
                  hint: 'e.g. Rajesh Kumar',
                  prefixIcon: Icons.person_outline,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppTextField(
                  controller: _phoneController,
                  label: 'Contact Phone',
                  hint: '10-digit mobile number',
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  validator: CustomerValidator.validatePhone,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppTextField(
                  controller: _emailController,
                  label: 'Contact Email',
                  hint: 'e.g. rajesh@tatamotors.com',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: CustomerValidator.validateEmail,
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
          Text(
            'Compliance Settings',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.darkTextPrimary,
            ),
          ),
          Divider(color: AppColors.darkBorder),
          CheckboxListTile(
            title: Text(
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
            title: Text(
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
            title: Text(
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
                    Text(
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
          Text(
            'Accounting Details',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.darkTextPrimary,
            ),
          ),
          Divider(color: AppColors.darkBorder),
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
                  readOnly: _isEditMode,
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

  Widget _buildCorporatePreferencesTab() {
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
                    Text(
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
                  label: 'Custom Selling Price',
                  hint: 'Default flat rate/Ltr',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Purchase Order (PO) Details',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.darkTextPrimary,
            ),
          ),
          Divider(color: AppColors.darkBorder),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  controller: _poNumberController,
                  label: 'PO Number',
                  hint: 'Enter customer PO number',
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
          const SizedBox(height: 20),
          Text(
            'Invoicing Rules & Notifications',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.darkTextPrimary,
            ),
          ),
          Divider(color: AppColors.darkBorder),
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
          const SizedBox(height: 12),
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
            maxLines: 3,
          ),
        ],
      ),
    );
  }
}

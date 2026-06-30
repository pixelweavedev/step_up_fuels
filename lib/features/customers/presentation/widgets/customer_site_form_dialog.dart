import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:step_up_fuels/core/theme/app_colors.dart';
import 'package:step_up_fuels/features/customers/domain/entities/customer_site.dart';
import 'package:step_up_fuels/features/customers/presentation/providers/customers_provider.dart';
import 'package:step_up_fuels/shared/widgets/buttons/primary_button.dart';
import 'package:step_up_fuels/shared/widgets/inputs/app_text_field.dart';
import 'package:uuid/uuid.dart';

/// Dialog to add or edit customer delivery sites with GPS and contact info.
class CustomerSiteFormDialog extends ConsumerStatefulWidget {
  const CustomerSiteFormDialog({
    super.key,
    required this.customerId,
    this.site,
  });

  final String customerId;
  final CustomerSite? site;

  @override
  ConsumerState<CustomerSiteFormDialog> createState() =>
      _CustomerSiteFormDialogState();
}

class _CustomerSiteFormDialogState
    extends ConsumerState<CustomerSiteFormDialog> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _addressLine1Controller = TextEditingController();
  final _addressLine2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _stateCodeController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _countryController = TextEditingController();

  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _contactNumberController = TextEditingController();

  bool _isDefault = false;
  bool _isActive = true;
  bool _isLoading = false;
  String? _errorMessage;

  bool get _isEditMode => widget.site != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      final s = widget.site!;
      _nameController.text = s.name;
      _addressLine1Controller.text = s.addressLine1 ?? '';
      _addressLine2Controller.text = s.addressLine2 ?? '';
      _cityController.text = s.city ?? '';
      _stateController.text = s.state ?? '';
      _stateCodeController.text = s.stateCode ?? '';
      _pincodeController.text = s.pincode ?? '';
      _countryController.text = s.country ?? 'India';
      _latitudeController.text = s.latitude?.toString() ?? '';
      _longitudeController.text = s.longitude?.toString() ?? '';
      _contactPersonController.text = s.contactPerson ?? '';
      _contactNumberController.text = s.contactNumber ?? '';
      _isDefault = s.isDefault;
      _isActive = s.isActive;
    } else {
      _countryController.text = 'India';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _stateCodeController.dispose();
    _pincodeController.dispose();
    _countryController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _contactPersonController.dispose();
    _contactNumberController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repo = ref.read(customerRepositoryProvider);

      final lat = double.tryParse(_latitudeController.text.trim());
      final lng = double.tryParse(_longitudeController.text.trim());

      final site = CustomerSite(
        id: _isEditMode ? widget.site!.id : const Uuid().v4(),
        customerId: widget.customerId,
        name: _nameController.text.trim(),
        addressLine1: _addressLine1Controller.text.trim().isEmpty
            ? null
            : _addressLine1Controller.text.trim(),
        addressLine2: _addressLine2Controller.text.trim().isEmpty
            ? null
            : _addressLine2Controller.text.trim(),
        city: _cityController.text.trim().isEmpty
            ? null
            : _cityController.text.trim(),
        state: _stateController.text.trim().isEmpty
            ? null
            : _stateController.text.trim(),
        stateCode: _stateCodeController.text.trim().isEmpty
            ? null
            : _stateCodeController.text.trim().toUpperCase(),
        pincode: _pincodeController.text.trim().isEmpty
            ? null
            : _pincodeController.text.trim(),
        country: _countryController.text.trim().isEmpty
            ? 'India'
            : _countryController.text.trim(),
        latitude: lat,
        longitude: lng,
        contactPerson: _contactPersonController.text.trim().isEmpty
            ? null
            : _contactPersonController.text.trim(),
        contactNumber: _contactNumberController.text.trim().isEmpty
            ? null
            : _contactNumberController.text.trim(),
        isDefault: _isDefault,
        isActive: _isActive,
        createdBy: _isEditMode ? widget.site!.createdBy : 'system',
        createdAt: _isEditMode ? widget.site!.createdAt : DateTime.now(),
        updatedBy: 'system',
        updatedAt: DateTime.now(),
        deletedAt: _isEditMode ? widget.site!.deletedAt : null,
        version: _isEditMode ? widget.site!.version : 1,
        tenantId: _isEditMode ? widget.site!.tenantId : null,
      );

      final result = await repo.saveSite(site);
      result.when(
        success: (_) {
          ref.invalidate(customerSitesProvider(widget.customerId));
          if (mounted) {
            Navigator.of(context).pop(true);
          }
        },
        failure: (f) {
          setState(() {
            _isLoading = false;
            _errorMessage = f.userMessage;
          });
        },
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.darkSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 550, maxHeight: 600),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _isEditMode ? 'Edit Delivery Site' : 'Add Delivery Site',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkTextPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: AppColors.darkTextSecondary,
                      size: 20,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(color: AppColors.darkBorder),

            // Error display
            if (_errorMessage != null)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                padding: const EdgeInsets.all(10),
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

            // Form Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      AppTextField(
                        controller: _nameController,
                        label: 'Site / Location Name *',
                        hint: 'e.g. Pune Plant, Metro Site 1',
                        prefixIcon: Icons.place_outlined,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Site name is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        controller: _addressLine1Controller,
                        label: 'Address Line 1',
                        hint: 'Plot number, survey location...',
                        prefixIcon: Icons.location_on_outlined,
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        controller: _addressLine2Controller,
                        label: 'Address Line 2',
                        hint: 'Area details...',
                        prefixIcon: Icons.map_outlined,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              controller: _cityController,
                              label: 'City',
                              hint: 'e.g. Pune',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppTextField(
                              controller: _stateController,
                              label: 'State',
                              hint: 'e.g. Maharashtra',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              controller: _stateCodeController,
                              label: 'GST State Code (2 digits)',
                              hint: 'e.g. 27',
                              keyboardType: TextInputType.number,
                              maxLength: 2,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppTextField(
                              controller: _pincodeController,
                              label: 'PIN Code',
                              hint: '6-digit code',
                              keyboardType: TextInputType.number,
                              maxLength: 6,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppTextField(
                              controller: _countryController,
                              label: 'Country',
                              hint: 'e.g. India',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'GPS Coordinates & Site Contact',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkTextSecondary,
                        ),
                      ),
                      const Divider(color: AppColors.darkBorder),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              controller: _latitudeController,
                              label: 'Latitude',
                              hint: 'e.g. 18.5204',
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppTextField(
                              controller: _longitudeController,
                              label: 'Longitude',
                              hint: 'e.g. 73.8567',
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              controller: _contactPersonController,
                              label: 'Site Contact Person',
                              hint: 'Name of supervisor/receiver',
                              prefixIcon: Icons.person_outline_rounded,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppTextField(
                              controller: _contactNumberController,
                              label: 'Contact Number',
                              hint: '10-digit phone',
                              prefixIcon: Icons.phone_android_outlined,
                              keyboardType: TextInputType.phone,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Text(
                            'Set as Default Site Location',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.darkTextPrimary,
                            ),
                          ),
                          const Spacer(),
                          Switch(
                            value: _isDefault,
                            onChanged: (val) =>
                                setState(() => _isDefault = val),
                            activeThumbColor: AppColors.brandAmber,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Footer
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
                    label: _isEditMode ? 'Save' : 'Add Site',
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
}

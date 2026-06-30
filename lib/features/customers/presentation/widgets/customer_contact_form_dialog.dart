import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:step_up_fuels/core/theme/app_colors.dart';
import 'package:step_up_fuels/features/customers/domain/entities/customer_contact.dart';
import 'package:step_up_fuels/features/customers/domain/validators/customer_validator.dart';
import 'package:step_up_fuels/features/customers/presentation/providers/customers_provider.dart';
import 'package:step_up_fuels/shared/widgets/buttons/primary_button.dart';
import 'package:step_up_fuels/shared/widgets/inputs/app_text_field.dart';
import 'package:uuid/uuid.dart';

/// Dialog to add or edit customer contact persons.
class CustomerContactFormDialog extends ConsumerStatefulWidget {
  const CustomerContactFormDialog({
    super.key,
    required this.customerId,
    this.contact,
  });

  final String customerId;
  final CustomerContact? contact;

  @override
  ConsumerState<CustomerContactFormDialog> createState() =>
      _CustomerContactFormDialogState();
}

class _CustomerContactFormDialogState
    extends ConsumerState<CustomerContactFormDialog> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _designationController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _whatsappController = TextEditingController();

  bool _isPrimary = false;
  bool _isActive = true;
  bool _isLoading = false;
  String? _errorMessage;

  bool get _isEditMode => widget.contact != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      final c = widget.contact!;
      _nameController.text = c.name;
      _designationController.text = c.designation ?? '';
      _phoneController.text = c.phone ?? '';
      _emailController.text = c.email ?? '';
      _whatsappController.text = c.whatsapp ?? '';
      _isPrimary = c.isPrimary;
      _isActive = c.isActive;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _designationController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _whatsappController.dispose();
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

      final contact = CustomerContact(
        id: _isEditMode ? widget.contact!.id : const Uuid().v4(),
        customerId: widget.customerId,
        name: _nameController.text.trim(),
        designation: _designationController.text.trim().isEmpty
            ? null
            : _designationController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        whatsapp: _whatsappController.text.trim().isEmpty
            ? null
            : _whatsappController.text.trim(),
        isPrimary: _isPrimary,
        isActive: _isActive,
        createdBy: _isEditMode ? widget.contact!.createdBy : 'system',
        createdAt: _isEditMode ? widget.contact!.createdAt : DateTime.now(),
        updatedBy: 'system',
        updatedAt: DateTime.now(),
        deletedAt: _isEditMode ? widget.contact!.deletedAt : null,
        version: _isEditMode ? widget.contact!.version : 1,
        tenantId: _isEditMode ? widget.contact!.tenantId : null,
      );

      final result = await repo.saveContact(contact);
      result.when(
        success: (_) {
          ref.invalidate(customerContactsProvider(widget.customerId));
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
        constraints: const BoxConstraints(maxWidth: 450, maxHeight: 520),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _isEditMode ? 'Edit Contact Person' : 'Add Contact Person',
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

            // Form inputs
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
                        label: 'Contact Name *',
                        hint: 'e.g. Ramesh Kumar',
                        prefixIcon: Icons.person_outline_rounded,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Name is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        controller: _designationController,
                        label: 'Designation',
                        hint: 'e.g. Purchase Manager, Driver',
                        prefixIcon: Icons.badge_outlined,
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        controller: _phoneController,
                        label: 'Mobile Number',
                        hint: '10-digit number',
                        prefixIcon: Icons.phone_android_outlined,
                        keyboardType: TextInputType.phone,
                        validator: CustomerValidator.validatePhone,
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        controller: _emailController,
                        label: 'Email Address',
                        hint: 'name@company.com',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: CustomerValidator.validateEmail,
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        controller: _whatsappController,
                        label: 'WhatsApp Number',
                        hint: 'For automated invoice dispatch',
                        prefixIcon: Icons.chat_outlined,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Text(
                            'Mark as Primary Contact',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.darkTextPrimary,
                            ),
                          ),
                          const Spacer(),
                          Switch(
                            value: _isPrimary,
                            onChanged: (val) =>
                                setState(() => _isPrimary = val),
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
                    label: _isEditMode ? 'Save' : 'Add Contact',
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

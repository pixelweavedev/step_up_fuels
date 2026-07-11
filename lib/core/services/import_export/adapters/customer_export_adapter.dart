import 'package:intl/intl.dart';
import 'package:step_up_fuels/app/di/injection_container.dart';
import 'package:step_up_fuels/core/services/import_export/models/export_adapter.dart';
import 'package:step_up_fuels/core/services/import_export/models/export_column.dart';
import 'package:step_up_fuels/core/services/import_export/models/export_filter.dart';
import 'package:step_up_fuels/core/services/import_export/models/import_result.dart';
import 'package:step_up_fuels/features/customers/application/usecases/get_customers_usecase.dart';
import 'package:step_up_fuels/features/customers/domain/entities/customer.dart';

class CustomerExportAdapter extends ExportAdapter<Customer> {
  @override
  String get entityName => 'customers';

  @override
  String get entityLabel => 'Customers';

  @override
  String get entityEmoji => '👥';

  @override
  String get gradientStart => '#2563EB';

  @override
  String get gradientEnd => '#1E40AF';

  @override
  bool get supportsImport => true;

  @override
  bool get supportsReport => true;

  // ── Data Columns ────────────────────────────────────────────────────────────

  @override
  List<ExportColumn<Customer>> get dataColumns => [
    ExportColumn<Customer>(
      key: 'customer_code',
      label: 'Customer Code',
      group: 'Identity',
      getValue: (c) => c.customerCode,
      importable: true,
      required: true,
      importAliases: ['code', 'cust code', 'account code'],
    ),
    ExportColumn<Customer>(
      key: 'name',
      label: 'Name',
      group: 'Identity',
      getValue: (c) => c.name,
      importable: true,
      required: true,
      importAliases: ['customer name', 'account name', 'client name', 'full name'],
    ),
    ExportColumn<Customer>(
      key: 'display_name',
      label: 'Display Name',
      group: 'Identity',
      getValue: (c) => c.displayName ?? '',
      defaultVisible: false,
      importable: true,
    ),
    ExportColumn<Customer>(
      key: 'trade_name',
      label: 'Trade Name',
      group: 'Identity',
      getValue: (c) => c.tradeName ?? '',
      defaultVisible: false,
      importable: true,
      importAliases: ['business name', 'shop name'],
    ),
    ExportColumn<Customer>(
      key: 'type',
      label: 'Type',
      group: 'Identity',
      getValue: (c) => c.type.name.toUpperCase(),
      importable: true,
      importAliases: ['customer type'],
    ),
    ExportColumn<Customer>(
      key: 'is_active',
      label: 'Active',
      group: 'Identity',
      getValue: (c) => c.isActive ? 'Yes' : 'No',
      getRawValue: (c) => c.isActive,
      type: ColumnType.boolean,
      importable: true,
    ),
    ExportColumn<Customer>(
      key: 'gstin',
      label: 'GSTIN',
      group: 'GST & Compliance',
      getValue: (c) => c.gstin ?? '',
      importable: true,
      importAliases: ['gst number', 'gst no', 'gstin number'],
    ),
    ExportColumn<Customer>(
      key: 'pan',
      label: 'PAN',
      group: 'GST & Compliance',
      getValue: (c) => c.pan ?? '',
      defaultVisible: false,
      importable: true,
      importAliases: ['pan number', 'pan no'],
    ),
    ExportColumn<Customer>(
      key: 'gst_registration_type',
      label: 'GST Reg. Type',
      group: 'GST & Compliance',
      getValue: (c) => c.gstRegistrationType ?? '',
      defaultVisible: false,
      importable: true,
    ),
    ExportColumn<Customer>(
      key: 'state',
      label: 'State',
      group: 'GST & Compliance',
      getValue: (c) => c.state ?? '',
      defaultVisible: false,
      importable: true,
    ),
    ExportColumn<Customer>(
      key: 'billing_address',
      label: 'Billing Address',
      group: 'Address',
      getValue: (c) {
        final parts = [
          c.billingAddressLine1,
          c.billingAddressLine2,
          c.billingArea,
          c.billingCity,
          c.billingState,
          c.billingPincode,
        ].where((p) => p != null && p.isNotEmpty).toList();
        return parts.join(', ');
      },
    ),
    ExportColumn<Customer>(
      key: 'billing_city',
      label: 'City',
      group: 'Address',
      getValue: (c) => c.billingCity ?? '',
      defaultVisible: false,
      importable: true,
      importAliases: ['city'],
    ),
    ExportColumn<Customer>(
      key: 'billing_state',
      label: 'Billing State',
      group: 'Address',
      getValue: (c) => c.billingState ?? '',
      defaultVisible: false,
      importable: true,
    ),
    ExportColumn<Customer>(
      key: 'billing_pincode',
      label: 'Pincode',
      group: 'Address',
      getValue: (c) => c.billingPincode ?? '',
      defaultVisible: false,
      importable: true,
      importAliases: ['pin code', 'zip code', 'postal code'],
    ),
    ExportColumn<Customer>(
      key: 'credit_limit',
      label: 'Credit Limit',
      group: 'Credit',
      getValue: (c) => c.creditLimit.toStringAsFixed(2),
      getRawValue: (c) => c.creditLimit,
      type: ColumnType.currency,
      importable: true,
      importAliases: ['credit', 'limit'],
    ),
    ExportColumn<Customer>(
      key: 'credit_days',
      label: 'Credit Days',
      group: 'Credit',
      getValue: (c) => c.creditDays.toString(),
      getRawValue: (c) => c.creditDays,
      type: ColumnType.number,
      defaultVisible: false,
      importable: true,
    ),
    ExportColumn<Customer>(
      key: 'payment_terms',
      label: 'Payment Terms',
      group: 'Credit',
      getValue: (c) => c.paymentTerms?.name ?? '',
      defaultVisible: false,
      importable: true,
    ),
    ExportColumn<Customer>(
      key: 'current_balance',
      label: 'Outstanding',
      group: 'Accounting',
      getValue: (c) => c.currentBalance.toStringAsFixed(2),
      getRawValue: (c) => c.currentBalance,
      type: ColumnType.currency,
    ),
    ExportColumn<Customer>(
      key: 'opening_balance',
      label: 'Opening Balance',
      group: 'Accounting',
      getValue: (c) => c.openingBalance.toStringAsFixed(2),
      getRawValue: (c) => c.openingBalance,
      type: ColumnType.currency,
      defaultVisible: false,
      importable: true,
    ),
    ExportColumn<Customer>(
      key: 'last_payment_date',
      label: 'Last Payment',
      group: 'Accounting',
      getValue: (c) => c.lastPaymentDate != null
          ? DateFormat('dd/MM/yyyy').format(c.lastPaymentDate!)
          : '',
      getRawValue: (c) => c.lastPaymentDate,
      type: ColumnType.date,
      defaultVisible: false,
    ),
    ExportColumn<Customer>(
      key: 'fuel_type',
      label: 'Fuel Type',
      group: 'Preferences',
      getValue: (c) => c.fuelType?.name ?? '',
      defaultVisible: false,
      importable: true,
    ),
    ExportColumn<Customer>(
      key: 'gst_applicable',
      label: 'GST Applicable',
      group: 'Preferences',
      getValue: (c) => c.gstApplicable ? 'Yes' : 'No',
      getRawValue: (c) => c.gstApplicable,
      type: ColumnType.boolean,
      defaultVisible: false,
      importable: true,
    ),
    ExportColumn<Customer>(
      key: 'notes',
      label: 'Notes',
      group: 'Other',
      getValue: (c) => c.notes ?? '',
      defaultVisible: false,
      importable: true,
    ),
    ExportColumn<Customer>(
      key: 'created_at',
      label: 'Created At',
      group: 'Audit',
      getValue: (c) => DateFormat('dd/MM/yyyy').format(c.createdAt),
      getRawValue: (c) => c.createdAt,
      type: ColumnType.date,
      defaultVisible: false,
    ),
  ];

  // ── Report Columns ─────────────────────────────────────────────────────────

  @override
  List<ExportColumn<Customer>> get reportColumns => [
    ExportColumn<Customer>(
      key: 'customer_code',
      label: 'Customer Code',
      getValue: (c) => c.customerCode,
    ),
    ExportColumn<Customer>(
      key: 'name',
      label: 'Customer',
      getValue: (c) => c.name,
    ),
    ExportColumn<Customer>(
      key: 'type',
      label: 'Type',
      getValue: (c) => c.type.name.toUpperCase(),
    ),
    ExportColumn<Customer>(
      key: 'current_balance',
      label: 'Outstanding (₹)',
      getValue: (c) => c.currentBalance.toStringAsFixed(2),
      getRawValue: (c) => c.currentBalance,
      type: ColumnType.currency,
    ),
    ExportColumn<Customer>(
      key: 'credit_limit',
      label: 'Credit Limit (₹)',
      getValue: (c) => c.creditLimit.toStringAsFixed(2),
      getRawValue: (c) => c.creditLimit,
      type: ColumnType.currency,
    ),
    ExportColumn<Customer>(
      key: 'gstin',
      label: 'GSTIN',
      getValue: (c) => c.gstin ?? '',
    ),
    ExportColumn<Customer>(
      key: 'last_payment_date',
      label: 'Last Payment',
      getValue: (c) => c.lastPaymentDate != null
          ? DateFormat('dd/MM/yyyy').format(c.lastPaymentDate!)
          : '',
      getRawValue: (c) => c.lastPaymentDate,
      type: ColumnType.date,
    ),
    ExportColumn<Customer>(
      key: 'is_active',
      label: 'Status',
      getValue: (c) => c.isActive ? 'Active' : 'Inactive',
    ),
  ];

  // ── Fetch Data ──────────────────────────────────────────────────────────────

  @override
  Future<List<Customer>> fetchData(ExportFilter filter) async {
    final useCase = sl<GetCustomersUseCase>();
    final result = await useCase(includeDeleted: !filter.activeOnly);
    return result.when(
      success: (list) {
        var filtered = list;
        if (filter.activeOnly) {
          filtered = filtered.where((c) => c.isActive).toList();
        }
        if (filter.outstandingOnly) {
          filtered = filtered.where((c) => c.currentBalance > 0).toList();
        }
        return filtered;
      },
      failure: (f) => throw Exception(f.userMessage),
    );
  }

  // ── Serialization ───────────────────────────────────────────────────────────

  @override
  Map<String, dynamic> toJson(Customer c) => {
    'id': c.id,
    'customer_code': c.customerCode,
    'name': c.name,
    'display_name': c.displayName,
    'trade_name': c.tradeName,
    'legal_business_name': c.legalBusinessName,
    'type': c.type.name,
    'is_active': c.isActive,
    'gstin': c.gstin,
    'pan': c.pan,
    'state': c.state,
    'place_of_supply': c.placeOfSupply,
    'gst_registration_type': c.gstRegistrationType,
    'billing_address_line1': c.billingAddressLine1,
    'billing_address_line2': c.billingAddressLine2,
    'billing_area': c.billingArea,
    'billing_city': c.billingCity,
    'billing_state': c.billingState,
    'billing_pincode': c.billingPincode,
    'billing_country': c.billingCountry,
    'payment_terms': c.paymentTerms?.name,
    'credit_limit': c.creditLimit,
    'credit_days': c.creditDays,
    'security_deposit': c.securityDeposit,
    'fuel_type': c.fuelType?.name,
    'default_gst_rate': c.defaultGstRate,
    'default_price': c.defaultPrice,
    'opening_balance': c.openingBalance,
    'current_balance': c.currentBalance,
    'gst_applicable': c.gstApplicable,
    'e_invoice_required': c.eInvoiceRequired,
    'e_way_bill_required': c.eWayBillRequired,
    'email_invoice': c.emailInvoice,
    'whatsapp_invoice': c.whatsappInvoice,
    'notes': c.notes,
    'created_at': c.createdAt.toIso8601String(),
    'updated_at': c.updatedAt.toIso8601String(),
  };

  @override
  Customer? fromJson(Map<String, dynamic> json) => null; // Handled by import service

  // ── Validation ──────────────────────────────────────────────────────────────

  @override
  List<ValidationError> validateRow(Map<String, dynamic> json) {
    final errors = <ValidationError>[];

    if ((json['customer_code'] as String?)?.isEmpty ?? true) {
      errors.add(const ValidationError(field: 'customer_code', message: 'Customer Code is required'));
    }
    if ((json['name'] as String?)?.isEmpty ?? true) {
      errors.add(const ValidationError(field: 'name', message: 'Name is required'));
    }

    final gstRate = double.tryParse(json['default_gst_rate']?.toString() ?? '');
    if (json['default_gst_rate'] != null && gstRate == null) {
      errors.add(const ValidationError(field: 'default_gst_rate', message: 'GST rate must be a number'));
    }

    final gstin = json['gstin'] as String?;
    if (gstin != null && gstin.isNotEmpty && gstin.length != 15) {
      errors.add(const ValidationError(
        field: 'gstin',
        message: 'GSTIN must be exactly 15 characters',
        severity: ValidationSeverity.warning,
        suggestion: 'Verify GSTIN format: 2-digit state code + 10-digit PAN + 1 + Z + check digit',
      ));
    }

    return errors;
  }
}

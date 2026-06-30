import 'package:equatable/equatable.dart';
import 'package:step_up_fuels/features/customers/domain/entities/customer_type.dart';
import 'package:step_up_fuels/features/customers/domain/entities/fuel_type.dart';
import 'package:step_up_fuels/features/customers/domain/entities/payment_terms.dart';

/// Represents a customer in the system.
class Customer extends Equatable {
  const Customer({
    required this.id,
    required this.customerCode,
    required this.name,
    this.displayName,
    this.tradeName,
    this.legalBusinessName,
    required this.type,
    required this.isActive,
    this.gstin,
    this.pan,
    this.state,
    this.placeOfSupply,
    this.gstRegistrationType,
    this.tan,
    this.billingAddressLine1,
    this.billingAddressLine2,
    this.billingArea,
    this.billingCity,
    this.billingState,
    this.billingPincode,
    this.billingCountry,
    this.paymentTerms,
    required this.creditLimit,
    required this.creditDays,
    required this.securityDeposit,
    this.fuelType,
    required this.defaultGstRate,
    this.defaultPrice,
    this.poNumber,
    this.poDate,
    this.poValidTill,
    this.poValue,
    this.poRemainingBalance,
    this.invoicePrefix,
    required this.emailInvoice,
    required this.whatsappInvoice,
    required this.requirePo,
    required this.requireDc,
    required this.requireSignature,
    required this.gstApplicable,
    required this.eInvoiceRequired,
    required this.eWayBillRequired,
    required this.openingBalance,
    required this.currentBalance,
    this.lastPaymentDate,
    this.lastInvoiceDate,
    this.notes,
    required this.createdBy,
    required this.createdAt,
    required this.updatedBy,
    required this.updatedAt,
    this.deletedAt,
    required this.version,
    this.tenantId,
  });

  /// Factory constructor for creating a new Customer with defaults.
  factory Customer.newCustomer({
    required String id,
    required String customerCode,
    required String name,
    String? displayName,
    String? tradeName,
    String? legalBusinessName,
    required CustomerType type,
    String? gstin,
    String? pan,
    String? state,
    String? placeOfSupply,
    String? gstRegistrationType,
    String? tan,
    String? billingAddressLine1,
    String? billingAddressLine2,
    String? billingArea,
    String? billingCity,
    String? billingState,
    String? billingPincode,
    String? billingCountry,
    PaymentTerms? paymentTerms,
    double creditLimit = 0.0,
    int creditDays = 30,
    double securityDeposit = 0.0,
    FuelType? fuelType,
    double defaultGstRate = 0.18,
    double? defaultPrice,
    String? poNumber,
    DateTime? poDate,
    DateTime? poValidTill,
    double? poValue,
    String? invoicePrefix,
    bool emailInvoice = true,
    bool whatsappInvoice = false,
    bool requirePo = false,
    bool requireDc = false,
    bool requireSignature = false,
    bool gstApplicable = true,
    bool eInvoiceRequired = false,
    bool eWayBillRequired = false,
    double openingBalance = 0.0,
    String? notes,
  }) {
    final now = DateTime.now();
    return Customer(
      id: id,
      customerCode: customerCode,
      name: name,
      displayName: displayName ?? name,
      tradeName: tradeName,
      legalBusinessName: legalBusinessName,
      type: type,
      isActive: true,
      gstin: gstin,
      pan: pan,
      state: state,
      placeOfSupply: placeOfSupply,
      gstRegistrationType: gstRegistrationType,
      tan: tan,
      billingAddressLine1: billingAddressLine1,
      billingAddressLine2: billingAddressLine2,
      billingArea: billingArea,
      billingCity: billingCity,
      billingState: billingState,
      billingPincode: billingPincode,
      billingCountry: billingCountry,
      paymentTerms: paymentTerms,
      creditLimit: creditLimit,
      creditDays: creditDays,
      securityDeposit: securityDeposit,
      fuelType: fuelType,
      defaultGstRate: defaultGstRate,
      defaultPrice: defaultPrice,
      poNumber: poNumber,
      poDate: poDate,
      poValidTill: poValidTill,
      poValue: poValue,
      poRemainingBalance: poValue,
      invoicePrefix: invoicePrefix,
      emailInvoice: emailInvoice,
      whatsappInvoice: whatsappInvoice,
      requirePo: requirePo,
      requireDc: requireDc,
      requireSignature: requireSignature,
      gstApplicable: gstApplicable,
      eInvoiceRequired: eInvoiceRequired,
      eWayBillRequired: eWayBillRequired,
      openingBalance: openingBalance,
      currentBalance: openingBalance,
      notes: notes,
      createdBy: 'system',
      createdAt: now,
      updatedBy: 'system',
      updatedAt: now,
      version: 1,
    );
  }
  final String id;
  final String customerCode;
  final String name;
  final String? displayName;
  final String? tradeName;
  final String? legalBusinessName;
  final CustomerType type;
  final bool isActive;

  // GST & Compliance
  final String? gstin;
  final String? pan;
  final String? state;
  final String? placeOfSupply;
  final String? gstRegistrationType;
  final String? tan;

  // Billing Address
  final String? billingAddressLine1;
  final String? billingAddressLine2;
  final String? billingArea;
  final String? billingCity;
  final String? billingState;
  final String? billingPincode;
  final String? billingCountry;

  // Credit Info
  final PaymentTerms? paymentTerms;
  final double creditLimit;
  final int creditDays;
  final double securityDeposit;

  // Fuel Preferences
  final FuelType? fuelType;
  final double defaultGstRate;
  final double? defaultPrice;

  // PO Details
  final String? poNumber;
  final DateTime? poDate;
  final DateTime? poValidTill;
  final double? poValue;
  final double? poRemainingBalance;

  // Invoice Preferences
  final String? invoicePrefix;
  final bool emailInvoice;
  final bool whatsappInvoice;
  final bool requirePo;
  final bool requireDc;
  final bool requireSignature;

  // Compliance Flags
  final bool gstApplicable;
  final bool eInvoiceRequired;
  final bool eWayBillRequired;

  // Accounting
  final double openingBalance;
  final double currentBalance;
  final DateTime? lastPaymentDate;
  final DateTime? lastInvoiceDate;

  // Notes
  final String? notes;

  // Enterprise Audits
  final String createdBy;
  final DateTime createdAt;
  final String updatedBy;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int version;
  final String? tenantId;

  Customer copyWith({
    String? customerCode,
    String? name,
    String? displayName,
    String? tradeName,
    String? legalBusinessName,
    CustomerType? type,
    bool? isActive,
    String? gstin,
    String? pan,
    String? state,
    String? placeOfSupply,
    String? gstRegistrationType,
    String? tan,
    String? billingAddressLine1,
    String? billingAddressLine2,
    String? billingArea,
    String? billingCity,
    String? billingState,
    String? billingPincode,
    String? billingCountry,
    PaymentTerms? paymentTerms,
    double? creditLimit,
    int? creditDays,
    double? securityDeposit,
    FuelType? fuelType,
    double? defaultGstRate,
    double? defaultPrice,
    String? poNumber,
    DateTime? poDate,
    DateTime? poValidTill,
    double? poValue,
    double? poRemainingBalance,
    String? invoicePrefix,
    bool? emailInvoice,
    bool? whatsappInvoice,
    bool? requirePo,
    bool? requireDc,
    bool? requireSignature,
    bool? gstApplicable,
    bool? eInvoiceRequired,
    bool? eWayBillRequired,
    double? openingBalance,
    double? currentBalance,
    DateTime? lastPaymentDate,
    DateTime? lastInvoiceDate,
    String? notes,
    String? updatedBy,
    DateTime? deletedAt,
    int? version,
    String? tenantId,
  }) {
    return Customer(
      id: id,
      customerCode: customerCode ?? this.customerCode,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      tradeName: tradeName ?? this.tradeName,
      legalBusinessName: legalBusinessName ?? this.legalBusinessName,
      type: type ?? this.type,
      isActive: isActive ?? this.isActive,
      gstin: gstin ?? this.gstin,
      pan: pan ?? this.pan,
      state: state ?? this.state,
      placeOfSupply: placeOfSupply ?? this.placeOfSupply,
      gstRegistrationType: gstRegistrationType ?? this.gstRegistrationType,
      tan: tan ?? this.tan,
      billingAddressLine1: billingAddressLine1 ?? this.billingAddressLine1,
      billingAddressLine2: billingAddressLine2 ?? this.billingAddressLine2,
      billingArea: billingArea ?? this.billingArea,
      billingCity: billingCity ?? this.billingCity,
      billingState: billingState ?? this.billingState,
      billingPincode: billingPincode ?? this.billingPincode,
      billingCountry: billingCountry ?? this.billingCountry,
      paymentTerms: paymentTerms ?? this.paymentTerms,
      creditLimit: creditLimit ?? this.creditLimit,
      creditDays: creditDays ?? this.creditDays,
      securityDeposit: securityDeposit ?? this.securityDeposit,
      fuelType: fuelType ?? this.fuelType,
      defaultGstRate: defaultGstRate ?? this.defaultGstRate,
      defaultPrice: defaultPrice ?? this.defaultPrice,
      poNumber: poNumber ?? this.poNumber,
      poDate: poDate ?? this.poDate,
      poValidTill: poValidTill ?? this.poValidTill,
      poValue: poValue ?? this.poValue,
      poRemainingBalance: poRemainingBalance ?? this.poRemainingBalance,
      invoicePrefix: invoicePrefix ?? this.invoicePrefix,
      emailInvoice: emailInvoice ?? this.emailInvoice,
      whatsappInvoice: whatsappInvoice ?? this.whatsappInvoice,
      requirePo: requirePo ?? this.requirePo,
      requireDc: requireDc ?? this.requireDc,
      requireSignature: requireSignature ?? this.requireSignature,
      gstApplicable: gstApplicable ?? this.gstApplicable,
      eInvoiceRequired: eInvoiceRequired ?? this.eInvoiceRequired,
      eWayBillRequired: eWayBillRequired ?? this.eWayBillRequired,
      openingBalance: openingBalance ?? this.openingBalance,
      currentBalance: currentBalance ?? this.currentBalance,
      lastPaymentDate: lastPaymentDate ?? this.lastPaymentDate,
      lastInvoiceDate: lastInvoiceDate ?? this.lastInvoiceDate,
      notes: notes ?? this.notes,
      createdBy: createdBy,
      createdAt: createdAt,
      updatedBy: updatedBy ?? this.updatedBy,
      updatedAt: DateTime.now(),
      deletedAt: deletedAt ?? this.deletedAt,
      version: version ?? (this.version + 1),
      tenantId: tenantId ?? this.tenantId,
    );
  }

  @override
  List<Object?> get props => [
    id,
    customerCode,
    name,
    displayName,
    tradeName,
    legalBusinessName,
    type,
    isActive,
    gstin,
    pan,
    state,
    placeOfSupply,
    gstRegistrationType,
    tan,
    billingAddressLine1,
    billingAddressLine2,
    billingArea,
    billingCity,
    billingState,
    billingPincode,
    billingCountry,
    paymentTerms,
    creditLimit,
    creditDays,
    securityDeposit,
    fuelType,
    defaultGstRate,
    defaultPrice,
    poNumber,
    poDate,
    poValidTill,
    poValue,
    poRemainingBalance,
    invoicePrefix,
    emailInvoice,
    whatsappInvoice,
    requirePo,
    requireDc,
    requireSignature,
    gstApplicable,
    eInvoiceRequired,
    eWayBillRequired,
    openingBalance,
    currentBalance,
    lastPaymentDate,
    lastInvoiceDate,
    notes,
    createdBy,
    createdAt,
    updatedBy,
    updatedAt,
    deletedAt,
    version,
    tenantId,
  ];
}

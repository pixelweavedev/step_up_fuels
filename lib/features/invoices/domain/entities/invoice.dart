/// Represents the lifecycle state of an Invoice.
enum InvoiceStatus {
  draft,
  verified,
  posted,
  partiallyPaid,
  paid,
  overdue,
  cancelled;

  String get displayName {
    switch (this) {
      case InvoiceStatus.draft:
        return 'Draft';
      case InvoiceStatus.verified:
        return 'Verified';
      case InvoiceStatus.posted:
        return 'Posted';
      case InvoiceStatus.partiallyPaid:
        return 'Partially Paid';
      case InvoiceStatus.paid:
        return 'Paid';
      case InvoiceStatus.overdue:
        return 'Overdue';
      case InvoiceStatus.cancelled:
        return 'Cancelled';
    }
  }

  static InvoiceStatus fromString(String value) {
    switch (value.toUpperCase()) {
      case 'DRAFT':
        return InvoiceStatus.draft;
      case 'VERIFIED':
        return InvoiceStatus.verified;
      case 'POSTED':
        return InvoiceStatus.posted;
      case 'PARTIALLY_PAID':
        return InvoiceStatus.partiallyPaid;
      case 'PAID':
        return InvoiceStatus.paid;
      case 'OVERDUE':
        return InvoiceStatus.overdue;
      case 'CANCELLED':
        return InvoiceStatus.cancelled;
      default:
        return InvoiceStatus.draft;
    }
  }

  String toDbString() {
    switch (this) {
      case InvoiceStatus.draft:
        return 'DRAFT';
      case InvoiceStatus.verified:
        return 'VERIFIED';
      case InvoiceStatus.posted:
        return 'POSTED';
      case InvoiceStatus.partiallyPaid:
        return 'PARTIALLY_PAID';
      case InvoiceStatus.paid:
        return 'PAID';
      case InvoiceStatus.overdue:
        return 'OVERDUE';
      case InvoiceStatus.cancelled:
        return 'CANCELLED';
    }
  }
}

/// Domain entity representing a GST-compliant Tax Invoice.
class Invoice {
  Invoice({
    required this.id,
    required this.invoiceNumber,
    required this.customerId,
    this.customerSiteId,
    required this.invoiceDate,
    required this.dueDate,
    required this.supplyType,
    required this.placeOfSupply,
    required this.isInterstate,
    required this.subtotal,
    required this.cgstAmount,
    required this.sgstAmount,
    required this.igstAmount,
    required this.totalAmount,
    required this.amountPaid,
    required this.outstanding,
    required this.status,
    this.notes,
    this.cancelledAt,
    this.cancelledReason,
    required this.createdBy,
    required this.createdAt,
    required this.updatedBy,
    required this.updatedAt,
    this.deletedAt,
    required this.version,
    this.tenantId,
  });

  final String id;
  final String invoiceNumber; // e.g. SUF/2026-27/001
  final String customerId;
  final String? customerSiteId;
  final DateTime invoiceDate;
  final DateTime dueDate;
  final String supplyType; // B2B, B2C
  final String placeOfSupply; // State code e.g. "27"
  final bool isInterstate;
  final double subtotal; // Taxable amount before GST
  final double cgstAmount;
  final double sgstAmount;
  final double igstAmount;
  final double totalAmount; // Incl. taxes
  final double amountPaid;
  final double outstanding; // totalAmount - amountPaid
  final InvoiceStatus status;
  final String? notes;
  final DateTime? cancelledAt;
  final String? cancelledReason;

  // Audits & SaaS Scope
  final String createdBy;
  final DateTime createdAt;
  final String updatedBy;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int version;
  final String? tenantId;

  /// Total GST amount (CGST+SGST for intrastate, IGST for interstate).
  double get totalGst => cgstAmount + sgstAmount + igstAmount;

  /// True if this invoice is still cancellable (not yet paid).
  bool get isCancellable => [
    InvoiceStatus.draft,
    InvoiceStatus.verified,
    InvoiceStatus.posted,
    InvoiceStatus.overdue,
  ].contains(status);

  Invoice copyWith({
    String? id,
    String? invoiceNumber,
    String? customerId,
    String? customerSiteId,
    DateTime? invoiceDate,
    DateTime? dueDate,
    String? supplyType,
    String? placeOfSupply,
    bool? isInterstate,
    double? subtotal,
    double? cgstAmount,
    double? sgstAmount,
    double? igstAmount,
    double? totalAmount,
    double? amountPaid,
    double? outstanding,
    InvoiceStatus? status,
    String? notes,
    DateTime? cancelledAt,
    String? cancelledReason,
    String? createdBy,
    DateTime? createdAt,
    String? updatedBy,
    DateTime? updatedAt,
    DateTime? deletedAt,
    int? version,
    String? tenantId,
  }) {
    return Invoice(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      customerId: customerId ?? this.customerId,
      customerSiteId: customerSiteId ?? this.customerSiteId,
      invoiceDate: invoiceDate ?? this.invoiceDate,
      dueDate: dueDate ?? this.dueDate,
      supplyType: supplyType ?? this.supplyType,
      placeOfSupply: placeOfSupply ?? this.placeOfSupply,
      isInterstate: isInterstate ?? this.isInterstate,
      subtotal: subtotal ?? this.subtotal,
      cgstAmount: cgstAmount ?? this.cgstAmount,
      sgstAmount: sgstAmount ?? this.sgstAmount,
      igstAmount: igstAmount ?? this.igstAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      amountPaid: amountPaid ?? this.amountPaid,
      outstanding: outstanding ?? this.outstanding,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cancelledReason: cancelledReason ?? this.cancelledReason,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedBy: updatedBy ?? this.updatedBy,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      version: version ?? this.version,
      tenantId: tenantId ?? this.tenantId,
    );
  }
}

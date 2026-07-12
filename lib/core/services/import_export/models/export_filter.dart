/// Rich filter applied to any export or import query.
///
/// Entity adapters use only the filters relevant to their domain.
class ExportFilter {
  factory ExportFilter.fromJson(Map<String, dynamic> json) => ExportFilter(
    dateFrom: json['dateFrom'] != null
        ? DateTime.tryParse(json['dateFrom'] as String)
        : null,
    dateTo: json['dateTo'] != null
        ? DateTime.tryParse(json['dateTo'] as String)
        : null,
    customerId: json['customerId'] as String?,
    status: json['status'] as String?,
    paymentMode: json['paymentMode'] as String?,
    driverId: json['driverId'] as String?,
    vehicleId: json['vehicleId'] as String?,
    outstandingOnly: json['outstandingOnly'] as bool? ?? false,
    activeOnly: json['activeOnly'] as bool? ?? false,
  );
  const ExportFilter({
    this.dateFrom,
    this.dateTo,
    this.customerId,
    this.status,
    this.paymentMode,
    this.driverId,
    this.vehicleId,
    this.outstandingOnly = false,
    this.activeOnly = false,
  });

  /// Factory for an empty (no-filter) instance.
  factory ExportFilter.empty() => const ExportFilter();

  final DateTime? dateFrom;
  final DateTime? dateTo;

  /// Filter by customer ID (invoices, payments, ledger).
  final String? customerId;

  /// Filter by status string (e.g. 'PAID', 'UNPAID', 'DRAFT', 'POSTED').
  final String? status;

  /// Filter by payment mode string (e.g. 'CASH', 'UPI', 'BANK_TRANSFER').
  final String? paymentMode;

  /// Filter by driver ID (deliveries, expenses).
  final String? driverId;

  /// Filter by vehicle ID (deliveries, expenses).
  final String? vehicleId;

  /// Export only records with outstanding balance > 0.
  final bool outstandingOnly;

  /// Export only active (non-deleted) records.
  final bool activeOnly;

  bool get hasDateFilter => dateFrom != null || dateTo != null;
  bool get hasAnyFilter =>
      hasDateFilter ||
      customerId != null ||
      status != null ||
      paymentMode != null ||
      driverId != null ||
      vehicleId != null ||
      outstandingOnly ||
      activeOnly;

  ExportFilter copyWith({
    DateTime? dateFrom,
    DateTime? dateTo,
    String? customerId,
    String? status,
    String? paymentMode,
    String? driverId,
    String? vehicleId,
    bool? outstandingOnly,
    bool? activeOnly,
  }) {
    return ExportFilter(
      dateFrom: dateFrom ?? this.dateFrom,
      dateTo: dateTo ?? this.dateTo,
      customerId: customerId ?? this.customerId,
      status: status ?? this.status,
      paymentMode: paymentMode ?? this.paymentMode,
      driverId: driverId ?? this.driverId,
      vehicleId: vehicleId ?? this.vehicleId,
      outstandingOnly: outstandingOnly ?? this.outstandingOnly,
      activeOnly: activeOnly ?? this.activeOnly,
    );
  }

  ExportFilter clearCustomerId() => ExportFilter(
    dateFrom: dateFrom,
    dateTo: dateTo,
    status: status,
    paymentMode: paymentMode,
    driverId: driverId,
    vehicleId: vehicleId,
    outstandingOnly: outstandingOnly,
    activeOnly: activeOnly,
  );

  ExportFilter clearStatus() => ExportFilter(
    dateFrom: dateFrom,
    dateTo: dateTo,
    customerId: customerId,
    paymentMode: paymentMode,
    driverId: driverId,
    vehicleId: vehicleId,
    outstandingOnly: outstandingOnly,
    activeOnly: activeOnly,
  );

  Map<String, dynamic> toJson() => {
    if (dateFrom != null) 'dateFrom': dateFrom!.toIso8601String(),
    if (dateTo != null) 'dateTo': dateTo!.toIso8601String(),
    if (customerId != null) 'customerId': customerId,
    if (status != null) 'status': status,
    if (paymentMode != null) 'paymentMode': paymentMode,
    if (driverId != null) 'driverId': driverId,
    if (vehicleId != null) 'vehicleId': vehicleId,
    'outstandingOnly': outstandingOnly,
    'activeOnly': activeOnly,
  };
}

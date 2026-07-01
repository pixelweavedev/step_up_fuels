import 'package:equatable/equatable.dart';

/// Represents a payment received from a customer.
class Payment extends Equatable {
  const Payment({
    required this.id,
    required this.paymentNumber,
    required this.customerId,
    this.invoiceId,
    required this.amount,
    required this.paymentDate,
    required this.paymentMode,
    this.referenceNumber,
    this.bankName,
    this.notes,
    required this.createdBy,
    required this.createdAt,
    required this.updatedBy,
    required this.updatedAt,
    this.deletedAt,
    required this.version,
    this.tenantId,
  });

  final String id;
  final String paymentNumber; // e.g. PMT/2026-27/001
  final String customerId;
  final String? invoiceId; // Nullable if advance or multi-allocated
  final double amount;
  final DateTime paymentDate;
  final String paymentMode; // CASH, UPI, BANK_TRANSFER, CHEQUE, etc.
  final String? referenceNumber; // Bank transaction ID, Cheque number, UTR
  final String? bankName;
  final String? notes;

  // Auditing & SaaS Scope
  final String createdBy;
  final DateTime createdAt;
  final String updatedBy;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int version;
  final String? tenantId;

  Payment copyWith({
    String? id,
    String? paymentNumber,
    String? customerId,
    String? invoiceId,
    double? amount,
    DateTime? paymentDate,
    String? paymentMode,
    String? referenceNumber,
    String? bankName,
    String? notes,
    String? createdBy,
    DateTime? createdAt,
    String? updatedBy,
    DateTime? updatedAt,
    DateTime? deletedAt,
    int? version,
    String? tenantId,
  }) {
    return Payment(
      id: id ?? this.id,
      paymentNumber: paymentNumber ?? this.paymentNumber,
      customerId: customerId ?? this.customerId,
      invoiceId: invoiceId ?? this.invoiceId,
      amount: amount ?? this.amount,
      paymentDate: paymentDate ?? this.paymentDate,
      paymentMode: paymentMode ?? this.paymentMode,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      bankName: bankName ?? this.bankName,
      notes: notes ?? this.notes,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedBy: updatedBy ?? this.updatedBy,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      version: version ?? this.version,
      tenantId: tenantId ?? this.tenantId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        paymentNumber,
        customerId,
        invoiceId,
        amount,
        paymentDate,
        paymentMode,
        referenceNumber,
        bankName,
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

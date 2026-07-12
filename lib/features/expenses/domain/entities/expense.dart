import 'package:equatable/equatable.dart';

class Expense extends Equatable {
  const Expense({
    required this.id,
    required this.expenseNumber,
    required this.category,
    required this.amount,
    required this.expenseDate,
    required this.paymentMode,
    this.paymentReference,
    this.vehicleId,
    this.driverId,
    this.billDocumentId,
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
  final String expenseNumber; // e.g. EXP/2026-27/001
  final String category; // DRIVER_SALARY, VEHICLE_MAINTENANCE, etc.
  final double amount;
  final DateTime expenseDate;
  final String paymentMode; // CASH, UPI, BANK_TRANSFER
  final String? paymentReference;
  final String? vehicleId;
  final String? driverId;
  final String? billDocumentId;
  final String? notes;

  // Audits
  final String createdBy;
  final DateTime createdAt;
  final String updatedBy;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int version;
  final String? tenantId;

  Expense copyWith({
    String? expenseNumber,
    String? category,
    double? amount,
    DateTime? expenseDate,
    String? paymentMode,
    String? paymentReference,
    String? vehicleId,
    String? driverId,
    String? billDocumentId,
    String? notes,
    String? updatedBy,
    DateTime? deletedAt,
    int? version,
    String? tenantId,
  }) {
    return Expense(
      id: id,
      expenseNumber: expenseNumber ?? this.expenseNumber,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      expenseDate: expenseDate ?? this.expenseDate,
      paymentMode: paymentMode ?? this.paymentMode,
      paymentReference: paymentReference ?? this.paymentReference,
      vehicleId: vehicleId ?? this.vehicleId,
      driverId: driverId ?? this.driverId,
      billDocumentId: billDocumentId ?? this.billDocumentId,
      notes: notes ?? this.notes,
      createdBy: createdBy,
      createdAt: createdAt,
      updatedBy: updatedBy ?? this.updatedBy,
      updatedAt: DateTime.now(),
      deletedAt: deletedAt ?? this.deletedAt,
      version: version ?? this.version,
      tenantId: tenantId ?? this.tenantId,
    );
  }

  @override
  List<Object?> get props => [
    id,
    expenseNumber,
    category,
    amount,
    expenseDate,
    paymentMode,
    paymentReference,
    vehicleId,
    driverId,
    billDocumentId,
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

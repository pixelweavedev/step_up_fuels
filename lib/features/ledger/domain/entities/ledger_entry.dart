import 'package:equatable/equatable.dart';

/// Represents a double-entry ledger debit or credit entry.
class LedgerEntry extends Equatable {
  const LedgerEntry({
    required this.id,
    required this.ledgerAccountId,
    required this.entryDate,
    required this.description,
    required this.debitAmount,
    required this.creditAmount,
    this.referenceId, // FK to invoice, payment, purchase, etc.
    this.referenceType, // INVOICE, PAYMENT, PURCHASE, EXPENSE
    required this.runningBalance,
    required this.createdAt,
    required this.createdBy,
  });

  final String id;
  final String ledgerAccountId;
  final DateTime entryDate;
  final String description;
  final double debitAmount;
  final double creditAmount;
  final String? referenceId;
  final String? referenceType;
  final double runningBalance;
  final DateTime createdAt;
  final String createdBy;

  LedgerEntry copyWith({
    String? id,
    String? ledgerAccountId,
    DateTime? entryDate,
    String? description,
    double? debitAmount,
    double? creditAmount,
    String? referenceId,
    String? referenceType,
    double? runningBalance,
    DateTime? createdAt,
    String? createdBy,
  }) {
    return LedgerEntry(
      id: id ?? this.id,
      ledgerAccountId: ledgerAccountId ?? this.ledgerAccountId,
      entryDate: entryDate ?? this.entryDate,
      description: description ?? this.description,
      debitAmount: debitAmount ?? this.debitAmount,
      creditAmount: creditAmount ?? this.creditAmount,
      referenceId: referenceId ?? this.referenceId,
      referenceType: referenceType ?? this.referenceType,
      runningBalance: runningBalance ?? this.runningBalance,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  @override
  List<Object?> get props => [
    id,
    ledgerAccountId,
    entryDate,
    description,
    debitAmount,
    creditAmount,
    referenceId,
    referenceType,
    runningBalance,
    createdAt,
    createdBy,
  ];
}

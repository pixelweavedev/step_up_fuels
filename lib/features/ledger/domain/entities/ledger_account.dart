import 'package:equatable/equatable.dart';

/// Represents a ledger account in the double-entry Chart of Accounts.
class LedgerAccount extends Equatable {
  const LedgerAccount({
    required this.id,
    required this.accountCode,
    required this.name,
    required this.accountType, // CUSTOMER, SUPPLIER, CASH, BANK, SALES, EXPENSE, TAX, PURCHASE
    this.referenceId,
    this.referenceType,
    required this.isSystem,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String accountCode; // e.g. ACT-SALES, ACT-CASH, ACT-BANK, ACT-SUP-001, ACT-CUST-001
  final String name;
  final String accountType;
  final String? referenceId; // customerId or supplierId
  final String? referenceType; // CUSTOMER or SUPPLIER
  final bool isSystem;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  LedgerAccount copyWith({
    String? id,
    String? accountCode,
    String? name,
    String? accountType,
    String? referenceId,
    String? referenceType,
    bool? isSystem,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LedgerAccount(
      id: id ?? this.id,
      accountCode: accountCode ?? this.accountCode,
      name: name ?? this.name,
      accountType: accountType ?? this.accountType,
      referenceId: referenceId ?? this.referenceId,
      referenceType: referenceType ?? this.referenceType,
      isSystem: isSystem ?? this.isSystem,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        accountCode,
        name,
        accountType,
        referenceId,
        referenceType,
        isSystem,
        isActive,
        createdAt,
        updatedAt,
      ];
}

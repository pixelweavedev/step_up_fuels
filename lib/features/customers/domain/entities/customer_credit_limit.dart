import 'package:equatable/equatable.dart';

/// Represents a change log of credit limit for a customer.
class CustomerCreditLimit extends Equatable {
  const CustomerCreditLimit({
    required this.id,
    required this.customerId,
    required this.creditLimit,
    required this.effectiveFrom,
    this.notes,
    required this.createdAt,
    this.createdBy,
  });
  final String id;
  final String customerId;
  final double creditLimit;
  final DateTime effectiveFrom;
  final String? notes;
  final DateTime createdAt;
  final String? createdBy;

  @override
  List<Object?> get props => [
    id,
    customerId,
    creditLimit,
    effectiveFrom,
    notes,
    createdAt,
    createdBy,
  ];
}

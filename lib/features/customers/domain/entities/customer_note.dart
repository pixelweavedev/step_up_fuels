import 'package:equatable/equatable.dart';

/// Represents a distinct note log entry for a customer.
class CustomerNote extends Equatable {
  const CustomerNote({
    required this.id,
    required this.customerId,
    required this.notes,
    required this.createdBy,
    required this.createdAt,
    this.updatedBy,
    this.updatedAt,
    this.deletedAt,
    this.tenantId,
  });
  final String id;
  final String customerId;
  final String notes;
  final String createdBy;
  final DateTime createdAt;
  final String? updatedBy;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final String? tenantId;

  @override
  List<Object?> get props => [
    id,
    customerId,
    notes,
    createdBy,
    createdAt,
    updatedBy,
    updatedAt,
    deletedAt,
    tenantId,
  ];
}

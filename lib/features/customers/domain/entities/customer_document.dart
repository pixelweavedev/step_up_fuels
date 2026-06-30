import 'package:equatable/equatable.dart';
import 'package:step_up_fuels/features/customers/domain/entities/document_type.dart';

/// Represents an uploaded compliance or business document.
class CustomerDocument extends Equatable {
  const CustomerDocument({
    required this.id,
    required this.customerId,
    required this.documentType,
    required this.fileUrl,
    required this.createdBy,
    required this.createdAt,
    this.updatedBy,
    this.updatedAt,
    this.deletedAt,
    this.tenantId,
  });
  final String id;
  final String customerId;
  final DocumentType documentType;
  final String fileUrl;
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
    documentType,
    fileUrl,
    createdBy,
    createdAt,
    updatedBy,
    updatedAt,
    deletedAt,
    tenantId,
  ];
}

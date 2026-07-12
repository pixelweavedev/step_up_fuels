import 'package:equatable/equatable.dart';

enum AllocationStatus {
  active,
  reversed;

  String get displayName {
    switch (this) {
      case AllocationStatus.active:
        return 'Active';
      case AllocationStatus.reversed:
        return 'Reversed';
    }
  }

  static AllocationStatus fromString(String value) {
    switch (value.toUpperCase()) {
      case 'ACTIVE':
        return AllocationStatus.active;
      case 'REVERSED':
        return AllocationStatus.reversed;
      default:
        return AllocationStatus.active;
    }
  }

  String toDbString() {
    switch (this) {
      case AllocationStatus.active:
        return 'ACTIVE';
      case AllocationStatus.reversed:
        return 'REVERSED';
    }
  }
}

enum AllocationType {
  payment,
  advance,
  creditNote,
  refund,
  writeOff;

  String get displayName {
    switch (this) {
      case AllocationType.payment:
        return 'Payment';
      case AllocationType.advance:
        return 'Advance';
      case AllocationType.creditNote:
        return 'Credit Note';
      case AllocationType.refund:
        return 'Refund';
      case AllocationType.writeOff:
        return 'Write-off';
    }
  }

  static AllocationType fromString(String value) {
    switch (value.toUpperCase()) {
      case 'PAYMENT':
        return AllocationType.payment;
      case 'ADVANCE':
        return AllocationType.advance;
      case 'CREDIT_NOTE':
        return AllocationType.creditNote;
      case 'REFUND':
        return AllocationType.refund;
      case 'WRITE_OFF':
        return AllocationType.writeOff;
      default:
        return AllocationType.payment;
    }
  }

  String toDbString() {
    switch (this) {
      case AllocationType.payment:
        return 'PAYMENT';
      case AllocationType.advance:
        return 'ADVANCE';
      case AllocationType.creditNote:
        return 'CREDIT_NOTE';
      case AllocationType.refund:
        return 'REFUND';
      case AllocationType.writeOff:
        return 'WRITE_OFF';
    }
  }
}

class PaymentAllocation extends Equatable {
  const PaymentAllocation({
    required this.id,
    required this.paymentId,
    required this.invoiceId,
    required this.allocatedAmount,
    required this.status,
    required this.type,
    this.referenceNumber,
    this.remarks,
    this.reversedAt,
    required this.createdAt,
  });

  final String id;
  final String paymentId;
  final String invoiceId;
  final double allocatedAmount;
  final AllocationStatus status;
  final AllocationType type;
  final String? referenceNumber;
  final String? remarks;
  final DateTime? reversedAt;
  final DateTime createdAt;

  PaymentAllocation copyWith({
    String? id,
    String? paymentId,
    String? invoiceId,
    double? allocatedAmount,
    AllocationStatus? status,
    AllocationType? type,
    String? referenceNumber,
    String? remarks,
    DateTime? reversedAt,
    DateTime? createdAt,
  }) {
    return PaymentAllocation(
      id: id ?? this.id,
      paymentId: paymentId ?? this.paymentId,
      invoiceId: invoiceId ?? this.invoiceId,
      allocatedAmount: allocatedAmount ?? this.allocatedAmount,
      status: status ?? this.status,
      type: type ?? this.type,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      remarks: remarks ?? this.remarks,
      reversedAt: reversedAt ?? this.reversedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    paymentId,
    invoiceId,
    allocatedAmount,
    status,
    type,
    referenceNumber,
    remarks,
    reversedAt,
    createdAt,
  ];
}

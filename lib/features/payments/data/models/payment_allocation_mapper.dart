import 'package:drift/drift.dart';
import 'package:step_up_fuels/app/database/app_database.dart';
import 'package:step_up_fuels/features/payments/domain/entities/payment_allocation.dart';

extension PaymentAllocationRowMapper on PaymentAllocationRow {
  PaymentAllocation toDomain() {
    return PaymentAllocation(
      id: id,
      paymentId: paymentId,
      invoiceId: invoiceId,
      allocatedAmount: allocatedAmount,
      status: AllocationStatus.fromString(status),
      type: AllocationType.fromString(type),
      referenceNumber: referenceNumber,
      remarks: remarks,
      reversedAt: reversedAt,
      createdAt: createdAt,
    );
  }
}

extension PaymentAllocationDomainMapper on PaymentAllocation {
  PaymentAllocationsCompanion toCompanion() {
    return PaymentAllocationsCompanion(
      id: Value(id),
      paymentId: Value(paymentId),
      invoiceId: Value(invoiceId),
      allocatedAmount: Value(allocatedAmount),
      status: Value(status.toDbString()),
      type: Value(type.toDbString()),
      referenceNumber: Value(referenceNumber),
      remarks: Value(remarks),
      reversedAt: Value(reversedAt),
      createdAt: Value(createdAt),
    );
  }
}

import 'package:drift/drift.dart';
import 'package:step_up_fuels/app/database/app_database.dart';
import 'package:step_up_fuels/features/payments/domain/entities/payment.dart';

extension PaymentRowMapper on PaymentRow {
  Payment toDomain() {
    return Payment(
      id: id,
      paymentNumber: paymentNumber,
      customerId: customerId,
      invoiceId: invoiceId,
      amount: amount,
      paymentDate: paymentDate,
      paymentMode: paymentMode,
      referenceNumber: referenceNumber,
      bankName: bankName,
      notes: notes,
      createdBy: createdBy,
      createdAt: createdAt,
      updatedBy: updatedBy,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
      version: version,
      tenantId: tenantId,
    );
  }
}

extension PaymentDomainMapper on Payment {
  PaymentsCompanion toCompanion() {
    return PaymentsCompanion(
      id: Value(id),
      paymentNumber: Value(paymentNumber),
      customerId: Value(customerId),
      invoiceId: Value(invoiceId),
      amount: Value(amount),
      paymentDate: Value(paymentDate),
      paymentMode: Value(paymentMode),
      referenceNumber: Value(referenceNumber),
      bankName: Value(bankName),
      notes: Value(notes),
      createdBy: Value(createdBy),
      createdAt: Value(createdAt),
      updatedBy: Value(updatedBy),
      updatedAt: Value(updatedAt),
      deletedAt: Value(deletedAt),
      version: Value(version),
      tenantId: Value(tenantId),
    );
  }
}

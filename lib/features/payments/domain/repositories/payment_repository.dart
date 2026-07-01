import 'package:step_up_fuels/core/result/result.dart';
import 'package:step_up_fuels/features/payments/domain/entities/payment.dart';

/// Repository interface for customer Payments.
abstract class PaymentRepository {
  /// Returns all payments, optionally filtered.
  Future<Result<List<Payment>>> getAll({
    String? customerId,
    String? invoiceId,
    String? searchQuery,
    DateTime? fromDate,
    DateTime? toDate,
  });

  /// Returns a single payment by its [id].
  Future<Result<Payment>> getById(String id);

  /// Saves a customer payment, allocating it to invoices and generating ledger entries.
  /// If [autoAllocate] is true and [payment.invoiceId] is null, the payment is applied
  /// to the customer's oldest outstanding invoices.
  Future<Result<void>> receivePayment(Payment payment, {bool autoAllocate = true});
}

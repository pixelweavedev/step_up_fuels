import 'package:step_up_fuels/core/result/result.dart';
import 'package:step_up_fuels/features/payments/domain/entities/payment.dart';
import 'package:step_up_fuels/features/payments/domain/entities/payment_allocation.dart';

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

  /// Reverses an active payment receipt, rolls back allocations, and posts reversing entries.
  Future<Result<void>> reversePayment(String paymentId);

  /// Links existing customer unallocated advance balances to a specific invoice.
  Future<Result<void>> applyAdvance({
    required String customerId,
    required String paymentId,
    required String invoiceId,
    required double amount,
  });

  /// Returns allocations optionally filtered by payment, invoice, or status.
  Future<Result<List<PaymentAllocation>>> getAllAllocations({
    String? paymentId,
    String? invoiceId,
    String? status,
  });
}

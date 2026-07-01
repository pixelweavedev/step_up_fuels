import 'package:step_up_fuels/core/result/result.dart';
import 'package:step_up_fuels/features/invoices/domain/entities/invoice.dart';
import 'package:step_up_fuels/features/invoices/domain/entities/invoice_item.dart';

/// Contract for accessing and mutating Invoice data.
abstract class InvoiceRepository {
  /// Returns all invoices, optionally filtered by [status] or [customerId].
  Future<Result<List<Invoice>>> getAll({
    InvoiceStatus? status,
    String? customerId,
    String? searchQuery,
    DateTime? fromDate,
    DateTime? toDate,
    bool includeDeleted,
  });

  /// Returns a single invoice by its [id].
  Future<Result<Invoice>> getById(String id);

  /// Returns all line items belonging to [invoiceId].
  Future<Result<List<InvoiceItem>>> getItems(String invoiceId);

  /// Saves (creates or updates) an invoice and its items atomically.
  Future<Result<void>> save(Invoice invoice, List<InvoiceItem> items);

  /// Posts a DRAFT/VERIFIED invoice (transitions to POSTED).
  /// Increments the invoice counter in AppSettings atomically.
  Future<Result<Invoice>> post(String invoiceId);

  /// Cancels an invoice. Requires [reason].
  Future<Result<void>> cancel(String invoiceId, String reason);

  /// Applies a payment amount to reduce outstanding balance.
  /// Used by the Payment module to update [amountPaid] and [outstanding].
  Future<Result<void>> applyPayment(String invoiceId, double amount);

  /// Soft-deletes an invoice.
  Future<Result<void>> softDelete(String id);
}

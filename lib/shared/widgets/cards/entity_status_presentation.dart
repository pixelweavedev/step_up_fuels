import 'package:flutter/material.dart';
import 'package:step_up_fuels/features/customers/domain/entities/customer.dart';
import 'package:step_up_fuels/features/invoices/domain/entities/invoice.dart';
import 'package:step_up_fuels/shared/widgets/cards/status_badge.dart';

/// Entity-specific status presentation mapping to ensure distinct semantic meaning
/// across different ERP modules without coupling them into a monolithic enum.
class EntityStatusPresentation {
  EntityStatusPresentation._();

  /// Maps [InvoiceStatus] to a consistent [StatusBadge].
  ///
  /// - draft: neutral slate
  /// - verified: info blue
  /// - posted: neutral dark / slate (not amber!)
  /// - partiallyPaid: warning amber
  /// - paid: success green
  /// - overdue / cancelled: error red
  static Widget invoiceBadge(InvoiceStatus status) {
    final (label, type) = switch (status) {
      InvoiceStatus.draft => ('Draft', StatusBadgeType.neutral),
      InvoiceStatus.verified => ('Verified', StatusBadgeType.info),
      InvoiceStatus.posted => ('Posted', StatusBadgeType.neutral),
      InvoiceStatus.partiallyPaid => ('Partially Paid', StatusBadgeType.warning),
      InvoiceStatus.paid => ('Paid', StatusBadgeType.success),
      InvoiceStatus.overdue => ('Overdue', StatusBadgeType.error),
      InvoiceStatus.cancelled => ('Cancelled', StatusBadgeType.error),
    };

    return StatusBadge(
      label: label,
      type: type,
    );
  }

  /// Maps Purchase payment status strings ('PAID', 'PARTIALLY_PAID', 'UNPAID', 'PENDING')
  /// to a consistent [StatusBadge].
  static Widget purchasePaymentBadge(String status) {
    final norm = status.toUpperCase().replaceAll(' ', '_');
    final (label, type) = switch (norm) {
      'PAID' => ('Paid', StatusBadgeType.success),
      'PARTIALLY_PAID' || 'PARTIAL' => ('Partially Paid', StatusBadgeType.warning),
      'UNPAID' || 'OVERDUE' => ('Unpaid', StatusBadgeType.error),
      'PENDING' || 'VERIFIED' => ('Verified', StatusBadgeType.info),
      _ => (status, StatusBadgeType.neutral),
    };

    return StatusBadge(
      label: label,
      type: type,
    );
  }

  /// Maps [Customer] status (active, inactive, deleted) to a consistent [StatusBadge].
  static Widget customerBadge(Customer customer) {
    if (customer.deletedAt != null) {
      return const StatusBadge(
        label: 'Deleted',
        type: StatusBadgeType.error,
      );
    }
    if (customer.isActive) {
      return const StatusBadge(
        label: 'Active',
        type: StatusBadgeType.success,
      );
    }
    return const StatusBadge(
      label: 'Inactive',
    );
  }
}

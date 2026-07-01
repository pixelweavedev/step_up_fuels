import 'package:drift/drift.dart';
import 'package:step_up_fuels/app/database/app_database.dart';
import 'package:step_up_fuels/features/invoices/domain/entities/invoice.dart';
import 'package:step_up_fuels/features/invoices/domain/entities/invoice_item.dart';

// ── InvoiceRow → Invoice ──────────────────────────────────────────────────────

extension InvoiceRowMapper on InvoiceRow {
  Invoice toDomain() => Invoice(
        id: id,
        invoiceNumber: invoiceNumber,
        customerId: customerId,
        customerSiteId: customerSiteId,
        invoiceDate: invoiceDate,
        dueDate: dueDate,
        supplyType: supplyType,
        placeOfSupply: placeOfSupply,
        isInterstate: isInterstate,
        subtotal: subtotal,
        cgstAmount: cgstAmount,
        sgstAmount: sgstAmount,
        igstAmount: igstAmount,
        totalAmount: totalAmount,
        amountPaid: amountPaid,
        outstanding: outstanding,
        status: InvoiceStatus.fromString(status),
        notes: notes,
        cancelledAt: cancelledAt,
        cancelledReason: cancelledReason,
        createdBy: createdBy,
        createdAt: createdAt,
        updatedBy: updatedBy,
        updatedAt: updatedAt,
        deletedAt: deletedAt,
        version: version,
        tenantId: tenantId,
      );
}

// ── Invoice → InvoicesCompanion ───────────────────────────────────────────────

extension InvoiceDomainMapper on Invoice {
  InvoicesCompanion toCompanion() => InvoicesCompanion(
        id: Value(id),
        invoiceNumber: Value(invoiceNumber),
        customerId: Value(customerId),
        customerSiteId: Value(customerSiteId),
        invoiceDate: Value(invoiceDate),
        dueDate: Value(dueDate),
        supplyType: Value(supplyType),
        placeOfSupply: Value(placeOfSupply),
        isInterstate: Value(isInterstate),
        subtotal: Value(subtotal),
        cgstAmount: Value(cgstAmount),
        sgstAmount: Value(sgstAmount),
        igstAmount: Value(igstAmount),
        totalAmount: Value(totalAmount),
        amountPaid: Value(amountPaid),
        outstanding: Value(outstanding),
        status: Value(status.toDbString()),
        notes: Value(notes),
        cancelledAt: Value(cancelledAt),
        cancelledReason: Value(cancelledReason),
        createdBy: Value(createdBy),
        createdAt: Value(createdAt),
        updatedBy: Value(updatedBy),
        updatedAt: Value(updatedAt),
        deletedAt: Value(deletedAt),
        version: Value(version),
        tenantId: Value(tenantId),
      );
}

// ── InvoiceItemRow → InvoiceItem ──────────────────────────────────────────────

extension InvoiceItemRowMapper on InvoiceItemRow {
  InvoiceItem toDomain() => InvoiceItem(
        id: id,
        invoiceId: invoiceId,
        productId: productId,
        hsnCode: hsnCode,
        description: description,
        quantity: quantity,
        unit: unit,
        rate: rate,
        taxableAmount: taxableAmount,
        gstRate: gstRate,
        cgstRate: cgstRate,
        sgstRate: sgstRate,
        igstRate: igstRate,
        cgstAmount: cgstAmount,
        sgstAmount: sgstAmount,
        igstAmount: igstAmount,
        totalAmount: totalAmount,
        sortOrder: sortOrder,
      );
}

// ── InvoiceItem → InvoiceItemsCompanion ──────────────────────────────────────

extension InvoiceItemDomainMapper on InvoiceItem {
  InvoiceItemsCompanion toCompanion() => InvoiceItemsCompanion(
        id: Value(id),
        invoiceId: Value(invoiceId),
        productId: Value(productId),
        hsnCode: Value(hsnCode),
        description: Value(description),
        quantity: Value(quantity),
        unit: Value(unit),
        rate: Value(rate),
        taxableAmount: Value(taxableAmount),
        gstRate: Value(gstRate),
        cgstRate: Value(cgstRate),
        sgstRate: Value(sgstRate),
        igstRate: Value(igstRate),
        cgstAmount: Value(cgstAmount),
        sgstAmount: Value(sgstAmount),
        igstAmount: Value(igstAmount),
        totalAmount: Value(totalAmount),
        sortOrder: Value(sortOrder),
      );
}

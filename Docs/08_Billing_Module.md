# 08 — Billing Module

## Overview

The Billing module is the core revenue function. It generates GST-compliant tax invoices from a simple form and produces professional PDFs ready for printing or sharing.

---

## Invoice Lifecycle (State Machine)

```
                    ┌──────────┐
                    │  DRAFT   │ ← Created, editable
                    └────┬─────┘
                         │ verify()
                    ┌────▼─────┐
                    │ VERIFIED │ ← Reviewed, locked
                    └────┬─────┘
                         │ post()
                    ┌────▼─────┐
                    │  POSTED  │ ← Stock deducted, ledger entry created
                    └────┬─────┘
              ┌──────────┼──────────┐
              │          │          │
         ┌────▼──┐  ┌───▼──────┐  ┌▼───────┐
         │ PAID  │  │ PARTIALLY│  │OVERDUE │
         │       │  │   PAID   │  │        │
         └───────┘  └──────────┘  └────────┘

  Any status except PAID → CANCELLED (with reason)
```

---

## InvoiceService (Domain Service)

```dart
class InvoiceService {
  Future<Result<Invoice>> createDraft({
    required String customerId,
    String? customerSiteId,
    required DateTime invoiceDate,
    required List<InvoiceItemInput> items,
    String? notes,
  });

  Future<Result<Invoice>> verifyInvoice(String invoiceId);

  /// Post: locks invoice, deducts stock, creates ledger entry.
  Future<Result<Invoice>> postInvoice(String invoiceId);

  Future<Result<Invoice>> cancelInvoice(String invoiceId, String reason);
}
```

---

## GstCalculationService

```dart
class GstCalculationService {
  GstBreakdown calculate({
    required double taxableAmount,
    required double gstRate,
    required String sellerStateCode,
    required String buyerStateCode,
  });
}

class GstBreakdown {
  final double taxableAmount;
  final double cgst;
  final double sgst;
  final double igst;
  final double totalTax;
  final double grandTotal;
  final bool isInterstate;
}
```

---

## Invoice PDF Generation Pipeline

```
InvoicePostUseCase
      ↓
InvoiceService.postInvoice()
      ↓ triggers
InvoicePdfGenerator.generate(invoice)
      ↓
InvoicePrintService.print() / saveToFile() / share()
```

### PDF Structure (matches sample invoice)
1. Header: Company logo, name, GSTIN, address
2. "TAX INVOICE" title + Invoice number + Date
3. Customer details: Name, GSTIN, address, place of supply
4. Line items table: HSN, Description, Qty, Rate, Taxable, GST%, CGST, SGST, Total
5. Tax summary: Taxable amount, CGST total, SGST total, Grand Total
6. Amount in words
7. Bank details for payment
8. Terms and conditions
9. Signature block

---

## Invoice Number Format

`SUF/2024-25/001`

- `SUF` = configurable prefix (from Settings)
- `2024-25` = financial year (April-March)
- `001` = sequential number (resets each financial year)

The counter is stored in `app_settings` and incremented atomically when an invoice is posted.

---

## Drift Tables

| Table | Key Columns |
|---|---|
| `invoices` | id, invoice_number, customer_id, date, status, subtotal, cgst, sgst, igst, total, outstanding |
| `invoice_items` | id, invoice_id, product_id, hsn_code, qty, rate, taxable_amount, gst_rate, cgst, sgst, total |

---

## Cross-Feature Effects of Posting an Invoice

When `InvoiceService.postInvoice()` is called:

1. Invoice status → `POSTED`
2. `InventoryMovement` created (type: `INVOICE_OUT`, quantity deducted)
3. `LedgerEntry` created (debit customer account, credit sales account)
4. `DomainEvent` emitted (`InvoicePosted`)

All four operations happen in a single database transaction.

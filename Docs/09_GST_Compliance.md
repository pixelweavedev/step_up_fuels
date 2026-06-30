# 09 — GST Compliance

## Overview

This application fully complies with India's Goods and Services Tax (GST) framework as applicable to B2B diesel distribution.

---

## GST on HSD (High Speed Diesel)

> **Important**: HSD (Diesel) is currently **outside GST**. It is taxed under the state VAT framework.
> However, the application is designed to support GST when/if petroleum products are brought under GST.
>
> For now, the application will generate invoices showing applicable state VAT or any other applicable taxes.
> The schema and service layer are GST-ready for seamless transition.

---

## Key GST Concepts

| Term | Meaning |
|---|---|
| GSTIN | GST Identification Number (15-character) |
| HSN Code | Harmonised System of Nomenclature — product classification code |
| CGST | Central GST — collected by Centre (intra-state) |
| SGST | State GST — collected by State (intra-state) |
| IGST | Integrated GST — for inter-state supplies |
| Place of Supply | Determines intra-state vs inter-state |
| B2B | Business to Business (both parties have GSTIN) |
| B2C | Business to Consumer (customer has no GSTIN) |
| GSTR-1 | Monthly outward supply return |
| e-Invoice | Electronic invoice generated via IRP (Invoice Registration Portal) |
| e-Way Bill | Required for goods movement above ₹50,000 |
| IRN | Invoice Reference Number (unique ID from IRP) |
| QR Code | Embedded in e-Invoice |

---

## Tax Type Determination

```
if (seller_state_code == buyer_state_code):
    Apply CGST + SGST (each at rate/2)
else:
    Apply IGST (at full rate)
```

### GstCalculationService

```dart
class GstCalculationService {
  GstBreakdown calculate({
    required double taxableAmount,
    required double gstRate,
    required bool isInterstate,
  }) {
    if (isInterstate) {
      return GstBreakdown(
        taxableAmount: taxableAmount,
        cgst: 0,
        sgst: 0,
        igst: taxableAmount * gstRate,
        total: taxableAmount + (taxableAmount * gstRate),
      );
    } else {
      final halfRate = gstRate / 2;
      return GstBreakdown(
        taxableAmount: taxableAmount,
        cgst: taxableAmount * halfRate,
        sgst: taxableAmount * halfRate,
        igst: 0,
        total: taxableAmount + (taxableAmount * gstRate),
      );
    }
  }
}
```

---

## GSTIN Validation

Format: `[2-digit state code][5-char PAN][4-digit serial][1-char entity][Z][1-char checksum]`

Regex: `^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$`

Indian state codes are stored in `lib/core/constants/gst_constants.dart`.

---

## Invoice Fields Required for GST Compliance

Every tax invoice must contain:

| Field | Example |
|---|---|
| Supplier Name | STEP UP FUELS |
| Supplier GSTIN | 27ABCDE1234F1Z5 |
| Supplier Address | Full address with state and pincode |
| Invoice Number | SUF/2024-25/001 |
| Invoice Date | 30-Jun-2024 |
| Customer Name | ABC Construction Pvt Ltd |
| Customer GSTIN | 27XYZPQ5678G1Z3 |
| Customer Address | |
| Place of Supply | Maharashtra (27) |
| HSN Code | 2710 |
| Description | High Speed Diesel |
| Quantity + Unit | 500 KL |
| Rate per Unit | ₹86.00 |
| Taxable Value | ₹43,000.00 |
| CGST Rate + Amount | 9% — ₹3,870.00 |
| SGST Rate + Amount | 9% — ₹3,870.00 |
| Total Tax | ₹7,740.00 |
| Invoice Total | ₹50,740.00 |
| Amount in Words | Fifty Thousand Seven Hundred Forty Rupees Only |

---

## Invoice Numbering

Format: `[PREFIX]/[FINANCIAL_YEAR]/[SEQUENCE]`

Example: `SUF/2024-25/001`

Financial year starts April 1. The sequence resets every financial year.

```dart
class InvoiceNumberGenerator {
  String generate({
    required String prefix,
    required int sequence,
    required DateTime date,
  }) {
    final fy = _getFinancialYear(date);
    final seq = sequence.toString().padLeft(3, '0');
    return '$prefix/$fy/$seq';
  }

  String _getFinancialYear(DateTime date) {
    final year = date.month >= 4 ? date.year : date.year - 1;
    return '$year-${(year + 1).toString().substring(2)}';
  }
}
```

---

## GSTR-1 Export Requirements

The Reports module will export GSTR-1 compatible data:

| Section | Contents |
|---|---|
| B2B | All B2B invoices with GSTIN |
| B2C Large | B2C invoices above ₹2.5 lakh |
| B2C Small | B2C invoices below ₹2.5 lakh |
| CDNR | Credit/Debit notes (for registered) |
| HSN Summary | HSN-wise summary |

---

## Future: e-Invoice Integration

When e-Invoice becomes applicable:

```
InvoiceService
    ↓
IRPClient.generateIRN(invoice)
    ↓
IRP API Response (IRN + QR Code)
    ↓
InvoiceService.attachIRN(invoice, irn, qrCode)
    ↓
InvoicePdfGenerator (embeds QR code)
```

The `domain_events` table will log all IRP interactions.

---

## Amount in Words

All invoice totals must display the amount in words in Indian format:

`₹50,740.00 → "Rupees Fifty Thousand Seven Hundred Forty Only"`

This is handled by `lib/core/utils/number_utils.dart → amountInWords()`.

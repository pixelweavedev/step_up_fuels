import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:step_up_fuels/features/customers/domain/entities/customer.dart';
import 'package:step_up_fuels/features/invoices/domain/entities/invoice.dart';
import 'package:step_up_fuels/features/invoices/domain/entities/invoice_item.dart';

class PdfInvoiceGenerator {
  static Future<Uint8List> generatePdf({
    required Invoice invoice,
    required List<InvoiceItem> items,
    required Customer customer,
    required bool isDuplicate,
  }) async {
    final pdf = pw.Document();

    final dateFmt = DateFormat('dd-MMM-yyyy');
    final currencyFmt = NumberFormat('#,##,##0.00', 'en_IN');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header Segment
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'STEP UP FUELS',
                        style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.amber,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Premium Fuel & Lubricants Distribution\nPlot No. 42, Sector 17, Vashi,\nNavi Mumbai, Maharashtra - 400703',
                        style: const pw.TextStyle(fontSize: 9),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'GSTIN: 27AAACS8976C1ZS • PAN: AAACS8976C\nState Code: 27 (Maharashtra)',
                        style: pw.TextStyle(
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'TAX INVOICE',
                        style: pw.TextStyle(
                          fontSize: 22,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blueGrey900,
                        ),
                      ),
                      pw.Text(
                        isDuplicate ? 'DUPLICATE FOR SUPPLIER' : 'ORIGINAL FOR RECIPIENT',
                        style: pw.TextStyle(
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.grey700,
                        ),
                      ),
                      pw.SizedBox(height: 12),
                      pw.Text(
                        'Invoice No: ${invoice.invoiceNumber}',
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        'Date: ${dateFmt.format(invoice.invoiceDate)}',
                        style: const pw.TextStyle(fontSize: 9),
                      ),
                      pw.Text(
                        'Due Date: ${dateFmt.format(invoice.dueDate)}',
                        style: const pw.TextStyle(fontSize: 9),
                      ),
                    ],
                  ),
                ],
              ),

              pw.Divider(thickness: 1, color: PdfColors.grey400),
              pw.SizedBox(height: 10),

              // Billing Details
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'BILLED TO (BUYER):',
                          style: pw.TextStyle(
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.grey700,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          customer.name,
                          style: pw.TextStyle(
                            fontSize: 11,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text(
                          [
                            customer.billingAddressLine1,
                            customer.billingAddressLine2,
                            customer.billingCity,
                            customer.billingState,
                            customer.billingPincode,
                          ].where((s) => s != null && s.isNotEmpty).join(', '),
                          style: const pw.TextStyle(fontSize: 9),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'GSTIN: ${customer.gstin ?? "Not Provided"} • PAN: ${customer.pan ?? "Not Provided"}',
                          style: pw.TextStyle(
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text(
                          'Place of Supply: State Code ${invoice.placeOfSupply}',
                          style: const pw.TextStyle(fontSize: 9),
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(width: 40),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'DISPATCH DETAILS:',
                        style: pw.TextStyle(
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.grey700,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Supply Type: ${invoice.supplyType}',
                        style: const pw.TextStyle(fontSize: 9),
                      ),
                      pw.Text(
                        'GST Type: ${invoice.isInterstate ? "Interstate (IGST)" : "Intrastate (CGST+SGST)"}',
                        style: const pw.TextStyle(fontSize: 9),
                      ),
                      pw.Text(
                        'Reverse Charge: N/A (No)',
                        style: const pw.TextStyle(fontSize: 9),
                      ),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 20),

              // Items Table
              pw.TableHelper.fromTextArray(
                context: context,
                border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
                headers: [
                  '#',
                  'Description',
                  'HSN',
                  'Qty',
                  'Rate',
                  'Taxable Value',
                  'GST Rate',
                  'GST Amount',
                  'Total Amount',
                ],
                data: List<List<String>>.generate(items.length, (index) {
                  final item = items[index];
                  final gstRatePct = '${(item.gstRate * 100).toStringAsFixed(0)}%';
                  return [
                    (index + 1).toString(),
                    item.description,
                    item.hsnCode,
                    '${item.quantity.toStringAsFixed(1)} ${item.unit}',
                    currencyFmt.format(item.rate),
                    currencyFmt.format(item.taxableAmount),
                    gstRatePct,
                    currencyFmt.format(item.totalTax),
                    currencyFmt.format(item.totalAmount),
                  ];
                }),
              ),

              pw.SizedBox(height: 16),

              // Totals Block
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'TERMS & CONDITIONS:',
                        style: pw.TextStyle(
                          fontSize: 8,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.grey700,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        '1. Interest @ 18% p.a. will be charged for payments delayed beyond credit period.\n'
                        '2. All disputes are subject to Mumbai Jurisdiction.\n'
                        '3. Delivery bowser log sheets are the final proof of fuel discharged.',
                        style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey800),
                      ),
                      pw.SizedBox(height: 12),
                      pw.Text(
                        'BANK PAYMENT DETAILS:',
                        style: pw.TextStyle(
                          fontSize: 8,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.grey700,
                        ),
                      ),
                      pw.Text(
                        'Bank: HDFC Bank Limited\nA/C No: 50100489768976\nIFSC: HDFC0000012 • Branch: Vashi',
                        style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey800),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Row(
                        children: [
                          pw.Text('Subtotal (Taxable Value):  ', style: const pw.TextStyle(fontSize: 10)),
                          pw.Text('₹${currencyFmt.format(invoice.subtotal)}', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                        ],
                      ),
                      if (!invoice.isInterstate) ...[
                        pw.SizedBox(height: 4),
                        pw.Row(
                          children: [
                            pw.Text('CGST:  ', style: const pw.TextStyle(fontSize: 9)),
                            pw.Text('₹${currencyFmt.format(invoice.cgstAmount)}', style: const pw.TextStyle(fontSize: 9)),
                          ],
                        ),
                        pw.SizedBox(height: 2),
                        pw.Row(
                          children: [
                            pw.Text('SGST:  ', style: const pw.TextStyle(fontSize: 9)),
                            pw.Text('₹${currencyFmt.format(invoice.sgstAmount)}', style: const pw.TextStyle(fontSize: 9)),
                          ],
                        ),
                      ] else ...[
                        pw.SizedBox(height: 4),
                        pw.Row(
                          children: [
                            pw.Text('IGST:  ', style: const pw.TextStyle(fontSize: 9)),
                            pw.Text('₹${currencyFmt.format(invoice.igstAmount)}', style: const pw.TextStyle(fontSize: 9)),
                          ],
                        ),
                      ],
                      pw.Divider(thickness: 0.5, color: PdfColors.grey400),
                      pw.Row(
                        children: [
                          pw.Text('Total Amount (Incl. GST):  ', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                          pw.Text('₹${currencyFmt.format(invoice.totalAmount)}', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey900)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),

              pw.Spacer(),

              // Footer Block
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Container(
                        width: 60,
                        height: 60,
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: PdfColors.grey400, width: 0.5),
                        ),
                        alignment: pw.Alignment.center,
                        child: pw.Text('QR CODE\nPLACEHOLDER', style: const pw.TextStyle(fontSize: 6), textAlign: pw.TextAlign.center),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text('IRN / E-Way Bill Placeholder', style: const pw.TextStyle(fontSize: 6)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('For STEP UP FUELS', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 30),
                      pw.Text('Authorized Signatory & Seal', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static Future<void> printInvoice({
    required Invoice invoice,
    required List<InvoiceItem> items,
    required Customer customer,
  }) async {
    final pdfBytes = await generatePdf(
      invoice: invoice,
      items: items,
      customer: customer,
      isDuplicate: false,
    );
    await Printing.layoutPdf(
      onLayout: (format) => pdfBytes,
      name: 'invoice_${invoice.invoiceNumber}.pdf',
    );
  }

  static Future<void> downloadInvoice({
    required Invoice invoice,
    required List<InvoiceItem> items,
    required Customer customer,
  }) async {
    final pdfBytes = await generatePdf(
      invoice: invoice,
      items: items,
      customer: customer,
      isDuplicate: false,
    );
    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: 'invoice_${invoice.invoiceNumber}.pdf',
    );
  }
}

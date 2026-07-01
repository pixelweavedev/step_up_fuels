import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfReportGenerator {
  static Future<Uint8List> generateGenericReport({
    required String title,
    required String subtitle,
    required List<String> headers,
    required List<List<String>> rows,
    Map<String, String>? summaryStats,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // Company Header
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'STEP UP FUELS',
                    style: pw.TextStyle(
                      fontSize: 22,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColor.fromHex('#102A43'),
                    ),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    'Indian Fuel Distribution ERP & Logistics',
                    style: pw.TextStyle(
                      fontSize: 10,
                      color: PdfColor.fromHex('#627D98'),
                    ),
                  ),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    'Date: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
                    style: pw.TextStyle(fontSize: 10, color: PdfColor.fromHex('#627D98')),
                  ),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 12),
          pw.Divider(thickness: 1.5, color: PdfColor.fromHex('#D9E2EC')),
          pw.SizedBox(height: 16),

          // Report Title
          pw.Text(
            title.toUpperCase(),
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromHex('#102A43'),
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            subtitle,
            style: pw.TextStyle(
              fontSize: 11,
              color: PdfColor.fromHex('#486581'),
            ),
          ),
          pw.SizedBox(height: 20),

          // Summary Stats Banner
          if (summaryStats != null && summaryStats.isNotEmpty) ...[
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#F0F4F8'),
                borderRadius: pw.BorderRadius.circular(6),
                border: pw.Border.all(color: PdfColor.fromHex('#D9E2EC')),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: summaryStats.entries.map((entry) {
                  return pw.Column(
                    children: [
                      pw.Text(
                        entry.key.toUpperCase(),
                        style: pw.TextStyle(fontSize: 9, color: PdfColor.fromHex('#627D98'), fontWeight: pw.FontWeight.bold),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        entry.value,
                        style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#102A43')),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
            pw.SizedBox(height: 24),
          ],

          // Data Table
          pw.TableHelper.fromTextArray(
            headers: headers,
            data: rows,
            border: pw.TableBorder(
              horizontalInside: pw.BorderSide(color: PdfColor.fromHex('#E4EBF4'), width: 0.8),
            ),
            headerStyle: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
            headerDecoration: pw.BoxDecoration(
              color: PdfColor.fromHex('#102A43'),
              borderRadius: const pw.BorderRadius.only(
                topLeft: pw.Radius.circular(4),
                topRight: pw.Radius.circular(4),
              ),
            ),
            cellStyle: const pw.TextStyle(fontSize: 9),
            cellAlignment: pw.Alignment.centerLeft,
            cellAlignments: {
              // Right align numeric columns (usually ending ones)
              for (var i = 0; i < headers.length; i++)
                if (headers[i].contains('₹') || headers[i].contains('Amt') || headers[i].contains('Val') || headers[i].contains('Quantity'))
                  i: pw.Alignment.centerRight,
            },
            rowDecoration: const pw.BoxDecoration(
              color: PdfColors.white,
            ),
            oddRowDecoration: pw.BoxDecoration(
              color: PdfColor.fromHex('#F8FAFC'),
            ),
          ),
          pw.SizedBox(height: 40),

          // Signatory / Footer Note
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Notes:',
                    style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#486581')),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    'This is a system generated report and does not require a physical signature.',
                    style: pw.TextStyle(fontSize: 8, color: PdfColor.fromHex('#627D98')),
                  ),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Container(
                    width: 120,
                    decoration: pw.BoxDecoration(
                      border: pw.Border(top: pw.BorderSide(color: PdfColor.fromHex('#D9E2EC'))),
                    ),
                    padding: const pw.EdgeInsets.only(top: 4),
                    child: pw.Center(
                      child: pw.Text(
                        'Authorized Signatory',
                        style: pw.TextStyle(fontSize: 9, color: PdfColor.fromHex('#486581')),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
        footer: (context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          margin: const pw.EdgeInsets.only(top: 20),
          child: pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: pw.TextStyle(fontSize: 8, color: PdfColor.fromHex('#9FB3C8')),
          ),
        ),
      ),
    );

    return pdf.save();
  }
}

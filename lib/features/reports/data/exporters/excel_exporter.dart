import 'package:excel/excel.dart';
import 'package:step_up_fuels/features/reports/domain/entities/report_models.dart';

class ExcelExporter {
  static List<int>? exportGstReport(GstReport report) {
    final excel = Excel.createExcel();
    
    // Rename default sheet
    excel.rename('Sheet1', 'B2B Invoices');
    final sheet1 = excel['B2B Invoices'];
    
    // Header styling
    final headerStyle = CellStyle(
      bold: true,
      fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
      backgroundColorHex: ExcelColor.fromHexString('#1A2E40'), // brandNavy color
      fontFamily: getFontFamily(FontFamily.Calibri),
    );

    // Write B2B Header Row
    final headersB2b = [
      'Invoice Number',
      'Invoice Date',
      'Customer Name',
      'GSTIN/UIN of Recipient',
      'Taxable Value (INR)',
      'CGST (INR)',
      'SGST (INR)',
      'IGST (INR)',
      'Total Invoice Value (INR)'
    ];

    for (int col = 0; col < headersB2b.length; col++) {
      final cell = sheet1.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0));
      cell.value = TextCellValue(headersB2b[col]);
      cell.cellStyle = headerStyle;
    }

    // Write B2B Data
    for (int rowIdx = 0; rowIdx < report.b2bInvoices.length; rowIdx++) {
      final data = report.b2bInvoices[rowIdx];
      final colValues = [
        TextCellValue(data.invoiceNumber),
        TextCellValue(data.invoiceDate.toIso8601String().substring(0, 10)),
        TextCellValue(data.customerName),
        TextCellValue(data.customerGstin ?? 'URP'),
        DoubleCellValue(data.taxableValue),
        DoubleCellValue(data.cgstAmount),
        DoubleCellValue(data.sgstAmount),
        DoubleCellValue(data.igstAmount),
        DoubleCellValue(data.totalAmount)
      ];

      for (int col = 0; col < colValues.length; col++) {
        final cell = sheet1.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: rowIdx + 1));
        cell.value = colValues[col];
      }
    }

    // Add HSN Summary Sheet
    final sheet2 = excel['HSN Summary'];
    final headersHsn = [
      'HSN',
      'Description',
      'UQC',
      'Total Quantity',
      'Total Value (INR)',
      'Taxable Value (INR)',
      'CGST (INR)',
      'SGST (INR)',
      'IGST (INR)'
    ];

    for (int col = 0; col < headersHsn.length; col++) {
      final cell = sheet2.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0));
      cell.value = TextCellValue(headersHsn[col]);
      cell.cellStyle = headerStyle;
    }

    // Write HSN Data
    for (int rowIdx = 0; rowIdx < report.hsnSummary.length; rowIdx++) {
      final data = report.hsnSummary[rowIdx];
      final colValues = [
        TextCellValue(data.hsnCode),
        TextCellValue(data.description),
        TextCellValue(data.unit),
        DoubleCellValue(data.totalQuantity),
        DoubleCellValue(data.totalValue),
        DoubleCellValue(data.taxableValue),
        DoubleCellValue(data.cgstAmount),
        DoubleCellValue(data.sgstAmount),
        DoubleCellValue(data.igstAmount)
      ];

      for (int col = 0; col < colValues.length; col++) {
        final cell = sheet2.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: rowIdx + 1));
        cell.value = colValues[col];
      }
    }

    return excel.save();
  }
}

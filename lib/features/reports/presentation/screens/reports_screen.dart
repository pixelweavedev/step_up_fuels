import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:step_up_fuels/core/theme/app_colors.dart';
import 'package:step_up_fuels/features/reports/data/exporters/excel_exporter.dart';
import 'package:step_up_fuels/features/reports/data/exporters/pdf_report_generator.dart';
import 'package:step_up_fuels/features/reports/presentation/providers/reports_provider.dart';
import 'package:step_up_fuels/shared/widgets/empty_states/empty_state_widget.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedType = ref.watch(reportSelectedTypeProvider);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Row(
        children: [
          // Left sidebar for reports menu
          Container(
            width: 280,
            decoration: BoxDecoration(
              border: Border(right: BorderSide(color: AppColors.darkBorder)),
            ),
            child: const _ReportsSidebar(),
          ),

          // Right workspace area
          Expanded(
            child: Column(
              children: [
                _buildFilterHeader(context, ref),
                Divider(color: AppColors.darkBorder, height: 1),
                Expanded(child: _buildReportContent(selectedType)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterHeader(BuildContext context, WidgetRef ref) {
    final selectedType = ref.watch(reportSelectedTypeProvider);
    final fromDate = ref.watch(reportDateFromProvider);
    final toDate = ref.watch(reportDateToProvider);

    // Hide date picker for reports that don't need it (e.g. Stock, Outstanding Aging)
    final needsDateRange =
        selectedType != 'stock' && selectedType != 'outstanding';

    Future<void> selectDateRange() async {
      final DateTimeRange? picked = await showDateRangePicker(
        context: context,
        initialDateRange: DateTimeRange(start: fromDate, end: toDate),
        firstDate: DateTime(2020),
        lastDate: DateTime(2101),
        builder: (context, child) => Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.brandAmber,
              onPrimary: AppColors.brandNavy,
              surface: AppColors.darkSurface,
              onSurface: AppColors.darkTextPrimary,
            ),
          ),
          child: child!,
        ),
      );
      if (picked != null) {
        ref.read(reportDateFromProvider.notifier).state = picked.start;
        ref.read(reportDateToProvider.notifier).state = picked.end;
      }
    }

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getReportTitle(selectedType),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkTextPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _getReportSubtitle(selectedType),
                style: TextStyle(
                  color: AppColors.darkTextSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          Row(
            children: [
              if (needsDateRange) ...[
                OutlinedButton.icon(
                  icon: const Icon(
                    Icons.date_range_rounded,
                    size: 16,
                    color: AppColors.brandAmber,
                  ),
                  label: Text(
                    '${DateFormat('dd MMM yyyy').format(fromDate)} - ${DateFormat('dd MMM yyyy').format(toDate)}',
                    style: TextStyle(color: AppColors.darkTextPrimary),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.darkBorder),
                  ),
                  onPressed: selectDateRange,
                ),
                const SizedBox(width: 16),
              ],
              if (selectedType == 'gst') ...[
                ElevatedButton.icon(
                  icon: const Icon(Icons.table_view_rounded, size: 16),
                  label: const Text('Export Excel (GSTR-1)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => _exportToExcel(context, ref),
                ),
                const SizedBox(width: 12),
              ],
              ElevatedButton.icon(
                icon: const Icon(Icons.picture_as_pdf_rounded, size: 16),
                label: const Text('Print / PDF'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandAmber,
                  foregroundColor: AppColors.brandNavy,
                ),
                onPressed: () => _printPdf(ref),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReportContent(String type) {
    switch (type) {
      case 'sales':
        return const _SalesReportView();
      case 'stock':
        return const _StockReportView();
      case 'expenses':
        return const _ExpenseReportView();
      case 'p&l':
        return const _ProfitLossReportView();
      case 'gst':
        return const _GstReportView();
      case 'outstanding':
        return const _OutstandingReportView();
      case 'purchase':
        return const _PurchaseReportView();
      default:
        return const Center(child: Text('Report not implemented'));
    }
  }

  String _getReportTitle(String type) {
    switch (type) {
      case 'sales':
        return 'Customer-wise Sales Report';
      case 'stock':
        return 'Current Stock Status';
      case 'expenses':
        return 'Expense Breakdown Analysis';
      case 'p&l':
        return 'Profit & Loss Estimate';
      case 'gst':
        return 'GST Compliance GSTR-1';
      case 'outstanding':
        return 'Customer Outstanding Aging';
      case 'purchase':
        return 'Purchase Report Summary';
      default:
        return 'Reports';
    }
  }

  String _getReportSubtitle(String type) {
    switch (type) {
      case 'sales':
        return 'Aggregated sales litres and taxable value';
      case 'stock':
        return 'Current stock levels across storage terminals and bowsers';
      case 'expenses':
        return 'Indirect & operating expenses grouped by category';
      case 'p&l':
        return 'Estimated business profitability based on Sales, COGS & Expenses';
      case 'gst':
        return 'GSTR-1 structured taxable billing returns & HSN summary';
      case 'outstanding':
        return 'Receivables aging categorized by invoice due age';
      case 'purchase':
        return 'Fuel purchases and incoming supply invoices';
      default:
        return 'ERP data visualizer';
    }
  }

  Future<void> _exportToExcel(BuildContext context, WidgetRef ref) async {
    try {
      final gstAsync = ref.read(gstReportProvider);
      final report = gstAsync.value;
      if (report == null) {
        throw Exception('Report data not loaded. Please wait.');
      }

      final bytes = ExcelExporter.exportGstReport(report);
      if (bytes == null) throw Exception('Failed to generate excel bytes');

      // Save file locally in current directory or user downloads
      final dir = await getApplicationDocumentsDirectory();
      final path =
          '${dir.path}/GSTR1_Report_${DateFormat('yyyyMMdd').format(DateTime.now())}.xlsx';
      final file = File(path);
      await file.writeAsBytes(bytes);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Excel exported successfully to: $path'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _printPdf(WidgetRef ref) async {
    final type = ref.read(reportSelectedTypeProvider);
    final fromDate = ref.read(reportDateFromProvider);
    final toDate = ref.read(reportDateToProvider);
    final rangeStr =
        '${DateFormat('dd/MM/yyyy').format(fromDate)} to ${DateFormat('dd/MM/yyyy').format(toDate)}';

    String title = '';
    List<String> headers = [];
    List<List<String>> rows = [];
    Map<String, String> stats = {};

    if (type == 'sales') {
      title = 'Customer-wise Sales Report';
      final data = ref.read(customerWiseSalesProvider).value ?? {};
      headers = [
        'Customer Name',
        'Total Litres',
        'Taxable Val',
        'Total CGST',
        'Total SGST',
        'Grand Total',
        'Outstanding',
      ];
      double totLit = 0;
      double totTax = 0;
      double totVal = 0;
      data.forEach((name, val) {
        totLit += val.totalLitres;
        totTax += val.taxableAmount;
        totVal += val.totalAmount;
        rows.add([
          name,
          '${val.totalLitres.toStringAsFixed(0)} L',
          '₹${val.taxableAmount.toStringAsFixed(2)}',
          '₹${val.cgstAmount.toStringAsFixed(2)}',
          '₹${val.sgstAmount.toStringAsFixed(2)}',
          '₹${val.totalAmount.toStringAsFixed(2)}',
          '₹${val.totalOutstanding.toStringAsFixed(2)}',
        ]);
      });
      stats = {
        'Total Litres': '${totLit.toStringAsFixed(0)} L',
        'Taxable Sales': '₹${totTax.toStringAsFixed(2)}',
        'Grand Total': '₹${totVal.toStringAsFixed(2)}',
      };
    } else if (type == 'stock') {
      title = 'Stock Status Report';
      final data = ref.read(stockReportProvider).value ?? [];
      headers = ['Location', 'Type', 'Product', 'Current Stock'];
      for (final s in data) {
        rows.add([
          s.locationName,
          s.locationType,
          s.productName,
          '${s.currentStock.toStringAsFixed(0)} Ltrs',
        ]);
      }
    } else if (type == 'expenses') {
      title = 'Expense Breakdown';
      final data = ref.read(expenseReportProvider).value ?? {};
      headers = ['Expense Category', 'Total Amount'];
      double total = 0;
      data.forEach((cat, amt) {
        total += amt;
        rows.add([cat.replaceAll('_', ' '), '₹${amt.toStringAsFixed(2)}']);
      });
      stats = {'Total Operating Expenses': '₹${total.toStringAsFixed(2)}'};
    } else if (type == 'p&l') {
      title = 'Profit & Loss Statement';
      final data = ref.read(profitLossEstimateProvider).value;
      if (data != null) {
        headers = ['Account Metric', 'Amount'];
        rows = [
          ['Revenue (Sales Subtotal)', '₹${data.revenue.toStringAsFixed(2)}'],
          [
            'Cost of Fuel Sold (COGS)',
            '- ₹${data.costOfFuelSold.toStringAsFixed(2)}',
          ],
          [
            'Operating Expenses',
            '- ₹${data.operatingExpenses.toStringAsFixed(2)}',
          ],
          [
            'Estimated Net Profit',
            '₹${data.estimatedNetProfit.toStringAsFixed(2)}',
          ],
        ];
        stats = {
          'Revenue': '₹${data.revenue.toStringAsFixed(0)}',
          'Operating Profit': '₹${data.estimatedNetProfit.toStringAsFixed(0)}',
        };
      }
    } else if (type == 'gst') {
      title = 'GSTR-1 Return Data';
      final data = ref.read(gstReportProvider).value;
      if (data != null) {
        headers = [
          'Buyer GSTIN',
          'Invoice No',
          'Date',
          'Taxable Val',
          'CGST',
          'SGST',
          'Total Val',
        ];
        for (final b in data.b2bInvoices) {
          rows.add([
            b.customerGstin ?? 'URP',
            b.invoiceNumber,
            DateFormat('dd/MM/yyyy').format(b.invoiceDate),
            '₹${b.taxableValue.toStringAsFixed(2)}',
            '₹${b.cgstAmount.toStringAsFixed(2)}',
            '₹${b.sgstAmount.toStringAsFixed(2)}',
            '₹${b.totalAmount.toStringAsFixed(2)}',
          ]);
        }
      }
    } else if (type == 'outstanding') {
      title = 'Outstanding Aging Report';
      final data = ref.read(outstandingReportProvider).value ?? [];
      headers = [
        'Customer',
        'Current (0-7d)',
        '8-15d',
        '16-30d',
        '31-45d',
        '45d+',
        'Total Outstanding',
      ];
      double total = 0;
      for (final o in data) {
        total += o.totalOutstanding;
        rows.add([
          o.customerName,
          '₹${o.current.toStringAsFixed(0)}',
          '₹${o.tier1.toStringAsFixed(0)}',
          '₹${o.tier2.toStringAsFixed(0)}',
          '₹${o.tier3.toStringAsFixed(0)}',
          '₹${o.overdue.toStringAsFixed(0)}',
          '₹${o.totalOutstanding.toStringAsFixed(2)}',
        ]);
      }
      stats = {'Total Receivables': '₹${total.toStringAsFixed(2)}'};
    } else if (type == 'purchase') {
      title = 'Purchase Report Summary';
      final data = ref.read(purchaseReportProvider).value ?? [];
      headers = [
        'Supplier Name',
        'Inv No',
        'Date',
        'Subtotal',
        'GST',
        'Total Val',
      ];
      double total = 0;
      for (final p in data) {
        total += p.totalAmount;
        rows.add([
          p.supplierName,
          p.supplierInvoiceNo,
          DateFormat('dd/MM/yyyy').format(p.purchaseDate),
          '₹${p.subtotal.toStringAsFixed(2)}',
          '₹${(p.cgstAmount + p.sgstAmount + p.igstAmount).toStringAsFixed(2)}',
          '₹${p.totalAmount.toStringAsFixed(2)}',
        ]);
      }
      stats = {'Total Purchases': '₹${total.toStringAsFixed(2)}'};
    }

    final pdfBytes = await PdfReportGenerator.generateGenericReport(
      title: title,
      subtitle: 'Statement period: $rangeStr',
      headers: headers,
      rows: rows,
      summaryStats: stats.isNotEmpty ? stats : null,
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdfBytes,
      name: '${title.replaceAll(" ", "_")}_Report.pdf',
    );
  }
}

class _ReportsSidebar extends ConsumerWidget {
  const _ReportsSidebar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedType = ref.watch(reportSelectedTypeProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reports Console',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkTextPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Operational & financial reports',
                style: TextStyle(
                  color: AppColors.darkTextSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Divider(color: AppColors.darkBorder, height: 1),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              _buildSidebarItem(
                ref,
                'sales',
                'Sales Report',
                Icons.trending_up_rounded,
                selectedType,
              ),
              _buildSidebarItem(
                ref,
                'purchase',
                'Purchase Report',
                Icons.shopping_cart_rounded,
                selectedType,
              ),
              _buildSidebarItem(
                ref,
                'stock',
                'Stock status',
                Icons.local_gas_station_rounded,
                selectedType,
              ),
              _buildSidebarItem(
                ref,
                'expenses',
                'Expense Analysis',
                Icons.pie_chart_outline_rounded,
                selectedType,
              ),
              _buildSidebarItem(
                ref,
                'p&l',
                'Profit & Loss',
                Icons.account_balance_rounded,
                selectedType,
              ),
              _buildSidebarItem(
                ref,
                'gst',
                'GSTR-1 GST Return',
                Icons.receipt_long_rounded,
                selectedType,
              ),
              _buildSidebarItem(
                ref,
                'outstanding',
                'Outstanding Aging',
                Icons.timer_outlined,
                selectedType,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSidebarItem(
    WidgetRef ref,
    String type,
    String label,
    IconData icon,
    String current,
  ) {
    final isSelected = type == current;
    return ListTile(
      onTap: () => ref.read(reportSelectedTypeProvider.notifier).state = type,
      selected: isSelected,
      selectedTileColor: AppColors.brandNavyMid,
      leading: Icon(
        icon,
        color: isSelected ? AppColors.brandAmber : AppColors.darkTextSecondary,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? AppColors.brandAmber : AppColors.darkTextPrimary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          fontSize: 14,
        ),
      ),
    );
  }
}

// ── Report Content Tab Views ──────────────────────────────────────────────────

class _SalesReportView extends ConsumerWidget {
  const _SalesReportView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(customerWiseSalesProvider);

    return dataAsync.when(
      data: (map) {
        if (map.isEmpty) {
          return const EmptyStateWidget(
            title: 'No sales found',
            subtitle: 'Modify date range parameters.',
            icon: Icons.trending_up_rounded,
          );
        }
        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            DataTable(
              headingRowColor: WidgetStateProperty.all(AppColors.brandNavy),
              columns: const [
                DataColumn(
                  label: Text(
                    'Customer',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Quantity',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Taxable Val',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'CGST',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'SGST',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Total Amount',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Outstanding',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
              rows: map.entries.map((e) {
                return DataRow(
                  cells: [
                    DataCell(
                      Text(
                        e.key,
                        style: TextStyle(color: AppColors.darkTextPrimary),
                      ),
                    ),
                    DataCell(
                      Text(
                        '${e.value.totalLitres.toStringAsFixed(0)} L',
                        style: TextStyle(color: AppColors.darkTextPrimary),
                      ),
                    ),
                    DataCell(
                      Text(
                        '₹${e.value.taxableAmount.toStringAsFixed(2)}',
                        style: TextStyle(color: AppColors.darkTextPrimary),
                      ),
                    ),
                    DataCell(
                      Text(
                        '₹${e.value.cgstAmount.toStringAsFixed(2)}',
                        style: TextStyle(color: AppColors.darkTextPrimary),
                      ),
                    ),
                    DataCell(
                      Text(
                        '₹${e.value.sgstAmount.toStringAsFixed(2)}',
                        style: TextStyle(color: AppColors.darkTextPrimary),
                      ),
                    ),
                    DataCell(
                      Text(
                        '₹${e.value.totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: AppColors.brandAmber,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        '₹${e.value.totalOutstanding.toStringAsFixed(2)}',
                        style: const TextStyle(color: AppColors.error),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.brandAmber),
      ),
      error: (e, _) => Center(
        child: Text(
          e.toString(),
          style: const TextStyle(color: AppColors.error),
        ),
      ),
    );
  }
}

class _PurchaseReportView extends ConsumerWidget {
  const _PurchaseReportView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(purchaseReportProvider);

    return dataAsync.when(
      data: (list) {
        if (list.isEmpty) {
          return const EmptyStateWidget(
            title: 'No purchases found',
            subtitle: 'Modify date range parameters.',
            icon: Icons.shopping_cart_rounded,
          );
        }
        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            DataTable(
              headingRowColor: WidgetStateProperty.all(AppColors.brandNavy),
              columns: const [
                DataColumn(
                  label: Text(
                    'Supplier',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Inv No',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Date',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Subtotal',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'GST',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Total Amount',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
              rows: list.map((p) {
                return DataRow(
                  cells: [
                    DataCell(
                      Text(
                        p.supplierName,
                        style: TextStyle(color: AppColors.darkTextPrimary),
                      ),
                    ),
                    DataCell(
                      Text(
                        p.supplierInvoiceNo,
                        style: TextStyle(color: AppColors.darkTextPrimary),
                      ),
                    ),
                    DataCell(
                      Text(
                        DateFormat('dd/MM/yyyy').format(p.purchaseDate),
                        style: TextStyle(color: AppColors.darkTextPrimary),
                      ),
                    ),
                    DataCell(
                      Text(
                        '₹${p.subtotal.toStringAsFixed(2)}',
                        style: TextStyle(color: AppColors.darkTextPrimary),
                      ),
                    ),
                    DataCell(
                      Text(
                        '₹${(p.cgstAmount + p.sgstAmount + p.igstAmount).toStringAsFixed(2)}',
                        style: TextStyle(color: AppColors.darkTextPrimary),
                      ),
                    ),
                    DataCell(
                      Text(
                        '₹${p.totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: AppColors.brandAmber,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.brandAmber),
      ),
      error: (e, _) => Center(
        child: Text(
          e.toString(),
          style: const TextStyle(color: AppColors.error),
        ),
      ),
    );
  }
}

class _StockReportView extends ConsumerWidget {
  const _StockReportView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(stockReportProvider);

    return dataAsync.when(
      data: (list) {
        if (list.isEmpty) {
          return const EmptyStateWidget(
            title: 'No stock details',
            subtitle: 'Define storage locations first.',
            icon: Icons.local_gas_station_rounded,
          );
        }
        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            DataTable(
              headingRowColor: WidgetStateProperty.all(AppColors.brandNavy),
              columns: const [
                DataColumn(
                  label: Text(
                    'Location Name',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Type',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Fuel Product',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Current Stock',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
              rows: list.map((s) {
                return DataRow(
                  cells: [
                    DataCell(
                      Text(
                        s.locationName,
                        style: TextStyle(color: AppColors.darkTextPrimary),
                      ),
                    ),
                    DataCell(
                      Text(
                        s.locationType,
                        style: TextStyle(color: AppColors.darkTextPrimary),
                      ),
                    ),
                    DataCell(
                      Text(
                        s.productName,
                        style: TextStyle(color: AppColors.darkTextPrimary),
                      ),
                    ),
                    DataCell(
                      Text(
                        '${s.currentStock.toStringAsFixed(0)} Ltrs',
                        style: TextStyle(
                          color: s.currentStock < 500
                              ? AppColors.error
                              : AppColors.brandAmber,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.brandAmber),
      ),
      error: (e, _) => Center(
        child: Text(
          e.toString(),
          style: const TextStyle(color: AppColors.error),
        ),
      ),
    );
  }
}

class _ExpenseReportView extends ConsumerWidget {
  const _ExpenseReportView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(expenseReportProvider);

    return dataAsync.when(
      data: (map) {
        if (map.isEmpty) {
          return const EmptyStateWidget(
            title: 'No expenses found',
            subtitle: 'Create operating expenses first.',
            icon: Icons.pie_chart_outline_rounded,
          );
        }
        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            DataTable(
              headingRowColor: WidgetStateProperty.all(AppColors.brandNavy),
              columns: const [
                DataColumn(
                  label: Text(
                    'Expense Category',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Total Value',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
              rows: map.entries.map((e) {
                return DataRow(
                  cells: [
                    DataCell(
                      Text(
                        e.key.replaceAll('_', ' '),
                        style: TextStyle(color: AppColors.darkTextPrimary),
                      ),
                    ),
                    DataCell(
                      Text(
                        '₹${e.value.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: AppColors.brandAmber,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.brandAmber),
      ),
      error: (e, _) => Center(
        child: Text(
          e.toString(),
          style: const TextStyle(color: AppColors.error),
        ),
      ),
    );
  }
}

class _ProfitLossReportView extends ConsumerWidget {
  const _ProfitLossReportView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(profitLossEstimateProvider);

    return dataAsync.when(
      data: (pl) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 500,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.darkSurface,
                  border: Border.all(color: AppColors.darkBorder),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Profit & Loss Summary',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildPlRow(
                      'Revenue (Sales Subtotal)',
                      pl.revenue,
                      isPositive: true,
                    ),
                    Divider(color: AppColors.darkBorder),
                    _buildPlRow(
                      'Cost of Fuel Sold (COGS)',
                      pl.costOfFuelSold,
                      isPositive: false,
                    ),
                    Divider(color: AppColors.darkBorder),
                    _buildPlRow(
                      'Operating Expenses',
                      pl.operatingExpenses,
                      isPositive: false,
                    ),
                    Divider(color: AppColors.darkBorder, thickness: 1.5),
                    const SizedBox(height: 8),
                    _buildPlRow(
                      'Estimated Net Profit',
                      pl.estimatedNetProfit,
                      isPositive: pl.estimatedNetProfit >= 0,
                      isTotal: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.brandAmber),
      ),
      error: (e, _) => Center(
        child: Text(
          e.toString(),
          style: const TextStyle(color: AppColors.error),
        ),
      ),
    );
  }

  Widget _buildPlRow(
    String label,
    double val, {
    required bool isPositive,
    bool isTotal = false,
  }) {
    final style = TextStyle(
      fontSize: isTotal ? 16 : 14,
      fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
      color: isTotal
          ? (val >= 0 ? AppColors.success : AppColors.error)
          : AppColors.darkTextPrimary,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal
                  ? AppColors.darkTextPrimary
                  : AppColors.darkTextSecondary,
            ),
          ),
          Text(
            '${isPositive ? "" : "- "}₹${val.abs().toStringAsFixed(2)}',
            style: style,
          ),
        ],
      ),
    );
  }
}

class _GstReportView extends ConsumerWidget {
  const _GstReportView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(gstReportProvider);

    return dataAsync.when(
      data: (report) {
        if (report.b2bInvoices.isEmpty && report.hsnSummary.isEmpty) {
          return const EmptyStateWidget(
            title: 'No GST returns data',
            subtitle: 'Modify date range parameters.',
            icon: Icons.receipt_long_rounded,
          );
        }

        return DefaultTabController(
          length: 2,
          child: Column(
            children: [
              TabBar(
                indicatorColor: AppColors.brandAmber,
                labelColor: AppColors.brandAmber,
                unselectedLabelColor: AppColors.darkTextSecondary,
                tabs: const [
                  Tab(text: 'B2B Invoices (GSTR-1)'),
                  Tab(text: 'HSN Summary (GSTR-1)'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    // B2B Invoices Tab
                    report.b2bInvoices.isEmpty
                        ? Center(
                            child: Text(
                              'No registered B2B invoice returns',
                              style: TextStyle(
                                color: AppColors.darkTextTertiary,
                              ),
                            ),
                          )
                        : ListView(
                            padding: const EdgeInsets.all(24),
                            children: [
                              DataTable(
                                headingRowColor: WidgetStateProperty.all(
                                  AppColors.brandNavy,
                                ),
                                columns: const [
                                  DataColumn(
                                    label: Text(
                                      'GSTIN',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Invoice No',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Date',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Taxable Val',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'CGST',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'SGST',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Grand Total',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                                rows: report.b2bInvoices.map((b) {
                                  return DataRow(
                                    cells: [
                                      DataCell(
                                        Text(
                                          b.customerGstin ?? 'URP',
                                          style: TextStyle(
                                            color: AppColors.darkTextPrimary,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          b.invoiceNumber,
                                          style: TextStyle(
                                            color: AppColors.darkTextPrimary,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          DateFormat(
                                            'dd/MM/yyyy',
                                          ).format(b.invoiceDate),
                                          style: TextStyle(
                                            color: AppColors.darkTextPrimary,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          '₹${b.taxableValue.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            color: AppColors.darkTextPrimary,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          '₹${b.cgstAmount.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            color: AppColors.darkTextPrimary,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          '₹${b.sgstAmount.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            color: AppColors.darkTextPrimary,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          '₹${b.totalAmount.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            color: AppColors.brandAmber,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ],
                          ),

                    // HSN Summary Tab
                    report.hsnSummary.isEmpty
                        ? Center(
                            child: Text(
                              'No HSN summaries found',
                              style: TextStyle(
                                color: AppColors.darkTextTertiary,
                              ),
                            ),
                          )
                        : ListView(
                            padding: const EdgeInsets.all(24),
                            children: [
                              DataTable(
                                headingRowColor: WidgetStateProperty.all(
                                  AppColors.brandNavy,
                                ),
                                columns: const [
                                  DataColumn(
                                    label: Text(
                                      'HSN',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Description',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'UQC',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Total Qty',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Taxable Val',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'CGST',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'SGST',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Total Value',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                                rows: report.hsnSummary.map((h) {
                                  return DataRow(
                                    cells: [
                                      DataCell(
                                        Text(
                                          h.hsnCode,
                                          style: TextStyle(
                                            color: AppColors.darkTextPrimary,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          h.description,
                                          style: TextStyle(
                                            color: AppColors.darkTextPrimary,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          h.unit,
                                          style: TextStyle(
                                            color: AppColors.darkTextPrimary,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          h.totalQuantity.toStringAsFixed(0),
                                          style: TextStyle(
                                            color: AppColors.darkTextPrimary,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          '₹${h.taxableValue.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            color: AppColors.darkTextPrimary,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          '₹${h.cgstAmount.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            color: AppColors.darkTextPrimary,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          '₹${h.sgstAmount.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            color: AppColors.darkTextPrimary,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          '₹${h.totalValue.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            color: AppColors.brandAmber,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.brandAmber),
      ),
      error: (e, _) => Center(
        child: Text(
          e.toString(),
          style: const TextStyle(color: AppColors.error),
        ),
      ),
    );
  }
}

class _OutstandingReportView extends ConsumerWidget {
  const _OutstandingReportView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(outstandingReportProvider);

    return dataAsync.when(
      data: (list) {
        if (list.isEmpty) {
          return const EmptyStateWidget(
            title: 'No outstanding balances',
            subtitle: 'All customer balances are fully paid.',
            icon: Icons.timer_outlined,
          );
        }
        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            DataTable(
              headingRowColor: WidgetStateProperty.all(AppColors.brandNavy),
              columns: const [
                DataColumn(
                  label: Text(
                    'Customer',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Current (0-7d)',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    '8-15d',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    '16-30d',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    '31-45d',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    '45d+',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Total Outstanding',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
              rows: list.map((o) {
                return DataRow(
                  cells: [
                    DataCell(
                      Text(
                        o.customerName,
                        style: TextStyle(color: AppColors.darkTextPrimary),
                      ),
                    ),
                    DataCell(
                      Text(
                        '₹${o.current.toStringAsFixed(0)}',
                        style: TextStyle(color: AppColors.darkTextPrimary),
                      ),
                    ),
                    DataCell(
                      Text(
                        '₹${o.tier1.toStringAsFixed(0)}',
                        style: TextStyle(color: AppColors.darkTextPrimary),
                      ),
                    ),
                    DataCell(
                      Text(
                        '₹${o.tier2.toStringAsFixed(0)}',
                        style: TextStyle(color: AppColors.darkTextPrimary),
                      ),
                    ),
                    DataCell(
                      Text(
                        '₹${o.tier3.toStringAsFixed(0)}',
                        style: TextStyle(color: AppColors.darkTextPrimary),
                      ),
                    ),
                    DataCell(
                      Text(
                        '₹${o.overdue.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: o.overdue > 0
                              ? AppColors.error
                              : AppColors.darkTextPrimary,
                          fontWeight: o.overdue > 0 ? FontWeight.bold : null,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        '₹${o.totalOutstanding.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: AppColors.brandAmber,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.brandAmber),
      ),
      error: (e, _) => Center(
        child: Text(
          e.toString(),
          style: const TextStyle(color: AppColors.error),
        ),
      ),
    );
  }
}

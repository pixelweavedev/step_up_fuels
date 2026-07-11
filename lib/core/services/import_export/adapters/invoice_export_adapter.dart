import 'package:intl/intl.dart';
import 'package:step_up_fuels/app/di/injection_container.dart';
import 'package:step_up_fuels/core/services/import_export/models/export_adapter.dart';
import 'package:step_up_fuels/core/services/import_export/models/export_column.dart';
import 'package:step_up_fuels/core/services/import_export/models/export_filter.dart';
import 'package:step_up_fuels/core/services/import_export/models/import_result.dart';
import 'package:step_up_fuels/features/invoices/application/usecases/get_invoices_usecase.dart';
import 'package:step_up_fuels/features/invoices/domain/entities/invoice.dart';

class InvoiceExportAdapter extends ExportAdapter<Invoice> {
  @override
  String get entityName => 'invoices';

  @override
  String get entityLabel => 'Invoices';

  @override
  String get entityEmoji => '🧾';

  @override
  String get gradientStart => '#7C3AED';

  @override
  String get gradientEnd => '#5B21B6';

  @override
  bool get supportsImport => false; // Audit-sensitive — export only

  @override
  bool get supportsReport => true;

  @override
  List<ExportColumn<Invoice>> get dataColumns => [
    ExportColumn<Invoice>(
      key: 'invoice_number',
      label: 'Invoice No.',
      getValue: (i) => i.invoiceNumber,
    ),
    ExportColumn<Invoice>(
      key: 'invoice_date',
      label: 'Invoice Date',
      getValue: (i) => DateFormat('dd/MM/yyyy').format(i.invoiceDate),
      getRawValue: (i) => i.invoiceDate,
      type: ColumnType.date,
    ),
    ExportColumn<Invoice>(
      key: 'customer_id',
      label: 'Customer ID',
      getValue: (i) => i.customerId,
      defaultVisible: false,
    ),
    ExportColumn<Invoice>(
      key: 'due_date',
      label: 'Due Date',
      getValue: (i) => DateFormat('dd/MM/yyyy').format(i.dueDate),
      getRawValue: (i) => i.dueDate,
      type: ColumnType.date,
    ),
    ExportColumn<Invoice>(
      key: 'status',
      label: 'Status',
      getValue: (i) => i.status.displayName,
    ),
    ExportColumn<Invoice>(
      key: 'supply_type',
      label: 'Supply Type',
      getValue: (i) => i.supplyType,
      defaultVisible: false,
    ),
    ExportColumn<Invoice>(
      key: 'taxable_amount',
      label: 'Taxable Amount',
      getValue: (i) => i.subtotal.toStringAsFixed(2),
      getRawValue: (i) => i.subtotal,
      type: ColumnType.currency,
    ),
    ExportColumn<Invoice>(
      key: 'cgst_amount',
      label: 'CGST',
      getValue: (i) => i.cgstAmount.toStringAsFixed(2),
      getRawValue: (i) => i.cgstAmount,
      type: ColumnType.currency,
      defaultVisible: false,
    ),
    ExportColumn<Invoice>(
      key: 'sgst_amount',
      label: 'SGST',
      getValue: (i) => i.sgstAmount.toStringAsFixed(2),
      getRawValue: (i) => i.sgstAmount,
      type: ColumnType.currency,
      defaultVisible: false,
    ),
    ExportColumn<Invoice>(
      key: 'igst_amount',
      label: 'IGST',
      getValue: (i) => i.igstAmount.toStringAsFixed(2),
      getRawValue: (i) => i.igstAmount,
      type: ColumnType.currency,
      defaultVisible: false,
    ),
    ExportColumn<Invoice>(
      key: 'total_amount',
      label: 'Total Amount',
      getValue: (i) => i.totalAmount.toStringAsFixed(2),
      getRawValue: (i) => i.totalAmount,
      type: ColumnType.currency,
    ),
    ExportColumn<Invoice>(
      key: 'paid_amount',
      label: 'Paid Amount',
      getValue: (i) => i.amountPaid.toStringAsFixed(2),
      getRawValue: (i) => i.amountPaid,
      type: ColumnType.currency,
    ),
    ExportColumn<Invoice>(
      key: 'outstanding_amount',
      label: 'Outstanding',
      getValue: (i) => i.outstanding.toStringAsFixed(2),
      getRawValue: (i) => i.outstanding,
      type: ColumnType.currency,
    ),
    ExportColumn<Invoice>(
      key: 'place_of_supply',
      label: 'Place of Supply',
      getValue: (i) => i.placeOfSupply,
      defaultVisible: false,
    ),
    ExportColumn<Invoice>(
      key: 'notes',
      label: 'Notes',
      getValue: (i) => i.notes ?? '',
      defaultVisible: false,
    ),
    ExportColumn<Invoice>(
      key: 'created_at',
      label: 'Created At',
      getValue: (i) => DateFormat('dd/MM/yyyy').format(i.createdAt),
      getRawValue: (i) => i.createdAt,
      type: ColumnType.date,
      defaultVisible: false,
    ),
  ];

  @override
  Future<List<Invoice>> fetchData(ExportFilter filter) async {
    final useCase = sl<GetInvoicesUseCase>();
    final status = filter.status != null
        ? InvoiceStatus.values.firstWhere(
            (s) => s.name.toLowerCase() == filter.status!.toLowerCase(),
            orElse: () => InvoiceStatus.posted,
          )
        : null;
    final result = await useCase(
      status: status,
      customerId: filter.customerId,
      fromDate: filter.dateFrom,
      toDate: filter.dateTo,
    );
    return result.when(
      success: (list) {
        if (filter.outstandingOnly) {
          return list.where((i) => i.outstanding > 0).toList();
        }
        return list;
      },
      failure: (f) => throw Exception(f.userMessage),
    );
  }

  @override
  Map<String, dynamic> toJson(Invoice i) => {
    'id': i.id,
    'invoice_number': i.invoiceNumber,
    'customer_id': i.customerId,
    'customer_site_id': i.customerSiteId,
    'invoice_date': i.invoiceDate.toIso8601String(),
    'due_date': i.dueDate.toIso8601String(),
    'supply_type': i.supplyType,
    'status': i.status.toDbString(),
    'taxable_amount': i.subtotal,
    'cgst_amount': i.cgstAmount,
    'sgst_amount': i.sgstAmount,
    'igst_amount': i.igstAmount,
    'total_amount': i.totalAmount,
    'paid_amount': i.amountPaid,
    'outstanding_amount': i.outstanding,
    'place_of_supply': i.placeOfSupply,
    'notes': i.notes,
    'created_at': i.createdAt.toIso8601String(),
    'updated_at': i.updatedAt.toIso8601String(),
  };

  @override
  Invoice? fromJson(Map<String, dynamic> json) => null;

  @override
  List<ValidationError> validateRow(Map<String, dynamic> json) => [];
}

import 'package:intl/intl.dart';
import 'package:step_up_fuels/app/di/injection_container.dart';
import 'package:step_up_fuels/core/services/import_export/models/export_adapter.dart';
import 'package:step_up_fuels/core/services/import_export/models/export_column.dart';
import 'package:step_up_fuels/core/services/import_export/models/export_filter.dart';
import 'package:step_up_fuels/core/services/import_export/models/import_result.dart';
import 'package:step_up_fuels/features/purchases/application/usecases/get_purchases_usecase.dart';
import 'package:step_up_fuels/features/purchases/domain/entities/fuel_purchase.dart';

class PurchaseExportAdapter extends ExportAdapter<FuelPurchase> {
  @override
  String get entityName => 'purchases';

  @override
  String get entityLabel => 'Purchases';

  @override
  String get entityEmoji => '🛒';

  @override
  String get gradientStart => '#F59E0B';

  @override
  String get gradientEnd => '#D97706';

  @override
  bool get supportsImport => false;

  @override
  bool get supportsReport => true;

  @override
  List<ExportColumn<FuelPurchase>> get dataColumns => [
        ExportColumn<FuelPurchase>(
          key: 'purchase_number',
          label: 'Purchase No.',
          getValue: (p) => p.purchaseNumber,
        ),
        ExportColumn<FuelPurchase>(
          key: 'supplier_id',
          label: 'Supplier ID',
          getValue: (p) => p.supplierId,
          defaultVisible: false,
        ),
        ExportColumn<FuelPurchase>(
          key: 'supplier_invoice_no',
          label: 'Supplier Invoice No.',
          getValue: (p) => p.supplierInvoiceNo,
        ),
        ExportColumn<FuelPurchase>(
          key: 'purchase_date',
          label: 'Purchase Date',
          getValue: (p) => DateFormat('dd/MM/yyyy').format(p.purchaseDate),
          getRawValue: (p) => p.purchaseDate,
          type: ColumnType.date,
        ),
        ExportColumn<FuelPurchase>(
          key: 'subtotal',
          label: 'Subtotal',
          getValue: (p) => p.subtotal.toStringAsFixed(2),
          getRawValue: (p) => p.subtotal,
          type: ColumnType.currency,
        ),
        ExportColumn<FuelPurchase>(
          key: 'cgst_amount',
          label: 'CGST',
          getValue: (p) => p.cgstAmount.toStringAsFixed(2),
          getRawValue: (p) => p.cgstAmount,
          type: ColumnType.currency,
          defaultVisible: false,
        ),
        ExportColumn<FuelPurchase>(
          key: 'sgst_amount',
          label: 'SGST',
          getValue: (p) => p.sgstAmount.toStringAsFixed(2),
          getRawValue: (p) => p.sgstAmount,
          type: ColumnType.currency,
          defaultVisible: false,
        ),
        ExportColumn<FuelPurchase>(
          key: 'igst_amount',
          label: 'IGST',
          getValue: (p) => p.igstAmount.toStringAsFixed(2),
          getRawValue: (p) => p.igstAmount,
          type: ColumnType.currency,
          defaultVisible: false,
        ),
        ExportColumn<FuelPurchase>(
          key: 'total_amount',
          label: 'Total Amount',
          getValue: (p) => p.totalAmount.toStringAsFixed(2),
          getRawValue: (p) => p.totalAmount,
          type: ColumnType.currency,
        ),
        ExportColumn<FuelPurchase>(
          key: 'payment_status',
          label: 'Payment Status',
          getValue: (p) => p.paymentStatus,
        ),
        ExportColumn<FuelPurchase>(
          key: 'notes',
          label: 'Notes',
          getValue: (p) => p.notes ?? '',
          defaultVisible: false,
        ),
        ExportColumn<FuelPurchase>(
          key: 'created_at',
          label: 'Created At',
          getValue: (p) => DateFormat('dd/MM/yyyy').format(p.createdAt),
          getRawValue: (p) => p.createdAt,
          type: ColumnType.date,
          defaultVisible: false,
        ),
      ];

  @override
  Future<List<FuelPurchase>> fetchData(ExportFilter filter) async {
    final useCase = sl<GetPurchasesUseCase>();
    final result = await useCase(
      supplierId: filter.customerId, // Uses customerId filter field as supplierId filter
      fromDate: filter.dateFrom,
      toDate: filter.dateTo,
    );
    return result.when(
      success: (list) {
        var filtered = list;
        if (filter.status != null) {
          filtered = filtered.where((p) => p.paymentStatus.toLowerCase() == filter.status!.toLowerCase()).toList();
        }
        return filtered;
      },
      failure: (f) => throw Exception(f.userMessage),
    );
  }

  @override
  Map<String, dynamic> toJson(FuelPurchase p) => {
        'id': p.id,
        'purchase_number': p.purchaseNumber,
        'supplier_id': p.supplierId,
        'supplier_invoice_no': p.supplierInvoiceNo,
        'purchase_date': p.purchaseDate.toIso8601String(),
        'subtotal': p.subtotal,
        'cgst_amount': p.cgstAmount,
        'sgst_amount': p.sgstAmount,
        'igst_amount': p.igstAmount,
        'total_amount': p.totalAmount,
        'payment_status': p.paymentStatus,
        'notes': p.notes,
        'created_at': p.createdAt.toIso8601String(),
        'updated_at': p.updatedAt.toIso8601String(),
      };

  @override
  FuelPurchase? fromJson(Map<String, dynamic> json) => null;

  @override
  List<ValidationError> validateRow(Map<String, dynamic> json) => [];
}

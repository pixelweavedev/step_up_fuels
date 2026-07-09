import 'package:intl/intl.dart';
import 'package:step_up_fuels/app/di/injection_container.dart';
import 'package:step_up_fuels/core/services/import_export/models/export_adapter.dart';
import 'package:step_up_fuels/core/services/import_export/models/export_column.dart';
import 'package:step_up_fuels/core/services/import_export/models/export_filter.dart';
import 'package:step_up_fuels/core/services/import_export/models/import_result.dart';
import 'package:step_up_fuels/features/payments/domain/entities/payment.dart';
import 'package:step_up_fuels/features/payments/domain/repositories/payment_repository.dart';

class PaymentExportAdapter extends ExportAdapter<Payment> {
  @override
  String get entityName => 'payments';

  @override
  String get entityLabel => 'Payments';

  @override
  String get entityEmoji => '💳';

  @override
  String get gradientStart => '#10B981';

  @override
  String get gradientEnd => '#059669';

  @override
  bool get supportsImport => false;

  @override
  bool get supportsReport => true;

  @override
  List<ExportColumn<Payment>> get dataColumns => [
        ExportColumn<Payment>(
          key: 'payment_number',
          label: 'Payment No.',
          getValue: (p) => p.paymentNumber,
        ),
        ExportColumn<Payment>(
          key: 'customer_id',
          label: 'Customer ID',
          getValue: (p) => p.customerId,
          defaultVisible: false,
        ),
        ExportColumn<Payment>(
          key: 'invoice_id',
          label: 'Invoice ID',
          getValue: (p) => p.invoiceId ?? '',
          defaultVisible: false,
        ),
        ExportColumn<Payment>(
          key: 'amount',
          label: 'Amount',
          getValue: (p) => p.amount.toStringAsFixed(2),
          getRawValue: (p) => p.amount,
          type: ColumnType.currency,
        ),
        ExportColumn<Payment>(
          key: 'payment_date',
          label: 'Payment Date',
          getValue: (p) => DateFormat('dd/MM/yyyy').format(p.paymentDate),
          getRawValue: (p) => p.paymentDate,
          type: ColumnType.date,
        ),
        ExportColumn<Payment>(
          key: 'payment_mode',
          label: 'Mode',
          getValue: (p) => p.paymentMode,
        ),
        ExportColumn<Payment>(
          key: 'reference_number',
          label: 'Ref No.',
          getValue: (p) => p.referenceNumber ?? '',
        ),
        ExportColumn<Payment>(
          key: 'bank_name',
          label: 'Bank Name',
          getValue: (p) => p.bankName ?? '',
          defaultVisible: false,
        ),
        ExportColumn<Payment>(
          key: 'notes',
          label: 'Notes',
          getValue: (p) => p.notes ?? '',
          defaultVisible: false,
        ),
        ExportColumn<Payment>(
          key: 'status',
          label: 'Status',
          getValue: (p) => p.status.displayName,
        ),
        ExportColumn<Payment>(
          key: 'created_at',
          label: 'Created At',
          getValue: (p) => DateFormat('dd/MM/yyyy').format(p.createdAt),
          getRawValue: (p) => p.createdAt,
          type: ColumnType.date,
          defaultVisible: false,
        ),
      ];

  @override
  Future<List<Payment>> fetchData(ExportFilter filter) async {
    final repo = sl<PaymentRepository>();
    final result = await repo.getAll(
      customerId: filter.customerId,
      fromDate: filter.dateFrom,
      toDate: filter.dateTo,
    );
    return result.when(
      success: (list) {
        var filtered = list;
        if (filter.status != null) {
          filtered = filtered.where((p) => p.status.name.toLowerCase() == filter.status!.toLowerCase()).toList();
        }
        if (filter.paymentMode != null) {
          filtered = filtered.where((p) => p.paymentMode.toLowerCase() == filter.paymentMode!.toLowerCase()).toList();
        }
        return filtered;
      },
      failure: (f) => throw Exception(f.userMessage),
    );
  }

  @override
  Map<String, dynamic> toJson(Payment p) => {
        'id': p.id,
        'payment_number': p.paymentNumber,
        'customer_id': p.customerId,
        'invoice_id': p.invoiceId,
        'amount': p.amount,
        'payment_date': p.paymentDate.toIso8601String(),
        'payment_mode': p.paymentMode,
        'reference_number': p.referenceNumber,
        'bank_name': p.bankName,
        'notes': p.notes,
        'status': p.status.toDbString(),
        'created_at': p.createdAt.toIso8601String(),
        'updated_at': p.updatedAt.toIso8601String(),
      };

  @override
  Payment? fromJson(Map<String, dynamic> json) => null;

  @override
  List<ValidationError> validateRow(Map<String, dynamic> json) => [];
}

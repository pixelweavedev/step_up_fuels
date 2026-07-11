import 'package:intl/intl.dart';
import 'package:step_up_fuels/app/di/injection_container.dart';
import 'package:step_up_fuels/core/services/import_export/models/export_adapter.dart';
import 'package:step_up_fuels/core/services/import_export/models/export_column.dart';
import 'package:step_up_fuels/core/services/import_export/models/export_filter.dart';
import 'package:step_up_fuels/core/services/import_export/models/import_result.dart';
import 'package:step_up_fuels/features/expenses/application/usecases/get_expenses_usecase.dart';
import 'package:step_up_fuels/features/expenses/domain/entities/expense.dart';

class ExpenseExportAdapter extends ExportAdapter<Expense> {
  @override
  String get entityName => 'expenses';

  @override
  String get entityLabel => 'Expenses';

  @override
  String get entityEmoji => '💸';

  @override
  String get gradientStart => '#EF4444';

  @override
  String get gradientEnd => '#B91C1C';

  @override
  bool get supportsImport => true;

  @override
  bool get supportsReport => true;

  @override
  List<ExportColumn<Expense>> get dataColumns => [
        ExportColumn<Expense>(
          key: 'expense_number',
          label: 'Expense No.',
          group: 'Identity',
          getValue: (e) => e.expenseNumber,
          importable: true,
          required: true,
          importAliases: ['exp no', 'number', 'expense number'],
        ),
        ExportColumn<Expense>(
          key: 'category',
          label: 'Category',
          group: 'Identity',
          getValue: (e) => e.category,
          importable: true,
          required: true,
          importAliases: ['exp category', 'type', 'expense type'],
        ),
        ExportColumn<Expense>(
          key: 'amount',
          label: 'Amount',
          group: 'Pricing',
          getValue: (e) => e.amount.toStringAsFixed(2),
          getRawValue: (e) => e.amount,
          type: ColumnType.currency,
          importable: true,
          required: true,
          importAliases: ['value', 'cost', 'total'],
        ),
        ExportColumn<Expense>(
          key: 'expense_date',
          label: 'Expense Date',
          group: 'Identity',
          getValue: (e) => DateFormat('dd/MM/yyyy').format(e.expenseDate),
          getRawValue: (e) => e.expenseDate,
          type: ColumnType.date,
          importable: true,
          required: true,
          importAliases: ['date', 'spent date'],
        ),
        ExportColumn<Expense>(
          key: 'payment_mode',
          label: 'Payment Mode',
          group: 'Payment',
          getValue: (e) => e.paymentMode,
          importable: true,
          required: true,
          importAliases: ['mode', 'payment type'],
        ),
        ExportColumn<Expense>(
          key: 'payment_reference',
          label: 'Payment Reference',
          group: 'Payment',
          getValue: (e) => e.paymentReference ?? '',
          importable: true,
          importAliases: ['ref', 'reference', 'txn id', 'transaction reference'],
        ),
        ExportColumn<Expense>(
          key: 'vehicle_id',
          label: 'Vehicle ID',
          group: 'References',
          getValue: (e) => e.vehicleId ?? '',
          defaultVisible: false,
          importable: true,
          importAliases: ['vehicle', 'reg no', 'vehicle reg'],
        ),
        ExportColumn<Expense>(
          key: 'driver_id',
          label: 'Driver ID',
          group: 'References',
          getValue: (e) => e.driverId ?? '',
          defaultVisible: false,
          importable: true,
          importAliases: ['driver', 'driver name', 'emp id'],
        ),
        ExportColumn<Expense>(
          key: 'notes',
          label: 'Notes',
          group: 'Other',
          getValue: (e) => e.notes ?? '',
          defaultVisible: false,
          importable: true,
        ),
      ];

  @override
  Future<List<Expense>> fetchData(ExportFilter filter) async {
    final useCase = sl<GetExpensesUseCase>();
    final result = await useCase(
      fromDate: filter.dateFrom,
      toDate: filter.dateTo,
      category: filter.status, // We repurpose status filter for category filter in Expense if desired
    );
    return result.when(
      success: (list) {
        var filtered = list;
        if (filter.driverId != null) {
          filtered = filtered.where((e) => e.driverId == filter.driverId).toList();
        }
        if (filter.vehicleId != null) {
          filtered = filtered.where((e) => e.vehicleId == filter.vehicleId).toList();
        }
        return filtered;
      },
      failure: (f) => throw Exception(f.userMessage),
    );
  }

  @override
  Map<String, dynamic> toJson(Expense e) => {
        'id': e.id,
        'expense_number': e.expenseNumber,
        'category': e.category,
        'amount': e.amount,
        'expense_date': e.expenseDate.toIso8601String(),
        'payment_mode': e.paymentMode,
        'payment_reference': e.paymentReference,
        'vehicle_id': e.vehicleId,
        'driver_id': e.driverId,
        'notes': e.notes,
        'created_at': e.createdAt.toIso8601String(),
        'updated_at': e.updatedAt.toIso8601String(),
      };

  @override
  Expense? fromJson(Map<String, dynamic> json) => null;

  @override
  List<ValidationError> validateRow(Map<String, dynamic> json) {
    final errors = <ValidationError>[];

    if ((json['expense_number'] as String?)?.isEmpty ?? true) {
      errors.add(const ValidationError(field: 'expense_number', message: 'Expense Number is required'));
    }
    if ((json['category'] as String?)?.isEmpty ?? true) {
      errors.add(const ValidationError(field: 'category', message: 'Category is required'));
    }

    final amount = double.tryParse(json['amount']?.toString() ?? '');
    if (amount == null) {
      errors.add(const ValidationError(field: 'amount', message: 'Amount must be a valid number'));
    } else if (amount <= 0) {
      errors.add(const ValidationError(field: 'amount', message: 'Amount must be greater than zero'));
    }

    final dateStr = json['expense_date'] as String?;
    if (dateStr == null || dateStr.isEmpty) {
      errors.add(const ValidationError(field: 'expense_date', message: 'Expense date is required'));
    }

    return errors;
  }

  @override
  List<DependencyRef> getDependencies(Map<String, dynamic> json) {
    final refs = <DependencyRef>[];
    final vId = json['vehicle_id'] as String?;
    final dId = json['driver_id'] as String?;

    if (vId != null && vId.trim().isNotEmpty) {
      refs.add(DependencyRef(field: 'vehicle_id', entityType: 'Vehicle', refId: vId));
    }
    if (dId != null && dId.trim().isNotEmpty) {
      refs.add(DependencyRef(field: 'driver_id', entityType: 'Driver', refId: dId));
    }

    return refs;
  }
}

import 'package:intl/intl.dart';
import 'package:step_up_fuels/app/di/injection_container.dart';
import 'package:step_up_fuels/core/services/import_export/models/export_adapter.dart';
import 'package:step_up_fuels/core/services/import_export/models/export_column.dart';
import 'package:step_up_fuels/core/services/import_export/models/export_filter.dart';
import 'package:step_up_fuels/core/services/import_export/models/import_result.dart';
import 'package:step_up_fuels/features/inventory/application/usecases/get_movements_usecase.dart';
import 'package:step_up_fuels/features/inventory/domain/entities/inventory_movement.dart';

class InventoryExportAdapter extends ExportAdapter<InventoryMovement> {
  @override
  String get entityName => 'inventory';

  @override
  String get entityLabel => 'Inventory Movements';

  @override
  String get entityEmoji => '⛽';

  @override
  String get gradientStart => '#EF4444';

  @override
  String get gradientEnd => '#F59E0B';

  @override
  bool get supportsImport => false;

  @override
  bool get supportsReport => true;

  @override
  List<ExportColumn<InventoryMovement>> get dataColumns => [
    ExportColumn<InventoryMovement>(
      key: 'product_id',
      label: 'Product ID',
      getValue: (i) => i.productId,
    ),
    ExportColumn<InventoryMovement>(
      key: 'source_location_id',
      label: 'Source Location',
      getValue: (i) => i.sourceLocationId ?? '',
    ),
    ExportColumn<InventoryMovement>(
      key: 'destination_location_id',
      label: 'Destination Location',
      getValue: (i) => i.destinationLocationId ?? '',
    ),
    ExportColumn<InventoryMovement>(
      key: 'type',
      label: 'Type',
      getValue: (i) => i.type.value,
    ),
    ExportColumn<InventoryMovement>(
      key: 'quantity',
      label: 'Quantity',
      getValue: (i) => i.quantity.toStringAsFixed(2),
      getRawValue: (i) => i.quantity,
      type: ColumnType.number,
    ),
    ExportColumn<InventoryMovement>(
      key: 'movement_date',
      label: 'Date',
      getValue: (i) => DateFormat('dd/MM/yyyy').format(i.movementDate),
      getRawValue: (i) => i.movementDate,
      type: ColumnType.date,
    ),
    ExportColumn<InventoryMovement>(
      key: 'reference_id',
      label: 'Ref ID',
      getValue: (i) => i.referenceId ?? '',
      defaultVisible: false,
    ),
    ExportColumn<InventoryMovement>(
      key: 'reference_type',
      label: 'Ref Type',
      getValue: (i) => i.referenceType ?? '',
      defaultVisible: false,
    ),
    ExportColumn<InventoryMovement>(
      key: 'notes',
      label: 'Notes',
      getValue: (i) => i.notes ?? '',
      defaultVisible: false,
    ),
  ];

  @override
  Future<List<InventoryMovement>> fetchData(ExportFilter filter) async {
    final useCase = sl<GetMovementsUseCase>();
    final result = await useCase(
      productId: filter.customerId, // Reuse customerId as productId filter here
      start: filter.dateFrom,
      end: filter.dateTo,
    );
    return result.when(
      success: (list) => list,
      failure: (f) => throw Exception(f.userMessage),
    );
  }

  @override
  Map<String, dynamic> toJson(InventoryMovement i) => {
    'id': i.id,
    'product_id': i.productId,
    'source_location_id': i.sourceLocationId,
    'destination_location_id': i.destinationLocationId,
    'type': i.type.value,
    'quantity': i.quantity,
    'reference_id': i.referenceId,
    'reference_type': i.referenceType,
    'movement_date': i.movementDate.toIso8601String(),
    'notes': i.notes,
    'created_at': i.createdAt.toIso8601String(),
  };

  @override
  InventoryMovement? fromJson(Map<String, dynamic> json) => null;

  @override
  List<ValidationError> validateRow(Map<String, dynamic> json) => [];
}

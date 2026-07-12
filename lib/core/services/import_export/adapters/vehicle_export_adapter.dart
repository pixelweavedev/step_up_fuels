import 'package:step_up_fuels/app/di/injection_container.dart';
import 'package:step_up_fuels/core/services/import_export/models/export_adapter.dart';
import 'package:step_up_fuels/core/services/import_export/models/export_column.dart';
import 'package:step_up_fuels/core/services/import_export/models/export_filter.dart';
import 'package:step_up_fuels/core/services/import_export/models/import_result.dart';
import 'package:step_up_fuels/features/vehicles/application/usecases/get_vehicles_usecase.dart';
import 'package:step_up_fuels/features/vehicles/domain/entities/vehicle.dart';

class VehicleExportAdapter extends ExportAdapter<Vehicle> {
  @override
  String get entityName => 'vehicles';

  @override
  String get entityLabel => 'Vehicles';

  @override
  String get entityEmoji => '🚛';

  @override
  String get gradientStart => '#0EA5E9';

  @override
  String get gradientEnd => '#0284C7';

  @override
  bool get supportsImport => true;

  @override
  bool get supportsReport => false;

  @override
  List<ExportColumn<Vehicle>> get dataColumns => [
    ExportColumn<Vehicle>(
      key: 'registration_number',
      label: 'Registration No.',
      group: 'Identity',
      getValue: (v) => v.registrationNumber,
      importable: true,
      required: true,
      importAliases: ['reg no', 'vehicle no', 'registration', 'number plate'],
    ),
    ExportColumn<Vehicle>(
      key: 'model',
      label: 'Model',
      group: 'Identity',
      getValue: (v) => v.model,
      importable: true,
      required: true,
      importAliases: ['vehicle model', 'make'],
    ),
    ExportColumn<Vehicle>(
      key: 'capacity',
      label: 'Capacity (L)',
      group: 'Capacity',
      getValue: (v) => v.capacity.toStringAsFixed(0),
      getRawValue: (v) => v.capacity,
      type: ColumnType.number,
      importable: true,
      required: true,
      importAliases: ['tank capacity', 'volume', 'size'],
    ),
    ExportColumn<Vehicle>(
      key: 'status',
      label: 'Status',
      group: 'Identity',
      getValue: (v) => v.status.displayName,
      importable: true,
      importAliases: ['vehicle status', 'state'],
    ),
    ExportColumn<Vehicle>(
      key: 'notes',
      label: 'Notes',
      group: 'Other',
      getValue: (v) => v.notes ?? '',
      defaultVisible: false,
      importable: true,
    ),
  ];

  @override
  Future<List<Vehicle>> fetchData(ExportFilter filter) async {
    final useCase = sl<GetVehiclesUseCase>();
    final result = await useCase();
    return result.when(
      success: (list) {
        var filtered = list;
        if (filter.activeOnly) {
          filtered = filtered
              .where((v) => v.status == VehicleStatus.active)
              .toList();
        }
        return filtered;
      },
      failure: (f) => throw Exception(f.userMessage),
    );
  }

  @override
  Map<String, dynamic> toJson(Vehicle v) => {
    'id': v.id,
    'registration_number': v.registrationNumber,
    'model': v.model,
    'capacity': v.capacity,
    'status': v.status.name,
    'notes': v.notes,
    'created_at': v.createdAt.toIso8601String(),
    'updated_at': v.updatedAt.toIso8601String(),
  };

  @override
  Vehicle? fromJson(Map<String, dynamic> json) => null;

  @override
  List<ValidationError> validateRow(Map<String, dynamic> json) {
    final errors = <ValidationError>[];

    if ((json['registration_number'] as String?)?.isEmpty ?? true) {
      errors.add(
        const ValidationError(
          field: 'registration_number',
          message: 'Registration Number is required',
        ),
      );
    }
    if ((json['model'] as String?)?.isEmpty ?? true) {
      errors.add(
        const ValidationError(field: 'model', message: 'Model is required'),
      );
    }

    final capacity = double.tryParse(json['capacity']?.toString() ?? '');
    if (capacity == null) {
      errors.add(
        const ValidationError(
          field: 'capacity',
          message: 'Capacity must be a valid number',
        ),
      );
    } else if (capacity <= 0) {
      errors.add(
        const ValidationError(
          field: 'capacity',
          message: 'Capacity must be greater than zero',
        ),
      );
    }

    return errors;
  }
}

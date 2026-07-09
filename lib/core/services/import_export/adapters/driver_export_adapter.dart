import 'package:intl/intl.dart';
import 'package:step_up_fuels/app/di/injection_container.dart';
import 'package:step_up_fuels/core/services/import_export/models/export_adapter.dart';
import 'package:step_up_fuels/core/services/import_export/models/export_column.dart';
import 'package:step_up_fuels/core/services/import_export/models/export_filter.dart';
import 'package:step_up_fuels/core/services/import_export/models/import_result.dart';
import 'package:step_up_fuels/features/drivers/application/usecases/get_drivers_usecase.dart';
import 'package:step_up_fuels/features/drivers/domain/entities/driver.dart';

class DriverExportAdapter extends ExportAdapter<Driver> {
  @override
  String get entityName => 'drivers';

  @override
  String get entityLabel => 'Drivers';

  @override
  String get entityEmoji => '🧑‍✈️';

  @override
  String get gradientStart => '#4B5563';

  @override
  String get gradientEnd => '#1F2937';

  @override
  bool get supportsImport => true;

  @override
  bool get supportsReport => false;

  @override
  List<ExportColumn<Driver>> get dataColumns => [
    ExportColumn<Driver>(
      key: 'name',
      label: 'Name',
      group: 'Identity',
      getValue: (d) => d.name,
      importable: true,
      required: true,
      importAliases: ['driver name', 'full name', 'name'],
    ),
    ExportColumn<Driver>(
      key: 'license_number',
      label: 'License Number',
      group: 'Verification',
      getValue: (d) => d.licenseNumber,
      importable: true,
      required: true,
      importAliases: ['license', 'license no', 'dl number', 'dl no'],
    ),
    ExportColumn<Driver>(
      key: 'license_expiry',
      label: 'License Expiry',
      group: 'Verification',
      getValue: (d) => DateFormat('dd/MM/yyyy').format(d.licenseExpiry),
      getRawValue: (d) => d.licenseExpiry,
      type: ColumnType.date,
      importable: true,
      required: true,
      importAliases: ['expiry', 'license expiry date', 'expiry date'],
    ),
    ExportColumn<Driver>(
      key: 'phone',
      label: 'Phone',
      group: 'Contact',
      getValue: (d) => d.phone,
      importable: true,
      required: true,
      importAliases: ['mobile', 'phone number', 'mobile number', 'contact'],
    ),
    ExportColumn<Driver>(
      key: 'email',
      label: 'Email',
      group: 'Contact',
      getValue: (d) => d.email ?? '',
      importable: true,
      importAliases: ['email address', 'mail'],
    ),
    ExportColumn<Driver>(
      key: 'status',
      label: 'Status',
      group: 'Identity',
      getValue: (d) => d.status.displayName,
      importable: true,
      importAliases: ['driver status', 'active status'],
    ),
  ];

  @override
  Future<List<Driver>> fetchData(ExportFilter filter) async {
    final useCase = sl<GetDriversUseCase>();
    final result = await useCase();
    return result.when(
      success: (list) {
        var filtered = list;
        if (filter.activeOnly) {
          filtered = filtered
              .where((d) => d.status == DriverStatus.active)
              .toList();
        }
        return filtered;
      },
      failure: (f) => throw Exception(f.userMessage),
    );
  }

  @override
  Map<String, dynamic> toJson(Driver d) => {
    'id': d.id,
    'name': d.name,
    'license_number': d.licenseNumber,
    'license_expiry': d.licenseExpiry.toIso8601String(),
    'phone': d.phone,
    'email': d.email,
    'status': d.status.name,
    'created_at': d.createdAt.toIso8601String(),
    'updated_at': d.updatedAt.toIso8601String(),
  };

  @override
  Driver? fromJson(Map<String, dynamic> json) => null;

  @override
  List<ValidationError> validateRow(Map<String, dynamic> json) {
    final errors = <ValidationError>[];

    if ((json['name'] as String?)?.isEmpty ?? true) {
      errors.add(
        const ValidationError(
          field: 'name',
          message: 'Driver Name is required',
        ),
      );
    }
    if ((json['license_number'] as String?)?.isEmpty ?? true) {
      errors.add(
        const ValidationError(
          field: 'license_number',
          message: 'License Number is required',
        ),
      );
    }
    if ((json['phone'] as String?)?.isEmpty ?? true) {
      errors.add(
        const ValidationError(
          field: 'phone',
          message: 'Phone number is required',
        ),
      );
    }

    final expiryStr = json['license_expiry'] as String?;
    if (expiryStr == null || expiryStr.isEmpty) {
      errors.add(
        const ValidationError(
          field: 'license_expiry',
          message: 'License expiry date is required',
        ),
      );
    } else {
      // Try to parse multiple formats
      DateTime? parsed;
      try {
        parsed = DateTime.parse(expiryStr);
      } catch (_) {
        try {
          parsed = DateFormat('dd/MM/yyyy').parse(expiryStr);
        } catch (_) {
          try {
            parsed = DateFormat('yyyy-MM-dd').parse(expiryStr);
          } catch (_) {}
        }
      }
      if (parsed == null) {
        errors.add(
          const ValidationError(
            field: 'license_expiry',
            message:
                'Invalid license expiry date format (use DD/MM/YYYY or YYYY-MM-DD)',
          ),
        );
      } else if (parsed.isBefore(DateTime.now())) {
        errors.add(
          ValidationError(
            field: 'license_expiry',
            message:
                'License has expired on ${DateFormat('dd/MM/yyyy').format(parsed)}',
            severity: ValidationSeverity.warning,
            suggestion: 'Renew license or confirm driver eligibility',
          ),
        );
      }
    }

    return errors;
  }
}

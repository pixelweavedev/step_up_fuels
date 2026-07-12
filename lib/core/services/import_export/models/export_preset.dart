import 'package:step_up_fuels/core/services/import_export/models/export_filter.dart';
import 'package:step_up_fuels/core/services/import_export/models/export_format.dart';
import 'package:step_up_fuels/core/services/import_export/models/export_mode.dart';

/// A saved, named export configuration that users can recall later.
///
/// Presets capture the entity, format, mode, visible columns, and filters
/// so that common exports (e.g. "Accounting Export", "GST Report") can be
/// reproduced with one click.
class ExportPreset {
  factory ExportPreset.fromJson(Map<String, dynamic> json) => ExportPreset(
    id: json['id'] as String,
    name: json['name'] as String,
    entityName: json['entityName'] as String,
    format: ExportFormat.values.firstWhere(
      (f) => f.name == json['format'],
      orElse: () => ExportFormat.csv,
    ),
    mode: ExportMode.values.firstWhere(
      (m) => m.name == json['mode'],
      orElse: () => ExportMode.data,
    ),
    visibleColumnKeys: List<String>.from(json['visibleColumnKeys'] as List),
    filter: ExportFilter.fromJson(json['filter'] as Map<String, dynamic>),
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: json['updatedAt'] != null
        ? DateTime.tryParse(json['updatedAt'] as String)
        : null,
  );
  const ExportPreset({
    required this.id,
    required this.name,
    required this.entityName,
    required this.format,
    required this.mode,
    required this.visibleColumnKeys,
    required this.filter,
    required this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String entityName;
  final ExportFormat format;
  final ExportMode mode;
  final List<String> visibleColumnKeys;
  final ExportFilter filter;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ExportPreset copyWith({
    String? name,
    ExportFormat? format,
    ExportMode? mode,
    List<String>? visibleColumnKeys,
    ExportFilter? filter,
  }) {
    return ExportPreset(
      id: id,
      name: name ?? this.name,
      entityName: entityName,
      format: format ?? this.format,
      mode: mode ?? this.mode,
      visibleColumnKeys: visibleColumnKeys ?? this.visibleColumnKeys,
      filter: filter ?? this.filter,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'entityName': entityName,
    'format': format.name,
    'mode': mode.name,
    'visibleColumnKeys': visibleColumnKeys,
    'filter': filter.toJson(),
    'createdAt': createdAt.toIso8601String(),
    if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
  };
}

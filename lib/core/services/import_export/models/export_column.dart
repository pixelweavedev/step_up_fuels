import 'package:intl/intl.dart';

/// The data type of a column — used by serializers for proper formatting.
enum ColumnType {
  text,
  number,
  currency, // formatted as ₹ with 2 decimal places
  date,
  boolean,
  percent,
}

/// Describes a single exportable/importable field of an entity.
///
/// Type parameter [T] is the entity class (e.g. Customer, Invoice).
class ExportColumn<T> {
  const ExportColumn({
    required this.key,
    required this.label,
    required this.getValue,
    this.getRawValue,
    this.type = ColumnType.text,
    this.group,
    this.defaultVisible = true,
    this.importable = false,
    this.required = false,
    this.importAliases = const [],
  });

  /// Unique snake_case identifier (used in CSV header + preset storage).
  final String key;

  /// Human-readable column label shown in pickers and Excel headers.
  final String label;

  /// Optional section group for the column picker (e.g. 'GST & Compliance').
  final String? group;

  /// Extracts the display string from an entity instance.
  final String Function(T item) getValue;

  /// Extracts the raw typed value (double, DateTime, bool) for Excel formatting.
  /// If null, [getValue] string is used.
  final dynamic Function(T item)? getRawValue;

  /// Data type — determines formatter in Excel serializer.
  final ColumnType type;

  /// Whether this column is visible by default in new exports.
  final bool defaultVisible;

  /// Whether this column can be used during import (mapped from CSV/JSON).
  final bool importable;

  /// Whether this field is required during import validation.
  final bool required;

  /// Alternative header names accepted during smart import mapping.
  /// e.g. ['Customer Name', 'client name', 'account name']
  final List<String> importAliases;

  /// Formats the raw value according to [type] for display.
  String format(T item) {
    if (type == ColumnType.currency) {
      final raw = getRawValue?.call(item);
      if (raw is num) {
        return NumberFormat('#,##0.00', 'en_IN').format(raw);
      }
    }
    if (type == ColumnType.date) {
      final raw = getRawValue?.call(item);
      if (raw is DateTime) {
        return DateFormat('dd/MM/yyyy').format(raw);
      }
    }
    if (type == ColumnType.percent) {
      final raw = getRawValue?.call(item);
      if (raw is num) {
        return '${(raw * 100).toStringAsFixed(1)}%';
      }
    }
    if (type == ColumnType.boolean) {
      final raw = getRawValue?.call(item);
      if (raw is bool) return raw ? 'Yes' : 'No';
    }
    return getValue(item);
  }
}

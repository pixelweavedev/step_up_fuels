import 'package:step_up_fuels/app/di/injection_container.dart';
import 'package:step_up_fuels/core/services/import_export/models/export_adapter.dart';
import 'package:step_up_fuels/core/services/import_export/models/export_column.dart';
import 'package:step_up_fuels/core/services/import_export/models/export_filter.dart';
import 'package:step_up_fuels/core/services/import_export/models/import_result.dart';
import 'package:step_up_fuels/features/products/application/usecases/get_products_usecase.dart';
import 'package:step_up_fuels/features/products/domain/entities/product.dart';

class ProductExportAdapter extends ExportAdapter<Product> {
  @override
  String get entityName => 'products';

  @override
  String get entityLabel => 'Products';

  @override
  String get entityEmoji => '📦';

  @override
  String get gradientStart => '#10B981';

  @override
  String get gradientEnd => '#059669';

  @override
  bool get supportsImport => true;

  @override
  bool get supportsReport => false;

  @override
  List<ExportColumn<Product>> get dataColumns => [
        ExportColumn<Product>(
          key: 'product_code',
          label: 'Product Code',
          group: 'Identity',
          getValue: (p) => p.productCode,
          importable: true,
          required: true,
          importAliases: ['code', 'prod code', 'item code'],
        ),
        ExportColumn<Product>(
          key: 'name',
          label: 'Product Name',
          group: 'Identity',
          getValue: (p) => p.name,
          importable: true,
          required: true,
          importAliases: ['name', 'item name', 'description name'],
        ),
        ExportColumn<Product>(
          key: 'description',
          label: 'Description',
          group: 'Identity',
          getValue: (p) => p.description ?? '',
          defaultVisible: false,
          importable: true,
        ),
        ExportColumn<Product>(
          key: 'hsn_code',
          label: 'HSN Code',
          group: 'GST & Compliance',
          getValue: (p) => p.hsnCode,
          importable: true,
          required: true,
          importAliases: ['hsn', 'hsn no', 'hsn code'],
        ),
        ExportColumn<Product>(
          key: 'unit_of_measure',
          label: 'UOM',
          group: 'Identity',
          getValue: (p) => p.unitOfMeasure,
          importable: true,
          required: true,
          importAliases: ['unit', 'uom', 'measure unit'],
        ),
        ExportColumn<Product>(
          key: 'gst_rate',
          label: 'GST Rate',
          group: 'GST & Compliance',
          getValue: (p) => p.gstRate.toStringAsFixed(2),
          getRawValue: (p) => p.gstRate,
          type: ColumnType.percent,
          importable: true,
          importAliases: ['gst', 'tax rate', 'gst %'],
        ),
        ExportColumn<Product>(
          key: 'cgst_rate',
          label: 'CGST Rate',
          group: 'GST & Compliance',
          getValue: (p) => p.cgstRate.toStringAsFixed(2),
          getRawValue: (p) => p.cgstRate,
          type: ColumnType.percent,
          defaultVisible: false,
          importable: true,
        ),
        ExportColumn<Product>(
          key: 'sgst_rate',
          label: 'SGST Rate',
          group: 'GST & Compliance',
          getValue: (p) => p.sgstRate.toStringAsFixed(2),
          getRawValue: (p) => p.sgstRate,
          type: ColumnType.percent,
          defaultVisible: false,
          importable: true,
        ),
        ExportColumn<Product>(
          key: 'igst_rate',
          label: 'IGST Rate',
          group: 'GST & Compliance',
          getValue: (p) => p.igstRate.toStringAsFixed(2),
          getRawValue: (p) => p.igstRate,
          type: ColumnType.percent,
          defaultVisible: false,
          importable: true,
        ),
        ExportColumn<Product>(
          key: 'current_selling_price',
          label: 'Selling Price',
          group: 'Pricing',
          getValue: (p) => p.currentSellingPrice?.toStringAsFixed(2) ?? '',
          getRawValue: (p) => p.currentSellingPrice,
          type: ColumnType.currency,
          importable: true,
          importAliases: ['price', 'rate', 'selling price'],
        ),
        ExportColumn<Product>(
          key: 'is_active',
          label: 'Active',
          group: 'Identity',
          getValue: (p) => p.isActive ? 'Yes' : 'No',
          getRawValue: (p) => p.isActive,
          type: ColumnType.boolean,
          importable: true,
        ),
      ];

  @override
  Future<List<Product>> fetchData(ExportFilter filter) async {
    final useCase = sl<GetProductsUseCase>();
    final result = await useCase();
    return result.when(
      success: (list) {
        var filtered = list;
        if (filter.activeOnly) {
          filtered = filtered.where((p) => p.isActive).toList();
        }
        return filtered;
      },
      failure: (f) => throw Exception(f.userMessage),
    );
  }

  @override
  Map<String, dynamic> toJson(Product p) => {
        'id': p.id,
        'product_code': p.productCode,
        'name': p.name,
        'description': p.description,
        'hsn_code': p.hsnCode,
        'unit_of_measure': p.unitOfMeasure,
        'gst_rate': p.gstRate,
        'cgst_rate': p.cgstRate,
        'sgst_rate': p.sgstRate,
        'igst_rate': p.igstRate,
        'current_selling_price': p.currentSellingPrice,
        'is_active': p.isActive,
        'created_at': p.createdAt.toIso8601String(),
        'updated_at': p.updatedAt.toIso8601String(),
      };

  @override
  Product? fromJson(Map<String, dynamic> json) => null;

  @override
  List<ValidationError> validateRow(Map<String, dynamic> json) {
    final errors = <ValidationError>[];

    if ((json['product_code'] as String?)?.isEmpty ?? true) {
      errors.add(const ValidationError(
          field: 'product_code', message: 'Product Code is required'));
    }
    if ((json['name'] as String?)?.isEmpty ?? true) {
      errors.add(const ValidationError(
          field: 'name', message: 'Product Name is required'));
    }
    if ((json['hsn_code'] as String?)?.isEmpty ?? true) {
      errors.add(const ValidationError(
          field: 'hsn_code', message: 'HSN Code is required'));
    }
    if ((json['unit_of_measure'] as String?)?.isEmpty ?? true) {
      errors.add(const ValidationError(
          field: 'unit_of_measure', message: 'Unit of measure is required'));
    }

    final gstRate = double.tryParse(json['gst_rate']?.toString() ?? '');
    if (json['gst_rate'] != null && gstRate == null) {
      errors.add(const ValidationError(
          field: 'gst_rate', message: 'GST Rate must be a number'));
    }

    return errors;
  }
}

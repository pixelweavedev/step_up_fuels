import 'package:step_up_fuels/core/services/import_export/adapters/customer_export_adapter.dart';
import 'package:step_up_fuels/core/services/import_export/adapters/driver_export_adapter.dart';
import 'package:step_up_fuels/core/services/import_export/adapters/expense_export_adapter.dart';
import 'package:step_up_fuels/core/services/import_export/adapters/inventory_export_adapter.dart';
import 'package:step_up_fuels/core/services/import_export/adapters/invoice_export_adapter.dart';
import 'package:step_up_fuels/core/services/import_export/adapters/payment_export_adapter.dart';
import 'package:step_up_fuels/core/services/import_export/adapters/product_export_adapter.dart';
import 'package:step_up_fuels/core/services/import_export/adapters/purchase_export_adapter.dart';
import 'package:step_up_fuels/core/services/import_export/adapters/vehicle_export_adapter.dart';
import 'package:step_up_fuels/core/services/import_export/models/export_adapter.dart';

class ExportAdapterRegistry {
  ExportAdapterRegistry._();

  static final List<ExportAdapter<dynamic>> all = [
    CustomerExportAdapter(),
    ProductExportAdapter(),
    InvoiceExportAdapter(),
    PurchaseExportAdapter(),
    PaymentExportAdapter(),
    ExpenseExportAdapter(),
    DriverExportAdapter(),
    VehicleExportAdapter(),
    InventoryExportAdapter(),
  ];

  static ExportAdapter<dynamic> getByName(String name) {
    return all.firstWhere(
      (a) => a.entityName == name,
      orElse: () => throw ArgumentError('No export adapter found for entity: $name'),
    );
  }
}

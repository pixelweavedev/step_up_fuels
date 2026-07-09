import 'dart:io';
import 'package:step_up_fuels/app/di/injection_container.dart';
import 'package:step_up_fuels/core/services/import_export/models/export_adapter.dart';
import 'package:step_up_fuels/core/services/import_export/models/export_format.dart';
import 'package:step_up_fuels/core/services/import_export/models/export_history_entry.dart';
import 'package:step_up_fuels/core/services/import_export/models/export_mode.dart';
import 'package:step_up_fuels/core/services/import_export/models/import_result.dart';
import 'package:step_up_fuels/core/services/import_export/models/import_export_storage.dart';
import 'package:step_up_fuels/core/services/import_export/serializers/csv_serializer.dart';
import 'package:step_up_fuels/core/services/import_export/serializers/json_serializer.dart';

// Use cases / Repos for Dependency Validation
import 'package:step_up_fuels/features/drivers/domain/repositories/driver_repository.dart';
import 'package:step_up_fuels/features/vehicles/domain/repositories/vehicle_repository.dart';
import 'package:step_up_fuels/features/customers/domain/repositories/customer_repository.dart';
import 'package:step_up_fuels/features/products/domain/repositories/product_repository.dart';
import 'package:step_up_fuels/features/expenses/domain/repositories/expense_repository.dart';

// Domain Entities
import 'package:step_up_fuels/features/customers/domain/entities/customer.dart';
import 'package:step_up_fuels/features/customers/domain/entities/customer_type.dart';
import 'package:step_up_fuels/features/customers/domain/entities/fuel_type.dart';
import 'package:step_up_fuels/features/customers/domain/entities/payment_terms.dart';
import 'package:step_up_fuels/features/products/domain/entities/product.dart';
import 'package:step_up_fuels/features/drivers/domain/entities/driver.dart';
import 'package:step_up_fuels/features/vehicles/domain/entities/vehicle.dart';
import 'package:step_up_fuels/features/expenses/domain/entities/expense.dart';

import 'package:uuid/uuid.dart';

class DataImportService {
  DataImportService({
    this.csvSerializer = const CsvSerializer(),
    this.jsonSerializer = const JsonSerializer(),
  });

  final CsvSerializer csvSerializer;
  final JsonSerializer jsonSerializer;

  /// Step 1: Reads and validates the file, returns a summary of errors/warnings/conflicts
  Future<ImportValidationSummary> validate({
    required ExportAdapter<dynamic> adapter,
    required String filePath,
    required ExportFormat format,
  }) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw FileSystemException('Import file not found', filePath);
    }

    final content = await file.readAsString();
    List<Map<String, dynamic>> rawRows = [];
    Map<String, String?> headerMapping = {};

    if (format == ExportFormat.json) {
      final jsonParseResult = jsonSerializer.parse(content, adapter.entityName);
      rawRows = jsonParseResult.rows;
      // JSON contains exact keys, no mapping needed
      for (final col in adapter.dataColumns) {
        headerMapping[col.key] = col.key;
      }
    } else if (format == ExportFormat.csv) {
      final csvParseResult = csvSerializer.parse(content);
      rawRows = csvParseResult.rows;
      headerMapping = adapter.smartMapHeaders(csvParseResult.headers);
    }

    // Load dependencies and potential conflicts for quick lookups
    final driverIds = await _fetchDriverIds();
    final vehicleIds = await _fetchVehicleIds();
    final customerCodes = await _fetchCustomerCodes();
    final productCodes = await _fetchProductCodes();
    final expenseNumbers = await _fetchExpenseNumbers();

    final rowResults = <ImportRowResult>[];
    int validCount = 0;
    int errorCount = 0;
    int warningCount = 0;
    int conflictCount = 0;

    for (int i = 0; i < rawRows.length; i++) {
      final rawRow = rawRows[i];
      final mappedRow = <String, dynamic>{};

      // Map raw row fields using headerMapping
      rawRow.forEach((key, val) {
        final mappedKey = headerMapping[key];
        if (mappedKey != null) {
          mappedRow[mappedKey] = val;
        }
      });

      // Field validation
      final errors = adapter.validateRow(mappedRow);
      final warnings = <ValidationError>[];

      // Smart Dependency Detection
      final deps = adapter.getDependencies(mappedRow);
      final brokenDeps = <DependencyRef>[];
      for (final dep in deps) {
        bool exists = false;
        if (dep.entityType == 'Driver') {
          exists = driverIds.contains(dep.refId);
        } else if (dep.entityType == 'Vehicle') {
          exists = vehicleIds.contains(dep.refId);
        }
        if (!exists) {
          brokenDeps.add(dep);
          errors.add(ValidationError(
            field: dep.field,
            message: 'Referenced ${dep.entityType} "${dep.refId}" does not exist.',
          ));
        }
      }

      // Conflict Detection
      bool hasConflict = false;
      String? conflictId;
      if (adapter.entityName == 'customers') {
        final code = mappedRow['customer_code'] as String?;
        if (code != null && customerCodes.containsKey(code)) {
          hasConflict = true;
          conflictId = customerCodes[code];
        }
      } else if (adapter.entityName == 'products') {
        final code = mappedRow['product_code'] as String?;
        if (code != null && productCodes.containsKey(code)) {
          hasConflict = true;
          conflictId = productCodes[code];
        }
      } else if (adapter.entityName == 'drivers') {
        // e.g. conflict on license number or name
        final lic = mappedRow['license_number'] as String?;
        if (lic != null && driverIds.contains(lic)) {
          hasConflict = true;
        }
      } else if (adapter.entityName == 'vehicles') {
        final reg = mappedRow['registration_number'] as String?;
        if (reg != null && vehicleIds.contains(reg)) {
          hasConflict = true;
        }
      } else if (adapter.entityName == 'expenses') {
        final num = mappedRow['expense_number'] as String?;
        if (num != null && expenseNumbers.containsKey(num)) {
          hasConflict = true;
          conflictId = expenseNumbers[num];
        }
      }

      ImportRowStatus status = ImportRowStatus.valid;
      if (errors.isNotEmpty) {
        status = ImportRowStatus.error;
        errorCount++;
      } else if (hasConflict) {
        status = ImportRowStatus.conflict;
        conflictCount++;
      } else if (warnings.isNotEmpty) {
        status = ImportRowStatus.warning;
        warningCount++;
      } else {
        validCount++;
      }

      rowResults.add(ImportRowResult(
        rowIndex: i + 1,
        status: status,
        rawData: rawRow,
        mappedData: mappedRow,
        errors: errors,
        warnings: warnings,
        dependencies: brokenDeps,
        message: conflictId, // Store conflict ID here temporarily
      ));
    }

    return ImportValidationSummary(
      totalRows: rawRows.length,
      validRows: validCount,
      warningRows: warningCount,
      errorRows: errorCount,
      conflictRows: conflictCount,
      rows: rowResults,
    );
  }

  /// Step 2: Executes the import of valid/conflict rows based on conflict strategy
  Future<ImportResult> executeImport({
    required ExportAdapter<dynamic> adapter,
    required ImportValidationSummary validationSummary,
    required ConflictStrategy conflictStrategy,
    bool dryRun = false,
  }) async {
    int importedCount = 0;
    int updatedCount = 0;
    int skippedCount = 0;
    int errorCount = 0;
    final logs = <ImportLogEntry>[];

    for (final row in validationSummary.rows) {
      if (row.status == ImportRowStatus.error) {
        errorCount++;
        logs.add(ImportLogEntry(
          rowIndex: row.rowIndex,
          status: ImportRowStatus.error,
          message: row.errors.map((e) => e.message).join('; '),
        ));
        continue;
      }

      final data = row.mappedData ?? {};
      bool isUpdate = false;
      bool isSkip = false;

      if (row.status == ImportRowStatus.conflict) {
        if (conflictStrategy == ConflictStrategy.skip) {
          skippedCount++;
          isSkip = true;
          logs.add(ImportLogEntry(
            rowIndex: row.rowIndex,
            status: ImportRowStatus.skipped,
            message: 'Conflict detected. Row skipped.',
          ));
        } else if (conflictStrategy == ConflictStrategy.updateExisting) {
          isUpdate = true;
        } else if (conflictStrategy == ConflictStrategy.createDuplicate) {
          isUpdate = false;
        }
      }

      if (isSkip) continue;

      if (dryRun) {
        if (isUpdate) {
          updatedCount++;
        } else {
          importedCount++;
        }
        logs.add(ImportLogEntry(
          rowIndex: row.rowIndex,
          status: isUpdate ? ImportRowStatus.updated : ImportRowStatus.imported,
          message: 'Dry run check: OK.',
        ));
        continue;
      }

      try {
        final conflictId = row.message; // temporary stored conflict ID
        final success = await _saveToDb(adapter.entityName, data, isUpdate, conflictId);
        if (success) {
          if (isUpdate) {
            updatedCount++;
            logs.add(ImportLogEntry(
              rowIndex: row.rowIndex,
              status: ImportRowStatus.updated,
              message: 'Successfully updated record.',
              entityId: conflictId,
            ));
          } else {
            importedCount++;
            logs.add(ImportLogEntry(
              rowIndex: row.rowIndex,
              status: ImportRowStatus.imported,
              message: 'Successfully imported record.',
            ));
          }
        } else {
          errorCount++;
          logs.add(ImportLogEntry(
            rowIndex: row.rowIndex,
            status: ImportRowStatus.error,
            message: 'Failed to write record to database.',
          ));
        }
      } catch (e) {
        errorCount++;
        logs.add(ImportLogEntry(
          rowIndex: row.rowIndex,
          status: ImportRowStatus.error,
          message: 'Error: ${e.toString()}',
        ));
      }
    }

    final result = ImportResult(
      totalRows: validationSummary.totalRows,
      importedCount: importedCount,
      updatedCount: updatedCount,
      skippedCount: skippedCount,
      errorCount: errorCount,
      log: logs,
      dryRun: dryRun,
    );

    // Save entry to import/export history
    final historyEntry = ExportHistoryEntry(
      id: const Uuid().v4(),
      entityName: adapter.entityName,
      entityLabel: adapter.entityLabel,
      format: ExportFormat.csv, // Default log format
      mode: ExportMode.data,
      type: ExportHistoryType.import,
      status: errorCount == 0 ? ExportHistoryStatus.success : ExportHistoryStatus.failed,
      timestamp: DateTime.now(),
      rowCount: validationSummary.totalRows,
      importedCount: importedCount,
      updatedCount: updatedCount,
      skippedCount: skippedCount,
      errorCount: errorCount,
      errorMessage: errorCount > 0 ? '$errorCount rows had errors' : null,
    );

    final history = await ImportExportStorage.loadHistory();
    history.insert(0, historyEntry);
    await ImportExportStorage.saveHistory(history);

    return result;
  }

  // ── Database Helper Actions ────────────────────────────────────────────────

  Future<bool> _saveToDb(String entityName, Map<String, dynamic> data, bool isUpdate, String? conflictId) async {
    final now = DateTime.now();
    final id = conflictId ?? const Uuid().v4();

    if (entityName == 'customers') {
      final repo = sl<CustomerRepository>();
      final typeStr = data['type']?.toString().toUpperCase() ?? 'COMPANY';
      final type = CustomerType.values.firstWhere((t) => t.name == typeStr, orElse: () => CustomerType.company);

      final fuelStr = data['fuel_type']?.toString().toUpperCase();
      final fuelType = fuelStr != null
          ? FuelType.values.firstWhere((f) => f.name == fuelStr, orElse: () => FuelType.diesel)
          : null;

      final termsStr = data['payment_terms']?.toString().toUpperCase();
      final paymentTerms = termsStr != null
          ? PaymentTerms.values.firstWhere((p) => p.name == termsStr, orElse: () => PaymentTerms.days30)
          : null;

      final customer = Customer(
        id: id,
        customerCode: data['customer_code']?.toString() ?? '',
        name: data['name']?.toString() ?? '',
        displayName: data['display_name']?.toString() ?? data['name']?.toString() ?? '',
        tradeName: data['trade_name']?.toString(),
        legalBusinessName: data['legal_business_name']?.toString(),
        type: type,
        isActive: data['is_active']?.toString().toLowerCase() == 'yes' || data['is_active'] == true,
        gstin: data['gstin']?.toString(),
        pan: data['pan']?.toString(),
        state: data['state']?.toString(),
        placeOfSupply: data['place_of_supply']?.toString(),
        gstRegistrationType: data['gst_registration_type']?.toString(),
        billingAddressLine1: data['billing_address_line1']?.toString(),
        billingAddressLine2: data['billing_address_line2']?.toString(),
        billingArea: data['billing_area']?.toString(),
        billingCity: data['billing_city']?.toString(),
        billingState: data['billing_state']?.toString(),
        billingPincode: data['billing_pincode']?.toString(),
        billingCountry: data['billing_country']?.toString(),
        creditLimit: double.tryParse(data['credit_limit']?.toString() ?? '') ?? 0.0,
        creditDays: int.tryParse(data['credit_days']?.toString() ?? '') ?? 30,
        securityDeposit: double.tryParse(data['security_deposit']?.toString() ?? '') ?? 0.0,
        defaultGstRate: double.tryParse(data['default_gst_rate']?.toString() ?? '') ?? 0.18,
        defaultPrice: double.tryParse(data['default_price']?.toString() ?? ''),
        openingBalance: double.tryParse(data['opening_balance']?.toString() ?? '') ?? 0.0,
        currentBalance: double.tryParse(data['current_balance']?.toString() ?? '') ?? 0.0,
        fuelType: fuelType,
        paymentTerms: paymentTerms,
        emailInvoice: data['email_invoice'] == true,
        whatsappInvoice: data['whatsapp_invoice'] == true,
        requirePo: false,
        requireDc: false,
        requireSignature: false,
        gstApplicable: data['gst_applicable'] != false,
        eInvoiceRequired: false,
        eWayBillRequired: false,
        createdBy: 'import',
        createdAt: now,
        updatedBy: 'import',
        updatedAt: now,
        version: 1,
      );

      final result = await repo.save(customer);
      return result.isSuccess;
    }

    if (entityName == 'products') {
      final repo = sl<ProductRepository>();
      final product = Product(
        id: id,
        productCode: data['product_code']?.toString() ?? '',
        name: data['name']?.toString() ?? '',
        description: data['description']?.toString(),
        hsnCode: data['hsn_code']?.toString() ?? '',
        unitOfMeasure: data['unit_of_measure']?.toString() ?? 'L',
        gstRate: double.tryParse(data['gst_rate']?.toString() ?? '') ?? 0.18,
        cgstRate: double.tryParse(data['cgst_rate']?.toString() ?? '') ?? 0.09,
        sgstRate: double.tryParse(data['sgst_rate']?.toString() ?? '') ?? 0.09,
        igstRate: double.tryParse(data['igst_rate']?.toString() ?? '') ?? 0.0,
        currentSellingPrice: double.tryParse(data['current_selling_price']?.toString() ?? ''),
        isActive: data['is_active'] != false,
        createdBy: 'import',
        createdAt: now,
        updatedBy: 'import',
        updatedAt: now,
        version: 1,
      );
      final result = await repo.save(product);
      return result.isSuccess;
    }

    if (entityName == 'drivers') {
      final repo = sl<DriverRepository>();
      final statusStr = data['status']?.toString().toLowerCase() ?? 'active';
      final status = DriverStatus.values.firstWhere((s) => s.name == statusStr, orElse: () => DriverStatus.active);

      DateTime expiry = now.add(const Duration(days: 365));
      if (data['license_expiry'] != null) {
        expiry = DateTime.tryParse(data['license_expiry']?.toString() ?? '') ?? expiry;
      }

      final driver = Driver(
        id: id,
        name: data['name']?.toString() ?? '',
        licenseNumber: data['license_number']?.toString() ?? '',
        licenseExpiry: expiry,
        phone: data['phone']?.toString() ?? '',
        email: data['email']?.toString(),
        status: status,
        createdBy: 'import',
        createdAt: now,
        updatedBy: 'import',
        updatedAt: now,
        version: 1,
      );
      final result = await repo.save(driver);
      return result.isSuccess;
    }

    if (entityName == 'vehicles') {
      final repo = sl<VehicleRepository>();
      final statusStr = data['status']?.toString().toLowerCase() ?? 'active';
      final status = VehicleStatus.values.firstWhere((s) => s.name == statusStr, orElse: () => VehicleStatus.active);

      final vehicle = Vehicle(
        id: id,
        registrationNumber: data['registration_number']?.toString() ?? '',
        model: data['model']?.toString() ?? '',
        capacity: double.tryParse(data['capacity']?.toString() ?? '') ?? 1000.0,
        status: status,
        notes: data['notes']?.toString(),
        createdBy: 'import',
        createdAt: now,
        updatedBy: 'import',
        updatedAt: now,
        version: 1,
      );
      final result = await repo.save(vehicle);
      return result.isSuccess;
    }

    if (entityName == 'expenses') {
      final repo = sl<ExpenseRepository>();
      DateTime expDate = now;
      if (data['expense_date'] != null) {
        expDate = DateTime.tryParse(data['expense_date']?.toString() ?? '') ?? expDate;
      }

      final expense = Expense(
        id: id,
        expenseNumber: data['expense_number']?.toString() ?? '',
        category: data['category']?.toString() ?? '',
        amount: double.tryParse(data['amount']?.toString() ?? '') ?? 0.0,
        expenseDate: expDate,
        paymentMode: data['payment_mode']?.toString() ?? 'CASH',
        paymentReference: data['payment_reference']?.toString(),
        vehicleId: data['vehicle_id']?.toString(),
        driverId: data['driver_id']?.toString(),
        notes: data['notes']?.toString(),
        createdBy: 'import',
        createdAt: now,
        updatedBy: 'import',
        updatedAt: now,
        version: 1,
      );
      final result = await repo.save(expense);
      return result.isSuccess;
    }

    return false;
  }

  // ── Smart Cache Fetching ───────────────────────────────────────────────────

  Future<Set<String>> _fetchDriverIds() async {
    final repo = sl<DriverRepository>();
    final list = await repo.getAll();
    return list.when(
      success: (l) => l.map((d) => d.id).toSet(),
      failure: (_) => {},
    );
  }

  Future<Set<String>> _fetchVehicleIds() async {
    final repo = sl<VehicleRepository>();
    final list = await repo.getAll();
    return list.when(
      success: (l) => l.map((v) => v.id).toSet(),
      failure: (_) => {},
    );
  }

  Future<Map<String, String>> _fetchCustomerCodes() async {
    final repo = sl<CustomerRepository>();
    final list = await repo.getAll();
    return list.when(
      success: (l) => {for (var c in l) c.customerCode: c.id},
      failure: (_) => {},
    );
  }

  Future<Map<String, String>> _fetchProductCodes() async {
    final repo = sl<ProductRepository>();
    final list = await repo.getAll();
    return list.when(
      success: (l) => {for (var p in l) p.productCode: p.id},
      failure: (_) => {},
    );
  }

  Future<Map<String, String>> _fetchExpenseNumbers() async {
    final repo = sl<ExpenseRepository>();
    final list = await repo.getAll();
    return list.when(
      success: (l) => {for (var e in l) e.expenseNumber: e.id},
      failure: (_) => {},
    );
  }
}

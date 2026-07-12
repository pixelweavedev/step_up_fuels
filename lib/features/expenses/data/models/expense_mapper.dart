import 'package:drift/drift.dart';
import 'package:step_up_fuels/app/database/app_database.dart';
import 'package:step_up_fuels/features/expenses/domain/entities/expense.dart';

extension ExpenseRowMapper on ExpenseRow {
  Expense toDomain() => Expense(
    id: id,
    expenseNumber: expenseNumber,
    category: category,
    amount: amount,
    expenseDate: expenseDate,
    paymentMode: paymentMode,
    paymentReference: paymentReference,
    vehicleId: vehicleId,
    driverId: driverId,
    billDocumentId: billDocumentId,
    notes: notes,
    createdBy: createdBy,
    createdAt: createdAt,
    updatedBy: updatedBy,
    updatedAt: updatedAt,
    deletedAt: deletedAt,
    version: version,
    tenantId: tenantId,
  );
}

extension ExpenseDomainMapper on Expense {
  ExpensesCompanion toCompanion() => ExpensesCompanion(
    id: Value(id),
    expenseNumber: Value(expenseNumber),
    category: Value(category),
    amount: Value(amount),
    expenseDate: Value(expenseDate),
    paymentMode: Value(paymentMode),
    paymentReference: Value(paymentReference),
    vehicleId: Value(vehicleId),
    driverId: Value(driverId),
    billDocumentId: Value(billDocumentId),
    notes: Value(notes),
    createdBy: Value(createdBy),
    createdAt: Value(createdAt),
    updatedBy: Value(updatedBy),
    updatedAt: Value(updatedAt),
    deletedAt: Value(deletedAt),
    version: Value(version),
    tenantId: Value(tenantId),
  );
}

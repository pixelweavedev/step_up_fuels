# 04 — Coding Standards

## File Naming

| Type | Convention | Example |
|---|---|---|
| Dart file | `snake_case.dart` | `customer_repository.dart` |
| Widget file | `snake_case_widget.dart` or `snake_case_screen.dart` | `customer_form_dialog.dart` |
| Test file | `snake_case_test.dart` | `customer_repository_test.dart` |

---

## Class Naming

| Type | Convention | Example |
|---|---|---|
| Class | `PascalCase` | `CustomerRepository` |
| Interface (abstract) | `PascalCase` (no I prefix) | `CustomerRepository` |
| Implementation | `PascalCaseImpl` | `CustomerRepositoryImpl` |
| Entity | `PascalCase` | `Customer` |
| Model (Drift/DTO) | `PascalCaseModel` or Drift-generated | `CustomersCompanion` |
| UseCase | `VerbNounUseCase` | `CreateCustomerUseCase` |
| Provider | `camelCaseProvider` | `customersListProvider` |
| Screen | `PascalCaseScreen` | `CustomersListScreen` |
| Widget | `PascalCaseWidget` | `CustomerCard` |
| Enum | `PascalCase` | `InvoiceStatus` |
| Enum value | `camelCase` | `InvoiceStatus.draft` |

---

## Layer Rules

### Presentation Layer
- ✅ Widgets, screens, dialogs
- ✅ Riverpod `ref.watch()` / `ref.read()`
- ❌ Never instantiate repositories directly
- ❌ Never call DAOs directly
- ❌ Never contain business logic (GST calculations, validations)
- Max widget file: **200 lines** — extract sub-widgets if longer

### Application Layer
- ✅ Use cases and `AsyncNotifier` providers
- ✅ Orchestrate domain services
- ✅ Coordinate cross-feature workflows
- ❌ Never import Flutter widgets
- ❌ Never import Drift or database packages

### Domain Layer
- ✅ Entities, repository interfaces, domain services, validators, value objects
- ✅ Pure Dart only
- ❌ **Zero Flutter imports**
- ❌ **Zero Drift imports**
- ❌ **Zero HTTP imports**
- Max file: **150 lines** — split into separate files if longer

### Data Layer
- ✅ Drift tables, DAOs, models, repository implementations
- ✅ Implement domain repository interfaces
- ❌ Never contain business logic

---

## SOLID Principles

### Single Responsibility
Each class has one job.
```dart
// ✅ Good — CustomerRepository only manages persistence
abstract class CustomerRepository {
  Future<Result<List<Customer>>> getAll();
  Future<Result<Customer>> getById(String id);
  Future<Result<void>> save(Customer customer);
  Future<Result<void>> delete(String id);
}

// ❌ Bad — mixing persistence with business logic
abstract class CustomerRepository {
  Future<Result<List<Customer>>> getAll();
  Future<Result<void>> validateGstin(String gstin); // belongs in domain service
  String generateCustomerCode(); // belongs in domain service
}
```

### Open/Closed
Add new behaviour by adding new classes, not by modifying existing ones.
Use domain events for cross-feature side effects.

### Liskov Substitution
Implementations must fully satisfy their abstract interface.

### Interface Segregation
Keep interfaces small and focused. Don't add methods to a repository
that only 1 use case needs.

### Dependency Inversion
Domain depends on abstractions. Data layer implements them.

---

## Result Type Usage

Always return `Result<T>` from repositories and use cases:

```dart
// Repository method
Future<Result<Customer>> getById(String id);

// Use case
Future<Result<Customer>> call(String id) async {
  final result = await _repository.getById(id);
  return result.when(
    success: (customer) => Result.success(customer),
    failure: (f) => Result.failure(f),
  );
}

// Provider / Notifier
Future<void> loadCustomer(String id) async {
  state = const AsyncValue.loading();
  final result = await _useCase(id);
  state = result.when(
    success: AsyncValue.data,
    failure: (f) => AsyncValue.error(f.message, StackTrace.current),
  );
}
```

---

## Validation Rules

- Validators live inside their **feature's `domain/validators/`** directory
- Validators return `String?` — `null` means valid, a string is the error message
- Never validate in widgets; pass the validator function as a parameter

```dart
// features/customers/domain/validators/customer_validator.dart
class CustomerValidator {
  static String? validateGstin(String? value) {
    if (value == null || value.isEmpty) return null; // GSTIN is optional
    final regex = RegExp(r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$');
    if (!regex.hasMatch(value)) return 'Invalid GSTIN format';
    return null;
  }
}
```

---

## State Machine Rules

Status transitions must be validated before being applied:

```dart
// features/invoices/domain/enums/invoice_status.dart
enum InvoiceStatus {
  draft,
  verified,
  posted,
  paid,
  partiallyPaid,
  overdue,
  cancelled;

  bool canTransitionTo(InvoiceStatus next) {
    return switch (this) {
      draft => next == verified || next == cancelled,
      verified => next == posted || next == cancelled,
      posted => next == paid || next == partiallyPaid || next == overdue || next == cancelled,
      partiallyPaid => next == paid || next == overdue || next == cancelled,
      overdue => next == paid || next == partiallyPaid || next == cancelled,
      paid => false, // terminal state
      cancelled => false, // terminal state
    };
  }
}
```

---

## Riverpod Provider Rules

- One provider file per feature area
- Provider names end with `Provider`
- Use `AsyncNotifierProvider` for server-fetched data
- Use `StateProvider` only for simple UI state (search query, selected tab)
- Use `Provider` for pure dependency injection (repositories, services)

```dart
// features/customers/presentation/providers/customers_provider.dart

final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  return ref.watch(customerRepositoryImplProvider);
});

final customersListProvider = AsyncNotifierProvider<CustomersListNotifier, List<Customer>>(
  CustomersListNotifier.new,
);

class CustomersListNotifier extends AsyncNotifier<List<Customer>> {
  @override
  Future<List<Customer>> build() async {
    final result = await ref.read(customerRepositoryProvider).getAll();
    return result.when(
      success: (list) => list,
      failure: (f) => throw f.message,
    );
  }
}
```

---

## Widget Rules

- Max widget build method: **50 lines**. Extract into named widgets or methods.
- All interactive elements have a `key` parameter
- Use `const` constructors everywhere possible
- Never use `BuildContext` across async gaps — store before await

```dart
// ✅ Good
Future<void> _handleSave(BuildContext context) async {
  final router = GoRouter.of(context); // capture before async
  await _saveData();
  router.pop();
}
```

---

## Naming Conventions Summary

```
features/invoices/
├── domain/
│   ├── entities/invoice.dart               # Invoice
│   ├── entities/invoice_item.dart          # InvoiceItem
│   ├── repositories/invoice_repository.dart # InvoiceRepository (abstract)
│   ├── services/invoice_service.dart        # InvoiceService
│   ├── services/gst_calculation_service.dart # GstCalculationService
│   ├── validators/invoice_validator.dart    # InvoiceValidator
│   └── enums/invoice_status.dart           # InvoiceStatus enum
├── application/
│   └── usecases/
│       ├── create_invoice_usecase.dart      # CreateInvoiceUseCase
│       └── post_invoice_usecase.dart        # PostInvoiceUseCase
├── data/
│   ├── tables/invoices_table.dart           # Invoices (Drift Table)
│   ├── tables/invoice_items_table.dart      # InvoiceItems (Drift Table)
│   ├── daos/invoices_dao.dart               # InvoicesDao
│   ├── models/invoice_model.dart            # InvoiceModel
│   └── repositories/invoice_repository_impl.dart # InvoiceRepositoryImpl
└── presentation/
    ├── providers/invoices_provider.dart     # invoicesListProvider, etc.
    ├── screens/invoices_list_screen.dart    # InvoicesListScreen
    ├── screens/invoice_detail_screen.dart   # InvoiceDetailScreen
    ├── widgets/invoice_card.dart            # InvoiceCard
    ├── widgets/invoice_form.dart            # InvoiceForm
    └── pdf/
        ├── invoice_pdf_generator.dart       # InvoicePdfGenerator
        └── invoice_print_service.dart       # InvoicePrintService
```

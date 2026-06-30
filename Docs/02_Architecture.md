# 02 — Architecture

## Architecture Philosophy

This application uses **Clean Architecture** with a **Feature-First** folder organization.

The four primary concerns are strictly separated:

```
Presentation  →  Application  →  Domain  →  Data
```

Each layer depends only on the layer below it. The domain layer has zero dependencies on Flutter, databases, or external packages.

---

## Layer Responsibilities

### Presentation Layer
- Flutter widgets, screens, dialogs
- Riverpod providers (UI state only)
- Receives data from Application layer
- Never contains business logic
- Never talks directly to repositories

### Application Layer
- Coordinates use cases
- Orchestrates domain services
- Handles cross-feature workflows (e.g., creating an invoice also triggers a stock movement)
- Riverpod `AsyncNotifier` providers that drive screens

### Domain Layer
- Pure Dart entities (no Flutter, no Drift, no HTTP)
- Abstract repository interfaces
- Domain services (complex business rules)
- Value objects (e.g., `GstIn`, `InvoiceNumber`)
- Feature-specific validators
- State machines (enums + transition rules)
- Domain events

### Data Layer
- Drift table definitions (SQLite)
- DAO implementations
- Model classes (Drift companions / future REST DTOs)
- Concrete repository implementations

---

## Folder Structure

```
lib/
├── main.dart
├── app/
│   ├── app.dart
│   ├── router/
│   │   ├── app_router.dart
│   │   └── route_names.dart
│   └── di/
│       └── injection_container.dart
│
├── core/
│   ├── constants/
│   │   ├── app_constants.dart
│   │   ├── gst_constants.dart        # GST rates, HSN codes
│   │   └── ui_constants.dart
│   ├── errors/
│   │   ├── failure.dart              # Failure sealed class hierarchy
│   │   └── exceptions.dart
│   ├── result/
│   │   └── result.dart               # Result<T> sealed class
│   ├── extensions/
│   │   ├── string_extensions.dart
│   │   ├── date_extensions.dart
│   │   ├── number_extensions.dart    # Indian currency formatting
│   │   └── context_extensions.dart
│   ├── utils/
│   │   ├── date_utils.dart
│   │   └── number_utils.dart
│   ├── theme/
│   │   ├── app_theme.dart
│   │   ├── app_colors.dart
│   │   ├── app_text_styles.dart
│   │   └── app_dimensions.dart
│   └── logging/
│       └── app_logger.dart
│
├── shared/
│   ├── widgets/
│   │   ├── app_scaffold.dart         # Desktop shell: sidebar + content
│   │   ├── sidebar/
│   │   ├── buttons/
│   │   ├── inputs/
│   │   ├── dialogs/
│   │   ├── cards/
│   │   ├── tables/
│   │   └── loaders/
│   └── providers/
│       └── theme_provider.dart
│
└── features/
    ├── customers/
    │   ├── domain/
    │   │   ├── entities/
    │   │   ├── repositories/         # Abstract interfaces
    │   │   ├── services/             # Domain services
    │   │   ├── validators/           # Feature validators
    │   │   └── value_objects/
    │   ├── application/
    │   │   └── usecases/
    │   ├── data/
    │   │   ├── tables/               # Drift table definitions
    │   │   ├── daos/                 # Data Access Objects
    │   │   ├── models/               # DTOs
    │   │   └── repositories/         # Implementations
    │   └── presentation/
    │       ├── providers/            # Riverpod providers
    │       ├── screens/
    │       └── widgets/
    │
    ├── products/           # Same structure
    ├── inventory/          # Same structure
    ├── purchases/          # Same structure
    ├── invoices/           # Same structure + pdf/ subfolder
    ├── payments/           # Same structure
    ├── ledger/             # Same structure
    ├── reports/            # Same structure
    ├── dashboard/          # Same structure
    └── settings/           # Same structure
```

---

## Technology Stack

| Concern | Package | Version | Reason |
|---|---|---|---|
| State Management | `flutter_riverpod` | ^2.x | Compile-safe, testable |
| Navigation | `go_router` | ^14.x | URL-based, declarative |
| Local Database | `drift` | ^2.x | Type-safe SQL, migration support |
| Dependency Injection | `get_it` | ^8.x | Async init, testable |
| Code Generation | `build_runner`, `drift_dev`, `freezed` | latest | |
| Immutable Models | `freezed` + `freezed_annotation` | ^2.x | Future-proof DTOs |
| JSON | `json_serializable` | ^6.x | REST-ready serialization |
| Logging | `logger` | ^2.x | Structured logs |
| PDF | `pdf` + `printing` | latest | Invoice generation |
| Charts | `fl_chart` | ^0.x | Dashboard analytics |
| Numbers | `intl` | ^0.x | Indian currency/date format |
| UUID | `uuid` | ^4.x | Cloud-sync ready IDs |
| Path | `path_provider` | ^2.x | Database file location |
| Equality | `equatable` | ^2.x | Value equality |
| Excel Export | `excel` | ^4.x | GSTR-1 export |

---

## Dependency Flow

```
┌─────────────────────────────────────┐
│           Presentation              │ ← Flutter Widgets, Riverpod UI Providers
└──────────────────┬──────────────────┘
                   │ depends on
┌──────────────────▼──────────────────┐
│            Application              │ ← Use Cases, Riverpod AsyncNotifiers
└──────────────────┬──────────────────┘
                   │ depends on
┌──────────────────▼──────────────────┐
│              Domain                 │ ← Entities, Repository Interfaces, Services
└──────────────────┬──────────────────┘
                   │ implemented by
┌──────────────────▼──────────────────┐
│               Data                  │ ← Drift, DAOs, Repository Implementations
└─────────────────────────────────────┘
```

---

## State Management Architecture

### Provider Hierarchy

```
ProviderScope (root)
│
├── databaseProvider              # Drift AppDatabase singleton
├── themeProvider                 # Light/Dark mode
│
├── customers/
│   ├── customersDaoProvider      # DAO (data)
│   ├── customerRepositoryProvider
│   ├── customersListProvider     # AsyncNotifier<List<Customer>>
│   └── selectedCustomerProvider  # StateProvider<Customer?>
│
├── invoices/
│   ├── invoicesDaoProvider
│   ├── invoiceRepositoryProvider
│   ├── invoiceServiceProvider    # Domain service
│   ├── gstCalculatorProvider
│   ├── invoicesListProvider
│   └── invoiceFormProvider       # StateNotifier for form state
│
└── ...
```

---

## Desktop Navigation Pattern

```
AppScaffold
├── Sidebar (always visible, left panel, 240px)
│   ├── Company logo + name
│   ├── NavItem: Dashboard
│   ├── NavItem: Customers
│   ├── NavItem: Products
│   ├── NavItem: Inventory
│   ├── NavItem: Purchases
│   ├── NavItem: Invoices
│   ├── NavItem: Payments
│   ├── NavItem: Ledger
│   ├── NavItem: Reports
│   └── NavItem: Settings
│
└── Content Area (fills remaining width)
    └── GoRouter Shell Route → Feature Screens
```

---

## Key Architectural Decisions

### 1. Feature-owned data

Each feature owns its own Drift tables, DAOs, models, and repository implementations. This prevents coupling and allows features to be developed and tested independently.

### 2. Ledger from day one

Every financial operation (invoice creation, payment receipt, purchase) creates a corresponding `LedgerEntry`. This ensures the system can always produce accurate P&L statements and customer outstanding reports without scanning unrelated tables.

### 3. Inventory as movements

Stock is never stored as a raw quantity. It is calculated from `InventoryMovement` records. This provides a complete audit trail and reconciliation capability.

### 4. Status state machines

Invoice status, purchase status, and payment status are modelled as explicit enums with valid transition rules enforced in domain services. Invalid state transitions are rejected at the domain layer.

### 5. Domain events

When critical business events occur (InvoicePosted, PaymentReceived, StockAdjusted), a domain event is emitted. Future modules (notifications, audit log, cloud sync) subscribe to these events without modifying existing code.

### 6. UUIDs as primary keys

All entities use UUID string primary keys. This enables local creation and future cloud merge without key conflicts.

# 12 — Future SaaS Architecture

## Vision

Step Up Fuels will evolve from a single-user offline desktop app into a **cloud-based multi-tenant SaaS ERP** without requiring architectural rewrites.

---

## Migration Path

### Stage 1 — Current (Offline Desktop)
```
Flutter Desktop App
        ↓
   Drift / SQLite
  (local database)
```

### Stage 2 — Cloud Backend (No UI changes)
```
Flutter Desktop App
        ↓
   Repository Interface (unchanged)
        ↓
   HTTP Repository Impl (new)  ←── replaces Local Repository Impl
        ↓
   Spring Boot REST API
        ↓
   PostgreSQL
```

### Stage 3 — Offline + Online Sync
```
Flutter App (Desktop + Mobile)
        ↓
   Hybrid Repository
   ├── Local: Drift (offline writes)
   └── Remote: Spring Boot (sync when online)
        ↓
   Conflict Resolution Service
        ↓
   PostgreSQL
```

---

## How the Repository Pattern Enables This

The domain layer only knows about the abstract interface:

```dart
// Domain — never changes
abstract class CustomerRepository {
  Future<Result<List<Customer>>> getAll();
  Future<Result<Customer>> getById(String id);
  Future<Result<void>> save(Customer customer);
}

// Phase 1 — Local
class CustomerRepositoryImpl implements CustomerRepository {
  final CustomersDao _dao;
  // ... Drift implementation
}

// Phase 2 — Remote (swap via GetIt)
class CustomerRemoteRepositoryImpl implements CustomerRepository {
  final ApiClient _client;
  // ... HTTP implementation
}

// Phase 3 — Hybrid
class CustomerHybridRepositoryImpl implements CustomerRepository {
  final CustomerRepositoryImpl _local;
  final CustomerRemoteRepositoryImpl _remote;
  // ... sync logic
}
```

The Flutter UI never changes. Only the binding in `injection_container.dart` changes.

---

## Multi-Tenancy Design

### Tenant Isolation (future)
Each company is a tenant. All tables will add:
```sql
company_id  UUID NOT NULL  -- tenant identifier
branch_id   UUID           -- branch within company
```

Row-level isolation enforced at the API layer (Spring Boot) and by PostgreSQL Row Level Security (RLS).

### UUID Primary Keys
Already in place — UUIDs work across tenants without conflict.

---

## Domain Events → Cloud Events

The `domain_events` table becomes a message bus:

```
Local DomainEvent
      ↓
EventBus (in-process, Phase 1)
      ↓ (Phase 3+)
EventBus → Kafka / RabbitMQ
      ↓
Microservices (Notifications, Audit, Analytics)
```

---

## Spring Boot API Design

```
/api/v1/customers
/api/v1/customers/{id}/sites
/api/v1/customers/{id}/contacts
/api/v1/products
/api/v1/inventory/stock
/api/v1/inventory/movements
/api/v1/invoices
/api/v1/payments
/api/v1/ledger
/api/v1/reports/gstr1
/api/v1/reports/sales
```

All responses follow:
```json
{
  "success": true,
  "data": { ... },
  "message": null,
  "timestamp": "2024-06-30T10:00:00Z"
}
```

---

## RBAC (Role-Based Access Control)

| Role | Permissions |
|---|---|
| Owner | Full access |
| Manager | All operations except delete |
| Billing Clerk | Create/edit invoices, view customers |
| Accountant | View invoices, manage payments, view reports |
| Inventory Manager | Manage purchases and stock |
| Viewer | Read-only access to all modules |

Future implementation uses JWT tokens with embedded roles, validated at both API and UI layers.

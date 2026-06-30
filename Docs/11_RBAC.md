# 11 — RBAC (Role-Based Access Control)

## Overview

RBAC will be implemented in Phase 15 (cloud backend). The architecture is designed
to support it from day one without breaking existing code.

---

## Roles

| Role | Scope | Key Permissions |
|---|---|---|
| Owner | Company | Full access, can manage users |
| Manager | Company | Full operational access, no user management |
| Billing Clerk | Feature | Create/edit invoices, view customers |
| Accountant | Feature | Payments, ledger, reports (read-only invoices) |
| Inventory Manager | Feature | Purchases, inventory, products |
| Viewer | Company | Read-only access to all modules |

---

## Permission Model

```dart
enum Permission {
  // Customers
  customerRead,
  customerCreate,
  customerUpdate,
  customerDelete,

  // Invoices
  invoiceRead,
  invoiceCreate,
  invoicePost,
  invoiceCancel,

  // Payments
  paymentRead,
  paymentCreate,

  // Inventory
  inventoryRead,
  inventoryAdjust,

  // Purchases
  purchaseRead,
  purchaseCreate,

  // Reports
  reportView,
  reportExport,

  // Settings
  settingsView,
  settingsUpdate,

  // Users (future)
  userManage,
}
```

---

## Implementation Plan (Future)

### Phase 15a — Auth Service
- JWT-based authentication via Spring Boot
- Token refresh flow
- Session management

### Phase 15b — Permission Guards
```dart
class PermissionGuard {
  static bool can(User user, Permission permission) {
    return user.role.permissions.contains(permission);
  }
}
```

### Phase 15c — UI Guards
```dart
// In presentation layer only — NEVER the only protection
class PermissionWidget extends ConsumerWidget {
  const PermissionWidget({
    required this.permission,
    required this.child,
    this.fallback = const SizedBox.shrink(),
  });
  // ...
}
```

### Phase 15d — GoRouter Guards
```dart
redirect: (context, state) {
  if (!authState.isAuthenticated) return '/login';
  if (!PermissionGuard.can(authState.user, requiredPermission)) return '/unauthorized';
  return null;
},
```

---

## Multi-Tenant Isolation

In the SaaS phase, all database queries will include:
```sql
WHERE company_id = :current_company_id
  AND branch_id = :current_branch_id
```

This is enforced at the repository layer and by PostgreSQL Row Level Security.

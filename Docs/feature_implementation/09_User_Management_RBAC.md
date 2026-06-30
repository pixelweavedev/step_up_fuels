# 09 — User Management & RBAC Design

## Overview
User Management provides authentication and role-based access control (RBAC). In the current local desktop environment, it supports password-less PIN logins for operators and drivers, and username/password for admins/accountants. Structurally, it matches cloud standards so it can transition to JWT-based backend authentication.

---

## Domain Entities

### User
```dart
class User {
  final String id;                    // UUID
  final String username;
  final String email;
  final String? phone;
  final String role;                  // ADMIN, ACCOUNTANT, OPERATOR, DRIVER
  final String? pinHash;              // For quick lock-screen PIN login on terminals
  final String? passwordHash;
  final bool isActive;

  // Auditing & SaaS Scope
  final String createdBy;
  final DateTime createdAt;
  final String updatedBy;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int version;
  final String? tenantId;
}
```

### Role & Permissions Mapping
Permissions are defined as fine-grained actions:
```dart
enum UserPermission {
  customerView, customerCreate, customerEdit, customerDelete,
  invoiceView, invoiceCreate, invoicePost, invoiceCancel,
  inventoryView, inventoryLoad, inventoryAdjust,
  purchaseView, purchaseCreate,
  expenseView, expenseCreate,
  paymentView, paymentCreate,
  reportView, reportExport,
  userManage, settingsEdit
}
```

#### Roles
1. **ADMIN**: Full access to all permissions.
2. **ACCOUNTANT**: Access to customer, invoice (read-only), payment, expense, ledger, reports. No inventory adjustments.
3. **OPERATOR**: Access to deliveries (create), invoices (draft/verify), vehicles, stock loading.
4. **DRIVER**: (Future) Mobile access to dispatch assignments and site deliveries.

---

## Database Drift Schema Details

```dart
@DataClassName('UserRow')
class Users extends Table {
  TextColumn get id => text()();
  TextColumn get username => text().unique()();
  TextColumn get email => text().unique()();
  TextColumn get phone => text().nullable()();
  TextColumn get role => text()(); // ADMIN, ACCOUNTANT, OPERATOR, DRIVER
  TextColumn get pinHash => text().nullable()();
  TextColumn get passwordHash => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  // Auditing & SaaS
  TextColumn get createdBy => text().withDefault(const Constant('system'))();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get updatedBy => text().withDefault(const Constant('system'))();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  TextColumn get tenantId => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
```

---

## Security Integration (Guards)

### UI Security Guard
A presentation widget to conditionally show or hide buttons/fields:
```dart
class PermissionGuardWidget extends ConsumerWidget {
  final UserPermission permission;
  final Widget child;
  final Widget fallback;

  const PermissionGuardWidget({
    super.key,
    required this.permission,
    required this.child,
    this.fallback = const SizedBox.shrink(),
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    if (currentUser == null) return fallback;
    final hasPermission = _checkPermission(currentUser.role, permission);
    return hasPermission ? child : fallback;
  }
}
```

### Application Security Guard
Use-cases verify permissions prior to execution:
```dart
abstract class AuthenticatedUseCase<Params, Type> {
  final UserSessionProvider sessionProvider;
  
  AuthenticatedUseCase(this.sessionProvider);

  Future<Result<Type>> call(Params params) async {
    final user = sessionProvider.getCurrentUser();
    if (user == null) return Result.failure(Failure.unauthenticated());
    
    if (!hasRequiredPermission(user.role)) {
      return Result.failure(Failure.unauthorized("Insufficient permissions"));
    }
    
    return execute(params, user);
  }

  bool hasRequiredPermission(String role);
  Future<Result<Type>> execute(Params params, User currentUser);
}
```

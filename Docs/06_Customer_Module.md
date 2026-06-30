# 06 — Customer Module

## Overview

The Customer module is the foundation of the ERP. Every invoice and payment is linked to a customer.

---

## Domain Entities

### Customer
```dart
class Customer {
  final String id;              // UUID
  final String customerCode;    // e.g. CUST-001
  final String name;
  final String? tradeName;
  final String? gstin;          // validated GSTIN
  final String? pan;
  final CustomerType type;      // company, individual, government
  final double creditLimit;
  final int creditDays;
  final bool isActive;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

### CustomerSite
```dart
class CustomerSite {
  final String id;
  final String customerId;
  final String name;            // e.g. "Project Alpha Site"
  final String? addressLine1;
  final String? city;
  final String? state;
  final String? stateCode;
  final String? pincode;
  final bool isDefault;
}
```

### CustomerContact
```dart
class CustomerContact {
  final String id;
  final String customerId;
  final String name;
  final String? designation;
  final String? phone;
  final String? email;
  final bool isPrimary;
}
```

---

## Feature Validators (in domain/validators/)

```dart
class CustomerValidator {
  static String? validateName(String? value);
  static String? validateGstin(String? value);
  static String? validatePan(String? value);
  static String? validatePhone(String? value);
  static String? validateEmail(String? value);
  static String? validateCreditLimit(String? value);
}
```

---

## Repository Interface

```dart
abstract class CustomerRepository {
  Future<Result<List<Customer>>> getAll({bool includeDeleted = false});
  Future<Result<List<Customer>>> search(String query);
  Future<Result<Customer>> getById(String id);
  Future<Result<void>> save(Customer customer);
  Future<Result<void>> softDelete(String id);
  Future<Result<void>> restore(String id);

  Future<Result<List<CustomerSite>>> getSitesForCustomer(String customerId);
  Future<Result<void>> saveSite(CustomerSite site);
  Future<Result<void>> deleteSite(String id);

  Future<Result<List<CustomerContact>>> getContactsForCustomer(String customerId);
  Future<Result<void>> saveContact(CustomerContact contact);
  Future<Result<void>> deleteContact(String id);
}
```

---

## Domain Service

```dart
class CustomerCreditService {
  /// Checks if a customer has exceeded their credit limit.
  Future<Result<bool>> isWithinCreditLimit({
    required String customerId,
    required double newInvoiceAmount,
  });

  /// Returns outstanding balance for a customer.
  Future<Result<double>> getOutstanding(String customerId);
}
```

---

## Use Cases

| Use Case | Trigger |
|---|---|
| `CreateCustomerUseCase` | User submits new customer form |
| `UpdateCustomerUseCase` | User edits customer details |
| `SoftDeleteCustomerUseCase` | User clicks delete |
| `RestoreCustomerUseCase` | User restores from deleted list |
| `GetCustomersUseCase` | Screen loads, search query changes |
| `GetCustomerDetailUseCase` | User opens customer detail |

---

## UI Screens

### Customer List Screen
- Search bar (real-time)
- Filter by type / status
- Sort by name / code / outstanding
- Customer cards in a data table
- "Add Customer" primary button
- Pagination-ready (renders current page, has next/prev)

### Customer Detail Screen (Master-Detail)
- Left: Customer info card
- Right: Tabs → Sites | Contacts | Invoices | Payments | Notes
- Edit button (opens form dialog)
- Status badge (Active / Inactive / Deleted)

### Customer Form Dialog
- Tabs: Basic Info | GST Details | Credit | Additional
- All fields validated on submit
- Auto-generates customer code

---

## Drift Tables

| Table | Key Columns |
|---|---|
| `customers` | id, customer_code, name, gstin, credit_limit, deleted_at |
| `customer_sites` | id, customer_id, name, address, state_code, is_default |
| `customer_contacts` | id, customer_id, name, phone, email, is_primary |
| `customer_credit_limits` | id, customer_id, credit_limit, effective_from |

# 03 — Database Design

## Philosophy

- **No soft data, ever** — Stock levels are calculated from movement records, never stored as mutable quantities.
- **Ledger entries for every financial event** — Invoices, payments, and purchases all produce ledger entries automatically.
- **UUID primary keys everywhere** — Enables local-first creation and future cloud merge without conflicts.
- **Soft deletes on all master records** — `deleted_at` timestamp instead of hard removal.
- **Audit fields on all tables** — `created_at`, `updated_at`, `created_by` on every entity.
- **PostgreSQL-compatible schema** — Drift SQLite schema mirrors PostgreSQL types so the ORM swap is minimal.

---

## Entity Overview

| # | Table | Feature | Type |
|---|---|---|---|
| 1 | `company_profile` | Settings | Master |
| 2 | `customers` | Customers | Master |
| 3 | `customer_sites` | Customers | Detail |
| 4 | `customer_contacts` | Customers | Detail |
| 5 | `customer_credit_limits` | Customers | Detail |
| 6 | `products` | Products | Master |
| 7 | `inventory_movements` | Inventory | Transaction |
| 8 | `stock_adjustments` | Inventory | Transaction |
| 9 | `suppliers` | Purchases | Master |
| 10 | `purchases` | Purchases | Transaction |
| 11 | `purchase_items` | Purchases | Detail |
| 12 | `invoices` | Invoices | Transaction |
| 13 | `invoice_items` | Invoices | Detail |
| 14 | `payments` | Payments | Transaction |
| 15 | `ledger_entries` | Ledger | Transaction |
| 16 | `ledger_accounts` | Ledger | Master |
| 17 | `domain_events` | Audit | Event Log |
| 18 | `app_settings` | Settings | Config |

---

## Detailed Entity Definitions

### company_profile
```
id              UUID PK
name            TEXT NOT NULL
trade_name      TEXT
gstin           TEXT NOT NULL UNIQUE
pan             TEXT
address_line1   TEXT
address_line2   TEXT
city            TEXT
state           TEXT
state_code      TEXT   -- GST state code (e.g. 27 for Maharashtra)
pincode         TEXT
phone           TEXT
email           TEXT
bank_name       TEXT
bank_account_no TEXT
bank_ifsc       TEXT
bank_branch     TEXT
logo_path       TEXT   -- local file path
invoice_prefix  TEXT DEFAULT 'INV'
invoice_counter INTEGER DEFAULT 0
created_at      DATETIME
updated_at      DATETIME
```

### customers
```
id              UUID PK
customer_code   TEXT UNIQUE   -- auto-generated e.g. CUST-001
name            TEXT NOT NULL
trade_name      TEXT
gstin           TEXT
pan             TEXT
customer_type   TEXT          -- COMPANY, INDIVIDUAL, GOVERNMENT
credit_limit    REAL DEFAULT 0
credit_days     INTEGER DEFAULT 0
is_active       BOOLEAN DEFAULT TRUE
notes           TEXT
deleted_at      DATETIME
created_at      DATETIME NOT NULL
updated_at      DATETIME NOT NULL
created_by      TEXT DEFAULT 'system'
```

### customer_sites
```
id              UUID PK
customer_id     UUID FK → customers.id
name            TEXT NOT NULL   -- e.g. "Project Site A"
address_line1   TEXT
address_line2   TEXT
city            TEXT
state           TEXT
state_code      TEXT
pincode         TEXT
is_default      BOOLEAN DEFAULT FALSE
is_active       BOOLEAN DEFAULT TRUE
deleted_at      DATETIME
created_at      DATETIME NOT NULL
updated_at      DATETIME NOT NULL
```

### customer_contacts
```
id              UUID PK
customer_id     UUID FK → customers.id
name            TEXT NOT NULL
designation     TEXT
phone           TEXT
email           TEXT
is_primary      BOOLEAN DEFAULT FALSE
is_active       BOOLEAN DEFAULT TRUE
deleted_at      DATETIME
created_at      DATETIME NOT NULL
updated_at      DATETIME NOT NULL
```

### customer_credit_limits
```
id              UUID PK
customer_id     UUID FK → customers.id
credit_limit    REAL NOT NULL
effective_from  DATE NOT NULL
notes           TEXT
created_at      DATETIME NOT NULL
created_by      TEXT
```

### products
```
id              UUID PK
product_code    TEXT UNIQUE   -- e.g. HSD-001
name            TEXT NOT NULL
description     TEXT
hsn_code        TEXT NOT NULL   -- e.g. 2710 for HSD
unit_of_measure TEXT NOT NULL   -- KL, LTRS
gst_rate        REAL NOT NULL   -- 0.18 for 18%
cgst_rate       REAL            -- 0.09
sgst_rate       REAL            -- 0.09
igst_rate       REAL            -- 0.18
current_selling_price REAL
is_active       BOOLEAN DEFAULT TRUE
deleted_at      DATETIME
created_at      DATETIME NOT NULL
updated_at      DATETIME NOT NULL
```
> **Note**: Stock is NOT stored here. It is computed from `inventory_movements`.

### inventory_movements
```
id              UUID PK
product_id      UUID FK → products.id
movement_type   TEXT NOT NULL   -- PURCHASE_IN, INVOICE_OUT, ADJUSTMENT_IN, ADJUSTMENT_OUT, OPENING_STOCK
quantity        REAL NOT NULL   -- always positive; direction determined by movement_type
reference_id    UUID            -- purchase_id or invoice_id or adjustment_id
reference_type  TEXT            -- PURCHASE, INVOICE, ADJUSTMENT
movement_date   DATE NOT NULL
notes           TEXT
created_at      DATETIME NOT NULL
created_by      TEXT
```

### stock_adjustments
```
id              UUID PK
product_id      UUID FK → products.id
adjustment_type TEXT NOT NULL   -- GAIN, LOSS, PHYSICAL_COUNT
quantity        REAL NOT NULL
reason          TEXT NOT NULL
adjustment_date DATE NOT NULL
approved_by     TEXT
created_at      DATETIME NOT NULL
created_by      TEXT
```

### suppliers
```
id              UUID PK
name            TEXT NOT NULL
gstin           TEXT
pan             TEXT
address         TEXT
city            TEXT
state           TEXT
phone           TEXT
email           TEXT
contact_person  TEXT
is_active       BOOLEAN DEFAULT TRUE
deleted_at      DATETIME
created_at      DATETIME NOT NULL
updated_at      DATETIME NOT NULL
```

### purchases
```
id              UUID PK
purchase_number TEXT UNIQUE   -- auto-generated
supplier_id     UUID FK → suppliers.id
supplier_invoice_no TEXT
purchase_date   DATE NOT NULL
subtotal        REAL NOT NULL
cgst_amount     REAL DEFAULT 0
sgst_amount     REAL DEFAULT 0
igst_amount     REAL DEFAULT 0
total_amount    REAL NOT NULL
payment_status  TEXT NOT NULL   -- PENDING, PARTIAL, PAID
notes           TEXT
created_at      DATETIME NOT NULL
updated_at      DATETIME NOT NULL
created_by      TEXT
```

### purchase_items
```
id              UUID PK
purchase_id     UUID FK → purchases.id
product_id      UUID FK → products.id
description     TEXT
quantity        REAL NOT NULL
rate            REAL NOT NULL
gst_rate        REAL NOT NULL
taxable_amount  REAL NOT NULL
cgst_amount     REAL DEFAULT 0
sgst_amount     REAL DEFAULT 0
igst_amount     REAL DEFAULT 0
total_amount    REAL NOT NULL
```

### invoices
```
id              UUID PK
invoice_number  TEXT UNIQUE NOT NULL   -- e.g. SUF/2024-25/001
customer_id     UUID FK → customers.id
customer_site_id UUID FK → customer_sites.id (nullable)
invoice_date    DATE NOT NULL
due_date        DATE
supply_type     TEXT NOT NULL   -- B2B, B2C
place_of_supply TEXT NOT NULL   -- state code
is_igst         BOOLEAN DEFAULT FALSE   -- interstate = IGST
subtotal        REAL NOT NULL
taxable_amount  REAL NOT NULL
cgst_amount     REAL DEFAULT 0
sgst_amount     REAL DEFAULT 0
igst_amount     REAL DEFAULT 0
total_amount    REAL NOT NULL
amount_paid     REAL DEFAULT 0
outstanding     REAL NOT NULL   -- = total_amount - amount_paid
status          TEXT NOT NULL   -- DRAFT, VERIFIED, POSTED, PAID, PARTIALLY_PAID, OVERDUE, CANCELLED
notes           TEXT
cancelled_at    DATETIME
cancelled_reason TEXT
created_at      DATETIME NOT NULL
updated_at      DATETIME NOT NULL
created_by      TEXT
```

### invoice_items
```
id              UUID PK
invoice_id      UUID FK → invoices.id
product_id      UUID FK → products.id
hsn_code        TEXT NOT NULL
description     TEXT NOT NULL
quantity        REAL NOT NULL
unit            TEXT NOT NULL
rate            REAL NOT NULL
taxable_amount  REAL NOT NULL
gst_rate        REAL NOT NULL
cgst_rate       REAL DEFAULT 0
sgst_rate       REAL DEFAULT 0
igst_rate       REAL DEFAULT 0
cgst_amount     REAL DEFAULT 0
sgst_amount     REAL DEFAULT 0
igst_amount     REAL DEFAULT 0
total_amount    REAL NOT NULL
sort_order      INTEGER DEFAULT 0
```

### payments
```
id              UUID PK
payment_number  TEXT UNIQUE
invoice_id      UUID FK → invoices.id (nullable — can be advance)
customer_id     UUID FK → customers.id
amount          REAL NOT NULL
payment_date    DATE NOT NULL
payment_mode    TEXT NOT NULL   -- CASH, CHEQUE, NEFT, RTGS, UPI
reference_no    TEXT            -- cheque no / transaction ID
bank_name       TEXT
notes           TEXT
created_at      DATETIME NOT NULL
updated_at      DATETIME NOT NULL
created_by      TEXT
```

### ledger_accounts
```
id              UUID PK
account_code    TEXT UNIQUE
name            TEXT NOT NULL
account_type    TEXT NOT NULL   -- CUSTOMER, SUPPLIER, CASH, BANK, SALES, PURCHASE, TAX
reference_id    UUID            -- customer_id or supplier_id (for linked accounts)
reference_type  TEXT
is_system       BOOLEAN DEFAULT FALSE   -- system accounts cannot be deleted
is_active       BOOLEAN DEFAULT TRUE
created_at      DATETIME NOT NULL
```

### ledger_entries
```
id              UUID PK
ledger_account_id UUID FK → ledger_accounts.id
entry_date      DATE NOT NULL
description     TEXT NOT NULL
debit_amount    REAL DEFAULT 0
credit_amount   REAL DEFAULT 0
reference_id    UUID            -- invoice_id / payment_id / purchase_id
reference_type  TEXT            -- INVOICE, PAYMENT, PURCHASE
running_balance REAL            -- computed, denormalized for performance
created_at      DATETIME NOT NULL
created_by      TEXT
```

### domain_events
```
id              UUID PK
event_type      TEXT NOT NULL   -- InvoicePosted, PaymentReceived, StockAdjusted, etc.
aggregate_id    UUID NOT NULL   -- the entity this event refers to
aggregate_type  TEXT NOT NULL   -- Invoice, Payment, Customer, etc.
payload         TEXT NOT NULL   -- JSON
occurred_at     DATETIME NOT NULL
processed       BOOLEAN DEFAULT FALSE
processed_at    DATETIME
```

### app_settings
```
key             TEXT PK
value           TEXT NOT NULL
updated_at      DATETIME NOT NULL
```

---

## Relationships

```
customers ──< customer_sites
customers ──< customer_contacts
customers ──< customer_credit_limits
customers ──< invoices
customers ──< payments
customers ──< ledger_entries (via ledger_accounts)

suppliers ──< purchases

products ──< purchase_items
products ──< invoice_items
products ──< inventory_movements

purchases ──< purchase_items
purchases ──< inventory_movements (via reference_id)

invoices ──< invoice_items
invoices ──< payments
invoices ──< inventory_movements (via reference_id)
invoices ──< ledger_entries (via reference_id)

payments ──< ledger_entries (via reference_id)

ledger_accounts ──< ledger_entries

stock_adjustments ──< inventory_movements (via reference_id)
```

---

## Current Stock Calculation

```sql
SELECT 
  product_id,
  SUM(
    CASE 
      WHEN movement_type IN ('PURCHASE_IN', 'ADJUSTMENT_IN', 'OPENING_STOCK') THEN quantity
      WHEN movement_type IN ('INVOICE_OUT', 'ADJUSTMENT_OUT') THEN -quantity
    END
  ) AS current_stock
FROM inventory_movements
WHERE product_id = ?
GROUP BY product_id
```

---

## Customer Outstanding Calculation

```sql
SELECT 
  SUM(outstanding) AS total_outstanding
FROM invoices
WHERE customer_id = ? 
  AND status NOT IN ('PAID', 'CANCELLED')
```

---

## Schema Version

| Version | Changes |
|---|---|
| 1 | Initial schema: all Phase 1 tables |

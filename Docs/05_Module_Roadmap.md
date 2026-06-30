# 05 — Module Roadmap

## Phase 1 — Project Foundation ← CURRENT
**Goal**: Compilable app shell, zero features implemented

- [ ] pubspec.yaml — all dependencies
- [ ] Strict analysis_options.yaml
- [ ] Core infrastructure (Result, Failure, extensions, utils)
- [ ] App theme (light + dark, premium design)
- [ ] App router (GoRouter, shell route, all route stubs)
- [ ] Dependency injection (GetIt)
- [ ] Drift database (minimal — settings table only)
- [ ] Desktop scaffold (sidebar + content area)
- [ ] Shared widget library
- [ ] Placeholder screens for all 10 modules
- [ ] Structured logging

**Done when**: `flutter run` launches the app with sidebar navigation and no compile errors.

---

## Phase 2 — Customer Module
**Goal**: Full customer management with sites, contacts, credit

- [ ] `customers` Drift table + DAO
- [ ] `customer_sites` Drift table + DAO
- [ ] `customer_contacts` Drift table + DAO
- [ ] `customer_credit_limits` Drift table + DAO
- [ ] Customer domain entities + repository interface
- [ ] CustomerValidator (GSTIN, PAN, phone, email)
- [ ] CRUD use cases (Create, Update, SoftDelete, Restore)
- [ ] CustomerRepository implementation
- [ ] Riverpod providers
- [ ] Customer list screen (search, filter, pagination-ready)
- [ ] Customer detail screen (master-detail layout)
- [ ] Customer form dialog (create + edit)
- [ ] Sites management sub-screen
- [ ] Contacts management sub-screen
- [ ] Customer credit status widget

**Done when**: Can create, view, edit, and soft-delete customers with all related data.

---

## Phase 3 — Products & Inventory
**Goal**: Product catalog + real-time stock from movements

- [ ] `products` Drift table + DAO
- [ ] `inventory_movements` Drift table + DAO
- [ ] `stock_adjustments` Drift table + DAO
- [ ] `suppliers` Drift table + DAO
- [ ] Product domain entities + repository interface
- [ ] InventoryMovement entity + repository interface
- [ ] InventoryService (calculateStock, recordMovement)
- [ ] Product CRUD use cases
- [ ] Inventory use cases (OpeningStock, AdjustStock, GetCurrentStock)
- [ ] Product list + detail screens
- [ ] Inventory dashboard (current stock, low stock warnings)
- [ ] Stock adjustment screen
- [ ] Inventory movement history screen

**Done when**: Can manage products and see real-time stock levels updated by movements.

---

## Phase 4 — GST Invoice Generation
**Goal**: Complete GST-compliant invoicing with PDF generation

- [ ] `invoices` Drift table + DAO
- [ ] `invoice_items` Drift table + DAO
- [ ] Invoice domain entities (Invoice, InvoiceItem)
- [ ] InvoiceStatus state machine
- [ ] GstCalculationService (CGST/SGST/IGST, interstate detection)
- [ ] InvoiceNumberGenerator (financial year aware)
- [ ] InvoiceService (create, verify, post, cancel)
- [ ] Invoice repository + implementation
- [ ] InvoiceValidator
- [ ] PostInvoiceUseCase (triggers inventory movement + ledger entry)
- [ ] Invoice list screen
- [ ] Invoice creation screen (dynamic line items, live GST calculation)
- [ ] Invoice detail / preview screen
- [ ] InvoicePdfGenerator (matches sample invoice format)
- [ ] InvoicePrintService
- [ ] PDF share / save to file

**Done when**: Can create, post, and print a GST invoice that matches the sample format exactly.

---

## Phase 5 — Purchases
**Goal**: Record fuel purchases, auto-update inventory

- [ ] `purchases` Drift table + DAO
- [ ] `purchase_items` Drift table + DAO
- [ ] Purchase domain entities
- [ ] PurchaseService (record purchase → inventory movement)
- [ ] Purchase CRUD use cases
- [ ] Purchase list + detail screens
- [ ] Purchase form (add items, GST calculation)
- [ ] Supplier management

**Done when**: Recording a purchase automatically increments stock.

---

## Phase 6 — Payments
**Goal**: Track customer payments, link to invoices

- [ ] `payments` Drift table + DAO
- [ ] `ledger_entries` Drift table + DAO
- [ ] `ledger_accounts` Drift table + DAO
- [ ] Payment domain entities
- [ ] LedgerService (createEntry, getBalance, getCustomerStatement)
- [ ] PaymentService (receivePayment → ledger entry + invoice update)
- [ ] Payment CRUD use cases
- [ ] Payments list screen
- [ ] Payment form (link to invoice or advance)
- [ ] Customer statement view
- [ ] Ledger screen

**Done when**: Receiving a payment updates invoice outstanding and ledger.

---

## Phase 7 — Reports
**Goal**: Essential business reports + GST export

- [ ] Sales report (by date, customer, product)
- [ ] GST report (GSTR-1 format)
- [ ] Stock report (current + movement history)
- [ ] Payment aging report (0-30, 31-60, 61-90, 90+ days)
- [ ] Customer ledger report
- [ ] Excel export for GSTR-1
- [ ] PDF export for all reports

**Done when**: All reports generate correctly and GSTR-1 data exports to Excel.

---

## Phase 8 — Dashboard
**Goal**: Real-time KPI summary at a glance

- [ ] Revenue this month / year
- [ ] Outstanding receivables
- [ ] Current stock levels
- [ ] Recent invoices
- [ ] Recent payments
- [ ] Low stock alerts
- [ ] Top customers by revenue
- [ ] Charts (fl_chart)

**Done when**: Dashboard shows accurate live data from all modules.

---

## Phase 9 — Settings
**Goal**: Company profile, invoice config, app preferences

- [ ] Company profile (name, GSTIN, address, bank details, logo)
- [ ] Invoice settings (prefix, starting number, terms, notes)
- [ ] Print settings (paper size, margins)
- [ ] Theme settings (light/dark)
- [ ] Backup (export database)
- [ ] Restore from backup

**Done when**: All company data is configurable and reflected in invoices.

---

## Future Phases

| Phase | Module |
|---|---|
| 10 | Vehicle Management |
| 11 | Driver Management |
| 12 | Fuel Dispatch |
| 13 | e-Invoice (IRP API) |
| 14 | e-Way Bill |
| 15 | Multi-user Auth + RBAC |
| 16 | Audit Log module |
| 17 | Cloud sync (Spring Boot backend) |
| 18 | Multi-branch |
| 19 | Multi-company SaaS |

# 01 — Project Vision

## Overview

**Step Up Fuels** is a Fuel Distribution Management ERP for an Indian diesel distribution company.

The company purchases diesel from authorized suppliers and delivers fuel to customers — construction companies, factories, industries, infrastructure projects, and government organizations — using portable fuel bowsers.

---

## Mission

Build a **production-grade, GST-compliant ERP system** that:

- Replaces manual billing and stock management
- Provides real-time financial visibility
- Generates government-compliant GST invoices and reports
- Scales from a single offline desktop app to a multi-user cloud SaaS platform

---

## Business Context

| Aspect | Detail |
|---|---|
| Industry | Fuel distribution / petroleum |
| Country | India |
| Tax Regime | GST (Goods and Services Tax) |
| Primary Product | HSD (High Speed Diesel) |
| Delivery Method | Portable fuel bowsers |
| Customer Types | Construction, factories, industries, government |

---

## Phase 1 — Offline Desktop ERP

- Single-user Windows desktop application
- Local SQLite database (Drift ORM)
- Full billing, inventory, and payment management
- GST invoice generation and PDF printing
- No internet dependency

## Phase 2 — Cloud-Ready SaaS

- Spring Boot REST API backend
- PostgreSQL database
- Multi-user with Role-Based Access Control (RBAC)
- Offline-sync capability
- e-Invoice / e-Way Bill government API integration
- Multi-branch and multi-company support

---

## Core Principles

1. **Offline First** — The application works 100% without internet
2. **GST Compliant** — Every transaction follows Indian GST law
3. **Audit Everything** — No data is ever hard-deleted; all changes are logged
4. **Domain Integrity** — Business rules live in the domain layer, never in UI
5. **Future-Proof** — Every design decision considers cloud migration

---

## Business Modules

### Current Scope (Phase 1)

| Module | Priority |
|---|---|
| Customer Management | Critical |
| Product Management | Critical |
| Inventory / Stock | Critical |
| Purchases | Critical |
| GST Invoice Generation | Critical |
| Payment Tracking | Critical |
| Ledger | Critical |
| Reports | High |
| Dashboard | High |
| Settings / Company Profile | High |

### Future Scope (Phase 2+)

| Module | Priority |
|---|---|
| Vehicle Management | High |
| Driver Management | High |
| Fuel Dispatch | High |
| Delivery Challans | High |
| Purchase Orders | Medium |
| e-Invoice Integration | High |
| e-Way Bill | High |
| Multi-user Auth | Critical |
| RBAC | Critical |
| Audit Logs | High |
| Notifications | Medium |
| Multi-branch | Medium |
| Multi-company SaaS | Low |

---

## Success Criteria

- [ ] Generate a GST-compliant tax invoice in under 60 seconds
- [ ] Real-time stock levels visible from the dashboard
- [ ] Zero data loss — every transaction recorded permanently
- [ ] PDF invoices match the company's approved invoice format
- [ ] GSTR-1 data exportable as Excel
- [ ] Application loads in under 3 seconds on standard hardware

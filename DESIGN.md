---
name: Step Up Fuels
description: Indian Fuel Distribution ERP System
colors:
  primary: "#D07A28"
  primary-light: "#E59C5C"
  primary-dark: "#B05F19"
  navy: "#0F172A"
  navy-mid: "#374151"
  surface-light: "#FFFFFF"
  surface-dark: "#1E293B"
  background-light: "#F6F2EB"
  background-dark: "#0F172A"
  border-light: "#E6E2DA"
  border-dark: "#334155"
  text-primary-light: "#0F172A"
  text-primary-dark: "#F8FAFC"
  text-secondary-light: "#334155"
  text-secondary-dark: "#CBD5E1"
  text-tertiary-light: "#5F6E82"
  text-tertiary-dark: "#94A3B8"
  success: "#2E7D32"
  warning: "#D58B18"
  error: "#B3261E"
  info: "#2563EB"
typography:
  display:
    fontFamily: "Inter, sans-serif"
    fontSize: "32px"
    fontWeight: 700
    lineHeight: 1.2
  headline:
    fontFamily: "Inter, sans-serif"
    fontSize: "22px"
    fontWeight: 700
    lineHeight: 1.3
  title:
    fontFamily: "Inter, sans-serif"
    fontSize: "16px"
    fontWeight: 600
    lineHeight: 1.4
  body:
    fontFamily: "Inter, sans-serif"
    fontSize: "14px"
    fontWeight: 400
    lineHeight: 1.5
  numeric:
    fontFamily: "Inter, sans-serif"
    fontSize: "15px"
    fontWeight: 600
    lineHeight: 1.2
    fontFeatures: "tabular-nums"
rounded:
  sm: "4px"
  md: "8px"
  lg: "10px"
  xl: "16px"
spacing:
  xs: "4px"
  sm: "8px"
  md: "12px"
  lg: "16px"
  xl: "20px"
  xxl: "24px"
components:
  button-primary:
    backgroundColor: "{colors.primary}"
    textColor: "#FFFFFF"
    rounded: "{rounded.md}"
    padding: "12px 20px"
    height: "48px"
  card:
    backgroundColor: "{colors.surface-light}"
    rounded: "{rounded.lg}"
    padding: "16px 20px"
---

# Step Up Fuels — Design System

## Overview
Step Up Fuels is a high-volume Indian Fuel Distribution ERP system. Its design language is **Industrial Graphite & Fuel Orange**: restrained, functional, trustworthy, and high-density without clutter. The interface prioritizes speed of data entry, clear financial amounts (INR), stock audits (Litres), and GST compliance.

## Colors
- **Brand Accent:** Fuel Orange / Amber (`#D07A28`). Used for primary actions, selected indicators, and brand touchpoints.
- **Surface & Shell:** Industrial Navy (`#0F172A`) for dark mode & headers; Warm Alabaster (`#F6F2EB`) and Crisp White (`#FFFFFF`) for light mode.
- **Semantic Roles:**
  - Success (`#2E7D32`): Paid invoices, verified fuel bowsers, positive adjustments.
  - Warning (`#D58B18`): Partially paid, low stock warnings, expiring driver licenses.
  - Error (`#B3261E`): Overdue balances, failed imports, deleted items.
  - Info (`#2563EB`): Posted transactions, vehicle service reminders.

## Typography
The system uses the **Inter** typeface across all screens:
- **Currency & Metric figures:** Always render using tabular numerals (`tabularFigures`) to maintain vertical alignment in tables and financial ledgers.
- **Contrast:** Body copy must strictly satisfy WCAG AA (>= 4.5:1 ratio against background).

## Layout
- **Navigation Chrome:**
  - Desktop (>1024px): Persistent expandable sidebar (240px wide).
  - Tablet (600–1024px): Compact Navigation Rail (72–80px wide).
  - Mobile (<600px): Bottom navigation bar + Drawer for extended management routes.
- **Split Views:** Adaptive Master-Detail structure for entity management (Customers, Invoices, Products, Vehicles).

## Elevation & Depth
- Cards and panels have clean 1px borders matching `{colors.border-light}` or `{colors.border-dark}`.
- Flat elevation with soft ambient shadows; no decorative zero-offset neon glow.

## Shapes
- Buttons and inputs use `8px` corner radius.
- Cards use `10px` or `16px` corner radius.
- Badges and chips use `4px` or pill radius (`16px`).

## Components
- `PrimaryButton`, `SecondaryButton`, `DangerButton`: Guaranteed >= 48dp minimum interactive touch target.
- `AppTextField`: Standardized label, hint, outline borders, and numeric formatters.
- `AppDropdown`: Standardized Material 3 dropdown with clear contrast, touch targets, and validation.
- `StatusBadge`: Coherent color-coded chips for entity states.
- `AppErrorWidget`: Consistent recovery UI with an icon, descriptive explanation, and a Retry button.

## Do's and Don'ts
- **DO** use `Theme.of(context).colorScheme` and semantic tokens for all UI elements.
- **DO** format currency using `₹` with Indian numbering grouping (`#,##,###.##`).
- **DO** ensure interactive touch targets are at least 48x48 dp.
- **DON'T** use raw `DropdownButton` with `underline: SizedBox()` without accessible styling.
- **DON'T** hardcode raw exception traces (`Text('Error: $e')`) directly to users.
- **DON'T** make buttons smaller than 48dp in height.

/// Route name constants for the GoRouter configuration.
///
/// Use these constants everywhere instead of hardcoded path strings.
library;

class RouteNames {
  RouteNames._();

  // ── Shell (always visible sidebar) ─────────────────────────────────────────
  static const String shell = '/';

  // ── Top-level routes ───────────────────────────────────────────────────────
  static const String dashboard = '/dashboard';
  static const String customers = '/customers';
  static const String customerDetail = '/customers/:id';
  static const String customerNew = '/customers/new';

  static const String products = '/products';
  static const String productDetail = '/products/:id';
  static const String productNew = '/products/new';

  static const String inventory = '/inventory';
  static const String inventoryMovements = '/inventory/movements';
  static const String stockAdjustment = '/inventory/adjust';

  static const String vehicles = '/vehicles';
  static const String drivers = '/drivers';

  static const String purchases = '/purchases';
  static const String purchaseDetail = '/purchases/:id';
  static const String purchaseNew = '/purchases/new';

  static const String invoices = '/invoices';
  static const String invoiceDetail = '/invoices/:id';
  static const String invoiceNew = '/invoices/new';

  static const String payments = '/payments';
  static const String paymentDetail = '/payments/:id';

  static const String ledger = '/ledger';
  static const String customerLedger = '/ledger/customer/:customerId';

  static const String reports = '/reports';
  static const String reportSales = '/reports/sales';
  static const String reportGstr1 = '/reports/gstr1';
  static const String reportStock = '/reports/stock';
  static const String reportPaymentAging = '/reports/payment-aging';

  static const String importExport = '/import-export';

  static const String settings = '/settings';
  static const String settingsCompany = '/settings/company';

  // ── Helper: build parameterised paths ────────────────────────────────────
  static String customerDetailPath(String id) => '/customers/$id';
  static String productDetailPath(String id) => '/products/$id';
  static String purchaseDetailPath(String id) => '/purchases/$id';
  static String invoiceDetailPath(String id) => '/invoices/$id';
  static String customerLedgerPath(String customerId) =>
      '/ledger/customer/$customerId';
}

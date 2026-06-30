/// Application-wide constants.
library;

class AppConstants {
  AppConstants._();

  // ── App Metadata ───────────────────────────────────────────────────────────
  static const String appName = 'Step Up Fuels';
  static const String appVersion = '1.0.0';
  static const String companyName = 'Step Up Fuels';

  // ── Database ───────────────────────────────────────────────────────────────
  static const String databaseName = 'step_up_fuels.db';
  static const int databaseVersion = 1;

  // ── Invoice ────────────────────────────────────────────────────────────────
  static const String defaultInvoicePrefix = 'SUF';
  static const int invoiceSequenceStartsAt = 1;

  // ── Pagination ─────────────────────────────────────────────────────────────
  static const int defaultPageSize = 50;

  // ── Date Formats ──────────────────────────────────────────────────────────
  static const String displayDateFormat = 'dd-MMM-yyyy';
  static const String displayDateTimeFormat = 'dd-MMM-yyyy HH:mm';
  static const String isoDateFormat = 'yyyy-MM-dd';
  static const String financialYearSeparator = '-';

  // ── Currency ───────────────────────────────────────────────────────────────
  static const String currencySymbol = '₹';
  static const String currencyCode = 'INR';
  static const String currencyLocale = 'en_IN';

  // ── Credit ─────────────────────────────────────────────────────────────────
  static const int defaultCreditDays = 30;

  // ── Settings Keys ──────────────────────────────────────────────────────────
  static const String settingsKeyThemeMode = 'theme_mode';
  static const String settingsKeyCompanyId = 'company_id';
  static const String settingsKeyInvoiceCounter = 'invoice_counter';
  static const String settingsKeyLastBackup = 'last_backup';
}

/// GST-related constants for Indian tax compliance.
library;

class GstConstants {
  GstConstants._();

  // ── Tax Rates ──────────────────────────────────────────────────────────────
  static const double gstRate0 = 0.00;
  static const double gstRate5 = 0.05;
  static const double gstRate12 = 0.12;
  static const double gstRate18 = 0.18;
  static const double gstRate28 = 0.28;

  // ── HSD (High Speed Diesel) ────────────────────────────────────────────────
  /// HSN code for petroleum oils — HSD
  static const String hsnHsd = '2710';
  static const String hsdDescription = 'High Speed Diesel (HSD)';
  static const String hsdUnit = 'KL'; // Kilolitre

  // ── GST Number Validation ─────────────────────────────────────────────────
  /// Standard 15-character GSTIN regex
  static const String gstinPattern =
      r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$';

  /// PAN regex
  static const String panPattern =
      r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$';

  /// IFSC regex
  static const String ifscPattern = r'^[A-Z]{4}0[A-Z0-9]{6}$';

  // ── Indian State Codes ─────────────────────────────────────────────────────
  static const Map<String, String> stateCodes = {
    '01': 'Jammu & Kashmir',
    '02': 'Himachal Pradesh',
    '03': 'Punjab',
    '04': 'Chandigarh',
    '05': 'Uttarakhand',
    '06': 'Haryana',
    '07': 'Delhi',
    '08': 'Rajasthan',
    '09': 'Uttar Pradesh',
    '10': 'Bihar',
    '11': 'Sikkim',
    '12': 'Arunachal Pradesh',
    '13': 'Nagaland',
    '14': 'Manipur',
    '15': 'Mizoram',
    '16': 'Tripura',
    '17': 'Meghalaya',
    '18': 'Assam',
    '19': 'West Bengal',
    '20': 'Jharkhand',
    '21': 'Odisha',
    '22': 'Chattisgarh',
    '23': 'Madhya Pradesh',
    '24': 'Gujarat',
    '26': 'Dadra & Nagar Haveli and Daman & Diu',
    '27': 'Maharashtra',
    '28': 'Andhra Pradesh',
    '29': 'Karnataka',
    '30': 'Goa',
    '31': 'Lakshadweep',
    '32': 'Kerala',
    '33': 'Tamil Nadu',
    '34': 'Puducherry',
    '35': 'Andaman & Nicobar Islands',
    '36': 'Telangana',
    '37': 'Andhra Pradesh (New)',
    '38': 'Ladakh',
    '97': 'Other Territory',
    '99': 'Centre Jurisdiction',
  };

  /// Get state name from a GSTIN (first 2 digits = state code)
  static String? stateFromGstin(String gstin) {
    if (gstin.length < 2) return null;
    return stateCodes[gstin.substring(0, 2)];
  }

  /// Get state code from a GSTIN
  static String? stateCodeFromGstin(String gstin) {
    if (gstin.length < 2) return null;
    return gstin.substring(0, 2);
  }

  // ── Supply Types ───────────────────────────────────────────────────────────
  static const String supplyTypeB2B = 'B2B';
  static const String supplyTypeB2C = 'B2C';

  // ── Financial Year ─────────────────────────────────────────────────────────
  static const int financialYearStartMonth = 4; // April

  // ── e-Invoice thresholds ───────────────────────────────────────────────────
  static const double eInvoiceThresholdCrores = 5; // ₹5 Crore turnover
}

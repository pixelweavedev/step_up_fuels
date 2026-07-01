/// Result of a GST computation for a single line item.
class GstBreakdown {
  GstBreakdown({
    required this.taxableAmount,
    required this.gstRate,
    required this.cgstRate,
    required this.sgstRate,
    required this.igstRate,
    required this.cgstAmount,
    required this.sgstAmount,
    required this.igstAmount,
    required this.totalAmount,
    required this.isInterstate,
  });

  final double taxableAmount;
  final double gstRate; // Combined GST rate e.g. 0.18
  final double cgstRate;
  final double sgstRate;
  final double igstRate;
  final double cgstAmount;
  final double sgstAmount;
  final double igstAmount;
  final double totalAmount;
  final bool isInterstate;

  double get totalTax => cgstAmount + sgstAmount + igstAmount;
}

/// Service for computing GST based on Indian tax rules.
///
/// Rules:
/// - Intrastate (seller state == buyer state): CGST + SGST each = gstRate/2
/// - Interstate (different states): IGST = gstRate
class GstCalculationService {
  const GstCalculationService({
    required this.sellerStateCode,
  });

  /// Company's state code from settings (e.g. "27" for Maharashtra).
  final String sellerStateCode;

  /// Compute GST breakdown for a single line item.
  ///
  /// [buyerStateCode] – place of supply (customer's state code)
  /// [taxableAmount] – price before GST
  /// [gstRate]       – total GST rate as decimal (e.g. 0.18 for 18%)
  GstBreakdown compute({
    required String buyerStateCode,
    required double taxableAmount,
    required double gstRate,
  }) {
    final isInterstate = sellerStateCode.trim() != buyerStateCode.trim();

    double cgstRate = 0;
    double sgstRate = 0;
    double igstRate = 0;

    if (isInterstate) {
      igstRate = gstRate;
    } else {
      cgstRate = gstRate / 2;
      sgstRate = gstRate / 2;
    }

    final cgstAmount = _round(taxableAmount * cgstRate);
    final sgstAmount = _round(taxableAmount * sgstRate);
    final igstAmount = _round(taxableAmount * igstRate);

    return GstBreakdown(
      taxableAmount: _round(taxableAmount),
      gstRate: gstRate,
      cgstRate: cgstRate,
      sgstRate: sgstRate,
      igstRate: igstRate,
      cgstAmount: cgstAmount,
      sgstAmount: sgstAmount,
      igstAmount: igstAmount,
      totalAmount: _round(taxableAmount + cgstAmount + sgstAmount + igstAmount),
      isInterstate: isInterstate,
    );
  }

  /// Recompute header-level totals from a list of item breakdowns.
  ({double subtotal, double cgst, double sgst, double igst, double total}) summarise(
    List<GstBreakdown> items,
  ) {
    double subtotal = 0;
    double cgst = 0;
    double sgst = 0;
    double igst = 0;

    for (final item in items) {
      subtotal += item.taxableAmount;
      cgst += item.cgstAmount;
      sgst += item.sgstAmount;
      igst += item.igstAmount;
    }

    return (
      subtotal: _round(subtotal),
      cgst: _round(cgst),
      sgst: _round(sgst),
      igst: _round(igst),
      total: _round(subtotal + cgst + sgst + igst),
    );
  }

  double _round(double value) => double.parse(value.toStringAsFixed(2));
}

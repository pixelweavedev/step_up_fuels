/// Domain entity representing a single line item in a Tax Invoice.
class InvoiceItem {
  InvoiceItem({
    required this.id,
    required this.invoiceId,
    required this.productId,
    required this.hsnCode,
    required this.description,
    required this.quantity,
    required this.unit,
    required this.rate,
    required this.taxableAmount,
    required this.gstRate,
    required this.cgstRate,
    required this.sgstRate,
    required this.igstRate,
    required this.cgstAmount,
    required this.sgstAmount,
    required this.igstAmount,
    required this.totalAmount,
    required this.sortOrder,
  });

  final String id;
  final String invoiceId;
  final String productId;
  final String hsnCode;
  final String description;
  final double quantity; // Litres or KL
  final String unit; // LTRS, KL
  final double rate; // Rate per unit exclusive of GST
  final double taxableAmount; // quantity * rate
  final double gstRate; // e.g. 0.18 (18%)
  final double cgstRate; // e.g. 0.09
  final double sgstRate; // e.g. 0.09
  final double igstRate; // e.g. 0.18
  final double cgstAmount;
  final double sgstAmount;
  final double igstAmount;
  final double totalAmount; // taxableAmount + taxes
  final int sortOrder;

  double get totalTax => cgstAmount + sgstAmount + igstAmount;
}

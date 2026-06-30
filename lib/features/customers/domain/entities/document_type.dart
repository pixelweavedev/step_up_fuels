/// Represents categories of uploadable business documents.
enum DocumentType {
  gstCertificate,
  pan,
  msmeCertificate,
  purchaseOrder,
  agreement,
  other;

  /// Display label for UI representation.
  String get displayName => switch (this) {
        DocumentType.gstCertificate => 'GST Certificate',
        DocumentType.pan => 'PAN Card',
        DocumentType.msmeCertificate => 'MSME Certificate',
        DocumentType.purchaseOrder => 'Purchase Order',
        DocumentType.agreement => 'Agreement',
        DocumentType.other => 'Other Document',
      };
}

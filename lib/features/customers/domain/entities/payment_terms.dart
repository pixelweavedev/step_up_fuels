/// Represents the credit payment terms for a customer.
enum PaymentTerms {
  advance,
  days7,
  days15,
  days30,
  days45;

  /// Display label for UI representation.
  String get displayName => switch (this) {
        PaymentTerms.advance => 'Advance',
        PaymentTerms.days7 => '7 Days',
        PaymentTerms.days15 => '15 Days',
        PaymentTerms.days30 => '30 Days',
        PaymentTerms.days45 => '45 Days',
      };
}

/// Represents the type of customer in the system.
enum CustomerType {
  company,
  individual,
  government;

  /// Returns the display name of the customer type.
  String get displayName => switch (this) {
        CustomerType.company => 'Company',
        CustomerType.individual => 'Individual',
        CustomerType.government => 'Government',
      };
}

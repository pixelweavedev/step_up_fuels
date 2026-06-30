/// Represents standard fuel preference options.
enum FuelType {
  diesel,
  petrol;

  /// Display name of the fuel type.
  String get displayName => switch (this) {
        FuelType.diesel => 'Diesel',
        FuelType.petrol => 'Petrol',
      };
}

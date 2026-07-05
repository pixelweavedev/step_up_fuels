class InvoiceSettings {
  const InvoiceSettings({
    required this.prefix,
    required this.startingNumber,
    required this.termsAndConditions,
    required this.authorizedSignatoryName,
  });

  factory InvoiceSettings.defaultSettings() {
    return const InvoiceSettings(
      prefix: 'SUF',
      startingNumber: 1,
      termsAndConditions:
          '1. Fuel once sold will not be taken back.\n2. Interest @ 18% p.a. will be charged for delayed payments.\n3. All disputes subject to local jurisdiction.',
      authorizedSignatoryName: '',
    );
  }

  factory InvoiceSettings.fromJson(Map<String, dynamic> json) {
    return InvoiceSettings(
      prefix: json['prefix'] as String? ?? 'SUF',
      startingNumber: json['startingNumber'] as int? ?? 1,
      termsAndConditions: json['termsAndConditions'] as String? ?? '',
      authorizedSignatoryName: json['authorizedSignatoryName'] as String? ?? '',
    );
  }
  final String prefix;
  final int startingNumber;
  final String termsAndConditions;
  final String authorizedSignatoryName;

  InvoiceSettings copyWith({
    String? prefix,
    int? startingNumber,
    String? termsAndConditions,
    String? authorizedSignatoryName,
  }) {
    return InvoiceSettings(
      prefix: prefix ?? this.prefix,
      startingNumber: startingNumber ?? this.startingNumber,
      termsAndConditions: termsAndConditions ?? this.termsAndConditions,
      authorizedSignatoryName:
          authorizedSignatoryName ?? this.authorizedSignatoryName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'prefix': prefix,
      'startingNumber': startingNumber,
      'termsAndConditions': termsAndConditions,
      'authorizedSignatoryName': authorizedSignatoryName,
    };
  }
}

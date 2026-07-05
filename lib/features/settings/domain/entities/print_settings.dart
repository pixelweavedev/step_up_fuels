class PrintSettings {
  factory PrintSettings.defaultSettings() {
    return const PrintSettings(
      paperSize: 'A4',
      marginTop: 20.0,
      marginBottom: 20.0,
      marginLeft: 20.0,
      marginRight: 20.0,
    );
  }

  factory PrintSettings.fromJson(Map<String, dynamic> json) {
    return PrintSettings(
      paperSize: json['paperSize'] as String? ?? 'A4',
      marginTop: (json['marginTop'] as num? ?? 20.0).toDouble(),
      marginBottom: (json['marginBottom'] as num? ?? 20.0).toDouble(),
      marginLeft: (json['marginLeft'] as num? ?? 20.0).toDouble(),
      marginRight: (json['marginRight'] as num? ?? 20.0).toDouble(),
    );
  }

  const PrintSettings({
    required this.paperSize,
    required this.marginTop,
    required this.marginBottom,
    required this.marginLeft,
    required this.marginRight,
  });
  final String paperSize; // "A4" or "LETTER"
  final double marginTop;
  final double marginBottom;
  final double marginLeft;
  final double marginRight;

  PrintSettings copyWith({
    String? paperSize,
    double? marginTop,
    double? marginBottom,
    double? marginLeft,
    double? marginRight,
  }) {
    return PrintSettings(
      paperSize: paperSize ?? this.paperSize,
      marginTop: marginTop ?? this.marginTop,
      marginBottom: marginBottom ?? this.marginBottom,
      marginLeft: marginLeft ?? this.marginLeft,
      marginRight: marginRight ?? this.marginRight,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'paperSize': paperSize,
      'marginTop': marginTop,
      'marginBottom': marginBottom,
      'marginLeft': marginLeft,
      'marginRight': marginRight,
    };
  }
}

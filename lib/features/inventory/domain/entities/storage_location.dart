import 'package:equatable/equatable.dart';

enum StorageLocationType {
  mainStorage,
  bowser,
}

extension StorageLocationTypeExtension on StorageLocationType {
  String get value {
    switch (this) {
      case StorageLocationType.mainStorage:
        return 'MAIN_STORAGE';
      case StorageLocationType.bowser:
        return 'BOWSER';
    }
  }

  static StorageLocationType fromString(String val) {
    if (val == 'MAIN_STORAGE') return StorageLocationType.mainStorage;
    return StorageLocationType.bowser;
  }
}

class StorageLocation extends Equatable {
  const StorageLocation({
    required this.id,
    required this.name,
    required this.type,
    this.vehicleId,
    required this.isActive,
    required this.createdBy,
    required this.createdAt,
    required this.updatedBy,
    required this.updatedAt,
    this.deletedAt,
    required this.version,
    this.tenantId,
  });

  final String id;
  final String name;
  final StorageLocationType type;
  final String? vehicleId;
  final bool isActive;

  // Audits
  final String createdBy;
  final DateTime createdAt;
  final String updatedBy;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int version;
  final String? tenantId;

  StorageLocation copyWith({
    String? name,
    StorageLocationType? type,
    String? vehicleId,
    bool? isActive,
    String? updatedBy,
    DateTime? deletedAt,
    int? version,
    String? tenantId,
  }) {
    return StorageLocation(
      id: id,
      name: name ?? this.name,
      type: type ?? this.type,
      vehicleId: vehicleId ?? this.vehicleId,
      isActive: isActive ?? this.isActive,
      createdBy: createdBy,
      createdAt: createdAt,
      updatedBy: updatedBy ?? this.updatedBy,
      updatedAt: DateTime.now(),
      deletedAt: deletedAt ?? this.deletedAt,
      version: version ?? (this.version + 1),
      tenantId: tenantId ?? this.tenantId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        vehicleId,
        isActive,
        createdBy,
        createdAt,
        updatedBy,
        updatedAt,
        deletedAt,
        version,
        tenantId,
      ];
}

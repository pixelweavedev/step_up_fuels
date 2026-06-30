// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSettingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSettingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSettingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSettingRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSettingRow extends DataClass implements Insertable<AppSettingRow> {
  final String key;
  final String value;
  final DateTime updatedAt;
  const AppSettingRow({
    required this.key,
    required this.value,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      key: Value(key),
      value: Value(value),
      updatedAt: Value(updatedAt),
    );
  }

  factory AppSettingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSettingRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AppSettingRow copyWith({String? key, String? value, DateTime? updatedAt}) =>
      AppSettingRow(
        key: key ?? this.key,
        value: value ?? this.value,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  AppSettingRow copyWithCompanion(AppSettingsCompanion data) {
    return AppSettingRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingRow(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSettingRow &&
          other.key == this.key &&
          other.value == this.value &&
          other.updatedAt == this.updatedAt);
}

class AppSettingsCompanion extends UpdateCompanion<AppSettingRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    required String value,
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<AppSettingRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CustomersTable extends Customers
    with TableInfo<$CustomersTable, CustomerRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _customerCodeMeta = const VerificationMeta(
    'customerCode',
  );
  @override
  late final GeneratedColumn<String> customerCode = GeneratedColumn<String>(
    'customer_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tradeNameMeta = const VerificationMeta(
    'tradeName',
  );
  @override
  late final GeneratedColumn<String> tradeName = GeneratedColumn<String>(
    'trade_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _legalBusinessNameMeta = const VerificationMeta(
    'legalBusinessName',
  );
  @override
  late final GeneratedColumn<String> legalBusinessName =
      GeneratedColumn<String>(
        'legal_business_name',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _customerTypeMeta = const VerificationMeta(
    'customerType',
  );
  @override
  late final GeneratedColumn<String> customerType = GeneratedColumn<String>(
    'customer_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _gstinMeta = const VerificationMeta('gstin');
  @override
  late final GeneratedColumn<String> gstin = GeneratedColumn<String>(
    'gstin',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _panMeta = const VerificationMeta('pan');
  @override
  late final GeneratedColumn<String> pan = GeneratedColumn<String>(
    'pan',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _placeOfSupplyMeta = const VerificationMeta(
    'placeOfSupply',
  );
  @override
  late final GeneratedColumn<String> placeOfSupply = GeneratedColumn<String>(
    'place_of_supply',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gstRegistrationTypeMeta =
      const VerificationMeta('gstRegistrationType');
  @override
  late final GeneratedColumn<String> gstRegistrationType =
      GeneratedColumn<String>(
        'gst_registration_type',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _tanMeta = const VerificationMeta('tan');
  @override
  late final GeneratedColumn<String> tan = GeneratedColumn<String>(
    'tan',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _billingAddressLine1Meta =
      const VerificationMeta('billingAddressLine1');
  @override
  late final GeneratedColumn<String> billingAddressLine1 =
      GeneratedColumn<String>(
        'billing_address_line1',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _billingAddressLine2Meta =
      const VerificationMeta('billingAddressLine2');
  @override
  late final GeneratedColumn<String> billingAddressLine2 =
      GeneratedColumn<String>(
        'billing_address_line2',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _billingAreaMeta = const VerificationMeta(
    'billingArea',
  );
  @override
  late final GeneratedColumn<String> billingArea = GeneratedColumn<String>(
    'billing_area',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _billingCityMeta = const VerificationMeta(
    'billingCity',
  );
  @override
  late final GeneratedColumn<String> billingCity = GeneratedColumn<String>(
    'billing_city',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _billingStateMeta = const VerificationMeta(
    'billingState',
  );
  @override
  late final GeneratedColumn<String> billingState = GeneratedColumn<String>(
    'billing_state',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _billingPincodeMeta = const VerificationMeta(
    'billingPincode',
  );
  @override
  late final GeneratedColumn<String> billingPincode = GeneratedColumn<String>(
    'billing_pincode',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _billingCountryMeta = const VerificationMeta(
    'billingCountry',
  );
  @override
  late final GeneratedColumn<String> billingCountry = GeneratedColumn<String>(
    'billing_country',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _paymentTermsMeta = const VerificationMeta(
    'paymentTerms',
  );
  @override
  late final GeneratedColumn<String> paymentTerms = GeneratedColumn<String>(
    'payment_terms',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _creditLimitMeta = const VerificationMeta(
    'creditLimit',
  );
  @override
  late final GeneratedColumn<double> creditLimit = GeneratedColumn<double>(
    'credit_limit',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _creditDaysMeta = const VerificationMeta(
    'creditDays',
  );
  @override
  late final GeneratedColumn<int> creditDays = GeneratedColumn<int>(
    'credit_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(30),
  );
  static const VerificationMeta _securityDepositMeta = const VerificationMeta(
    'securityDeposit',
  );
  @override
  late final GeneratedColumn<double> securityDeposit = GeneratedColumn<double>(
    'security_deposit',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _fuelTypeMeta = const VerificationMeta(
    'fuelType',
  );
  @override
  late final GeneratedColumn<String> fuelType = GeneratedColumn<String>(
    'fuel_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _defaultGstRateMeta = const VerificationMeta(
    'defaultGstRate',
  );
  @override
  late final GeneratedColumn<double> defaultGstRate = GeneratedColumn<double>(
    'default_gst_rate',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.18),
  );
  static const VerificationMeta _defaultPriceMeta = const VerificationMeta(
    'defaultPrice',
  );
  @override
  late final GeneratedColumn<double> defaultPrice = GeneratedColumn<double>(
    'default_price',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _poNumberMeta = const VerificationMeta(
    'poNumber',
  );
  @override
  late final GeneratedColumn<String> poNumber = GeneratedColumn<String>(
    'po_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _poDateMeta = const VerificationMeta('poDate');
  @override
  late final GeneratedColumn<DateTime> poDate = GeneratedColumn<DateTime>(
    'po_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _poValidTillMeta = const VerificationMeta(
    'poValidTill',
  );
  @override
  late final GeneratedColumn<DateTime> poValidTill = GeneratedColumn<DateTime>(
    'po_valid_till',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _poValueMeta = const VerificationMeta(
    'poValue',
  );
  @override
  late final GeneratedColumn<double> poValue = GeneratedColumn<double>(
    'po_value',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _poRemainingBalanceMeta =
      const VerificationMeta('poRemainingBalance');
  @override
  late final GeneratedColumn<double> poRemainingBalance =
      GeneratedColumn<double>(
        'po_remaining_balance',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _invoicePrefixMeta = const VerificationMeta(
    'invoicePrefix',
  );
  @override
  late final GeneratedColumn<String> invoicePrefix = GeneratedColumn<String>(
    'invoice_prefix',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emailInvoiceMeta = const VerificationMeta(
    'emailInvoice',
  );
  @override
  late final GeneratedColumn<bool> emailInvoice = GeneratedColumn<bool>(
    'email_invoice',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("email_invoice" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _whatsappInvoiceMeta = const VerificationMeta(
    'whatsappInvoice',
  );
  @override
  late final GeneratedColumn<bool> whatsappInvoice = GeneratedColumn<bool>(
    'whatsapp_invoice',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("whatsapp_invoice" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _requirePoMeta = const VerificationMeta(
    'requirePo',
  );
  @override
  late final GeneratedColumn<bool> requirePo = GeneratedColumn<bool>(
    'require_po',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("require_po" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _requireDcMeta = const VerificationMeta(
    'requireDc',
  );
  @override
  late final GeneratedColumn<bool> requireDc = GeneratedColumn<bool>(
    'require_dc',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("require_dc" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _requireSignatureMeta = const VerificationMeta(
    'requireSignature',
  );
  @override
  late final GeneratedColumn<bool> requireSignature = GeneratedColumn<bool>(
    'require_signature',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("require_signature" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _gstApplicableMeta = const VerificationMeta(
    'gstApplicable',
  );
  @override
  late final GeneratedColumn<bool> gstApplicable = GeneratedColumn<bool>(
    'gst_applicable',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("gst_applicable" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _eInvoiceRequiredMeta = const VerificationMeta(
    'eInvoiceRequired',
  );
  @override
  late final GeneratedColumn<bool> eInvoiceRequired = GeneratedColumn<bool>(
    'e_invoice_required',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("e_invoice_required" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _eWayBillRequiredMeta = const VerificationMeta(
    'eWayBillRequired',
  );
  @override
  late final GeneratedColumn<bool> eWayBillRequired = GeneratedColumn<bool>(
    'e_way_bill_required',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("e_way_bill_required" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _openingBalanceMeta = const VerificationMeta(
    'openingBalance',
  );
  @override
  late final GeneratedColumn<double> openingBalance = GeneratedColumn<double>(
    'opening_balance',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _currentBalanceMeta = const VerificationMeta(
    'currentBalance',
  );
  @override
  late final GeneratedColumn<double> currentBalance = GeneratedColumn<double>(
    'current_balance',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _lastPaymentDateMeta = const VerificationMeta(
    'lastPaymentDate',
  );
  @override
  late final GeneratedColumn<DateTime> lastPaymentDate =
      GeneratedColumn<DateTime>(
        'last_payment_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastInvoiceDateMeta = const VerificationMeta(
    'lastInvoiceDate',
  );
  @override
  late final GeneratedColumn<DateTime> lastInvoiceDate =
      GeneratedColumn<DateTime>(
        'last_invoice_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('system'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedByMeta = const VerificationMeta(
    'updatedBy',
  );
  @override
  late final GeneratedColumn<String> updatedBy = GeneratedColumn<String>(
    'updated_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('system'),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _tenantIdMeta = const VerificationMeta(
    'tenantId',
  );
  @override
  late final GeneratedColumn<String> tenantId = GeneratedColumn<String>(
    'tenant_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    customerCode,
    name,
    displayName,
    tradeName,
    legalBusinessName,
    customerType,
    isActive,
    gstin,
    pan,
    state,
    placeOfSupply,
    gstRegistrationType,
    tan,
    billingAddressLine1,
    billingAddressLine2,
    billingArea,
    billingCity,
    billingState,
    billingPincode,
    billingCountry,
    paymentTerms,
    creditLimit,
    creditDays,
    securityDeposit,
    fuelType,
    defaultGstRate,
    defaultPrice,
    poNumber,
    poDate,
    poValidTill,
    poValue,
    poRemainingBalance,
    invoicePrefix,
    emailInvoice,
    whatsappInvoice,
    requirePo,
    requireDc,
    requireSignature,
    gstApplicable,
    eInvoiceRequired,
    eWayBillRequired,
    openingBalance,
    currentBalance,
    lastPaymentDate,
    lastInvoiceDate,
    notes,
    createdBy,
    createdAt,
    updatedBy,
    updatedAt,
    deletedAt,
    version,
    tenantId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'customers';
  @override
  VerificationContext validateIntegrity(
    Insertable<CustomerRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('customer_code')) {
      context.handle(
        _customerCodeMeta,
        customerCode.isAcceptableOrUnknown(
          data['customer_code']!,
          _customerCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_customerCodeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    }
    if (data.containsKey('trade_name')) {
      context.handle(
        _tradeNameMeta,
        tradeName.isAcceptableOrUnknown(data['trade_name']!, _tradeNameMeta),
      );
    }
    if (data.containsKey('legal_business_name')) {
      context.handle(
        _legalBusinessNameMeta,
        legalBusinessName.isAcceptableOrUnknown(
          data['legal_business_name']!,
          _legalBusinessNameMeta,
        ),
      );
    }
    if (data.containsKey('customer_type')) {
      context.handle(
        _customerTypeMeta,
        customerType.isAcceptableOrUnknown(
          data['customer_type']!,
          _customerTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_customerTypeMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('gstin')) {
      context.handle(
        _gstinMeta,
        gstin.isAcceptableOrUnknown(data['gstin']!, _gstinMeta),
      );
    }
    if (data.containsKey('pan')) {
      context.handle(
        _panMeta,
        pan.isAcceptableOrUnknown(data['pan']!, _panMeta),
      );
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    }
    if (data.containsKey('place_of_supply')) {
      context.handle(
        _placeOfSupplyMeta,
        placeOfSupply.isAcceptableOrUnknown(
          data['place_of_supply']!,
          _placeOfSupplyMeta,
        ),
      );
    }
    if (data.containsKey('gst_registration_type')) {
      context.handle(
        _gstRegistrationTypeMeta,
        gstRegistrationType.isAcceptableOrUnknown(
          data['gst_registration_type']!,
          _gstRegistrationTypeMeta,
        ),
      );
    }
    if (data.containsKey('tan')) {
      context.handle(
        _tanMeta,
        tan.isAcceptableOrUnknown(data['tan']!, _tanMeta),
      );
    }
    if (data.containsKey('billing_address_line1')) {
      context.handle(
        _billingAddressLine1Meta,
        billingAddressLine1.isAcceptableOrUnknown(
          data['billing_address_line1']!,
          _billingAddressLine1Meta,
        ),
      );
    }
    if (data.containsKey('billing_address_line2')) {
      context.handle(
        _billingAddressLine2Meta,
        billingAddressLine2.isAcceptableOrUnknown(
          data['billing_address_line2']!,
          _billingAddressLine2Meta,
        ),
      );
    }
    if (data.containsKey('billing_area')) {
      context.handle(
        _billingAreaMeta,
        billingArea.isAcceptableOrUnknown(
          data['billing_area']!,
          _billingAreaMeta,
        ),
      );
    }
    if (data.containsKey('billing_city')) {
      context.handle(
        _billingCityMeta,
        billingCity.isAcceptableOrUnknown(
          data['billing_city']!,
          _billingCityMeta,
        ),
      );
    }
    if (data.containsKey('billing_state')) {
      context.handle(
        _billingStateMeta,
        billingState.isAcceptableOrUnknown(
          data['billing_state']!,
          _billingStateMeta,
        ),
      );
    }
    if (data.containsKey('billing_pincode')) {
      context.handle(
        _billingPincodeMeta,
        billingPincode.isAcceptableOrUnknown(
          data['billing_pincode']!,
          _billingPincodeMeta,
        ),
      );
    }
    if (data.containsKey('billing_country')) {
      context.handle(
        _billingCountryMeta,
        billingCountry.isAcceptableOrUnknown(
          data['billing_country']!,
          _billingCountryMeta,
        ),
      );
    }
    if (data.containsKey('payment_terms')) {
      context.handle(
        _paymentTermsMeta,
        paymentTerms.isAcceptableOrUnknown(
          data['payment_terms']!,
          _paymentTermsMeta,
        ),
      );
    }
    if (data.containsKey('credit_limit')) {
      context.handle(
        _creditLimitMeta,
        creditLimit.isAcceptableOrUnknown(
          data['credit_limit']!,
          _creditLimitMeta,
        ),
      );
    }
    if (data.containsKey('credit_days')) {
      context.handle(
        _creditDaysMeta,
        creditDays.isAcceptableOrUnknown(data['credit_days']!, _creditDaysMeta),
      );
    }
    if (data.containsKey('security_deposit')) {
      context.handle(
        _securityDepositMeta,
        securityDeposit.isAcceptableOrUnknown(
          data['security_deposit']!,
          _securityDepositMeta,
        ),
      );
    }
    if (data.containsKey('fuel_type')) {
      context.handle(
        _fuelTypeMeta,
        fuelType.isAcceptableOrUnknown(data['fuel_type']!, _fuelTypeMeta),
      );
    }
    if (data.containsKey('default_gst_rate')) {
      context.handle(
        _defaultGstRateMeta,
        defaultGstRate.isAcceptableOrUnknown(
          data['default_gst_rate']!,
          _defaultGstRateMeta,
        ),
      );
    }
    if (data.containsKey('default_price')) {
      context.handle(
        _defaultPriceMeta,
        defaultPrice.isAcceptableOrUnknown(
          data['default_price']!,
          _defaultPriceMeta,
        ),
      );
    }
    if (data.containsKey('po_number')) {
      context.handle(
        _poNumberMeta,
        poNumber.isAcceptableOrUnknown(data['po_number']!, _poNumberMeta),
      );
    }
    if (data.containsKey('po_date')) {
      context.handle(
        _poDateMeta,
        poDate.isAcceptableOrUnknown(data['po_date']!, _poDateMeta),
      );
    }
    if (data.containsKey('po_valid_till')) {
      context.handle(
        _poValidTillMeta,
        poValidTill.isAcceptableOrUnknown(
          data['po_valid_till']!,
          _poValidTillMeta,
        ),
      );
    }
    if (data.containsKey('po_value')) {
      context.handle(
        _poValueMeta,
        poValue.isAcceptableOrUnknown(data['po_value']!, _poValueMeta),
      );
    }
    if (data.containsKey('po_remaining_balance')) {
      context.handle(
        _poRemainingBalanceMeta,
        poRemainingBalance.isAcceptableOrUnknown(
          data['po_remaining_balance']!,
          _poRemainingBalanceMeta,
        ),
      );
    }
    if (data.containsKey('invoice_prefix')) {
      context.handle(
        _invoicePrefixMeta,
        invoicePrefix.isAcceptableOrUnknown(
          data['invoice_prefix']!,
          _invoicePrefixMeta,
        ),
      );
    }
    if (data.containsKey('email_invoice')) {
      context.handle(
        _emailInvoiceMeta,
        emailInvoice.isAcceptableOrUnknown(
          data['email_invoice']!,
          _emailInvoiceMeta,
        ),
      );
    }
    if (data.containsKey('whatsapp_invoice')) {
      context.handle(
        _whatsappInvoiceMeta,
        whatsappInvoice.isAcceptableOrUnknown(
          data['whatsapp_invoice']!,
          _whatsappInvoiceMeta,
        ),
      );
    }
    if (data.containsKey('require_po')) {
      context.handle(
        _requirePoMeta,
        requirePo.isAcceptableOrUnknown(data['require_po']!, _requirePoMeta),
      );
    }
    if (data.containsKey('require_dc')) {
      context.handle(
        _requireDcMeta,
        requireDc.isAcceptableOrUnknown(data['require_dc']!, _requireDcMeta),
      );
    }
    if (data.containsKey('require_signature')) {
      context.handle(
        _requireSignatureMeta,
        requireSignature.isAcceptableOrUnknown(
          data['require_signature']!,
          _requireSignatureMeta,
        ),
      );
    }
    if (data.containsKey('gst_applicable')) {
      context.handle(
        _gstApplicableMeta,
        gstApplicable.isAcceptableOrUnknown(
          data['gst_applicable']!,
          _gstApplicableMeta,
        ),
      );
    }
    if (data.containsKey('e_invoice_required')) {
      context.handle(
        _eInvoiceRequiredMeta,
        eInvoiceRequired.isAcceptableOrUnknown(
          data['e_invoice_required']!,
          _eInvoiceRequiredMeta,
        ),
      );
    }
    if (data.containsKey('e_way_bill_required')) {
      context.handle(
        _eWayBillRequiredMeta,
        eWayBillRequired.isAcceptableOrUnknown(
          data['e_way_bill_required']!,
          _eWayBillRequiredMeta,
        ),
      );
    }
    if (data.containsKey('opening_balance')) {
      context.handle(
        _openingBalanceMeta,
        openingBalance.isAcceptableOrUnknown(
          data['opening_balance']!,
          _openingBalanceMeta,
        ),
      );
    }
    if (data.containsKey('current_balance')) {
      context.handle(
        _currentBalanceMeta,
        currentBalance.isAcceptableOrUnknown(
          data['current_balance']!,
          _currentBalanceMeta,
        ),
      );
    }
    if (data.containsKey('last_payment_date')) {
      context.handle(
        _lastPaymentDateMeta,
        lastPaymentDate.isAcceptableOrUnknown(
          data['last_payment_date']!,
          _lastPaymentDateMeta,
        ),
      );
    }
    if (data.containsKey('last_invoice_date')) {
      context.handle(
        _lastInvoiceDateMeta,
        lastInvoiceDate.isAcceptableOrUnknown(
          data['last_invoice_date']!,
          _lastInvoiceDateMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_by')) {
      context.handle(
        _updatedByMeta,
        updatedBy.isAcceptableOrUnknown(data['updated_by']!, _updatedByMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('tenant_id')) {
      context.handle(
        _tenantIdMeta,
        tenantId.isAcceptableOrUnknown(data['tenant_id']!, _tenantIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CustomerRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomerRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      customerCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_code'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      ),
      tradeName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trade_name'],
      ),
      legalBusinessName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}legal_business_name'],
      ),
      customerType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_type'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      gstin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gstin'],
      ),
      pan: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pan'],
      ),
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      ),
      placeOfSupply: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}place_of_supply'],
      ),
      gstRegistrationType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gst_registration_type'],
      ),
      tan: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tan'],
      ),
      billingAddressLine1: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}billing_address_line1'],
      ),
      billingAddressLine2: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}billing_address_line2'],
      ),
      billingArea: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}billing_area'],
      ),
      billingCity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}billing_city'],
      ),
      billingState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}billing_state'],
      ),
      billingPincode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}billing_pincode'],
      ),
      billingCountry: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}billing_country'],
      ),
      paymentTerms: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_terms'],
      ),
      creditLimit: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}credit_limit'],
      )!,
      creditDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}credit_days'],
      )!,
      securityDeposit: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}security_deposit'],
      )!,
      fuelType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fuel_type'],
      ),
      defaultGstRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}default_gst_rate'],
      )!,
      defaultPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}default_price'],
      ),
      poNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}po_number'],
      ),
      poDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}po_date'],
      ),
      poValidTill: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}po_valid_till'],
      ),
      poValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}po_value'],
      ),
      poRemainingBalance: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}po_remaining_balance'],
      ),
      invoicePrefix: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}invoice_prefix'],
      ),
      emailInvoice: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}email_invoice'],
      )!,
      whatsappInvoice: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}whatsapp_invoice'],
      )!,
      requirePo: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}require_po'],
      )!,
      requireDc: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}require_dc'],
      )!,
      requireSignature: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}require_signature'],
      )!,
      gstApplicable: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}gst_applicable'],
      )!,
      eInvoiceRequired: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}e_invoice_required'],
      )!,
      eWayBillRequired: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}e_way_bill_required'],
      )!,
      openingBalance: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}opening_balance'],
      )!,
      currentBalance: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}current_balance'],
      )!,
      lastPaymentDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_payment_date'],
      ),
      lastInvoiceDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_invoice_date'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_by'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      tenantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tenant_id'],
      ),
    );
  }

  @override
  $CustomersTable createAlias(String alias) {
    return $CustomersTable(attachedDatabase, alias);
  }
}

class CustomerRow extends DataClass implements Insertable<CustomerRow> {
  final String id;
  final String customerCode;
  final String name;
  final String? displayName;
  final String? tradeName;
  final String? legalBusinessName;
  final String customerType;
  final bool isActive;
  final String? gstin;
  final String? pan;
  final String? state;
  final String? placeOfSupply;
  final String? gstRegistrationType;
  final String? tan;
  final String? billingAddressLine1;
  final String? billingAddressLine2;
  final String? billingArea;
  final String? billingCity;
  final String? billingState;
  final String? billingPincode;
  final String? billingCountry;
  final String? paymentTerms;
  final double creditLimit;
  final int creditDays;
  final double securityDeposit;
  final String? fuelType;
  final double defaultGstRate;
  final double? defaultPrice;
  final String? poNumber;
  final DateTime? poDate;
  final DateTime? poValidTill;
  final double? poValue;
  final double? poRemainingBalance;
  final String? invoicePrefix;
  final bool emailInvoice;
  final bool whatsappInvoice;
  final bool requirePo;
  final bool requireDc;
  final bool requireSignature;
  final bool gstApplicable;
  final bool eInvoiceRequired;
  final bool eWayBillRequired;
  final double openingBalance;
  final double currentBalance;
  final DateTime? lastPaymentDate;
  final DateTime? lastInvoiceDate;
  final String? notes;
  final String createdBy;
  final DateTime createdAt;
  final String updatedBy;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int version;
  final String? tenantId;
  const CustomerRow({
    required this.id,
    required this.customerCode,
    required this.name,
    this.displayName,
    this.tradeName,
    this.legalBusinessName,
    required this.customerType,
    required this.isActive,
    this.gstin,
    this.pan,
    this.state,
    this.placeOfSupply,
    this.gstRegistrationType,
    this.tan,
    this.billingAddressLine1,
    this.billingAddressLine2,
    this.billingArea,
    this.billingCity,
    this.billingState,
    this.billingPincode,
    this.billingCountry,
    this.paymentTerms,
    required this.creditLimit,
    required this.creditDays,
    required this.securityDeposit,
    this.fuelType,
    required this.defaultGstRate,
    this.defaultPrice,
    this.poNumber,
    this.poDate,
    this.poValidTill,
    this.poValue,
    this.poRemainingBalance,
    this.invoicePrefix,
    required this.emailInvoice,
    required this.whatsappInvoice,
    required this.requirePo,
    required this.requireDc,
    required this.requireSignature,
    required this.gstApplicable,
    required this.eInvoiceRequired,
    required this.eWayBillRequired,
    required this.openingBalance,
    required this.currentBalance,
    this.lastPaymentDate,
    this.lastInvoiceDate,
    this.notes,
    required this.createdBy,
    required this.createdAt,
    required this.updatedBy,
    required this.updatedAt,
    this.deletedAt,
    required this.version,
    this.tenantId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['customer_code'] = Variable<String>(customerCode);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || displayName != null) {
      map['display_name'] = Variable<String>(displayName);
    }
    if (!nullToAbsent || tradeName != null) {
      map['trade_name'] = Variable<String>(tradeName);
    }
    if (!nullToAbsent || legalBusinessName != null) {
      map['legal_business_name'] = Variable<String>(legalBusinessName);
    }
    map['customer_type'] = Variable<String>(customerType);
    map['is_active'] = Variable<bool>(isActive);
    if (!nullToAbsent || gstin != null) {
      map['gstin'] = Variable<String>(gstin);
    }
    if (!nullToAbsent || pan != null) {
      map['pan'] = Variable<String>(pan);
    }
    if (!nullToAbsent || state != null) {
      map['state'] = Variable<String>(state);
    }
    if (!nullToAbsent || placeOfSupply != null) {
      map['place_of_supply'] = Variable<String>(placeOfSupply);
    }
    if (!nullToAbsent || gstRegistrationType != null) {
      map['gst_registration_type'] = Variable<String>(gstRegistrationType);
    }
    if (!nullToAbsent || tan != null) {
      map['tan'] = Variable<String>(tan);
    }
    if (!nullToAbsent || billingAddressLine1 != null) {
      map['billing_address_line1'] = Variable<String>(billingAddressLine1);
    }
    if (!nullToAbsent || billingAddressLine2 != null) {
      map['billing_address_line2'] = Variable<String>(billingAddressLine2);
    }
    if (!nullToAbsent || billingArea != null) {
      map['billing_area'] = Variable<String>(billingArea);
    }
    if (!nullToAbsent || billingCity != null) {
      map['billing_city'] = Variable<String>(billingCity);
    }
    if (!nullToAbsent || billingState != null) {
      map['billing_state'] = Variable<String>(billingState);
    }
    if (!nullToAbsent || billingPincode != null) {
      map['billing_pincode'] = Variable<String>(billingPincode);
    }
    if (!nullToAbsent || billingCountry != null) {
      map['billing_country'] = Variable<String>(billingCountry);
    }
    if (!nullToAbsent || paymentTerms != null) {
      map['payment_terms'] = Variable<String>(paymentTerms);
    }
    map['credit_limit'] = Variable<double>(creditLimit);
    map['credit_days'] = Variable<int>(creditDays);
    map['security_deposit'] = Variable<double>(securityDeposit);
    if (!nullToAbsent || fuelType != null) {
      map['fuel_type'] = Variable<String>(fuelType);
    }
    map['default_gst_rate'] = Variable<double>(defaultGstRate);
    if (!nullToAbsent || defaultPrice != null) {
      map['default_price'] = Variable<double>(defaultPrice);
    }
    if (!nullToAbsent || poNumber != null) {
      map['po_number'] = Variable<String>(poNumber);
    }
    if (!nullToAbsent || poDate != null) {
      map['po_date'] = Variable<DateTime>(poDate);
    }
    if (!nullToAbsent || poValidTill != null) {
      map['po_valid_till'] = Variable<DateTime>(poValidTill);
    }
    if (!nullToAbsent || poValue != null) {
      map['po_value'] = Variable<double>(poValue);
    }
    if (!nullToAbsent || poRemainingBalance != null) {
      map['po_remaining_balance'] = Variable<double>(poRemainingBalance);
    }
    if (!nullToAbsent || invoicePrefix != null) {
      map['invoice_prefix'] = Variable<String>(invoicePrefix);
    }
    map['email_invoice'] = Variable<bool>(emailInvoice);
    map['whatsapp_invoice'] = Variable<bool>(whatsappInvoice);
    map['require_po'] = Variable<bool>(requirePo);
    map['require_dc'] = Variable<bool>(requireDc);
    map['require_signature'] = Variable<bool>(requireSignature);
    map['gst_applicable'] = Variable<bool>(gstApplicable);
    map['e_invoice_required'] = Variable<bool>(eInvoiceRequired);
    map['e_way_bill_required'] = Variable<bool>(eWayBillRequired);
    map['opening_balance'] = Variable<double>(openingBalance);
    map['current_balance'] = Variable<double>(currentBalance);
    if (!nullToAbsent || lastPaymentDate != null) {
      map['last_payment_date'] = Variable<DateTime>(lastPaymentDate);
    }
    if (!nullToAbsent || lastInvoiceDate != null) {
      map['last_invoice_date'] = Variable<DateTime>(lastInvoiceDate);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_by'] = Variable<String>(createdBy);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_by'] = Variable<String>(updatedBy);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['version'] = Variable<int>(version);
    if (!nullToAbsent || tenantId != null) {
      map['tenant_id'] = Variable<String>(tenantId);
    }
    return map;
  }

  CustomersCompanion toCompanion(bool nullToAbsent) {
    return CustomersCompanion(
      id: Value(id),
      customerCode: Value(customerCode),
      name: Value(name),
      displayName: displayName == null && nullToAbsent
          ? const Value.absent()
          : Value(displayName),
      tradeName: tradeName == null && nullToAbsent
          ? const Value.absent()
          : Value(tradeName),
      legalBusinessName: legalBusinessName == null && nullToAbsent
          ? const Value.absent()
          : Value(legalBusinessName),
      customerType: Value(customerType),
      isActive: Value(isActive),
      gstin: gstin == null && nullToAbsent
          ? const Value.absent()
          : Value(gstin),
      pan: pan == null && nullToAbsent ? const Value.absent() : Value(pan),
      state: state == null && nullToAbsent
          ? const Value.absent()
          : Value(state),
      placeOfSupply: placeOfSupply == null && nullToAbsent
          ? const Value.absent()
          : Value(placeOfSupply),
      gstRegistrationType: gstRegistrationType == null && nullToAbsent
          ? const Value.absent()
          : Value(gstRegistrationType),
      tan: tan == null && nullToAbsent ? const Value.absent() : Value(tan),
      billingAddressLine1: billingAddressLine1 == null && nullToAbsent
          ? const Value.absent()
          : Value(billingAddressLine1),
      billingAddressLine2: billingAddressLine2 == null && nullToAbsent
          ? const Value.absent()
          : Value(billingAddressLine2),
      billingArea: billingArea == null && nullToAbsent
          ? const Value.absent()
          : Value(billingArea),
      billingCity: billingCity == null && nullToAbsent
          ? const Value.absent()
          : Value(billingCity),
      billingState: billingState == null && nullToAbsent
          ? const Value.absent()
          : Value(billingState),
      billingPincode: billingPincode == null && nullToAbsent
          ? const Value.absent()
          : Value(billingPincode),
      billingCountry: billingCountry == null && nullToAbsent
          ? const Value.absent()
          : Value(billingCountry),
      paymentTerms: paymentTerms == null && nullToAbsent
          ? const Value.absent()
          : Value(paymentTerms),
      creditLimit: Value(creditLimit),
      creditDays: Value(creditDays),
      securityDeposit: Value(securityDeposit),
      fuelType: fuelType == null && nullToAbsent
          ? const Value.absent()
          : Value(fuelType),
      defaultGstRate: Value(defaultGstRate),
      defaultPrice: defaultPrice == null && nullToAbsent
          ? const Value.absent()
          : Value(defaultPrice),
      poNumber: poNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(poNumber),
      poDate: poDate == null && nullToAbsent
          ? const Value.absent()
          : Value(poDate),
      poValidTill: poValidTill == null && nullToAbsent
          ? const Value.absent()
          : Value(poValidTill),
      poValue: poValue == null && nullToAbsent
          ? const Value.absent()
          : Value(poValue),
      poRemainingBalance: poRemainingBalance == null && nullToAbsent
          ? const Value.absent()
          : Value(poRemainingBalance),
      invoicePrefix: invoicePrefix == null && nullToAbsent
          ? const Value.absent()
          : Value(invoicePrefix),
      emailInvoice: Value(emailInvoice),
      whatsappInvoice: Value(whatsappInvoice),
      requirePo: Value(requirePo),
      requireDc: Value(requireDc),
      requireSignature: Value(requireSignature),
      gstApplicable: Value(gstApplicable),
      eInvoiceRequired: Value(eInvoiceRequired),
      eWayBillRequired: Value(eWayBillRequired),
      openingBalance: Value(openingBalance),
      currentBalance: Value(currentBalance),
      lastPaymentDate: lastPaymentDate == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPaymentDate),
      lastInvoiceDate: lastInvoiceDate == null && nullToAbsent
          ? const Value.absent()
          : Value(lastInvoiceDate),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdBy: Value(createdBy),
      createdAt: Value(createdAt),
      updatedBy: Value(updatedBy),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      version: Value(version),
      tenantId: tenantId == null && nullToAbsent
          ? const Value.absent()
          : Value(tenantId),
    );
  }

  factory CustomerRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomerRow(
      id: serializer.fromJson<String>(json['id']),
      customerCode: serializer.fromJson<String>(json['customerCode']),
      name: serializer.fromJson<String>(json['name']),
      displayName: serializer.fromJson<String?>(json['displayName']),
      tradeName: serializer.fromJson<String?>(json['tradeName']),
      legalBusinessName: serializer.fromJson<String?>(
        json['legalBusinessName'],
      ),
      customerType: serializer.fromJson<String>(json['customerType']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      gstin: serializer.fromJson<String?>(json['gstin']),
      pan: serializer.fromJson<String?>(json['pan']),
      state: serializer.fromJson<String?>(json['state']),
      placeOfSupply: serializer.fromJson<String?>(json['placeOfSupply']),
      gstRegistrationType: serializer.fromJson<String?>(
        json['gstRegistrationType'],
      ),
      tan: serializer.fromJson<String?>(json['tan']),
      billingAddressLine1: serializer.fromJson<String?>(
        json['billingAddressLine1'],
      ),
      billingAddressLine2: serializer.fromJson<String?>(
        json['billingAddressLine2'],
      ),
      billingArea: serializer.fromJson<String?>(json['billingArea']),
      billingCity: serializer.fromJson<String?>(json['billingCity']),
      billingState: serializer.fromJson<String?>(json['billingState']),
      billingPincode: serializer.fromJson<String?>(json['billingPincode']),
      billingCountry: serializer.fromJson<String?>(json['billingCountry']),
      paymentTerms: serializer.fromJson<String?>(json['paymentTerms']),
      creditLimit: serializer.fromJson<double>(json['creditLimit']),
      creditDays: serializer.fromJson<int>(json['creditDays']),
      securityDeposit: serializer.fromJson<double>(json['securityDeposit']),
      fuelType: serializer.fromJson<String?>(json['fuelType']),
      defaultGstRate: serializer.fromJson<double>(json['defaultGstRate']),
      defaultPrice: serializer.fromJson<double?>(json['defaultPrice']),
      poNumber: serializer.fromJson<String?>(json['poNumber']),
      poDate: serializer.fromJson<DateTime?>(json['poDate']),
      poValidTill: serializer.fromJson<DateTime?>(json['poValidTill']),
      poValue: serializer.fromJson<double?>(json['poValue']),
      poRemainingBalance: serializer.fromJson<double?>(
        json['poRemainingBalance'],
      ),
      invoicePrefix: serializer.fromJson<String?>(json['invoicePrefix']),
      emailInvoice: serializer.fromJson<bool>(json['emailInvoice']),
      whatsappInvoice: serializer.fromJson<bool>(json['whatsappInvoice']),
      requirePo: serializer.fromJson<bool>(json['requirePo']),
      requireDc: serializer.fromJson<bool>(json['requireDc']),
      requireSignature: serializer.fromJson<bool>(json['requireSignature']),
      gstApplicable: serializer.fromJson<bool>(json['gstApplicable']),
      eInvoiceRequired: serializer.fromJson<bool>(json['eInvoiceRequired']),
      eWayBillRequired: serializer.fromJson<bool>(json['eWayBillRequired']),
      openingBalance: serializer.fromJson<double>(json['openingBalance']),
      currentBalance: serializer.fromJson<double>(json['currentBalance']),
      lastPaymentDate: serializer.fromJson<DateTime?>(json['lastPaymentDate']),
      lastInvoiceDate: serializer.fromJson<DateTime?>(json['lastInvoiceDate']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedBy: serializer.fromJson<String>(json['updatedBy']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      version: serializer.fromJson<int>(json['version']),
      tenantId: serializer.fromJson<String?>(json['tenantId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'customerCode': serializer.toJson<String>(customerCode),
      'name': serializer.toJson<String>(name),
      'displayName': serializer.toJson<String?>(displayName),
      'tradeName': serializer.toJson<String?>(tradeName),
      'legalBusinessName': serializer.toJson<String?>(legalBusinessName),
      'customerType': serializer.toJson<String>(customerType),
      'isActive': serializer.toJson<bool>(isActive),
      'gstin': serializer.toJson<String?>(gstin),
      'pan': serializer.toJson<String?>(pan),
      'state': serializer.toJson<String?>(state),
      'placeOfSupply': serializer.toJson<String?>(placeOfSupply),
      'gstRegistrationType': serializer.toJson<String?>(gstRegistrationType),
      'tan': serializer.toJson<String?>(tan),
      'billingAddressLine1': serializer.toJson<String?>(billingAddressLine1),
      'billingAddressLine2': serializer.toJson<String?>(billingAddressLine2),
      'billingArea': serializer.toJson<String?>(billingArea),
      'billingCity': serializer.toJson<String?>(billingCity),
      'billingState': serializer.toJson<String?>(billingState),
      'billingPincode': serializer.toJson<String?>(billingPincode),
      'billingCountry': serializer.toJson<String?>(billingCountry),
      'paymentTerms': serializer.toJson<String?>(paymentTerms),
      'creditLimit': serializer.toJson<double>(creditLimit),
      'creditDays': serializer.toJson<int>(creditDays),
      'securityDeposit': serializer.toJson<double>(securityDeposit),
      'fuelType': serializer.toJson<String?>(fuelType),
      'defaultGstRate': serializer.toJson<double>(defaultGstRate),
      'defaultPrice': serializer.toJson<double?>(defaultPrice),
      'poNumber': serializer.toJson<String?>(poNumber),
      'poDate': serializer.toJson<DateTime?>(poDate),
      'poValidTill': serializer.toJson<DateTime?>(poValidTill),
      'poValue': serializer.toJson<double?>(poValue),
      'poRemainingBalance': serializer.toJson<double?>(poRemainingBalance),
      'invoicePrefix': serializer.toJson<String?>(invoicePrefix),
      'emailInvoice': serializer.toJson<bool>(emailInvoice),
      'whatsappInvoice': serializer.toJson<bool>(whatsappInvoice),
      'requirePo': serializer.toJson<bool>(requirePo),
      'requireDc': serializer.toJson<bool>(requireDc),
      'requireSignature': serializer.toJson<bool>(requireSignature),
      'gstApplicable': serializer.toJson<bool>(gstApplicable),
      'eInvoiceRequired': serializer.toJson<bool>(eInvoiceRequired),
      'eWayBillRequired': serializer.toJson<bool>(eWayBillRequired),
      'openingBalance': serializer.toJson<double>(openingBalance),
      'currentBalance': serializer.toJson<double>(currentBalance),
      'lastPaymentDate': serializer.toJson<DateTime?>(lastPaymentDate),
      'lastInvoiceDate': serializer.toJson<DateTime?>(lastInvoiceDate),
      'notes': serializer.toJson<String?>(notes),
      'createdBy': serializer.toJson<String>(createdBy),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedBy': serializer.toJson<String>(updatedBy),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'version': serializer.toJson<int>(version),
      'tenantId': serializer.toJson<String?>(tenantId),
    };
  }

  CustomerRow copyWith({
    String? id,
    String? customerCode,
    String? name,
    Value<String?> displayName = const Value.absent(),
    Value<String?> tradeName = const Value.absent(),
    Value<String?> legalBusinessName = const Value.absent(),
    String? customerType,
    bool? isActive,
    Value<String?> gstin = const Value.absent(),
    Value<String?> pan = const Value.absent(),
    Value<String?> state = const Value.absent(),
    Value<String?> placeOfSupply = const Value.absent(),
    Value<String?> gstRegistrationType = const Value.absent(),
    Value<String?> tan = const Value.absent(),
    Value<String?> billingAddressLine1 = const Value.absent(),
    Value<String?> billingAddressLine2 = const Value.absent(),
    Value<String?> billingArea = const Value.absent(),
    Value<String?> billingCity = const Value.absent(),
    Value<String?> billingState = const Value.absent(),
    Value<String?> billingPincode = const Value.absent(),
    Value<String?> billingCountry = const Value.absent(),
    Value<String?> paymentTerms = const Value.absent(),
    double? creditLimit,
    int? creditDays,
    double? securityDeposit,
    Value<String?> fuelType = const Value.absent(),
    double? defaultGstRate,
    Value<double?> defaultPrice = const Value.absent(),
    Value<String?> poNumber = const Value.absent(),
    Value<DateTime?> poDate = const Value.absent(),
    Value<DateTime?> poValidTill = const Value.absent(),
    Value<double?> poValue = const Value.absent(),
    Value<double?> poRemainingBalance = const Value.absent(),
    Value<String?> invoicePrefix = const Value.absent(),
    bool? emailInvoice,
    bool? whatsappInvoice,
    bool? requirePo,
    bool? requireDc,
    bool? requireSignature,
    bool? gstApplicable,
    bool? eInvoiceRequired,
    bool? eWayBillRequired,
    double? openingBalance,
    double? currentBalance,
    Value<DateTime?> lastPaymentDate = const Value.absent(),
    Value<DateTime?> lastInvoiceDate = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    String? createdBy,
    DateTime? createdAt,
    String? updatedBy,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    int? version,
    Value<String?> tenantId = const Value.absent(),
  }) => CustomerRow(
    id: id ?? this.id,
    customerCode: customerCode ?? this.customerCode,
    name: name ?? this.name,
    displayName: displayName.present ? displayName.value : this.displayName,
    tradeName: tradeName.present ? tradeName.value : this.tradeName,
    legalBusinessName: legalBusinessName.present
        ? legalBusinessName.value
        : this.legalBusinessName,
    customerType: customerType ?? this.customerType,
    isActive: isActive ?? this.isActive,
    gstin: gstin.present ? gstin.value : this.gstin,
    pan: pan.present ? pan.value : this.pan,
    state: state.present ? state.value : this.state,
    placeOfSupply: placeOfSupply.present
        ? placeOfSupply.value
        : this.placeOfSupply,
    gstRegistrationType: gstRegistrationType.present
        ? gstRegistrationType.value
        : this.gstRegistrationType,
    tan: tan.present ? tan.value : this.tan,
    billingAddressLine1: billingAddressLine1.present
        ? billingAddressLine1.value
        : this.billingAddressLine1,
    billingAddressLine2: billingAddressLine2.present
        ? billingAddressLine2.value
        : this.billingAddressLine2,
    billingArea: billingArea.present ? billingArea.value : this.billingArea,
    billingCity: billingCity.present ? billingCity.value : this.billingCity,
    billingState: billingState.present ? billingState.value : this.billingState,
    billingPincode: billingPincode.present
        ? billingPincode.value
        : this.billingPincode,
    billingCountry: billingCountry.present
        ? billingCountry.value
        : this.billingCountry,
    paymentTerms: paymentTerms.present ? paymentTerms.value : this.paymentTerms,
    creditLimit: creditLimit ?? this.creditLimit,
    creditDays: creditDays ?? this.creditDays,
    securityDeposit: securityDeposit ?? this.securityDeposit,
    fuelType: fuelType.present ? fuelType.value : this.fuelType,
    defaultGstRate: defaultGstRate ?? this.defaultGstRate,
    defaultPrice: defaultPrice.present ? defaultPrice.value : this.defaultPrice,
    poNumber: poNumber.present ? poNumber.value : this.poNumber,
    poDate: poDate.present ? poDate.value : this.poDate,
    poValidTill: poValidTill.present ? poValidTill.value : this.poValidTill,
    poValue: poValue.present ? poValue.value : this.poValue,
    poRemainingBalance: poRemainingBalance.present
        ? poRemainingBalance.value
        : this.poRemainingBalance,
    invoicePrefix: invoicePrefix.present
        ? invoicePrefix.value
        : this.invoicePrefix,
    emailInvoice: emailInvoice ?? this.emailInvoice,
    whatsappInvoice: whatsappInvoice ?? this.whatsappInvoice,
    requirePo: requirePo ?? this.requirePo,
    requireDc: requireDc ?? this.requireDc,
    requireSignature: requireSignature ?? this.requireSignature,
    gstApplicable: gstApplicable ?? this.gstApplicable,
    eInvoiceRequired: eInvoiceRequired ?? this.eInvoiceRequired,
    eWayBillRequired: eWayBillRequired ?? this.eWayBillRequired,
    openingBalance: openingBalance ?? this.openingBalance,
    currentBalance: currentBalance ?? this.currentBalance,
    lastPaymentDate: lastPaymentDate.present
        ? lastPaymentDate.value
        : this.lastPaymentDate,
    lastInvoiceDate: lastInvoiceDate.present
        ? lastInvoiceDate.value
        : this.lastInvoiceDate,
    notes: notes.present ? notes.value : this.notes,
    createdBy: createdBy ?? this.createdBy,
    createdAt: createdAt ?? this.createdAt,
    updatedBy: updatedBy ?? this.updatedBy,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    version: version ?? this.version,
    tenantId: tenantId.present ? tenantId.value : this.tenantId,
  );
  CustomerRow copyWithCompanion(CustomersCompanion data) {
    return CustomerRow(
      id: data.id.present ? data.id.value : this.id,
      customerCode: data.customerCode.present
          ? data.customerCode.value
          : this.customerCode,
      name: data.name.present ? data.name.value : this.name,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      tradeName: data.tradeName.present ? data.tradeName.value : this.tradeName,
      legalBusinessName: data.legalBusinessName.present
          ? data.legalBusinessName.value
          : this.legalBusinessName,
      customerType: data.customerType.present
          ? data.customerType.value
          : this.customerType,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      gstin: data.gstin.present ? data.gstin.value : this.gstin,
      pan: data.pan.present ? data.pan.value : this.pan,
      state: data.state.present ? data.state.value : this.state,
      placeOfSupply: data.placeOfSupply.present
          ? data.placeOfSupply.value
          : this.placeOfSupply,
      gstRegistrationType: data.gstRegistrationType.present
          ? data.gstRegistrationType.value
          : this.gstRegistrationType,
      tan: data.tan.present ? data.tan.value : this.tan,
      billingAddressLine1: data.billingAddressLine1.present
          ? data.billingAddressLine1.value
          : this.billingAddressLine1,
      billingAddressLine2: data.billingAddressLine2.present
          ? data.billingAddressLine2.value
          : this.billingAddressLine2,
      billingArea: data.billingArea.present
          ? data.billingArea.value
          : this.billingArea,
      billingCity: data.billingCity.present
          ? data.billingCity.value
          : this.billingCity,
      billingState: data.billingState.present
          ? data.billingState.value
          : this.billingState,
      billingPincode: data.billingPincode.present
          ? data.billingPincode.value
          : this.billingPincode,
      billingCountry: data.billingCountry.present
          ? data.billingCountry.value
          : this.billingCountry,
      paymentTerms: data.paymentTerms.present
          ? data.paymentTerms.value
          : this.paymentTerms,
      creditLimit: data.creditLimit.present
          ? data.creditLimit.value
          : this.creditLimit,
      creditDays: data.creditDays.present
          ? data.creditDays.value
          : this.creditDays,
      securityDeposit: data.securityDeposit.present
          ? data.securityDeposit.value
          : this.securityDeposit,
      fuelType: data.fuelType.present ? data.fuelType.value : this.fuelType,
      defaultGstRate: data.defaultGstRate.present
          ? data.defaultGstRate.value
          : this.defaultGstRate,
      defaultPrice: data.defaultPrice.present
          ? data.defaultPrice.value
          : this.defaultPrice,
      poNumber: data.poNumber.present ? data.poNumber.value : this.poNumber,
      poDate: data.poDate.present ? data.poDate.value : this.poDate,
      poValidTill: data.poValidTill.present
          ? data.poValidTill.value
          : this.poValidTill,
      poValue: data.poValue.present ? data.poValue.value : this.poValue,
      poRemainingBalance: data.poRemainingBalance.present
          ? data.poRemainingBalance.value
          : this.poRemainingBalance,
      invoicePrefix: data.invoicePrefix.present
          ? data.invoicePrefix.value
          : this.invoicePrefix,
      emailInvoice: data.emailInvoice.present
          ? data.emailInvoice.value
          : this.emailInvoice,
      whatsappInvoice: data.whatsappInvoice.present
          ? data.whatsappInvoice.value
          : this.whatsappInvoice,
      requirePo: data.requirePo.present ? data.requirePo.value : this.requirePo,
      requireDc: data.requireDc.present ? data.requireDc.value : this.requireDc,
      requireSignature: data.requireSignature.present
          ? data.requireSignature.value
          : this.requireSignature,
      gstApplicable: data.gstApplicable.present
          ? data.gstApplicable.value
          : this.gstApplicable,
      eInvoiceRequired: data.eInvoiceRequired.present
          ? data.eInvoiceRequired.value
          : this.eInvoiceRequired,
      eWayBillRequired: data.eWayBillRequired.present
          ? data.eWayBillRequired.value
          : this.eWayBillRequired,
      openingBalance: data.openingBalance.present
          ? data.openingBalance.value
          : this.openingBalance,
      currentBalance: data.currentBalance.present
          ? data.currentBalance.value
          : this.currentBalance,
      lastPaymentDate: data.lastPaymentDate.present
          ? data.lastPaymentDate.value
          : this.lastPaymentDate,
      lastInvoiceDate: data.lastInvoiceDate.present
          ? data.lastInvoiceDate.value
          : this.lastInvoiceDate,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      version: data.version.present ? data.version.value : this.version,
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomerRow(')
          ..write('id: $id, ')
          ..write('customerCode: $customerCode, ')
          ..write('name: $name, ')
          ..write('displayName: $displayName, ')
          ..write('tradeName: $tradeName, ')
          ..write('legalBusinessName: $legalBusinessName, ')
          ..write('customerType: $customerType, ')
          ..write('isActive: $isActive, ')
          ..write('gstin: $gstin, ')
          ..write('pan: $pan, ')
          ..write('state: $state, ')
          ..write('placeOfSupply: $placeOfSupply, ')
          ..write('gstRegistrationType: $gstRegistrationType, ')
          ..write('tan: $tan, ')
          ..write('billingAddressLine1: $billingAddressLine1, ')
          ..write('billingAddressLine2: $billingAddressLine2, ')
          ..write('billingArea: $billingArea, ')
          ..write('billingCity: $billingCity, ')
          ..write('billingState: $billingState, ')
          ..write('billingPincode: $billingPincode, ')
          ..write('billingCountry: $billingCountry, ')
          ..write('paymentTerms: $paymentTerms, ')
          ..write('creditLimit: $creditLimit, ')
          ..write('creditDays: $creditDays, ')
          ..write('securityDeposit: $securityDeposit, ')
          ..write('fuelType: $fuelType, ')
          ..write('defaultGstRate: $defaultGstRate, ')
          ..write('defaultPrice: $defaultPrice, ')
          ..write('poNumber: $poNumber, ')
          ..write('poDate: $poDate, ')
          ..write('poValidTill: $poValidTill, ')
          ..write('poValue: $poValue, ')
          ..write('poRemainingBalance: $poRemainingBalance, ')
          ..write('invoicePrefix: $invoicePrefix, ')
          ..write('emailInvoice: $emailInvoice, ')
          ..write('whatsappInvoice: $whatsappInvoice, ')
          ..write('requirePo: $requirePo, ')
          ..write('requireDc: $requireDc, ')
          ..write('requireSignature: $requireSignature, ')
          ..write('gstApplicable: $gstApplicable, ')
          ..write('eInvoiceRequired: $eInvoiceRequired, ')
          ..write('eWayBillRequired: $eWayBillRequired, ')
          ..write('openingBalance: $openingBalance, ')
          ..write('currentBalance: $currentBalance, ')
          ..write('lastPaymentDate: $lastPaymentDate, ')
          ..write('lastInvoiceDate: $lastInvoiceDate, ')
          ..write('notes: $notes, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('version: $version, ')
          ..write('tenantId: $tenantId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    customerCode,
    name,
    displayName,
    tradeName,
    legalBusinessName,
    customerType,
    isActive,
    gstin,
    pan,
    state,
    placeOfSupply,
    gstRegistrationType,
    tan,
    billingAddressLine1,
    billingAddressLine2,
    billingArea,
    billingCity,
    billingState,
    billingPincode,
    billingCountry,
    paymentTerms,
    creditLimit,
    creditDays,
    securityDeposit,
    fuelType,
    defaultGstRate,
    defaultPrice,
    poNumber,
    poDate,
    poValidTill,
    poValue,
    poRemainingBalance,
    invoicePrefix,
    emailInvoice,
    whatsappInvoice,
    requirePo,
    requireDc,
    requireSignature,
    gstApplicable,
    eInvoiceRequired,
    eWayBillRequired,
    openingBalance,
    currentBalance,
    lastPaymentDate,
    lastInvoiceDate,
    notes,
    createdBy,
    createdAt,
    updatedBy,
    updatedAt,
    deletedAt,
    version,
    tenantId,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomerRow &&
          other.id == this.id &&
          other.customerCode == this.customerCode &&
          other.name == this.name &&
          other.displayName == this.displayName &&
          other.tradeName == this.tradeName &&
          other.legalBusinessName == this.legalBusinessName &&
          other.customerType == this.customerType &&
          other.isActive == this.isActive &&
          other.gstin == this.gstin &&
          other.pan == this.pan &&
          other.state == this.state &&
          other.placeOfSupply == this.placeOfSupply &&
          other.gstRegistrationType == this.gstRegistrationType &&
          other.tan == this.tan &&
          other.billingAddressLine1 == this.billingAddressLine1 &&
          other.billingAddressLine2 == this.billingAddressLine2 &&
          other.billingArea == this.billingArea &&
          other.billingCity == this.billingCity &&
          other.billingState == this.billingState &&
          other.billingPincode == this.billingPincode &&
          other.billingCountry == this.billingCountry &&
          other.paymentTerms == this.paymentTerms &&
          other.creditLimit == this.creditLimit &&
          other.creditDays == this.creditDays &&
          other.securityDeposit == this.securityDeposit &&
          other.fuelType == this.fuelType &&
          other.defaultGstRate == this.defaultGstRate &&
          other.defaultPrice == this.defaultPrice &&
          other.poNumber == this.poNumber &&
          other.poDate == this.poDate &&
          other.poValidTill == this.poValidTill &&
          other.poValue == this.poValue &&
          other.poRemainingBalance == this.poRemainingBalance &&
          other.invoicePrefix == this.invoicePrefix &&
          other.emailInvoice == this.emailInvoice &&
          other.whatsappInvoice == this.whatsappInvoice &&
          other.requirePo == this.requirePo &&
          other.requireDc == this.requireDc &&
          other.requireSignature == this.requireSignature &&
          other.gstApplicable == this.gstApplicable &&
          other.eInvoiceRequired == this.eInvoiceRequired &&
          other.eWayBillRequired == this.eWayBillRequired &&
          other.openingBalance == this.openingBalance &&
          other.currentBalance == this.currentBalance &&
          other.lastPaymentDate == this.lastPaymentDate &&
          other.lastInvoiceDate == this.lastInvoiceDate &&
          other.notes == this.notes &&
          other.createdBy == this.createdBy &&
          other.createdAt == this.createdAt &&
          other.updatedBy == this.updatedBy &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.version == this.version &&
          other.tenantId == this.tenantId);
}

class CustomersCompanion extends UpdateCompanion<CustomerRow> {
  final Value<String> id;
  final Value<String> customerCode;
  final Value<String> name;
  final Value<String?> displayName;
  final Value<String?> tradeName;
  final Value<String?> legalBusinessName;
  final Value<String> customerType;
  final Value<bool> isActive;
  final Value<String?> gstin;
  final Value<String?> pan;
  final Value<String?> state;
  final Value<String?> placeOfSupply;
  final Value<String?> gstRegistrationType;
  final Value<String?> tan;
  final Value<String?> billingAddressLine1;
  final Value<String?> billingAddressLine2;
  final Value<String?> billingArea;
  final Value<String?> billingCity;
  final Value<String?> billingState;
  final Value<String?> billingPincode;
  final Value<String?> billingCountry;
  final Value<String?> paymentTerms;
  final Value<double> creditLimit;
  final Value<int> creditDays;
  final Value<double> securityDeposit;
  final Value<String?> fuelType;
  final Value<double> defaultGstRate;
  final Value<double?> defaultPrice;
  final Value<String?> poNumber;
  final Value<DateTime?> poDate;
  final Value<DateTime?> poValidTill;
  final Value<double?> poValue;
  final Value<double?> poRemainingBalance;
  final Value<String?> invoicePrefix;
  final Value<bool> emailInvoice;
  final Value<bool> whatsappInvoice;
  final Value<bool> requirePo;
  final Value<bool> requireDc;
  final Value<bool> requireSignature;
  final Value<bool> gstApplicable;
  final Value<bool> eInvoiceRequired;
  final Value<bool> eWayBillRequired;
  final Value<double> openingBalance;
  final Value<double> currentBalance;
  final Value<DateTime?> lastPaymentDate;
  final Value<DateTime?> lastInvoiceDate;
  final Value<String?> notes;
  final Value<String> createdBy;
  final Value<DateTime> createdAt;
  final Value<String> updatedBy;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> version;
  final Value<String?> tenantId;
  final Value<int> rowid;
  const CustomersCompanion({
    this.id = const Value.absent(),
    this.customerCode = const Value.absent(),
    this.name = const Value.absent(),
    this.displayName = const Value.absent(),
    this.tradeName = const Value.absent(),
    this.legalBusinessName = const Value.absent(),
    this.customerType = const Value.absent(),
    this.isActive = const Value.absent(),
    this.gstin = const Value.absent(),
    this.pan = const Value.absent(),
    this.state = const Value.absent(),
    this.placeOfSupply = const Value.absent(),
    this.gstRegistrationType = const Value.absent(),
    this.tan = const Value.absent(),
    this.billingAddressLine1 = const Value.absent(),
    this.billingAddressLine2 = const Value.absent(),
    this.billingArea = const Value.absent(),
    this.billingCity = const Value.absent(),
    this.billingState = const Value.absent(),
    this.billingPincode = const Value.absent(),
    this.billingCountry = const Value.absent(),
    this.paymentTerms = const Value.absent(),
    this.creditLimit = const Value.absent(),
    this.creditDays = const Value.absent(),
    this.securityDeposit = const Value.absent(),
    this.fuelType = const Value.absent(),
    this.defaultGstRate = const Value.absent(),
    this.defaultPrice = const Value.absent(),
    this.poNumber = const Value.absent(),
    this.poDate = const Value.absent(),
    this.poValidTill = const Value.absent(),
    this.poValue = const Value.absent(),
    this.poRemainingBalance = const Value.absent(),
    this.invoicePrefix = const Value.absent(),
    this.emailInvoice = const Value.absent(),
    this.whatsappInvoice = const Value.absent(),
    this.requirePo = const Value.absent(),
    this.requireDc = const Value.absent(),
    this.requireSignature = const Value.absent(),
    this.gstApplicable = const Value.absent(),
    this.eInvoiceRequired = const Value.absent(),
    this.eWayBillRequired = const Value.absent(),
    this.openingBalance = const Value.absent(),
    this.currentBalance = const Value.absent(),
    this.lastPaymentDate = const Value.absent(),
    this.lastInvoiceDate = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CustomersCompanion.insert({
    required String id,
    required String customerCode,
    required String name,
    this.displayName = const Value.absent(),
    this.tradeName = const Value.absent(),
    this.legalBusinessName = const Value.absent(),
    required String customerType,
    this.isActive = const Value.absent(),
    this.gstin = const Value.absent(),
    this.pan = const Value.absent(),
    this.state = const Value.absent(),
    this.placeOfSupply = const Value.absent(),
    this.gstRegistrationType = const Value.absent(),
    this.tan = const Value.absent(),
    this.billingAddressLine1 = const Value.absent(),
    this.billingAddressLine2 = const Value.absent(),
    this.billingArea = const Value.absent(),
    this.billingCity = const Value.absent(),
    this.billingState = const Value.absent(),
    this.billingPincode = const Value.absent(),
    this.billingCountry = const Value.absent(),
    this.paymentTerms = const Value.absent(),
    this.creditLimit = const Value.absent(),
    this.creditDays = const Value.absent(),
    this.securityDeposit = const Value.absent(),
    this.fuelType = const Value.absent(),
    this.defaultGstRate = const Value.absent(),
    this.defaultPrice = const Value.absent(),
    this.poNumber = const Value.absent(),
    this.poDate = const Value.absent(),
    this.poValidTill = const Value.absent(),
    this.poValue = const Value.absent(),
    this.poRemainingBalance = const Value.absent(),
    this.invoicePrefix = const Value.absent(),
    this.emailInvoice = const Value.absent(),
    this.whatsappInvoice = const Value.absent(),
    this.requirePo = const Value.absent(),
    this.requireDc = const Value.absent(),
    this.requireSignature = const Value.absent(),
    this.gstApplicable = const Value.absent(),
    this.eInvoiceRequired = const Value.absent(),
    this.eWayBillRequired = const Value.absent(),
    this.openingBalance = const Value.absent(),
    this.currentBalance = const Value.absent(),
    this.lastPaymentDate = const Value.absent(),
    this.lastInvoiceDate = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdBy = const Value.absent(),
    required DateTime createdAt,
    this.updatedBy = const Value.absent(),
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       customerCode = Value(customerCode),
       name = Value(name),
       customerType = Value(customerType),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<CustomerRow> custom({
    Expression<String>? id,
    Expression<String>? customerCode,
    Expression<String>? name,
    Expression<String>? displayName,
    Expression<String>? tradeName,
    Expression<String>? legalBusinessName,
    Expression<String>? customerType,
    Expression<bool>? isActive,
    Expression<String>? gstin,
    Expression<String>? pan,
    Expression<String>? state,
    Expression<String>? placeOfSupply,
    Expression<String>? gstRegistrationType,
    Expression<String>? tan,
    Expression<String>? billingAddressLine1,
    Expression<String>? billingAddressLine2,
    Expression<String>? billingArea,
    Expression<String>? billingCity,
    Expression<String>? billingState,
    Expression<String>? billingPincode,
    Expression<String>? billingCountry,
    Expression<String>? paymentTerms,
    Expression<double>? creditLimit,
    Expression<int>? creditDays,
    Expression<double>? securityDeposit,
    Expression<String>? fuelType,
    Expression<double>? defaultGstRate,
    Expression<double>? defaultPrice,
    Expression<String>? poNumber,
    Expression<DateTime>? poDate,
    Expression<DateTime>? poValidTill,
    Expression<double>? poValue,
    Expression<double>? poRemainingBalance,
    Expression<String>? invoicePrefix,
    Expression<bool>? emailInvoice,
    Expression<bool>? whatsappInvoice,
    Expression<bool>? requirePo,
    Expression<bool>? requireDc,
    Expression<bool>? requireSignature,
    Expression<bool>? gstApplicable,
    Expression<bool>? eInvoiceRequired,
    Expression<bool>? eWayBillRequired,
    Expression<double>? openingBalance,
    Expression<double>? currentBalance,
    Expression<DateTime>? lastPaymentDate,
    Expression<DateTime>? lastInvoiceDate,
    Expression<String>? notes,
    Expression<String>? createdBy,
    Expression<DateTime>? createdAt,
    Expression<String>? updatedBy,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? version,
    Expression<String>? tenantId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (customerCode != null) 'customer_code': customerCode,
      if (name != null) 'name': name,
      if (displayName != null) 'display_name': displayName,
      if (tradeName != null) 'trade_name': tradeName,
      if (legalBusinessName != null) 'legal_business_name': legalBusinessName,
      if (customerType != null) 'customer_type': customerType,
      if (isActive != null) 'is_active': isActive,
      if (gstin != null) 'gstin': gstin,
      if (pan != null) 'pan': pan,
      if (state != null) 'state': state,
      if (placeOfSupply != null) 'place_of_supply': placeOfSupply,
      if (gstRegistrationType != null)
        'gst_registration_type': gstRegistrationType,
      if (tan != null) 'tan': tan,
      if (billingAddressLine1 != null)
        'billing_address_line1': billingAddressLine1,
      if (billingAddressLine2 != null)
        'billing_address_line2': billingAddressLine2,
      if (billingArea != null) 'billing_area': billingArea,
      if (billingCity != null) 'billing_city': billingCity,
      if (billingState != null) 'billing_state': billingState,
      if (billingPincode != null) 'billing_pincode': billingPincode,
      if (billingCountry != null) 'billing_country': billingCountry,
      if (paymentTerms != null) 'payment_terms': paymentTerms,
      if (creditLimit != null) 'credit_limit': creditLimit,
      if (creditDays != null) 'credit_days': creditDays,
      if (securityDeposit != null) 'security_deposit': securityDeposit,
      if (fuelType != null) 'fuel_type': fuelType,
      if (defaultGstRate != null) 'default_gst_rate': defaultGstRate,
      if (defaultPrice != null) 'default_price': defaultPrice,
      if (poNumber != null) 'po_number': poNumber,
      if (poDate != null) 'po_date': poDate,
      if (poValidTill != null) 'po_valid_till': poValidTill,
      if (poValue != null) 'po_value': poValue,
      if (poRemainingBalance != null)
        'po_remaining_balance': poRemainingBalance,
      if (invoicePrefix != null) 'invoice_prefix': invoicePrefix,
      if (emailInvoice != null) 'email_invoice': emailInvoice,
      if (whatsappInvoice != null) 'whatsapp_invoice': whatsappInvoice,
      if (requirePo != null) 'require_po': requirePo,
      if (requireDc != null) 'require_dc': requireDc,
      if (requireSignature != null) 'require_signature': requireSignature,
      if (gstApplicable != null) 'gst_applicable': gstApplicable,
      if (eInvoiceRequired != null) 'e_invoice_required': eInvoiceRequired,
      if (eWayBillRequired != null) 'e_way_bill_required': eWayBillRequired,
      if (openingBalance != null) 'opening_balance': openingBalance,
      if (currentBalance != null) 'current_balance': currentBalance,
      if (lastPaymentDate != null) 'last_payment_date': lastPaymentDate,
      if (lastInvoiceDate != null) 'last_invoice_date': lastInvoiceDate,
      if (notes != null) 'notes': notes,
      if (createdBy != null) 'created_by': createdBy,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedBy != null) 'updated_by': updatedBy,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (version != null) 'version': version,
      if (tenantId != null) 'tenant_id': tenantId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CustomersCompanion copyWith({
    Value<String>? id,
    Value<String>? customerCode,
    Value<String>? name,
    Value<String?>? displayName,
    Value<String?>? tradeName,
    Value<String?>? legalBusinessName,
    Value<String>? customerType,
    Value<bool>? isActive,
    Value<String?>? gstin,
    Value<String?>? pan,
    Value<String?>? state,
    Value<String?>? placeOfSupply,
    Value<String?>? gstRegistrationType,
    Value<String?>? tan,
    Value<String?>? billingAddressLine1,
    Value<String?>? billingAddressLine2,
    Value<String?>? billingArea,
    Value<String?>? billingCity,
    Value<String?>? billingState,
    Value<String?>? billingPincode,
    Value<String?>? billingCountry,
    Value<String?>? paymentTerms,
    Value<double>? creditLimit,
    Value<int>? creditDays,
    Value<double>? securityDeposit,
    Value<String?>? fuelType,
    Value<double>? defaultGstRate,
    Value<double?>? defaultPrice,
    Value<String?>? poNumber,
    Value<DateTime?>? poDate,
    Value<DateTime?>? poValidTill,
    Value<double?>? poValue,
    Value<double?>? poRemainingBalance,
    Value<String?>? invoicePrefix,
    Value<bool>? emailInvoice,
    Value<bool>? whatsappInvoice,
    Value<bool>? requirePo,
    Value<bool>? requireDc,
    Value<bool>? requireSignature,
    Value<bool>? gstApplicable,
    Value<bool>? eInvoiceRequired,
    Value<bool>? eWayBillRequired,
    Value<double>? openingBalance,
    Value<double>? currentBalance,
    Value<DateTime?>? lastPaymentDate,
    Value<DateTime?>? lastInvoiceDate,
    Value<String?>? notes,
    Value<String>? createdBy,
    Value<DateTime>? createdAt,
    Value<String>? updatedBy,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? version,
    Value<String?>? tenantId,
    Value<int>? rowid,
  }) {
    return CustomersCompanion(
      id: id ?? this.id,
      customerCode: customerCode ?? this.customerCode,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      tradeName: tradeName ?? this.tradeName,
      legalBusinessName: legalBusinessName ?? this.legalBusinessName,
      customerType: customerType ?? this.customerType,
      isActive: isActive ?? this.isActive,
      gstin: gstin ?? this.gstin,
      pan: pan ?? this.pan,
      state: state ?? this.state,
      placeOfSupply: placeOfSupply ?? this.placeOfSupply,
      gstRegistrationType: gstRegistrationType ?? this.gstRegistrationType,
      tan: tan ?? this.tan,
      billingAddressLine1: billingAddressLine1 ?? this.billingAddressLine1,
      billingAddressLine2: billingAddressLine2 ?? this.billingAddressLine2,
      billingArea: billingArea ?? this.billingArea,
      billingCity: billingCity ?? this.billingCity,
      billingState: billingState ?? this.billingState,
      billingPincode: billingPincode ?? this.billingPincode,
      billingCountry: billingCountry ?? this.billingCountry,
      paymentTerms: paymentTerms ?? this.paymentTerms,
      creditLimit: creditLimit ?? this.creditLimit,
      creditDays: creditDays ?? this.creditDays,
      securityDeposit: securityDeposit ?? this.securityDeposit,
      fuelType: fuelType ?? this.fuelType,
      defaultGstRate: defaultGstRate ?? this.defaultGstRate,
      defaultPrice: defaultPrice ?? this.defaultPrice,
      poNumber: poNumber ?? this.poNumber,
      poDate: poDate ?? this.poDate,
      poValidTill: poValidTill ?? this.poValidTill,
      poValue: poValue ?? this.poValue,
      poRemainingBalance: poRemainingBalance ?? this.poRemainingBalance,
      invoicePrefix: invoicePrefix ?? this.invoicePrefix,
      emailInvoice: emailInvoice ?? this.emailInvoice,
      whatsappInvoice: whatsappInvoice ?? this.whatsappInvoice,
      requirePo: requirePo ?? this.requirePo,
      requireDc: requireDc ?? this.requireDc,
      requireSignature: requireSignature ?? this.requireSignature,
      gstApplicable: gstApplicable ?? this.gstApplicable,
      eInvoiceRequired: eInvoiceRequired ?? this.eInvoiceRequired,
      eWayBillRequired: eWayBillRequired ?? this.eWayBillRequired,
      openingBalance: openingBalance ?? this.openingBalance,
      currentBalance: currentBalance ?? this.currentBalance,
      lastPaymentDate: lastPaymentDate ?? this.lastPaymentDate,
      lastInvoiceDate: lastInvoiceDate ?? this.lastInvoiceDate,
      notes: notes ?? this.notes,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedBy: updatedBy ?? this.updatedBy,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      version: version ?? this.version,
      tenantId: tenantId ?? this.tenantId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (customerCode.present) {
      map['customer_code'] = Variable<String>(customerCode.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (tradeName.present) {
      map['trade_name'] = Variable<String>(tradeName.value);
    }
    if (legalBusinessName.present) {
      map['legal_business_name'] = Variable<String>(legalBusinessName.value);
    }
    if (customerType.present) {
      map['customer_type'] = Variable<String>(customerType.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (gstin.present) {
      map['gstin'] = Variable<String>(gstin.value);
    }
    if (pan.present) {
      map['pan'] = Variable<String>(pan.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (placeOfSupply.present) {
      map['place_of_supply'] = Variable<String>(placeOfSupply.value);
    }
    if (gstRegistrationType.present) {
      map['gst_registration_type'] = Variable<String>(
        gstRegistrationType.value,
      );
    }
    if (tan.present) {
      map['tan'] = Variable<String>(tan.value);
    }
    if (billingAddressLine1.present) {
      map['billing_address_line1'] = Variable<String>(
        billingAddressLine1.value,
      );
    }
    if (billingAddressLine2.present) {
      map['billing_address_line2'] = Variable<String>(
        billingAddressLine2.value,
      );
    }
    if (billingArea.present) {
      map['billing_area'] = Variable<String>(billingArea.value);
    }
    if (billingCity.present) {
      map['billing_city'] = Variable<String>(billingCity.value);
    }
    if (billingState.present) {
      map['billing_state'] = Variable<String>(billingState.value);
    }
    if (billingPincode.present) {
      map['billing_pincode'] = Variable<String>(billingPincode.value);
    }
    if (billingCountry.present) {
      map['billing_country'] = Variable<String>(billingCountry.value);
    }
    if (paymentTerms.present) {
      map['payment_terms'] = Variable<String>(paymentTerms.value);
    }
    if (creditLimit.present) {
      map['credit_limit'] = Variable<double>(creditLimit.value);
    }
    if (creditDays.present) {
      map['credit_days'] = Variable<int>(creditDays.value);
    }
    if (securityDeposit.present) {
      map['security_deposit'] = Variable<double>(securityDeposit.value);
    }
    if (fuelType.present) {
      map['fuel_type'] = Variable<String>(fuelType.value);
    }
    if (defaultGstRate.present) {
      map['default_gst_rate'] = Variable<double>(defaultGstRate.value);
    }
    if (defaultPrice.present) {
      map['default_price'] = Variable<double>(defaultPrice.value);
    }
    if (poNumber.present) {
      map['po_number'] = Variable<String>(poNumber.value);
    }
    if (poDate.present) {
      map['po_date'] = Variable<DateTime>(poDate.value);
    }
    if (poValidTill.present) {
      map['po_valid_till'] = Variable<DateTime>(poValidTill.value);
    }
    if (poValue.present) {
      map['po_value'] = Variable<double>(poValue.value);
    }
    if (poRemainingBalance.present) {
      map['po_remaining_balance'] = Variable<double>(poRemainingBalance.value);
    }
    if (invoicePrefix.present) {
      map['invoice_prefix'] = Variable<String>(invoicePrefix.value);
    }
    if (emailInvoice.present) {
      map['email_invoice'] = Variable<bool>(emailInvoice.value);
    }
    if (whatsappInvoice.present) {
      map['whatsapp_invoice'] = Variable<bool>(whatsappInvoice.value);
    }
    if (requirePo.present) {
      map['require_po'] = Variable<bool>(requirePo.value);
    }
    if (requireDc.present) {
      map['require_dc'] = Variable<bool>(requireDc.value);
    }
    if (requireSignature.present) {
      map['require_signature'] = Variable<bool>(requireSignature.value);
    }
    if (gstApplicable.present) {
      map['gst_applicable'] = Variable<bool>(gstApplicable.value);
    }
    if (eInvoiceRequired.present) {
      map['e_invoice_required'] = Variable<bool>(eInvoiceRequired.value);
    }
    if (eWayBillRequired.present) {
      map['e_way_bill_required'] = Variable<bool>(eWayBillRequired.value);
    }
    if (openingBalance.present) {
      map['opening_balance'] = Variable<double>(openingBalance.value);
    }
    if (currentBalance.present) {
      map['current_balance'] = Variable<double>(currentBalance.value);
    }
    if (lastPaymentDate.present) {
      map['last_payment_date'] = Variable<DateTime>(lastPaymentDate.value);
    }
    if (lastInvoiceDate.present) {
      map['last_invoice_date'] = Variable<DateTime>(lastInvoiceDate.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedBy.present) {
      map['updated_by'] = Variable<String>(updatedBy.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (tenantId.present) {
      map['tenant_id'] = Variable<String>(tenantId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomersCompanion(')
          ..write('id: $id, ')
          ..write('customerCode: $customerCode, ')
          ..write('name: $name, ')
          ..write('displayName: $displayName, ')
          ..write('tradeName: $tradeName, ')
          ..write('legalBusinessName: $legalBusinessName, ')
          ..write('customerType: $customerType, ')
          ..write('isActive: $isActive, ')
          ..write('gstin: $gstin, ')
          ..write('pan: $pan, ')
          ..write('state: $state, ')
          ..write('placeOfSupply: $placeOfSupply, ')
          ..write('gstRegistrationType: $gstRegistrationType, ')
          ..write('tan: $tan, ')
          ..write('billingAddressLine1: $billingAddressLine1, ')
          ..write('billingAddressLine2: $billingAddressLine2, ')
          ..write('billingArea: $billingArea, ')
          ..write('billingCity: $billingCity, ')
          ..write('billingState: $billingState, ')
          ..write('billingPincode: $billingPincode, ')
          ..write('billingCountry: $billingCountry, ')
          ..write('paymentTerms: $paymentTerms, ')
          ..write('creditLimit: $creditLimit, ')
          ..write('creditDays: $creditDays, ')
          ..write('securityDeposit: $securityDeposit, ')
          ..write('fuelType: $fuelType, ')
          ..write('defaultGstRate: $defaultGstRate, ')
          ..write('defaultPrice: $defaultPrice, ')
          ..write('poNumber: $poNumber, ')
          ..write('poDate: $poDate, ')
          ..write('poValidTill: $poValidTill, ')
          ..write('poValue: $poValue, ')
          ..write('poRemainingBalance: $poRemainingBalance, ')
          ..write('invoicePrefix: $invoicePrefix, ')
          ..write('emailInvoice: $emailInvoice, ')
          ..write('whatsappInvoice: $whatsappInvoice, ')
          ..write('requirePo: $requirePo, ')
          ..write('requireDc: $requireDc, ')
          ..write('requireSignature: $requireSignature, ')
          ..write('gstApplicable: $gstApplicable, ')
          ..write('eInvoiceRequired: $eInvoiceRequired, ')
          ..write('eWayBillRequired: $eWayBillRequired, ')
          ..write('openingBalance: $openingBalance, ')
          ..write('currentBalance: $currentBalance, ')
          ..write('lastPaymentDate: $lastPaymentDate, ')
          ..write('lastInvoiceDate: $lastInvoiceDate, ')
          ..write('notes: $notes, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('version: $version, ')
          ..write('tenantId: $tenantId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CustomerSitesTable extends CustomerSites
    with TableInfo<$CustomerSitesTable, CustomerSiteRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomerSitesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _customerIdMeta = const VerificationMeta(
    'customerId',
  );
  @override
  late final GeneratedColumn<String> customerId = GeneratedColumn<String>(
    'customer_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES customers (id)',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _addressLine1Meta = const VerificationMeta(
    'addressLine1',
  );
  @override
  late final GeneratedColumn<String> addressLine1 = GeneratedColumn<String>(
    'address_line1',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addressLine2Meta = const VerificationMeta(
    'addressLine2',
  );
  @override
  late final GeneratedColumn<String> addressLine2 = GeneratedColumn<String>(
    'address_line2',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cityMeta = const VerificationMeta('city');
  @override
  late final GeneratedColumn<String> city = GeneratedColumn<String>(
    'city',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stateCodeMeta = const VerificationMeta(
    'stateCode',
  );
  @override
  late final GeneratedColumn<String> stateCode = GeneratedColumn<String>(
    'state_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pincodeMeta = const VerificationMeta(
    'pincode',
  );
  @override
  late final GeneratedColumn<String> pincode = GeneratedColumn<String>(
    'pincode',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _countryMeta = const VerificationMeta(
    'country',
  );
  @override
  late final GeneratedColumn<String> country = GeneratedColumn<String>(
    'country',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contactPersonMeta = const VerificationMeta(
    'contactPerson',
  );
  @override
  late final GeneratedColumn<String> contactPerson = GeneratedColumn<String>(
    'contact_person',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contactNumberMeta = const VerificationMeta(
    'contactNumber',
  );
  @override
  late final GeneratedColumn<String> contactNumber = GeneratedColumn<String>(
    'contact_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDefaultMeta = const VerificationMeta(
    'isDefault',
  );
  @override
  late final GeneratedColumn<bool> isDefault = GeneratedColumn<bool>(
    'is_default',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_default" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('system'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedByMeta = const VerificationMeta(
    'updatedBy',
  );
  @override
  late final GeneratedColumn<String> updatedBy = GeneratedColumn<String>(
    'updated_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('system'),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _tenantIdMeta = const VerificationMeta(
    'tenantId',
  );
  @override
  late final GeneratedColumn<String> tenantId = GeneratedColumn<String>(
    'tenant_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    customerId,
    name,
    addressLine1,
    addressLine2,
    city,
    state,
    stateCode,
    pincode,
    country,
    latitude,
    longitude,
    contactPerson,
    contactNumber,
    isDefault,
    isActive,
    createdBy,
    createdAt,
    updatedBy,
    updatedAt,
    deletedAt,
    version,
    tenantId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'customer_sites';
  @override
  VerificationContext validateIntegrity(
    Insertable<CustomerSiteRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('customer_id')) {
      context.handle(
        _customerIdMeta,
        customerId.isAcceptableOrUnknown(data['customer_id']!, _customerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_customerIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('address_line1')) {
      context.handle(
        _addressLine1Meta,
        addressLine1.isAcceptableOrUnknown(
          data['address_line1']!,
          _addressLine1Meta,
        ),
      );
    }
    if (data.containsKey('address_line2')) {
      context.handle(
        _addressLine2Meta,
        addressLine2.isAcceptableOrUnknown(
          data['address_line2']!,
          _addressLine2Meta,
        ),
      );
    }
    if (data.containsKey('city')) {
      context.handle(
        _cityMeta,
        city.isAcceptableOrUnknown(data['city']!, _cityMeta),
      );
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    }
    if (data.containsKey('state_code')) {
      context.handle(
        _stateCodeMeta,
        stateCode.isAcceptableOrUnknown(data['state_code']!, _stateCodeMeta),
      );
    }
    if (data.containsKey('pincode')) {
      context.handle(
        _pincodeMeta,
        pincode.isAcceptableOrUnknown(data['pincode']!, _pincodeMeta),
      );
    }
    if (data.containsKey('country')) {
      context.handle(
        _countryMeta,
        country.isAcceptableOrUnknown(data['country']!, _countryMeta),
      );
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    }
    if (data.containsKey('contact_person')) {
      context.handle(
        _contactPersonMeta,
        contactPerson.isAcceptableOrUnknown(
          data['contact_person']!,
          _contactPersonMeta,
        ),
      );
    }
    if (data.containsKey('contact_number')) {
      context.handle(
        _contactNumberMeta,
        contactNumber.isAcceptableOrUnknown(
          data['contact_number']!,
          _contactNumberMeta,
        ),
      );
    }
    if (data.containsKey('is_default')) {
      context.handle(
        _isDefaultMeta,
        isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_by')) {
      context.handle(
        _updatedByMeta,
        updatedBy.isAcceptableOrUnknown(data['updated_by']!, _updatedByMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('tenant_id')) {
      context.handle(
        _tenantIdMeta,
        tenantId.isAcceptableOrUnknown(data['tenant_id']!, _tenantIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CustomerSiteRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomerSiteRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      addressLine1: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address_line1'],
      ),
      addressLine2: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address_line2'],
      ),
      city: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}city'],
      ),
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      ),
      stateCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state_code'],
      ),
      pincode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pincode'],
      ),
      country: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}country'],
      ),
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      ),
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      ),
      contactPerson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}contact_person'],
      ),
      contactNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}contact_number'],
      ),
      isDefault: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_default'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_by'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      tenantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tenant_id'],
      ),
    );
  }

  @override
  $CustomerSitesTable createAlias(String alias) {
    return $CustomerSitesTable(attachedDatabase, alias);
  }
}

class CustomerSiteRow extends DataClass implements Insertable<CustomerSiteRow> {
  final String id;
  final String customerId;
  final String name;
  final String? addressLine1;
  final String? addressLine2;
  final String? city;
  final String? state;
  final String? stateCode;
  final String? pincode;
  final String? country;
  final double? latitude;
  final double? longitude;
  final String? contactPerson;
  final String? contactNumber;
  final bool isDefault;
  final bool isActive;
  final String createdBy;
  final DateTime createdAt;
  final String updatedBy;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int version;
  final String? tenantId;
  const CustomerSiteRow({
    required this.id,
    required this.customerId,
    required this.name,
    this.addressLine1,
    this.addressLine2,
    this.city,
    this.state,
    this.stateCode,
    this.pincode,
    this.country,
    this.latitude,
    this.longitude,
    this.contactPerson,
    this.contactNumber,
    required this.isDefault,
    required this.isActive,
    required this.createdBy,
    required this.createdAt,
    required this.updatedBy,
    required this.updatedAt,
    this.deletedAt,
    required this.version,
    this.tenantId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['customer_id'] = Variable<String>(customerId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || addressLine1 != null) {
      map['address_line1'] = Variable<String>(addressLine1);
    }
    if (!nullToAbsent || addressLine2 != null) {
      map['address_line2'] = Variable<String>(addressLine2);
    }
    if (!nullToAbsent || city != null) {
      map['city'] = Variable<String>(city);
    }
    if (!nullToAbsent || state != null) {
      map['state'] = Variable<String>(state);
    }
    if (!nullToAbsent || stateCode != null) {
      map['state_code'] = Variable<String>(stateCode);
    }
    if (!nullToAbsent || pincode != null) {
      map['pincode'] = Variable<String>(pincode);
    }
    if (!nullToAbsent || country != null) {
      map['country'] = Variable<String>(country);
    }
    if (!nullToAbsent || latitude != null) {
      map['latitude'] = Variable<double>(latitude);
    }
    if (!nullToAbsent || longitude != null) {
      map['longitude'] = Variable<double>(longitude);
    }
    if (!nullToAbsent || contactPerson != null) {
      map['contact_person'] = Variable<String>(contactPerson);
    }
    if (!nullToAbsent || contactNumber != null) {
      map['contact_number'] = Variable<String>(contactNumber);
    }
    map['is_default'] = Variable<bool>(isDefault);
    map['is_active'] = Variable<bool>(isActive);
    map['created_by'] = Variable<String>(createdBy);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_by'] = Variable<String>(updatedBy);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['version'] = Variable<int>(version);
    if (!nullToAbsent || tenantId != null) {
      map['tenant_id'] = Variable<String>(tenantId);
    }
    return map;
  }

  CustomerSitesCompanion toCompanion(bool nullToAbsent) {
    return CustomerSitesCompanion(
      id: Value(id),
      customerId: Value(customerId),
      name: Value(name),
      addressLine1: addressLine1 == null && nullToAbsent
          ? const Value.absent()
          : Value(addressLine1),
      addressLine2: addressLine2 == null && nullToAbsent
          ? const Value.absent()
          : Value(addressLine2),
      city: city == null && nullToAbsent ? const Value.absent() : Value(city),
      state: state == null && nullToAbsent
          ? const Value.absent()
          : Value(state),
      stateCode: stateCode == null && nullToAbsent
          ? const Value.absent()
          : Value(stateCode),
      pincode: pincode == null && nullToAbsent
          ? const Value.absent()
          : Value(pincode),
      country: country == null && nullToAbsent
          ? const Value.absent()
          : Value(country),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
      contactPerson: contactPerson == null && nullToAbsent
          ? const Value.absent()
          : Value(contactPerson),
      contactNumber: contactNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(contactNumber),
      isDefault: Value(isDefault),
      isActive: Value(isActive),
      createdBy: Value(createdBy),
      createdAt: Value(createdAt),
      updatedBy: Value(updatedBy),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      version: Value(version),
      tenantId: tenantId == null && nullToAbsent
          ? const Value.absent()
          : Value(tenantId),
    );
  }

  factory CustomerSiteRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomerSiteRow(
      id: serializer.fromJson<String>(json['id']),
      customerId: serializer.fromJson<String>(json['customerId']),
      name: serializer.fromJson<String>(json['name']),
      addressLine1: serializer.fromJson<String?>(json['addressLine1']),
      addressLine2: serializer.fromJson<String?>(json['addressLine2']),
      city: serializer.fromJson<String?>(json['city']),
      state: serializer.fromJson<String?>(json['state']),
      stateCode: serializer.fromJson<String?>(json['stateCode']),
      pincode: serializer.fromJson<String?>(json['pincode']),
      country: serializer.fromJson<String?>(json['country']),
      latitude: serializer.fromJson<double?>(json['latitude']),
      longitude: serializer.fromJson<double?>(json['longitude']),
      contactPerson: serializer.fromJson<String?>(json['contactPerson']),
      contactNumber: serializer.fromJson<String?>(json['contactNumber']),
      isDefault: serializer.fromJson<bool>(json['isDefault']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedBy: serializer.fromJson<String>(json['updatedBy']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      version: serializer.fromJson<int>(json['version']),
      tenantId: serializer.fromJson<String?>(json['tenantId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'customerId': serializer.toJson<String>(customerId),
      'name': serializer.toJson<String>(name),
      'addressLine1': serializer.toJson<String?>(addressLine1),
      'addressLine2': serializer.toJson<String?>(addressLine2),
      'city': serializer.toJson<String?>(city),
      'state': serializer.toJson<String?>(state),
      'stateCode': serializer.toJson<String?>(stateCode),
      'pincode': serializer.toJson<String?>(pincode),
      'country': serializer.toJson<String?>(country),
      'latitude': serializer.toJson<double?>(latitude),
      'longitude': serializer.toJson<double?>(longitude),
      'contactPerson': serializer.toJson<String?>(contactPerson),
      'contactNumber': serializer.toJson<String?>(contactNumber),
      'isDefault': serializer.toJson<bool>(isDefault),
      'isActive': serializer.toJson<bool>(isActive),
      'createdBy': serializer.toJson<String>(createdBy),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedBy': serializer.toJson<String>(updatedBy),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'version': serializer.toJson<int>(version),
      'tenantId': serializer.toJson<String?>(tenantId),
    };
  }

  CustomerSiteRow copyWith({
    String? id,
    String? customerId,
    String? name,
    Value<String?> addressLine1 = const Value.absent(),
    Value<String?> addressLine2 = const Value.absent(),
    Value<String?> city = const Value.absent(),
    Value<String?> state = const Value.absent(),
    Value<String?> stateCode = const Value.absent(),
    Value<String?> pincode = const Value.absent(),
    Value<String?> country = const Value.absent(),
    Value<double?> latitude = const Value.absent(),
    Value<double?> longitude = const Value.absent(),
    Value<String?> contactPerson = const Value.absent(),
    Value<String?> contactNumber = const Value.absent(),
    bool? isDefault,
    bool? isActive,
    String? createdBy,
    DateTime? createdAt,
    String? updatedBy,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    int? version,
    Value<String?> tenantId = const Value.absent(),
  }) => CustomerSiteRow(
    id: id ?? this.id,
    customerId: customerId ?? this.customerId,
    name: name ?? this.name,
    addressLine1: addressLine1.present ? addressLine1.value : this.addressLine1,
    addressLine2: addressLine2.present ? addressLine2.value : this.addressLine2,
    city: city.present ? city.value : this.city,
    state: state.present ? state.value : this.state,
    stateCode: stateCode.present ? stateCode.value : this.stateCode,
    pincode: pincode.present ? pincode.value : this.pincode,
    country: country.present ? country.value : this.country,
    latitude: latitude.present ? latitude.value : this.latitude,
    longitude: longitude.present ? longitude.value : this.longitude,
    contactPerson: contactPerson.present
        ? contactPerson.value
        : this.contactPerson,
    contactNumber: contactNumber.present
        ? contactNumber.value
        : this.contactNumber,
    isDefault: isDefault ?? this.isDefault,
    isActive: isActive ?? this.isActive,
    createdBy: createdBy ?? this.createdBy,
    createdAt: createdAt ?? this.createdAt,
    updatedBy: updatedBy ?? this.updatedBy,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    version: version ?? this.version,
    tenantId: tenantId.present ? tenantId.value : this.tenantId,
  );
  CustomerSiteRow copyWithCompanion(CustomerSitesCompanion data) {
    return CustomerSiteRow(
      id: data.id.present ? data.id.value : this.id,
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
      name: data.name.present ? data.name.value : this.name,
      addressLine1: data.addressLine1.present
          ? data.addressLine1.value
          : this.addressLine1,
      addressLine2: data.addressLine2.present
          ? data.addressLine2.value
          : this.addressLine2,
      city: data.city.present ? data.city.value : this.city,
      state: data.state.present ? data.state.value : this.state,
      stateCode: data.stateCode.present ? data.stateCode.value : this.stateCode,
      pincode: data.pincode.present ? data.pincode.value : this.pincode,
      country: data.country.present ? data.country.value : this.country,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      contactPerson: data.contactPerson.present
          ? data.contactPerson.value
          : this.contactPerson,
      contactNumber: data.contactNumber.present
          ? data.contactNumber.value
          : this.contactNumber,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      version: data.version.present ? data.version.value : this.version,
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomerSiteRow(')
          ..write('id: $id, ')
          ..write('customerId: $customerId, ')
          ..write('name: $name, ')
          ..write('addressLine1: $addressLine1, ')
          ..write('addressLine2: $addressLine2, ')
          ..write('city: $city, ')
          ..write('state: $state, ')
          ..write('stateCode: $stateCode, ')
          ..write('pincode: $pincode, ')
          ..write('country: $country, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('contactPerson: $contactPerson, ')
          ..write('contactNumber: $contactNumber, ')
          ..write('isDefault: $isDefault, ')
          ..write('isActive: $isActive, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('version: $version, ')
          ..write('tenantId: $tenantId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    customerId,
    name,
    addressLine1,
    addressLine2,
    city,
    state,
    stateCode,
    pincode,
    country,
    latitude,
    longitude,
    contactPerson,
    contactNumber,
    isDefault,
    isActive,
    createdBy,
    createdAt,
    updatedBy,
    updatedAt,
    deletedAt,
    version,
    tenantId,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomerSiteRow &&
          other.id == this.id &&
          other.customerId == this.customerId &&
          other.name == this.name &&
          other.addressLine1 == this.addressLine1 &&
          other.addressLine2 == this.addressLine2 &&
          other.city == this.city &&
          other.state == this.state &&
          other.stateCode == this.stateCode &&
          other.pincode == this.pincode &&
          other.country == this.country &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.contactPerson == this.contactPerson &&
          other.contactNumber == this.contactNumber &&
          other.isDefault == this.isDefault &&
          other.isActive == this.isActive &&
          other.createdBy == this.createdBy &&
          other.createdAt == this.createdAt &&
          other.updatedBy == this.updatedBy &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.version == this.version &&
          other.tenantId == this.tenantId);
}

class CustomerSitesCompanion extends UpdateCompanion<CustomerSiteRow> {
  final Value<String> id;
  final Value<String> customerId;
  final Value<String> name;
  final Value<String?> addressLine1;
  final Value<String?> addressLine2;
  final Value<String?> city;
  final Value<String?> state;
  final Value<String?> stateCode;
  final Value<String?> pincode;
  final Value<String?> country;
  final Value<double?> latitude;
  final Value<double?> longitude;
  final Value<String?> contactPerson;
  final Value<String?> contactNumber;
  final Value<bool> isDefault;
  final Value<bool> isActive;
  final Value<String> createdBy;
  final Value<DateTime> createdAt;
  final Value<String> updatedBy;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> version;
  final Value<String?> tenantId;
  final Value<int> rowid;
  const CustomerSitesCompanion({
    this.id = const Value.absent(),
    this.customerId = const Value.absent(),
    this.name = const Value.absent(),
    this.addressLine1 = const Value.absent(),
    this.addressLine2 = const Value.absent(),
    this.city = const Value.absent(),
    this.state = const Value.absent(),
    this.stateCode = const Value.absent(),
    this.pincode = const Value.absent(),
    this.country = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.contactPerson = const Value.absent(),
    this.contactNumber = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CustomerSitesCompanion.insert({
    required String id,
    required String customerId,
    required String name,
    this.addressLine1 = const Value.absent(),
    this.addressLine2 = const Value.absent(),
    this.city = const Value.absent(),
    this.state = const Value.absent(),
    this.stateCode = const Value.absent(),
    this.pincode = const Value.absent(),
    this.country = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.contactPerson = const Value.absent(),
    this.contactNumber = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdBy = const Value.absent(),
    required DateTime createdAt,
    this.updatedBy = const Value.absent(),
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       customerId = Value(customerId),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<CustomerSiteRow> custom({
    Expression<String>? id,
    Expression<String>? customerId,
    Expression<String>? name,
    Expression<String>? addressLine1,
    Expression<String>? addressLine2,
    Expression<String>? city,
    Expression<String>? state,
    Expression<String>? stateCode,
    Expression<String>? pincode,
    Expression<String>? country,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<String>? contactPerson,
    Expression<String>? contactNumber,
    Expression<bool>? isDefault,
    Expression<bool>? isActive,
    Expression<String>? createdBy,
    Expression<DateTime>? createdAt,
    Expression<String>? updatedBy,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? version,
    Expression<String>? tenantId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (customerId != null) 'customer_id': customerId,
      if (name != null) 'name': name,
      if (addressLine1 != null) 'address_line1': addressLine1,
      if (addressLine2 != null) 'address_line2': addressLine2,
      if (city != null) 'city': city,
      if (state != null) 'state': state,
      if (stateCode != null) 'state_code': stateCode,
      if (pincode != null) 'pincode': pincode,
      if (country != null) 'country': country,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (contactPerson != null) 'contact_person': contactPerson,
      if (contactNumber != null) 'contact_number': contactNumber,
      if (isDefault != null) 'is_default': isDefault,
      if (isActive != null) 'is_active': isActive,
      if (createdBy != null) 'created_by': createdBy,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedBy != null) 'updated_by': updatedBy,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (version != null) 'version': version,
      if (tenantId != null) 'tenant_id': tenantId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CustomerSitesCompanion copyWith({
    Value<String>? id,
    Value<String>? customerId,
    Value<String>? name,
    Value<String?>? addressLine1,
    Value<String?>? addressLine2,
    Value<String?>? city,
    Value<String?>? state,
    Value<String?>? stateCode,
    Value<String?>? pincode,
    Value<String?>? country,
    Value<double?>? latitude,
    Value<double?>? longitude,
    Value<String?>? contactPerson,
    Value<String?>? contactNumber,
    Value<bool>? isDefault,
    Value<bool>? isActive,
    Value<String>? createdBy,
    Value<DateTime>? createdAt,
    Value<String>? updatedBy,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? version,
    Value<String?>? tenantId,
    Value<int>? rowid,
  }) {
    return CustomerSitesCompanion(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      name: name ?? this.name,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      city: city ?? this.city,
      state: state ?? this.state,
      stateCode: stateCode ?? this.stateCode,
      pincode: pincode ?? this.pincode,
      country: country ?? this.country,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      contactPerson: contactPerson ?? this.contactPerson,
      contactNumber: contactNumber ?? this.contactNumber,
      isDefault: isDefault ?? this.isDefault,
      isActive: isActive ?? this.isActive,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedBy: updatedBy ?? this.updatedBy,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      version: version ?? this.version,
      tenantId: tenantId ?? this.tenantId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<String>(customerId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (addressLine1.present) {
      map['address_line1'] = Variable<String>(addressLine1.value);
    }
    if (addressLine2.present) {
      map['address_line2'] = Variable<String>(addressLine2.value);
    }
    if (city.present) {
      map['city'] = Variable<String>(city.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (stateCode.present) {
      map['state_code'] = Variable<String>(stateCode.value);
    }
    if (pincode.present) {
      map['pincode'] = Variable<String>(pincode.value);
    }
    if (country.present) {
      map['country'] = Variable<String>(country.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (contactPerson.present) {
      map['contact_person'] = Variable<String>(contactPerson.value);
    }
    if (contactNumber.present) {
      map['contact_number'] = Variable<String>(contactNumber.value);
    }
    if (isDefault.present) {
      map['is_default'] = Variable<bool>(isDefault.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedBy.present) {
      map['updated_by'] = Variable<String>(updatedBy.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (tenantId.present) {
      map['tenant_id'] = Variable<String>(tenantId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomerSitesCompanion(')
          ..write('id: $id, ')
          ..write('customerId: $customerId, ')
          ..write('name: $name, ')
          ..write('addressLine1: $addressLine1, ')
          ..write('addressLine2: $addressLine2, ')
          ..write('city: $city, ')
          ..write('state: $state, ')
          ..write('stateCode: $stateCode, ')
          ..write('pincode: $pincode, ')
          ..write('country: $country, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('contactPerson: $contactPerson, ')
          ..write('contactNumber: $contactNumber, ')
          ..write('isDefault: $isDefault, ')
          ..write('isActive: $isActive, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('version: $version, ')
          ..write('tenantId: $tenantId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CustomerContactsTable extends CustomerContacts
    with TableInfo<$CustomerContactsTable, CustomerContactRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomerContactsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _customerIdMeta = const VerificationMeta(
    'customerId',
  );
  @override
  late final GeneratedColumn<String> customerId = GeneratedColumn<String>(
    'customer_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES customers (id)',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _designationMeta = const VerificationMeta(
    'designation',
  );
  @override
  late final GeneratedColumn<String> designation = GeneratedColumn<String>(
    'designation',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _whatsappMeta = const VerificationMeta(
    'whatsapp',
  );
  @override
  late final GeneratedColumn<String> whatsapp = GeneratedColumn<String>(
    'whatsapp',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isPrimaryMeta = const VerificationMeta(
    'isPrimary',
  );
  @override
  late final GeneratedColumn<bool> isPrimary = GeneratedColumn<bool>(
    'is_primary',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_primary" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('system'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedByMeta = const VerificationMeta(
    'updatedBy',
  );
  @override
  late final GeneratedColumn<String> updatedBy = GeneratedColumn<String>(
    'updated_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('system'),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _tenantIdMeta = const VerificationMeta(
    'tenantId',
  );
  @override
  late final GeneratedColumn<String> tenantId = GeneratedColumn<String>(
    'tenant_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    customerId,
    name,
    designation,
    phone,
    email,
    whatsapp,
    isPrimary,
    isActive,
    createdBy,
    createdAt,
    updatedBy,
    updatedAt,
    deletedAt,
    version,
    tenantId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'customer_contacts';
  @override
  VerificationContext validateIntegrity(
    Insertable<CustomerContactRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('customer_id')) {
      context.handle(
        _customerIdMeta,
        customerId.isAcceptableOrUnknown(data['customer_id']!, _customerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_customerIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('designation')) {
      context.handle(
        _designationMeta,
        designation.isAcceptableOrUnknown(
          data['designation']!,
          _designationMeta,
        ),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('whatsapp')) {
      context.handle(
        _whatsappMeta,
        whatsapp.isAcceptableOrUnknown(data['whatsapp']!, _whatsappMeta),
      );
    }
    if (data.containsKey('is_primary')) {
      context.handle(
        _isPrimaryMeta,
        isPrimary.isAcceptableOrUnknown(data['is_primary']!, _isPrimaryMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_by')) {
      context.handle(
        _updatedByMeta,
        updatedBy.isAcceptableOrUnknown(data['updated_by']!, _updatedByMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('tenant_id')) {
      context.handle(
        _tenantIdMeta,
        tenantId.isAcceptableOrUnknown(data['tenant_id']!, _tenantIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CustomerContactRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomerContactRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      designation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}designation'],
      ),
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      whatsapp: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}whatsapp'],
      ),
      isPrimary: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_primary'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_by'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      tenantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tenant_id'],
      ),
    );
  }

  @override
  $CustomerContactsTable createAlias(String alias) {
    return $CustomerContactsTable(attachedDatabase, alias);
  }
}

class CustomerContactRow extends DataClass
    implements Insertable<CustomerContactRow> {
  final String id;
  final String customerId;
  final String name;
  final String? designation;
  final String? phone;
  final String? email;
  final String? whatsapp;
  final bool isPrimary;
  final bool isActive;
  final String createdBy;
  final DateTime createdAt;
  final String updatedBy;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int version;
  final String? tenantId;
  const CustomerContactRow({
    required this.id,
    required this.customerId,
    required this.name,
    this.designation,
    this.phone,
    this.email,
    this.whatsapp,
    required this.isPrimary,
    required this.isActive,
    required this.createdBy,
    required this.createdAt,
    required this.updatedBy,
    required this.updatedAt,
    this.deletedAt,
    required this.version,
    this.tenantId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['customer_id'] = Variable<String>(customerId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || designation != null) {
      map['designation'] = Variable<String>(designation);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || whatsapp != null) {
      map['whatsapp'] = Variable<String>(whatsapp);
    }
    map['is_primary'] = Variable<bool>(isPrimary);
    map['is_active'] = Variable<bool>(isActive);
    map['created_by'] = Variable<String>(createdBy);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_by'] = Variable<String>(updatedBy);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['version'] = Variable<int>(version);
    if (!nullToAbsent || tenantId != null) {
      map['tenant_id'] = Variable<String>(tenantId);
    }
    return map;
  }

  CustomerContactsCompanion toCompanion(bool nullToAbsent) {
    return CustomerContactsCompanion(
      id: Value(id),
      customerId: Value(customerId),
      name: Value(name),
      designation: designation == null && nullToAbsent
          ? const Value.absent()
          : Value(designation),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      whatsapp: whatsapp == null && nullToAbsent
          ? const Value.absent()
          : Value(whatsapp),
      isPrimary: Value(isPrimary),
      isActive: Value(isActive),
      createdBy: Value(createdBy),
      createdAt: Value(createdAt),
      updatedBy: Value(updatedBy),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      version: Value(version),
      tenantId: tenantId == null && nullToAbsent
          ? const Value.absent()
          : Value(tenantId),
    );
  }

  factory CustomerContactRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomerContactRow(
      id: serializer.fromJson<String>(json['id']),
      customerId: serializer.fromJson<String>(json['customerId']),
      name: serializer.fromJson<String>(json['name']),
      designation: serializer.fromJson<String?>(json['designation']),
      phone: serializer.fromJson<String?>(json['phone']),
      email: serializer.fromJson<String?>(json['email']),
      whatsapp: serializer.fromJson<String?>(json['whatsapp']),
      isPrimary: serializer.fromJson<bool>(json['isPrimary']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedBy: serializer.fromJson<String>(json['updatedBy']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      version: serializer.fromJson<int>(json['version']),
      tenantId: serializer.fromJson<String?>(json['tenantId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'customerId': serializer.toJson<String>(customerId),
      'name': serializer.toJson<String>(name),
      'designation': serializer.toJson<String?>(designation),
      'phone': serializer.toJson<String?>(phone),
      'email': serializer.toJson<String?>(email),
      'whatsapp': serializer.toJson<String?>(whatsapp),
      'isPrimary': serializer.toJson<bool>(isPrimary),
      'isActive': serializer.toJson<bool>(isActive),
      'createdBy': serializer.toJson<String>(createdBy),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedBy': serializer.toJson<String>(updatedBy),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'version': serializer.toJson<int>(version),
      'tenantId': serializer.toJson<String?>(tenantId),
    };
  }

  CustomerContactRow copyWith({
    String? id,
    String? customerId,
    String? name,
    Value<String?> designation = const Value.absent(),
    Value<String?> phone = const Value.absent(),
    Value<String?> email = const Value.absent(),
    Value<String?> whatsapp = const Value.absent(),
    bool? isPrimary,
    bool? isActive,
    String? createdBy,
    DateTime? createdAt,
    String? updatedBy,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    int? version,
    Value<String?> tenantId = const Value.absent(),
  }) => CustomerContactRow(
    id: id ?? this.id,
    customerId: customerId ?? this.customerId,
    name: name ?? this.name,
    designation: designation.present ? designation.value : this.designation,
    phone: phone.present ? phone.value : this.phone,
    email: email.present ? email.value : this.email,
    whatsapp: whatsapp.present ? whatsapp.value : this.whatsapp,
    isPrimary: isPrimary ?? this.isPrimary,
    isActive: isActive ?? this.isActive,
    createdBy: createdBy ?? this.createdBy,
    createdAt: createdAt ?? this.createdAt,
    updatedBy: updatedBy ?? this.updatedBy,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    version: version ?? this.version,
    tenantId: tenantId.present ? tenantId.value : this.tenantId,
  );
  CustomerContactRow copyWithCompanion(CustomerContactsCompanion data) {
    return CustomerContactRow(
      id: data.id.present ? data.id.value : this.id,
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
      name: data.name.present ? data.name.value : this.name,
      designation: data.designation.present
          ? data.designation.value
          : this.designation,
      phone: data.phone.present ? data.phone.value : this.phone,
      email: data.email.present ? data.email.value : this.email,
      whatsapp: data.whatsapp.present ? data.whatsapp.value : this.whatsapp,
      isPrimary: data.isPrimary.present ? data.isPrimary.value : this.isPrimary,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      version: data.version.present ? data.version.value : this.version,
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomerContactRow(')
          ..write('id: $id, ')
          ..write('customerId: $customerId, ')
          ..write('name: $name, ')
          ..write('designation: $designation, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('whatsapp: $whatsapp, ')
          ..write('isPrimary: $isPrimary, ')
          ..write('isActive: $isActive, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('version: $version, ')
          ..write('tenantId: $tenantId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    customerId,
    name,
    designation,
    phone,
    email,
    whatsapp,
    isPrimary,
    isActive,
    createdBy,
    createdAt,
    updatedBy,
    updatedAt,
    deletedAt,
    version,
    tenantId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomerContactRow &&
          other.id == this.id &&
          other.customerId == this.customerId &&
          other.name == this.name &&
          other.designation == this.designation &&
          other.phone == this.phone &&
          other.email == this.email &&
          other.whatsapp == this.whatsapp &&
          other.isPrimary == this.isPrimary &&
          other.isActive == this.isActive &&
          other.createdBy == this.createdBy &&
          other.createdAt == this.createdAt &&
          other.updatedBy == this.updatedBy &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.version == this.version &&
          other.tenantId == this.tenantId);
}

class CustomerContactsCompanion extends UpdateCompanion<CustomerContactRow> {
  final Value<String> id;
  final Value<String> customerId;
  final Value<String> name;
  final Value<String?> designation;
  final Value<String?> phone;
  final Value<String?> email;
  final Value<String?> whatsapp;
  final Value<bool> isPrimary;
  final Value<bool> isActive;
  final Value<String> createdBy;
  final Value<DateTime> createdAt;
  final Value<String> updatedBy;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> version;
  final Value<String?> tenantId;
  final Value<int> rowid;
  const CustomerContactsCompanion({
    this.id = const Value.absent(),
    this.customerId = const Value.absent(),
    this.name = const Value.absent(),
    this.designation = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.whatsapp = const Value.absent(),
    this.isPrimary = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CustomerContactsCompanion.insert({
    required String id,
    required String customerId,
    required String name,
    this.designation = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.whatsapp = const Value.absent(),
    this.isPrimary = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdBy = const Value.absent(),
    required DateTime createdAt,
    this.updatedBy = const Value.absent(),
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       customerId = Value(customerId),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<CustomerContactRow> custom({
    Expression<String>? id,
    Expression<String>? customerId,
    Expression<String>? name,
    Expression<String>? designation,
    Expression<String>? phone,
    Expression<String>? email,
    Expression<String>? whatsapp,
    Expression<bool>? isPrimary,
    Expression<bool>? isActive,
    Expression<String>? createdBy,
    Expression<DateTime>? createdAt,
    Expression<String>? updatedBy,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? version,
    Expression<String>? tenantId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (customerId != null) 'customer_id': customerId,
      if (name != null) 'name': name,
      if (designation != null) 'designation': designation,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (whatsapp != null) 'whatsapp': whatsapp,
      if (isPrimary != null) 'is_primary': isPrimary,
      if (isActive != null) 'is_active': isActive,
      if (createdBy != null) 'created_by': createdBy,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedBy != null) 'updated_by': updatedBy,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (version != null) 'version': version,
      if (tenantId != null) 'tenant_id': tenantId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CustomerContactsCompanion copyWith({
    Value<String>? id,
    Value<String>? customerId,
    Value<String>? name,
    Value<String?>? designation,
    Value<String?>? phone,
    Value<String?>? email,
    Value<String?>? whatsapp,
    Value<bool>? isPrimary,
    Value<bool>? isActive,
    Value<String>? createdBy,
    Value<DateTime>? createdAt,
    Value<String>? updatedBy,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? version,
    Value<String?>? tenantId,
    Value<int>? rowid,
  }) {
    return CustomerContactsCompanion(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      name: name ?? this.name,
      designation: designation ?? this.designation,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      whatsapp: whatsapp ?? this.whatsapp,
      isPrimary: isPrimary ?? this.isPrimary,
      isActive: isActive ?? this.isActive,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedBy: updatedBy ?? this.updatedBy,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      version: version ?? this.version,
      tenantId: tenantId ?? this.tenantId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<String>(customerId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (designation.present) {
      map['designation'] = Variable<String>(designation.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (whatsapp.present) {
      map['whatsapp'] = Variable<String>(whatsapp.value);
    }
    if (isPrimary.present) {
      map['is_primary'] = Variable<bool>(isPrimary.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedBy.present) {
      map['updated_by'] = Variable<String>(updatedBy.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (tenantId.present) {
      map['tenant_id'] = Variable<String>(tenantId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomerContactsCompanion(')
          ..write('id: $id, ')
          ..write('customerId: $customerId, ')
          ..write('name: $name, ')
          ..write('designation: $designation, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('whatsapp: $whatsapp, ')
          ..write('isPrimary: $isPrimary, ')
          ..write('isActive: $isActive, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('version: $version, ')
          ..write('tenantId: $tenantId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CustomerCreditLimitsTable extends CustomerCreditLimits
    with TableInfo<$CustomerCreditLimitsTable, CustomerCreditLimitRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomerCreditLimitsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _customerIdMeta = const VerificationMeta(
    'customerId',
  );
  @override
  late final GeneratedColumn<String> customerId = GeneratedColumn<String>(
    'customer_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES customers (id)',
    ),
  );
  static const VerificationMeta _creditLimitMeta = const VerificationMeta(
    'creditLimit',
  );
  @override
  late final GeneratedColumn<double> creditLimit = GeneratedColumn<double>(
    'credit_limit',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _effectiveFromMeta = const VerificationMeta(
    'effectiveFrom',
  );
  @override
  late final GeneratedColumn<DateTime> effectiveFrom =
      GeneratedColumn<DateTime>(
        'effective_from',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    customerId,
    creditLimit,
    effectiveFrom,
    notes,
    createdAt,
    createdBy,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'customer_credit_limits';
  @override
  VerificationContext validateIntegrity(
    Insertable<CustomerCreditLimitRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('customer_id')) {
      context.handle(
        _customerIdMeta,
        customerId.isAcceptableOrUnknown(data['customer_id']!, _customerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_customerIdMeta);
    }
    if (data.containsKey('credit_limit')) {
      context.handle(
        _creditLimitMeta,
        creditLimit.isAcceptableOrUnknown(
          data['credit_limit']!,
          _creditLimitMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_creditLimitMeta);
    }
    if (data.containsKey('effective_from')) {
      context.handle(
        _effectiveFromMeta,
        effectiveFrom.isAcceptableOrUnknown(
          data['effective_from']!,
          _effectiveFromMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_effectiveFromMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CustomerCreditLimitRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomerCreditLimitRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_id'],
      )!,
      creditLimit: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}credit_limit'],
      )!,
      effectiveFrom: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}effective_from'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      ),
    );
  }

  @override
  $CustomerCreditLimitsTable createAlias(String alias) {
    return $CustomerCreditLimitsTable(attachedDatabase, alias);
  }
}

class CustomerCreditLimitRow extends DataClass
    implements Insertable<CustomerCreditLimitRow> {
  final String id;
  final String customerId;
  final double creditLimit;
  final DateTime effectiveFrom;
  final String? notes;
  final DateTime createdAt;
  final String? createdBy;
  const CustomerCreditLimitRow({
    required this.id,
    required this.customerId,
    required this.creditLimit,
    required this.effectiveFrom,
    this.notes,
    required this.createdAt,
    this.createdBy,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['customer_id'] = Variable<String>(customerId);
    map['credit_limit'] = Variable<double>(creditLimit);
    map['effective_from'] = Variable<DateTime>(effectiveFrom);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || createdBy != null) {
      map['created_by'] = Variable<String>(createdBy);
    }
    return map;
  }

  CustomerCreditLimitsCompanion toCompanion(bool nullToAbsent) {
    return CustomerCreditLimitsCompanion(
      id: Value(id),
      customerId: Value(customerId),
      creditLimit: Value(creditLimit),
      effectiveFrom: Value(effectiveFrom),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
      createdBy: createdBy == null && nullToAbsent
          ? const Value.absent()
          : Value(createdBy),
    );
  }

  factory CustomerCreditLimitRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomerCreditLimitRow(
      id: serializer.fromJson<String>(json['id']),
      customerId: serializer.fromJson<String>(json['customerId']),
      creditLimit: serializer.fromJson<double>(json['creditLimit']),
      effectiveFrom: serializer.fromJson<DateTime>(json['effectiveFrom']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'customerId': serializer.toJson<String>(customerId),
      'creditLimit': serializer.toJson<double>(creditLimit),
      'effectiveFrom': serializer.toJson<DateTime>(effectiveFrom),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'createdBy': serializer.toJson<String?>(createdBy),
    };
  }

  CustomerCreditLimitRow copyWith({
    String? id,
    String? customerId,
    double? creditLimit,
    DateTime? effectiveFrom,
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
    Value<String?> createdBy = const Value.absent(),
  }) => CustomerCreditLimitRow(
    id: id ?? this.id,
    customerId: customerId ?? this.customerId,
    creditLimit: creditLimit ?? this.creditLimit,
    effectiveFrom: effectiveFrom ?? this.effectiveFrom,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
    createdBy: createdBy.present ? createdBy.value : this.createdBy,
  );
  CustomerCreditLimitRow copyWithCompanion(CustomerCreditLimitsCompanion data) {
    return CustomerCreditLimitRow(
      id: data.id.present ? data.id.value : this.id,
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
      creditLimit: data.creditLimit.present
          ? data.creditLimit.value
          : this.creditLimit,
      effectiveFrom: data.effectiveFrom.present
          ? data.effectiveFrom.value
          : this.effectiveFrom,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomerCreditLimitRow(')
          ..write('id: $id, ')
          ..write('customerId: $customerId, ')
          ..write('creditLimit: $creditLimit, ')
          ..write('effectiveFrom: $effectiveFrom, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('createdBy: $createdBy')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    customerId,
    creditLimit,
    effectiveFrom,
    notes,
    createdAt,
    createdBy,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomerCreditLimitRow &&
          other.id == this.id &&
          other.customerId == this.customerId &&
          other.creditLimit == this.creditLimit &&
          other.effectiveFrom == this.effectiveFrom &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.createdBy == this.createdBy);
}

class CustomerCreditLimitsCompanion
    extends UpdateCompanion<CustomerCreditLimitRow> {
  final Value<String> id;
  final Value<String> customerId;
  final Value<double> creditLimit;
  final Value<DateTime> effectiveFrom;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<String?> createdBy;
  final Value<int> rowid;
  const CustomerCreditLimitsCompanion({
    this.id = const Value.absent(),
    this.customerId = const Value.absent(),
    this.creditLimit = const Value.absent(),
    this.effectiveFrom = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CustomerCreditLimitsCompanion.insert({
    required String id,
    required String customerId,
    required double creditLimit,
    required DateTime effectiveFrom,
    this.notes = const Value.absent(),
    required DateTime createdAt,
    this.createdBy = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       customerId = Value(customerId),
       creditLimit = Value(creditLimit),
       effectiveFrom = Value(effectiveFrom),
       createdAt = Value(createdAt);
  static Insertable<CustomerCreditLimitRow> custom({
    Expression<String>? id,
    Expression<String>? customerId,
    Expression<double>? creditLimit,
    Expression<DateTime>? effectiveFrom,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<String>? createdBy,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (customerId != null) 'customer_id': customerId,
      if (creditLimit != null) 'credit_limit': creditLimit,
      if (effectiveFrom != null) 'effective_from': effectiveFrom,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (createdBy != null) 'created_by': createdBy,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CustomerCreditLimitsCompanion copyWith({
    Value<String>? id,
    Value<String>? customerId,
    Value<double>? creditLimit,
    Value<DateTime>? effectiveFrom,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
    Value<String?>? createdBy,
    Value<int>? rowid,
  }) {
    return CustomerCreditLimitsCompanion(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      creditLimit: creditLimit ?? this.creditLimit,
      effectiveFrom: effectiveFrom ?? this.effectiveFrom,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<String>(customerId.value);
    }
    if (creditLimit.present) {
      map['credit_limit'] = Variable<double>(creditLimit.value);
    }
    if (effectiveFrom.present) {
      map['effective_from'] = Variable<DateTime>(effectiveFrom.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomerCreditLimitsCompanion(')
          ..write('id: $id, ')
          ..write('customerId: $customerId, ')
          ..write('creditLimit: $creditLimit, ')
          ..write('effectiveFrom: $effectiveFrom, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CustomerDocumentsTable extends CustomerDocuments
    with TableInfo<$CustomerDocumentsTable, CustomerDocumentRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomerDocumentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _customerIdMeta = const VerificationMeta(
    'customerId',
  );
  @override
  late final GeneratedColumn<String> customerId = GeneratedColumn<String>(
    'customer_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES customers (id)',
    ),
  );
  static const VerificationMeta _documentTypeMeta = const VerificationMeta(
    'documentType',
  );
  @override
  late final GeneratedColumn<String> documentType = GeneratedColumn<String>(
    'document_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileUrlMeta = const VerificationMeta(
    'fileUrl',
  );
  @override
  late final GeneratedColumn<String> fileUrl = GeneratedColumn<String>(
    'file_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('system'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedByMeta = const VerificationMeta(
    'updatedBy',
  );
  @override
  late final GeneratedColumn<String> updatedBy = GeneratedColumn<String>(
    'updated_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tenantIdMeta = const VerificationMeta(
    'tenantId',
  );
  @override
  late final GeneratedColumn<String> tenantId = GeneratedColumn<String>(
    'tenant_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    customerId,
    documentType,
    fileUrl,
    createdBy,
    createdAt,
    updatedBy,
    updatedAt,
    deletedAt,
    tenantId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'customer_documents';
  @override
  VerificationContext validateIntegrity(
    Insertable<CustomerDocumentRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('customer_id')) {
      context.handle(
        _customerIdMeta,
        customerId.isAcceptableOrUnknown(data['customer_id']!, _customerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_customerIdMeta);
    }
    if (data.containsKey('document_type')) {
      context.handle(
        _documentTypeMeta,
        documentType.isAcceptableOrUnknown(
          data['document_type']!,
          _documentTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_documentTypeMeta);
    }
    if (data.containsKey('file_url')) {
      context.handle(
        _fileUrlMeta,
        fileUrl.isAcceptableOrUnknown(data['file_url']!, _fileUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_fileUrlMeta);
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_by')) {
      context.handle(
        _updatedByMeta,
        updatedBy.isAcceptableOrUnknown(data['updated_by']!, _updatedByMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('tenant_id')) {
      context.handle(
        _tenantIdMeta,
        tenantId.isAcceptableOrUnknown(data['tenant_id']!, _tenantIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CustomerDocumentRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomerDocumentRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_id'],
      )!,
      documentType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}document_type'],
      )!,
      fileUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_url'],
      )!,
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_by'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      tenantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tenant_id'],
      ),
    );
  }

  @override
  $CustomerDocumentsTable createAlias(String alias) {
    return $CustomerDocumentsTable(attachedDatabase, alias);
  }
}

class CustomerDocumentRow extends DataClass
    implements Insertable<CustomerDocumentRow> {
  final String id;
  final String customerId;
  final String documentType;
  final String fileUrl;
  final String createdBy;
  final DateTime createdAt;
  final String? updatedBy;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final String? tenantId;
  const CustomerDocumentRow({
    required this.id,
    required this.customerId,
    required this.documentType,
    required this.fileUrl,
    required this.createdBy,
    required this.createdAt,
    this.updatedBy,
    this.updatedAt,
    this.deletedAt,
    this.tenantId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['customer_id'] = Variable<String>(customerId);
    map['document_type'] = Variable<String>(documentType);
    map['file_url'] = Variable<String>(fileUrl);
    map['created_by'] = Variable<String>(createdBy);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedBy != null) {
      map['updated_by'] = Variable<String>(updatedBy);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || tenantId != null) {
      map['tenant_id'] = Variable<String>(tenantId);
    }
    return map;
  }

  CustomerDocumentsCompanion toCompanion(bool nullToAbsent) {
    return CustomerDocumentsCompanion(
      id: Value(id),
      customerId: Value(customerId),
      documentType: Value(documentType),
      fileUrl: Value(fileUrl),
      createdBy: Value(createdBy),
      createdAt: Value(createdAt),
      updatedBy: updatedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedBy),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      tenantId: tenantId == null && nullToAbsent
          ? const Value.absent()
          : Value(tenantId),
    );
  }

  factory CustomerDocumentRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomerDocumentRow(
      id: serializer.fromJson<String>(json['id']),
      customerId: serializer.fromJson<String>(json['customerId']),
      documentType: serializer.fromJson<String>(json['documentType']),
      fileUrl: serializer.fromJson<String>(json['fileUrl']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedBy: serializer.fromJson<String?>(json['updatedBy']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      tenantId: serializer.fromJson<String?>(json['tenantId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'customerId': serializer.toJson<String>(customerId),
      'documentType': serializer.toJson<String>(documentType),
      'fileUrl': serializer.toJson<String>(fileUrl),
      'createdBy': serializer.toJson<String>(createdBy),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedBy': serializer.toJson<String?>(updatedBy),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'tenantId': serializer.toJson<String?>(tenantId),
    };
  }

  CustomerDocumentRow copyWith({
    String? id,
    String? customerId,
    String? documentType,
    String? fileUrl,
    String? createdBy,
    DateTime? createdAt,
    Value<String?> updatedBy = const Value.absent(),
    Value<DateTime?> updatedAt = const Value.absent(),
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<String?> tenantId = const Value.absent(),
  }) => CustomerDocumentRow(
    id: id ?? this.id,
    customerId: customerId ?? this.customerId,
    documentType: documentType ?? this.documentType,
    fileUrl: fileUrl ?? this.fileUrl,
    createdBy: createdBy ?? this.createdBy,
    createdAt: createdAt ?? this.createdAt,
    updatedBy: updatedBy.present ? updatedBy.value : this.updatedBy,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    tenantId: tenantId.present ? tenantId.value : this.tenantId,
  );
  CustomerDocumentRow copyWithCompanion(CustomerDocumentsCompanion data) {
    return CustomerDocumentRow(
      id: data.id.present ? data.id.value : this.id,
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
      documentType: data.documentType.present
          ? data.documentType.value
          : this.documentType,
      fileUrl: data.fileUrl.present ? data.fileUrl.value : this.fileUrl,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomerDocumentRow(')
          ..write('id: $id, ')
          ..write('customerId: $customerId, ')
          ..write('documentType: $documentType, ')
          ..write('fileUrl: $fileUrl, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('tenantId: $tenantId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    customerId,
    documentType,
    fileUrl,
    createdBy,
    createdAt,
    updatedBy,
    updatedAt,
    deletedAt,
    tenantId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomerDocumentRow &&
          other.id == this.id &&
          other.customerId == this.customerId &&
          other.documentType == this.documentType &&
          other.fileUrl == this.fileUrl &&
          other.createdBy == this.createdBy &&
          other.createdAt == this.createdAt &&
          other.updatedBy == this.updatedBy &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.tenantId == this.tenantId);
}

class CustomerDocumentsCompanion extends UpdateCompanion<CustomerDocumentRow> {
  final Value<String> id;
  final Value<String> customerId;
  final Value<String> documentType;
  final Value<String> fileUrl;
  final Value<String> createdBy;
  final Value<DateTime> createdAt;
  final Value<String?> updatedBy;
  final Value<DateTime?> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String?> tenantId;
  final Value<int> rowid;
  const CustomerDocumentsCompanion({
    this.id = const Value.absent(),
    this.customerId = const Value.absent(),
    this.documentType = const Value.absent(),
    this.fileUrl = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CustomerDocumentsCompanion.insert({
    required String id,
    required String customerId,
    required String documentType,
    required String fileUrl,
    this.createdBy = const Value.absent(),
    required DateTime createdAt,
    this.updatedBy = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       customerId = Value(customerId),
       documentType = Value(documentType),
       fileUrl = Value(fileUrl),
       createdAt = Value(createdAt);
  static Insertable<CustomerDocumentRow> custom({
    Expression<String>? id,
    Expression<String>? customerId,
    Expression<String>? documentType,
    Expression<String>? fileUrl,
    Expression<String>? createdBy,
    Expression<DateTime>? createdAt,
    Expression<String>? updatedBy,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? tenantId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (customerId != null) 'customer_id': customerId,
      if (documentType != null) 'document_type': documentType,
      if (fileUrl != null) 'file_url': fileUrl,
      if (createdBy != null) 'created_by': createdBy,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedBy != null) 'updated_by': updatedBy,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (tenantId != null) 'tenant_id': tenantId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CustomerDocumentsCompanion copyWith({
    Value<String>? id,
    Value<String>? customerId,
    Value<String>? documentType,
    Value<String>? fileUrl,
    Value<String>? createdBy,
    Value<DateTime>? createdAt,
    Value<String?>? updatedBy,
    Value<DateTime?>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String?>? tenantId,
    Value<int>? rowid,
  }) {
    return CustomerDocumentsCompanion(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      documentType: documentType ?? this.documentType,
      fileUrl: fileUrl ?? this.fileUrl,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedBy: updatedBy ?? this.updatedBy,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      tenantId: tenantId ?? this.tenantId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<String>(customerId.value);
    }
    if (documentType.present) {
      map['document_type'] = Variable<String>(documentType.value);
    }
    if (fileUrl.present) {
      map['file_url'] = Variable<String>(fileUrl.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedBy.present) {
      map['updated_by'] = Variable<String>(updatedBy.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (tenantId.present) {
      map['tenant_id'] = Variable<String>(tenantId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomerDocumentsCompanion(')
          ..write('id: $id, ')
          ..write('customerId: $customerId, ')
          ..write('documentType: $documentType, ')
          ..write('fileUrl: $fileUrl, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('tenantId: $tenantId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CustomerNotesTable extends CustomerNotes
    with TableInfo<$CustomerNotesTable, CustomerNoteRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomerNotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _customerIdMeta = const VerificationMeta(
    'customerId',
  );
  @override
  late final GeneratedColumn<String> customerId = GeneratedColumn<String>(
    'customer_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES customers (id)',
    ),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('system'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedByMeta = const VerificationMeta(
    'updatedBy',
  );
  @override
  late final GeneratedColumn<String> updatedBy = GeneratedColumn<String>(
    'updated_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tenantIdMeta = const VerificationMeta(
    'tenantId',
  );
  @override
  late final GeneratedColumn<String> tenantId = GeneratedColumn<String>(
    'tenant_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    customerId,
    notes,
    createdBy,
    createdAt,
    updatedBy,
    updatedAt,
    deletedAt,
    tenantId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'customer_notes';
  @override
  VerificationContext validateIntegrity(
    Insertable<CustomerNoteRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('customer_id')) {
      context.handle(
        _customerIdMeta,
        customerId.isAcceptableOrUnknown(data['customer_id']!, _customerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_customerIdMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    } else if (isInserting) {
      context.missing(_notesMeta);
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_by')) {
      context.handle(
        _updatedByMeta,
        updatedBy.isAcceptableOrUnknown(data['updated_by']!, _updatedByMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('tenant_id')) {
      context.handle(
        _tenantIdMeta,
        tenantId.isAcceptableOrUnknown(data['tenant_id']!, _tenantIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CustomerNoteRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomerNoteRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_id'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_by'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      tenantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tenant_id'],
      ),
    );
  }

  @override
  $CustomerNotesTable createAlias(String alias) {
    return $CustomerNotesTable(attachedDatabase, alias);
  }
}

class CustomerNoteRow extends DataClass implements Insertable<CustomerNoteRow> {
  final String id;
  final String customerId;
  final String notes;
  final String createdBy;
  final DateTime createdAt;
  final String? updatedBy;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final String? tenantId;
  const CustomerNoteRow({
    required this.id,
    required this.customerId,
    required this.notes,
    required this.createdBy,
    required this.createdAt,
    this.updatedBy,
    this.updatedAt,
    this.deletedAt,
    this.tenantId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['customer_id'] = Variable<String>(customerId);
    map['notes'] = Variable<String>(notes);
    map['created_by'] = Variable<String>(createdBy);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || updatedBy != null) {
      map['updated_by'] = Variable<String>(updatedBy);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || tenantId != null) {
      map['tenant_id'] = Variable<String>(tenantId);
    }
    return map;
  }

  CustomerNotesCompanion toCompanion(bool nullToAbsent) {
    return CustomerNotesCompanion(
      id: Value(id),
      customerId: Value(customerId),
      notes: Value(notes),
      createdBy: Value(createdBy),
      createdAt: Value(createdAt),
      updatedBy: updatedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedBy),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      tenantId: tenantId == null && nullToAbsent
          ? const Value.absent()
          : Value(tenantId),
    );
  }

  factory CustomerNoteRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomerNoteRow(
      id: serializer.fromJson<String>(json['id']),
      customerId: serializer.fromJson<String>(json['customerId']),
      notes: serializer.fromJson<String>(json['notes']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedBy: serializer.fromJson<String?>(json['updatedBy']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      tenantId: serializer.fromJson<String?>(json['tenantId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'customerId': serializer.toJson<String>(customerId),
      'notes': serializer.toJson<String>(notes),
      'createdBy': serializer.toJson<String>(createdBy),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedBy': serializer.toJson<String?>(updatedBy),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'tenantId': serializer.toJson<String?>(tenantId),
    };
  }

  CustomerNoteRow copyWith({
    String? id,
    String? customerId,
    String? notes,
    String? createdBy,
    DateTime? createdAt,
    Value<String?> updatedBy = const Value.absent(),
    Value<DateTime?> updatedAt = const Value.absent(),
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<String?> tenantId = const Value.absent(),
  }) => CustomerNoteRow(
    id: id ?? this.id,
    customerId: customerId ?? this.customerId,
    notes: notes ?? this.notes,
    createdBy: createdBy ?? this.createdBy,
    createdAt: createdAt ?? this.createdAt,
    updatedBy: updatedBy.present ? updatedBy.value : this.updatedBy,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    tenantId: tenantId.present ? tenantId.value : this.tenantId,
  );
  CustomerNoteRow copyWithCompanion(CustomerNotesCompanion data) {
    return CustomerNoteRow(
      id: data.id.present ? data.id.value : this.id,
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomerNoteRow(')
          ..write('id: $id, ')
          ..write('customerId: $customerId, ')
          ..write('notes: $notes, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('tenantId: $tenantId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    customerId,
    notes,
    createdBy,
    createdAt,
    updatedBy,
    updatedAt,
    deletedAt,
    tenantId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomerNoteRow &&
          other.id == this.id &&
          other.customerId == this.customerId &&
          other.notes == this.notes &&
          other.createdBy == this.createdBy &&
          other.createdAt == this.createdAt &&
          other.updatedBy == this.updatedBy &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.tenantId == this.tenantId);
}

class CustomerNotesCompanion extends UpdateCompanion<CustomerNoteRow> {
  final Value<String> id;
  final Value<String> customerId;
  final Value<String> notes;
  final Value<String> createdBy;
  final Value<DateTime> createdAt;
  final Value<String?> updatedBy;
  final Value<DateTime?> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String?> tenantId;
  final Value<int> rowid;
  const CustomerNotesCompanion({
    this.id = const Value.absent(),
    this.customerId = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CustomerNotesCompanion.insert({
    required String id,
    required String customerId,
    required String notes,
    this.createdBy = const Value.absent(),
    required DateTime createdAt,
    this.updatedBy = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       customerId = Value(customerId),
       notes = Value(notes),
       createdAt = Value(createdAt);
  static Insertable<CustomerNoteRow> custom({
    Expression<String>? id,
    Expression<String>? customerId,
    Expression<String>? notes,
    Expression<String>? createdBy,
    Expression<DateTime>? createdAt,
    Expression<String>? updatedBy,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? tenantId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (customerId != null) 'customer_id': customerId,
      if (notes != null) 'notes': notes,
      if (createdBy != null) 'created_by': createdBy,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedBy != null) 'updated_by': updatedBy,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (tenantId != null) 'tenant_id': tenantId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CustomerNotesCompanion copyWith({
    Value<String>? id,
    Value<String>? customerId,
    Value<String>? notes,
    Value<String>? createdBy,
    Value<DateTime>? createdAt,
    Value<String?>? updatedBy,
    Value<DateTime?>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String?>? tenantId,
    Value<int>? rowid,
  }) {
    return CustomerNotesCompanion(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      notes: notes ?? this.notes,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedBy: updatedBy ?? this.updatedBy,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      tenantId: tenantId ?? this.tenantId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<String>(customerId.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedBy.present) {
      map['updated_by'] = Variable<String>(updatedBy.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (tenantId.present) {
      map['tenant_id'] = Variable<String>(tenantId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomerNotesCompanion(')
          ..write('id: $id, ')
          ..write('customerId: $customerId, ')
          ..write('notes: $notes, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('tenantId: $tenantId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $CustomersTable customers = $CustomersTable(this);
  late final $CustomerSitesTable customerSites = $CustomerSitesTable(this);
  late final $CustomerContactsTable customerContacts = $CustomerContactsTable(
    this,
  );
  late final $CustomerCreditLimitsTable customerCreditLimits =
      $CustomerCreditLimitsTable(this);
  late final $CustomerDocumentsTable customerDocuments =
      $CustomerDocumentsTable(this);
  late final $CustomerNotesTable customerNotes = $CustomerNotesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    appSettings,
    customers,
    customerSites,
    customerContacts,
    customerCreditLimits,
    customerDocuments,
    customerNotes,
  ];
}

typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String key,
      required String value,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSettingRow,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSettingRow,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSettingRow>,
          ),
          AppSettingRow,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSettingRow,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSettingRow,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSettingRow>,
      ),
      AppSettingRow,
      PrefetchHooks Function()
    >;
typedef $$CustomersTableCreateCompanionBuilder =
    CustomersCompanion Function({
      required String id,
      required String customerCode,
      required String name,
      Value<String?> displayName,
      Value<String?> tradeName,
      Value<String?> legalBusinessName,
      required String customerType,
      Value<bool> isActive,
      Value<String?> gstin,
      Value<String?> pan,
      Value<String?> state,
      Value<String?> placeOfSupply,
      Value<String?> gstRegistrationType,
      Value<String?> tan,
      Value<String?> billingAddressLine1,
      Value<String?> billingAddressLine2,
      Value<String?> billingArea,
      Value<String?> billingCity,
      Value<String?> billingState,
      Value<String?> billingPincode,
      Value<String?> billingCountry,
      Value<String?> paymentTerms,
      Value<double> creditLimit,
      Value<int> creditDays,
      Value<double> securityDeposit,
      Value<String?> fuelType,
      Value<double> defaultGstRate,
      Value<double?> defaultPrice,
      Value<String?> poNumber,
      Value<DateTime?> poDate,
      Value<DateTime?> poValidTill,
      Value<double?> poValue,
      Value<double?> poRemainingBalance,
      Value<String?> invoicePrefix,
      Value<bool> emailInvoice,
      Value<bool> whatsappInvoice,
      Value<bool> requirePo,
      Value<bool> requireDc,
      Value<bool> requireSignature,
      Value<bool> gstApplicable,
      Value<bool> eInvoiceRequired,
      Value<bool> eWayBillRequired,
      Value<double> openingBalance,
      Value<double> currentBalance,
      Value<DateTime?> lastPaymentDate,
      Value<DateTime?> lastInvoiceDate,
      Value<String?> notes,
      Value<String> createdBy,
      required DateTime createdAt,
      Value<String> updatedBy,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> version,
      Value<String?> tenantId,
      Value<int> rowid,
    });
typedef $$CustomersTableUpdateCompanionBuilder =
    CustomersCompanion Function({
      Value<String> id,
      Value<String> customerCode,
      Value<String> name,
      Value<String?> displayName,
      Value<String?> tradeName,
      Value<String?> legalBusinessName,
      Value<String> customerType,
      Value<bool> isActive,
      Value<String?> gstin,
      Value<String?> pan,
      Value<String?> state,
      Value<String?> placeOfSupply,
      Value<String?> gstRegistrationType,
      Value<String?> tan,
      Value<String?> billingAddressLine1,
      Value<String?> billingAddressLine2,
      Value<String?> billingArea,
      Value<String?> billingCity,
      Value<String?> billingState,
      Value<String?> billingPincode,
      Value<String?> billingCountry,
      Value<String?> paymentTerms,
      Value<double> creditLimit,
      Value<int> creditDays,
      Value<double> securityDeposit,
      Value<String?> fuelType,
      Value<double> defaultGstRate,
      Value<double?> defaultPrice,
      Value<String?> poNumber,
      Value<DateTime?> poDate,
      Value<DateTime?> poValidTill,
      Value<double?> poValue,
      Value<double?> poRemainingBalance,
      Value<String?> invoicePrefix,
      Value<bool> emailInvoice,
      Value<bool> whatsappInvoice,
      Value<bool> requirePo,
      Value<bool> requireDc,
      Value<bool> requireSignature,
      Value<bool> gstApplicable,
      Value<bool> eInvoiceRequired,
      Value<bool> eWayBillRequired,
      Value<double> openingBalance,
      Value<double> currentBalance,
      Value<DateTime?> lastPaymentDate,
      Value<DateTime?> lastInvoiceDate,
      Value<String?> notes,
      Value<String> createdBy,
      Value<DateTime> createdAt,
      Value<String> updatedBy,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> version,
      Value<String?> tenantId,
      Value<int> rowid,
    });

final class $$CustomersTableReferences
    extends BaseReferences<_$AppDatabase, $CustomersTable, CustomerRow> {
  $$CustomersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$CustomerSitesTable, List<CustomerSiteRow>>
  _customerSitesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.customerSites,
    aliasName: $_aliasNameGenerator(
      db.customers.id,
      db.customerSites.customerId,
    ),
  );

  $$CustomerSitesTableProcessedTableManager get customerSitesRefs {
    final manager = $$CustomerSitesTableTableManager(
      $_db,
      $_db.customerSites,
    ).filter((f) => f.customerId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_customerSitesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CustomerContactsTable, List<CustomerContactRow>>
  _customerContactsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.customerContacts,
    aliasName: $_aliasNameGenerator(
      db.customers.id,
      db.customerContacts.customerId,
    ),
  );

  $$CustomerContactsTableProcessedTableManager get customerContactsRefs {
    final manager = $$CustomerContactsTableTableManager(
      $_db,
      $_db.customerContacts,
    ).filter((f) => f.customerId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _customerContactsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $CustomerCreditLimitsTable,
    List<CustomerCreditLimitRow>
  >
  _customerCreditLimitsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.customerCreditLimits,
        aliasName: $_aliasNameGenerator(
          db.customers.id,
          db.customerCreditLimits.customerId,
        ),
      );

  $$CustomerCreditLimitsTableProcessedTableManager
  get customerCreditLimitsRefs {
    final manager = $$CustomerCreditLimitsTableTableManager(
      $_db,
      $_db.customerCreditLimits,
    ).filter((f) => f.customerId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _customerCreditLimitsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CustomerDocumentsTable, List<CustomerDocumentRow>>
  _customerDocumentsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.customerDocuments,
        aliasName: $_aliasNameGenerator(
          db.customers.id,
          db.customerDocuments.customerId,
        ),
      );

  $$CustomerDocumentsTableProcessedTableManager get customerDocumentsRefs {
    final manager = $$CustomerDocumentsTableTableManager(
      $_db,
      $_db.customerDocuments,
    ).filter((f) => f.customerId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _customerDocumentsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CustomerNotesTable, List<CustomerNoteRow>>
  _customerNotesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.customerNotes,
    aliasName: $_aliasNameGenerator(
      db.customers.id,
      db.customerNotes.customerId,
    ),
  );

  $$CustomerNotesTableProcessedTableManager get customerNotesRefs {
    final manager = $$CustomerNotesTableTableManager(
      $_db,
      $_db.customerNotes,
    ).filter((f) => f.customerId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_customerNotesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CustomersTableFilterComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customerCode => $composableBuilder(
    column: $table.customerCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tradeName => $composableBuilder(
    column: $table.tradeName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get legalBusinessName => $composableBuilder(
    column: $table.legalBusinessName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customerType => $composableBuilder(
    column: $table.customerType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gstin => $composableBuilder(
    column: $table.gstin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pan => $composableBuilder(
    column: $table.pan,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get placeOfSupply => $composableBuilder(
    column: $table.placeOfSupply,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gstRegistrationType => $composableBuilder(
    column: $table.gstRegistrationType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tan => $composableBuilder(
    column: $table.tan,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get billingAddressLine1 => $composableBuilder(
    column: $table.billingAddressLine1,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get billingAddressLine2 => $composableBuilder(
    column: $table.billingAddressLine2,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get billingArea => $composableBuilder(
    column: $table.billingArea,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get billingCity => $composableBuilder(
    column: $table.billingCity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get billingState => $composableBuilder(
    column: $table.billingState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get billingPincode => $composableBuilder(
    column: $table.billingPincode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get billingCountry => $composableBuilder(
    column: $table.billingCountry,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentTerms => $composableBuilder(
    column: $table.paymentTerms,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get creditLimit => $composableBuilder(
    column: $table.creditLimit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get creditDays => $composableBuilder(
    column: $table.creditDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get securityDeposit => $composableBuilder(
    column: $table.securityDeposit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fuelType => $composableBuilder(
    column: $table.fuelType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get defaultGstRate => $composableBuilder(
    column: $table.defaultGstRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get defaultPrice => $composableBuilder(
    column: $table.defaultPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get poNumber => $composableBuilder(
    column: $table.poNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get poDate => $composableBuilder(
    column: $table.poDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get poValidTill => $composableBuilder(
    column: $table.poValidTill,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get poValue => $composableBuilder(
    column: $table.poValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get poRemainingBalance => $composableBuilder(
    column: $table.poRemainingBalance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get invoicePrefix => $composableBuilder(
    column: $table.invoicePrefix,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get emailInvoice => $composableBuilder(
    column: $table.emailInvoice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get whatsappInvoice => $composableBuilder(
    column: $table.whatsappInvoice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get requirePo => $composableBuilder(
    column: $table.requirePo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get requireDc => $composableBuilder(
    column: $table.requireDc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get requireSignature => $composableBuilder(
    column: $table.requireSignature,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get gstApplicable => $composableBuilder(
    column: $table.gstApplicable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get eInvoiceRequired => $composableBuilder(
    column: $table.eInvoiceRequired,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get eWayBillRequired => $composableBuilder(
    column: $table.eWayBillRequired,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get openingBalance => $composableBuilder(
    column: $table.openingBalance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get currentBalance => $composableBuilder(
    column: $table.currentBalance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastPaymentDate => $composableBuilder(
    column: $table.lastPaymentDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastInvoiceDate => $composableBuilder(
    column: $table.lastInvoiceDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> customerSitesRefs(
    Expression<bool> Function($$CustomerSitesTableFilterComposer f) f,
  ) {
    final $$CustomerSitesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.customerSites,
      getReferencedColumn: (t) => t.customerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomerSitesTableFilterComposer(
            $db: $db,
            $table: $db.customerSites,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> customerContactsRefs(
    Expression<bool> Function($$CustomerContactsTableFilterComposer f) f,
  ) {
    final $$CustomerContactsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.customerContacts,
      getReferencedColumn: (t) => t.customerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomerContactsTableFilterComposer(
            $db: $db,
            $table: $db.customerContacts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> customerCreditLimitsRefs(
    Expression<bool> Function($$CustomerCreditLimitsTableFilterComposer f) f,
  ) {
    final $$CustomerCreditLimitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.customerCreditLimits,
      getReferencedColumn: (t) => t.customerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomerCreditLimitsTableFilterComposer(
            $db: $db,
            $table: $db.customerCreditLimits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> customerDocumentsRefs(
    Expression<bool> Function($$CustomerDocumentsTableFilterComposer f) f,
  ) {
    final $$CustomerDocumentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.customerDocuments,
      getReferencedColumn: (t) => t.customerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomerDocumentsTableFilterComposer(
            $db: $db,
            $table: $db.customerDocuments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> customerNotesRefs(
    Expression<bool> Function($$CustomerNotesTableFilterComposer f) f,
  ) {
    final $$CustomerNotesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.customerNotes,
      getReferencedColumn: (t) => t.customerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomerNotesTableFilterComposer(
            $db: $db,
            $table: $db.customerNotes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CustomersTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customerCode => $composableBuilder(
    column: $table.customerCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tradeName => $composableBuilder(
    column: $table.tradeName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get legalBusinessName => $composableBuilder(
    column: $table.legalBusinessName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customerType => $composableBuilder(
    column: $table.customerType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gstin => $composableBuilder(
    column: $table.gstin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pan => $composableBuilder(
    column: $table.pan,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get placeOfSupply => $composableBuilder(
    column: $table.placeOfSupply,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gstRegistrationType => $composableBuilder(
    column: $table.gstRegistrationType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tan => $composableBuilder(
    column: $table.tan,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get billingAddressLine1 => $composableBuilder(
    column: $table.billingAddressLine1,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get billingAddressLine2 => $composableBuilder(
    column: $table.billingAddressLine2,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get billingArea => $composableBuilder(
    column: $table.billingArea,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get billingCity => $composableBuilder(
    column: $table.billingCity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get billingState => $composableBuilder(
    column: $table.billingState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get billingPincode => $composableBuilder(
    column: $table.billingPincode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get billingCountry => $composableBuilder(
    column: $table.billingCountry,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentTerms => $composableBuilder(
    column: $table.paymentTerms,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get creditLimit => $composableBuilder(
    column: $table.creditLimit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get creditDays => $composableBuilder(
    column: $table.creditDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get securityDeposit => $composableBuilder(
    column: $table.securityDeposit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fuelType => $composableBuilder(
    column: $table.fuelType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get defaultGstRate => $composableBuilder(
    column: $table.defaultGstRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get defaultPrice => $composableBuilder(
    column: $table.defaultPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get poNumber => $composableBuilder(
    column: $table.poNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get poDate => $composableBuilder(
    column: $table.poDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get poValidTill => $composableBuilder(
    column: $table.poValidTill,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get poValue => $composableBuilder(
    column: $table.poValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get poRemainingBalance => $composableBuilder(
    column: $table.poRemainingBalance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get invoicePrefix => $composableBuilder(
    column: $table.invoicePrefix,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get emailInvoice => $composableBuilder(
    column: $table.emailInvoice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get whatsappInvoice => $composableBuilder(
    column: $table.whatsappInvoice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get requirePo => $composableBuilder(
    column: $table.requirePo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get requireDc => $composableBuilder(
    column: $table.requireDc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get requireSignature => $composableBuilder(
    column: $table.requireSignature,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get gstApplicable => $composableBuilder(
    column: $table.gstApplicable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get eInvoiceRequired => $composableBuilder(
    column: $table.eInvoiceRequired,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get eWayBillRequired => $composableBuilder(
    column: $table.eWayBillRequired,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get openingBalance => $composableBuilder(
    column: $table.openingBalance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get currentBalance => $composableBuilder(
    column: $table.currentBalance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastPaymentDate => $composableBuilder(
    column: $table.lastPaymentDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastInvoiceDate => $composableBuilder(
    column: $table.lastInvoiceDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CustomersTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get customerCode => $composableBuilder(
    column: $table.customerCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tradeName =>
      $composableBuilder(column: $table.tradeName, builder: (column) => column);

  GeneratedColumn<String> get legalBusinessName => $composableBuilder(
    column: $table.legalBusinessName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get customerType => $composableBuilder(
    column: $table.customerType,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<String> get gstin =>
      $composableBuilder(column: $table.gstin, builder: (column) => column);

  GeneratedColumn<String> get pan =>
      $composableBuilder(column: $table.pan, builder: (column) => column);

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<String> get placeOfSupply => $composableBuilder(
    column: $table.placeOfSupply,
    builder: (column) => column,
  );

  GeneratedColumn<String> get gstRegistrationType => $composableBuilder(
    column: $table.gstRegistrationType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tan =>
      $composableBuilder(column: $table.tan, builder: (column) => column);

  GeneratedColumn<String> get billingAddressLine1 => $composableBuilder(
    column: $table.billingAddressLine1,
    builder: (column) => column,
  );

  GeneratedColumn<String> get billingAddressLine2 => $composableBuilder(
    column: $table.billingAddressLine2,
    builder: (column) => column,
  );

  GeneratedColumn<String> get billingArea => $composableBuilder(
    column: $table.billingArea,
    builder: (column) => column,
  );

  GeneratedColumn<String> get billingCity => $composableBuilder(
    column: $table.billingCity,
    builder: (column) => column,
  );

  GeneratedColumn<String> get billingState => $composableBuilder(
    column: $table.billingState,
    builder: (column) => column,
  );

  GeneratedColumn<String> get billingPincode => $composableBuilder(
    column: $table.billingPincode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get billingCountry => $composableBuilder(
    column: $table.billingCountry,
    builder: (column) => column,
  );

  GeneratedColumn<String> get paymentTerms => $composableBuilder(
    column: $table.paymentTerms,
    builder: (column) => column,
  );

  GeneratedColumn<double> get creditLimit => $composableBuilder(
    column: $table.creditLimit,
    builder: (column) => column,
  );

  GeneratedColumn<int> get creditDays => $composableBuilder(
    column: $table.creditDays,
    builder: (column) => column,
  );

  GeneratedColumn<double> get securityDeposit => $composableBuilder(
    column: $table.securityDeposit,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fuelType =>
      $composableBuilder(column: $table.fuelType, builder: (column) => column);

  GeneratedColumn<double> get defaultGstRate => $composableBuilder(
    column: $table.defaultGstRate,
    builder: (column) => column,
  );

  GeneratedColumn<double> get defaultPrice => $composableBuilder(
    column: $table.defaultPrice,
    builder: (column) => column,
  );

  GeneratedColumn<String> get poNumber =>
      $composableBuilder(column: $table.poNumber, builder: (column) => column);

  GeneratedColumn<DateTime> get poDate =>
      $composableBuilder(column: $table.poDate, builder: (column) => column);

  GeneratedColumn<DateTime> get poValidTill => $composableBuilder(
    column: $table.poValidTill,
    builder: (column) => column,
  );

  GeneratedColumn<double> get poValue =>
      $composableBuilder(column: $table.poValue, builder: (column) => column);

  GeneratedColumn<double> get poRemainingBalance => $composableBuilder(
    column: $table.poRemainingBalance,
    builder: (column) => column,
  );

  GeneratedColumn<String> get invoicePrefix => $composableBuilder(
    column: $table.invoicePrefix,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get emailInvoice => $composableBuilder(
    column: $table.emailInvoice,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get whatsappInvoice => $composableBuilder(
    column: $table.whatsappInvoice,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get requirePo =>
      $composableBuilder(column: $table.requirePo, builder: (column) => column);

  GeneratedColumn<bool> get requireDc =>
      $composableBuilder(column: $table.requireDc, builder: (column) => column);

  GeneratedColumn<bool> get requireSignature => $composableBuilder(
    column: $table.requireSignature,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get gstApplicable => $composableBuilder(
    column: $table.gstApplicable,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get eInvoiceRequired => $composableBuilder(
    column: $table.eInvoiceRequired,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get eWayBillRequired => $composableBuilder(
    column: $table.eWayBillRequired,
    builder: (column) => column,
  );

  GeneratedColumn<double> get openingBalance => $composableBuilder(
    column: $table.openingBalance,
    builder: (column) => column,
  );

  GeneratedColumn<double> get currentBalance => $composableBuilder(
    column: $table.currentBalance,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastPaymentDate => $composableBuilder(
    column: $table.lastPaymentDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastInvoiceDate => $composableBuilder(
    column: $table.lastInvoiceDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedBy =>
      $composableBuilder(column: $table.updatedBy, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get tenantId =>
      $composableBuilder(column: $table.tenantId, builder: (column) => column);

  Expression<T> customerSitesRefs<T extends Object>(
    Expression<T> Function($$CustomerSitesTableAnnotationComposer a) f,
  ) {
    final $$CustomerSitesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.customerSites,
      getReferencedColumn: (t) => t.customerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomerSitesTableAnnotationComposer(
            $db: $db,
            $table: $db.customerSites,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> customerContactsRefs<T extends Object>(
    Expression<T> Function($$CustomerContactsTableAnnotationComposer a) f,
  ) {
    final $$CustomerContactsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.customerContacts,
      getReferencedColumn: (t) => t.customerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomerContactsTableAnnotationComposer(
            $db: $db,
            $table: $db.customerContacts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> customerCreditLimitsRefs<T extends Object>(
    Expression<T> Function($$CustomerCreditLimitsTableAnnotationComposer a) f,
  ) {
    final $$CustomerCreditLimitsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.customerCreditLimits,
          getReferencedColumn: (t) => t.customerId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CustomerCreditLimitsTableAnnotationComposer(
                $db: $db,
                $table: $db.customerCreditLimits,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> customerDocumentsRefs<T extends Object>(
    Expression<T> Function($$CustomerDocumentsTableAnnotationComposer a) f,
  ) {
    final $$CustomerDocumentsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.customerDocuments,
          getReferencedColumn: (t) => t.customerId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CustomerDocumentsTableAnnotationComposer(
                $db: $db,
                $table: $db.customerDocuments,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> customerNotesRefs<T extends Object>(
    Expression<T> Function($$CustomerNotesTableAnnotationComposer a) f,
  ) {
    final $$CustomerNotesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.customerNotes,
      getReferencedColumn: (t) => t.customerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomerNotesTableAnnotationComposer(
            $db: $db,
            $table: $db.customerNotes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CustomersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CustomersTable,
          CustomerRow,
          $$CustomersTableFilterComposer,
          $$CustomersTableOrderingComposer,
          $$CustomersTableAnnotationComposer,
          $$CustomersTableCreateCompanionBuilder,
          $$CustomersTableUpdateCompanionBuilder,
          (CustomerRow, $$CustomersTableReferences),
          CustomerRow,
          PrefetchHooks Function({
            bool customerSitesRefs,
            bool customerContactsRefs,
            bool customerCreditLimitsRefs,
            bool customerDocumentsRefs,
            bool customerNotesRefs,
          })
        > {
  $$CustomersTableTableManager(_$AppDatabase db, $CustomersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> customerCode = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> displayName = const Value.absent(),
                Value<String?> tradeName = const Value.absent(),
                Value<String?> legalBusinessName = const Value.absent(),
                Value<String> customerType = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<String?> gstin = const Value.absent(),
                Value<String?> pan = const Value.absent(),
                Value<String?> state = const Value.absent(),
                Value<String?> placeOfSupply = const Value.absent(),
                Value<String?> gstRegistrationType = const Value.absent(),
                Value<String?> tan = const Value.absent(),
                Value<String?> billingAddressLine1 = const Value.absent(),
                Value<String?> billingAddressLine2 = const Value.absent(),
                Value<String?> billingArea = const Value.absent(),
                Value<String?> billingCity = const Value.absent(),
                Value<String?> billingState = const Value.absent(),
                Value<String?> billingPincode = const Value.absent(),
                Value<String?> billingCountry = const Value.absent(),
                Value<String?> paymentTerms = const Value.absent(),
                Value<double> creditLimit = const Value.absent(),
                Value<int> creditDays = const Value.absent(),
                Value<double> securityDeposit = const Value.absent(),
                Value<String?> fuelType = const Value.absent(),
                Value<double> defaultGstRate = const Value.absent(),
                Value<double?> defaultPrice = const Value.absent(),
                Value<String?> poNumber = const Value.absent(),
                Value<DateTime?> poDate = const Value.absent(),
                Value<DateTime?> poValidTill = const Value.absent(),
                Value<double?> poValue = const Value.absent(),
                Value<double?> poRemainingBalance = const Value.absent(),
                Value<String?> invoicePrefix = const Value.absent(),
                Value<bool> emailInvoice = const Value.absent(),
                Value<bool> whatsappInvoice = const Value.absent(),
                Value<bool> requirePo = const Value.absent(),
                Value<bool> requireDc = const Value.absent(),
                Value<bool> requireSignature = const Value.absent(),
                Value<bool> gstApplicable = const Value.absent(),
                Value<bool> eInvoiceRequired = const Value.absent(),
                Value<bool> eWayBillRequired = const Value.absent(),
                Value<double> openingBalance = const Value.absent(),
                Value<double> currentBalance = const Value.absent(),
                Value<DateTime?> lastPaymentDate = const Value.absent(),
                Value<DateTime?> lastInvoiceDate = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String> createdBy = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> updatedBy = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String?> tenantId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomersCompanion(
                id: id,
                customerCode: customerCode,
                name: name,
                displayName: displayName,
                tradeName: tradeName,
                legalBusinessName: legalBusinessName,
                customerType: customerType,
                isActive: isActive,
                gstin: gstin,
                pan: pan,
                state: state,
                placeOfSupply: placeOfSupply,
                gstRegistrationType: gstRegistrationType,
                tan: tan,
                billingAddressLine1: billingAddressLine1,
                billingAddressLine2: billingAddressLine2,
                billingArea: billingArea,
                billingCity: billingCity,
                billingState: billingState,
                billingPincode: billingPincode,
                billingCountry: billingCountry,
                paymentTerms: paymentTerms,
                creditLimit: creditLimit,
                creditDays: creditDays,
                securityDeposit: securityDeposit,
                fuelType: fuelType,
                defaultGstRate: defaultGstRate,
                defaultPrice: defaultPrice,
                poNumber: poNumber,
                poDate: poDate,
                poValidTill: poValidTill,
                poValue: poValue,
                poRemainingBalance: poRemainingBalance,
                invoicePrefix: invoicePrefix,
                emailInvoice: emailInvoice,
                whatsappInvoice: whatsappInvoice,
                requirePo: requirePo,
                requireDc: requireDc,
                requireSignature: requireSignature,
                gstApplicable: gstApplicable,
                eInvoiceRequired: eInvoiceRequired,
                eWayBillRequired: eWayBillRequired,
                openingBalance: openingBalance,
                currentBalance: currentBalance,
                lastPaymentDate: lastPaymentDate,
                lastInvoiceDate: lastInvoiceDate,
                notes: notes,
                createdBy: createdBy,
                createdAt: createdAt,
                updatedBy: updatedBy,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                version: version,
                tenantId: tenantId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String customerCode,
                required String name,
                Value<String?> displayName = const Value.absent(),
                Value<String?> tradeName = const Value.absent(),
                Value<String?> legalBusinessName = const Value.absent(),
                required String customerType,
                Value<bool> isActive = const Value.absent(),
                Value<String?> gstin = const Value.absent(),
                Value<String?> pan = const Value.absent(),
                Value<String?> state = const Value.absent(),
                Value<String?> placeOfSupply = const Value.absent(),
                Value<String?> gstRegistrationType = const Value.absent(),
                Value<String?> tan = const Value.absent(),
                Value<String?> billingAddressLine1 = const Value.absent(),
                Value<String?> billingAddressLine2 = const Value.absent(),
                Value<String?> billingArea = const Value.absent(),
                Value<String?> billingCity = const Value.absent(),
                Value<String?> billingState = const Value.absent(),
                Value<String?> billingPincode = const Value.absent(),
                Value<String?> billingCountry = const Value.absent(),
                Value<String?> paymentTerms = const Value.absent(),
                Value<double> creditLimit = const Value.absent(),
                Value<int> creditDays = const Value.absent(),
                Value<double> securityDeposit = const Value.absent(),
                Value<String?> fuelType = const Value.absent(),
                Value<double> defaultGstRate = const Value.absent(),
                Value<double?> defaultPrice = const Value.absent(),
                Value<String?> poNumber = const Value.absent(),
                Value<DateTime?> poDate = const Value.absent(),
                Value<DateTime?> poValidTill = const Value.absent(),
                Value<double?> poValue = const Value.absent(),
                Value<double?> poRemainingBalance = const Value.absent(),
                Value<String?> invoicePrefix = const Value.absent(),
                Value<bool> emailInvoice = const Value.absent(),
                Value<bool> whatsappInvoice = const Value.absent(),
                Value<bool> requirePo = const Value.absent(),
                Value<bool> requireDc = const Value.absent(),
                Value<bool> requireSignature = const Value.absent(),
                Value<bool> gstApplicable = const Value.absent(),
                Value<bool> eInvoiceRequired = const Value.absent(),
                Value<bool> eWayBillRequired = const Value.absent(),
                Value<double> openingBalance = const Value.absent(),
                Value<double> currentBalance = const Value.absent(),
                Value<DateTime?> lastPaymentDate = const Value.absent(),
                Value<DateTime?> lastInvoiceDate = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String> createdBy = const Value.absent(),
                required DateTime createdAt,
                Value<String> updatedBy = const Value.absent(),
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String?> tenantId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomersCompanion.insert(
                id: id,
                customerCode: customerCode,
                name: name,
                displayName: displayName,
                tradeName: tradeName,
                legalBusinessName: legalBusinessName,
                customerType: customerType,
                isActive: isActive,
                gstin: gstin,
                pan: pan,
                state: state,
                placeOfSupply: placeOfSupply,
                gstRegistrationType: gstRegistrationType,
                tan: tan,
                billingAddressLine1: billingAddressLine1,
                billingAddressLine2: billingAddressLine2,
                billingArea: billingArea,
                billingCity: billingCity,
                billingState: billingState,
                billingPincode: billingPincode,
                billingCountry: billingCountry,
                paymentTerms: paymentTerms,
                creditLimit: creditLimit,
                creditDays: creditDays,
                securityDeposit: securityDeposit,
                fuelType: fuelType,
                defaultGstRate: defaultGstRate,
                defaultPrice: defaultPrice,
                poNumber: poNumber,
                poDate: poDate,
                poValidTill: poValidTill,
                poValue: poValue,
                poRemainingBalance: poRemainingBalance,
                invoicePrefix: invoicePrefix,
                emailInvoice: emailInvoice,
                whatsappInvoice: whatsappInvoice,
                requirePo: requirePo,
                requireDc: requireDc,
                requireSignature: requireSignature,
                gstApplicable: gstApplicable,
                eInvoiceRequired: eInvoiceRequired,
                eWayBillRequired: eWayBillRequired,
                openingBalance: openingBalance,
                currentBalance: currentBalance,
                lastPaymentDate: lastPaymentDate,
                lastInvoiceDate: lastInvoiceDate,
                notes: notes,
                createdBy: createdBy,
                createdAt: createdAt,
                updatedBy: updatedBy,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                version: version,
                tenantId: tenantId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CustomersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                customerSitesRefs = false,
                customerContactsRefs = false,
                customerCreditLimitsRefs = false,
                customerDocumentsRefs = false,
                customerNotesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (customerSitesRefs) db.customerSites,
                    if (customerContactsRefs) db.customerContacts,
                    if (customerCreditLimitsRefs) db.customerCreditLimits,
                    if (customerDocumentsRefs) db.customerDocuments,
                    if (customerNotesRefs) db.customerNotes,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (customerSitesRefs)
                        await $_getPrefetchedData<
                          CustomerRow,
                          $CustomersTable,
                          CustomerSiteRow
                        >(
                          currentTable: table,
                          referencedTable: $$CustomersTableReferences
                              ._customerSitesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CustomersTableReferences(
                                db,
                                table,
                                p0,
                              ).customerSitesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.customerId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (customerContactsRefs)
                        await $_getPrefetchedData<
                          CustomerRow,
                          $CustomersTable,
                          CustomerContactRow
                        >(
                          currentTable: table,
                          referencedTable: $$CustomersTableReferences
                              ._customerContactsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CustomersTableReferences(
                                db,
                                table,
                                p0,
                              ).customerContactsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.customerId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (customerCreditLimitsRefs)
                        await $_getPrefetchedData<
                          CustomerRow,
                          $CustomersTable,
                          CustomerCreditLimitRow
                        >(
                          currentTable: table,
                          referencedTable: $$CustomersTableReferences
                              ._customerCreditLimitsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CustomersTableReferences(
                                db,
                                table,
                                p0,
                              ).customerCreditLimitsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.customerId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (customerDocumentsRefs)
                        await $_getPrefetchedData<
                          CustomerRow,
                          $CustomersTable,
                          CustomerDocumentRow
                        >(
                          currentTable: table,
                          referencedTable: $$CustomersTableReferences
                              ._customerDocumentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CustomersTableReferences(
                                db,
                                table,
                                p0,
                              ).customerDocumentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.customerId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (customerNotesRefs)
                        await $_getPrefetchedData<
                          CustomerRow,
                          $CustomersTable,
                          CustomerNoteRow
                        >(
                          currentTable: table,
                          referencedTable: $$CustomersTableReferences
                              ._customerNotesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CustomersTableReferences(
                                db,
                                table,
                                p0,
                              ).customerNotesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.customerId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CustomersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CustomersTable,
      CustomerRow,
      $$CustomersTableFilterComposer,
      $$CustomersTableOrderingComposer,
      $$CustomersTableAnnotationComposer,
      $$CustomersTableCreateCompanionBuilder,
      $$CustomersTableUpdateCompanionBuilder,
      (CustomerRow, $$CustomersTableReferences),
      CustomerRow,
      PrefetchHooks Function({
        bool customerSitesRefs,
        bool customerContactsRefs,
        bool customerCreditLimitsRefs,
        bool customerDocumentsRefs,
        bool customerNotesRefs,
      })
    >;
typedef $$CustomerSitesTableCreateCompanionBuilder =
    CustomerSitesCompanion Function({
      required String id,
      required String customerId,
      required String name,
      Value<String?> addressLine1,
      Value<String?> addressLine2,
      Value<String?> city,
      Value<String?> state,
      Value<String?> stateCode,
      Value<String?> pincode,
      Value<String?> country,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<String?> contactPerson,
      Value<String?> contactNumber,
      Value<bool> isDefault,
      Value<bool> isActive,
      Value<String> createdBy,
      required DateTime createdAt,
      Value<String> updatedBy,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> version,
      Value<String?> tenantId,
      Value<int> rowid,
    });
typedef $$CustomerSitesTableUpdateCompanionBuilder =
    CustomerSitesCompanion Function({
      Value<String> id,
      Value<String> customerId,
      Value<String> name,
      Value<String?> addressLine1,
      Value<String?> addressLine2,
      Value<String?> city,
      Value<String?> state,
      Value<String?> stateCode,
      Value<String?> pincode,
      Value<String?> country,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<String?> contactPerson,
      Value<String?> contactNumber,
      Value<bool> isDefault,
      Value<bool> isActive,
      Value<String> createdBy,
      Value<DateTime> createdAt,
      Value<String> updatedBy,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> version,
      Value<String?> tenantId,
      Value<int> rowid,
    });

final class $$CustomerSitesTableReferences
    extends
        BaseReferences<_$AppDatabase, $CustomerSitesTable, CustomerSiteRow> {
  $$CustomerSitesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CustomersTable _customerIdTable(_$AppDatabase db) =>
      db.customers.createAlias(
        $_aliasNameGenerator(db.customerSites.customerId, db.customers.id),
      );

  $$CustomersTableProcessedTableManager get customerId {
    final $_column = $_itemColumn<String>('customer_id')!;

    final manager = $$CustomersTableTableManager(
      $_db,
      $_db.customers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_customerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CustomerSitesTableFilterComposer
    extends Composer<_$AppDatabase, $CustomerSitesTable> {
  $$CustomerSitesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get addressLine1 => $composableBuilder(
    column: $table.addressLine1,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get addressLine2 => $composableBuilder(
    column: $table.addressLine2,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get city => $composableBuilder(
    column: $table.city,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stateCode => $composableBuilder(
    column: $table.stateCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pincode => $composableBuilder(
    column: $table.pincode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get country => $composableBuilder(
    column: $table.country,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contactPerson => $composableBuilder(
    column: $table.contactPerson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contactNumber => $composableBuilder(
    column: $table.contactNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnFilters(column),
  );

  $$CustomersTableFilterComposer get customerId {
    final $$CustomersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableFilterComposer(
            $db: $db,
            $table: $db.customers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CustomerSitesTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomerSitesTable> {
  $$CustomerSitesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get addressLine1 => $composableBuilder(
    column: $table.addressLine1,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get addressLine2 => $composableBuilder(
    column: $table.addressLine2,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get city => $composableBuilder(
    column: $table.city,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stateCode => $composableBuilder(
    column: $table.stateCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pincode => $composableBuilder(
    column: $table.pincode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get country => $composableBuilder(
    column: $table.country,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contactPerson => $composableBuilder(
    column: $table.contactPerson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contactNumber => $composableBuilder(
    column: $table.contactNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnOrderings(column),
  );

  $$CustomersTableOrderingComposer get customerId {
    final $$CustomersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableOrderingComposer(
            $db: $db,
            $table: $db.customers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CustomerSitesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomerSitesTable> {
  $$CustomerSitesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get addressLine1 => $composableBuilder(
    column: $table.addressLine1,
    builder: (column) => column,
  );

  GeneratedColumn<String> get addressLine2 => $composableBuilder(
    column: $table.addressLine2,
    builder: (column) => column,
  );

  GeneratedColumn<String> get city =>
      $composableBuilder(column: $table.city, builder: (column) => column);

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<String> get stateCode =>
      $composableBuilder(column: $table.stateCode, builder: (column) => column);

  GeneratedColumn<String> get pincode =>
      $composableBuilder(column: $table.pincode, builder: (column) => column);

  GeneratedColumn<String> get country =>
      $composableBuilder(column: $table.country, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<String> get contactPerson => $composableBuilder(
    column: $table.contactPerson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contactNumber => $composableBuilder(
    column: $table.contactNumber,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDefault =>
      $composableBuilder(column: $table.isDefault, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedBy =>
      $composableBuilder(column: $table.updatedBy, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get tenantId =>
      $composableBuilder(column: $table.tenantId, builder: (column) => column);

  $$CustomersTableAnnotationComposer get customerId {
    final $$CustomersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableAnnotationComposer(
            $db: $db,
            $table: $db.customers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CustomerSitesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CustomerSitesTable,
          CustomerSiteRow,
          $$CustomerSitesTableFilterComposer,
          $$CustomerSitesTableOrderingComposer,
          $$CustomerSitesTableAnnotationComposer,
          $$CustomerSitesTableCreateCompanionBuilder,
          $$CustomerSitesTableUpdateCompanionBuilder,
          (CustomerSiteRow, $$CustomerSitesTableReferences),
          CustomerSiteRow,
          PrefetchHooks Function({bool customerId})
        > {
  $$CustomerSitesTableTableManager(_$AppDatabase db, $CustomerSitesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomerSitesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomerSitesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomerSitesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> customerId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> addressLine1 = const Value.absent(),
                Value<String?> addressLine2 = const Value.absent(),
                Value<String?> city = const Value.absent(),
                Value<String?> state = const Value.absent(),
                Value<String?> stateCode = const Value.absent(),
                Value<String?> pincode = const Value.absent(),
                Value<String?> country = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<String?> contactPerson = const Value.absent(),
                Value<String?> contactNumber = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<String> createdBy = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> updatedBy = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String?> tenantId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomerSitesCompanion(
                id: id,
                customerId: customerId,
                name: name,
                addressLine1: addressLine1,
                addressLine2: addressLine2,
                city: city,
                state: state,
                stateCode: stateCode,
                pincode: pincode,
                country: country,
                latitude: latitude,
                longitude: longitude,
                contactPerson: contactPerson,
                contactNumber: contactNumber,
                isDefault: isDefault,
                isActive: isActive,
                createdBy: createdBy,
                createdAt: createdAt,
                updatedBy: updatedBy,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                version: version,
                tenantId: tenantId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String customerId,
                required String name,
                Value<String?> addressLine1 = const Value.absent(),
                Value<String?> addressLine2 = const Value.absent(),
                Value<String?> city = const Value.absent(),
                Value<String?> state = const Value.absent(),
                Value<String?> stateCode = const Value.absent(),
                Value<String?> pincode = const Value.absent(),
                Value<String?> country = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<String?> contactPerson = const Value.absent(),
                Value<String?> contactNumber = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<String> createdBy = const Value.absent(),
                required DateTime createdAt,
                Value<String> updatedBy = const Value.absent(),
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String?> tenantId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomerSitesCompanion.insert(
                id: id,
                customerId: customerId,
                name: name,
                addressLine1: addressLine1,
                addressLine2: addressLine2,
                city: city,
                state: state,
                stateCode: stateCode,
                pincode: pincode,
                country: country,
                latitude: latitude,
                longitude: longitude,
                contactPerson: contactPerson,
                contactNumber: contactNumber,
                isDefault: isDefault,
                isActive: isActive,
                createdBy: createdBy,
                createdAt: createdAt,
                updatedBy: updatedBy,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                version: version,
                tenantId: tenantId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CustomerSitesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({customerId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (customerId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.customerId,
                                referencedTable: $$CustomerSitesTableReferences
                                    ._customerIdTable(db),
                                referencedColumn: $$CustomerSitesTableReferences
                                    ._customerIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CustomerSitesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CustomerSitesTable,
      CustomerSiteRow,
      $$CustomerSitesTableFilterComposer,
      $$CustomerSitesTableOrderingComposer,
      $$CustomerSitesTableAnnotationComposer,
      $$CustomerSitesTableCreateCompanionBuilder,
      $$CustomerSitesTableUpdateCompanionBuilder,
      (CustomerSiteRow, $$CustomerSitesTableReferences),
      CustomerSiteRow,
      PrefetchHooks Function({bool customerId})
    >;
typedef $$CustomerContactsTableCreateCompanionBuilder =
    CustomerContactsCompanion Function({
      required String id,
      required String customerId,
      required String name,
      Value<String?> designation,
      Value<String?> phone,
      Value<String?> email,
      Value<String?> whatsapp,
      Value<bool> isPrimary,
      Value<bool> isActive,
      Value<String> createdBy,
      required DateTime createdAt,
      Value<String> updatedBy,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> version,
      Value<String?> tenantId,
      Value<int> rowid,
    });
typedef $$CustomerContactsTableUpdateCompanionBuilder =
    CustomerContactsCompanion Function({
      Value<String> id,
      Value<String> customerId,
      Value<String> name,
      Value<String?> designation,
      Value<String?> phone,
      Value<String?> email,
      Value<String?> whatsapp,
      Value<bool> isPrimary,
      Value<bool> isActive,
      Value<String> createdBy,
      Value<DateTime> createdAt,
      Value<String> updatedBy,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> version,
      Value<String?> tenantId,
      Value<int> rowid,
    });

final class $$CustomerContactsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $CustomerContactsTable,
          CustomerContactRow
        > {
  $$CustomerContactsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CustomersTable _customerIdTable(_$AppDatabase db) =>
      db.customers.createAlias(
        $_aliasNameGenerator(db.customerContacts.customerId, db.customers.id),
      );

  $$CustomersTableProcessedTableManager get customerId {
    final $_column = $_itemColumn<String>('customer_id')!;

    final manager = $$CustomersTableTableManager(
      $_db,
      $_db.customers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_customerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CustomerContactsTableFilterComposer
    extends Composer<_$AppDatabase, $CustomerContactsTable> {
  $$CustomerContactsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get designation => $composableBuilder(
    column: $table.designation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get whatsapp => $composableBuilder(
    column: $table.whatsapp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPrimary => $composableBuilder(
    column: $table.isPrimary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnFilters(column),
  );

  $$CustomersTableFilterComposer get customerId {
    final $$CustomersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableFilterComposer(
            $db: $db,
            $table: $db.customers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CustomerContactsTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomerContactsTable> {
  $$CustomerContactsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get designation => $composableBuilder(
    column: $table.designation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get whatsapp => $composableBuilder(
    column: $table.whatsapp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPrimary => $composableBuilder(
    column: $table.isPrimary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnOrderings(column),
  );

  $$CustomersTableOrderingComposer get customerId {
    final $$CustomersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableOrderingComposer(
            $db: $db,
            $table: $db.customers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CustomerContactsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomerContactsTable> {
  $$CustomerContactsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get designation => $composableBuilder(
    column: $table.designation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get whatsapp =>
      $composableBuilder(column: $table.whatsapp, builder: (column) => column);

  GeneratedColumn<bool> get isPrimary =>
      $composableBuilder(column: $table.isPrimary, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedBy =>
      $composableBuilder(column: $table.updatedBy, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get tenantId =>
      $composableBuilder(column: $table.tenantId, builder: (column) => column);

  $$CustomersTableAnnotationComposer get customerId {
    final $$CustomersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableAnnotationComposer(
            $db: $db,
            $table: $db.customers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CustomerContactsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CustomerContactsTable,
          CustomerContactRow,
          $$CustomerContactsTableFilterComposer,
          $$CustomerContactsTableOrderingComposer,
          $$CustomerContactsTableAnnotationComposer,
          $$CustomerContactsTableCreateCompanionBuilder,
          $$CustomerContactsTableUpdateCompanionBuilder,
          (CustomerContactRow, $$CustomerContactsTableReferences),
          CustomerContactRow,
          PrefetchHooks Function({bool customerId})
        > {
  $$CustomerContactsTableTableManager(
    _$AppDatabase db,
    $CustomerContactsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomerContactsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomerContactsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomerContactsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> customerId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> designation = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> whatsapp = const Value.absent(),
                Value<bool> isPrimary = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<String> createdBy = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> updatedBy = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String?> tenantId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomerContactsCompanion(
                id: id,
                customerId: customerId,
                name: name,
                designation: designation,
                phone: phone,
                email: email,
                whatsapp: whatsapp,
                isPrimary: isPrimary,
                isActive: isActive,
                createdBy: createdBy,
                createdAt: createdAt,
                updatedBy: updatedBy,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                version: version,
                tenantId: tenantId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String customerId,
                required String name,
                Value<String?> designation = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> whatsapp = const Value.absent(),
                Value<bool> isPrimary = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<String> createdBy = const Value.absent(),
                required DateTime createdAt,
                Value<String> updatedBy = const Value.absent(),
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<String?> tenantId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomerContactsCompanion.insert(
                id: id,
                customerId: customerId,
                name: name,
                designation: designation,
                phone: phone,
                email: email,
                whatsapp: whatsapp,
                isPrimary: isPrimary,
                isActive: isActive,
                createdBy: createdBy,
                createdAt: createdAt,
                updatedBy: updatedBy,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                version: version,
                tenantId: tenantId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CustomerContactsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({customerId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (customerId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.customerId,
                                referencedTable:
                                    $$CustomerContactsTableReferences
                                        ._customerIdTable(db),
                                referencedColumn:
                                    $$CustomerContactsTableReferences
                                        ._customerIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CustomerContactsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CustomerContactsTable,
      CustomerContactRow,
      $$CustomerContactsTableFilterComposer,
      $$CustomerContactsTableOrderingComposer,
      $$CustomerContactsTableAnnotationComposer,
      $$CustomerContactsTableCreateCompanionBuilder,
      $$CustomerContactsTableUpdateCompanionBuilder,
      (CustomerContactRow, $$CustomerContactsTableReferences),
      CustomerContactRow,
      PrefetchHooks Function({bool customerId})
    >;
typedef $$CustomerCreditLimitsTableCreateCompanionBuilder =
    CustomerCreditLimitsCompanion Function({
      required String id,
      required String customerId,
      required double creditLimit,
      required DateTime effectiveFrom,
      Value<String?> notes,
      required DateTime createdAt,
      Value<String?> createdBy,
      Value<int> rowid,
    });
typedef $$CustomerCreditLimitsTableUpdateCompanionBuilder =
    CustomerCreditLimitsCompanion Function({
      Value<String> id,
      Value<String> customerId,
      Value<double> creditLimit,
      Value<DateTime> effectiveFrom,
      Value<String?> notes,
      Value<DateTime> createdAt,
      Value<String?> createdBy,
      Value<int> rowid,
    });

final class $$CustomerCreditLimitsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $CustomerCreditLimitsTable,
          CustomerCreditLimitRow
        > {
  $$CustomerCreditLimitsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CustomersTable _customerIdTable(_$AppDatabase db) =>
      db.customers.createAlias(
        $_aliasNameGenerator(
          db.customerCreditLimits.customerId,
          db.customers.id,
        ),
      );

  $$CustomersTableProcessedTableManager get customerId {
    final $_column = $_itemColumn<String>('customer_id')!;

    final manager = $$CustomersTableTableManager(
      $_db,
      $_db.customers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_customerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CustomerCreditLimitsTableFilterComposer
    extends Composer<_$AppDatabase, $CustomerCreditLimitsTable> {
  $$CustomerCreditLimitsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get creditLimit => $composableBuilder(
    column: $table.creditLimit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get effectiveFrom => $composableBuilder(
    column: $table.effectiveFrom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  $$CustomersTableFilterComposer get customerId {
    final $$CustomersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableFilterComposer(
            $db: $db,
            $table: $db.customers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CustomerCreditLimitsTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomerCreditLimitsTable> {
  $$CustomerCreditLimitsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get creditLimit => $composableBuilder(
    column: $table.creditLimit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get effectiveFrom => $composableBuilder(
    column: $table.effectiveFrom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  $$CustomersTableOrderingComposer get customerId {
    final $$CustomersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableOrderingComposer(
            $db: $db,
            $table: $db.customers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CustomerCreditLimitsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomerCreditLimitsTable> {
  $$CustomerCreditLimitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get creditLimit => $composableBuilder(
    column: $table.creditLimit,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get effectiveFrom => $composableBuilder(
    column: $table.effectiveFrom,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  $$CustomersTableAnnotationComposer get customerId {
    final $$CustomersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableAnnotationComposer(
            $db: $db,
            $table: $db.customers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CustomerCreditLimitsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CustomerCreditLimitsTable,
          CustomerCreditLimitRow,
          $$CustomerCreditLimitsTableFilterComposer,
          $$CustomerCreditLimitsTableOrderingComposer,
          $$CustomerCreditLimitsTableAnnotationComposer,
          $$CustomerCreditLimitsTableCreateCompanionBuilder,
          $$CustomerCreditLimitsTableUpdateCompanionBuilder,
          (CustomerCreditLimitRow, $$CustomerCreditLimitsTableReferences),
          CustomerCreditLimitRow,
          PrefetchHooks Function({bool customerId})
        > {
  $$CustomerCreditLimitsTableTableManager(
    _$AppDatabase db,
    $CustomerCreditLimitsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomerCreditLimitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomerCreditLimitsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CustomerCreditLimitsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> customerId = const Value.absent(),
                Value<double> creditLimit = const Value.absent(),
                Value<DateTime> effectiveFrom = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomerCreditLimitsCompanion(
                id: id,
                customerId: customerId,
                creditLimit: creditLimit,
                effectiveFrom: effectiveFrom,
                notes: notes,
                createdAt: createdAt,
                createdBy: createdBy,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String customerId,
                required double creditLimit,
                required DateTime effectiveFrom,
                Value<String?> notes = const Value.absent(),
                required DateTime createdAt,
                Value<String?> createdBy = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomerCreditLimitsCompanion.insert(
                id: id,
                customerId: customerId,
                creditLimit: creditLimit,
                effectiveFrom: effectiveFrom,
                notes: notes,
                createdAt: createdAt,
                createdBy: createdBy,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CustomerCreditLimitsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({customerId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (customerId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.customerId,
                                referencedTable:
                                    $$CustomerCreditLimitsTableReferences
                                        ._customerIdTable(db),
                                referencedColumn:
                                    $$CustomerCreditLimitsTableReferences
                                        ._customerIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CustomerCreditLimitsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CustomerCreditLimitsTable,
      CustomerCreditLimitRow,
      $$CustomerCreditLimitsTableFilterComposer,
      $$CustomerCreditLimitsTableOrderingComposer,
      $$CustomerCreditLimitsTableAnnotationComposer,
      $$CustomerCreditLimitsTableCreateCompanionBuilder,
      $$CustomerCreditLimitsTableUpdateCompanionBuilder,
      (CustomerCreditLimitRow, $$CustomerCreditLimitsTableReferences),
      CustomerCreditLimitRow,
      PrefetchHooks Function({bool customerId})
    >;
typedef $$CustomerDocumentsTableCreateCompanionBuilder =
    CustomerDocumentsCompanion Function({
      required String id,
      required String customerId,
      required String documentType,
      required String fileUrl,
      Value<String> createdBy,
      required DateTime createdAt,
      Value<String?> updatedBy,
      Value<DateTime?> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String?> tenantId,
      Value<int> rowid,
    });
typedef $$CustomerDocumentsTableUpdateCompanionBuilder =
    CustomerDocumentsCompanion Function({
      Value<String> id,
      Value<String> customerId,
      Value<String> documentType,
      Value<String> fileUrl,
      Value<String> createdBy,
      Value<DateTime> createdAt,
      Value<String?> updatedBy,
      Value<DateTime?> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String?> tenantId,
      Value<int> rowid,
    });

final class $$CustomerDocumentsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $CustomerDocumentsTable,
          CustomerDocumentRow
        > {
  $$CustomerDocumentsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CustomersTable _customerIdTable(_$AppDatabase db) =>
      db.customers.createAlias(
        $_aliasNameGenerator(db.customerDocuments.customerId, db.customers.id),
      );

  $$CustomersTableProcessedTableManager get customerId {
    final $_column = $_itemColumn<String>('customer_id')!;

    final manager = $$CustomersTableTableManager(
      $_db,
      $_db.customers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_customerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CustomerDocumentsTableFilterComposer
    extends Composer<_$AppDatabase, $CustomerDocumentsTable> {
  $$CustomerDocumentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get documentType => $composableBuilder(
    column: $table.documentType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fileUrl => $composableBuilder(
    column: $table.fileUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnFilters(column),
  );

  $$CustomersTableFilterComposer get customerId {
    final $$CustomersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableFilterComposer(
            $db: $db,
            $table: $db.customers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CustomerDocumentsTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomerDocumentsTable> {
  $$CustomerDocumentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get documentType => $composableBuilder(
    column: $table.documentType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileUrl => $composableBuilder(
    column: $table.fileUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnOrderings(column),
  );

  $$CustomersTableOrderingComposer get customerId {
    final $$CustomersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableOrderingComposer(
            $db: $db,
            $table: $db.customers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CustomerDocumentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomerDocumentsTable> {
  $$CustomerDocumentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get documentType => $composableBuilder(
    column: $table.documentType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fileUrl =>
      $composableBuilder(column: $table.fileUrl, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedBy =>
      $composableBuilder(column: $table.updatedBy, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get tenantId =>
      $composableBuilder(column: $table.tenantId, builder: (column) => column);

  $$CustomersTableAnnotationComposer get customerId {
    final $$CustomersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableAnnotationComposer(
            $db: $db,
            $table: $db.customers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CustomerDocumentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CustomerDocumentsTable,
          CustomerDocumentRow,
          $$CustomerDocumentsTableFilterComposer,
          $$CustomerDocumentsTableOrderingComposer,
          $$CustomerDocumentsTableAnnotationComposer,
          $$CustomerDocumentsTableCreateCompanionBuilder,
          $$CustomerDocumentsTableUpdateCompanionBuilder,
          (CustomerDocumentRow, $$CustomerDocumentsTableReferences),
          CustomerDocumentRow,
          PrefetchHooks Function({bool customerId})
        > {
  $$CustomerDocumentsTableTableManager(
    _$AppDatabase db,
    $CustomerDocumentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomerDocumentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomerDocumentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomerDocumentsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> customerId = const Value.absent(),
                Value<String> documentType = const Value.absent(),
                Value<String> fileUrl = const Value.absent(),
                Value<String> createdBy = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String?> updatedBy = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> tenantId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomerDocumentsCompanion(
                id: id,
                customerId: customerId,
                documentType: documentType,
                fileUrl: fileUrl,
                createdBy: createdBy,
                createdAt: createdAt,
                updatedBy: updatedBy,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                tenantId: tenantId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String customerId,
                required String documentType,
                required String fileUrl,
                Value<String> createdBy = const Value.absent(),
                required DateTime createdAt,
                Value<String?> updatedBy = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> tenantId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomerDocumentsCompanion.insert(
                id: id,
                customerId: customerId,
                documentType: documentType,
                fileUrl: fileUrl,
                createdBy: createdBy,
                createdAt: createdAt,
                updatedBy: updatedBy,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                tenantId: tenantId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CustomerDocumentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({customerId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (customerId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.customerId,
                                referencedTable:
                                    $$CustomerDocumentsTableReferences
                                        ._customerIdTable(db),
                                referencedColumn:
                                    $$CustomerDocumentsTableReferences
                                        ._customerIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CustomerDocumentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CustomerDocumentsTable,
      CustomerDocumentRow,
      $$CustomerDocumentsTableFilterComposer,
      $$CustomerDocumentsTableOrderingComposer,
      $$CustomerDocumentsTableAnnotationComposer,
      $$CustomerDocumentsTableCreateCompanionBuilder,
      $$CustomerDocumentsTableUpdateCompanionBuilder,
      (CustomerDocumentRow, $$CustomerDocumentsTableReferences),
      CustomerDocumentRow,
      PrefetchHooks Function({bool customerId})
    >;
typedef $$CustomerNotesTableCreateCompanionBuilder =
    CustomerNotesCompanion Function({
      required String id,
      required String customerId,
      required String notes,
      Value<String> createdBy,
      required DateTime createdAt,
      Value<String?> updatedBy,
      Value<DateTime?> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String?> tenantId,
      Value<int> rowid,
    });
typedef $$CustomerNotesTableUpdateCompanionBuilder =
    CustomerNotesCompanion Function({
      Value<String> id,
      Value<String> customerId,
      Value<String> notes,
      Value<String> createdBy,
      Value<DateTime> createdAt,
      Value<String?> updatedBy,
      Value<DateTime?> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String?> tenantId,
      Value<int> rowid,
    });

final class $$CustomerNotesTableReferences
    extends
        BaseReferences<_$AppDatabase, $CustomerNotesTable, CustomerNoteRow> {
  $$CustomerNotesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CustomersTable _customerIdTable(_$AppDatabase db) =>
      db.customers.createAlias(
        $_aliasNameGenerator(db.customerNotes.customerId, db.customers.id),
      );

  $$CustomersTableProcessedTableManager get customerId {
    final $_column = $_itemColumn<String>('customer_id')!;

    final manager = $$CustomersTableTableManager(
      $_db,
      $_db.customers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_customerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CustomerNotesTableFilterComposer
    extends Composer<_$AppDatabase, $CustomerNotesTable> {
  $$CustomerNotesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnFilters(column),
  );

  $$CustomersTableFilterComposer get customerId {
    final $$CustomersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableFilterComposer(
            $db: $db,
            $table: $db.customers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CustomerNotesTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomerNotesTable> {
  $$CustomerNotesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnOrderings(column),
  );

  $$CustomersTableOrderingComposer get customerId {
    final $$CustomersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableOrderingComposer(
            $db: $db,
            $table: $db.customers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CustomerNotesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomerNotesTable> {
  $$CustomerNotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedBy =>
      $composableBuilder(column: $table.updatedBy, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get tenantId =>
      $composableBuilder(column: $table.tenantId, builder: (column) => column);

  $$CustomersTableAnnotationComposer get customerId {
    final $$CustomersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableAnnotationComposer(
            $db: $db,
            $table: $db.customers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CustomerNotesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CustomerNotesTable,
          CustomerNoteRow,
          $$CustomerNotesTableFilterComposer,
          $$CustomerNotesTableOrderingComposer,
          $$CustomerNotesTableAnnotationComposer,
          $$CustomerNotesTableCreateCompanionBuilder,
          $$CustomerNotesTableUpdateCompanionBuilder,
          (CustomerNoteRow, $$CustomerNotesTableReferences),
          CustomerNoteRow,
          PrefetchHooks Function({bool customerId})
        > {
  $$CustomerNotesTableTableManager(_$AppDatabase db, $CustomerNotesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomerNotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomerNotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomerNotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> customerId = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<String> createdBy = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String?> updatedBy = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> tenantId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomerNotesCompanion(
                id: id,
                customerId: customerId,
                notes: notes,
                createdBy: createdBy,
                createdAt: createdAt,
                updatedBy: updatedBy,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                tenantId: tenantId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String customerId,
                required String notes,
                Value<String> createdBy = const Value.absent(),
                required DateTime createdAt,
                Value<String?> updatedBy = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String?> tenantId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomerNotesCompanion.insert(
                id: id,
                customerId: customerId,
                notes: notes,
                createdBy: createdBy,
                createdAt: createdAt,
                updatedBy: updatedBy,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                tenantId: tenantId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CustomerNotesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({customerId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (customerId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.customerId,
                                referencedTable: $$CustomerNotesTableReferences
                                    ._customerIdTable(db),
                                referencedColumn: $$CustomerNotesTableReferences
                                    ._customerIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CustomerNotesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CustomerNotesTable,
      CustomerNoteRow,
      $$CustomerNotesTableFilterComposer,
      $$CustomerNotesTableOrderingComposer,
      $$CustomerNotesTableAnnotationComposer,
      $$CustomerNotesTableCreateCompanionBuilder,
      $$CustomerNotesTableUpdateCompanionBuilder,
      (CustomerNoteRow, $$CustomerNotesTableReferences),
      CustomerNoteRow,
      PrefetchHooks Function({bool customerId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$CustomersTableTableManager get customers =>
      $$CustomersTableTableManager(_db, _db.customers);
  $$CustomerSitesTableTableManager get customerSites =>
      $$CustomerSitesTableTableManager(_db, _db.customerSites);
  $$CustomerContactsTableTableManager get customerContacts =>
      $$CustomerContactsTableTableManager(_db, _db.customerContacts);
  $$CustomerCreditLimitsTableTableManager get customerCreditLimits =>
      $$CustomerCreditLimitsTableTableManager(_db, _db.customerCreditLimits);
  $$CustomerDocumentsTableTableManager get customerDocuments =>
      $$CustomerDocumentsTableTableManager(_db, _db.customerDocuments);
  $$CustomerNotesTableTableManager get customerNotes =>
      $$CustomerNotesTableTableManager(_db, _db.customerNotes);
}

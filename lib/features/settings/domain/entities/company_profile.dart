class CompanyProfile {
  factory CompanyProfile.empty() {
    return const CompanyProfile(
      companyName: '',
      gstin: '',
      pan: '',
      email: '',
      phone: '',
      address: '',
      bankName: '',
      bankBranch: '',
      bankAccountNo: '',
      bankIfsc: '',
    );
  }

  const CompanyProfile({
    required this.companyName,
    required this.gstin,
    this.pan,
    required this.email,
    required this.phone,
    required this.address,
    required this.bankName,
    required this.bankBranch,
    required this.bankAccountNo,
    required this.bankIfsc,
    this.logoUrl,
  });

  factory CompanyProfile.fromJson(Map<String, dynamic> json) {
    return CompanyProfile(
      companyName: json['companyName'] as String? ?? '',
      gstin: json['gstin'] as String? ?? '',
      pan: json['pan'] as String?,
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      address: json['address'] as String? ?? '',
      bankName: json['bankName'] as String? ?? '',
      bankBranch: json['bankBranch'] as String? ?? '',
      bankAccountNo: json['bankAccountNo'] as String? ?? '',
      bankIfsc: json['bankIfsc'] as String? ?? '',
      logoUrl: json['logoUrl'] as String?,
    );
  }
  final String companyName;
  final String gstin;
  final String? pan;
  final String email;
  final String phone;
  final String address;
  final String bankName;
  final String bankBranch;
  final String bankAccountNo;
  final String bankIfsc;
  final String? logoUrl;

  CompanyProfile copyWith({
    String? companyName,
    String? gstin,
    String? pan,
    String? email,
    String? phone,
    String? address,
    String? bankName,
    String? bankBranch,
    String? bankAccountNo,
    String? bankIfsc,
    String? logoUrl,
  }) {
    return CompanyProfile(
      companyName: companyName ?? this.companyName,
      gstin: gstin ?? this.gstin,
      pan: pan ?? this.pan,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      bankName: bankName ?? this.bankName,
      bankBranch: bankBranch ?? this.bankBranch,
      bankAccountNo: bankAccountNo ?? this.bankAccountNo,
      bankIfsc: bankIfsc ?? this.bankIfsc,
      logoUrl: logoUrl ?? this.logoUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'companyName': companyName,
      'gstin': gstin,
      'pan': pan,
      'email': email,
      'phone': phone,
      'address': address,
      'bankName': bankName,
      'bankBranch': bankBranch,
      'bankAccountNo': bankAccountNo,
      'bankIfsc': bankIfsc,
      'logoUrl': logoUrl,
    };
  }
}

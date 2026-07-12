/// Validator class for validating customer details in the domain layer.
class CustomerValidator {
  CustomerValidator._();

  /// Validates that the customer name is not empty.
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    return null;
  }

  /// Validates that the GSTIN format is correct (if provided).
  /// Standard Indian GSTIN is a 15-character alphanumeric code.
  static String? validateGstin(String? value) {
    if (value == null || value.trim().isEmpty) return null; // GSTIN is optional
    final cleaned = value.trim().toUpperCase();
    final regex = RegExp(
      r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$',
    );
    if (!regex.hasMatch(cleaned)) {
      return 'Invalid GSTIN format (e.g. 27AAAAA1111A1Z1)';
    }
    return null;
  }

  /// Validates that the PAN format is correct (if provided).
  /// Standard Indian PAN is a 10-character alphanumeric code.
  static String? validatePan(String? value) {
    if (value == null || value.trim().isEmpty) return null; // PAN is optional
    final cleaned = value.trim().toUpperCase();
    final regex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$');
    if (!regex.hasMatch(cleaned)) {
      return 'Invalid PAN format (e.g. ABCDE1234F)';
    }
    return null;
  }

  /// Validates that the mobile phone format is correct (if provided).
  /// Validates standard 10-digit Indian phone numbers starting with 6-9.
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) return null; // Phone is optional
    final cleaned = value.trim();
    final regex = RegExp(r'^[6-9]\d{9}$');
    if (!regex.hasMatch(cleaned)) {
      return 'Invalid 10-digit mobile number';
    }
    return null;
  }

  /// Validates that the email address is correct (if provided).
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return null; // Email is optional
    final cleaned = value.trim();
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regex.hasMatch(cleaned)) {
      return 'Invalid email format';
    }
    return null;
  }

  /// Validates credit limit value.
  static String? validateCreditLimit(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final parsed = double.tryParse(value.trim());
    if (parsed == null) {
      return 'Credit limit must be a valid number';
    }
    if (parsed < 0) {
      return 'Credit limit cannot be negative';
    }
    return null;
  }
}

/// Form-field validators used across registration / login / OTP screens.
/// Each returns null when valid, an error key (caller localizes) when not.

class Validators {
  Validators._();

  static String? required(String? value) {
    if (value == null || value.trim().isEmpty) return 'required';
    return null;
  }

  static String? name(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'required';
    if (v.length > 40) return 'tooLong';
    return null;
  }

  static String? email(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'required';
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v);
    return ok ? null : 'invalidEmail';
  }

  // Nepali mobile: 10 digits, starts with 97x or 98x (national numbering plan).
  static String? nepaliPhone(String? value) {
    final v = value?.replaceAll(RegExp(r'\s+'), '') ?? '';
    if (v.isEmpty) return 'required';
    if (!RegExp(r'^9[7-8]\d{8}$').hasMatch(v)) return 'invalidPhone';
    return null;
  }

  static String? password(String? value) {
    final v = value ?? '';
    if (v.length < 8) return 'passwordTooShort';
    final hasLetter = RegExp(r'[A-Za-z]').hasMatch(v);
    final hasDigit = RegExp(r'\d').hasMatch(v);
    if (!hasLetter || !hasDigit) return 'passwordWeak';
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if ((value ?? '') != original) return 'passwordMismatch';
    return null;
  }

  static String? otpCode(String? value) {
    final v = value?.trim() ?? '';
    if (!RegExp(r'^\d{6}$').hasMatch(v)) return 'invalidOtp';
    return null;
  }
}

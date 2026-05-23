/// Detects phone numbers and other external contact identifiers in free-text
/// fields. Used to enforce docs/plan.md §5.6: free-text inputs (job descriptions,
/// bid cover notes, bios, reviews, chat messages) must not contain phone numbers,
/// WhatsApp links, emails, or social handles with contact intent.
///
/// The client-side check is non-authoritative — Postgres triggers in the
/// backend repeat the same validation as a backstop.

class PhoneBanRegex {
  PhoneBanRegex._();

  // Bare digit sequences of 7+ digits (covers Nepali 10-digit mobile, intl with +977, etc.).
  static final RegExp _digits = RegExp(r'(\+?\d[\d\s\-.]{6,}\d)');

  // Common contact-intent links.
  static final RegExp _links = RegExp(
    r'(wa\.me/|t\.me/|viber\.me/|whatsapp\.com|telegram\.me|m\.me/)',
    caseSensitive: false,
  );

  // Bare email.
  static final RegExp _email = RegExp(
    r'[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}',
    caseSensitive: false,
  );

  /// Returns true when `text` likely contains a phone number, an email, or a
  /// contact-intent link.
  static bool isViolation(String text) {
    if (text.isEmpty) return false;
    if (_email.hasMatch(text)) return true;
    if (_links.hasMatch(text)) return true;
    if (_digits.hasMatch(text)) {
      // Count actual digits to ignore short room numbers like "Class 11".
      final digitCount = RegExp(r'\d').allMatches(text).length;
      if (digitCount >= 7) return true;
    }
    return false;
  }
}

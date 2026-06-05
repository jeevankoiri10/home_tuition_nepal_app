/// Builds the launch URIs for revealed contact actions. Pure + testable; the
/// widget layer pairs these with `url_launcher`.
class ContactLinks {
  ContactLinks._();

  /// `tel:` dialer URI. The phone is kept verbatim (E.164 incl. the leading
  /// `+`), which dialers accept.
  static Uri tel(String phone) => Uri(scheme: 'tel', path: phone.trim());

  /// `wa.me` URI. WhatsApp wants digits only — strip the `+`, spaces and any
  /// punctuation. Nepal numbers are stored E.164 (e.g. +9779812345678).
  static Uri whatsApp(String phone) {
    final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    return Uri.parse('https://wa.me/$digits');
  }
}

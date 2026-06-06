import 'dart:typed_data';

/// Lightweight PDF sniffing so a renamed/spoofed non-PDF can't slip through
/// an extension-only check. A valid PDF starts with the `%PDF-` header.
class PdfValidator {
  PdfValidator._();

  static const List<int> _magic = [0x25, 0x50, 0x44, 0x46, 0x2D]; // %PDF-

  static bool isPdf(Uint8List bytes) {
    if (bytes.length < _magic.length) return false;
    for (var i = 0; i < _magic.length; i++) {
      if (bytes[i] != _magic[i]) return false;
    }
    return true;
  }
}

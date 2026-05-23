import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  AppTextStyles._();

  static const String fontFamilyDevanagari = 'NotoSansDevanagari';

  static TextTheme buildTextTheme({required bool isDark}) {
    final Color body = isDark ? Colors.white : const Color(0xFF212121);
    final Color subtle = isDark ? Colors.white70 : const Color(0xFF616161);

    final TextTheme base = TextTheme(
      displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: body),
      displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: body),
      headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: body),
      headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: body),
      titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: body),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: body),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: body),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: body),
      bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: subtle),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: body),
      labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: subtle),
    );

    return GoogleFonts.notoSansDevanagariTextTheme(base);
  }
}

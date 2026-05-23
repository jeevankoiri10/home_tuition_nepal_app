# Fonts

Drop the following TTF files here before `flutter pub get`:

- `NotoSansDevanagari-Regular.ttf`
- `NotoSansDevanagari-Medium.ttf`
- `NotoSansDevanagari-Bold.ttf`

Download from Google Fonts: https://fonts.google.com/noto/specimen/Noto+Sans+Devanagari

These provide Devanagari glyph coverage for Nepali UI strings. Without them, Nepali text falls back to the system default and may render incorrectly on some Android versions.

If the build complains about missing fonts before you've downloaded them, comment out the `fonts:` block in `pubspec.yaml` temporarily.

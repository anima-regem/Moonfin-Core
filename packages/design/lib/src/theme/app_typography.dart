import 'package:flutter/material.dart';

class AppTypography {
  const AppTypography();

  static const fontFamily = 'Roboto';
  static const fontFamilyFallback = [
    'NotoSans',
    'Apple Color Emoji',
    'Segoe UI Emoji',
    'Noto Color Emoji',
  ];

  /// One family and a compact hierarchy shared by every app surface.
  TextTheme textTheme({String? family, required Color foreground}) {
    TextStyle style(double size, FontWeight weight, {double height = 1.3}) =>
        TextStyle(
          fontFamily: family ?? fontFamily,
          fontFamilyFallback: fontFamilyFallback,
          fontSize: size,
          fontWeight: weight,
          height: height,
          color: foreground,
        );
    return TextTheme(
      displayLarge: style(40, FontWeight.w700, height: 1.1),
      displayMedium: style(36, FontWeight.w700, height: 1.15),
      displaySmall: style(32, FontWeight.w700, height: 1.2),
      headlineLarge: style(28, FontWeight.w700, height: 1.2),
      headlineMedium: style(24, FontWeight.w700),
      headlineSmall: style(22, FontWeight.w700),
      titleLarge: style(20, FontWeight.w700),
      titleMedium: style(16, FontWeight.w500),
      titleSmall: style(14, FontWeight.w500),
      bodyLarge: style(16, FontWeight.w400, height: 1.5),
      bodyMedium: style(14, FontWeight.w400, height: 1.45),
      bodySmall: style(12, FontWeight.w400, height: 1.4),
      labelLarge: style(14, FontWeight.w500),
      labelMedium: style(12, FontWeight.w500),
      labelSmall: style(10, FontWeight.w500),
    );
  }

  static const double fontSize2xs = 10;
  static const double fontSizeXs = 12;
  static const double fontSizeSm = 14;
  static const double fontSizeMd = 16;
  static const double fontSizeLg = 18;
  static const double fontSizeXl = 20;
  static const double fontSize2xl = 24;
  static const double fontSize3xl = 32;

  TextStyle get displayLarge => const TextStyle(
    fontSize: fontSize3xl,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
  );

  TextStyle get displayMedium =>
      const TextStyle(fontSize: 28, fontWeight: FontWeight.bold);

  TextStyle get headlineLarge =>
      const TextStyle(fontSize: fontSize2xl, fontWeight: FontWeight.w600);

  TextStyle get headlineMedium =>
      const TextStyle(fontSize: fontSizeXl, fontWeight: FontWeight.w600);

  TextStyle get titleLarge =>
      const TextStyle(fontSize: fontSizeLg, fontWeight: FontWeight.w500);

  TextStyle get titleMedium =>
      const TextStyle(fontSize: fontSizeMd, fontWeight: FontWeight.w500);

  TextStyle get bodyLarge =>
      const TextStyle(fontSize: fontSizeMd, fontWeight: FontWeight.normal);

  TextStyle get bodyMedium =>
      const TextStyle(fontSize: fontSizeSm, fontWeight: FontWeight.normal);

  TextStyle get bodySmall =>
      const TextStyle(fontSize: fontSizeXs, fontWeight: FontWeight.normal);

  TextStyle get labelLarge => const TextStyle(
    fontSize: fontSizeSm,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  );

  TextStyle get labelMedium => const TextStyle(
    fontSize: fontSizeXs,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );

  TextStyle get labelSmall => const TextStyle(
    fontSize: fontSize2xs,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );
}

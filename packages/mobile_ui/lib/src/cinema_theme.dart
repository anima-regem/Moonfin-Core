import 'package:flutter/material.dart';

/// The host app supplies its active design tokens to the cinema widgets.
/// Standalone previews use the same type scale with a bundled sans serif.
@immutable
class CinemaTheme extends ThemeExtension<CinemaTheme> {
  const CinemaTheme({
    this.background = const Color(0xFF101010),
    this.surface = const Color(0xFF1A1A1A),
    this.raised = const Color(0xFF252525),
    this.foreground = const Color(0xFFFFFFFF),
    this.muted = const Color(0xFFB3B3B3),
    this.accent = const Color(0xFF0A84FF),
    this.onAccent = const Color(0xFFFFFFFF),
    this.border = const Color(0xFF404040),
    this.radius = 14,
    this.fontFamily = 'packages/moonfin_mobile_ui/Inter',
    this.fontFamilyFallback = const [
      'NotoSans',
      'Apple Color Emoji',
      'Segoe UI Emoji',
      'Noto Color Emoji',
    ],
  });

  final Color background, surface, raised, foreground, muted, accent;
  final Color onAccent, border;
  final double radius;
  final String fontFamily;
  final List<String> fontFamilyFallback;

  static CinemaTheme of(BuildContext context) =>
      Theme.of(context).extension<CinemaTheme>() ?? const CinemaTheme();

  @override
  CinemaTheme copyWith({
    Color? background,
    Color? surface,
    Color? raised,
    Color? foreground,
    Color? muted,
    Color? accent,
    Color? onAccent,
    Color? border,
    double? radius,
    String? fontFamily,
    List<String>? fontFamilyFallback,
  }) => CinemaTheme(
    background: background ?? this.background,
    surface: surface ?? this.surface,
    raised: raised ?? this.raised,
    foreground: foreground ?? this.foreground,
    muted: muted ?? this.muted,
    accent: accent ?? this.accent,
    onAccent: onAccent ?? this.onAccent,
    border: border ?? this.border,
    radius: radius ?? this.radius,
    fontFamily: fontFamily ?? this.fontFamily,
    fontFamilyFallback: fontFamilyFallback ?? this.fontFamilyFallback,
  );

  @override
  CinemaTheme lerp(covariant CinemaTheme? other, double t) {
    if (other == null) return this;
    return copyWith(
      background: Color.lerp(background, other.background, t),
      surface: Color.lerp(surface, other.surface, t),
      raised: Color.lerp(raised, other.raised, t),
      foreground: Color.lerp(foreground, other.foreground, t),
      muted: Color.lerp(muted, other.muted, t),
      accent: Color.lerp(accent, other.accent, t),
      onAccent: Color.lerp(onAccent, other.onAccent, t),
      border: Color.lerp(border, other.border, t),
      radius: radius + (other.radius - radius) * t,
      fontFamily: t < 0.5 ? fontFamily : other.fontFamily,
      fontFamilyFallback: t < 0.5
          ? fontFamilyFallback
          : other.fontFamilyFallback,
    );
  }
}

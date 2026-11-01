import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:moonfin_design/moonfin_design.dart';
import 'package:moonfin_mobile_ui/moonfin_mobile_ui.dart';

import '../../preference/preference_constants.dart';
import '../../preference/user_preferences.dart';
import '../../util/idiom/app_ui_idiom.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData buildTheme(ThemeSpec spec, {MobileCinemaMode? cinemaMode}) {
    final c = spec.colors;
    final borders = spec.borders;
    final apple =
        cinemaMode == MobileCinemaMode.appleTv ||
        (cinemaMode == null && AppUiIdiomResolver.isApple);
    final radius = spec.isPixel
        ? 0.0
        : cinemaMode == MobileCinemaMode.netflix
        ? 6.0
        : apple
        ? 14.0
        : AppShapes.medium;
    final borderRadius = BorderRadius.circular(radius);
    final panelRadius = BorderRadius.circular(spec.isPixel ? 0 : radius + 6);
    final OutlinedBorder buttonShape = apple && !spec.isPixel
        ? AppShapes.squircle(radius)
        : RoundedRectangleBorder(borderRadius: borderRadius);
    final panelShape = RoundedRectangleBorder(
      borderRadius: panelRadius,
      side: borders.cardBorder,
    );
    final family = spec.fontFamily ?? AppTypography.fontFamily;
    var text = JellyfinTokens.typography.textTheme(
      family: family,
      foreground: c.onSurface,
    );
    // Custom themes may decorate headings without introducing a second face
    // or making body copy and form labels harder to read.
    if (spec.textGlow.isNotEmpty) {
      TextStyle? heading(TextStyle? style) =>
          style?.copyWith(shadows: spec.textGlow);
      text = text.copyWith(
        displayLarge: heading(text.displayLarge),
        displayMedium: heading(text.displayMedium),
        displaySmall: heading(text.displaySmall),
        headlineLarge: heading(text.headlineLarge),
        headlineMedium: heading(text.headlineMedium),
        headlineSmall: heading(text.headlineSmall),
        titleLarge: heading(text.titleLarge),
        titleMedium: heading(text.titleMedium),
        titleSmall: heading(text.titleSmall),
      );
    }
    final muted = c.onSurface.withValues(alpha: 0.68);
    final error = c.error ?? spec.semantic.statusError;
    final selection = c.accent.withValues(alpha: 0.16);
    final scheme = ColorScheme.dark(
      primary: c.accent,
      onPrimary: c.onAccent,
      primaryContainer: selection,
      onPrimaryContainer: c.onSurface,
      secondary: c.accent,
      onSecondary: c.onAccent,
      secondaryContainer: selection,
      onSecondaryContainer: c.onSurface,
      tertiary: spec.semantic.statusRequested,
      onTertiary: c.onSurface,
      surface: c.surface,
      onSurface: c.onSurface,
      onSurfaceVariant: muted,
      surfaceDim: c.background,
      surfaceBright: c.surfaceVariant,
      surfaceContainerLowest: c.background,
      surfaceContainerLow: c.surface,
      surfaceContainer: c.card,
      surfaceContainerHigh: c.surfaceVariant,
      surfaceContainerHighest: c.surfaceVariant,
      surfaceTint: Colors.transparent,
      outline: c.inputBorder,
      outlineVariant: c.inputBorder.withValues(alpha: 0.45),
      error: error,
      onError: c.onSurface,
      errorContainer: error.withValues(alpha: 0.16),
      onErrorContainer: error,
      scrim: c.scrim,
    );
    final inputBorder = OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: BorderSide(color: c.inputBorder),
    );
    final buttonStyle = ButtonStyle(
      shape: WidgetStatePropertyAll(buttonShape),
      minimumSize: const WidgetStatePropertyAll(Size(48, 48)),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
      textStyle: WidgetStatePropertyAll(text.labelLarge),
      overlayColor: WidgetStatePropertyAll(c.accent.withValues(alpha: 0.12)),
    );
    return ThemeData(
      useMaterial3: true,
      platform: switch (AppUiIdiomResolver.current) {
        AppUiIdiom.iosMobile => TargetPlatform.iOS,
        AppUiIdiom.macDesktop => TargetPlatform.macOS,
        AppUiIdiom.material => TargetPlatform.android,
        AppUiIdiom.tvosLeanback => null,
      },
      brightness: Brightness.dark,
      fontFamily: family,
      fontFamilyFallback: AppTypography.fontFamilyFallback,
      textTheme: text,
      primaryTextTheme: text,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.background,
      canvasColor: c.surface,
      cardColor: c.card,
      dividerColor: scheme.outlineVariant,
      disabledColor: c.onButtonDisabled,
      focusColor: selection,
      hoverColor: c.onSurface.withValues(alpha: 0.06),
      highlightColor: selection,
      iconTheme: IconThemeData(color: c.onSurface, size: 22),
      extensions: [
        CinemaTheme(
          background: c.background,
          surface: c.surface,
          raised: c.surfaceVariant,
          foreground: c.onSurface,
          muted: muted,
          accent: c.accent,
          onAccent: c.onAccent,
          border: c.inputBorder,
          radius: radius,
          fontFamily: family,
          fontFamilyFallback: AppTypography.fontFamilyFallback,
        ),
      ],
      textSelectionTheme: TextSelectionThemeData(
        selectionColor: c.accent.withValues(alpha: 0.4),
        selectionHandleColor: c.accent,
        cursorColor: c.accent,
      ),
      cardTheme: CardThemeData(
        color: c.card,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: panelShape,
        margin: const EdgeInsets.symmetric(vertical: 6),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: c.background,
        foregroundColor: c.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: text.titleLarge,
        iconTheme: IconThemeData(color: c.onSurface, size: 22),
      ),
      pageTransitionsTheme: AppUiIdiomResolver.current == AppUiIdiom.iosMobile
          ? _cupertinoTransitions
          : _fadeScaleTransitions,
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: c.surface,
        selectedItemColor: c.accent,
        unselectedItemColor: muted,
        selectedLabelStyle: text.labelSmall,
        unselectedLabelStyle: text.labelSmall,
        elevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: selection,
        labelTextStyle: WidgetStatePropertyAll(text.labelSmall),
        elevation: 0,
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: c.surface,
        indicatorColor: selection,
        selectedIconTheme: IconThemeData(color: c.accent),
        unselectedIconTheme: IconThemeData(color: muted),
        selectedLabelTextStyle: text.labelMedium?.copyWith(color: c.accent),
        unselectedLabelTextStyle: text.labelMedium?.copyWith(color: muted),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: c.accent,
          foregroundColor: c.onAccent,
          disabledBackgroundColor: c.buttonDisabled,
          disabledForegroundColor: c.onButtonDisabled,
        ).merge(buttonStyle),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: c.buttonNormal,
          foregroundColor: c.onButtonNormal,
          disabledBackgroundColor: c.buttonDisabled,
          disabledForegroundColor: c.onButtonDisabled,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
        ).merge(buttonStyle),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: c.onSurface,
          side: BorderSide(color: c.inputBorder),
        ).merge(buttonStyle),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: c.accent)
            .merge(buttonStyle),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: c.onSurface,
          minimumSize: const Size(48, 48),
          shape: buttonShape,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.inputBackground,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        labelStyle: text.bodyMedium?.copyWith(color: muted),
        hintStyle: text.bodyMedium?.copyWith(color: muted),
        helperStyle: text.bodySmall?.copyWith(color: muted),
        prefixIconColor: muted,
        suffixIconColor: muted,
        border: inputBorder,
        enabledBorder: inputBorder,
        disabledBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: c.inputBorderFocused, width: 2),
        ),
        errorBorder: inputBorder.copyWith(borderSide: BorderSide(color: error)),
        focusedErrorBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: error, width: 2),
        ),
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        titleTextStyle: text.bodyLarge,
        subtitleTextStyle: text.bodyMedium?.copyWith(color: muted),
        iconColor: muted,
        textColor: c.onSurface,
        selectedColor: c.accent,
        selectedTileColor: selection,
        shape: buttonShape,
      ),
      tabBarTheme: TabBarThemeData(
        labelStyle: text.labelLarge,
        unselectedLabelStyle: text.labelLarge,
        labelColor: c.onSurface,
        unselectedLabelColor: muted,
        indicatorColor: c.accent,
        dividerColor: scheme.outlineVariant,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: borders.chipBackground,
        selectedColor: selection,
        disabledColor: c.buttonDisabled,
        labelStyle: text.labelMedium,
        secondaryLabelStyle: text.labelMedium?.copyWith(color: c.accent),
        side: borders.chipBorder,
        shape: RoundedRectangleBorder(borderRadius: borders.chipRadius),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        shape: panelShape,
        titleTextStyle: text.headlineSmall,
        contentTextStyle: text.bodyMedium,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.surface,
        modalBackgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        modalBarrierColor: c.scrim,
        dragHandleColor: muted,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: panelRadius.topLeft),
          side: borders.cardBorder,
        ),
        clipBehavior: Clip.antiAlias,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: c.surface,
        surfaceTintColor: Colors.transparent,
        textStyle: text.bodyMedium,
        shape: panelShape,
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: text.bodyMedium,
        menuStyle: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(c.surface),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          shape: WidgetStatePropertyAll(panelShape),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: c.surfaceVariant,
        contentTextStyle: text.bodyMedium,
        actionTextColor: c.accent,
        behavior: SnackBarBehavior.floating,
        shape: panelShape,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: c.surfaceVariant,
          borderRadius: borderRadius,
        ),
        textStyle: text.bodySmall,
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: c.rangeProgress,
        inactiveTrackColor: c.rangeTrack,
        thumbColor: c.rangeThumb,
        valueIndicatorTextStyle: text.labelMedium?.copyWith(color: c.onAccent),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: c.rangeProgress,
        linearTrackColor: c.rangeTrack,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.disabled)
              ? c.onButtonDisabled
              : states.contains(WidgetState.selected)
              ? c.onAccent
              : muted,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? c.accent
              : c.inputBackground,
        ),
        trackOutlineColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? Colors.transparent
              : c.inputBorder,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.disabled)
              ? c.buttonDisabled
              : states.contains(WidgetState.selected)
              ? c.accent
              : Colors.transparent,
        ),
        checkColor: WidgetStatePropertyAll(c.onAccent),
        side: BorderSide(color: c.inputBorder),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(spec.isPixel ? 0 : 4),
        ),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.disabled)
              ? c.onButtonDisabled
              : states.contains(WidgetState.selected)
              ? c.accent
              : muted,
        ),
      ),
    );
  }

  static final darkTheme = buildTheme(
    ThemeRegistry.resolveById(ThemeRegistry.moonfinId),
  );

  static const _fadeScaleTransitions = PageTransitionsTheme(
    builders: {
      TargetPlatform.android: _FadeScalePageTransitionsBuilder(),
      TargetPlatform.fuchsia: _FadeScalePageTransitionsBuilder(),
      TargetPlatform.linux: _FadeScalePageTransitionsBuilder(),
      TargetPlatform.macOS: _FadeScalePageTransitionsBuilder(),
      TargetPlatform.windows: _FadeScalePageTransitionsBuilder(),
      TargetPlatform.iOS: _FadeScalePageTransitionsBuilder(),
    },
  );

  static const _cupertinoTransitions = PageTransitionsTheme(
    builders: {
      TargetPlatform.android: CupertinoPageTransitionsBuilder(),
      TargetPlatform.fuchsia: CupertinoPageTransitionsBuilder(),
      TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
      TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    },
  );
}

class _FadeScalePageTransitionsBuilder extends PageTransitionsBuilder {
  const _FadeScalePageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final speed = GetIt.I.isRegistered<UserPreferences>()
        ? GetIt.I<UserPreferences>().get(UserPreferences.pageTransitionSpeed)
        : PageTransitionSpeed.medium;

    // The route owns this controller and there is no public way to retime it,
    // so without this a speed change would only take hold on the next route.
    // No Fade comes through here too. Handing back the child early would skip
    // the fade but leave the route running for Flutter's 450ms default.
    // ignore: invalid_use_of_protected_member
    final controller = route.controller;
    if (controller != null && controller.duration != speed.duration) {
      controller.duration = speed.duration;
      controller.reverseDuration = speed.duration;
      if (controller.isAnimating) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (controller.isAnimating) {
            final remaining = (1.0 - controller.value).clamp(0.0, 1.0);
            if (animation.status == AnimationStatus.forward) {
              controller.animateTo(
                1.0,
                duration: speed.duration * remaining,
                curve: Curves.linear,
              );
            } else if (animation.status == AnimationStatus.reverse) {
              controller.animateBack(
                0.0,
                duration: speed.duration * controller.value,
                curve: Curves.linear,
              );
            }
          }
        });
      }
    }

    final Animation<double> curved;
    final Tween<double> scaleTween;

    switch (speed) {
      case PageTransitionSpeed.off:
        return child;
      case PageTransitionSpeed.fast:
        // Snappy fade (150ms feel) with subtle scale
        curved = CurvedAnimation(
          parent: animation,
          curve: const Interval(0.0, 0.7, curve: Curves.easeOutQuad),
          reverseCurve: const Interval(0.3, 1.0, curve: Curves.easeInQuad),
        );
        scaleTween = Tween<double>(begin: 0.97, end: 1.0);
      case PageTransitionSpeed.medium:
        // Balanced fade (300ms) with moderate scale
        curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        scaleTween = Tween<double>(begin: 0.94, end: 1.0);
      case PageTransitionSpeed.slow:
        // Deliberate cinematic long fade (450ms) with more depth
        curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOutSine,
          reverseCurve: Curves.easeInOutSine,
        );
        scaleTween = Tween<double>(begin: 0.90, end: 1.0);
    }

    return FadeTransition(
      opacity: curved,
      child: ScaleTransition(scale: scaleTween.animate(curved), child: child),
    );
  }
}

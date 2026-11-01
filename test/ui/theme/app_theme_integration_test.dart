import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moonfin/ui/theme/app_theme.dart';
import 'package:moonfin/ui/widgets/settings/clean_settings_typography.dart';
import 'package:moonfin_design/moonfin_design.dart';
import 'package:moonfin_mobile_ui/moonfin_mobile_ui.dart';

void main() {
  test('every built-in theme supplies the same tokens to app components', () {
    for (final id in ThemeRegistry.builtInIds) {
      final spec = ThemeRegistry.resolveById(id);
      final theme = AppTheme.buildTheme(spec);
      final cinema = theme.extension<CinemaTheme>()!;

      expect(cinema.background, spec.colors.background, reason: id);
      expect(cinema.accent, theme.colorScheme.primary, reason: id);
      expect(cinema.fontFamily, theme.textTheme.bodyMedium!.fontFamily);
      expect(theme.colorScheme.surfaceContainerLow, spec.colors.surface);
      expect(
        theme.colorScheme.surfaceContainerHighest,
        spec.colors.surfaceVariant,
      );
      expect(theme.colorScheme.outline, spec.colors.inputBorder);
      expect(theme.bottomSheetTheme.backgroundColor, spec.colors.surface);
      expect(theme.dialogTheme.backgroundColor, spec.colors.surface);
      expect(theme.popupMenuTheme.color, spec.colors.surface);
      expect(theme.inputDecorationTheme.fillColor, spec.colors.inputBackground);
      expect(
        theme.filledButtonTheme.style!.backgroundColor!.resolve({}),
        spec.colors.accent,
      );
      expect(
        theme.switchTheme.trackColor!.resolve({WidgetState.selected}),
        spec.colors.accent,
      );
      expect(
        theme.checkboxTheme.fillColor!.resolve({WidgetState.selected}),
        spec.colors.accent,
      );
      for (final style in [
        theme.textTheme.displayLarge,
        theme.textTheme.headlineSmall,
        theme.textTheme.bodyLarge,
        theme.textTheme.labelSmall,
        theme.listTileTheme.titleTextStyle,
        theme.dialogTheme.titleTextStyle,
        theme.appBarTheme.titleTextStyle,
      ]) {
        expect(style!.fontFamily, AppTypography.fontFamily, reason: id);
        expect(style.fontFamilyFallback, contains('NotoSans'), reason: id);
      }
    }
  });

  test(
    'cinema modes change shared chrome and retain selected theme colors',
    () {
      final spec = ThemeRegistry.resolveById(ThemeRegistry.neonPulseId);
      final apple = AppTheme.buildTheme(
        spec,
        cinemaMode: MobileCinemaMode.appleTv,
      );
      final netflix = AppTheme.buildTheme(
        spec,
        cinemaMode: MobileCinemaMode.netflix,
      );
      expect(apple.extension<CinemaTheme>()!.radius, 14);
      expect(netflix.extension<CinemaTheme>()!.radius, 6);
      expect(apple.colorScheme, netflix.colorScheme);
      expect(apple.textTheme, netflix.textTheme);
      final pixel = AppTheme.buildTheme(
        ThemeRegistry.resolveById(ThemeRegistry.eightbitHeroId),
        cinemaMode: MobileCinemaMode.appleTv,
      );
      expect(pixel.extension<CinemaTheme>()!.radius, 0);
    },
  );

  testWidgets(
    'open dialogs and settings inherit theme changes without losing input',
    (tester) async {
      final active = ValueNotifier(ThemeRegistry.moonfinId);
      final input = TextEditingController();
      addTearDown(active.dispose);
      addTearDown(input.dispose);
      await tester.pumpWidget(
        ValueListenableBuilder(
          valueListenable: active,
          builder: (context, id, _) => MaterialApp(
            theme: AppTheme.buildTheme(ThemeRegistry.resolveById(id)),
            home: Builder(
              builder: (context) => Scaffold(
                body: withCleanSettingsTypography(
                  context,
                  Center(
                    child: FilledButton(
                      onPressed: () => showDialog<void>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Library settings'),
                          content: TextField(controller: input),
                        ),
                      ),
                      child: const Text('Settings'),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'My library');
      active.value = ThemeRegistry.neonPulseId;
      await tester.pumpAndSettle();
      expect(find.text('Library settings'), findsOneWidget);
      expect(input.text, 'My library');
      final theme = Theme.of(tester.element(find.byType(TextField)));
      expect(
        theme.colorScheme.primary,
        ThemeRegistry.resolveById(ThemeRegistry.neonPulseId).colors.accent,
      );
      expect(theme.textTheme.bodyMedium!.fontFamily, AppTypography.fontFamily);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'cinema widgets inherit the app font and palette at large text sizes',
    (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      for (final mode in MobileCinemaMode.values) {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.buildTheme(
              ThemeRegistry.resolveById(ThemeRegistry.neonPulseId),
              cinemaMode: mode,
            ),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.linear(1.6)),
              child: child!,
            ),
            home: Scaffold(
              body: Center(
                child: CinemaButton(
                  mode: mode,
                  label: 'Browse your library',
                  onPressed: () {},
                ),
              ),
              bottomNavigationBar: CinemaNavigationBar(
                mode: mode,
                selected: CinemaDestination.search,
                onSelected: (_) {},
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final label = tester.widget<Text>(find.text('Browse your library'));
        expect(label.style!.fontFamily, AppTypography.fontFamily);
        expect(label.style!.fontFamilyFallback, contains('NotoSans'));
        expect(tester.takeException(), isNull);
      }
    },
  );
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moonfin/preference/user_preferences.dart';
import 'package:moonfin/ui/widgets/bottom_nav/bottom_navbar.dart';
import 'package:moonfin/ui/widgets/bottom_nav/bottom_mini_player.dart';
import 'package:moonfin/ui/widgets/navigation_layout.dart';
import 'package:moonfin_mobile_ui/moonfin_mobile_ui.dart';

import 'bottom_nav/bottom_nav_fakes.dart';

void main() {
  late UserPreferences prefs;
  late FakePlaybackManager playback;

  setUp(() async {
    final services = await setUpBottomNav(cinema: true);
    prefs = services.prefs;
    playback = services.playback;
  });

  tearDown(tearDownBottomNav);

  testWidgets(
    'audio controls remain available when a detail page hides navigation',
    (tester) async {
      usePhoneView(tester);
      playback.queueService.setQueue([testTrack]);
      await tester.pumpWidget(bottomNavApp(chrome: false));
      await tester.pumpAndSettle();
      expect(find.byType(BottomMiniPlayer), findsOneWidget);
      expect(find.byType(CinemaNavigationBar), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'search and library routes share cinema chrome and preserve input when modes change',
    (tester) async {
      usePhoneView(tester);
      final input = TextEditingController();
      addTearDown(input.dispose);
      await tester.pumpWidget(
        bottomNavApp(
          activeRoute: '/search',
          child: Center(child: TextField(controller: input)),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(CinemaNavigationBar), findsOneWidget);
      expect(NavigationLayout.usesBottomNavbar, isTrue);
      expect(
        tester
            .widget<CinemaNavigationBar>(find.byType(CinemaNavigationBar))
            .selected,
        CinemaDestination.search,
      );
      await tester.enterText(find.byType(TextField), 'Moonfin');

      await prefs.set(UserPreferences.mobileCinemaMode, 'netflix');
      await tester.pumpAndSettle();
      expect(input.text, 'Moonfin');
      expect(
        tester
            .widget<CinemaNavigationBar>(find.byType(CinemaNavigationBar))
            .mode,
        MobileCinemaMode.netflix,
      );

      await tester.pumpWidget(
        bottomNavApp(
          activeRoute: '/library/test',
          child: Center(child: TextField(controller: input)),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<CinemaNavigationBar>(find.byType(CinemaNavigationBar))
            .selected,
        CinemaDestination.library,
      );
      expect(input.text, 'Moonfin');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'the library picker works away from home, including empty accounts',
    (tester) async {
      usePhoneView(tester);
      await tester.pumpWidget(bottomNavApp(activeRoute: '/search'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byWidgetPredicate(
          (widget) => widget is CinemaPressable && widget.label == 'Library',
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('No libraries found'), findsOneWidget);
      await tester.tap(
        find.byWidgetPredicate(
          (widget) => widget is CinemaPressable && widget.label == 'Close',
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('No libraries found'), findsNothing);
      expect(find.byType(CinemaNavigationBar), findsOneWidget);
    },
  );

  testWidgets(
    'the keyboard hides cinema navigation and leaves the page mounted',
    (tester) async {
      usePhoneView(tester);
      await tester.pumpWidget(
        bottomNavApp(child: const Text('Search results')),
      );
      await tester.pumpAndSettle();
      expect(find.byType(CinemaNavigationBar), findsOneWidget);
      tester.view.viewInsets = const FakeViewPadding(bottom: 600);
      await tester.pumpAndSettle();
      expect(find.byType(CinemaNavigationBar), findsNothing);
      expect(find.text('Search results'), findsOneWidget);
      tester.view.viewInsets = const FakeViewPadding();
      await tester.pumpAndSettle();
      expect(find.byType(CinemaNavigationBar), findsOneWidget);
    },
  );

  testWidgets('turning cinema off restores the selected legacy navbar', (
    tester,
  ) async {
    usePhoneView(tester);
    await tester.pumpWidget(bottomNavApp(child: const Text('Library content')));
    await tester.pumpAndSettle();
    await prefs.set(UserPreferences.mobileCinemaEnabled, false);
    await tester.pumpAndSettle();
    expect(find.byType(CinemaNavigationBar), findsNothing);
    expect(find.byType(BottomNavbar), findsOneWidget);
    expect(find.text('Library content'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

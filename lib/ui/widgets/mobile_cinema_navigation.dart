import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:moonfin_mobile_ui/moonfin_mobile_ui.dart';
import 'package:playback_core/playback_core.dart';

import '../../data/models/aggregated_library.dart';
import '../../data/repositories/user_views_repository.dart';
import '../../data/repositories/multi_server_repository.dart';
import '../../data/services/library_scope_service.dart';
import '../../l10n/app_localizations.dart';
import '../../preference/user_preferences.dart';
import '../../util/platform_detection.dart';
import '../../util/game_library.dart';
import '../navigation/destinations.dart';
import '../screens/downloads/downloads_panel.dart';
import 'user_menu_dialog.dart';
import 'bottom_nav/bottom_mini_player.dart';
import 'bottom_nav/bottom_nav_theme.dart';
import 'settings/settings_panel.dart';
import '../screens/settings/settings_side_panel.dart';

bool usesMobileCinema(UserPreferences preferences) =>
    PlatformDetection.useMobileUi &&
    preferences.get(UserPreferences.mobileCinemaEnabled) &&
    !preferences.get(UserPreferences.kidsModeEnabled);

/// Shared by home, search, libraries, and detail routes.
class MobileCinemaNavigation extends StatelessWidget {
  const MobileCinemaNavigation({
    super.key,
    required this.preferences,
    this.activeRoute,
    this.onHome,
    this.showDestinations = true,
  });

  final UserPreferences preferences;
  final String? activeRoute;
  final VoidCallback? onHome;
  final bool showDestinations;

  @override
  Widget build(BuildContext context) => StreamBuilder(
    stream: GetIt.instance<PlaybackManager>().queueService.queueChangedStream,
    builder: (context, _) => ListenableBuilder(
      listenable: preferences,
      builder: (context, _) {
        final mode = MobileCinemaMode.fromPreference(
          preferences.get(UserPreferences.mobileCinemaMode),
        );
        final l10n = AppLocalizations.of(context);
        final selected = activeRoute == Destinations.home
            ? CinemaDestination.home
            : activeRoute == Destinations.search
            ? CinemaDestination.search
            : CinemaDestination.library;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (bottomMiniPlayerHasTrack())
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                child: BottomMiniPlayer(
                  variant: BottomMiniPlayerVariant.capsule,
                  theme: BottomNavTheme.resolve(context),
                ),
              ),
            if (showDestinations)
              CinemaNavigationBar(
                mode: mode,
                selected: selected,
                homeLabel: l10n.home,
                libraryLabel: l10n.library,
                searchLabel: l10n.search,
                downloadsLabel: l10n.savedMedia,
                profileLabel: l10n.profile,
                onSelected: (destination) {
                  switch (destination) {
                    case CinemaDestination.home:
                      if (activeRoute == Destinations.home) {
                        onHome?.call();
                      } else {
                        context.go(Destinations.home);
                      }
                    case CinemaDestination.search:
                      if (activeRoute != Destinations.search) {
                        context.navigateTopLevel(Destinations.search);
                      }
                    case CinemaDestination.downloads:
                      showDownloadsDialog(context);
                    case CinemaDestination.profile:
                      showMobileCinemaProfile(context, preferences);
                    case CinemaDestination.library:
                      showCinemaSheet<void>(
                        context,
                        mode: mode,
                        builder: (_) => _CinemaLibrarySheet(
                          mode: mode,
                          routeContext: context,
                        ),
                      );
                  }
                },
              ),
          ],
        );
      },
    ),
  );
}

class _CinemaLibrarySheet extends StatefulWidget {
  const _CinemaLibrarySheet({required this.mode, required this.routeContext});
  final MobileCinemaMode mode;
  final BuildContext routeContext;

  @override
  State<_CinemaLibrarySheet> createState() => _CinemaLibrarySheetState();
}

class _CinemaLibrarySheetState extends State<_CinemaLibrarySheet> {
  late Future<List<AggregatedLibrary>> _libraries;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _libraries = _fetchLibraries();
    unawaited(GetIt.instance<GameLibraryRegistry>().refresh());
  }

  Future<List<AggregatedLibrary>> _fetchLibraries() async {
    final prefs = GetIt.instance<UserPreferences>();
    if (!prefs.get(UserPreferences.enableMultiServerLibraries)) {
      return GetIt.instance<UserViewsRepository>().getUserViews();
    }
    final libraries = await GetIt.instance<MultiServerRepository>()
        .getAggregatedLibraries();
    return GetIt.instance<LibraryScopeService>().withoutHiddenLibraries(
      libraries,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.library,
                  style: CinemaStyle.text(
                    context,
                    widget.mode,
                    28,
                    weight: FontWeight.w700,
                  ),
                ),
              ),
              CinemaIconButton(
                icon: CinemaGlyph.close,
                label: l10n.close,
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 20),
          FutureBuilder<List<AggregatedLibrary>>(
            future: _libraries,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Column(
                  children: [
                    Text(l10n.failedToLoadLibraries),
                    const SizedBox(height: 16),
                    CinemaButton(
                      mode: widget.mode,
                      label: l10n.retry,
                      onPressed: () => setState(_load),
                    ),
                  ],
                );
              }
              if (!snapshot.hasData) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              final libraries = snapshot.data!;
              if (libraries.isEmpty) return Text(l10n.noLibrariesFound);
              return Column(
                children: [
                  for (final library in libraries)
                    CinemaPressable(
                      label: library.name,
                      onPressed: () {
                        Navigator.pop(context);
                        if (!widget.routeContext.mounted) return;
                        widget.routeContext.navigateTopLevel(
                          libraryRoute(
                            library.id,
                            library.collectionType,
                            library.name,
                            serverId: library.serverId,
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        child: Row(
                          children: [
                            const CinemaIcon(CinemaGlyph.library),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                library.name,
                                style: CinemaStyle.text(
                                  context,
                                  widget.mode,
                                  18,
                                ),
                              ),
                            ),
                            const CinemaIcon(CinemaGlyph.chevron, size: 14),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

void showMobileCinemaProfile(
  BuildContext context,
  UserPreferences preferences,
) {
  final mode = MobileCinemaMode.fromPreference(
    preferences.get(UserPreferences.mobileCinemaMode),
  );
  showCinemaSheet<void>(
    context,
    mode: mode,
    builder: (sheetContext) => SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CinemaAvatar(size: 42, apple: mode == MobileCinemaMode.appleTv),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Your Moonfin',
                  style: CinemaStyle.text(
                    context,
                    mode,
                    26,
                    weight: FontWeight.w700,
                  ),
                ),
              ),
              CinemaIconButton(
                icon: CinemaGlyph.close,
                label: 'Close',
                onPressed: () => Navigator.pop(sheetContext),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Text(
            'Appearance',
            style: CinemaStyle.text(context, mode, 20, weight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          for (final value in MobileCinemaMode.values)
            CinemaPressable(
              label: '${value.label} mode',
              selected: value == mode,
              onPressed: () async {
                await preferences.set(
                  UserPreferences.mobileCinemaMode,
                  value.name,
                );
                if (sheetContext.mounted) Navigator.pop(sheetContext);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 17),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        value.label,
                        style: CinemaStyle.text(context, mode, 18),
                      ),
                    ),
                    if (value == mode) const CinemaIcon(CinemaGlyph.check),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: CinemaButton(
              mode: mode,
              label: AppLocalizations.of(context).settings,
              primary: false,
              onPressed: () {
                Navigator.pop(sheetContext);
                SettingsPanel.open(context, const SettingsSidePanel());
              },
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: CinemaButton(
              mode: mode,
              label: 'Manage account',
              primary: false,
              onPressed: () {
                Navigator.pop(sheetContext);
                showUserMenu(context);
              },
            ),
          ),
        ],
      ),
    ),
  );
}

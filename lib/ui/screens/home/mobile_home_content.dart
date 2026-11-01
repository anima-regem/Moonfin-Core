import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:moonfin_mobile_ui/moonfin_mobile_ui.dart';
import 'package:server_core/server_core.dart';

import '../../../data/models/aggregated_item.dart';
import '../../../data/models/home_row.dart';
import '../../../data/services/media_server_client_factory.dart';
import '../../../data/services/user_data_sync.dart';
import '../../../l10n/app_localizations.dart';
import '../../../preference/user_preferences.dart';
import '../../../preference/preference_constants.dart';
import '../../navigation/destinations.dart';
import '../../util/home_row_title_localizer.dart';
import '../../widgets/bounded_network_image.dart';
import '../../widgets/mobile_cinema_navigation.dart';
import 'home_view_model.dart';

/// Uses the existing home pipeline, including cached rows and multi-server data.
class MobileHomeContent extends StatelessWidget {
  const MobileHomeContent({
    super.key,
    required this.viewModel,
    required this.preferences,
    required this.onOpen,
    required this.posterFor,
    required this.backdropFor,
  });

  final HomeViewModel viewModel;
  final UserPreferences preferences;
  final ValueChanged<AggregatedItem> onOpen;
  final String? Function(AggregatedItem, ImageApi) posterFor, backdropFor;

  String _key(AggregatedItem item) => '${item.serverId}/${item.id}';
  MediaServerClient _client(AggregatedItem item) =>
      GetIt.instance<MediaServerClientFactory>().clientForServerOrActive(
        item.serverId,
      );

  MobileMedia _media(AggregatedItem item) {
    final images = _client(item).imageApi;
    final external = item.serverId == 'seerr';
    final kind = switch (item.type) {
      'Movie' || 'movie' => MobileMediaKind.movie,
      'Series' || 'Episode' || 'tv' => MobileMediaKind.series,
      _ => MobileMediaKind.other,
    };
    return MobileMedia(
      id: _key(item),
      title: item.type == 'Episode' ? item.seriesName ?? item.name : item.name,
      subtitle: item.type == 'Episode'
          ? [
              if (item.parentIndexNumber != null) 'S${item.parentIndexNumber}',
              if (item.indexNumber != null) 'E${item.indexNumber}',
              item.name,
            ].join(' · ')
          : item.subtitle ?? '',
      overview: item.overview ?? '',
      metadata: [
        if (item.productionYear != null) '${item.productionYear}',
        if (item.genres.isNotEmpty) item.genres.first,
        if (item.officialRating?.isNotEmpty ?? false) item.officialRating!,
      ].join('  ·  '),
      posterUrl: posterFor(item, images),
      backdropUrl: backdropFor(item, images),
      logoUrl: item.logoImageTag == null
          ? null
          : images.getLogoImageUrl(
              item.id,
              maxWidth: 500,
              tag: item.logoImageTag,
            ),
      kind: kind,
      progress: ((item.playedPercentage ?? 0) / 100).clamp(0, 1),
      saved: item.isFavorite,
      canPlay:
          !external &&
          const {
            'Movie',
            'Episode',
            'Video',
            'MusicVideo',
            'Audio',
            'AudioBook',
          }.contains(item.type),
      canSave: !external && kind != MobileMediaKind.other,
    );
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: Listenable.merge([
      viewModel,
      viewModel.mediaBarViewModel,
      preferences,
    ]),
    builder: (context, _) {
      final l10n = AppLocalizations.of(context);
      final itemsByKey = <String, AggregatedItem>{};
      final rails = [
        for (final row in viewModel.rows)
          if (row.rowType != HomeRowType.mediaBar)
            MobileMediaRail(
              id: row.id,
              title: localizeHomeRowTitle(
                row: row,
                l10n: l10n,
                mergeContinueWatchingAndNextUp: preferences.get(
                  UserPreferences.mergeContinueWatchingNextUp,
                ),
              ),
              items: [
                for (final item in row.items)
                  () {
                    itemsByKey[_key(item)] = item;
                    return _media(item);
                  }(),
              ],
              continueWatching:
                  row.rowType == HomeRowType.resume ||
                  row.rowType == HomeRowType.nextUp ||
                  row.rowType == HomeRowType.resumeAudio,
              loading: row.isLoading,
              hasMore: row.hasMore,
            ),
      ];
      final featured = <MobileMedia>[];
      for (final slide in viewModel.mediaBarViewModel.items) {
        final item = AggregatedItem(
          id: slide.itemId,
          serverId: slide.serverId,
          rawData: {'Name': slide.title, 'Type': slide.itemType},
        );
        itemsByKey.putIfAbsent(_key(item), () => item);
        featured.add(
          MobileMedia(
            id: _key(item),
            title: slide.title,
            overview: slide.overview ?? '',
            metadata: [
              if (slide.year != null) '${slide.year}',
              ...slide.genres.take(2),
              if (slide.officialRating != null) slide.officialRating!,
            ].join('  ·  '),
            posterUrl: slide.posterUrl,
            backdropUrl: slide.backdropUrl,
            logoUrl: slide.logoUrl,
            kind: slide.itemType == 'Series'
                ? MobileMediaKind.series
                : MobileMediaKind.movie,
            canPlay: !slide.isExternal && slide.itemType == 'Movie',
            // Slides do not carry authoritative favorite state. Details owns it.
            canSave: false,
          ),
        );
      }
      final mode = MobileCinemaMode.fromPreference(
        preferences.get(UserPreferences.mobileCinemaMode),
      );
      Future<void> save(MobileMedia media, bool saved) async {
        final item = itemsByKey[media.id]!;
        final api = _client(item).userLibraryApi;
        if (saved) {
          await api.markFavorite(item.id);
        } else {
          await api.unmarkFavorite(item.id);
        }
        userDataSync.publish(item.id, {'IsFavorite': saved});
      }

      void play(MobileMedia media) {
        final item = itemsByKey[media.id]!;
        context.push(
          Destinations.item(item.id, serverId: item.serverId, autoPlay: true),
        );
      }

      Widget artwork(BuildContext context, String url, BoxFit fit) =>
          BoundedNetworkImage(
            imageUrl: url,
            fit: fit,
            errorBuilder: (_, _, _) =>
                const Center(child: CinemaIcon(CinemaGlyph.library)),
          );
      return MobileCinemaHome(
        mode: mode,
        rails: rails,
        featured: featured,
        loading: viewModel.isLoading,
        labels: MobileHomeLabels(
          movies: l10n.movies,
          series: l10n.series,
          saved: l10n.favorites,
          search: l10n.search,
          play: l10n.play,
          resume: l10n.resume,
          details: l10n.details,
          retry: l10n.refresh,
        ),
        onModeChanged: (mode) =>
            preferences.set(UserPreferences.mobileCinemaMode, mode.name),
        onOpen: (media) {
          if (media.kind == MobileMediaKind.other ||
              (media.progress > 0 &&
                  preferences.get(
                        UserPreferences.continueWatchingDefaultAction,
                      ) ==
                      ContinueWatchingDefaultAction.play)) {
            onOpen(itemsByKey[media.id]!);
            return;
          }
          showCinemaDetails(
            context,
            mode: mode,
            item: media,
            artworkBuilder: artwork,
            onPlay: () => play(media),
            onSave: media.canSave ? (saved) => save(media, saved) : null,
            onMore: () => onOpen(itemsByKey[media.id]!),
          );
        },
        onPlay: play,
        onSave: save,
        onSearch: () => context.push(Destinations.search),
        onProfile: () => showMobileCinemaProfile(context, preferences),
        onRefresh: () => viewModel.refresh(preserveExisting: true),
        onRailVisible: (id) => viewModel.loadSectionsNear(
          viewModel.rows.where((row) => row.id == id),
        ),
        onLoadMore: (id) {
          final index = viewModel.rows.indexWhere((row) => row.id == id);
          if (index >= 0) viewModel.loadMoreForRow(index);
        },
        artworkBuilder: artwork,
        bottomPadding: mode == MobileCinemaMode.appleTv ? 110 : 24,
      );
    },
  );
}

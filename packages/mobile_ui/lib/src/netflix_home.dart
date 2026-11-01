part of 'mobile_home.dart';

class _NetflixHome extends StatelessWidget {
  const _NetflixHome({required this.state, required this.feed});
  final _MobileCinemaHomeState state;
  final _Feed feed;
  @override
  Widget build(BuildContext context) => Stack(
    children: [
      Positioned.fill(
        child: ColoredBox(color: CinemaTheme.of(context).background),
      ),
      Positioned(
        top: 0,
        left: 0,
        right: 0,
        height: 710,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                CinemaTheme.of(context).accent.withValues(alpha: 0.22),
                CinemaTheme.of(context).background,
                CinemaTheme.of(context).background,
              ],
            ),
          ),
        ),
      ),
      SafeArea(
        bottom: false,
        child: CustomScrollView(
          key: const PageStorageKey('netflix-cinema-home'),
          controller: state._scroll,
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            CupertinoSliverRefreshControl(onRefresh: state.widget.onRefresh),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 12, 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: CinemaPressable(
                          label: 'Appearance',
                          onPressed: state._appearance,
                          child: Text(
                            'MOONFIN',
                            style: CinemaStyle.text(
                              context,
                              MobileCinemaMode.netflix,
                              30,
                              spacing: 1.2,
                              color: CinemaTheme.of(context).accent,
                              weight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                    CinemaIconButton(
                      icon: CinemaGlyph.search,
                      label: state.labels.search,
                      onPressed: state.widget.onSearch,
                    ),
                    CinemaPressable(
                      label: state.labels.profile,
                      onPressed: state.widget.onProfile,
                      child: const Padding(
                        padding: EdgeInsets.all(8),
                        child: CinemaAvatar(size: 28),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(child: state._categoryPicker(apple: false)),
            if (feed.featured.isNotEmpty)
              SliverToBoxAdapter(
                child: _NetflixFeatured(
                  key: ValueKey(state._category),
                  state: state,
                  items: feed.featured,
                ),
              ),
            if (feed.rails.isEmpty) state._empty() else state._rows(feed),
            SliverToBoxAdapter(
              child: SizedBox(height: state.widget.bottomPadding),
            ),
          ],
        ),
      ),
    ],
  );
}

class _NetflixFeatured extends StatelessWidget {
  const _NetflixFeatured({super.key, required this.state, required this.items});
  final _MobileCinemaHomeState state;
  final List<MobileMedia> items;
  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.textScalerOf(context).scale(1);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 25),
      child: SizedBox(
        height: 477 + (scale - 1).clamp(0, 2) * 165,
        child: PageView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(9),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CinemaPressable(
                      label: '${item.title}, ${state.labels.details}',
                      onPressed: () => state.widget.onOpen(item),
                      child: _Artwork(
                        url: item.posterUrl ?? item.backdropUrl,
                        builder: state.widget.artworkBuilder,
                      ),
                    ),
                    const IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: [0, .4, .73, 1],
                            colors: [
                              Color(0x00000000),
                              Color(0x00000000),
                              Color(0x99221812),
                              Color(0xFF221812),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: CinemaIconButton(
                        icon: CinemaGlyph.info,
                        label: state.labels.details,
                        background: const Color(0x66000000),
                        size: 21,
                        onPressed: () => state.widget.onOpen(item),
                      ),
                    ),
                    Positioned(
                      left: 15,
                      right: 15,
                      bottom: 17,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _TitleArt(
                            item: item,
                            mode: MobileCinemaMode.netflix,
                            artworkBuilder: state.widget.artworkBuilder,
                          ),
                          const SizedBox(height: 15),
                          Text(
                            item.metadata,
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: CinemaStyle.text(
                              context,
                              MobileCinemaMode.netflix,
                              12,
                              color: const Color(0xFFF0EAE5),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              Expanded(
                                child: CinemaButton(
                                  mode: MobileCinemaMode.netflix,
                                  label: item.canPlay
                                      ? item.progress > 0
                                            ? state.labels.resume
                                            : 'Play'
                                      : state.labels.details,
                                  icon: item.canPlay
                                      ? CinemaGlyph.play
                                      : CinemaGlyph.info,
                                  onPressed: () => item.canPlay
                                      ? state.widget.onPlay(item)
                                      : state.widget.onOpen(item),
                                ),
                              ),
                              if (state.widget.onSave != null &&
                                  item.canSave) ...[
                                const SizedBox(width: 9),
                                Expanded(
                                  child: CinemaButton(
                                    mode: MobileCinemaMode.netflix,
                                    primary: false,
                                    label: 'My List',
                                    selected: state._isSaved(item),
                                    icon: state._isSaved(item)
                                        ? CinemaGlyph.check
                                        : CinemaGlyph.plus,
                                    onPressed: state._saving.contains(item.id)
                                        ? null
                                        : () => state._toggleSave(item),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

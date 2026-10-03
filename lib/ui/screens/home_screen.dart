import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../data/mock_video_library.dart';
import '../../models/local_video.dart';
import '../widgets/ambient_background.dart';
import '../widgets/empty_library_view.dart';
import '../widgets/hero_video_card.dart';
import '../widgets/home_skeleton_loader.dart';
import '../widgets/home_top_bar.dart';
import '../widgets/library_filter_row.dart';
import '../widgets/pichi_bottom_nav.dart';
import '../widgets/section_header.dart';
import '../widgets/video_context_menu_sheet.dart';
import '../widgets/video_thumbnail_card.dart';
import 'folders_screen.dart';
import 'library_screen.dart';
import 'player_screen.dart';
import 'search_screen.dart';
import 'settings_screen.dart';
import 'video_details_screen.dart';

/// The official Home Screen for PIchiPlayer.
/// An offline-first personal media library adhering strictly to the
/// dark cinematic visual system with electric blue and subtle violet accents.
class HomeScreen extends StatefulWidget {
  final bool initialLoading;
  final bool isEmptyLibrary;

  const HomeScreen({
    super.key,
    this.initialLoading = false,
    this.isEmptyLibrary = false,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final ScrollController _scrollController;
  double _scrollOffset = 0.0;

  NavDestination _currentDestination = NavDestination.home;
  late bool _isLoading;
  late List<LocalVideo> _allVideos;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    _isLoading = widget.initialLoading;
    _allVideos = widget.isEmptyLibrary ? [] : MockVideoLibrary.sampleVideos;

    // If initialLoading was requested, simulate a brief smooth load
    if (_isLoading) {
      Future.delayed(const Duration(milliseconds: 900), () {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _allVideos = MockVideoLibrary.sampleVideos;
          });
        }
      });
    }
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _handleVideoPlay(LocalVideo video) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, anim, __) => PlayerScreen(video: video),
        transitionDuration: const Duration(milliseconds: 250),
        transitionsBuilder: (context, anim, _, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  void _handleVideoLongPress(LocalVideo video) {
    VideoContextMenuSheet.show(
      context,
      video: video,
      onPlay: () => _handleVideoPlay(video),
      onDetails: () {
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (_, anim, __) => VideoDetailsScreen(video: video),
            transitionDuration: const Duration(milliseconds: 240),
            transitionsBuilder: (context, anim, _, child) =>
                FadeTransition(opacity: anim, child: child),
          ),
        );
      },
      onDelete: () {
        setState(() {
          _allVideos.removeWhere((v) => v.id == video.id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.surface,
            content: Text('${video.title} removed from library view'),
          ),
        );
      },
    );
  }

  void _handleSearch() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, anim, _) => const SearchScreen(),
        transitionDuration: const Duration(milliseconds: 240),
        transitionsBuilder: (context, anim, _, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  void _handleSettings() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, anim, _) => const SettingsScreen(),
        transitionDuration: const Duration(milliseconds: 240),
        transitionsBuilder: (context, anim, _, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    final continueWatching = MockVideoLibrary.getContinueWatchingVideos(_allVideos);
    final recentlyAdded = MockVideoLibrary.getRecentlyAddedVideos(_allVideos);
    final highQuality = MockVideoLibrary.getHighQualityVideos(_allVideos);

    final hasVideos = _allVideos.isNotEmpty;
    final featuredVideo = hasVideos ? MockVideoLibrary.getFeaturedVideo(_allVideos) : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AmbientBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // 1. Top App Bar (PIchiPlayer + Dynamic Greeting + Search & Settings)
              HomeTopBar(
                scrollOffset: _scrollOffset,
                onSearchTap: _handleSearch,
                onSettingsTap: _handleSettings,
              ),

              // 2. Main Scrollable Content Area
              Expanded(
                child: _isLoading
                    ? const HomeSkeletonLoader()
                    : !hasVideos
                        ? EmptyLibraryView(
                            onScanStorage: () {
                              setState(() {
                                _isLoading = true;
                              });
                              Future.delayed(const Duration(milliseconds: 800), () {
                                if (mounted) {
                                  setState(() {
                                    _isLoading = false;
                                    _allVideos = MockVideoLibrary.sampleVideos;
                                  });
                                }
                              });
                            },
                            onChooseFolder: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  backgroundColor: AppColors.surface,
                                  content: Text('Folder selection opened'),
                                ),
                              );
                            },
                          )
                        : SingleChildScrollView(
                            controller: _scrollController,
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.only(bottom: 24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 12),

                                // 2A. Featured / Continue Hero Card
                                if (featuredVideo != null)
                                  HeroVideoCard(
                                    video: featuredVideo,
                                    onTap: () => _handleVideoPlay(featuredVideo),
                                  ),

                                const SizedBox(height: 28),

                                // 2B. Continue Watching Section (Only shown when partially watched exist)
                                if (continueWatching.isNotEmpty) ...[
                                  SectionHeader(
                                    title: 'Continue Watching',
                                    actionText: 'View all',
                                    onActionTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => const LibraryScreen(
                                            initialFilter: LibraryFilter.all,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 14),
                                  SizedBox(
                                    height: AppDimensions.videoCardThumbnailHeight + 52,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      physics: const BouncingScrollPhysics(),
                                      padding: AppDimensions.homeHorizontalPadding,
                                      itemCount: continueWatching.length,
                                      itemBuilder: (context, index) {
                                        final video = continueWatching[index];
                                        return VideoThumbnailCard(
                                          video: video,
                                          showProgress: true,
                                          onTap: () => _handleVideoPlay(video),
                                          onLongPress: () => _handleVideoLongPress(video),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                ],

                                // 2C. Recently Added Section
                                if (recentlyAdded.isNotEmpty) ...[
                                  SectionHeader(
                                    title: 'Recently Added',
                                    actionText: 'View all',
                                    onActionTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => const LibraryScreen(
                                            initialFilter: LibraryFilter.recent,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 14),
                                  SizedBox(
                                    height: AppDimensions.videoCardThumbnailHeight + 50,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      physics: const BouncingScrollPhysics(),
                                      padding: AppDimensions.homeHorizontalPadding,
                                      itemCount: recentlyAdded.length,
                                      itemBuilder: (context, index) {
                                        final video = recentlyAdded[index];
                                        return VideoThumbnailCard(
                                          video: video,
                                          showProgress: false,
                                          onTap: () => _handleVideoPlay(video),
                                          onLongPress: () => _handleVideoLongPress(video),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                ],

                                // 2D. 4K & High Quality Section
                                if (highQuality.isNotEmpty) ...[
                                  SectionHeader(
                                    title: '4K & High Quality',
                                    actionText: 'See all',
                                    onActionTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => const LibraryScreen(
                                            initialFilter: LibraryFilter.fourK,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 14),
                                  SizedBox(
                                    height: AppDimensions.videoCardThumbnailHeight + 50,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      physics: const BouncingScrollPhysics(),
                                      padding: AppDimensions.homeHorizontalPadding,
                                      itemCount: highQuality.length,
                                      itemBuilder: (context, index) {
                                        final video = highQuality[index];
                                        return VideoThumbnailCard(
                                          video: video,
                                          showProgress: false,
                                          showQualityBadges: true,
                                          onTap: () => _handleVideoPlay(video),
                                          onLongPress: () => _handleVideoLongPress(video),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
              ),

              // 3. Fixed Bottom Navigation Bar
              PichiBottomNav(
                currentDestination: _currentDestination,
                onDestinationSelected: (dest) {
                  if (dest == NavDestination.library) {
                    Navigator.of(context).pushReplacement(
                      PageRouteBuilder(
                        pageBuilder: (context, _, __) => const LibraryScreen(),
                        transitionDuration: const Duration(milliseconds: 300),
                        transitionsBuilder: (context, anim, _, child) =>
                            FadeTransition(opacity: anim, child: child),
                      ),
                    );
                  } else if (dest == NavDestination.folders) {
                    Navigator.of(context).pushReplacement(
                      PageRouteBuilder(
                        pageBuilder: (context, _, __) => const FoldersScreen(),
                        transitionDuration: const Duration(milliseconds: 300),
                        transitionsBuilder: (context, anim, _, child) =>
                            FadeTransition(opacity: anim, child: child),
                      ),
                    );
                  } else {
                    setState(() {
                      _currentDestination = dest;
                    });
                    if (dest != NavDestination.home) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AppColors.surface,
                          duration: const Duration(seconds: 1),
                          content: Text('${dest.name.toUpperCase()} tab selected'),
                        ),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}


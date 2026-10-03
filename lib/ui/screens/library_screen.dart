import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../data/mock_video_library.dart';
import '../../models/local_video.dart';
import '../widgets/ambient_background.dart';
import '../widgets/empty_library_view.dart';
import '../widgets/library_context_menu_sheet.dart';
import '../widgets/library_filter_row.dart';
import '../widgets/library_grid_card.dart';
import '../widgets/library_list_tile.dart';
import '../widgets/library_skeleton_loader.dart';
import '../widgets/library_sort_toolbar.dart';
import '../widgets/library_top_bar.dart';
import '../widgets/pichi_bottom_nav.dart';
import '../widgets/sort_bottom_sheet.dart';
import 'folders_screen.dart';
import 'home_screen.dart';
import 'player_screen.dart';
import 'video_details_screen.dart';

/// The official Library Screen for PIchiPlayer.
/// High-performance local video media browser with 2-column grid and list modes,
/// real-time in-line search, multi-selection toolbar, and advanced filtering.
class LibraryScreen extends StatefulWidget {
  final bool initialLoading;
  final bool isEmptyLibrary;
  final LibraryFilter initialFilter;
  final bool enableBackgroundAnimation;

  const LibraryScreen({
    super.key,
    this.initialLoading = false,
    this.isEmptyLibrary = false,
    this.initialFilter = LibraryFilter.all,
    this.enableBackgroundAnimation = true,
  });

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  late List<LocalVideo> _allVideos;
  late bool _isLoading;

  // View & Filter States
  LibraryViewMode _viewMode = LibraryViewMode.grid;
  late LibraryFilter _activeFilter;
  LibrarySort _currentSort = LibrarySort.recent;
  bool _isAscending = false;

  // Search State
  bool _isSearchActive = false;
  String _searchQuery = '';

  // Multi-Selection State
  bool _isSelectionMode = false;
  final Set<String> _selectedVideoIds = {};

  NavDestination _currentDestination = NavDestination.library;

  @override
  void initState() {
    super.initState();
    _isLoading = widget.initialLoading;
    _activeFilter = widget.initialFilter;
    _allVideos = widget.isEmptyLibrary ? [] : List<LocalVideo>.from(MockVideoLibrary.sampleVideos);

    if (_isLoading) {
      Future.delayed(const Duration(milliseconds: 700), () {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _allVideos = List<LocalVideo>.from(MockVideoLibrary.sampleVideos);
          });
        }
      });
    }
  }

  // Filter & Sort Pipeline
  List<LocalVideo> get _processedVideos {
    List<LocalVideo> list = List<LocalVideo>.from(_allVideos);

    // 1. Filter by category
    switch (_activeFilter) {
      case LibraryFilter.all:
        break;
      case LibraryFilter.recent:
        list.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
        break;
      case LibraryFilter.favorites:
        list = list.where((v) => v.isFavorite).toList();
        break;
      case LibraryFilter.fourK:
        list = list.where((v) => v.resolution == '4K').toList();
        break;
      case LibraryFilter.hdr:
        list = list.where((v) => v.isHdr).toList();
        break;
      case LibraryFilter.unwatched:
        list = list.where((v) => v.isUnwatched).toList();
        break;
    }

    // 2. Filter by search query
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      list = list.where((v) {
        return v.displayFileName.toLowerCase().contains(q) ||
            v.title.toLowerCase().contains(q) ||
            v.folderPath.toLowerCase().contains(q);
      }).toList();
    }

    // 3. Sort
    list.sort((a, b) {
      int cmp = 0;
      switch (_currentSort) {
        case LibrarySort.recent:
          cmp = a.dateAdded.compareTo(b.dateAdded);
          break;
        case LibrarySort.name:
          cmp = a.displayFileName.toLowerCase().compareTo(b.displayFileName.toLowerCase());
          break;
        case LibrarySort.duration:
          cmp = a.duration.compareTo(b.duration);
          break;
        case LibrarySort.size:
          cmp = a.fileSizeBytes.compareTo(b.fileSizeBytes);
          break;
        case LibrarySort.resolution:
          cmp = a.resolution.compareTo(b.resolution);
          break;
        case LibrarySort.dateModified:
          cmp = a.effectiveDateModified.compareTo(b.effectiveDateModified);
          break;
      }
      return _isAscending ? cmp : -cmp;
    });

    return list;
  }

  void _handleVideoPlay(LocalVideo video) {
    if (_isSelectionMode) {
      _toggleItemSelection(video.id);
      return;
    }

    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, anim, __) => PlayerScreen(video: video),
        transitionDuration: const Duration(milliseconds: 250),
        transitionsBuilder: (context, anim, _, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  void _openContextMenu(LocalVideo video) {
    LibraryContextMenuSheet.show(
      context,
      video: video,
      onPlay: () => _handleVideoPlay(video),
      onResume: video.isPartiallyWatched ? () => _handleVideoPlay(video) : null,
      onToggleFavorite: () {
        setState(() {
          final idx = _allVideos.indexWhere((v) => v.id == video.id);
          if (idx != -1) {
            _allVideos[idx] = _allVideos[idx].copyWith(isFavorite: !_allVideos[idx].isFavorite);
          }
        });
      },
      onAddToPlaylist: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.surface,
            content: Text('Added "${video.title}" to offline playlist'),
          ),
        );
      },
      onVideoInfo: () {
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (_, anim, __) => VideoDetailsScreen(video: video),
            transitionDuration: const Duration(milliseconds: 240),
            transitionsBuilder: (context, anim, _, child) =>
                FadeTransition(opacity: anim, child: child),
          ),
        );
      },
      onOpenFolder: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.surface,
            content: Text('Storage Location: ${video.folderPath}'),
          ),
        );
      },
      onRename: (newName) {
        setState(() {
          final idx = _allVideos.indexWhere((v) => v.id == video.id);
          if (idx != -1) {
            final ext = video.displayFileName.contains('.')
                ? '.${video.displayFileName.split('.').last}'
                : '.mkv';
            final formatted = newName.endsWith(ext) ? newName : '$newName$ext';
            _allVideos[idx] = _allVideos[idx].copyWith(title: newName, fileName: formatted);
          }
        });
      },
      onDelete: () {
        setState(() {
          _allVideos.removeWhere((v) => v.id == video.id);
          _selectedVideoIds.remove(video.id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.surface,
            content: Text('Deleted "${video.displayFileName}" from device'),
          ),
        );
      },
    );
  }

  void _toggleItemSelection(String videoId) {
    setState(() {
      if (_selectedVideoIds.contains(videoId)) {
        _selectedVideoIds.remove(videoId);
        if (_selectedVideoIds.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedVideoIds.add(videoId);
      }
    });
  }

  void _enterSelectionModeWith(String videoId) {
    setState(() {
      _isSelectionMode = true;
      _selectedVideoIds.add(videoId);
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedVideoIds.clear();
    });
  }

  void _selectAll() {
    setState(() {
      final currentList = _processedVideos;
      if (_selectedVideoIds.length == currentList.length) {
        _selectedVideoIds.clear();
        _isSelectionMode = false;
      } else {
        _selectedVideoIds.addAll(currentList.map((v) => v.id));
      }
    });
  }

  void _favoriteSelected() {
    setState(() {
      for (int i = 0; i < _allVideos.length; i++) {
        if (_selectedVideoIds.contains(_allVideos[i].id)) {
          _allVideos[i] = _allVideos[i].copyWith(isFavorite: true);
        }
      }
    });
    final count = _selectedVideoIds.length;
    _exitSelectionMode();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.surface,
        content: Text('$count ${count == 1 ? "video" : "videos"} added to Favorites'),
      ),
    );
  }

  void _deleteSelected() {
    final count = _selectedVideoIds.length;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.glassBorderSubtle),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 22),
            SizedBox(width: 8),
            Text('Delete Selected?', style: TextStyle(color: AppColors.textPrimary, fontSize: 18)),
          ],
        ),
        content: Text(
          'Permanently delete $count selected ${count == 1 ? "video" : "videos"} from your device? This cannot be undone.',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _allVideos.removeWhere((v) => _selectedVideoIds.contains(v.id));
                _exitSelectionMode();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AppColors.surface,
                  content: Text('Deleted $count ${count == 1 ? "video" : "videos"}'),
                ),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _openSortSheet() {
    SortBottomSheet.show(
      context,
      currentSort: _currentSort,
      isAscending: _isAscending,
      onSortSelected: (sort) {
        setState(() {
          _currentSort = sort;
        });
      },
      onToggleOrder: () {
        setState(() {
          _isAscending = !_isAscending;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayedVideos = _processedVideos;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AmbientBackground(
        enableAnimation: widget.enableBackgroundAnimation,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // 1. Library Top App Bar (Supports Standard, Search, and Multi-select)
              LibraryTopBar(
                totalCount: _allVideos.length,
                viewMode: _viewMode,
                onViewModeChanged: (mode) {
                  setState(() {
                    _viewMode = mode;
                  });
                },
                isSearchActive: _isSearchActive,
                searchQuery: _searchQuery,
                onSearchQueryChanged: (q) {
                  setState(() {
                    _searchQuery = q;
                  });
                },
                onOpenSearch: () {
                  setState(() {
                    _isSearchActive = true;
                  });
                },
                onCloseSearch: () {
                  setState(() {
                    _isSearchActive = false;
                    _searchQuery = '';
                  });
                },
                isSelectionMode: _isSelectionMode,
                selectedCount: _selectedVideoIds.length,
                onCancelSelection: _exitSelectionMode,
                onSelectAll: _selectAll,
                onFavoriteSelected: _favoriteSelected,
                onDeleteSelected: _deleteSelected,
              ),

              // 2. Filter Row (Chips)
              const SizedBox(height: 10),
              LibraryFilterRow(
                selectedFilter: _activeFilter,
                onFilterSelected: (filter) {
                  setState(() {
                    _activeFilter = filter;
                  });
                },
              ),

              // 3. Compact Sort Toolbar
              LibrarySortToolbar(
                currentSort: _currentSort,
                isAscending: _isAscending,
                onOpenSortSheet: _openSortSheet,
                totalCount: displayedVideos.length,
              ),

              // 4. Main Media Collection Area (Grid or List)
              Expanded(
                child: _isLoading
                    ? LibrarySkeletonLoader(viewMode: _viewMode)
                    : displayedVideos.isEmpty
                        ? EmptyLibraryView(
                            onScanStorage: () {
                              setState(() {
                                _isLoading = true;
                              });
                              Future.delayed(const Duration(milliseconds: 700), () {
                                if (mounted) {
                                  setState(() {
                                    _isLoading = false;
                                    _allVideos = List<LocalVideo>.from(MockVideoLibrary.sampleVideos);
                                    _activeFilter = LibraryFilter.all;
                                    _searchQuery = '';
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
                        : _viewMode == LibraryViewMode.grid
                            ? GridView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                                physics: const BouncingScrollPhysics(),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.86,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                ),
                                itemCount: displayedVideos.length,
                                itemBuilder: (context, index) {
                                  final video = displayedVideos[index];
                                  final isSelected = _selectedVideoIds.contains(video.id);

                                  return LibraryGridCard(
                                    video: video,
                                    isSelectionMode: _isSelectionMode,
                                    isSelected: isSelected,
                                    onTap: () => _handleVideoPlay(video),
                                    onLongPress: () {
                                      if (!_isSelectionMode) {
                                        _enterSelectionModeWith(video.id);
                                      } else {
                                        _toggleItemSelection(video.id);
                                      }
                                    },
                                    onMoreTap: () => _openContextMenu(video),
                                  );
                                },
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(vertical: 6.0),
                                physics: const BouncingScrollPhysics(),
                                itemCount: displayedVideos.length,
                                itemBuilder: (context, index) {
                                  final video = displayedVideos[index];
                                  final isSelected = _selectedVideoIds.contains(video.id);

                                  return LibraryListTile(
                                    video: video,
                                    isSelectionMode: _isSelectionMode,
                                    isSelected: isSelected,
                                    onTap: () => _handleVideoPlay(video),
                                    onLongPress: () {
                                      if (!_isSelectionMode) {
                                        _enterSelectionModeWith(video.id);
                                      } else {
                                        _toggleItemSelection(video.id);
                                      }
                                    },
                                    onMoreTap: () => _openContextMenu(video),
                                  );
                                },
                              ),
              ),

              // 5. Fixed Bottom Navigation Bar (Library selected)
              PichiBottomNav(
                currentDestination: _currentDestination,
                onDestinationSelected: (dest) {
                  if (dest == NavDestination.home) {
                    Navigator.of(context).pushReplacement(
                      PageRouteBuilder(
                        pageBuilder: (context, _, __) => const HomeScreen(),
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
                    if (dest != NavDestination.library) {
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

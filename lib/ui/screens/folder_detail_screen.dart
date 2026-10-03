import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../data/mock_folder_data.dart';
import '../../models/local_folder.dart';
import '../../models/local_video.dart';
import '../widgets/ambient_background.dart';
import '../widgets/folder_empty_view.dart';
import '../widgets/library_context_menu_sheet.dart';
import '../widgets/library_filter_row.dart';
import '../widgets/library_grid_card.dart';
import '../widgets/library_list_tile.dart';
import '../widgets/library_sort_toolbar.dart';
import '../widgets/library_top_bar.dart';
import '../widgets/sort_bottom_sheet.dart';

/// Folder-specific media browser screen for browsing videos inside a single directory
class FolderDetailScreen extends StatefulWidget {
  final LocalFolder folder;
  final bool enableBackgroundAnimation;

  const FolderDetailScreen({
    super.key,
    required this.folder,
    this.enableBackgroundAnimation = true,
  });

  @override
  State<FolderDetailScreen> createState() => _FolderDetailScreenState();
}

class _FolderDetailScreenState extends State<FolderDetailScreen> {
  late List<LocalVideo> _folderVideos;
  LibraryViewMode _viewMode = LibraryViewMode.grid;
  LibraryFilter _activeFilter = LibraryFilter.all;
  LibrarySort _currentSort = LibrarySort.recent;
  bool _isAscending = false;

  // In-line Search
  bool _isSearchActive = false;
  String _searchQuery = '';

  // Multi-selection
  bool _isSelectionMode = false;
  final Set<String> _selectedVideoIds = {};

  @override
  void initState() {
    super.initState();
    _folderVideos = MockFolderData.getVideosForFolder(widget.folder);
  }

  List<LocalVideo> get _processedVideos {
    List<LocalVideo> list = List<LocalVideo>.from(_folderVideos);

    // 1. Filter
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

    // 2. Search query
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      list = list.where((v) {
        return v.displayFileName.toLowerCase().contains(q) ||
            v.title.toLowerCase().contains(q);
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
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.surface,
        behavior: SnackBarBehavior.floating,
        content: Row(
          children: [
            const Icon(Icons.play_circle_fill_rounded, color: AppColors.electricBlueBright),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Playing ${video.displayFileName}',
                style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
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
          final idx = _folderVideos.indexWhere((v) => v.id == video.id);
          if (idx != -1) {
            _folderVideos[idx] = _folderVideos[idx].copyWith(isFavorite: !_folderVideos[idx].isFavorite);
          }
        });
      },
      onAddToPlaylist: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.surface,
            content: Text('Added "${video.title}" to playlist'),
          ),
        );
      },
      onVideoInfo: () => _showTechnicalInfoDialog(video),
      onOpenFolder: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.surface,
            content: Text('Directory: ${widget.folder.path}'),
          ),
        );
      },
      onRename: (newName) {
        setState(() {
          final idx = _folderVideos.indexWhere((v) => v.id == video.id);
          if (idx != -1) {
            final ext = video.displayFileName.contains('.')
                ? '.${video.displayFileName.split('.').last}'
                : '.mkv';
            final formatted = newName.endsWith(ext) ? newName : '$newName$ext';
            _folderVideos[idx] = _folderVideos[idx].copyWith(title: newName, fileName: formatted);
          }
        });
      },
      onDelete: () {
        setState(() {
          _folderVideos.removeWhere((v) => v.id == video.id);
          _selectedVideoIds.remove(video.id);
        });
      },
    );
  }

  void _showTechnicalInfoDialog(LocalVideo video) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.glassBorderSubtle),
        ),
        title: Text(video.displayFileName, style: const TextStyle(color: AppColors.textPrimary, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildInfoRow('Path', widget.folder.path),
            _buildInfoRow('Resolution', video.resolution),
            _buildInfoRow('Codec', video.codec),
            _buildInfoRow('Duration', video.durationFormatted),
            _buildInfoRow('Size', video.fileSizeFormatted),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close', style: TextStyle(color: AppColors.electricBlueBright)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(width: 80, child: Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 12))),
          Expanded(child: Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  void _toggleItemSelection(String videoId) {
    setState(() {
      if (_selectedVideoIds.contains(videoId)) {
        _selectedVideoIds.remove(videoId);
        if (_selectedVideoIds.isEmpty) _isSelectionMode = false;
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

  void _deleteSelected() {
    setState(() {
      _folderVideos.removeWhere((v) => _selectedVideoIds.contains(v.id));
      _exitSelectionMode();
    });
  }

  void _openSortSheet() {
    SortBottomSheet.show(
      context,
      currentSort: _currentSort,
      isAscending: _isAscending,
      onSortSelected: (s) => setState(() => _currentSort = s),
      onToggleOrder: () => setState(() => _isAscending = !_isAscending),
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
              // 1. Header with back affordance and folder information
              _buildFolderHeader(),

              // 2. Filter row
              const SizedBox(height: 8),
              LibraryFilterRow(
                selectedFilter: _activeFilter,
                onFilterSelected: (f) => setState(() => _activeFilter = f),
              ),

              // 3. Compact Sort Toolbar
              LibrarySortToolbar(
                currentSort: _currentSort,
                isAscending: _isAscending,
                onOpenSortSheet: _openSortSheet,
                totalCount: displayedVideos.length,
              ),

              // 4. Video Content Area
              Expanded(
                child: displayedVideos.isEmpty
                    ? FolderEmptyView(
                        onRescanFolder: () {
                          setState(() {
                            _folderVideos = MockFolderData.getVideosForFolder(widget.folder);
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: AppColors.surface,
                              content: Text('Rescanned ${widget.folder.name}'),
                            ),
                          );
                        },
                        onChooseAnotherFolder: () => Navigator.pop(context),
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
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                            physics: const BouncingScrollPhysics(),
                            itemCount: displayedVideos.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 8),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFolderHeader() {
    if (_isSelectionMode) {
      return Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        decoration: const BoxDecoration(
          color: AppColors.surfaceGlass,
          border: Border(bottom: BorderSide(color: AppColors.glassBorderSubtle, width: 0.8)),
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary),
              onPressed: _exitSelectionMode,
            ),
            const SizedBox(width: 8),
            Text(
              '${_selectedVideoIds.length} selected',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.select_all_rounded, color: AppColors.textSecondary),
              tooltip: 'Select All',
              onPressed: _selectAll,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444)),
              tooltip: 'Delete',
              onPressed: _deleteSelected,
            ),
          ],
        ),
      );
    }

    if (_isSearchActive) {
      return Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        decoration: const BoxDecoration(
          color: AppColors.surfaceGlass,
          border: Border(bottom: BorderSide(color: AppColors.glassBorderSubtle, width: 0.8)),
        ),
        child: Row(
          children: [
            const Icon(Icons.search_rounded, color: AppColors.electricBlueBright, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                autofocus: true,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
                decoration: const InputDecoration(
                  hintText: 'Search in folder...',
                  hintStyle: TextStyle(color: AppColors.textMuted),
                  border: InputBorder.none,
                ),
                onChanged: (val) => setState(() => _searchQuery = val),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary, size: 20),
              onPressed: () => setState(() {
                _isSearchActive = false;
                _searchQuery = '';
              }),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Row(
        children: [
          // Back Button
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
          const SizedBox(width: 8),

          // Folder Title & Metadata (e.g. Movies / 245 videos • 18.7 GB)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.folder.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  widget.folder.metadataSummary,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Right Icons: Search & Grid/List Toggle
          IconButton(
            icon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
            onPressed: () => setState(() => _isSearchActive = true),
          ),
          IconButton(
            icon: Icon(
              _viewMode == LibraryViewMode.grid
                  ? Icons.view_list_rounded
                  : Icons.grid_view_rounded,
              color: AppColors.textSecondary,
            ),
            onPressed: () {
              setState(() {
                _viewMode = _viewMode == LibraryViewMode.grid
                    ? LibraryViewMode.list
                    : LibraryViewMode.grid;
              });
            },
          ),
        ],
      ),
    );
  }
}

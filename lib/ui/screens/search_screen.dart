import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../data/mock_video_library.dart';
import '../../models/local_video.dart';
import '../../services/search_history_service.dart';
import '../widgets/ambient_background.dart';
import '../widgets/library_context_menu_sheet.dart';
import '../widgets/library_grid_card.dart';
import '../widgets/search_filter_row.dart';

/// The official Search screen for PIchiPlayer.
/// Offline-only, zero-latency local video search with smart matching,
/// recent search history, fuzzy typo suggestions, and library filters.
class SearchScreen extends StatefulWidget {
  final String? initialQuery;
  final bool enableBackgroundAnimation;

  const SearchScreen({
    super.key,
    this.initialQuery,
    this.enableBackgroundAnimation = true,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final TextEditingController _searchController;
  late final FocusNode _focusNode;

  SearchFilter _selectedFilter = SearchFilter.all;
  String _currentQuery = '';
  List<String> _recentSearches = [];

  @override
  void initState() {
    super.initState();
    _currentQuery = widget.initialQuery ?? '';
    _searchController = TextEditingController(text: _currentQuery);
    _focusNode = FocusNode();

    _recentSearches = SearchHistoryService.getRecentSearches();

    // Auto-focus the search field immediately and open the keyboard
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onQueryChanged(String query) {
    setState(() {
      _currentQuery = query;
    });
  }

  void _submitQuery(String query) {
    if (query.trim().isNotEmpty) {
      SearchHistoryService.addSearch(query.trim());
      setState(() {
        _recentSearches = SearchHistoryService.getRecentSearches();
      });
    }
  }

  void _selectSearchTerm(String term) {
    _searchController.text = term;
    _searchController.selection = TextSelection.fromPosition(
      TextPosition(offset: term.length),
    );
    setState(() {
      _currentQuery = term;
    });
    _submitQuery(term);
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _currentQuery = '';
    });
    _focusNode.requestFocus();
  }

  void _removeRecentSearch(String term) {
    SearchHistoryService.removeSearch(term);
    setState(() {
      _recentSearches = SearchHistoryService.getRecentSearches();
    });
  }

  void _clearAllHistory() {
    SearchHistoryService.clearHistory();
    setState(() {
      _recentSearches = [];
    });
  }

  // Filter & Search Pipeline
  List<LocalVideo> get _matchingVideos {
    final allVideos = MockVideoLibrary.sampleVideos;
    if (_currentQuery.trim().isEmpty) {
      return [];
    }

    final q = _currentQuery.trim();

    // 1. Local Search Matching across title, filename, and folder path
    List<LocalVideo> results = allVideos.where((v) {
      return SearchHistoryService.matches(q, v.displayFileName) ||
          SearchHistoryService.matches(q, v.title) ||
          SearchHistoryService.matches(q, v.folderPath);
    }).toList();

    // 2. Filter chips
    switch (_selectedFilter) {
      case SearchFilter.all:
        break;
      case SearchFilter.fourK:
        results = results.where((v) => v.resolution == '4K').toList();
        break;
      case SearchFilter.tenEightyP:
        results = results.where((v) => v.resolution == '1080p').toList();
        break;
      case SearchFilter.sevenTwentyP:
        results = results.where((v) => v.resolution == '720p').toList();
        break;
      case SearchFilter.hdr:
        results = results.where((v) => v.isHdr).toList();
        break;
      case SearchFilter.favorites:
        results = results.where((v) => v.isFavorite).toList();
        break;
    }

    return results;
  }

  // Fuzzy suggestion when 0 results found
  String? get _fuzzySuggestion {
    if (_currentQuery.trim().length < 3) return null;
    final allTitles = MockVideoLibrary.sampleVideos.map((v) => v.title).toList();
    return SearchHistoryService.findFuzzySuggestion(_currentQuery, allTitles);
  }

  void _handleVideoPlay(LocalVideo video) {
    _focusNode.unfocus();
    _submitQuery(_currentQuery);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.surface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.glassBorderSubtle),
        ),
        content: Row(
          children: [
            const Icon(
              Icons.play_circle_fill_rounded,
              color: AppColors.electricBlueBright,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    video.displayFileName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Playing from local storage • ${video.resolution} • ${video.codec}',
                    style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openContextMenu(LocalVideo video) {
    _focusNode.unfocus();
    LibraryContextMenuSheet.show(
      context,
      video: video,
      onPlay: () => _handleVideoPlay(video),
      onResume: video.isPartiallyWatched ? () => _handleVideoPlay(video) : null,
      onToggleFavorite: () {},
      onAddToPlaylist: () {},
      onVideoInfo: () {},
      onOpenFolder: () {},
      onRename: (_) {},
      onDelete: () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    final queryText = _currentQuery.trim();
    final isQueryEmpty = queryText.isEmpty;
    final results = _matchingVideos;
    final fuzzySuggestion = isQueryEmpty ? null : _fuzzySuggestion;

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      body: AmbientBackground(
        enableAnimation: widget.enableBackgroundAnimation,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // 1. Top Search Bar
              _buildSearchBar(),

              // 2. Body Area (Recent Searches / Live Results / Empty / No-Results)
              Expanded(
                child: isQueryEmpty
                    ? _buildEmptyOrRecentView()
                    : results.isEmpty
                        ? _buildNoResultsView(fuzzySuggestion)
                        : _buildResultsView(results),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Top Search Bar ---
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: AppColors.surfaceGlass,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _focusNode.hasFocus
                ? AppColors.electricBlue.withOpacity(0.60)
                : AppColors.glassBorderSubtle,
            width: 0.9,
          ),
          boxShadow: [
            BoxShadow(
              color: _focusNode.hasFocus
                  ? AppColors.electricBlue.withOpacity(0.12)
                  : Colors.black.withOpacity(0.20),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Back Button
            IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary, size: 22),
              onPressed: () {
                _focusNode.unfocus();
                Navigator.pop(context);
              },
              tooltip: 'Back',
            ),

            // Search Icon (Electric Blue)
            const Icon(
              Icons.search_rounded,
              color: AppColors.electricBlueBright,
              size: 20,
            ),
            const SizedBox(width: 10),

            // Search Text Field
            Expanded(
              child: TextField(
                controller: _searchController,
                focusNode: _focusNode,
                autofocus: true,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                decoration: const InputDecoration(
                  hintText: 'Search videos...',
                  hintStyle: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 14.5,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                textInputAction: TextInputAction.search,
                onChanged: _onQueryChanged,
                onSubmitted: (value) {
                  _submitQuery(value);
                  _focusNode.unfocus();
                },
              ),
            ),

            // Clear / X button when query is not empty
            if (_currentQuery.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary, size: 18),
                onPressed: _clearSearch,
                tooltip: 'Clear',
              ),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }

  // --- Empty / Recent Searches View ---
  Widget _buildEmptyOrRecentView() {
    return ListView(
      physics: const BouncingScrollPhysics(),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      children: [
        if (_recentSearches.isNotEmpty) ...[
          // Recent Searches Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 6.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent searches',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.2,
                  ),
                ),
                GestureDetector(
                  onTap: _clearAllHistory,
                  child: const Text(
                    'Clear all',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // Recent Search Items
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceGlass,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.glassBorderSubtle, width: 0.8),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _recentSearches.length,
              separatorBuilder: (_, __) => const Divider(
                color: AppColors.glassBorderSubtle,
                height: 1,
                indent: 44,
              ),
              itemBuilder: (context, index) {
                final term = _recentSearches[index];
                return ListTile(
                  dense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
                  leading: const Icon(
                    Icons.history_rounded,
                    color: AppColors.textMuted,
                    size: 19,
                  ),
                  title: Text(
                    term,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.close_rounded, size: 16, color: AppColors.textMuted),
                    onPressed: () => _removeRecentSearch(term),
                  ),
                  onTap: () => _selectSearchTerm(term),
                );
              },
            ),
          ),
          const SizedBox(height: 32),
        ],

        // Calm Empty / Privacy State
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surfaceGlass,
                  border: Border.all(color: AppColors.glassBorderSubtle, width: 1.0),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.electricBlue.withOpacity(0.08),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.manage_search_rounded,
                    size: 34,
                    color: AppColors.electricBlueBright,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Search your local video library',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.lock_outline_rounded,
                    size: 13,
                    color: AppColors.electricBlueBright.withOpacity(0.85),
                  ),
                  const SizedBox(width: 5),
                  const Text(
                    'Everything stays on your device.',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- Live Results View ---
  Widget _buildResultsView(List<LocalVideo> results) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Horizontal Filter Chips (All, 4K, 1080p, 720p, HDR, Favorites)
        SearchFilterRow(
          selectedFilter: _selectedFilter,
          onFilterSelected: (f) {
            setState(() {
              _selectedFilter = f;
            });
          },
        ),

        // 2. Dynamic Result Count Header
        Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 12.0, bottom: 6.0),
          child: Row(
            children: [
              Text(
                '${results.length} ${results.length == 1 ? "result" : "results"}',
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.2,
                ),
              ),
              const Spacer(),
              Text(
                'Matching "$_currentQuery"',
                style: const TextStyle(
                  fontSize: 11.5,
                  color: AppColors.textMuted,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),

        // 3. 2-Column Video Grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
            physics: const BouncingScrollPhysics(),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.86,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: results.length,
            itemBuilder: (context, index) {
              final video = results[index];
              return LibraryGridCard(
                video: video,
                onTap: () => _handleVideoPlay(video),
                onLongPress: () => _openContextMenu(video),
                onMoreTap: () => _openContextMenu(video),
              );
            },
          ),
        ),
      ],
    );
  }

  // --- No Results View ---
  Widget _buildNoResultsView(String? fuzzySuggestion) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surfaceGlass,
                border: Border.all(color: AppColors.glassBorderSubtle, width: 1.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.30),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.videocam_off_rounded,
                  size: 36,
                  color: AppColors.textMuted,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // "No videos found"
            const Text(
              'No videos found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),

            // "We couldn't find a local video matching 'query'"
            Text(
              'We couldn\'t find a local video matching "$_currentQuery".',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),

            const Text(
              'Try another name or folder.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textMuted,
              ),
            ),

            // Optional "Did you mean [Suggestion]?"
            if (fuzzySuggestion != null) ...[
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => _selectSearchTerm(fuzzySuggestion),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.electricBlue.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: AppColors.electricBlue.withOpacity(0.35),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.auto_fix_high_rounded,
                        size: 14,
                        color: AppColors.electricBlueBright,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Did you mean $fuzzySuggestion?',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.electricBlueBright,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Clear Search action button
            ElevatedButton.icon(
              onPressed: _clearSearch,
              icon: const Icon(Icons.clear_rounded, size: 16),
              label: const Text('Clear Search'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.surfaceGlass,
                foregroundColor: AppColors.textPrimary,
                elevation: 0,
                side: const BorderSide(color: AppColors.glassBorderSubtle),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

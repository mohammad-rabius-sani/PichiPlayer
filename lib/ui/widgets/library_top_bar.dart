import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Presentation mode for Library (2-column Grid vs List)
enum LibraryViewMode { grid, list }

/// Clean, stateful Top App Bar for the Library screen.
/// Supports standard view, expanded in-line search, and selection mode.
class LibraryTopBar extends StatelessWidget {
  final int totalCount;
  final LibraryViewMode viewMode;
  final ValueChanged<LibraryViewMode> onViewModeChanged;

  // Search Mode
  final bool isSearchActive;
  final String searchQuery;
  final ValueChanged<String> onSearchQueryChanged;
  final VoidCallback onOpenSearch;
  final VoidCallback onCloseSearch;

  // Selection Mode
  final bool isSelectionMode;
  final int selectedCount;
  final VoidCallback onCancelSelection;
  final VoidCallback onSelectAll;
  final VoidCallback onFavoriteSelected;
  final VoidCallback onDeleteSelected;

  const LibraryTopBar({
    super.key,
    required this.totalCount,
    required this.viewMode,
    required this.onViewModeChanged,
    required this.isSearchActive,
    required this.searchQuery,
    required this.onSearchQueryChanged,
    required this.onOpenSearch,
    required this.onCloseSearch,
    required this.isSelectionMode,
    required this.selectedCount,
    required this.onCancelSelection,
    required this.onSelectAll,
    required this.onFavoriteSelected,
    required this.onDeleteSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        left: 16.0,
        right: 14.0,
        top: 14.0,
        bottom: 12.0,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(
            color: AppColors.glassBorderSubtle,
            width: 0.8,
          ),
        ),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        child: isSelectionMode
            ? _buildSelectionHeader(context)
            : isSearchActive
                ? _buildSearchHeader(context)
                : _buildStandardHeader(context),
      ),
    );
  }

  // 1. Standard Header (Title, Count, Search Icon, Grid/List Toggle)
  Widget _buildStandardHeader(BuildContext context) {
    return Row(
      key: const ValueKey('standard_header'),
      children: [
        // Navigation affordance if Navigator can pop
        if (Navigator.of(context).canPop()) ...[
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
            onPressed: () => Navigator.of(context).maybePop(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
          const SizedBox(width: 4),
        ],

        // Title and Video Count
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Library',
                style: AppTypography.topBarBrand,
              ),
              const SizedBox(height: 2),
              Text(
                '$totalCount ${totalCount == 1 ? "video" : "videos"}',
                style: AppTypography.greetingSubtitle,
              ),
            ],
          ),
        ),

        // Search Action
        _HeaderActionButton(
          icon: Icons.search_rounded,
          tooltip: 'Search videos',
          onTap: onOpenSearch,
        ),

        const SizedBox(width: 8),

        // Grid / List View Toggle Action
        _HeaderActionButton(
          icon: viewMode == LibraryViewMode.grid
              ? Icons.view_list_rounded
              : Icons.grid_view_rounded,
          tooltip: viewMode == LibraryViewMode.grid ? 'List View' : 'Grid View',
          onTap: () {
            onViewModeChanged(
              viewMode == LibraryViewMode.grid
                  ? LibraryViewMode.list
                  : LibraryViewMode.grid,
            );
          },
        ),
      ],
    );
  }

  // 2. In-Line Local Search Header ("Search videos...")
  Widget _buildSearchHeader(BuildContext context) {
    return Row(
      key: const ValueKey('search_header'),
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: onCloseSearch,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceGlass,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.electricBlue.withOpacity(0.4),
                width: 0.8,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.search_rounded,
                  size: 18,
                  color: AppColors.electricBlueBright,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    autofocus: true,
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 13.5),
                    decoration: const InputDecoration(
                      hintText: 'Search videos...',
                      hintStyle: TextStyle(color: AppColors.textMuted),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: onSearchQueryChanged,
                  ),
                ),
                if (searchQuery.isNotEmpty)
                  GestureDetector(
                    onTap: () => onSearchQueryChanged(''),
                    child: const Icon(Icons.close_rounded, size: 16, color: AppColors.textSecondary),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 3. Selection Mode Header ("2 selected", Select All, Favorite, Delete)
  Widget _buildSelectionHeader(BuildContext context) {
    return Row(
      key: const ValueKey('selection_header'),
      children: [
        IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary),
          onPressed: onCancelSelection,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '$selectedCount selected',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        _HeaderActionButton(
          icon: Icons.select_all_rounded,
          tooltip: 'Select All',
          onTap: onSelectAll,
        ),
        const SizedBox(width: 6),
        _HeaderActionButton(
          icon: Icons.favorite_border_rounded,
          tooltip: 'Favorite Selected',
          onTap: onFavoriteSelected,
        ),
        const SizedBox(width: 6),
        _HeaderActionButton(
          icon: Icons.delete_outline_rounded,
          tooltip: 'Delete Selected',
          iconColor: const Color(0xFFEF4444),
          onTap: onDeleteSelected,
        ),
      ],
    );
  }
}

class _HeaderActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final Color? iconColor;

  const _HeaderActionButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          splashColor: AppColors.electricBlue.withOpacity(0.2),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.surfaceGlass.withOpacity(0.5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.glassBorderSubtle,
                width: 0.8,
              ),
            ),
            child: Center(
              child: Icon(
                icon,
                size: 19,
                color: iconColor ?? AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

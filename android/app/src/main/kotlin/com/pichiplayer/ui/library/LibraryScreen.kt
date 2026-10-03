package com.pichiplayer.ui.library

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.outlined.Sort
import androidx.compose.material.icons.automirrored.outlined.ViewList
import androidx.compose.material.icons.filled.*
import androidx.compose.material.icons.outlined.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.pichiplayer.PichiPlayerApp
import com.pichiplayer.data.database.VideoEntity
import com.pichiplayer.ui.components.*
import com.pichiplayer.ui.states.EmptyLibraryState
import com.pichiplayer.ui.theme.AppColors
import com.pichiplayer.ui.theme.AppTypography
import kotlinx.coroutines.launch

enum class LibrarySortOption(val title: String) {
    DATE_ADDED_DESC("Newest Added"),
    DATE_ADDED_ASC("Oldest Added"),
    NAME_ASC("Name (A–Z)"),
    NAME_DESC("Name (Z–A)"),
    DURATION_DESC("Longest"),
    SIZE_DESC("Largest File")
}

@Composable
fun LibraryScreen(
    onPlayVideo: (VideoEntity, List<VideoEntity>) -> Unit,
    onVideoDetails: (Long) -> Unit,
    onNavigateSearch: () -> Unit,
    onSelectCustomFolder: () -> Unit,
    modifier: Modifier = Modifier
) {
    val repository = PichiPlayerApp.instance.repository
    val coroutineScope = rememberCoroutineScope()

    val allVideos by repository.allVideos.collectAsState(initial = emptyList())
    var selectedFilter by remember { mutableStateOf("All") }
    var selectedSort by remember { mutableStateOf(LibrarySortOption.DATE_ADDED_DESC) }
    var isGridView by remember { mutableStateOf(true) }
    var showSortMenu by remember { mutableStateOf(false) }

    val filters = listOf("All", "4K", "1080p", "720p", "HDR", "Favorites")

    // Filter & Sort videos in memory
    val displayedVideos = remember(allVideos, selectedFilter, selectedSort) {
        val filtered = when (selectedFilter) {
            "4K" -> allVideos.filter { it.is4K }
            "1080p" -> allVideos.filter { it.is1080p }
            "720p" -> allVideos.filter { it.is720p }
            "HDR" -> allVideos.filter { it.isHdr }
            "Favorites" -> allVideos.filter { it.isFavorite }
            else -> allVideos
        }

        when (selectedSort) {
            LibrarySortOption.DATE_ADDED_DESC -> filtered.sortedByDescending { it.dateAdded }
            LibrarySortOption.DATE_ADDED_ASC -> filtered.sortedBy { it.dateAdded }
            LibrarySortOption.NAME_ASC -> filtered.sortedBy { it.displayName.lowercase() }
            LibrarySortOption.NAME_DESC -> filtered.sortedByDescending { it.displayName.lowercase() }
            LibrarySortOption.DURATION_DESC -> filtered.sortedByDescending { it.durationMs }
            LibrarySortOption.SIZE_DESC -> filtered.sortedByDescending { it.fileSize }
        }
    }

    Box(
        modifier = modifier
            .fillMaxSize()
            .background(AppColors.background)
    ) {
        if (allVideos.isEmpty()) {
            EmptyLibraryState(
                onScanClick = { coroutineScope.launch { repository.rescan() } },
                onSelectFolderClick = onSelectCustomFolder
            )
        } else {
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .statusBarsPadding()
                    .displayCutoutPadding()
            ) {
                // Header Bar
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(horizontal = 20.dp, vertical = 12.dp),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.SpaceBetween
                ) {
                    Column {
                        Text(
                            text = "Library",
                            style = AppTypography.heroTitle
                        )
                        Text(
                            text = "${displayedVideos.size} of ${allVideos.size} videos",
                            style = AppTypography.caption.copy(color = AppColors.textSecondary)
                        )
                    }

                    Row(
                        horizontalArrangement = Arrangement.spacedBy(8.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        PichiIconButton(
                            icon = Icons.Outlined.Search,
                            contentDescription = "Search",
                            onClick = onNavigateSearch,
                            size = 38.dp
                        )
                        // Grid/List toggle
                        PichiIconButton(
                            icon = if (isGridView) Icons.AutoMirrored.Outlined.ViewList else Icons.Outlined.GridView,
                            contentDescription = "Toggle View",
                            onClick = { isGridView = !isGridView },
                            size = 38.dp
                        )
                        // Sort menu anchor
                        Box {
                            PichiIconButton(
                                icon = Icons.AutoMirrored.Outlined.Sort,
                                contentDescription = "Sort",
                                onClick = { showSortMenu = true },
                                size = 38.dp
                            )
                            DropdownMenu(
                                expanded = showSortMenu,
                                onDismissRequest = { showSortMenu = false },
                                modifier = Modifier
                                    .background(AppColors.surface)
                                    .border(1.dp, AppColors.glassBorder, RoundedCornerShape(12.dp))
                            ) {
                                LibrarySortOption.entries.forEach { option ->
                                    DropdownMenuItem(
                                        text = {
                                            Text(
                                                text = option.title,
                                                style = AppTypography.bodyMedium.copy(
                                                    color = if (option == selectedSort) AppColors.electricBlueBright else AppColors.textPrimary,
                                                    fontWeight = if (option == selectedSort) FontWeight.Bold else FontWeight.Normal
                                                )
                                            )
                                        },
                                        onClick = {
                                            selectedSort = option
                                            showSortMenu = false
                                        }
                                    )
                                }
                            }
                        }
                    }
                }

                // Filter Chips Row
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(horizontal = 20.dp, vertical = 6.dp),
                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    filters.forEach { filter ->
                        val isSelected = filter == selectedFilter
                        Box(
                            modifier = Modifier
                                .clip(RoundedCornerShape(20.dp))
                                .background(if (isSelected) AppColors.electricBlue else AppColors.surfaceSubtle)
                                .border(
                                    1.dp,
                                    if (isSelected) AppColors.electricBlueBright else AppColors.glassBorderSubtle,
                                    RoundedCornerShape(20.dp)
                                )
                                .clickable { selectedFilter = filter }
                                .padding(horizontal = 14.dp, vertical = 6.dp),
                            contentAlignment = Alignment.Center
                        ) {
                            Text(
                                text = filter,
                                style = AppTypography.caption.copy(
                                    fontWeight = if (isSelected) FontWeight.Bold else FontWeight.Medium,
                                    color = if (isSelected) Color.White else AppColors.textSecondary
                                )
                            )
                        }
                    }
                }

                Spacer(modifier = Modifier.height(10.dp))

                // Videos Display (Grid or List)
                if (isGridView) {
                    LazyVerticalGrid(
                        columns = GridCells.Fixed(2),
                        contentPadding = PaddingValues(horizontal = 16.dp, vertical = 8.dp),
                        horizontalArrangement = Arrangement.spacedBy(12.dp),
                        verticalArrangement = Arrangement.spacedBy(16.dp),
                        modifier = Modifier
                            .fillMaxSize()
                            .padding(bottom = 16.dp)
                    ) {
                        items(displayedVideos, key = { it.id }) { video ->
                            VideoGridItem(
                                video = video,
                                onClick = { onPlayVideo(video, displayedVideos) },
                                onMoreClick = { onVideoDetails(video.id) }
                            )
                        }
                    }
                } else {
                    LazyColumn(
                        contentPadding = PaddingValues(horizontal = 16.dp, vertical = 8.dp),
                        verticalArrangement = Arrangement.spacedBy(12.dp),
                        modifier = Modifier
                            .fillMaxSize()
                            .padding(bottom = 16.dp)
                    ) {
                        items(displayedVideos, key = { it.id }) { video ->
                            VideoListItem(
                                video = video,
                                onClick = { onPlayVideo(video, displayedVideos) },
                                onMoreClick = { onVideoDetails(video.id) }
                            )
                        }
                    }
                }
            }
        }
    }
}

@Composable
private fun VideoGridItem(
    video: VideoEntity,
    onClick: () -> Unit,
    onMoreClick: () -> Unit
) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(14.dp))
            .clickable(onClick = onClick)
    ) {
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(115.dp)
        ) {
            PichiVideoThumbnail(
                video = video,
                thumbnailPath = video.thumbnailPath,
                modifier = Modifier.fillMaxSize()
            )
        }

        Spacer(modifier = Modifier.height(6.dp))

        Row(
            modifier = Modifier.fillMaxWidth(),
            verticalAlignment = Alignment.Top,
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = video.displayName,
                    style = AppTypography.cardTitle.copy(fontSize = 13.5.sp),
                    maxLines = 2,
                    overflow = TextOverflow.Ellipsis
                )
                Spacer(modifier = Modifier.height(2.dp))
                Text(
                    text = "${video.formattedFileSize} • ${video.folderName}",
                    style = AppTypography.caption.copy(fontSize = 11.sp),
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )
            }

            IconButton(
                onClick = onMoreClick,
                modifier = Modifier.size(24.dp)
            ) {
                Icon(
                    imageVector = Icons.Default.MoreVert,
                    contentDescription = "Details",
                    tint = AppColors.textMuted,
                    modifier = Modifier.size(16.dp)
                )
            }
        }
    }
}

@Composable
private fun VideoListItem(
    video: VideoEntity,
    onClick: () -> Unit,
    onMoreClick: () -> Unit
) {
    PichiGlassCard(
        modifier = Modifier
            .fillMaxWidth()
            .height(86.dp),
        onClick = onClick
    ) {
        Row(
            modifier = Modifier
                .fillMaxSize()
                .padding(8.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Box(
                modifier = Modifier
                    .width(115.dp)
                    .fillMaxHeight()
            ) {
                PichiVideoThumbnail(
                    video = video,
                    thumbnailPath = video.thumbnailPath,
                    modifier = Modifier.fillMaxSize()
                )
            }

            Spacer(modifier = Modifier.width(12.dp))

            Column(
                modifier = Modifier.weight(1f),
                verticalArrangement = Arrangement.Center
            ) {
                Text(
                    text = video.displayName,
                    style = AppTypography.cardTitle.copy(fontSize = 14.sp),
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )
                Spacer(modifier = Modifier.height(4.dp))
                Text(
                    text = "${video.formattedDuration} • ${video.formattedFileSize} • ${video.folderName}",
                    style = AppTypography.caption.copy(color = AppColors.textSecondary),
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )
                if (video.watchedPercentage > 0.05f) {
                    Spacer(modifier = Modifier.height(2.dp))
                    Text(
                        text = "Watched ${video.formattedWatchedPercentage}",
                        style = AppTypography.caption.copy(
                            color = AppColors.electricBlueBright,
                            fontSize = 10.5.sp
                        )
                    )
                }
            }

            IconButton(
                onClick = onMoreClick,
                modifier = Modifier.size(36.dp)
            ) {
                Icon(
                    imageVector = Icons.Default.MoreVert,
                    contentDescription = "Details",
                    tint = AppColors.textMuted,
                    modifier = Modifier.size(18.dp)
                )
            }
        }
    }
}

package com.pichiplayer.ui.search

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardActions
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.*
import androidx.compose.material.icons.outlined.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalSoftwareKeyboardController
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.pichiplayer.PichiPlayerApp
import com.pichiplayer.data.database.VideoEntity
import com.pichiplayer.ui.components.*
import com.pichiplayer.ui.states.EmptySearchState
import com.pichiplayer.ui.theme.AppColors
import com.pichiplayer.ui.theme.AppTypography
import kotlinx.coroutines.launch

@Composable
fun SearchScreen(
    onPlayVideo: (VideoEntity, List<VideoEntity>) -> Unit,
    onVideoDetails: (Long) -> Unit,
    onBackClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    val repository = PichiPlayerApp.instance.repository
    val keyboardController = LocalSoftwareKeyboardController.current
    val coroutineScope = rememberCoroutineScope()

    var query by remember { mutableStateOf("") }
    var selectedFilter by remember { mutableStateOf("All") }
    val filters = listOf("All", "4K", "1080p", "Favorites")

    val searchHistory by repository.recentSearches.collectAsState(initial = emptyList())
    val searchResults by repository.searchVideos(query, selectedFilter).collectAsState(initial = emptyList())
    val allVideos by repository.allVideos.collectAsState(initial = emptyList())

    var fuzzySuggestion by remember { mutableStateOf<String?>(null) }

    LaunchedEffect(query, searchResults) {
        if (query.length >= 3 && searchResults.isEmpty()) {
            fuzzySuggestion = repository.findFuzzySuggestion(query, allVideos)
        } else {
            fuzzySuggestion = null
        }
    }

    Box(
        modifier = modifier
            .fillMaxSize()
            .background(AppColors.background)
            .statusBarsPadding()
            .displayCutoutPadding()
    ) {
        Column(modifier = Modifier.fillMaxSize()) {
            // Search Bar Row
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 16.dp, vertical = 12.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                PichiIconButton(
                    icon = Icons.AutoMirrored.Filled.ArrowBack,
                    contentDescription = "Back",
                    onClick = onBackClick,
                    size = 40.dp
                )

                Spacer(modifier = Modifier.width(10.dp))

                TextField(
                    value = query,
                    onValueChange = { query = it },
                    placeholder = {
                        Text(
                            text = "Search local titles, folders...",
                            style = AppTypography.bodyMedium.copy(color = AppColors.textMuted)
                        )
                    },
                    singleLine = true,
                    keyboardOptions = KeyboardOptions(imeAction = ImeAction.Search),
                    keyboardActions = KeyboardActions(
                        onSearch = {
                            keyboardController?.hide()
                            if (query.isNotBlank()) {
                                coroutineScope.launch { repository.addSearchHistory(query) }
                            }
                        }
                    ),
                    trailingIcon = {
                        if (query.isNotEmpty()) {
                            IconButton(onClick = { query = "" }) {
                                Icon(
                                    imageVector = Icons.Default.Close,
                                    contentDescription = "Clear",
                                    tint = AppColors.textMuted
                                )
                            }
                        }
                    },
                    colors = TextFieldDefaults.colors(
                        focusedContainerColor = AppColors.surface,
                        unfocusedContainerColor = AppColors.surfaceSubtle,
                        focusedIndicatorColor = Color.Transparent,
                        unfocusedIndicatorColor = Color.Transparent,
                        focusedTextColor = AppColors.textPrimary,
                        unfocusedTextColor = AppColors.textPrimary
                    ),
                    shape = RoundedCornerShape(20.dp),
                    modifier = Modifier
                        .weight(1f)
                        .height(50.dp)
                )
            }

            // Filter Chips
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 20.dp, vertical = 4.dp),
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                filters.forEach { filter ->
                    val isSelected = filter == selectedFilter
                    Box(
                        modifier = Modifier
                            .clip(RoundedCornerShape(16.dp))
                            .background(if (isSelected) AppColors.electricBlue else AppColors.surfaceSubtle)
                            .clickable { selectedFilter = filter }
                            .padding(horizontal = 12.dp, vertical = 6.dp),
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

            // Body: If query is blank, show Recent Searches. If query entered, show results or empty state.
            if (query.isBlank()) {
                if (searchHistory.isNotEmpty()) {
                    Column(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(horizontal = 20.dp, vertical = 12.dp)
                    ) {
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceBetween,
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Text(
                                text = "Recent Searches",
                                style = AppTypography.cardTitle.copy(color = AppColors.textMuted)
                            )
                            Text(
                                text = "Clear All",
                                style = AppTypography.caption.copy(color = AppColors.electricBlueBright),
                                modifier = Modifier
                                    .clickable {
                                        coroutineScope.launch { repository.clearSearchHistory() }
                                    }
                                    .padding(4.dp)
                            )
                        }

                        Spacer(modifier = Modifier.height(12.dp))

                        LazyColumn(verticalArrangement = Arrangement.spacedBy(6.dp)) {
                            items(searchHistory) { historyItem ->
                                Row(
                                    modifier = Modifier
                                        .fillMaxWidth()
                                        .clip(RoundedCornerShape(10.dp))
                                        .clickable { query = historyItem }
                                        .padding(horizontal = 12.dp, vertical = 10.dp),
                                    verticalAlignment = Alignment.CenterVertically,
                                    horizontalArrangement = Arrangement.SpaceBetween
                                ) {
                                    Row(
                                        verticalAlignment = Alignment.CenterVertically,
                                        horizontalArrangement = Arrangement.spacedBy(10.dp)
                                    ) {
                                        Icon(
                                            imageVector = Icons.Default.History,
                                            contentDescription = null,
                                            tint = AppColors.textMuted,
                                            modifier = Modifier.size(18.dp)
                                        )
                                        Text(
                                            text = historyItem,
                                            style = AppTypography.bodyMedium.copy(color = AppColors.textPrimary)
                                        )
                                    }

                                    IconButton(
                                        onClick = {
                                            coroutineScope.launch { repository.removeSearchHistory(historyItem) }
                                        },
                                        modifier = Modifier.size(24.dp)
                                    ) {
                                        Icon(
                                            imageVector = Icons.Default.Close,
                                            contentDescription = "Remove",
                                            tint = AppColors.textMuted,
                                            modifier = Modifier.size(14.dp)
                                        )
                                    }
                                }
                            }
                        }
                    }
                }
            } else {
                if (searchResults.isEmpty()) {
                    EmptySearchState(
                        query = query,
                        suggestedTerm = fuzzySuggestion,
                        onSuggestionClick = { suggestion ->
                            query = suggestion
                        }
                    )
                } else {
                    LazyColumn(
                        modifier = Modifier.fillMaxSize(),
                        contentPadding = PaddingValues(horizontal = 16.dp, vertical = 8.dp),
                        verticalArrangement = Arrangement.spacedBy(10.dp)
                    ) {
                        items(searchResults, key = { it.id }) { video ->
                            PichiGlassCard(
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .height(84.dp),
                                onClick = {
                                    coroutineScope.launch { repository.addSearchHistory(query) }
                                    onPlayVideo(video, searchResults)
                                }
                            ) {
                                Row(
                                    modifier = Modifier
                                        .fillMaxSize()
                                        .padding(8.dp),
                                    verticalAlignment = Alignment.CenterVertically
                                ) {
                                    Box(
                                        modifier = Modifier
                                            .width(110.dp)
                                            .fillMaxHeight()
                                    ) {
                                        PichiVideoThumbnail(
                                            video = video,
                                            thumbnailPath = video.thumbnailPath,
                                            modifier = Modifier.fillMaxSize()
                                        )
                                    }

                                    Spacer(modifier = Modifier.width(12.dp))

                                    Column(modifier = Modifier.weight(1f)) {
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
                                    }

                                    IconButton(
                                        onClick = { onVideoDetails(video.id) },
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
                    }
                }
            }
        }
    }
}

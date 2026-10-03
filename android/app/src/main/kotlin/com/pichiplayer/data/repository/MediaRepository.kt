package com.pichiplayer.data.repository

import android.content.Context
import android.net.Uri
import com.pichiplayer.data.database.FolderEntity
import com.pichiplayer.data.database.PichiDatabase
import com.pichiplayer.data.database.SearchHistoryEntity
import com.pichiplayer.data.database.VideoEntity
import com.pichiplayer.data.preferences.UserPreferencesRepository
import com.pichiplayer.media.scanner.MediaStoreScanner
import com.pichiplayer.media.thumbnails.ThumbnailCacheManager
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import java.util.Locale

class MediaRepository(
    private val context: Context,
    private val database: PichiDatabase,
    val preferences: UserPreferencesRepository,
    val thumbnailCache: ThumbnailCacheManager,
    val scanner: MediaStoreScanner
) {
    private val videoDao = database.videoDao()
    private val folderDao = database.folderDao()
    private val searchHistoryDao = database.searchHistoryDao()

    val allVideos: Flow<List<VideoEntity>> = videoDao.getAllVideos()
    val continueWatchingVideos: Flow<List<VideoEntity>> = videoDao.getContinueWatchingVideos()
    val recentlyAddedVideos: Flow<List<VideoEntity>> = videoDao.getRecentlyAddedVideos()
    val fourKVideos: Flow<List<VideoEntity>> = videoDao.get4KVideos()
    val favoriteVideos: Flow<List<VideoEntity>> = videoDao.getFavoriteVideos()
    val allFolders: Flow<List<FolderEntity>> = folderDao.getAllFolders()
    val recentSearches: Flow<List<String>> = searchHistoryDao.getRecentSearches()

    suspend fun getVideoById(id: Long): VideoEntity? = videoDao.getVideoById(id)
    fun getVideoByIdFlow(id: Long): Flow<VideoEntity?> = videoDao.getVideoByIdFlow(id)

    fun getVideosByFolder(folderName: String): Flow<List<VideoEntity>> =
        videoDao.getVideosByFolder(folderName)

    suspend fun toggleFavorite(id: Long) = videoDao.toggleFavorite(id)

    suspend fun updatePlaybackPosition(id: Long, positionMs: Long, durationMs: Long) {
        val percentage = if (durationMs > 0) (positionMs.toFloat() / durationMs).coerceIn(0f, 1f) else 0f
        videoDao.updatePlaybackPosition(id, positionMs, percentage)
    }

    suspend fun clearPlaybackHistory() = videoDao.clearPlaybackHistory()

    fun searchVideos(query: String, filter: String = "All"): Flow<List<VideoEntity>> {
        return videoDao.searchVideos(query).map { list ->
            when (filter) {
                "4K" -> list.filter { it.is4K }
                "1080p" -> list.filter { it.is1080p }
                "720p" -> list.filter { it.is720p }
                "HDR" -> list.filter { it.isHdr }
                "Favorites" -> list.filter { it.isFavorite }
                else -> list
            }
        }
    }

    suspend fun addSearchHistory(query: String) {
        if (query.isNotBlank()) {
            searchHistoryDao.insertSearch(SearchHistoryEntity(query.trim()))
        }
    }

    suspend fun removeSearchHistory(query: String) {
        searchHistoryDao.deleteSearch(query)
    }

    suspend fun clearSearchHistory() {
        searchHistoryDao.clearAll()
    }

    suspend fun rescan(customFolderUris: List<Uri> = emptyList()) {
        scanner.scanLocalVideos(customFolderUris)
    }

    /**
     * Local offline fuzzy search suggestion using Levenshtein distance
     * Returns a suggestion if a query has minor typos (e.g. "interstelar" -> "Interstellar")
     */
    suspend fun findFuzzySuggestion(query: String, allVideosList: List<VideoEntity>): String? {
        if (query.length < 3) return null
        val lowerQuery = query.lowercase(Locale.ROOT)

        var bestMatch: String? = null
        var minDistance = Int.MAX_VALUE

        for (video in allVideosList) {
            val name = video.displayName.substringBeforeLast('.')
            val lowerName = name.lowercase(Locale.ROOT)

            if (lowerName.contains(lowerQuery)) return null // Already matches directly

            // Check individual words
            for (word in lowerName.split(" ", "_", "-", ".")) {
                if (word.length >= 3) {
                    val dist = levenshteinDistance(lowerQuery, word)
                    if (dist in 1..2 && dist < minDistance) {
                        minDistance = dist
                        bestMatch = name
                    }
                }
            }
        }
        return bestMatch
    }

    private fun levenshteinDistance(a: String, b: String): Int {
        val dp = Array(a.length + 1) { IntArray(b.length + 1) }
        for (i in 0..a.length) dp[i][0] = i
        for (j in 0..b.length) dp[0][j] = j
        for (i in 1..a.length) {
            for (j in 1..b.length) {
                val cost = if (a[i - 1] == b[j - 1]) 0 else 1
                dp[i][j] = minOf(
                    dp[i - 1][j] + 1,
                    dp[i][j - 1] + 1,
                    dp[i - 1][j - 1] + cost
                )
            }
        }
        return dp[a.length][b.length]
    }
}

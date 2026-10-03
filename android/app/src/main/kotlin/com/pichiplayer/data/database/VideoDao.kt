package com.pichiplayer.data.database

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import androidx.room.Update
import kotlinx.coroutines.flow.Flow

@Dao
interface VideoDao {
    @Query("SELECT * FROM videos ORDER BY dateAdded DESC")
    fun getAllVideos(): Flow<List<VideoEntity>>

    @Query("SELECT * FROM videos WHERE id = :id LIMIT 1")
    suspend fun getVideoById(id: Long): VideoEntity?

    @Query("SELECT * FROM videos WHERE id = :id LIMIT 1")
    fun getVideoByIdFlow(id: Long): Flow<VideoEntity?>

    @Query("SELECT * FROM videos WHERE lastPositionMs > 1000 AND watchedPercentage < 0.95 ORDER BY dateModified DESC LIMIT 10")
    fun getContinueWatchingVideos(): Flow<List<VideoEntity>>

    @Query("SELECT * FROM videos ORDER BY dateAdded DESC LIMIT 10")
    fun getRecentlyAddedVideos(): Flow<List<VideoEntity>>

    @Query("SELECT * FROM videos WHERE (width >= 3840 AND height >= 2160) OR (width >= 2160 AND height >= 3840) ORDER BY dateAdded DESC")
    fun get4KVideos(): Flow<List<VideoEntity>>

    @Query("SELECT * FROM videos WHERE isFavorite = 1 ORDER BY displayName ASC")
    fun getFavoriteVideos(): Flow<List<VideoEntity>>

    @Query("SELECT * FROM videos WHERE folderName = :folderName ORDER BY displayName ASC")
    fun getVideosByFolder(folderName: String): Flow<List<VideoEntity>>

    @Query("SELECT * FROM videos WHERE displayName LIKE '%' || :query || '%' OR folderName LIKE '%' || :query || '%' ORDER BY displayName ASC")
    fun searchVideos(query: String): Flow<List<VideoEntity>>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertVideos(videos: List<VideoEntity>)

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertVideo(video: VideoEntity)

    @Update
    suspend fun updateVideo(video: VideoEntity)

    @Query("UPDATE videos SET isFavorite = NOT isFavorite WHERE id = :id")
    suspend fun toggleFavorite(id: Long)

    @Query("UPDATE videos SET lastPositionMs = :positionMs, watchedPercentage = :watchedPercentage WHERE id = :id")
    suspend fun updatePlaybackPosition(id: Long, positionMs: Long, watchedPercentage: Float)

    @Query("UPDATE videos SET lastPositionMs = 0, watchedPercentage = 0")
    suspend fun clearPlaybackHistory()

    @Query("DELETE FROM videos WHERE id = :id")
    suspend fun deleteVideoById(id: Long)

    @Query("DELETE FROM videos WHERE id NOT IN (:validIds)")
    suspend fun deleteVideosNotIn(validIds: List<Long>)

    @Query("SELECT COUNT(*) FROM videos")
    suspend fun getVideoCount(): Int

    @Query("SELECT id FROM videos")
    suspend fun getAllVideoIds(): List<Long>
}

@Dao
interface FolderDao {
    @Query("SELECT * FROM folders ORDER BY folderName ASC")
    fun getAllFolders(): Flow<List<FolderEntity>>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertFolders(folders: List<FolderEntity>)

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertFolder(folder: FolderEntity)

    @Query("DELETE FROM folders WHERE folderPath = :path")
    suspend fun deleteFolder(path: String)

    @Query("UPDATE folders SET hasPermission = :hasPermission WHERE folderPath = :path")
    suspend fun updatePermission(path: String, hasPermission: Boolean)
}

@Dao
interface SearchHistoryDao {
    @Query("SELECT query FROM search_history ORDER BY timestamp DESC LIMIT 10")
    fun getRecentSearches(): Flow<List<String>>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertSearch(search: SearchHistoryEntity)

    @Query("DELETE FROM search_history WHERE query = :query")
    suspend fun deleteSearch(query: String)

    @Query("DELETE FROM search_history")
    suspend fun clearAll()
}

package com.pichiplayer.data.database

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "folders")
data class FolderEntity(
    @PrimaryKey
    val folderPath: String,
    val folderName: String,
    val videoCount: Int = 0,
    val totalSizeBytes: Long = 0L,
    val persistedUriString: String? = null,
    val hasPermission: Boolean = true,
    val lastScannedTimestamp: Long = System.currentTimeMillis()
) {
    val formattedTotalSize: String get() {
        if (totalSizeBytes <= 0) return "0 MB"
        val mb = totalSizeBytes.toDouble() / (1024 * 1024)
        return if (mb >= 1024) {
            String.format("%.2f GB", mb / 1024)
        } else {
            String.format("%.1f MB", mb)
        }
    }
}

@Entity(tableName = "search_history")
data class SearchHistoryEntity(
    @PrimaryKey
    val query: String,
    val timestamp: Long = System.currentTimeMillis()
)

package com.pichiplayer.data.database

import androidx.room.Entity
import androidx.room.Index
import androidx.room.PrimaryKey

@Entity(
    tableName = "videos",
    indices = [
        Index(value = ["displayName"]),
        Index(value = ["folderName"]),
        Index(value = ["isFavorite"]),
        Index(value = ["dateModified"]),
        Index(value = ["lastPositionMs"])
    ]
)
data class VideoEntity(
    @PrimaryKey
    val id: Long, // Matches MediaStore ID or stable hash
    val contentUri: String,
    val filePath: String?,
    val displayName: String,
    val folderName: String,
    val durationMs: Long,
    val width: Int,
    val height: Int,
    val videoCodec: String? = null,
    val audioCodec: String? = null,
    val frameRate: Float? = null,
    val bitrate: Long? = null,
    val fileSize: Long = 0L,
    val isHdr: Boolean = false,
    val dateAdded: Long = 0L,
    val dateModified: Long = 0L,
    val thumbnailPath: String? = null,
    val lastPositionMs: Long = 0L,
    val watchedPercentage: Float = 0f,
    val isFavorite: Boolean = false,
    val folderUri: String? = null
) {
    val isPartiallyWatched: Boolean get() = lastPositionMs > 1000L && watchedPercentage < 0.95f
    val maxDim: Int get() = maxOf(width, height)
    val minDim: Int get() = minOf(width, height)

    val fileExtension: String get() {
        val name = displayName.trim()
        val extIndex = name.lastIndexOf('.')
        return if (extIndex != -1 && extIndex < name.length - 1) {
            name.substring(extIndex + 1).lowercase()
        } else {
            filePath?.substringAfterLast('.', "")?.lowercase() ?: ""
        }
    }

    val is3gp: Boolean get() = fileExtension == "3gp" || fileExtension == "3gpp"

    val is8K: Boolean get() = maxDim >= 7680 || minDim >= 4320
    val is4K: Boolean get() = !is8K && (maxDim >= 3600 || minDim >= 2100)
    // 2K / 1440p (QHD: 2560x1440, DCI 2K: 2048x1080). 1920x1080 is NOT 2K!
    val is2K: Boolean get() = !is8K && !is4K && ((minDim in 1300..2099) || (maxDim in 2048..3599 && minDim >= 1000))
    // 1080p / FHD (1920x1080, 1080x1920, or vertical height in 950..1299)
    val is1080p: Boolean get() = !is8K && !is4K && !is2K && (minDim in 950..1299 || (maxDim in 1800..2047 && minDim >= 900))
    // 720p / HD (1280x720, 720x1280, or vertical height in 650..949)
    val is720p: Boolean get() = !is8K && !is4K && !is2K && !is1080p && (minDim in 650..949 || (maxDim in 1150..1799 && minDim >= 600))
    // 480p / SD (854x480, 640x480, or vertical height in 420..649)
    val is480p: Boolean get() = !is8K && !is4K && !is2K && !is1080p && !is720p && (minDim in 420..649 || (maxDim in 640..1149 && minDim >= 400))
    // 360p
    val is360p: Boolean get() = !is8K && !is4K && !is2K && !is1080p && !is720p && !is480p && (minDim in 300..419 || (maxDim in 480..639 && minDim >= 300))
    // 240p
    val is240p: Boolean get() = !is8K && !is4K && !is2K && !is1080p && !is720p && !is480p && !is360p && (minDim in 200..299 || (maxDim in 300..479 && minDim >= 180))
    // 144p
    val is144p: Boolean get() = !is8K && !is4K && !is2K && !is1080p && !is720p && !is480p && !is360p && !is240p && (minDim in 100..199)

    val resolutionBadge: String get() = when {
        is8K -> "8K"
        is4K -> "4K"
        is2K -> "2K"
        is1080p -> "1080p"
        is720p -> "720p"
        is480p -> "480p"
        is360p -> "360p"
        is240p -> "240p"
        is144p -> "144p"
        minDim > 0 -> "${minDim}p"
        is3gp -> "3GP"
        fileExtension.isNotEmpty() -> fileExtension.uppercase()
        else -> "SD"
    }

    val formatBadge: String? get() = when {
        is3gp -> "3GP"
        fileExtension in listOf("mkv", "webm", "avi", "flv", "mov", "wmv", "ts") -> fileExtension.uppercase()
        else -> null
    }

    val resolutionLabel: String get() = when {
        is8K -> "8K UHD"
        is4K -> "4K UHD"
        is2K -> "2K QHD"
        is1080p -> "1080p FHD"
        is720p -> "720p HD"
        is480p -> "480p SD"
        is360p -> "360p"
        is240p -> "240p"
        is144p -> "144p"
        width > 0 && height > 0 -> "${width}x${height}"
        is3gp -> "3GP Video"
        else -> "Standard"
    }

    val formattedDuration: String get() {
        val totalSecs = durationMs / 1000
        val hours = totalSecs / 3600
        val mins = (totalSecs % 3600) / 60
        val secs = totalSecs % 60
        return if (hours > 0) {
            String.format("%d:%02d:%02d", hours, mins, secs)
        } else {
            String.format("%02d:%02d", mins, secs)
        }
    }

    val formattedLastPosition: String get() {
        val totalSecs = lastPositionMs / 1000
        val hours = totalSecs / 3600
        val mins = (totalSecs % 3600) / 60
        val secs = totalSecs % 60
        return if (hours > 0) {
            String.format("%d:%02d:%02d", hours, mins, secs)
        } else {
            String.format("%02d:%02d", mins, secs)
        }
    }

    val formattedWatchedPercentage: String get() = "${(watchedPercentage * 100).toInt()}%"

    val formattedFileSize: String get() {
        if (fileSize <= 0) return "0 MB"
        val mb = fileSize.toDouble() / (1024 * 1024)
        return if (mb >= 1024) {
            String.format("%.2f GB", mb / 1024)
        } else {
            String.format("%.1f MB", mb)
        }
    }
}

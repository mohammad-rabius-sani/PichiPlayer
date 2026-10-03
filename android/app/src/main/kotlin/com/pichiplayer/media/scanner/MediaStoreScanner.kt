package com.pichiplayer.media.scanner

import android.content.ContentUris
import android.content.Context
import android.net.Uri
import android.os.Build
import android.provider.MediaStore
import androidx.documentfile.provider.DocumentFile
import com.pichiplayer.data.database.FolderEntity
import com.pichiplayer.data.database.PichiDatabase
import com.pichiplayer.data.database.VideoEntity
import com.pichiplayer.media.metadata.MediaMetadataExtractor
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.withContext

data class ScanProgress(
    val progress: Float = 0f,
    val videosFound: Int = 0,
    val currentFolder: String = "Storage/",
    val foldersChecked: Int = 0,
    val isComplete: Boolean = false
)

class MediaStoreScanner(
    private val context: Context,
    private val database: PichiDatabase
) {
    private val _scanProgress = MutableStateFlow(ScanProgress())
    val scanProgress: StateFlow<ScanProgress> = _scanProgress.asStateFlow()

    suspend fun scanLocalVideos(customFolderUris: List<Uri> = emptyList()) = withContext(Dispatchers.IO) {
        val videoList = mutableListOf<VideoEntity>()
        val folderMap = mutableMapOf<String, FolderEntity>()
        val videoDao = database.videoDao()
        val folderDao = database.folderDao()

        _scanProgress.value = ScanProgress(
            progress = 0.05f,
            videosFound = 0,
            currentFolder = "Initializing scan...",
            isComplete = false
        )

        // 1. Scan MediaStore
        val projection = arrayOf(
            MediaStore.Video.Media._ID,
            MediaStore.Video.Media.DISPLAY_NAME,
            MediaStore.Video.Media.DATA,
            MediaStore.Video.Media.DURATION,
            MediaStore.Video.Media.WIDTH,
            MediaStore.Video.Media.HEIGHT,
            MediaStore.Video.Media.SIZE,
            MediaStore.Video.Media.DATE_ADDED,
            MediaStore.Video.Media.DATE_MODIFIED,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                MediaStore.Video.Media.BUCKET_DISPLAY_NAME
            } else {
                MediaStore.Video.Media.DATA
            }
        )

        val sortOrder = "${MediaStore.Video.Media.DATE_ADDED} DESC"

        try {
            val cursor = context.contentResolver.query(
                MediaStore.Video.Media.EXTERNAL_CONTENT_URI,
                projection,
                null,
                null,
                sortOrder
            )

            cursor?.use {
                val idCol = it.getColumnIndexOrThrow(MediaStore.Video.Media._ID)
                val nameCol = it.getColumnIndexOrThrow(MediaStore.Video.Media.DISPLAY_NAME)
                val dataCol = it.getColumnIndexOrThrow(MediaStore.Video.Media.DATA)
                val durationCol = it.getColumnIndexOrThrow(MediaStore.Video.Media.DURATION)
                val widthCol = it.getColumnIndexOrThrow(MediaStore.Video.Media.WIDTH)
                val heightCol = it.getColumnIndexOrThrow(MediaStore.Video.Media.HEIGHT)
                val sizeCol = it.getColumnIndexOrThrow(MediaStore.Video.Media.SIZE)
                val addedCol = it.getColumnIndexOrThrow(MediaStore.Video.Media.DATE_ADDED)
                val modifiedCol = it.getColumnIndexOrThrow(MediaStore.Video.Media.DATE_MODIFIED)
                val bucketCol = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    it.getColumnIndex(MediaStore.Video.Media.BUCKET_DISPLAY_NAME)
                } else -1

                val totalCount = it.count
                var index = 0

                while (it.moveToNext()) {
                    val id = it.getLong(idCol)
                    val displayName = it.getString(nameCol) ?: "Video_$id"
                    val filePath = it.getString(dataCol)
                    val durationMs = it.getLong(durationCol)
                    val width = it.getInt(widthCol)
                    val height = it.getInt(heightCol)
                    val fileSize = it.getLong(sizeCol)
                    val dateAdded = it.getLong(addedCol)
                    val dateModified = it.getLong(modifiedCol)

                    val folderName = if (bucketCol != -1) {
                        it.getString(bucketCol) ?: "Movies"
                    } else {
                        filePath?.substringBeforeLast('/')?.substringAfterLast('/') ?: "Movies"
                    }

                    val contentUri = ContentUris.withAppendedId(
                        MediaStore.Video.Media.EXTERNAL_CONTENT_URI,
                        id
                    ).toString()

                    // Extract deep metadata (codec, HDR, audio)
                    val metadata = MediaMetadataExtractor.extract(
                        context,
                        Uri.parse(contentUri)
                    )

                    val video = VideoEntity(
                        id = id,
                        contentUri = contentUri,
                        filePath = filePath,
                        displayName = displayName,
                        folderName = folderName,
                        durationMs = durationMs,
                        width = width,
                        height = height,
                        videoCodec = metadata.videoCodec,
                        audioCodec = metadata.audioCodec,
                        frameRate = metadata.frameRate,
                        bitrate = metadata.bitrate,
                        fileSize = fileSize,
                        isHdr = metadata.isHdr,
                        dateAdded = dateAdded,
                        dateModified = dateModified
                    )

                    videoList.add(video)

                    // Track folder
                    val existingFolder = folderMap[folderName]
                    val folderPath = filePath?.substringBeforeLast('/') ?: folderName
                    folderMap[folderName] = FolderEntity(
                        folderPath = folderPath,
                        folderName = folderName,
                        videoCount = (existingFolder?.videoCount ?: 0) + 1,
                        totalSizeBytes = (existingFolder?.totalSizeBytes ?: 0L) + fileSize
                    )

                    index++
                    if (index % 5 == 0 || index == totalCount) {
                        val progress = if (totalCount > 0) (index.toFloat() / totalCount) * 0.85f else 0.85f
                        _scanProgress.value = ScanProgress(
                            progress = progress,
                            videosFound = videoList.size,
                            currentFolder = folderName,
                            foldersChecked = folderMap.size,
                            isComplete = false
                        )
                    }
                }
            }
        } catch (_: Exception) {}

        // 2. Scan custom SAF folders if provided
        for (folderUri in customFolderUris) {
            try {
                val docFile = DocumentFile.fromTreeUri(context, folderUri) ?: continue
                val folderName = docFile.name ?: "Custom Folder"
                var customVideosFound = 0
                var customFolderSize = 0L

                for (file in docFile.listFiles()) {
                    if (file.isFile && (file.type?.startsWith("video/") == true ||
                                file.name?.endsWith(".mp4", ignoreCase = true) == true ||
                                file.name?.endsWith(".mkv", ignoreCase = true) == true ||
                                file.name?.endsWith(".webm", ignoreCase = true) == true ||
                                file.name?.endsWith(".avi", ignoreCase = true) == true)
                    ) {
                        val id = file.uri.hashCode().toLong()
                        val metadata = MediaMetadataExtractor.extract(context, file.uri)

                        val video = VideoEntity(
                            id = id,
                            contentUri = file.uri.toString(),
                            filePath = null,
                            displayName = file.name ?: "Video_$id",
                            folderName = folderName,
                            durationMs = 0L,
                            width = 1920,
                            height = 1080,
                            videoCodec = metadata.videoCodec,
                            audioCodec = metadata.audioCodec,
                            fileSize = file.length(),
                            folderUri = folderUri.toString()
                        )
                        videoList.add(video)
                        customVideosFound++
                        customFolderSize += file.length()
                    }
                }

                folderMap[folderName] = FolderEntity(
                    folderPath = folderUri.toString(),
                    folderName = folderName,
                    videoCount = customVideosFound,
                    totalSizeBytes = customFolderSize,
                    persistedUriString = folderUri.toString(),
                    hasPermission = true
                )
            } catch (_: Exception) {}
        }

        // 3. Save to database
        videoDao.insertVideos(videoList)
        folderDao.insertFolders(folderMap.values.toList())

        // Remove deleted videos
        val validIds = videoList.map { it.id }
        if (validIds.isNotEmpty()) {
            videoDao.deleteVideosNotIn(validIds)
        }

        _scanProgress.value = ScanProgress(
            progress = 1.0f,
            videosFound = videoList.size,
            currentFolder = "All media indexed",
            foldersChecked = folderMap.size,
            isComplete = true
        )
    }
}

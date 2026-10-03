package com.pichiplayer.media.thumbnails

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Canvas
import android.graphics.LinearGradient
import android.graphics.Paint
import android.graphics.Path
import android.graphics.Shader
import android.media.MediaMetadataRetriever
import android.net.Uri
import android.util.LruCache
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.io.File
import java.io.FileOutputStream

class ThumbnailCacheManager(private val context: Context) {
    private val diskCacheDir = File(context.cacheDir, "pichi_thumbnails").apply { mkdirs() }

    // Memory cache: 25% of available max memory
    private val maxMemory = (Runtime.getRuntime().maxMemory() / 1024).toInt()
    private val cacheSize = maxMemory / 4

    private val memoryCache = object : LruCache<Long, Bitmap>(cacheSize) {
        override fun sizeOf(key: Long, bitmap: Bitmap): Int {
            return bitmap.byteCount / 1024
        }
    }

    suspend fun getThumbnail(
        videoId: Long,
        contentUri: Uri,
        width: Int = 360,
        height: Int = 202
    ): Bitmap = withContext(Dispatchers.IO) {
        // 1. Check memory cache
        memoryCache.get(videoId)?.let { return@withContext it }

        // 2. Check disk cache
        val diskFile = File(diskCacheDir, "$videoId.jpg")
        if (diskFile.exists() && diskFile.length() > 0) {
            try {
                val bitmap = BitmapFactory.decodeFile(diskFile.absolutePath)
                if (bitmap != null) {
                    memoryCache.put(videoId, bitmap)
                    return@withContext bitmap
                }
            } catch (_: Exception) {}
        }

        // 3. Extract from video using MediaMetadataRetriever
        var extractedBitmap: Bitmap? = null
        val retriever = MediaMetadataRetriever()
        try {
            retriever.setDataSource(context, contentUri)
            // Extract downscaled frame directly to avoid loading full 4K/8K bitmaps in RAM
            val frame: Bitmap? = if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O_MR1) {
                retriever.getScaledFrameAtTime(
                    2_000_000,
                    MediaMetadataRetriever.OPTION_CLOSEST_SYNC,
                    width,
                    height
                )
            } else {
                val fullFrame = retriever.getFrameAtTime(2_000_000, MediaMetadataRetriever.OPTION_CLOSEST_SYNC)
                if (fullFrame != null) {
                    val scaled = Bitmap.createScaledBitmap(fullFrame, width, height, true)
                    if (scaled != fullFrame) {
                        fullFrame.recycle()
                    }
                    scaled
                } else null
            }
            extractedBitmap = frame
        } catch (_: Exception) {
        } finally {
            try {
                if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.Q) {
                    retriever.close()
                } else {
                    retriever.release()
                }
            } catch (_: Exception) {}
        }

        // 4. If extraction fails, generate a tasteful cinematic fallback bitmap
        val finalBitmap = extractedBitmap ?: generateFallbackThumbnail(videoId, width, height)

        // Save to disk & memory
        try {
            FileOutputStream(diskFile).use { out ->
                finalBitmap.compress(Bitmap.CompressFormat.JPEG, 85, out)
            }
        } catch (_: Exception) {}

        memoryCache.put(videoId, finalBitmap)
        return@withContext finalBitmap
    }

    private fun generateFallbackThumbnail(videoId: Long, width: Int, height: Int): Bitmap {
        val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)

        // Palette variations based on videoId hash
        val colors = listOf(
            intArrayOf(0xFF0F172A.toInt(), 0xFF1E293B.toInt()),
            intArrayOf(0xFF0284C7.toInt(), 0xFF0F172A.toInt()),
            intArrayOf(0xFF7C3AED.toInt(), 0xFF0F172A.toInt()),
            intArrayOf(0xFF0D9488.toInt(), 0xFF0F172A.toInt())
        )
        val pair = colors[(videoId.hashCode().let { if (it < 0) -it else it }) % colors.size]

        val paint = Paint().apply {
            shader = LinearGradient(
                0f, 0f, width.toFloat(), height.toFloat(),
                pair[0], pair[1], Shader.TileMode.CLAMP
            )
        }
        canvas.drawRect(0f, 0f, width.toFloat(), height.toFloat(), paint)

        // Subtle Play symbol in center
        val playPaint = Paint().apply {
            color = 0x66FFFFFF
            style = Paint.Style.FILL
            isAntiAlias = true
        }
        val centerX = width / 2f
        val centerY = height / 2f
        val size = width * 0.12f

        val path = Path().apply {
            moveTo(centerX - size * 0.5f, centerY - size * 0.6f)
            lineTo(centerX + size * 0.7f, centerY)
            lineTo(centerX - size * 0.5f, centerY + size * 0.6f)
            close()
        }
        canvas.drawPath(path, playPaint)

        return bitmap
    }

    fun clearCache() {
        memoryCache.evictAll()
        diskCacheDir.deleteRecursively()
        diskCacheDir.mkdirs()
    }

    fun getCacheSizeBytes(): Long {
        return diskCacheDir.walkTopDown().filter { it.isFile }.map { it.length() }.sum()
    }
}

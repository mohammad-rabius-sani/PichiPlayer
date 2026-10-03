package com.pichiplayer

import android.app.Application
import coil.ImageLoader
import coil.ImageLoaderFactory
import coil.decode.VideoFrameDecoder
import coil.disk.DiskCache
import coil.memory.MemoryCache
import com.pichiplayer.data.database.PichiDatabase
import com.pichiplayer.data.preferences.UserPreferencesRepository
import com.pichiplayer.data.repository.MediaRepository
import com.pichiplayer.media.playback.PlayerManager
import com.pichiplayer.media.scanner.MediaStoreScanner
import com.pichiplayer.media.thumbnails.ThumbnailCacheManager
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch

class PichiPlayerApp : Application(), ImageLoaderFactory {

    private val applicationScope = CoroutineScope(SupervisorJob() + Dispatchers.IO)

    lateinit var database: PichiDatabase
        private set
    lateinit var preferences: UserPreferencesRepository
        private set
    lateinit var thumbnailCache: ThumbnailCacheManager
        private set
    lateinit var scanner: MediaStoreScanner
        private set
    lateinit var repository: MediaRepository
        private set
    lateinit var playerManager: PlayerManager
        private set

    override fun onCreate() {
        super.onCreate()
        instance = this

        database = PichiDatabase.getInstance(this)
        preferences = UserPreferencesRepository(this)
        thumbnailCache = ThumbnailCacheManager(this)
        scanner = MediaStoreScanner(this, database)
        repository = MediaRepository(this, database, preferences, thumbnailCache, scanner)
        playerManager = PlayerManager.getInstance(this)
        val savedDecoder = com.pichiplayer.media.playback.DecoderMode.fromCode(preferences.decoderMode.value)
        playerManager.setDecoderMode(savedDecoder)

        // Automatically persist position updates from player to Room database
        playerManager.setPositionUpdateListener { videoId, posMs, durMs ->
            applicationScope.launch {
                repository.updatePlaybackPosition(videoId, posMs, durMs)
            }
        }
    }

    override fun newImageLoader(): ImageLoader {
        return ImageLoader.Builder(this)
            .components {
                add(VideoFrameDecoder.Factory())
            }
            .memoryCache {
                MemoryCache.Builder(this)
                    .maxSizePercent(0.25)
                    .build()
            }
            .diskCache {
                DiskCache.Builder()
                    .directory(cacheDir.resolve("pichi_video_thumbnails"))
                    .maxSizePercent(0.05)
                    .build()
            }
            .crossfade(true)
            .respectCacheHeaders(false)
            .build()
    }

    companion object {
        lateinit var instance: PichiPlayerApp
            private set
    }
}

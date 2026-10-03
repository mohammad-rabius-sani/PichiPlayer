package com.pichiplayer

import android.Manifest
import android.app.PictureInPictureParams
import android.content.Intent
import android.content.pm.PackageManager
import android.content.res.Configuration
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.util.Rational
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.core.content.ContextCompat
import androidx.lifecycle.lifecycleScope
import com.pichiplayer.data.database.VideoEntity
import com.pichiplayer.media.metadata.MediaMetadataExtractor
import com.pichiplayer.ui.navigation.PichiNavHost
import com.pichiplayer.ui.states.PermissionRequiredState
import com.pichiplayer.ui.theme.PichiTheme
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.launch

class MainActivity : ComponentActivity() {

    private var hasStoragePermission by mutableStateOf(false)

    private val permissionLauncher = registerForActivityResult(
        ActivityResultContracts.RequestMultiplePermissions()
    ) { _ ->
        val granted = checkStoragePermission()
        hasStoragePermission = granted
        if (granted) {
            lifecycleScope.launch {
                PichiPlayerApp.instance.repository.rescan()
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()

        hasStoragePermission = checkStoragePermission()
        if (hasStoragePermission) {
            lifecycleScope.launch {
                val autoScan = PichiPlayerApp.instance.preferences.autoScanOnStart.first()
                if (autoScan) {
                    PichiPlayerApp.instance.repository.rescan()
                }
            }
        } else {
            requestRequiredPermissions()
        }

        handleIncomingIntent(intent)

        setContent {
            PichiTheme {
                if (!hasStoragePermission) {
                    PermissionRequiredState(
                        onGrantClick = { requestRequiredPermissions() }
                    )
                } else {
                    PichiNavHost(
                        onEnterPiP = { enterPictureInPicture() }
                    )
                }
            }
        }
    }

    override fun onResume() {
        super.onResume()
        val current = checkStoragePermission()
        if (current != hasStoragePermission) {
            hasStoragePermission = current
            if (current) {
                lifecycleScope.launch {
                    PichiPlayerApp.instance.repository.rescan()
                }
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleIncomingIntent(intent)
    }

    private fun checkStoragePermission(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            ContextCompat.checkSelfPermission(this, Manifest.permission.READ_MEDIA_VIDEO) == PackageManager.PERMISSION_GRANTED
        } else {
            ContextCompat.checkSelfPermission(this, Manifest.permission.READ_EXTERNAL_STORAGE) == PackageManager.PERMISSION_GRANTED
        }
    }

    private fun requestRequiredPermissions() {
        val permissions = mutableListOf<String>()

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            if (ContextCompat.checkSelfPermission(this, Manifest.permission.READ_MEDIA_VIDEO) != PackageManager.PERMISSION_GRANTED) {
                permissions.add(Manifest.permission.READ_MEDIA_VIDEO)
            }
            if (ContextCompat.checkSelfPermission(this, Manifest.permission.POST_NOTIFICATIONS) != PackageManager.PERMISSION_GRANTED) {
                permissions.add(Manifest.permission.POST_NOTIFICATIONS)
            }
        } else {
            if (ContextCompat.checkSelfPermission(this, Manifest.permission.READ_EXTERNAL_STORAGE) != PackageManager.PERMISSION_GRANTED) {
                permissions.add(Manifest.permission.READ_EXTERNAL_STORAGE)
            }
        }

        if (permissions.isNotEmpty()) {
            permissionLauncher.launch(permissions.toTypedArray())
        }
    }

    private fun handleIncomingIntent(intent: Intent?) {
        if (intent?.action == Intent.ACTION_VIEW) {
            val uri: Uri? = intent.data
            if (uri != null) {
                lifecycleScope.launch {
                    val metadata = MediaMetadataExtractor.extract(this@MainActivity, uri)
                    val displayName = uri.lastPathSegment ?: "External Video"
                    val video = VideoEntity(
                        id = uri.hashCode().toLong(),
                        contentUri = uri.toString(),
                        filePath = null,
                        displayName = displayName,
                        folderName = "External",
                        durationMs = 0L,
                        width = 1920,
                        height = 1080,
                        videoCodec = metadata.videoCodec,
                        audioCodec = metadata.audioCodec
                    )
                    PichiPlayerApp.instance.playerManager.playVideo(video)
                }
            }
        }
    }

    fun enterPictureInPicture() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            PichiPlayerApp.instance.playerManager.setInPipMode(true)
            val playerState = PichiPlayerApp.instance.playerManager.uiState.value
            val width = playerState.currentVideo?.width ?: 16
            val height = playerState.currentVideo?.height ?: 9

            val rational = if (width > 0 && height > 0) {
                val ratio = (width.toFloat() / height.toFloat()).coerceIn(0.41841f, 2.39f)
                val num = (ratio * 100).toInt()
                Rational(num, 100)
            } else Rational(16, 9)

            val params = PictureInPictureParams.Builder()
                .setAspectRatio(rational)
                .build()

            enterPictureInPictureMode(params)
        }
    }

    override fun onUserLeaveHint() {
        super.onUserLeaveHint()
        val playerState = PichiPlayerApp.instance.playerManager.uiState.value
        if (playerState.isPlaying) {
            lifecycleScope.launch {
                val autoPip = PichiPlayerApp.instance.preferences.autoPipEnabled.first()
                if (autoPip) {
                    enterPictureInPicture()
                }
            }
        }
    }

    override fun onPictureInPictureModeChanged(isInPictureInPictureMode: Boolean, newConfig: Configuration) {
        super.onPictureInPictureModeChanged(isInPictureInPictureMode, newConfig)
        PichiPlayerApp.instance.playerManager.setInPipMode(isInPictureInPictureMode)
    }
}

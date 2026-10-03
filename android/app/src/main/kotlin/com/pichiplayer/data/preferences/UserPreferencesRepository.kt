package com.pichiplayer.data.preferences

import android.content.Context
import android.content.SharedPreferences
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow

data class AppPreferences(
    // Playback
    val resumePlayback: Boolean = true,
    val autoPlayNext: Boolean = true,
    val defaultSpeed: Float = 1.0f,
    val defaultOrientation: String = "Auto", // Auto, Landscape, Portrait
    val doubleTapSeekSeconds: Int = 10,
    val hardwareDecoding: Boolean = true,
    val decoderMode: String = "auto", // auto, hw, sw
    val lastSeenVersionCode: Int = 0,

    // Appearance
    val themeMode: String = "Dark Cinematic",
    val accentColorName: String = "Electric Blue",
    val enableGlowEffects: Boolean = true,

    // Subtitles
    val preferredLanguage: String = "Auto",
    val subtitleStyleName: String = "Cinema",
    val subtitleFontSize: Int = 18,
    val externalSubtitlesEnabled: Boolean = true,

    // Library
    val autoScanLibrary: Boolean = true,
    val generateThumbnails: Boolean = true,
    val showHiddenFolders: Boolean = false,

    // Background & PiP
    val backgroundPlayback: Boolean = true,
    val pictureInPicture: Boolean = true,
    val autoEnterPip: Boolean = false,
    val leavingAppBehavior: String = "Open PiP" // Open PiP, Background Playback, Pause
)

class UserPreferencesRepository(context: Context) {
    private val prefs: SharedPreferences = context.getSharedPreferences("pichi_prefs", Context.MODE_PRIVATE)

    private val _preferencesFlow = MutableStateFlow(loadFromPrefs())
    val preferencesFlow: StateFlow<AppPreferences> = _preferencesFlow.asStateFlow()

    // Individual StateFlow accessors
    val resumePlayback = MutableStateFlow(prefs.getBoolean("resumePlayback", true))
    val hardwareAcceleration = MutableStateFlow(prefs.getBoolean("hardwareDecoding", true))
    val backgroundPlaybackEnabled = MutableStateFlow(prefs.getBoolean("backgroundPlayback", true))
    val autoPipEnabled = MutableStateFlow(prefs.getBoolean("autoEnterPip", true))
    val autoScanOnStart = MutableStateFlow(prefs.getBoolean("autoScanLibrary", true))
    val generateThumbnails = MutableStateFlow(prefs.getBoolean("generateThumbnails", true))
    val defaultPlaybackSpeed = MutableStateFlow(prefs.getFloat("defaultSpeed", 1.0f))
    val subtitleFontSize = MutableStateFlow(prefs.getInt("subtitleFontSize", 18))
    val decoderMode = MutableStateFlow(prefs.getString("decoderMode", "auto") ?: "auto")
    val lastSeenVersionCode = MutableStateFlow(prefs.getInt("lastSeenVersionCode", 0))

    private fun loadFromPrefs(): AppPreferences {
        return AppPreferences(
            resumePlayback = prefs.getBoolean("resumePlayback", true),
            autoPlayNext = prefs.getBoolean("autoPlayNext", true),
            defaultSpeed = prefs.getFloat("defaultSpeed", 1.0f),
            defaultOrientation = prefs.getString("defaultOrientation", "Auto") ?: "Auto",
            doubleTapSeekSeconds = prefs.getInt("doubleTapSeekSeconds", 10),
            hardwareDecoding = prefs.getBoolean("hardwareDecoding", true),
            themeMode = prefs.getString("themeMode", "Dark Cinematic") ?: "Dark Cinematic",
            accentColorName = prefs.getString("accentColorName", "Electric Blue") ?: "Electric Blue",
            enableGlowEffects = prefs.getBoolean("enableGlowEffects", true),
            preferredLanguage = prefs.getString("preferredLanguage", "Auto") ?: "Auto",
            subtitleStyleName = prefs.getString("subtitleStyleName", "Cinema") ?: "Cinema",
            subtitleFontSize = prefs.getInt("subtitleFontSize", 18),
            externalSubtitlesEnabled = prefs.getBoolean("externalSubtitlesEnabled", true),
            autoScanLibrary = prefs.getBoolean("autoScanLibrary", true),
            generateThumbnails = prefs.getBoolean("generateThumbnails", true),
            showHiddenFolders = prefs.getBoolean("showHiddenFolders", false),
            backgroundPlayback = prefs.getBoolean("backgroundPlayback", true),
            pictureInPicture = prefs.getBoolean("pictureInPicture", true),
            autoEnterPip = prefs.getBoolean("autoEnterPip", true),
            leavingAppBehavior = prefs.getString("leavingAppBehavior", "Open PiP") ?: "Open PiP",
            decoderMode = prefs.getString("decoderMode", "auto") ?: "auto",
            lastSeenVersionCode = prefs.getInt("lastSeenVersionCode", 0)
        )
    }

    fun setDecoderMode(value: String) {
        prefs.edit().putString("decoderMode", value).apply()
        decoderMode.value = value
        _preferencesFlow.value = _preferencesFlow.value.copy(decoderMode = value)
    }

    fun setLastSeenVersionCode(value: Int) {
        prefs.edit().putInt("lastSeenVersionCode", value).apply()
        lastSeenVersionCode.value = value
        _preferencesFlow.value = _preferencesFlow.value.copy(lastSeenVersionCode = value)
    }

    fun setResumePlayback(value: Boolean) {
        prefs.edit().putBoolean("resumePlayback", value).apply()
        resumePlayback.value = value
        _preferencesFlow.value = _preferencesFlow.value.copy(resumePlayback = value)
    }

    fun setHardwareAcceleration(value: Boolean) {
        prefs.edit().putBoolean("hardwareDecoding", value).apply()
        hardwareAcceleration.value = value
        _preferencesFlow.value = _preferencesFlow.value.copy(hardwareDecoding = value)
    }

    fun setBackgroundPlaybackEnabled(value: Boolean) {
        prefs.edit().putBoolean("backgroundPlayback", value).apply()
        backgroundPlaybackEnabled.value = value
        _preferencesFlow.value = _preferencesFlow.value.copy(backgroundPlayback = value)
    }

    fun setAutoPipEnabled(value: Boolean) {
        prefs.edit().putBoolean("autoEnterPip", value).apply()
        autoPipEnabled.value = value
        _preferencesFlow.value = _preferencesFlow.value.copy(autoEnterPip = value)
    }

    fun setAutoScanOnStart(value: Boolean) {
        prefs.edit().putBoolean("autoScanLibrary", value).apply()
        autoScanOnStart.value = value
        _preferencesFlow.value = _preferencesFlow.value.copy(autoScanLibrary = value)
    }

    fun setGenerateThumbnails(value: Boolean) {
        prefs.edit().putBoolean("generateThumbnails", value).apply()
        generateThumbnails.value = value
        _preferencesFlow.value = _preferencesFlow.value.copy(generateThumbnails = value)
    }

    fun setDefaultPlaybackSpeed(speed: Float) {
        prefs.edit().putFloat("defaultSpeed", speed).apply()
        defaultPlaybackSpeed.value = speed
        _preferencesFlow.value = _preferencesFlow.value.copy(defaultSpeed = speed)
    }

    fun setSubtitleFontSize(size: Int) {
        prefs.edit().putInt("subtitleFontSize", size).apply()
        subtitleFontSize.value = size
        _preferencesFlow.value = _preferencesFlow.value.copy(subtitleFontSize = size)
    }

    fun resetPlayerSettings() {
        prefs.edit().clear().apply()
        _preferencesFlow.value = AppPreferences()
        resumePlayback.value = true
        hardwareAcceleration.value = true
        backgroundPlaybackEnabled.value = true
        autoPipEnabled.value = true
        autoScanOnStart.value = true
        generateThumbnails.value = true
        defaultPlaybackSpeed.value = 1.0f
        subtitleFontSize.value = 18
    }
}

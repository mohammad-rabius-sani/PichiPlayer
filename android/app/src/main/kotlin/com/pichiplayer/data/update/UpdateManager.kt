package com.pichiplayer.data.update

import android.content.Context
import android.os.Build
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import org.json.JSONObject
import java.io.BufferedReader
import java.io.InputStreamReader
import java.net.HttpURLConnection
import java.net.URL

data class AppUpdateInfo(
    val versionCode: Int,
    val versionName: String,
    val minSupportedVersion: Int,
    val downloadUrl: String,
    val releasesPageUrl: String,
    val releaseDate: String,
    val title: String,
    val message: String,
    val changelog: List<String>,
    val isForceUpdate: Boolean,
    val apkSize: String
)

sealed class UpdateCheckResult {
    data class Available(val info: AppUpdateInfo) : UpdateCheckResult()
    data class UpToDate(val info: AppUpdateInfo) : UpdateCheckResult()
    data class Error(val message: String, val fallbackInfo: AppUpdateInfo?) : UpdateCheckResult()
}

object UpdateManager {
    private const val REMOTE_CONFIG_URL =
        "https://raw.githubusercontent.com/mohammad-rabius-sani/PichiPlayer/main/update.json"

    fun getCurrentVersionCode(context: Context): Int {
        return try {
            val pInfo = context.packageManager.getPackageInfo(context.packageName, 0)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                pInfo.longVersionCode.toInt()
            } else {
                @Suppress("DEPRECATION")
                pInfo.versionCode
            }
        } catch (_: Exception) {
            100
        }
    }

    fun getCurrentVersionName(context: Context): String {
        return try {
            context.packageManager.getPackageInfo(context.packageName, 0).versionName ?: "1.0.0"
        } catch (_: Exception) {
            "1.0.0"
        }
    }

    fun getLocalBundledInfo(context: Context): AppUpdateInfo? {
        return try {
            val jsonString = context.assets.open("update.json").bufferedReader().use { it.readText() }
            parseJson(jsonString)
        } catch (_: Exception) {
            null
        }
    }

    suspend fun checkForUpdates(context: Context): UpdateCheckResult = withContext(Dispatchers.IO) {
        val currentCode = getCurrentVersionCode(context)
        var remoteJson: String? = null

        try {
            val url = URL(REMOTE_CONFIG_URL)
            val connection = (url.openConnection() as HttpURLConnection).apply {
                connectTimeout = 4000
                readTimeout = 4000
                requestMethod = "GET"
                setRequestProperty("Accept", "application/json")
            }

            if (connection.responseCode == HttpURLConnection.HTTP_OK) {
                val reader = BufferedReader(InputStreamReader(connection.inputStream))
                remoteJson = reader.use { it.readText() }
            }
            connection.disconnect()
        } catch (_: Exception) {
            // Network failure or repo not yet live
        }

        val jsonToParse = remoteJson ?: try {
            context.assets.open("update.json").bufferedReader().use { it.readText() }
        } catch (_: Exception) {
            null
        }

        if (jsonToParse == null) {
            return@withContext UpdateCheckResult.Error(
                message = "Unable to fetch update information. Check your internet connection.",
                fallbackInfo = null
            )
        }

        try {
            val updateInfo = parseJson(jsonToParse)
            if (updateInfo.versionCode > currentCode) {
                UpdateCheckResult.Available(updateInfo)
            } else {
                UpdateCheckResult.UpToDate(updateInfo)
            }
        } catch (e: Exception) {
            UpdateCheckResult.Error(
                message = "Failed to parse update data: ${e.localizedMessage}",
                fallbackInfo = getLocalBundledInfo(context)
            )
        }
    }

    private fun parseJson(jsonString: String): AppUpdateInfo {
        val json = JSONObject(jsonString)
        val changelogArray = json.optJSONArray("changelog")
        val changelog = mutableListOf<String>()
        if (changelogArray != null) {
            for (i in 0 until changelogArray.length()) {
                changelog.add(changelogArray.optString(i))
            }
        }

        return AppUpdateInfo(
            versionCode = json.optInt("versionCode", 100),
            versionName = json.optString("versionName", "1.0.0"),
            minSupportedVersion = json.optInt("minSupportedVersion", 100),
            downloadUrl = json.optString(
                "downloadUrl",
                "https://github.com/mohammad-rabius-sani/PichiPlayer/releases/latest/download/PichiPlayer.apk"
            ),
            releasesPageUrl = json.optString(
                "releasesPageUrl",
                "https://github.com/mohammad-rabius-sani/PichiPlayer/releases"
            ),
            releaseDate = json.optString("releaseDate", "October 3, 2026"),
            title = json.optString("title", "PichiPlayer Update"),
            message = json.optString("message", "A new version of PichiPlayer is available."),
            changelog = changelog,
            isForceUpdate = json.optBoolean("isForceUpdate", false),
            apkSize = json.optString("apkSize", "15.48 MB")
        )
    }
}

package com.pichiplayer.media.metadata

import android.content.Context
import android.media.MediaExtractor
import android.media.MediaFormat
import android.media.MediaMetadataRetriever
import android.net.Uri
import android.os.Build

data class ExtractedVideoMetadata(
    val videoCodec: String? = null,
    val audioCodec: String? = null,
    val frameRate: Float? = null,
    val bitrate: Long? = null,
    val isHdr: Boolean = false,
    val audioChannels: Int? = null,
    val colorStandard: Int? = null,
    val colorTransfer: Int? = null
)

object MediaMetadataExtractor {

    fun extract(context: Context, contentUri: Uri): ExtractedVideoMetadata {
        var videoCodec: String? = null
        var audioCodec: String? = null
        var frameRate: Float? = null
        var bitrate: Long? = null
        var isHdr = false
        var audioChannels: Int? = null
        var colorStandard: Int? = null
        var colorTransfer: Int? = null

        // 1. Try MediaMetadataRetriever
        try {
            val retriever = MediaMetadataRetriever()
            retriever.setDataSource(context, contentUri)

            val bitrateStr = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_BITRATE)
            if (bitrateStr != null) bitrate = bitrateStr.toLongOrNull()

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                val colorStandardStr = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_COLOR_STANDARD)
                val colorTransferStr = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_COLOR_TRANSFER)
                colorStandard = colorStandardStr?.toIntOrNull()
                colorTransfer = colorTransferStr?.toIntOrNull()
                // Color transfer 6 (ST2084 / PQ) or 7 (HLG) indicates HDR
                if (colorTransfer == 6 || colorTransfer == 7) {
                    isHdr = true
                }
            }
            retriever.release()
        } catch (_: Exception) {}

        // 2. Try MediaExtractor for precise track codecs and frame rate
        try {
            val extractor = MediaExtractor()
            extractor.setDataSource(context, contentUri, null)
            val trackCount = extractor.trackCount

            for (i in 0 until trackCount) {
                val format = extractor.getTrackFormat(i)
                val mime = format.getString(MediaFormat.KEY_MIME) ?: continue

                if (mime.startsWith("video/") && videoCodec == null) {
                    videoCodec = formatMimeToReadable(mime)
                    if (format.containsKey(MediaFormat.KEY_FRAME_RATE)) {
                        frameRate = try {
                            format.getFloat(MediaFormat.KEY_FRAME_RATE)
                        } catch (_: Exception) {
                            format.getInteger(MediaFormat.KEY_FRAME_RATE).toFloat()
                        }
                    }
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                        if (format.containsKey(MediaFormat.KEY_COLOR_STANDARD)) {
                            val std = format.getInteger(MediaFormat.KEY_COLOR_STANDARD)
                            if (std == MediaFormat.COLOR_STANDARD_BT2020) {
                                isHdr = true
                            }
                        }
                    }
                } else if (mime.startsWith("audio/") && audioCodec == null) {
                    audioCodec = formatMimeToReadable(mime)
                    if (format.containsKey(MediaFormat.KEY_CHANNEL_COUNT)) {
                        audioChannels = format.getInteger(MediaFormat.KEY_CHANNEL_COUNT)
                    }
                }
            }
            extractor.release()
        } catch (_: Exception) {}

        return ExtractedVideoMetadata(
            videoCodec = videoCodec,
            audioCodec = audioCodec,
            frameRate = frameRate,
            bitrate = bitrate,
            isHdr = isHdr,
            audioChannels = audioChannels,
            colorStandard = colorStandard,
            colorTransfer = colorTransfer
        )
    }

    private fun formatMimeToReadable(mime: String): String {
        return when {
            mime.contains("av01") || mime.contains("av1") -> "AV1"
            mime.contains("hevc") || mime.contains("h265") -> "HEVC (H.265)"
            mime.contains("avc") || mime.contains("h264") -> "AVC (H.264)"
            mime.contains("vp9") -> "VP9"
            mime.contains("vp8") -> "VP8"
            mime.contains("mpeg2") -> "MPEG-2"
            mime.contains("mp4v") -> "MPEG-4"
            mime.contains("dts-hd") -> "DTS-HD MA"
            mime.contains("dts") -> "DTS"
            mime.contains("ac3") -> "Dolby AC-3"
            mime.contains("eac3") -> "Dolby E-AC-3"
            mime.contains("flac") -> "FLAC"
            mime.contains("opus") -> "Opus"
            mime.contains("mp4a-latm") || mime.contains("aac") -> "AAC"
            mime.contains("mp3") || mime.contains("mpeg") -> "MP3"
            mime.contains("vorbis") -> "Vorbis"
            else -> mime.substringAfter('/')
        }
    }
}

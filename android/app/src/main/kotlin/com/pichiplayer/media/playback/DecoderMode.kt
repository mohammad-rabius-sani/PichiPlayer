package com.pichiplayer.media.playback

enum class DecoderMode(
    val code: String,
    val title: String,
    val shortName: String,
    val description: String
) {
    AUTO(
        code = "auto",
        title = "Auto",
        shortName = "Auto",
        description = "Smart GPU acceleration with automatic software fallback"
    ),
    HW(
        code = "hw",
        title = "Hardware (HW)",
        shortName = "HW",
        description = "Force dedicated GPU/DSP hardware decoding for efficiency"
    ),
    SW(
        code = "sw",
        title = "Software (SW)",
        shortName = "SW",
        description = "Software CPU decoding for maximum compatibility"
    );

    companion object {
        fun fromCode(code: String?): DecoderMode =
            entries.firstOrNull { it.code.equals(code, ignoreCase = true) } ?: AUTO
    }
}

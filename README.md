# PichiPlayer 🎬⚡

[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](https://github.com/mohammad-rabius-sani/PichiPlayer/releases)
[![Platform](https://img.shields.io/badge/platform-Android%207.0%2B-green.svg)](https://android.com)
[![Media3](https://img.shields.io/badge/engine-AndroidX%20Media3%201.4.1-orange.svg)](https://developer.android.com/media/media3)
[![License](https://img.shields.io/badge/license-Proprietary-red.svg)](#license)

**PichiPlayer** is a modern, ultra-fast, offline video player for Android engineered with **100% Kotlin**, **Jetpack Compose**, and **AndroidX Media3 (ExoPlayer)**. Designed for silky-smooth **2K & 4K** playback, an advanced **Auto / HW / SW decoder engine**, complete format & resolution detection, and responsive micro-animations.

---

## 📥 Download

Get the latest official release APK:

👉 **[Download PichiPlayer v1.0.0 APK](https://github.com/mohammad-rabius-sani/PichiPlayer/releases/latest/download/PichiPlayer.apk)**

Or browse all versions on the [Releases Page](https://github.com/mohammad-rabius-sani/PichiPlayer/releases).

---

## ✨ Highlights & Features

### 🚀 Ultra-Smooth 2K & 4K Playback
- **Asynchronous Buffer Queueing:** Hardware decoding frames are queued off the main playback thread via dedicated handler threads (`forceEnableMediaCodecAsynchronousQueueing()`), eliminating frame drops on 60fps/120fps video streams.
- **High-Bitrate Load Control:** Configured with a generous 64 MB frame buffer ceiling and time-prioritized thresholds for seamless 2K (1440p) and 4K (2160p) local video decoding.
- **Zero-Flicker Surface Transitions:** Transparent shutter initialization and seamless surface rendering prevent black blinks when opening videos or entering Picture-in-Picture.
- **Memory Optimized Thumbnails:** Frame thumbnails are downscaled on the fly, preventing out-of-memory overhead when browsing extensive 4K libraries.

### ⚡ Auto / HW / SW Decoder Engine
- **Auto (Smart Fallback):** Recommended default utilizing GPU hardware MediaCodec acceleration with automated software fallback if unsupported codecs/profiles are detected.
- **HW (Hardware Forced):** Direct VPU/GPU decoding for minimal battery drain and maximum high-frame-rate efficiency.
- **SW (Software Decoding):** CPU-based decoding for maximum resilience on exotic, legacy, or partially corrupted video files.
- **Instant In-Player Switch:** Toggle decoders on the fly directly via the HUD pill `[Decoder: Auto / HW / SW]` without losing your playback position!

### 🎬 Complete Resolution & Format Badges
Accurately categorizes every video in your library:
- **8K UHD** (`7680×4320+`)
- **4K UHD** (`3840×2160`)
- **2K QHD** (`2560×1440` / `2048×1080`)
- **1080p FHD** (`1920×1080`)
- **720p HD** (`1280×720`)
- **480p SD**, **360p**, **240p**, **144p**
- **Format Indicators:** Dedicated badges for **3GP** (`.3gp`, `.3gpp`), **MKV**, **WEBM**, **AVI**, and **MP4**.

### 🎨 Bouncy Micro-Animations & Fluid HUD
- **Dynamic Rotation Swivel:** Fluid spring-damped swivel animation on the rotation icon.
- **Play/Pause Bounce:** Tactile spring pulse animation when toggling playback.
- **Streamlined Home Player:** Quick 10-second seek buttons, play/pause, and a close button that cleanly reveals last-played metadata.
- **Ergonomic Top Bar:** Subtitles and PiP controls conveniently positioned alongside the rotation lock.

### 🔄 Built-in Update Manager & "What's New"
- **GitHub Release Integration:** Automatically checks for new versions via `update.json` hosted on GitHub.
- **What's New Modal:** Greets users with interactive release highlights upon the first launch after each update.

---

## 🛠️ Architecture & Tech Stack

- **UI Layer:** Jetpack Compose + Material 3 Dark Cinematic Design System
- **Playback Engine:** AndroidX Media3 (ExoPlayer 1.4.1) + Custom MediaCodecSelector
- **Local Database:** Android Room DB with Coroutines & StateFlow
- **Image & Thumbnail Pipeline:** Coil 2.7 with downscaled frame extraction
- **Language:** 100% Kotlin

---

## 🏗️ Building from Source

### Prerequisites
- Android Studio Ladybug or newer
- JDK 17 (`D:\java\jdk-17.0.12+7` or standard OpenJDK 17)
- Android SDK 35 (Platform 35, Build-Tools 35.0.0)

### Clone & Build
```bash
git clone https://github.com/mohammad-rabius-sani/PichiPlayer.git
cd PichiPlayer/android
./gradlew assembleRelease
```
The compiled APK will be located at:
`android/app/build/outputs/apk/release/app-release.apk`

---

## 👤 Author & Credits

- **Creator:** Rabius Sani (`mohammad.rabius.sanii@gmail.com`)
- **Role:** Owner & CEO at PichiPie & Freelancer
- **Company:** PichiPie

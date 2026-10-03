# PichiPlayer - Release Notes

## Version 1.0.0 (Build 100) - October 3, 2026 (Initial Release)

### 🚀 Highlights & Major Improvements

#### 1. Smart Resolution Badges & Universal Format Detection
- **Precise Dimension Math:** Completely resolved the issue where 1080p videos (1920x1080) were misidentified as 2K. The resolution classification now uses accurate bounding intervals based on video orientation (min/max dimensions).
- **Comprehensive Badge System:**
  - **8K UHD** (`7680×4320+`): Vibrant Gold/Red badge.
  - **4K UHD** (`3840×2160`): High-contrast Amber/Gold badge.
  - **2K QHD** (`2560×1440` / `2048×1080`): Electric Cyan badge.
  - **1080p FHD** (`1920×1080`): Emerald Green badge.
  - **720p HD** (`1280×720`): Sky Blue badge.
  - **480p SD** (`854×480` / `640×480`): Slate Gray badge.
  - **360p / 240p / 144p**: Dedicated compact badges for lower-resolution clips.
- **Container / Format Indicators:** Added dedicated badges for **3GP** (`.3gp`, `.3gpp`), **MKV**, **WEBM**, **AVI**, and other legacy/modern containers.
- **HDR Tag:** Retained violet badge for High Dynamic Range content.

#### 2. Auto / HW / SW Decoder Engine
- **Three Dedicated Decoder Modes:**
  - **Auto (Smart Fallback):** Default recommended mode utilizing hardware GPU acceleration with seamless software fallback on unsupported frames.
  - **Hardware (HW):** Forces dedicated hardware MediaCodec decoder pipelines for maximum battery savings and high-efficiency 4K/60fps playback.
  - **Software (SW):** CPU-based software decoding pipeline for maximum compatibility with exotic codecs, corrupted files, or devices with buggy GPU vendor drivers.
- **Instant In-Player Switching:** Added a **Decoder Pill** `[Decoder: Auto / HW / SW]` directly in the bottom control strip. Tapping it reconfigures the active decoder without losing the playback position or detaching the video surface!
- **Persistent Setting:** Configurable in the Settings menu under the **PLAYBACK** section.

#### 3. 4K / 8K High-Bitrate Memory & Stability Optimization
- Added `largeHeap="true"` and hardware-accelerated window compositing in `AndroidManifest.xml`.
- Configured Media3 `DefaultLoadControl` with a strictly bounded 32 MB buffer ceiling and low-latency startup (`bufferForPlaybackMs = 500ms`), preventing multi-hundred megabyte heap bloat and OutOfMemory crashes on high-bitrate 4K files.
- Bounded bitmap decodes in `ThumbnailCacheManager` using `retriever.getScaledFrameAtTime()`.
- Safe surface detachment when navigating between inline and fullscreen playback.

#### 4. Bouncy Micro-Animations & UI Enhancements
- **Dynamic Rotation Swivel:** Rotating the screen triggers a smooth spring-physics animation (0° to 90°) on the rotation button.
- **Play/Pause Pulse:** Bouncy spring pulse animation when toggling playback state.
- **Control Bar Transitions:** Top and bottom HUDs slide and fade cleanly using spring motion specifications.
- **Rebalanced Top Bar:** Subtitles and PiP buttons relocated to the top bar beside the Rotation button for intuitive one-hand reach.
- **Streamlined Home Inline Player:** Inline card now offers quick **-10s Seek**, **Play/Pause**, **+10s Seek**, and a **Close (X)** button that gracefully pauses and shows the last-played video's metadata card.

#### 5. Automated Updates & First-Launch "What's New" Dialog
- **Update System:** Online/offline update checker backed by `update.json` and hosted on GitHub Releases:
  - Download URL: `https://github.com/mohammad-rabius-sani/PichiPlayer/releases/latest/download/PichiPlayer.apk`
  - Releases Page: `https://github.com/mohammad-rabius-sani/PichiPlayer/releases`
- **What's New Dialog:** Automatically introduces new features on the first launch after an update, retaining state in user preferences so it appears only once per version.
- **Creator Attribution:** Updated in Settings to strictly read `Owner & CEO at PichiPie & Freelancer`.

---

## Technical Specifications
- **Package Name:** `com.pichiplayer`
- **Target SDK:** 35 (Android 15)
- **Min SDK:** 24 (Android 7.0 Nougat)
- **Architecture:** 100% Kotlin + Jetpack Compose + Media3 ExoPlayer + Room DB + Coroutines/StateFlow
- **Author:** Rabius Sani (`mohammad.rabius.sanii@gmail.com`)
- **Company:** PichiPie

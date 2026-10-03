# PichiPlayer - Release Notes (v1.0.0)

## Overview
PichiPlayer v1.0.0 is the first official release, bringing ultra-smooth 2K & 4K playback, full resolution badge detection (240p to 4K/8K and 3GP), a flexible Auto/HW/SW hardware decoder engine, buttery-smooth micro-animations, an automated update manager, and a first-launch "What's New" modal.

### Key Changes
1. **Full Video Resolution & Format Badges:**
   - Accurately classifies 8K, 4K, 2K, 1080p (FHD), 720p (HD), 480p (SD), 360p, 240p, 144p, and 3GP.
   - Fixed the bug where 1080p (1920x1080) was wrongly labeled 2K.
   - Shows container formats like 3GP, MKV, WEBM, AVI.

2. **Auto / HW / SW Decoder Switcher:**
   - **Auto:** Smart hardware GPU acceleration with automatic software fallback.
   - **HW:** Dedicated GPU/DSP hardware decoding for efficiency and 4K/60fps speed.
   - **SW:** Software CPU decoding for maximum compatibility with legacy/corrupted video files.
   - Switchable directly from the Player HUD pill or Settings menu.

3. **4K & High-Res Smooth Playback:**
   - 32 MB bounded buffer ceiling preventing OutOfMemory crashes.
   - Hardware-scaled frame thumbnails and clean surface transitions.

4. **Animations & Polish:**
   - Spring swivel rotation animation.
   - Bouncy play/pause pulse.
   - Rebalanced top bar (Subtitles + PiP moved beside rotate).
   - Cleaned inline home player with -10s, play/pause, +10s, and close button.

5. **Update Manager & Release Notes:**
   - `update.json` configured with download URL:
     `https://github.com/mohammad-rabius-sani/PichiPlayer/releases/latest/download/PichiPlayer.apk`
   - "What's New" popup shown on first launch after updating.
   - Interactive Update Dialog in Settings.

# Vulcanium

**Vulcanium** is a Chromium-based browser build & patch set focused on first-class **Vulkan rendering**, **Vulkan Video Decoding (`VkVideo`)**, and **Linux Wayland/DMA-BUF** stability across **AMD (RADV)**, **Intel (ANV)**, and **NVIDIA (proprietary Vulkan)** GPUs.

## Goals

1. **Vulkan & ANGLE-Vulkan Stability (`patches/vulkan/`)**
   - Fix `DmaBufImageSiblingVkLinux` format/modifier validation failures and `EGL_BAD_PARAMETER` GPU process crashes.
   - Ensure smooth Skia Ganesh/Graphite + ANGLE Vulkan initialization without falling back to software rendering.
   - Multi-GPU / render-node selection improvements (hybrid laptops, NVIDIA + Mesa).

2. **Vulkan Video Decoding (`patches/video-decode/`)**
   - Implement/enable `VulkanVideoDecoder` (`VK_KHR_video_decode_queue`, H.264, H.265/HEVC, AV1, VP9 where supported by driver) as a cross-vendor alternative to VA-API.
   - Integrate with Chromium's `media/gpu/` pipeline and zero-copy DMA-BUF/Vulkan image sharing.

3. **Wayland & Ozone (`patches/wayland/`)**
   - Allow native `--ozone-platform=wayland` with `--use-gl=angle --use-angle=vulkan` cleanly.
   - Improve DMA-BUF modifier negotiation and presentation on KWin, Mutter, and wlroots/Hyprland compositors.

4. **Vulcanium Branding & Defaults (`patches/branding/`, `config/`)**
   - Clean `Vulcanium` branding, desktop entry, and sensible default flags (`config/vulcanium-flags.conf`).

## Project Layout

```text
vulcanium/
├── arch/                   # Arch Linux PKGBUILD & base distro patches
├── config/
│   ├── args.gn             # Shared GN build arguments (Vulkan, codecs, Wayland)
│   └── vulcanium-flags.conf# Default runtime flags for Linux/Wayland/Vulkan
├── patches/
│   ├── series              # Ordered patch list applied on top of Chromium
│   ├── branding/           # Vulcanium branding & UI strings
│   ├── vulkan/             # ANGLE/Skia/Vulkan & DMA-BUF patches
│   ├── video-decode/       # Vulkan Video Decoding (VkVideo) patches
│   └── wayland/            # Ozone/Wayland presentation & modifier patches
├── scripts/
│   ├── fetch-source.sh     # Download & extract Chromium tarball (+ git init for patch dev)
│   ├── apply-patches.sh    # Apply patches listed in patches/series
│   ├── new-patch.sh        # Export git diff from src/ into patches/
│   └── build.sh            # Standalone gn + ninja build script
└── src/                    # (gitignored) Downloaded tarballs & extracted Chromium source
```

## Quick Start

### 1. Fetch & Prepare Chromium Source (for patch development or standalone builds)

```bash
./scripts/fetch-source.sh
./scripts/apply-patches.sh
```

### 2. Standalone Build (`gn` + `ninja`)

```bash
./scripts/build.sh
```

### 3. Arch Linux Package (`makepkg`)

```bash
cd arch
makepkg -si
```

## Target Chromium Version

- **Base Version:** `157.0.8103.78` (synced with Arch Linux `chromium`)

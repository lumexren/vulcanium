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

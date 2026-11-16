# Vulcanium

Chromium `157.0.8103.78` patch set and Arch Linux packaging focused on native **Linux Wayland + Vulkan** rendering and **Vulkan Video** hardware decoding across NVIDIA, AMD, and Intel GPUs.

## Features

- **Native Wayland + Vulkan (`patches/wayland/`, `patches/vulkan/`):**
  - `GaneshVulkan` + `ANGLE_VULKAN` via `VK_KHR_wayland_surface` swapchain, premultiplied alpha, and Wayland windowing state synchronization.
  - DMA-BUF linear modifier fallback and `VK_IMAGE_LAYOUT_GENERAL` transitions.
- **Vulkan Video Decoding (`patches/video-decode/`):**
  - `VulkanVideoDecoder` backed by FFmpeg Vulkan hwaccel for H.264, HEVC/H.265, VP9, and AV1 with zero-copy DMA-BUF frame wrapping.
- **Isolated Branding & Defaults (`patches/branding/`, `config/`):**
  - Separate profile directory, `/usr/bin/vulcanium` launcher, and default Wayland/Vulkan/zero-copy runtime flags.

## Screenshots

### Graphics Feature Status (`chrome://gpu`)
![Graphics Feature Status](docs/screenshots/chrome-gpu.png)

### Driver Information (`GaneshVulkan` + `ANGLE_VULKAN`)
![Driver Information](docs/screenshots/driver-info.png)

### Video Acceleration Information (`H.264`, `HEVC`, `VP9`, `AV1`)
![Video Acceleration Information](docs/screenshots/video-acceleration.png)

## Build

### Arch Linux (`makepkg`)

```bash
cd arch
makepkg -si
```

### Standalone (`gn` + `ninja`)

```bash
./scripts/fetch-source.sh
./scripts/apply-patches.sh
./scripts/build.sh
```

## Notes & Limitations

- **Base Version:** Targets Chromium `157.0.8103.78`.
- **In-Process GPU (`--in-process-gpu`):** Enabled by default in `config/vulcanium-flags.conf` so `VK_KHR_wayland_surface` on the GPU thread can share the browser process's `wl_display` and `wl_surface` handles directly.
- **Tested Environment:** Arch Linux, KDE Plasma Wayland (KWin), NVIDIA RTX 3060 (`620.70.06`).

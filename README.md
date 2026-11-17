# Vulcanium

Chromium `157.0.8103.78` patch set and Arch Linux packaging focused on native **Linux Wayland + Vulkan** rendering and **Vulkan Video** hardware decoding/encoding.

## Features

- **Native Wayland + Vulkan (`patches/wayland/`, `patches/vulkan/`):**
  - `GaneshVulkan` + `ANGLE_VULKAN` via `VK_KHR_wayland_surface` swapchain, premultiplied alpha, and Wayland windowing state synchronization.
  - DMA-BUF linear modifier fallback and `VK_IMAGE_LAYOUT_GENERAL` transitions.
- **Vulkan Video Decoding & Encoding (`patches/video-decode/`, `patches/video-encode/`):**
  - `VulkanVideoDecoder` (H.264, HEVC/H.265, VP9, AV1) backed by FFmpeg Vulkan hwaccel with zero-copy DMA-BUF frame wrapping.
  - `VulkanVideoEncodeAccelerator` (H.264, HEVC/H.265) backed by FFmpeg `h264_vulkan` and `hevc_vulkan` (`VK_KHR_video_encode_queue`).
- **Isolated Branding & Safe Defaults (`patches/branding/`, `config/`):**
  - Separate profile directory, default Wayland/Vulkan runtime flags, and automatic launcher neutralization of conflicting VA-API flags.

## Install (Arch Linux / AUR)

Prebuilt portable `x86_64` binaries (`-bin`) and source packages are available on the AUR:

- [`vulcanium`](https://aur.archlinux.org/packages/vulcanium) / [`vulcanium-bin`](https://aur.archlinux.org/packages/vulcanium-bin)
- [`ungoogled-vulcanium`](https://aur.archlinux.org/packages/ungoogled-vulcanium) / [`ungoogled-vulcanium-bin`](https://aur.archlinux.org/packages/ungoogled-vulcanium-bin)

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

## Screenshots

### Graphics Feature Status (`chrome://gpu`)
![Graphics Feature Status](docs/screenshots/chrome-gpu.png)

### Driver Information (`GaneshVulkan` + `ANGLE_VULKAN`)
![Driver Information](docs/screenshots/driver-info.png)

### Video Acceleration Information (Decode & Encode)
![Video Acceleration Information](docs/screenshots/video-acceleration.png)

## Notes & Limitations

- Uses `--in-process-gpu` so `VK_KHR_wayland_surface` shares Wayland surface handles directly.
- Tested on Arch Linux, KDE Plasma Wayland, and NVIDIA RTX 3060 (AMD and Intel GPUs are currently untested).

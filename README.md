# Vulcanium

Chromium `157.0.8103.78` patch set and Arch Linux packaging focused on native **Linux Wayland + Vulkan** rendering and **Vulkan Video** hardware decoding across NVIDIA, AMD, and Intel GPUs.

## Features

- **Native Wayland + Vulkan (`patches/wayland/`, `patches/vulkan/`):**
  - `GaneshVulkan` + `ANGLE_VULKAN` via `VK_KHR_wayland_surface` swapchain, premultiplied alpha, and Wayland windowing state synchronization.
  - DMA-BUF linear modifier fallback and `VK_IMAGE_LAYOUT_GENERAL` transitions.
- **Vulkan Video Decoding (`patches/video-decode/`):**
  - `VulkanVideoDecoder` backed by FFmpeg Vulkan hwaccel for H.264, HEVC/H.265, VP9, and AV1 with zero-copy DMA-BUF frame wrapping.
- **Vulkan Video Encoding (`patches/video-encode/`):**
  - `VulkanVideoEncodeAccelerator` backed by FFmpeg `h264_vulkan` and `hevc_vulkan` (`VK_KHR_video_encode_queue`) for H.264 and HEVC/H.265 hardware encoding.
- **Isolated Branding & Defaults (`patches/branding/`, `config/`):**
  - Separate profile directory, `/usr/bin/vulcanium` launcher, and default Wayland/Vulkan/zero-copy runtime flags.

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

### Video Acceleration Information (`H.264`, `HEVC`, `VP9`, `AV1`)
![Video Acceleration Information](docs/screenshots/video-acceleration.png)

### Video Encode Acceleration (`H.264`, `HEVC`)
![Video Encode Acceleration](docs/screenshots/video-encode.png)

## Notes & Limitations

- Targets Chromium `157.0.8103.78`.
- Uses `--in-process-gpu` so `VK_KHR_wayland_surface` shares Wayland surface handles directly.
- Tested on Arch Linux, KDE Plasma Wayland, and NVIDIA RTX 3060.
- **Do not enable VA-API flags (`VaapiOnNvidiaGPUs`, `VaapiVideoDecoder`, `AcceleratedVideoDecodeLinuxGL`, etc.) alongside `VulkanVideoDecode`:** on NVIDIA with `libva-nvidia-driver`, VA-API conflicts with Vulkan video decoding and can cause green flashing during video playback. If your `~/.config/chromium-flags.conf` (or `vulcanium-flags.conf`) has VA-API flags enabled, remove them or add `--disable-features=VaapiVideoDecoder,VaapiVideoEncoder,VaapiVideoDecodeLinuxGL,VaapiOnNvidiaGPUs,AcceleratedVideoDecodeLinuxGL`.

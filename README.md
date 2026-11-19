<div align="center">

<img src="assets/icons/vulcanium.svg" alt="Vulcanium" width="96" />

# Vulcanium

Chromium with Vulkan rendering and Vulkan Video Decoding / Encoding

</div>

> [!IMPORTANT]
> I maintain this project solo and build all three browsers locally on my own machine. Because of that, Chromium version updates are planned for the end of each month. Bug fixes are exempt from this schedule and will be built and released on top of the current version as soon as they are resolved.

## Features

- **Native Wayland + Vulkan:** Out-of-process GPU rendering (`GaneshVulkan` + `ANGLE_VULKAN`) with DMA-BUF support and preserved window alpha.
- **Vulkan Video Decoding & Encoding:** Hardware-accelerated H.264, HEVC/H.265, VP9, and AV1 decoding (`VulkanVideoDecoder`, zero-copy DMA-BUF → `SharedImage`) and H.264/HEVC encoding (`VulkanVideoEncodeAccelerator`) via FFmpeg Vulkan.
- **Isolated Branding & Defaults:** Separate profile directory, Wayland/Vulkan runtime flags, and automatic neutralization of conflicting VA-API flags.

## Install (Arch Linux / AUR)

Prebuilt portable `x86_64` binaries (`-bin`) and source packages are available on the AUR:

- [`vulcanium`](https://aur.archlinux.org/packages/vulcanium) / [`vulcanium-bin`](https://aur.archlinux.org/packages/vulcanium-bin)
- [`helcanium`](https://aur.archlinux.org/packages/helcanium) / [`helcanium-bin`](https://aur.archlinux.org/packages/helcanium-bin)
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

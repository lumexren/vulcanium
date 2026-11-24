<div align="center">

<img src="assets/icons/vulcanium.svg" alt="Vulcanium" width="96" />

# Vulcanium

Chromium with native Wayland Vulkan rendering and Vulkan Video Decoding / Encoding

[Latest Release](https://github.com/lumexren/vulcanium/releases/latest) · [Patches](patches/README.md) · [Hardware Report](https://github.com/lumexren/vulcanium/issues/new?template=hardware_report.yml) · [License (BSD-3-Clause)](LICENSE)

</div>

> [!IMPORTANT]
> I maintain this project solo and build all three browsers locally on my own machine. Because of that, Chromium version updates are planned for the end of each month. Bug fixes are exempt from this schedule and will be built and released on top of the current version as soon as they are resolved.

## Features

- **Native Wayland + Vulkan:** Out-of-process GPU rendering (`GaneshVulkan` + `ANGLE_VULKAN`) with DMA-BUF support and preserved window alpha.
- **Vulkan Video Decoding & Encoding:** Hardware-accelerated H.264, HEVC/H.265, VP9, and AV1 decoding (`VulkanVideoDecoder`, zero-copy DMA-BUF → `SharedImage`) and H.264/HEVC encoding (`VulkanVideoEncodeAccelerator`) via FFmpeg Vulkan.
- **Branding & Sensible Defaults:** Vulcanium / Helcanium branding and Wayland PWA window grouping, preconfigured Wayland/Vulkan flags, and automatic neutralization of conflicting VA-API flags.

## Requirements

- Linux on Wayland with a Vulkan-capable GPU and driver supporting `VK_KHR_video_decode_queue` / `VK_KHR_video_encode_queue`.
- Tested primarily on NVIDIA proprietary drivers; AMD (`RADV`) and Intel (`ANV`) users are welcome to share results via the [Hardware Compatibility report](https://github.com/lumexren/vulcanium/issues/new?template=hardware_report.yml).
- Custom user flags can be added to `~/.config/vulcanium-flags.conf` (or `~/.config/helcanium-flags.conf` for Helcanium); conflicting VA-API flags are stripped automatically by the launcher.

## Install (Arch Linux / AUR)

Prebuilt portable `x86_64` binaries (`-bin`) and source packages are available on the AUR:

| Variant | Base | AUR Packages | Profile & User Flags |
| :--- | :--- | :--- | :--- |
| **Vulcanium** | Chromium | [`vulcanium`](https://aur.archlinux.org/packages/vulcanium) / [`vulcanium-bin`](https://aur.archlinux.org/packages/vulcanium-bin) | `~/.config/chromium` · `~/.config/vulcanium-flags.conf` |
| **Ungoogled Vulcanium** | ungoogled-chromium | [`ungoogled-vulcanium`](https://aur.archlinux.org/packages/ungoogled-vulcanium) / [`ungoogled-vulcanium-bin`](https://aur.archlinux.org/packages/ungoogled-vulcanium-bin) | `~/.config/chromium` · `~/.config/vulcanium-flags.conf` |
| **Helcanium** | Helium | [`helcanium`](https://aur.archlinux.org/packages/helcanium) / [`helcanium-bin`](https://aur.archlinux.org/packages/helcanium-bin) | `~/.config/net.imput.helium` · `~/.config/helcanium-flags.conf` |

```bash
paru -S vulcanium-bin   # or ungoogled-vulcanium-bin / helcanium-bin
```

`vulcanium` and `ungoogled-vulcanium` share `~/.config/chromium` and conflict with `chromium`, `ungoogled-chromium`, and each other. `helcanium` uses Helium's profile directory and can be installed alongside them.

## Build

See [patches/README.md](patches/README.md) for the patch architecture and target files.

### Arch Linux (`makepkg`)

```bash
cd arch
makepkg -si
```

For portable `x86_64` binaries (strips `-march=native` to `-march=x86-64 -mtune=generic`):

```bash
VULCANIUM_PORTABLE=1 makepkg -si
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

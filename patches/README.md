# Vulcanium Patch Architecture

All `.patch` files are applied in the order listed in `patches/series` against Chromium `158.0.8127.36`.
(`helcanium` substitutes `branding/0003-helcanium-branding.patch` in place of `branding/0001-vulcanium-branding.patch`.)

## Patch Categories

### 1. `branding/`
- **Vulcanium / Helcanium Identity & Startup Prompt**:
  - `0001-vulcanium-branding.patch` (`vulcanium`, `ungoogled-vulcanium`): Product name (`Vulcanium`), default `.desktop` ID (`vulcanium.desktop`), icon name (`vulcanium`), and PulseAudio display name. Keeps Chromium's default profile directory (`~/.config/chromium`).
  - `0002-hide-unsafe-webgpu-bad-flag-banner.patch`: Hides the `--enable-unsafe-webgpu` startup warning banner.
  - `0003-helcanium-branding.patch` (`helcanium` only, applied instead of `0001`): Product name (`Helcanium`), `HELCANIUM_DESKTOP`/`HELIUM_DESKTOP`/`CHROME_DESKTOP` override chain (`helcanium.desktop`), icon name, PulseAudio display name, and AppStream RDN (`helcanium`). Keeps Helium's default profile directory (`~/.config/net.imput.helium`).
  - Pre-rendered internal product logos/wordmarks/vector icons are applied alongside patches via `scripts/apply-branding-icons.sh` from `assets/branding/{vulcanium,helcanium}/`.
- Target files:
  - `chrome/app/chromium_strings.grd`, `chrome/app/theme/chromium/BRANDING`
  - `chrome/common/channel_info_posix.cc`, `chrome/browser/shell_integration_linux.cc`
  - `chrome/installer/linux/common/chromium-browser.info`, `media/audio/pulse/pulse_util.cc`
  - `chrome/browser/ui/startup/bad_flags_prompt.cc`

### 2. `vulkan/`
- **ANGLE DMA-BUF, Skia Vulkan & Out-of-Process DMA-BUF Import**:
  - Graceful fallback in `DmaBufImageSiblingVkLinux::initImpl` when DRM modifiers are rejected (`0001`).
  - `VK_IMAGE_LAYOUT_GENERAL` transitions for Ozone Vulkan SharedImages (`0002`).
  - Drops `VkExportMemoryAllocateInfo` when importing DMA-BUFs into `VulkanImage` so NVIDIA out-of-process GPU mode doesn't create shadow allocations / black screens (`0003`).
  - Uses YCbCr-compatible Vulkan image usage flags (`SAMPLED | TRANSFER_SRC | TRANSFER_DST`) when importing multi-planar NV12/P010 DMA-BUFs (`0004`).
  - Matches `disable_rgb_to_yuv_conversion` (`gpu_driver_bug_list.json` #474) by NVIDIA PCI vendor ID (`0x10de`) instead of OpenGL vendor string so Skia+ANGLE+Vulkan also avoids broken hardware RGB->YUV conversion into 2-plane NV12 pixmaps (`0005`).
- Target files:
  - `third_party/angle/src/libANGLE/renderer/vulkan/linux/DmaBufImageSiblingVkLinux.cpp`
  - `gpu/command_buffer/service/shared_image/skia_vk_ozone_image_representation.cc`
  - `gpu/vulkan/vulkan_image_linux.cc`, `ui/ozone/platform/wayland/gpu/vulkan_implementation_wayland.cc`
  - `gpu/config/gpu_driver_bug_list.json`

### 3. `wayland/`
- **Ozone/Wayland, `VK_KHR_wayland_surface` Swapchain & PWA Grouping**:
  - Enable Vulkan on Wayland (`0001`), GBM modifier fallback (`0002`), disable incompatible `wp_linux_drm_syncobj_v1` on Vulkan (`0003`), linear DMA-BUF pixmap allocation (`0004`).
  - Direct `VK_KHR_wayland_surface` swapchain (`0005`), premultiplied alpha + preserved CSD border alpha (dropping `z_order == 0` opaque override) + `ack_configure` / `set_window_geometry` sync (`0006`).
  - Prefixes Wayland PWA `.desktop` files and `xdg_toplevel` `app_id` with the browser's desktop ID (`vulcanium-*` / `helcanium-*`) so installed web apps group separately from the main browser window (`0007`).
- Target files:
  - `ui/ozone/platform/wayland/...`, `gpu/ipc/service/gpu_init.cc`, `gpu/vulkan/vulkan_surface.cc`
  - `chrome/browser/web_applications/os_integration/web_app_shortcut_linux.cc`, `chrome/browser/shell_integration_linux.cc`

### 4. `video-decode/`
- **Vulkan Video Decoding (`VkVideo`)**:
  - Shared GPU-process `VulkanVideoDevice` singleton (`vulkan_video_device.{h,cc}`) with `vkGetPhysicalDeviceVideoCapabilitiesKHR` probing across `H.264`, `HEVC`, `VP9`, and `AV1` decode/encode queues and extent limits, dedicated `VK_QUEUE_TRANSFER_BIT` queue preference, and exportable NV12 DRM modifier probing.
  - `VulkanVideoDecoder` backed by FFmpeg `AV_HWDEVICE_TYPE_VULKAN` (`H.264`, `HEVC/H.265`, `VP9`, `AV1`) gated by probed GPU capabilities, with tiled/linear DMA-BUF output (`vkCmdCopyImage` with semaphore-narrowed pipeline barriers -> 2-plane DMA-BUF -> `MailboxVideoFrameConverter` `SharedImage`).
  - Concurrent decoder cap (`kMaxConcurrentDecoders = 8`) with software fallback, reusable `AVPacket`/`AVFrame`/`VkCommandPool`/`VkCommandBuffer`/`VkFence`, same-config flush fast-path, and bounded DMA-BUF `OutputSlot` pool (`kMaxOutputPoolSize = 12`) with frame-lifetime tracking.
- Target files:
  - `media/base/media_switches.{h,cc}` (`VulkanVideoDecode`)
  - `third_party/ffmpeg/` (Vulkan hwaccel & VP9/AV1/HEVC decoder enablement)
  - `media/gpu/vulkan/vulkan_video_device.{h,cc}`, `media/gpu/vulkan/vulkan_video_decoder.{h,cc}`, `media/gpu/BUILD.gn`, `media/mojo/services/gpu_mojo_media_client_linux.cc`

### 5. `video-encode/`
- **Vulkan Video Encoding (`VkVideo`)**:
  - `VulkanVideoEncodeAccelerator` backed by FFmpeg `h264_vulkan`, `hevc_vulkan`, and `av1_vulkan` (`VK_KHR_video_encode_queue`, dynamically gated by GPU capability probing via `VulkanVideoDevice`).
  - Zero-copy GPU-to-GPU DMA-BUF input path (`CopyDmabufToVkFrame`: imports `MappableSharedImage`/`STORAGE_DMABUFS` native pixmap handles with explicit modifier, image format property, and DMA-BUF size validation into `AVVkFrame` via `vkCmdCopyImage` with semaphore-narrowed barriers), with reusable `AVFrame`/`AVPacket`, low-latency tuning (`tune=ll`, `usage=stream`, `async_depth`), dynamic CBR/VBR bitrate updates, and `ConvertToMemoryMappedFrame` CPU upload fallback.
- Target files:
  - `third_party/ffmpeg/` (`CONFIG_VULKAN_ENCODE`, `h264_vulkan`, `hevc_vulkan`, `av1_vulkan`)
  - `media/base/media_switches.{h,cc}` (`VulkanVideoEncode`)
  - `media/gpu/vulkan/vulkan_video_encode_accelerator.{h,cc}`, `media/gpu/BUILD.gn`, `media/gpu/gpu_video_encode_accelerator_factory.cc`
  - `content/renderer/render_thread_impl.cc`, `content/browser/gpu/compositor_util.cc`

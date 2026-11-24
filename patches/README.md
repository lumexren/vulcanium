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
- **ANGLE DMA-BUF, Skia Vulkan, Graphite & Out-of-Process DMA-BUF Import**:
  - Graceful fallback in `DmaBufImageSiblingVkLinux::initImpl` when DRM modifiers are rejected (`0001`).
  - Narrowed `VK_IMAGE_LAYOUT_GENERAL` transitions on Ozone Vulkan SharedImages (`SkiaVkOzoneImageRepresentation::GetEndAccessState(bool readonly)`): transitions to `GENERAL` only on writes or external-writer usages, passing `VK_IMAGE_LAYOUT_UNDEFINED` on read-only non-external-writer accesses to preserve optimal GPU layouts (`0002`).
  - Drops `VkExportMemoryAllocateInfo` when importing DMA-BUFs into `VulkanImage` so NVIDIA out-of-process GPU mode doesn't create shadow allocations / black screens (`0003`).
  - Uses YCbCr-compatible Vulkan image usage flags (`SAMPLED | TRANSFER_SRC | TRANSFER_DST`) when importing multi-planar NV12/P010 DMA-BUFs, filters modifiers by `VK_EXTERNAL_MEMORY_FEATURE_EXPORTABLE_BIT`, and queries `VK_IMAGE_ASPECT_MEMORY_PLANE_i_BIT_EXT` subresource layouts with `VK_IMAGE_ASPECT_PLANE_i_BIT` fallback (`0004`).
  - Matches `disable_rgb_to_yuv_conversion` (`gpu_driver_bug_list.json` #474) by NVIDIA PCI vendor ID (`0x10de`) instead of OpenGL vendor string so Skia+ANGLE+Vulkan also avoids broken hardware RGB->YUV conversion into 2-plane NV12 pixmaps (`0005`).
  - Experimental Linux Wayland Skia Graphite + Dawn Vulkan support (`SkiaOutputDeviceBufferQueue` in `InitializeForDawn`, `SharedTextureMemoryDmaBuf` in `DawnContextProvider` / `WebGPUDecoderImpl`, `kSkiaGraphiteUsePersistentCache` enabled on Linux, per-plane multi-planar video sampling instead of Linux external-sampler Y-channel-only red rendering or `PaintCanvasVideoRenderer` readback failures on 8-bit NV12, and reporting `Vulkan: Enabled` on `chrome://gpu` when Graphite uses a Vulkan backend, `0006`; upstream Dawn `PhysicalDeviceVk` still lacks `MultiPlanarFormatP010` / `kDrmFormatP010`).
- Target files:
  - `third_party/angle/src/libANGLE/renderer/vulkan/linux/DmaBufImageSiblingVkLinux.cpp`
  - `gpu/command_buffer/service/shared_image/skia_vk_ozone_image_representation.{h,cc}`
  - `gpu/vulkan/vulkan_image_linux.cc`, `ui/ozone/platform/wayland/gpu/vulkan_implementation_wayland.cc`
  - `gpu/config/gpu_driver_bug_list.json`, `gpu/config/gpu_finch_features.cc`
  - `components/viz/service/display_embedder/skia_output_surface_impl_on_gpu.cc`, `gpu/command_buffer/service/dawn_context_provider.cc`, `gpu/command_buffer/service/webgpu_decoder_impl.cc`, `media/gpu/chromeos/mailbox_video_frame_converter.cc`, `content/browser/gpu/compositor_util.cc`

### 3. `wayland/`
- **Ozone/Wayland, DMA-BUF Pixmaps & PWA Grouping**:
  - Enable Vulkan on Wayland (`0001`), tiled-first implicit GBM modifier fallback before `DRM_FORMAT_MOD_LINEAR` & CSD alpha preservation (`0002`), disable `wp_linux_drm_syncobj_manager_v1` by default only on NVIDIA + Vulkan so AMD/Intel Vulkan and non-Vulkan sessions keep explicit sync (`--enable-wayland-drm-syncobj` / `--disable-wayland-drm-syncobj` CLI overrides, `0003`), and tiled-first Vulkan DMA-BUF pixmap fallback (`InitializeVulkanBuffer`) trying compositor-advertised tiled modifiers before `DRM_FORMAT_MOD_LINEAR` with multi-plane FD export and 8-bit (`RGBA/BGRA/RGBX/BGRX_8888`), 10-bit (`BGRA/RGBA_1010102`), and `RGBA_F16` support (`0004`).
  - Prefixes Wayland PWA `.desktop` files and `xdg_toplevel` `app_id` with the browser's desktop ID (`vulcanium-*` / `helcanium-*`) so installed web apps group separately from the main browser window (`0007`).
- Target files:
  - `ui/ozone/platform/wayland/gpu/wayland_surface_factory.cc`, `ui/ozone/platform/wayland/gpu/gbm_pixmap_wayland.{h,cc}`, `ui/ozone/platform/wayland/host/wayland_connection.cc`
  - `chrome/browser/web_applications/os_integration/web_app_shortcut_linux.cc`, `chrome/browser/shell_integration_linux.cc`

### 4. `video-decode/`
- **Vulkan Video Decoding (`VkVideo`)**:
  - Shared GPU-process `VulkanVideoDevice` singleton (`vulkan_video_device.{h,cc}`) with `vkGetPhysicalDeviceVideoCapabilitiesKHR` probing across `H.264`, `HEVC` (8-bit and Main10 10-bit), `VP9` (8-bit and Profile 2 10-bit), and `AV1` (8-bit and Main 10-bit) decode/encode queues and extent limits, dedicated `VK_QUEUE_TRANSFER_BIT` queue preference, and exportable NV12 + P010 DRM modifier probing.
  - `VulkanVideoDecoder` backed by FFmpeg `AV_HWDEVICE_TYPE_VULKAN` (`H.264`, `HEVC/H.265`, `VP9`, `AV1`) gated by probed GPU capabilities, outputting 8-bit NV12 or 10-bit `P010LE` DMA-BUFs (both preferring tiled modifiers before linear via `vkCmdCopyImage` with semaphore-narrowed pipeline barriers -> 2-plane DMA-BUF -> `MailboxVideoFrameConverter` `SharedImage`) with process-wide `g_drm_prime_map_supported` gating, CPU fallback, `AVERROR(EAGAIN)` drain loop in `Decode()`, dedicated `VideoDecoderType::kVulkan` (`VulkanVideoDecoder`) `chrome://media-internals` reporting, and `visible_rect`/`natural_size`/`ColorSpace`/`hdr_metadata` propagation.
  - Concurrent decoder cap (`kMaxConcurrentDecoders = 8`) with software fallback, reusable `AVPacket`/`AVFrame`, same-config flush fast-path, async pipelined 6-slot `VkCommandPool`/`VkCommandBuffer`/`VkFence` copy ring (`kDecodeCopyRingSize = 6`, polling `vkGetFenceStatus` without per-frame `vkWaitForFences` stalls), and bounded DMA-BUF `OutputSlot` pool (`kMaxOutputPoolSize = 12`) with frame-lifetime tracking.
- Target files:
  - `media/base/media_switches.{h,cc}` (`VulkanVideoDecode`), `media/base/decoder.{h,cc}` (`VideoDecoderType::kVulkan`)
  - `third_party/ffmpeg/` (Vulkan hwaccel & VP9/AV1/HEVC decoder enablement)
  - `media/gpu/vulkan/vulkan_video_device.{h,cc}`, `media/gpu/vulkan/vulkan_video_decoder.{h,cc}`, `media/gpu/BUILD.gn`, `media/mojo/services/gpu_mojo_media_client_linux.cc`

### 5. `video-encode/`
- **Vulkan Video Encoding (`VkVideo`)**:
  - `VulkanVideoEncodeAccelerator` backed by FFmpeg `h264_vulkan`, `hevc_vulkan`, and `av1_vulkan` (`VK_KHR_video_encode_queue`, dynamically gated by GPU capability probing via `VulkanVideoDevice`).
  - Async zero-copy GPU-to-GPU DMA-BUF input path (`CopyDmabufToVkFrame`: imports `MappableSharedImage`/`STORAGE_DMABUFS` native pixmap handles with cached per-`(modifier, disjoint)` format property validation and DMA-BUF size checks into `AVVkFrame` via a 4-slot pipelined `VkCommandPool`/`VkCommandBuffer`/`VkFence` ring and 6-frame `initial_pool_size` retaining source frames/imports until GPU completion without per-frame `vkWaitForFences` stalls), direct bitstream shared-memory copy fast-path in `DrainPackets()`, reusable `AVFrame`/`AVPacket`, low-latency tuning (`tune=ll`, `usage=stream`, `async_depth`), dynamic CBR/VBR bitrate updates, dynamic resolution reconfiguration (`supports_frame_size_change = true`), and `ConvertToMemoryMappedFrame` CPU upload fallback.
- Target files:
  - `third_party/ffmpeg/` (`CONFIG_VULKAN_ENCODE`, `h264_vulkan`, `hevc_vulkan`, `av1_vulkan`)
  - `media/base/media_switches.{h,cc}` (`VulkanVideoEncode`)
  - `media/gpu/vulkan/vulkan_video_encode_accelerator.{h,cc}`, `media/gpu/BUILD.gn`, `media/gpu/gpu_video_encode_accelerator_factory.cc`
  - `content/renderer/render_thread_impl.cc`, `content/browser/gpu/compositor_util.cc`

# Vulcanium Patch Architecture

All `.patch` files are applied in the order listed in `patches/series` against Chromium `157.0.8103.78`.

## Patch Categories

### 1. `branding/`
- Product name (`Vulcanium`), user-data/config directory (`~/.config/vulcanium`), and hiding the `--enable-unsafe-webgpu` warning banner.
- Target files:
  - `chrome/app/chromium_strings.grd`, `chrome/common/chrome_paths_linux.cc`
  - `chrome/browser/ui/startup/bad_flags_prompt.cc`

### 2. `vulkan/`
- **ANGLE DMA-BUF & Skia Vulkan Stability**: Graceful fallback in `DmaBufImageSiblingVkLinux::initImpl` when DRM modifiers are rejected, and `VK_IMAGE_LAYOUT_GENERAL` transitions for Ozone Vulkan SharedImages.
- Target files:
  - `third_party/angle/src/libANGLE/renderer/vulkan/linux/DmaBufImageSiblingVkLinux.cpp`
  - `gpu/command_buffer/service/shared_image/skia_vk_ozone_image_representation.cc`

### 3. `wayland/`
- **Ozone/Wayland + `VK_KHR_wayland_surface` Swapchain**: Enable Vulkan on Wayland, linear DMA-BUF modifier fallback, disable incompatible `wp_linux_drm_syncobj_v1` on Vulkan, direct `VK_KHR_wayland_surface` swapchain, premultiplied alpha, and `ack_configure` / `set_window_geometry` synchronization.
- Target files:
  - `ui/ozone/platform/wayland/...`, `gpu/ipc/service/gpu_init.cc`, `gpu/vulkan/vulkan_surface.cc`

### 4. `video-decode/`
- **Vulkan Video Decoding (`VkVideo`)**: `VulkanVideoDecoder` backed by FFmpeg `AV_HWDEVICE_TYPE_VULKAN` (`H.264`, `HEVC/H.265`, `VP9`, `AV1`).
- Target files:
  - `media/base/media_switches.{h,cc}` (`VulkanVideoDecode`)
  - `third_party/ffmpeg/` (Vulkan hwaccel & VP9/AV1/HEVC decoder enablement)
  - `media/gpu/vulkan/vulkan_video_decoder.{h,cc}`, `media/mojo/services/gpu_mojo_media_client_linux.cc`

### 5. `video-encode/`
- **Vulkan Video Encoding (`VkVideo`)**: `VulkanVideoEncodeAccelerator` backed by FFmpeg `h264_vulkan` and `hevc_vulkan` (`VK_KHR_video_encode_queue`) for `H.264` and `HEVC/H.265` hardware encoding.
- Target files:
  - `third_party/ffmpeg/` (`CONFIG_VULKAN_ENCODE`, `h264_vulkan`, `hevc_vulkan`)
  - `media/base/media_switches.{h,cc}` (`VulkanVideoEncode`)
  - `media/gpu/vulkan/vulkan_video_encode_accelerator.{h,cc}`, `media/gpu/gpu_video_encode_accelerator_factory.cc`
  - `media/video/video_encode_accelerator_adapter.cc`, `content/renderer/render_thread_impl.cc`, `content/browser/gpu/compositor_util.cc`

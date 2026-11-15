# Vulcanium Patch Architecture & Roadmap

All `.patch` files are applied in the order listed in `patches/series` against Chromium `157.0.8103.78`.

## Patch Categories

### 1. `branding/`
- Product name (`Vulcanium`), user-data/config directory (`~/.config/vulcanium`), and `chrome://version` branding without touching trademarked Google Chrome assets.
- Target files:
  - `chrome/app/chromium_strings.grd`
  - `chrome/common/chrome_paths_linux.cc`

### 2. `vulkan/`
- **ANGLE DMA-BUF Sibling Stability**: Address `DmaBufImageSiblingVkLinux::initImpl` (`EGL_BAD_PARAMETER` / `VK_ERROR_FEATURE_NOT_PRESENT`) crashes when Mesa RADV/ANV or NVIDIA drivers reject specific DRM modifiers.
- **GPU Process & Blocklist**: Keep Vulkan enabled cleanly across AMD (RADV), Intel (ANV), and NVIDIA proprietary Vulkan drivers without falling back to SwiftShader.
- Target files:
  - `third_party/angle/src/libANGLE/renderer/vulkan/linux/DmaBufImageSiblingVkLinux.cpp`
  - `gpu/command_buffer/service/shared_image/ozone_image_backing.cc`
  - `gpu/vulkan/vulkan_device_queue.cc`

### 3. `video-decode/`
- **Vulkan Video Decoding (`VkVideo`)**: Implement & wire `VulkanVideoDecoder` (`VK_KHR_video_decode_queue`, H.264, H.265, AV1) for cross-vendor hardware video decode (especially critical for NVIDIA where native VA-API is absent, and unified with RADV/ANV on Mesa).
- Target files:
  - `media/base/media_switches.cc` / `.h` (feature flag `VulkanVideoDecode`)
  - `media/gpu/vulkan/` (new `VulkanVideoDecoder` implementation)
  - `media/mojo/services/gpu_mojo_media_client_linux.cc` (decoder selection & fallback to VA-API)

### 4. `wayland/`
- **Ozone/Wayland + ANGLE-Vulkan**: Remove hard blocks and fix DMA-BUF surface/modifier negotiation when running `--ozone-platform=wayland` with `--use-gl=angle --use-angle=vulkan`.
- Target files:
  - `ui/ozone/platform/wayland/gpu/wayland_surface_factory.cc`
  - `ui/ozone/platform/wayland/host/wayland_buffer_manager_host.cc`

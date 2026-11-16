# Draft 02: Vulkan & ANGLE DMA-BUF Stability

> **Status:** Draft (verified against Chromium 157 `third_party/angle` and `gpu/`)

## Problems Addressed
1. **`DmaBufImageSiblingVkLinux::initImpl` Crash (`EGL_BAD_PARAMETER` / `-8`):**
   * On Mesa (RADV/ANV) or NVIDIA drivers, when DRM format modifiers (e.g. `DRM_FORMAT_MOD_LINEAR` vs compressed modifiers) do not match Vulkan `VkImageFormatProperties2` queries, ANGLE crashes the GPU process 3 times and falls back to software rendering (`SwiftShader`).
   * **Approach:** When a modifier is unsupported or incompatible with `VK_IMAGE_CREATE_MUTABLE_FORMAT_BIT`, try supported subset/linear fallbacks and return a clean `angle::Result::Stop` instead of a fatal assert.
2. **`OzoneImageBacking` + ANGLE Vulkan:**
   * Prevent the GPU process from locking up on `EGLImage` creation errors during `ProduceSkiaGanesh` / `ProduceSkiaGraphite`.
3. **NVIDIA & Multi-GPU (Hybrid) Selection:**
   * Ensure primary/external Vulkan physical device selection in `gpu/vulkan/vulkan_device_queue.cc` properly checks `VK_KHR_external_memory_fd` and `VK_EXT_external_memory_dma_buf`.

## Target Files
* `third_party/angle/src/libANGLE/renderer/vulkan/linux/DmaBufImageSiblingVkLinux.cpp`
* `gpu/command_buffer/service/shared_image/ozone_image_backing.cc`
* `gpu/vulkan/vulkan_device_queue.cc`
* `gpu/config/gpu_driver_bug_list.json`

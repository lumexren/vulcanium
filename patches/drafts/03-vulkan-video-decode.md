# Draft 03: Vulkan Video Decoding (`VkVideo` via FFmpeg `AV_HWDEVICE_TYPE_VULKAN`)

> **Status:** Draft — Adapted from Firefox's `FFmpegVulkanVideoDecoder` (`reference/FFmpegVulkanVideoDecoder.{h,cpp}`) for Chromium.

## Why FFmpeg Vulkan Hwaccel?
Instead of writing an H.264/H.265/AV1 bitstream parser and `VK_KHR_video_decode_*` command recorder from scratch, using `AV_HWDEVICE_TYPE_VULKAN` through Chromium's existing FFmpeg (`libavcodec`) stack is cleaner and easier to maintain:
* H.264, H.265/HEVC, VP9, and AV1 are decoded through a single unified backend.
* Works across AMD (RADV), Intel (ANV), and NVIDIA (proprietary Vulkan) through the same interface.

## Key Pieces Adapted from the Firefox Reference
1. **Physical Device & Modifier Negotiation (`InitDrmModifiers`, `SelectVulkanDecoderPhysicalDevice`):**
   * Intersect DRM modifiers advertised by the Wayland compositor (`zwp_linux_dmabuf_v1`) with Vulkan `vkGetPhysicalDeviceImageFormatProperties2` queries.
   * `BLOCK_LINEAR` modifier fallback for NVIDIA in addition to `LINEAR` (`mForcedNvidiaBlockLinear`).
2. **Dual Path (Zero-Copy Map + Copy Ring Buffer):**
   * **Path A (Zero-Copy):** If the decoded `AVFrame` (`AV_PIX_FMT_VULKAN`) already uses a compositor-compatible DRM modifier, map it via `av_hwframe_map` as `AV_PIX_FMT_DRM_PRIME`.
   * **Path B (GPU-to-GPU Copy Ring Buffer):** If FFmpeg decodes with opaque/optimal tiling, copy via `vkCmdCopyImage` into a 32-slot NV12 `VkImage` ring buffer and export via `vkGetMemoryFdKHR` + `VK_EXTERNAL_SEMAPHORE_HANDLE_TYPE_SYNC_FD_BIT` as a DMA-BUF FD.
3. **Synchronization:**
   * Use `vkGetDeviceQueue2` matching `AVVulkanDeviceContext.queue_flags` (`VUID-vkGetDeviceQueue-flags-01841`).

## Chromium Integration Points
* **`third_party/ffmpeg/`:** Enable `hwcontext_vulkan` and `*_vulkan` hwaccels in Chromium's bundled FFmpeg GN/config files.
* **`media/base/media_switches.h/.cc`:** `kVulkanVideoDecode` feature flag.
* **`media/gpu/vulkan/`:**
  * Select `AV_PIX_FMT_VULKAN` in `AVCodecContext::get_format`.
  * Wrap output `AVFrame` -> DMA-BUF FDs (`VideoFrame::WrapExternalDmabufs`) with host NV12 transfer fallback.
* **`media/mojo/services/gpu_mojo_media_client_linux.cc`:** Prefer `VulkanVideoDecoder` when `kVulkanVideoDecode` is enabled, otherwise fall back to VA-API.

## Reference Files
* [FFmpegVulkanVideoDecoder.h](reference/FFmpegVulkanVideoDecoder.h)
* [FFmpegVulkanVideoDecoder.cpp](reference/FFmpegVulkanVideoDecoder.cpp)

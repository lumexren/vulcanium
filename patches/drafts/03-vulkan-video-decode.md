# Taslak 03: Vulkan Video Decoding (`VkVideo` via FFmpeg `AV_HWDEVICE_TYPE_VULKAN`)

> **Durum:** Taslak — Firefox'un `FFmpegVulkanVideoDecoder` (`patches/drafts/reference/FFmpegVulkanVideoDecoder.{h,cpp}`) referansı baz alınarak Chromium'a uyarlanacak.

## Neden FFmpeg Vulkan Hwaccel?
Sıfırdan H.264/H.265/AV1 bitstream parser + `VK_KHR_video_decode_*` komut üreticisi yazmak yerine, Chromium'un zaten kullandığı `FFmpegVideoDecoder` (`libavcodec`) üzerinden `AV_HWDEVICE_TYPE_VULKAN` donanım hızlandırmasını kullanmak çok daha temiz ve sürdürülebilirdir:
* H.264, H.265/HEVC, AV1 (ve sürücü destekledikçe VP9) tek merkezden çözülür.
* AMD (RADV), Intel (ANV) ve NVIDIA (proprietary Vulkan) üzerinde aynı arayüzle çalışır.

## Firefox Referansından Uyarlanacak Kritik Parçalar
1. **Fiziksel Aygıt & Modifier Pazarlığı (`InitDrmModifiers`, `SelectVulkanDecoderPhysicalDevice`):**
   * Compositor'ın (Wayland/Ozone `zwp_linux_dmabuf_v1`) desteklediği DRM modifier'lar ile Vulkan `vkGetPhysicalDeviceImageFormatProperties2` sorgusunu kesiştirme.
   * NVIDIA için `LINEAR` dışında `BLOCK_LINEAR` modifier fallback (`mForcedNvidiaBlockLinear`).
2. **Çift Yol (Zero-Copy Map + Copy Ring Buffer):**
   * **Yol A (Zero-Copy):** Dekode edilen `AVFrame` (`AV_PIX_FMT_VULKAN`) doğrudan compositor uyumlu bir DRM modifier taşıyorsa `av_hwframe_map` ile `AV_PIX_FMT_DRM_PRIME` olarak sarılır.
   * **Yol B (GPU-to-GPU Copy Ring Buffer):** FFmpeg opaque/optimal tiling ile dekode ettiyse, 32 slotlu NV12 `VkImage` ring buffer'a `vkCmdCopyImage` ile kopyalanıp `vkGetMemoryFdKHR` + `VK_EXTERNAL_SEMAPHORE_HANDLE_TYPE_SYNC_FD_BIT` ile DMA-BUF fd olarak dışa aktarılır.
3. **Senkronizasyon:**
   * `AVVulkanDeviceContext.queue_flags` ile uyumlu `vkGetDeviceQueue2` kullanımı (`VUID-vkGetDeviceQueue-flags-01841`).

## Chromium Tarafında Uyarlama Noktaları
* **`third_party/ffmpeg/`:** Chromium'un gömülü FFmpeg yapılandırmasında `hwcontext_vulkan` ve `*_vulkan` hwaccel'lerin açık olduğundan emin olmak (veya sistem FFmpeg / GN config güncellemesi).
* **`media/base/media_switches.h/.cc`:** `kVulkanVideoDecode` feature flag'i.
* **`media/filters/ffmpeg_video_decoder.cc` (veya `media/gpu/vulkan/`):**
  * `AVCodecContext::get_format` callback'inde `AV_PIX_FMT_VULKAN` seçimi.
  * Çıktı `AVFrame` -> DMA-BUF fd (`gfx::NativePixmapHandle`) -> `media::VideoFrame::WrapExternalGpuMemoryBuffer` / `SharedImage` (`OzoneImageBacking`) dönüşümü.
* **`media/mojo/services/gpu_mojo_media_client_linux.cc`:** `kVulkanVideoDecode` etkin ve GPU destekli ise önceliklendirme, aksi halde VA-API'ye düşüş.

## Referans Dosyalar
* [FFmpegVulkanVideoDecoder.h](file:///home/eren/Projects/vulcanium/patches/drafts/reference/FFmpegVulkanVideoDecoder.h)
* [FFmpegVulkanVideoDecoder.cpp](file:///home/eren/Projects/vulcanium/patches/drafts/reference/FFmpegVulkanVideoDecoder.cpp)

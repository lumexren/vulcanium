# Taslak 03: Vulkan Video Decoding (`VkVideo`)

> **Durum:** Taslak (Chromium 157 `media/gpu/` ve `media/mojo/` yapısına göre geliştirilecek)

## Mimari Yaklaşım
1. **Feature Flag (`media/base/media_switches.h/.cc`):**
   * `BASE_FEATURE(kVulkanVideoDecode, "VulkanVideoDecode", base::FEATURE_ENABLED_BY_DEFAULT);`
2. **Vulkan Device Uzantıları (`gpu/vulkan/vulkan_device_queue.cc`):**
   * `VK_KHR_video_queue`
   * `VK_KHR_video_decode_queue`
   * `VK_KHR_video_decode_h264`, `VK_KHR_video_decode_h265`, `VK_KHR_video_decode_av1` (sürücü destekliyorsa dinamik olarak etkinleştirilir)
3. **`VulkanVideoDecoder` (`media/gpu/vulkan/`):**
   * Chromium'un `VideoDecoderMixin` arayüzünü uygular.
   * Bitstream ayrıştırma için Chromium'un mevcut `H264Decoder` / `H265Decoder` / `AV1Decoder` (`AcceleratedVideoDecoder` + `Accelerator` pattern) sınıflarını yeniden kullanır!
   * Her kare için `VkVideoSessionKHR` + DPB (Decoded Picture Buffer) slotlarını yönetir ve `vkCmdDecodeVideoKHR` ile decode komutlarını Vulkan kuyruğuna (`VK_QUEUE_VIDEO_DECODE_BIT_KHR`) gönderir.
   * Çıktı `VkImage` doğrudan `SharedImage` / DMA-BUF üzerinden Skia/ANGLE compositor'a sıfır kopya (zero-copy) ile aktarılır.
4. **Dekoder Seçimi (`media/mojo/services/gpu_mojo_media_client_linux.cc`):**
   * `kVulkanVideoDecode` etkinse ve GPU Vulkan Video Decode kuyruğu sunuyorsa öncelikle `VulkanVideoDecoder` seçilir; desteklenmeyen kodeklerde (ör. VP9) otomatik olarak VA-API'ye (`VaapiVideoDecoder`) düşülür.

## Hedeflenen Dosyalar
* `media/base/media_switches.h` & `media/base/media_switches.cc`
* `media/gpu/BUILD.gn`
* `media/gpu/vulkan/vulkan_video_decoder.h` & `vulkan_video_decoder.cc`
* `media/gpu/vulkan/vulkan_video_decode_accelerator_delegate.cc`
* `media/mojo/services/gpu_mojo_media_client_linux.cc`
* `gpu/vulkan/vulkan_device_queue.cc`

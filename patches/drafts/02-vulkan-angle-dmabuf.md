# Taslak 02: Vulkan & ANGLE DMA-BUF Kararlılığı

> **Durum:** Taslak (Chromium 157 kaynak kodu açıldığında `third_party/angle` ve `gpu/` satırları doğrulanacak)

## Çözülen Sorunlar
1. **`DmaBufImageSiblingVkLinux::initImpl` Çökmesi (`EGL_BAD_PARAMETER` / `-8`):**
   * Mesa (RADV/ANV) veya NVIDIA sürücülerinde, DRM format modifier (ör. `DRM_FORMAT_MOD_LINEAR` vs sıkıştırılmış modifier) ile Vulkan `VkImageFormatProperties2` sorgusu uyuşmadığında ANGLE GPU sürecini 3 kez çökertip yazılım render'a (`SwiftShader`) düşüyor.
   * **Yaklaşım:** Modifier desteklenmediğinde veya `VK_IMAGE_CREATE_MUTABLE_FORMAT_BIT` ile uyumsuz olduğunda, desteklenen alt küme/linear fallback denemek ve fatal assert yerine temiz `angle::Result::Stop` / fallback döndürmek.
2. **`OzoneImageBacking` + ANGLE Vulkan:**
   * `ProduceSkiaGanesh` / `ProduceSkiaGraphite` sırasında `EGLImage` oluşturma hatasında GPU sürecinin tamamen kilitlenmesini önlemek.
3. **NVIDIA & Çoklu GPU (Hybrid) Seçimi:**
   * `gpu/vulkan/vulkan_device_queue.cc` içinde harici/birincil Vulkan fiziksel aygıt seçiminin `VK_KHR_external_memory_fd` ve `VK_EXT_external_memory_dma_buf` uzantılarını doğru kontrol etmesi.

## Hedeflenen Dosyalar
* `third_party/angle/src/libANGLE/renderer/vulkan/linux/DmaBufImageSiblingVkLinux.cpp`
* `gpu/command_buffer/service/shared_image/ozone_image_backing.cc`
* `gpu/vulkan/vulkan_device_queue.cc`
* `gpu/config/gpu_driver_bug_list.json`

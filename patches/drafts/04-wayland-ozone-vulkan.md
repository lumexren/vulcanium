# Taslak 04: Wayland / Ozone + Vulkan Desteği

> **Durum:** Taslak (Chromium 157 `ui/ozone/platform/wayland/` dosyaları incelenerek netleştirilecek)

## Çözülen Sorunlar
1. **`--ozone-platform=wayland` + Vulkan / ANGLE Engeli:**
   * Bazı sürümlerde Chromium, Wayland altında Vulkan veya `--use-angle=vulkan` kullanıldığında uyarı verip engelleyebiliyor ya da X11'e yönlendiriyor.
   * `WaylandSurfaceFactory` içinde `ANGLEImplementation::kVulkan` ve `SkiaRenderer` Vulkan yolunun Wayland DMA-BUF sunumuyla sorunsuz çalışmasını sağlamak.
2. **DMA-BUF Modifier Pazarlığı (`WaylandBufferManagerHost`):**
   * KWin (KDE Plasma), Mutter (GNOME) ve wlroots/Hyprland kompozitörlerinin `zwp_linux_dmabuf_v1` üzerinden bildirdiği modifier listesiyle ANGLE/Vulkan'ın ürettiği modifier'ların eşleşmemesi durumunda siyah ekran / 1 FPS sorununu önlemek.
3. **NVIDIA Wayland + Explicit Sync:**
   * NVIDIA 555+/580+ sürücülerinde `linux-drm-syncobj-v1` (explicit sync) ve render-node seçiminde (`--render-node-override`) DMA-BUF import hatalarını azaltmak.

## Hedeflenen Dosyalar
* `ui/ozone/platform/wayland/gpu/wayland_surface_factory.cc`
* `ui/ozone/platform/wayland/host/wayland_buffer_manager_host.cc`
* `ui/ozone/platform/wayland/gpu/gbm_surfaceless_wayland.cc`

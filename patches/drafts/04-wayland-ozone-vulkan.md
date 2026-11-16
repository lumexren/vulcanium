# Draft 04: Wayland / Ozone + Vulkan Support

> **Status:** Draft (refined against Chromium 157 `ui/ozone/platform/wayland/`)

## Problems Addressed
1. **`--ozone-platform=wayland` + Vulkan / ANGLE Block:**
   * Chromium can warn or block Vulkan / `--use-angle=vulkan` under Wayland or fall back to X11.
   * Enable `ANGLEImplementation::kVulkan` and `SkiaRenderer` Vulkan presentation cleanly in `WaylandSurfaceFactory`.
2. **DMA-BUF Modifier Negotiation (`WaylandBufferManagerHost`):**
   * Prevent black screens or 1 FPS stalls when compositor `zwp_linux_dmabuf_v1` modifier lists (KWin, Mutter, wlroots/Hyprland) do not match ANGLE/Vulkan modifiers.
3. **NVIDIA Wayland + Explicit Sync:**
   * Address DMA-BUF import and `linux-drm-syncobj-v1` / render-node selection (`--render-node-override`) issues on NVIDIA 555+ drivers.

## Target Files
* `ui/ozone/platform/wayland/gpu/wayland_surface_factory.cc`
* `ui/ozone/platform/wayland/host/wayland_buffer_manager_host.cc`
* `ui/ozone/platform/wayland/gpu/gbm_surfaceless_wayland.cc`

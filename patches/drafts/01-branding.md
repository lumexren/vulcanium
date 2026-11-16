# Draft 01: Vulcanium Branding

> **Status:** Draft (line numbers and context verified against Chromium 157)

## Goals
1. Change the application display name from `Chromium` to `Vulcanium` (`chrome://settings/help`, window titles, desktop notifications).
2. Separate the profile and configuration directory from `~/.config/chromium` to `~/.config/vulcanium` to avoid conflicts with existing Chromium profiles.
3. Display `Vulcanium` in `chrome://version`.
4. Keep the open-source `chromium` theme assets without touching Google Chrome proprietary branding/icons.

## Target Files
* `chrome/app/chromium_strings.grd`
* `components/components_chromium_strings.grd`
* `chrome/common/chrome_paths_linux.cc`
* `chrome/common/chrome_constants.cc`
* `components/version_info/version_info_values.h.version`

## Notes
* Keep the `Chrome/<major>.0.0.0` token in the `User-Agent` header to preserve web compatibility; optionally append `Vulcanium/<ver>` or leave the standard Chromium UA intact.

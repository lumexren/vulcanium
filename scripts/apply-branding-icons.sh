#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 2 || $# -gt 3 ]]; then
  echo "Usage: $0 <vulcanium|helcanium> <chromium-src-dir> [repo-root]" >&2
  exit 1
fi

VARIANT="$1"
TARGET_DIR="$2"
ROOT_DIR="${3:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

case "${VARIANT}" in
  vulcanium|helcanium) ;;
  *)
    echo "Error: Unknown variant '${VARIANT}' (expected 'vulcanium' or 'helcanium')." >&2
    exit 1
    ;;
esac

if [[ ! -d "${TARGET_DIR}" ]]; then
  echo "Error: Chromium source directory not found: ${TARGET_DIR}" >&2
  exit 1
fi

ICON_DIR="${ROOT_DIR}/assets/icons/${VARIANT}"
ICON_SVG="${ROOT_DIR}/assets/icons/${VARIANT}.svg"
BRANDING_DIR="${ROOT_DIR}/assets/branding/${VARIANT}"

install_asset() {
  local src="$1"
  local dst_rel="$2"
  local dst="${TARGET_DIR}/${dst_rel}"

  if [[ ! -f "${src}" ]]; then
    echo "Error: Missing branding asset: ${src}" >&2
    exit 1
  fi

  if [[ -d "${dst%/*}" ]]; then
    install -m644 "${src}" "${dst}"
  fi
}

# Pre-validate all required source files before copying
required_files=(
  "${ICON_SVG}"
  "${ICON_DIR}/16.png"
  "${ICON_DIR}/24.png"
  "${ICON_DIR}/32.png"
  "${ICON_DIR}/48.png"
  "${ICON_DIR}/64.png"
  "${ICON_DIR}/128.png"
  "${ICON_DIR}/256.png"
  "${BRANDING_DIR}/product_logo.png"
  "${BRANDING_DIR}/product_logo_200.png"
  "${BRANDING_DIR}/product_logo_white.png"
  "${BRANDING_DIR}/product_logo_white_200.png"
  "${BRANDING_DIR}/product_logo_name_22.png"
  "${BRANDING_DIR}/product_logo_name_22_200.png"
  "${BRANDING_DIR}/product_logo_name_22_white.png"
  "${BRANDING_DIR}/product_logo_name_22_white_200.png"
  "${BRANDING_DIR}/product_logo_22_mono.png"
  "${BRANDING_DIR}/product_refresh.icon"
)
for f in "${required_files[@]}"; do
  if [[ ! -f "${f}" ]]; then
    echo "Error: Required branding source file missing: ${f}" >&2
    exit 1
  fi
done

install_asset "${ICON_SVG}" "chrome/app/theme/chromium/product_logo.svg"
install_asset "${ICON_SVG}" "chrome/app/theme/chromium/product_logo_animation.svg"

for sz in 16 24 48 64 128 256; do
  install_asset "${ICON_DIR}/${sz}.png" "chrome/app/theme/chromium/product_logo_${sz}.png"
done

for sz in 24 48 64 128 256; do
  install_asset "${ICON_DIR}/${sz}.png" "chrome/app/theme/chromium/linux/product_logo_${sz}.png"
done

for sz in 16 32; do
  install_asset "${ICON_DIR}/${sz}.png" "chrome/app/theme/default_100_percent/chromium/product_logo_${sz}.png"
  install_asset "${ICON_DIR}/${sz}.png" "chrome/app/theme/default_100_percent/chromium/linux/product_logo_${sz}.png"
done

install_asset "${ICON_DIR}/32.png" "chrome/app/theme/default_200_percent/chromium/product_logo_16.png"
install_asset "${ICON_DIR}/64.png" "chrome/app/theme/default_200_percent/chromium/product_logo_32.png"

install_asset "${BRANDING_DIR}/product_logo_22_mono.png" "chrome/app/theme/chromium/product_logo_22_mono.png"
install_asset "${BRANDING_DIR}/product_logo_name_22.png" "chrome/app/theme/default_100_percent/chromium/product_logo_name_22.png"
install_asset "${BRANDING_DIR}/product_logo_name_22_white.png" "chrome/app/theme/default_100_percent/chromium/product_logo_name_22_white.png"
install_asset "${BRANDING_DIR}/product_logo_name_22_200.png" "chrome/app/theme/default_200_percent/chromium/product_logo_name_22.png"
install_asset "${BRANDING_DIR}/product_logo_name_22_white_200.png" "chrome/app/theme/default_200_percent/chromium/product_logo_name_22_white.png"

install_asset "${BRANDING_DIR}/product_logo.png" "components/resources/default_100_percent/chromium/product_logo.png"
install_asset "${BRANDING_DIR}/product_logo_white.png" "components/resources/default_100_percent/chromium/product_logo_white.png"
install_asset "${BRANDING_DIR}/product_logo_200.png" "components/resources/default_200_percent/chromium/product_logo.png"
install_asset "${BRANDING_DIR}/product_logo_white_200.png" "components/resources/default_200_percent/chromium/product_logo_white.png"

install_asset "${BRANDING_DIR}/product_refresh.icon" "components/vector_icons/chromium/product_refresh.icon"

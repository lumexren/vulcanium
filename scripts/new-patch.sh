#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <category> <patch-name>"
  echo "Categories: branding | vulkan | video-decode | wayland"
  echo "Example: $0 vulkan 0001-fix-dmabuf-sibling-modifier.patch"
  exit 1
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CATEGORY="$1"
PATCH_NAME="$2"
[[ "${PATCH_NAME}" == *.patch ]] || PATCH_NAME="${PATCH_NAME}.patch"

VERSION="${CHROMIUM_VERSION:-157.0.8103.78}"
TARGET_DIR="${ROOT_DIR}/src/chromium-${VERSION}"
OUT_FILE="${ROOT_DIR}/patches/${CATEGORY}/${PATCH_NAME}"

if [[ ! -d "${TARGET_DIR}/.git" ]]; then
  echo "Error: ${TARGET_DIR} is not a git repo. Run ./scripts/fetch-source.sh first." >&2
  exit 1
fi

mkdir -p "${ROOT_DIR}/patches/${CATEGORY}"
git -C "${TARGET_DIR}" diff > "${OUT_FILE}"

if [[ ! -s "${OUT_FILE}" ]]; then
  rm -f "${OUT_FILE}"
  echo "No unstaged changes in ${TARGET_DIR}; nothing written."
  exit 1
fi

REL_PATH="${CATEGORY}/${PATCH_NAME}"
if ! grep -qxF "${REL_PATH}" "${ROOT_DIR}/patches/series" 2>/dev/null; then
  echo "${REL_PATH}" >> "${ROOT_DIR}/patches/series"
  echo "==> Added ${REL_PATH} to patches/series"
fi

echo "==> Wrote ${OUT_FILE}"

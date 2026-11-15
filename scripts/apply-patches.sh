#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION="${CHROMIUM_VERSION:-157.0.8103.78}"
TARGET_DIR="${1:-${ROOT_DIR}/src/chromium-${VERSION}}"
SERIES_FILE="${ROOT_DIR}/patches/series"

if [[ ! -d "${TARGET_DIR}" ]]; then
  echo "Error: Chromium source directory not found: ${TARGET_DIR}" >&2
  echo "Run ./scripts/fetch-source.sh first." >&2
  exit 1
fi

if [[ ! -f "${SERIES_FILE}" ]]; then
  echo "Error: patches/series not found: ${SERIES_FILE}" >&2
  exit 1
fi

while IFS= read -r line || [[ -n "${line}" ]]; do
  # Strip comments and whitespace
  patch_rel="${line%%#*}"
  patch_rel="${patch_rel//[[:space:]]/}"
  [[ -z "${patch_rel}" ]] && continue

  patch_file="${ROOT_DIR}/patches/${patch_rel}"
  if [[ ! -f "${patch_file}" ]]; then
    echo "Error: Listed patch not found: ${patch_file}" >&2
    exit 1
  fi

  echo "==> Applying ${patch_rel}..."
  patch -d "${TARGET_DIR}" -Np1 --forward < "${patch_file}"
done < "${SERIES_FILE}"

echo "==> All Vulcanium patches applied."

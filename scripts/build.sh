#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION="${CHROMIUM_VERSION:-157.0.8103.78}"
TARGET_DIR="${1:-${ROOT_DIR}/src/chromium-${VERSION}}"
OUT_DIR="${TARGET_DIR}/out/Release"

if [[ ! -d "${TARGET_DIR}" ]]; then
  echo "Error: Chromium source directory not found: ${TARGET_DIR}" >&2
  exit 1
fi

cd "${TARGET_DIR}"

export CC="${CC:-clang}"
export CXX="${CXX:-clang++}"
export AR="${AR:-ar}"
export NM="${NM:-nm}"

mkdir -p "${OUT_DIR}"
cp "${ROOT_DIR}/config/args.gn" "${OUT_DIR}/args.gn"

echo "==> Generating ninja build files in ${OUT_DIR}..."
gn gen "${OUT_DIR}"

echo "==> Building chrome..."
ninja -C "${OUT_DIR}" chrome chrome_sandbox

#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION="${CHROMIUM_VERSION:-157.0.8103.78}"
TARBALL="chromium-${VERSION}-lite.tar.xz"
URL="https://commondatastorage.googleapis.com/chromium-browser-official/${TARBALL}"
SRC_DIR="${ROOT_DIR}/src"
TARGET_DIR="${SRC_DIR}/chromium-${VERSION}"

mkdir -p "${SRC_DIR}"

if [[ ! -f "${SRC_DIR}/${TARBALL}" ]]; then
  echo "==> Downloading ${TARBALL}..."
  curl -L -C - --retry 3 -o "${SRC_DIR}/${TARBALL}" "${URL}"
else
  echo "==> Resuming/verifying existing ${TARBALL}..."
  curl -L -C - --retry 3 -o "${SRC_DIR}/${TARBALL}" "${URL}"
fi

if [[ ! -d "${TARGET_DIR}" ]]; then
  echo "==> Extracting ${TARBALL} into ${SRC_DIR}..."
  tar -xf "${SRC_DIR}/${TARBALL}" -C "${SRC_DIR}"
fi

if [[ ! -d "${TARGET_DIR}/.git" ]]; then
  echo "==> Initializing local git repository for patch development..."
  git -C "${TARGET_DIR}" init -q
  git -C "${TARGET_DIR}" add -A
  git -C "${TARGET_DIR}" commit -q -m "Import Chromium ${VERSION}"
  git -C "${TARGET_DIR}" tag "upstream-${VERSION}"
fi

echo "==> Chromium ${VERSION} source ready at ${TARGET_DIR}"

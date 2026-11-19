#!/usr/bin/env bash
set -euo pipefail

# Sync Vulcanium PKGBUILDs with ungoogled-chromium upstream.
# Usage:
#   ./scripts/update-upstream.sh --check          # show current vs upstream
#   ./scripts/update-upstream.sh [--apply] [VER]  # update PKGBUILDs (e.g. 158.0.xxxx.xx-1)

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC_DIR="${SRCDEST:-$ROOT_DIR/src}"
MODE="check"
TARGET_TAG=""

for arg in "$@"; do
  case "$arg" in
    --check) MODE="check" ;;
    --apply) MODE="apply" ;;
    *) TARGET_TAG="$arg" ;;
  esac
done

UC_RAW_BASE="https://raw.githubusercontent.com/ungoogled-software/ungoogled-chromium/refs/heads/master"

if [[ -z "$TARGET_TAG" ]]; then
  NEW_PKGVER="$(curl -fsSL "$UC_RAW_BASE/chromium_version.txt" | tr -d '[:space:]')"
  NEW_REV="$(curl -fsSL "$UC_RAW_BASE/revision.txt" | tr -d '[:space:]')"
  NEW_UC_VER="${NEW_PKGVER}-${NEW_REV}"
else
  NEW_PKGVER="${TARGET_TAG%-*}"
  NEW_UC_VER="$TARGET_TAG"
fi

CUR_PKGVER="$(sed -n 's/^pkgver=//p' "$ROOT_DIR/aur/vulcanium/PKGBUILD" | head -n1)"
CUR_UC_VER="$(sed -n 's/^_uc_ver=//p' "$ROOT_DIR/aur/ungoogled-vulcanium/PKGBUILD" | head -n1)"
HELIUM_TAG="$(curl -fsSL https://api.github.com/repos/imputnet/helium-linux/releases/latest \
  | sed -n 's/.*"tag_name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n1 || echo "unknown")"

echo "Current vulcanium pkgver   : $CUR_PKGVER (ungoogled: $CUR_UC_VER)"
echo "Upstream ungoogled-chromium: $NEW_UC_VER (chromium $NEW_PKGVER)"
echo "Upstream helium-linux      : ${HELIUM_TAG:-unknown}"

if [[ "$MODE" == "check" ]]; then
  exit 0
fi

mkdir -p "$SRC_DIR"
CHROMIUM_TAR="$SRC_DIR/chromium-$NEW_PKGVER-lite.tar.xz"
UC_TAR="$SRC_DIR/ungoogled-chromium-$NEW_UC_VER.tar.gz"

if [[ ! -f "$CHROMIUM_TAR" ]]; then
  echo "Downloading chromium-$NEW_PKGVER-lite.tar.xz -> $SRC_DIR ..."
  curl -fL --progress-bar \
    "https://commondatastorage.googleapis.com/chromium-browser-official/chromium-$NEW_PKGVER-lite.tar.xz" \
    -o "$CHROMIUM_TAR"
fi

if [[ ! -f "$UC_TAR" ]]; then
  echo "Downloading ungoogled-chromium-$NEW_UC_VER.tar.gz -> $SRC_DIR ..."
  curl -fL --progress-bar \
    "https://github.com/ungoogled-software/ungoogled-chromium/archive/$NEW_UC_VER.tar.gz" \
    -o "$UC_TAR"
fi

CHROMIUM_SHA="$(sha256sum "$CHROMIUM_TAR" | awk '{print $1}')"
UC_SHA="$(sha256sum "$UC_TAR" | awk '{print $1}')"
CRUBIT_REV="$(tar -xOf "$CHROMIUM_TAR" "chromium-$NEW_PKGVER/tools/rust/update_rust.py" \
  | sed -n "s/^CRUBIT_REVISION = '\([^']*\)'.*/\1/p" | head -n1 || true)"

echo "chromium-$NEW_PKGVER-lite.tar.xz sha256 : $CHROMIUM_SHA"
echo "ungoogled-chromium-$NEW_UC_VER.tar.gz sha256: $UC_SHA"
[[ -n "$CRUBIT_REV" ]] && echo "CRUBIT_REVISION: $CRUBIT_REV"

for pkg in vulcanium ungoogled-vulcanium helcanium; do
  pb="$ROOT_DIR/aur/$pkg/PKGBUILD"
  sed -i -E \
    -e "s/^pkgver=.*/pkgver=$NEW_PKGVER/" \
    -e "s/^pkgrel=.*/pkgrel=1/" \
    -e "s/^_uc_ver=.*/_uc_ver=$NEW_UC_VER/" \
    "$pb"
  if [[ -n "$CRUBIT_REV" ]]; then
    sed -i -E "s/^_crubit_rev=.*/_crubit_rev=$CRUBIT_REV/" "$pb"
  fi
  # Replace 1st sha256 (chromium-*-lite.tar.xz)
  awk -v cr_sha="$CHROMIUM_SHA" -v uc_sha="$UC_SHA" -v is_uc="$([ "$pkg" = "ungoogled-vulcanium" ] && echo 1 || echo 0)" '
    BEGIN { in_sums=0; idx=0 }
    /^sha256sums=\(/ { in_sums=1; idx=1; sub(/[0-9a-f]{64}/, cr_sha); print; next }
    in_sums {
      idx++
      if (is_uc && idx == 3) sub(/[0-9a-f]{64}/, uc_sha)
      if (/\)/) in_sums=0
    }
    { print }
  ' "$pb" > "$pb.tmp" && mv "$pb.tmp" "$pb"

  (cd "$ROOT_DIR/aur/$pkg" && makepkg --printsrcinfo > .SRCINFO)
  echo "Updated $pb"
done

echo "Done. Review git diff before building."

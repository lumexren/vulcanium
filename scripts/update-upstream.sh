#!/usr/bin/env bash
set -euo pipefail

# Sync Vulcanium PKGBUILDs with the latest ungoogled-chromium upstream release.
# Usage:
#   ./scripts/update-upstream.sh --check          # show current vs latest upstream
#   ./scripts/update-upstream.sh [--apply] [TAG]  # update PKGBUILDs (default: latest)

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

if [[ -z "$TARGET_TAG" ]]; then
  TARGET_TAG="$(curl -fsSL https://api.github.com/repos/ungoogled-software/ungoogled-chromium/releases/latest \
    | python3 -c 'import json, sys; print(json.load(sys.stdin)["tag_name"])')"
fi

NEW_PKGVER="${TARGET_TAG%-*}"
NEW_UC_VER="$TARGET_TAG"
CUR_PKGVER="$(sed -n 's/^pkgver=//p' "$ROOT_DIR/aur/vulcanium/PKGBUILD" | head -n1)"
CUR_UC_VER="$(sed -n 's/^_uc_ver=//p' "$ROOT_DIR/aur/ungoogled-vulcanium/PKGBUILD" | head -n1)"
HELIUM_TAG="$(curl -fsSL https://api.github.com/repos/imputnet/helium-linux/releases/latest \
  | python3 -c 'import json, sys; print(json.load(sys.stdin)["tag_name"])' || echo "unknown")"

echo "Current vulcanium pkgver : $CUR_PKGVER (ungoogled: $CUR_UC_VER)"
echo "Upstream ungoogled-chromium: $NEW_UC_VER (chromium $NEW_PKGVER)"
echo "Upstream helium-linux      : $HELIUM_TAG"

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

python3 - "$ROOT_DIR" "$NEW_PKGVER" "$NEW_UC_VER" "$CHROMIUM_SHA" "$UC_SHA" "$CRUBIT_REV" <<'PY'
import pathlib, re, sys

root = pathlib.Path(sys.argv[1])
pkgver, uc_ver, cr_sha, uc_sha, crubit_rev = sys.argv[2:7]

for pkg in ("vulcanium", "ungoogled-vulcanium", "helcanium"):
    pb = root / "aur" / pkg / "PKGBUILD"
    text = pb.read_text()
    text = re.sub(r"^pkgver=.*$", f"pkgver={pkgver}", text, flags=re.M)
    text = re.sub(r"^pkgrel=.*$", "pkgrel=1", text, flags=re.M)
    if crubit_rev:
        text = re.sub(r"^_crubit_rev=.*$", f"_crubit_rev={crubit_rev}", text, flags=re.M)
    text = re.sub(r"^_uc_ver=.*$", f"_uc_ver={uc_ver}", text, flags=re.M)
    text = re.sub(
        r"(sha256sums=\(')([0-9a-f]{64})(')",
        rf"\g<1>{cr_sha}\g<3>",
        text,
        count=1,
    )
    if pkg == "ungoogled-vulcanium":
        # 3rd entry in sha256sums is ungoogled-chromium tarball
        lines = text.splitlines()
        for i, line in enumerate(lines):
            if "ungoogled-chromium-" in line and i + 5 < len(lines):
                for j in range(i, len(lines)):
                    if lines[j].strip().startswith("'") and len(lines[j].strip()) == 66:
                        # 2nd hash after sha256sums=('...'
                        pass
    pb.write_text(text)
    print(f"Updated {pb}")
PY

for pkg in vulcanium ungoogled-vulcanium helcanium; do
  (cd "$ROOT_DIR/aur/$pkg" && makepkg --printsrcinfo > .SRCINFO)
done

echo "Done. Review git diff before building."

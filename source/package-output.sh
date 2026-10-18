#!/bin/bash
set -euo pipefail

: "${UNRAID_VERSION:?UNRAID_VERSION is required}"
OUT_DIR="${OUT_DIR:-out}"
DIST_DIR="${DIST_DIR:-dist}"

CDC="$(find "$OUT_DIR" -type f -name 'cdc-wdm.ko*' | head -n1 || true)"
QMI="$(find "$OUT_DIR" -type f -name 'qmi_wwan.ko*' | head -n1 || true)"

[ -n "$CDC" ] || { echo "ERROR: cdc-wdm module not found" >&2; exit 1; }
[ -n "$QMI" ] || { echo "ERROR: qmi_wwan module not found" >&2; exit 1; }

CDC_KVER="$(modinfo -F vermagic "$CDC" | awk '{print $1}')"
QMI_KVER="$(modinfo -F vermagic "$QMI" | awk '{print $1}')"
[ -n "$CDC_KVER" ] || { echo "ERROR: empty cdc-wdm vermagic" >&2; exit 1; }
[ "$CDC_KVER" = "$QMI_KVER" ] || {
  echo "ERROR: module vermagic mismatch: cdc=$CDC_KVER qmi=$QMI_KVER" >&2
  exit 1
}

KVER="$CDC_KVER"
PKG="$(mktemp -d)"
trap 'rm -rf "$PKG"' EXIT
mkdir -p "$PKG/modules"
cp "$CDC" "$PKG/modules/cdc-wdm.ko"
cp "$QMI" "$PKG/modules/qmi_wwan.ko"

cat > "$PKG/manifest.env" <<MANIFEST
UNRAID_VERSION=$UNRAID_VERSION
KERNEL_VERSION=$KVER
MANIFEST

mkdir -p "$DIST_DIR"
BUNDLE="$DIST_DIR/hideck-qmi-${UNRAID_VERSION}.tar.gz"
tar -C "$PKG" -czf "$BUNDLE" manifest.env modules
(cd "$DIST_DIR" && sha256sum "$(basename "$BUNDLE")" > "$(basename "$BUNDLE").sha256")

echo "UNRAID_VERSION=$UNRAID_VERSION"
echo "KERNEL_VERSION=$KVER"
echo "BUNDLE=$BUNDLE"

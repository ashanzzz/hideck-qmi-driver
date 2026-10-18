#!/bin/bash
set -euo pipefail

URL="https://docs.unraid.net/unraid-os/download_list/"
HTML="$(curl -fsSL --retry 3 --connect-timeout 15 "$URL")"

# Stable downloadable releases use unRAIDServer-X.Y.Z-x86_64.zip.
# Pre-releases in the archive do not use this direct-download form.
printf '%s' "$HTML" \
  | grep -oE 'unRAIDServer-[0-9]+\.[0-9]+\.[0-9]+-x86_64\.zip' \
  | sed -E 's/^unRAIDServer-//; s/-x86_64\.zip$//' \
  | sort -Vu \
  | tail -n1

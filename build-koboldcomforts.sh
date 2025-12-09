#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MOD_NAME="koboldcomforts"
MOD_DIR="${ROOT_DIR}/${MOD_NAME}"

if [ ! -d "$MOD_DIR" ]; then
  echo "Error: mod directory '$MOD_DIR' not found." >&2
  exit 1
fi

cd "$MOD_DIR"

if [ ! -f "modinfo.json" ]; then
  echo "Error: modinfo.json not found in '$MOD_DIR'." >&2
  exit 1
fi

if [ ! -d "assets" ]; then
  echo "Error: assets directory not found in '$MOD_DIR'." >&2
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "Error: 'jq' is required but not installed. For example: sudo apt install jq" >&2
  exit 1
fi

VERSION="$(jq -r '.version // empty' modinfo.json)"

if [ -z "$VERSION" ]; then
  echo "Error: could not read 'version' from modinfo.json." >&2
  exit 1
fi

OUTPUT_ZIP="${ROOT_DIR}/${MOD_NAME}_${VERSION}.zip"

rm -f "$OUTPUT_ZIP"
zip -r "$OUTPUT_ZIP" assets modinfo.json > /dev/null

echo "Created $OUTPUT_ZIP"

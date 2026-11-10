#!/bin/bash

SRC_OVERLAY="$TARGET_ROOTFS/product/overlay"
DST_OVERLAY="$PORT_ROOTFS/product/overlay"
PORT_CFG="$PORT_METADATA/unified_config-product"
TARGET_CFG="$TARGET_METADATA/unified_config-product"

if [ ! -d "$SRC_OVERLAY" ]; then
    echo "Target product/overlay not found, skipping."
    return 0
fi

echo "Replacing donor product overlays with target stock RROs."
sudo rm -rf "$DST_OVERLAY"
sudo mkdir -p "$(dirname "$DST_OVERLAY")"
sudo cp -a "$SRC_OVERLAY" "$DST_OVERLAY"

if [ -f "$PORT_CFG" ] && [ -f "$TARGET_CFG" ]; then
    echo "Syncing product overlay metadata."
    TMP_CFG=$(mktemp)
    grep -v -E '^/overlay(/|$)' "$PORT_CFG" > "$TMP_CFG" || true
    grep -E '^/overlay(/|$)' "$TARGET_CFG" >> "$TMP_CFG" || true
    cat "$TMP_CFG" > "$PORT_CFG"
    rm -f "$TMP_CFG"
else
    echo "Warning: product metadata missing, permissions/contexts may be wrong."
fi

echo "Stock product overlays applied."

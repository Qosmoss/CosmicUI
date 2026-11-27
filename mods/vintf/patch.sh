#!/bin/bash
# Replace the donor VINTF device matrix/manifest with the target's stock one
# and sync the metadata so labels survive the repack.

VINTF_DIR="/system/system/etc/vintf"
PORT_VINTF_TARGET="$PORT_ROOTFS$VINTF_DIR"
STOCK_VINTF_SOURCE="$TARGET_ROOTFS$VINTF_DIR"

sudo mkdir -p "$PORT_VINTF_TARGET"

if [ -f "$STOCK_VINTF_SOURCE/compatibility_matrix.device.xml" ]; then
    info "Swapping in target compatibility matrix"
    sudo cp -a "$STOCK_VINTF_SOURCE/compatibility_matrix.device.xml" "$PORT_VINTF_TARGET/compatibility_matrix.device.xml"
else
    warn "compatibility_matrix.device.xml not found in $STOCK_VINTF_SOURCE"
fi

if [ -f "$STOCK_VINTF_SOURCE/manifest.xml" ]; then
    info "Swapping in target device manifest"
    sudo cp -a "$STOCK_VINTF_SOURCE/manifest.xml" "$PORT_VINTF_TARGET/manifest.xml"
fi

PORT_CFG="$PORT_METADATA/unified_config-system"
STOCK_CFG="$TARGET_METADATA/unified_config-system"

if [ -f "$STOCK_CFG" ] && [ -f "$PORT_CFG" ]; then
    TMP_MOD_CFG="$(mktemp)"
    grep -E "^${VINTF_DIR}" "$STOCK_CFG" > "$TMP_MOD_CFG" || true

    if [ -s "$TMP_MOD_CFG" ]; then
        # Target entries override donor entries on duplicate paths.
        merge_metadata "$PORT_CFG" "$TMP_MOD_CFG"
        info "Synced VINTF metadata"
    else
        warn "No VINTF entries found in target metadata ($STOCK_CFG)"
    fi
    rm -f "$TMP_MOD_CFG"
fi

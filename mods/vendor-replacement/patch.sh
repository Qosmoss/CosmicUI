#!/bin/bash
# Swap the donor vendor partition for the target's stock vendor rootfs, and
# sync unified_config-vendor so the repack step applies the target's labels.

STOCK_CFG="$TARGET_METADATA/unified_config-vendor"
PORT_CFG="$PORT_METADATA/unified_config-vendor"

if [ -f "$STOCK_CFG" ] && [ -f "$PORT_CFG" ]; then
    info "Using target vendor metadata"
    cp -- "$STOCK_CFG" "$PORT_CFG"
else
    warn "vendor-replacement: metadata missing ($STOCK_CFG or $PORT_CFG)"
fi

TARGET_PATH="/vendor"
PORT_TARGET_DIR="$PORT_ROOTFS$TARGET_PATH"
STOCK_TARGET_DIR="$TARGET_ROOTFS$TARGET_PATH"

if [ ! -d "$STOCK_TARGET_DIR" ]; then
    warn "vendor-replacement: target vendor directory not found ($STOCK_TARGET_DIR)"
    return 0
fi

if [ -d "$PORT_TARGET_DIR" ]; then
    info "Removing donor vendor files"
    sudo rm -rf "$PORT_TARGET_DIR"
fi
info "Copying target vendor files"
sudo cp -a "$STOCK_TARGET_DIR" "$PORT_TARGET_DIR"

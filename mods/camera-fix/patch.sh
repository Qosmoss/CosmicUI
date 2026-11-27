#!/bin/bash
# Replace the donor's camera feature list with the target's stock one.

TARGET_PATH="/system/system/cameradata/camera-feature.xml"
PORT_TARGET_DIR="$PORT_ROOTFS$TARGET_PATH"
STOCK_TARGET_DIR="$TARGET_ROOTFS$TARGET_PATH"

if [ ! -f "$STOCK_TARGET_DIR" ]; then
    warn "camera-fix: target feature XML not found ($STOCK_TARGET_DIR) — skipping"
    return 0
fi

if [ -f "$PORT_TARGET_DIR" ]; then
    sudo rm -f "$PORT_TARGET_DIR"
fi
info "Copying target camera feature XML"
sudo mkdir -p "$(dirname "$PORT_TARGET_DIR")"
sudo cp -a "$STOCK_TARGET_DIR" "$PORT_TARGET_DIR"

#!/bin/bash
# Swap the donor's VNDK apex (/system/system_ext/apex) for the target's
# stock one, so the APEX matches the target's vendor.

TARGET_PATH="/system/system/system_ext/apex"
PORT_TARGET_DIR="$PORT_ROOTFS$TARGET_PATH"
STOCK_TARGET_DIR="$TARGET_ROOTFS$TARGET_PATH"

if [ ! -d "$STOCK_TARGET_DIR" ]; then
    warn "vndk: target apex directory not found ($STOCK_TARGET_DIR) — skipping"
    return 0
fi

if [ -d "$PORT_TARGET_DIR" ]; then
    info "Removing donor apex files"
    sudo rm -rf "$PORT_TARGET_DIR"
fi
info "Copying target apex files"
sudo cp -a "$STOCK_TARGET_DIR" "$PORT_TARGET_DIR"

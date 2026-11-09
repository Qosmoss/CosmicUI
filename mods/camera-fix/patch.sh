#!/bin/bash
TARGET_PATH="/system/system/cameradata/camera-feature.xml"
PORT_TARGET_DIR="$PORT_ROOTFS$TARGET_PATH"
STOCK_TARGET_DIR="$TARGET_ROOTFS$TARGET_PATH"

if [ -f "$STOCK_TARGET_DIR" ]; then
    if [ -f "$PORT_TARGET_DIR" ]; then
        echo "Removing donor mapping files."
        sudo rm -rf "$PORT_TARGET_DIR"
    fi
    echo "Copying target mapping files."
    sudo cp -a "$STOCK_TARGET_DIR" "$PORT_TARGET_DIR"
else
    echo "Target mapping directory not found"
fi

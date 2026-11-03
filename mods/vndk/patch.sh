#!/bin/bash
TARGET_PATH="/system/system/system_ext/apex"
PORT_TARGET_DIR="$PORT_ROOTFS$TARGET_PATH"
STOCK_TARGET_DIR="$STOCK_ROOTFS$TARGET_PATH"

if [ -d "$STOCK_TARGET_DIR" ]; then
    if [ -d "$PORT_TARGET_DIR" ]; then
        echo "Removing donor mapping files."
        sudo rm -rf "$PORT_TARGET_DIR"
    fi
    echo "Copying target mapping files."
    sudo cp -a "$STOCK_TARGET_DIR" "$PORT_TARGET_DIR"
else
    echo "Target mapping directory not found"
fi

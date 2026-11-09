#!/bin/bash
TARGET_PATH="/vendor/lib64/libAImode_wrapper.camera.samsung.so"
CONFIG_VENDOR="$PORT_ROOTFS/vendor/etc/public.libraries.txt"
PORT_TARGET_DIR="$PORT_ROOTFS$TARGET_PATH"
STOCK_TARGET_DIR="$TARGET_ROOTFS$TARGET_PATH"

if [ -f "$STOCK_TARGET_DIR" ]; then
    if [ -f "$PORT_TARGET_DIR" ]; then
        echo "Removing donor mapping files."
        sudo rm -rf "$PORT_TARGET_DIR"
    fi
    echo "Copying target mapping files."
    sudo cp -a "$STOCK_TARGET_DIR" "$PORT_TARGET_DIR"
    if [ -f "$CONFIG_VENDOR" ]; then
        echo "libAImode_wrapper.camera.samsung.so" | sudo tee -a "$CONFIG_VENDOR" > /dev/null
        echo "done!!!!!!!!"
    fi
else
    echo "Target mapping directory not found"
fi

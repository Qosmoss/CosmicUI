#!/bin/bash

STOCK_CFG="$STOCK_META/unified_config-vendor"
PORT_CFG="$PORT_META/unified_config-vendor"

if [ -f "$STOCK_CFG" ] && [ -f "$PORT_CFG" ]; then
    rm -rf $PORT_CFG
    cp $STOCK_CFG $PORT_CFG
else
    echo "Metadata is missing."
fi

TARGET_PATH="/vendor"
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

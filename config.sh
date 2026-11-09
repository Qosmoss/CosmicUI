#!/bin/bash
ROM_VERSION="0.1-beta"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK_DIR="$ROOT_DIR/workspace"
NODE_DIR="$WORK_DIR/firmwares/$CURRENT_MODE"
# Download
FIRMWARE="$NODE_DIR/downloads/firmware.zip"
UNPACKED="$NODE_DIR/unpacked"
ROOTFS="$NODE_DIR/rootfs"
EXTRACTED="$NODE_DIR/extracted"
METADATA="$NODE_DIR/metadata"

# Donor directories(s23fe)
SOURCE_UNPACKED="$WORK_DIR/firmwares/$SOURCE/unpacked"
SOURCE_ROOTFS="$WORK_DIR/firmwares/$SOURCE/rootfs"
SOURCE_METADATA="$WORK_DIR/firmwares/$SOURCE/metadata"
# Stock directories(a55)
TARGET_UNPACKED="$WORK_DIR/firmwares/$TARGET/unpacked"
TARGET_ROOTFS="$WORK_DIR/firmwares/$TARGET/rootfs"
TARGET_METADATA="$WORK_DIR/firmwares/$TARGET/metadata"
# Port or output
PORT="$WORK_DIR/port"
PORT_ROOTFS="$PORT/rootfs"
PORT_METADATA="$PORT/metadata"

OUTPUT="$WORK_DIR/output"

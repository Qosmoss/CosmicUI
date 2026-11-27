#!/bin/bash
# Global CosmicUI configuration. Sourced by build.sh — do not run directly.
# Per-firmware paths are resolved by load_firmware_env() below; call it once
# per firmware set (donor and target) before the download/unpack phases.

ROM_NAME="CosmicUI"
ROM_VERSION="1.2"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK_DIR="$ROOT_DIR/workspace"
OUTPUT="$WORK_DIR/output"

PORT="$WORK_DIR/port"
PORT_ROOTFS="$PORT/rootfs"
PORT_METADATA="$PORT/metadata"

# Default empty; the base config (target/<target>/<base>.sh) fills this in.
MODS=()

# Point the firmware path variables at the given firmware set.
#   $1 = firmware dir name under workspace/firmwares (e.g. "s23fe")
# Sets: CURRENT_MODE, NODE_DIR, FIRMWARE, UNPACKED, ROOTFS, EXTRACTED, METADATA.
load_firmware_env() {
    local mode="$1"
    CURRENT_MODE="$mode"
    NODE_DIR="$WORK_DIR/firmwares/$mode"
    FIRMWARE="$NODE_DIR/downloads/firmware.zip"
    UNPACKED="$NODE_DIR/unpacked"
    ROOTFS="$NODE_DIR/rootfs"
    EXTRACTED="$NODE_DIR/extracted"
    METADATA="$NODE_DIR/metadata"
}

# SOURCE_UNPACKED / SOURCE_ROOTFS / SOURCE_METADATA and
# TARGET_UNPACKED / TARGET_ROOTFS / TARGET_METADATA are derived from the
# <base> and <target> arguments and are assigned by build.sh.

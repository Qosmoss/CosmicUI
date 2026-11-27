#!/bin/bash
# CosmicUI build orchestrator.
#
# Usage: ./build.sh <target> <base>
#   ./build.sh a55 s23fe
#
# <target>  device the ROM is built for (see target/<target>/config.sh)
# <base>    donor firmware to port (see target/<target>/<base>.sh)

set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

usage() {
    echo "Usage: ./build.sh <target> <base>   e.g. ./build.sh a55 s23fe" >&2
    exit 2
}

TARGET="${1:-}"
SOURCE="${2:-}"
[ -z "$TARGET" ] && usage
[ -z "$SOURCE" ] && usage

BASE_CFG="./target/$TARGET/$SOURCE.sh"
TARGET_CFG="./target/$TARGET/config.sh"
[ -f "$BASE_CFG" ]   || { echo "ERROR: no base config: $BASE_CFG" >&2; exit 1; }
[ -f "$TARGET_CFG" ] || { echo "ERROR: no target config: $TARGET_CFG" >&2; exit 1; }

source ./config.sh
source ./scripts/lib.sh

info "Checking dependencies..."
require_cmds samloader curl lz4 unzip tar simg2img lpunpack fsck.erofs mkfs.erofs \
             getfattr setfattr find awk tac sed sudo xxd

# Derived paths for donor (<base>) and target (<target>).
SOURCE_UNPACKED="$WORK_DIR/firmwares/$SOURCE/unpacked"
SOURCE_ROOTFS="$WORK_DIR/firmwares/$SOURCE/rootfs"
SOURCE_METADATA="$WORK_DIR/firmwares/$SOURCE/metadata"
TARGET_UNPACKED="$WORK_DIR/firmwares/$TARGET/unpacked"
TARGET_ROOTFS="$WORK_DIR/firmwares/$TARGET/rootfs"
TARGET_METADATA="$WORK_DIR/firmwares/$TARGET/metadata"

info "=== Phase 1/4: Donor firmware ($SOURCE) ==="
source "$BASE_CFG"
DONOR_MODEL="$MODEL"; DONOR_REGION="$REGION"; DONOR_VERSION="$VERSION"
DONOR_MODS=("${MODS[@]}")
load_firmware_env "$SOURCE"
source ./scripts/download_fw.sh
source ./scripts/unpack_fw.sh
source ./scripts/unpack_img.sh

info "=== Phase 2/4: Target firmware ($TARGET) ==="
source "$TARGET_CFG"
TARGET_MODEL="$MODEL"; TARGET_REGION="$REGION"; TARGET_VERSION="$VERSION"
load_firmware_env "$TARGET"
source ./scripts/download_fw.sh
source ./scripts/unpack_fw.sh
source ./scripts/unpack_img.sh

info "=== Phase 3/4: Patching port ==="
MODS=("${DONOR_MODS[@]}")
source ./scripts/patch_port.sh

info "=== Phase 4/4: Repacking partitions ==="
source ./scripts/repack_img.sh

# Reproducibility manifest (which inputs produced this output).
mkdir -p "$OUTPUT"
{
    echo "CosmicUI build manifest"
    echo "date_utc=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo "rom=$ROM_NAME $ROM_VERSION"
    echo "target=$TARGET model=$TARGET_MODEL region=$TARGET_REGION version=${TARGET_VERSION:-latest}"
    echo "base=$SOURCE model=$DONOR_MODEL region=$DONOR_REGION version=${DONOR_VERSION:-latest}"
    if command -v git >/dev/null 2>&1; then
        echo "git_commit=$(git rev-parse HEAD 2>/dev/null || echo unknown)"
        if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
            echo "git_dirty=yes"
        else
            echo "git_dirty=no"
        fi
    fi
    echo "mods:"
    for mod in "${DONOR_MODS[@]}"; do
        echo "  - $mod"
    done
} > "$OUTPUT/build-info.txt"
info "Manifest written to $OUTPUT/build-info.txt"
info "Done. Flashable output is in $OUTPUT/ (super/ holds the rebuilt partition images)."

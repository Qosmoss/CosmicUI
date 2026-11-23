#!/bin/bash
# Remove the donor's 32-bit Chrome/TrichromeLibrary. Play Store installs the
# 64-bit Chrome and its library once 32bit-to-64bit makes the device arm64-only.
#
# No unified_config file is needed here: this mod only deletes files, and
# repack skips metadata entries whose paths no longer exist.

PORT_PRODUCT="$PORT_ROOTFS/product/app"
if [ ! -d "$PORT_PRODUCT" ]; then
    echo "chrome-64: $PORT_PRODUCT not found, skipping."
    return 0
fi

sudo rm -rf "$PORT_PRODUCT/Chrome" "$PORT_PRODUCT/TrichromeLibrary"

# Drop the matching metadata entries (repack skips missing paths anyway).
PORT_CFG="$PORT_METADATA/unified_config-product"
[ -f "$PORT_CFG" ] && sudo sed -i -E '\#^/app/(Chrome|TrichromeLibrary)[/|]#d' "$PORT_CFG"

echo "chrome-64: removed 32-bit Chrome/TrichromeLibrary."

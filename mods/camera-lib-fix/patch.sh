#!/bin/bash
# Camera fix (A55 target): the donor (s23fe) camera HAL expects
# libAImode_wrapper.camera.samsung.so, so we pull that library from the
# DONOR and whitelist it in vendor public.libraries.txt.
# Note: vendor-replacement has already swapped in the stock vendor, which is
# why we copy this one library back from the donor on purpose.

TARGET_PATH="/vendor/lib64/libAImode_wrapper.camera.samsung.so"
CONFIG_VENDOR="$PORT_ROOTFS/vendor/etc/public.libraries.txt"
PORT_TARGET_DIR="$PORT_ROOTFS$TARGET_PATH"
DONOR_TARGET_DIR="$SOURCE_ROOTFS$TARGET_PATH"

if [ ! -f "$DONOR_TARGET_DIR" ]; then
    warn "camera-lib-fix: donor library not found ($DONOR_TARGET_DIR) — skipping"
    return 0
fi

if [ -f "$PORT_TARGET_DIR" ]; then
    sudo rm -rf "$PORT_TARGET_DIR"
fi
info "Copying donor camera library"
sudo cp -a "$DONOR_TARGET_DIR" "$PORT_TARGET_DIR"

if [ -f "$CONFIG_VENDOR" ]; then
    if sudo grep -qxF "libAImode_wrapper.camera.samsung.so" "$CONFIG_VENDOR"; then
        info "libAImode_wrapper.camera.samsung.so already whitelisted"
    else
        echo "libAImode_wrapper.camera.samsung.so" | sudo tee -a "$CONFIG_VENDOR" > /dev/null
        info "Whitelisted libAImode_wrapper.camera.samsung.so in public.libraries.txt"
    fi
else
    warn "camera-lib-fix: $CONFIG_VENDOR not found — library may be blocked by the linker"
fi

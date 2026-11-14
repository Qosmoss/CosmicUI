#!/bin/bash

# Unify the A55 vendor partition for SM-A556B and SM-A556E.
#
# Follows the LineageOS a55x vendor layout (reference tree: lineageos-vendor/).
# The shared vendor ships the B blobs as the base, while the per-variant
# firmware and TEE trees live under /vendor/firmware and are bind-mounted by
# init.a55x.unify.rc at early-init, keyed by ro.boot.em.model and
# ro.boot.bootloader. Metadata for the new paths is merged from
# unified_config-vendor by patch_port.sh.

MOD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Both variants are baked into the mod, so the built vendor is identical no
# matter which variant's firmware is the build source.
B_SRC="$MOD_DIR/A556B"
E_SRC="$MOD_DIR/A556E"

# B follows the target firmware being built; E is the donor variant baked in.
B_MODEL="${MODEL:-SM-A556B}"
B_BOOTLOADER="${VERSION%%/*}"
E_MODEL="SM-A556E"
E_BOOTLOADER="A556EXXSABYI4"

PORT_VENDOR="$PORT_ROOTFS/vendor"
FW_DIR="$PORT_VENDOR/firmware"

echo "Unifying vendor for $B_MODEL ($B_BOOTLOADER) and $E_MODEL ($E_BOOTLOADER)."

# Model-specific firmware blobs.
sudo mkdir -p "$FW_DIR/$B_MODEL" "$FW_DIR/$E_MODEL"
for fw in AIE.bin calliope_sram.bin mfc_fw.bin os.checked.bin pablo_icpufw.bin vts.bin; do
    sudo cp -a "$B_SRC/$fw" "$FW_DIR/$B_MODEL/$fw"
    sudo cp -a "$E_SRC/$fw" "$FW_DIR/$E_MODEL/$fw"
done

# Model-specific wifi firmware (bound like the rest; B and E blobs differ).
sudo mkdir -p "$FW_DIR/$B_MODEL/wifi" "$FW_DIR/$E_MODEL/wifi"
for fw in mx140.bin slsi_reg_database.bin; do
    sudo cp -a "$B_SRC/wifi/$fw" "$FW_DIR/$B_MODEL/wifi/$fw"
    sudo cp -a "$E_SRC/wifi/$fw" "$FW_DIR/$E_MODEL/wifi/$fw"
done

# /vendor/tee stays empty as the bind-mount point; the matching tree is
# mounted over it by init.a55x.unify.rc at early-init.
sudo rm -rf "$PORT_VENDOR/tee"
sudo mkdir -p "$PORT_VENDOR/tee"
sudo mkdir -p "$FW_DIR/tee/$B_BOOTLOADER" "$FW_DIR/tee/$E_BOOTLOADER"
sudo cp -a "$B_SRC/tee/." "$FW_DIR/tee/$B_BOOTLOADER/"
sudo cp -a "$E_SRC/tee/." "$FW_DIR/tee/$E_BOOTLOADER/"

# Variant bind-mount rules.
sudo mkdir -p "$PORT_VENDOR/etc/init"
sudo cp -a "$MOD_DIR/init.a55x.unify.rc" "$PORT_VENDOR/etc/init/init.a55x.unify.rc"

# Drop the stock /tee entries; the files now live under /firmware/tee.
sed -i '/^\/tee\//d' "$PORT_METADATA/unified_config-vendor"

# Allow init to bind-mount over the tee dir and the per-model firmware files.
# Search/read on vendor_file_type is already granted by plat_sepolicy.
# The A55 vendor targets sepolicy 34.0 (device launched on Android 14), but
# derive the init attribute from the vendor itself instead of hardcoding
# init_XX_0 — a wrong version attribute fails policy compile at boot.
SEPVERS="$(head -n1 "$PORT_VENDOR/etc/selinux/plat_sepolicy_vers.txt" 2>/dev/null | tr -d '[:space:]')"
SEPVERS="${SEPVERS:-34.0}"
INIT_ATTR="init_${SEPVERS//./_}"
echo "Vendor sepolicy version $SEPVERS -> $INIT_ATTR"
sudo tee -a "$PORT_VENDOR/etc/selinux/vendor_sepolicy.cil" > /dev/null <<EOF

;; unify-vendor: variant mounts
(allow $INIT_ATTR tee_file (dir (mounton)))
(allow $INIT_ATTR vendor_fw_file (file (mounton)))
EOF

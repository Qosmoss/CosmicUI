#!/bin/bash
# Build the port tree: copy the donor rootfs/metadata into $PORT, copy the
# loose (non-super) partition images, then apply MODS in order.
# Meant to be sourced by build.sh — do not run directly.

case "$PORT" in
    "$WORK_DIR"/port) ;;
    ""|*) die "Refusing to wipe unexpected PORT path: '$PORT'" ;;
esac

info "Wiping previous port at $PORT"
sudo rm -rf "$PORT"
mkdir -p "$PORT_ROOTFS" "$PORT_METADATA"

info "Copying donor firmware (rootfs and metadata)..."
sudo cp -a "$SOURCE_ROOTFS"/. "$PORT_ROOTFS/"
sudo cp -a "$SOURCE_METADATA"/. "$PORT_METADATA/"

if [ -d "$SOURCE_UNPACKED" ]; then
    find "$SOURCE_UNPACKED" -maxdepth 1 -type f -name '*.img' \
        ! -name 'super.img' ! -name 'super.img.raw' -exec cp -- {} "$PORT/" \;
fi

for mod_path in "${MODS[@]}"; do
    mod_dir="./mods/$mod_path"
    if [ ! -d "$mod_dir" ]; then
        die "Mod '$mod_path' not found (expected directory: $mod_dir)"
    fi

    # Merge any shipped unified_config-* files into the port metadata first;
    # mod entries win over existing ones on duplicate paths.
    for custom_cfg in "$mod_dir"/unified_config-*; do
        [ -f "$custom_cfg" ] || continue
        cfg_target="$(basename "$custom_cfg")"
        merge_metadata "$PORT_METADATA/$cfg_target" "$custom_cfg"
        info "Merged $mod_path metadata into $cfg_target"
    done

    if [ -f "$mod_dir/patch.sh" ]; then
        info "Applying mod: $mod_path"
        if ! ( set -e; source "$mod_dir/patch.sh" ); then
            die "Mod '$mod_path' failed"
        fi
    else
        info "Mod '$mod_path' has no patch.sh (metadata only)"
    fi
done

info "All mods applied."

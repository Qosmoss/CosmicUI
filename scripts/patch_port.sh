#!/bin/bash

sudo rm -rf "$PORT"
mkdir -p "$PORT_ROOTFS" "$PORT_METADATA"

echo "Copying donor fw."
sudo cp -a "$SOURCE_ROOTFS"/. "$PORT_ROOTFS/"
sudo cp -a "$SOURCE_METADATA"/. "$PORT_METADATA/"

if [ -d "$SOURCE_UNPACKED" ]; then
    find "$SOURCE_UNPACKED" -maxdepth 1 -type f -name "*.img" ! -name "super.img" ! -name "super.img.raw" -exec cp {} "$PORT/" \; 2>/dev/null
fi

for mod_path in "${MODS[@]}"; do
    mod_dir="./mods/$mod_path"
    if [ -d "$mod_dir" ]; then
        for custom_cfg in "$mod_dir"/unified_config-*; do
             if [ -f "$custom_cfg" ]; then
                cfg_target=$(basename "$custom_cfg")          
                TMP_MERGE=$(mktemp)
                cat "$PORT_METADATA/$cfg_target" "$custom_cfg" 2>/dev/null > "$TMP_MERGE"
                tac "$TMP_MERGE" | awk -F'|' '!x[$1]++' | tac > "$PORT_METADATA/$cfg_target"
                rm -f "$TMP_MERGE"
             fi
        done
        if [ -f "$mod_dir/patch.sh" ]; then
            echo "Applying module: $mod_path"
            source "$mod_dir/patch.sh"
        fi
    fi
done
echo "All mods are done!"

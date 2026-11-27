#!/bin/bash
# Replace the donor's SELinux policy-mapping directory with the target's
# stock one, and sync the metadata so the repack step applies the right
# labels. (The mapping lives inside the system partition at /system/etc.)

MAPPING_FS="/system/system/etc/selinux/mapping"   # path inside the rootfs tree
META_PREFIX="/system/etc/selinux/mapping"          # path prefix used in unified_config

STOCK_MAPPING="$TARGET_ROOTFS$MAPPING_FS"
PORT_MAPPING="$PORT_ROOTFS$MAPPING_FS"
STOCK_CFG="$TARGET_METADATA/unified_config-system"
PORT_CFG="$PORT_METADATA/unified_config-system"

if [ ! -d "$STOCK_MAPPING" ]; then
    warn "selinux-mappings: target mapping directory not found ($STOCK_MAPPING) — skipping"
    return 0
fi

if [ -d "$PORT_MAPPING" ]; then
    info "Removing donor mapping files"
    sudo rm -rf "$PORT_MAPPING"
fi
info "Copying target mapping files"
sudo mkdir -p "$(dirname "$PORT_MAPPING")"
sudo cp -a "$STOCK_MAPPING" "$PORT_MAPPING"

if [ -f "$STOCK_CFG" ] && [ -f "$PORT_CFG" ]; then
    # Drop the donor's mapping entries, then add the target's (last wins).
    TMP_STRIPPED="$(mktemp)"
    grep -v -E "^${META_PREFIX}(/|\\||$)" "$PORT_CFG" > "$TMP_STRIPPED" || true
    cat "$TMP_STRIPPED" > "$PORT_CFG"
    rm -f "$TMP_STRIPPED"

    TMP_STOCK_LINES="$(mktemp)"
    grep -E "^${META_PREFIX}(/|\\||$)" "$STOCK_CFG" > "$TMP_STOCK_LINES" || true

    if [ -s "$TMP_STOCK_LINES" ]; then
        merge_metadata "$PORT_CFG" "$TMP_STOCK_LINES"
        info "Synced SELinux mapping metadata"
    else
        warn "No mapping entries found in target metadata ($STOCK_CFG)"
    fi
    rm -f "$TMP_STOCK_LINES"
else
    warn "Metadata missing ($STOCK_CFG or $PORT_CFG) — permissions/contexts may be wrong"
fi

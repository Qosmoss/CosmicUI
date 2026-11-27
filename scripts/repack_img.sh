#!/bin/bash
# Apply the recorded ownership/SELinux/capabilities to the port tree and
# repack each partition as an erofs image into $OUTPUT/super. Loose partition
# images (boot, dtbo, recovery, vbmeta_patched, ...) are copied to $OUTPUT.
# Meant to be sourced by build.sh — do not run directly.

case "$OUTPUT" in
    "$WORK_DIR"/output) ;;
    ""|*) die "Refusing to wipe unexpected OUTPUT path: '$OUTPUT'" ;;
esac

sudo rm -rf "$OUTPUT"
mkdir -p "$OUTPUT/super"

mapfile -t PARTITIONS < <(find "$PORT_ROOTFS" -mindepth 1 -maxdepth 1 -type d -exec basename -- {} \; | sort)

if [ "${#PARTITIONS[@]}" -eq 0 ]; then
    die "No partitions found in $PORT_ROOTFS — did patch_port.sh run?"
fi

for part in "${PARTITIONS[@]}"; do
    SRC_SUBDIR="$PORT_ROOTFS/$part"
    IMG_OUTPUT="$OUTPUT/super/$part.img"
    UNIFIED_CONFIG="$PORT_METADATA/unified_config-$part"

    if [ ! -f "$UNIFIED_CONFIG" ]; then
        die "Missing metadata for partition '$part' ($UNIFIED_CONFIG) — refusing to build an unlabeled image"
    fi

    info "Applying attributes to [$part]"
    while IFS='|' read -r r_path uid gid mode selinux_ctx capabilities; do
        [ -z "$r_path" ] && continue

        if [ "$r_path" = "/" ]; then
            local_path="$SRC_SUBDIR"
        else
            local_path="$SRC_SUBDIR$r_path"
        fi

        if [ -e "$local_path" ] || [ -L "$local_path" ]; then
            sudo chown -h "$uid:$gid" "$local_path"
            sudo chmod -h "$mode" "$local_path" 2>/dev/null || true

            if [ -L "$local_path" ]; then
                sudo chmod -f "$mode" "$local_path" 2>/dev/null || true
            fi

            sudo setfattr -hn security.selinux -v "${selinux_ctx}\0" "$local_path" 2>/dev/null || true

            if [ "$capabilities" != "0x0" ] && [ "$capabilities" != "0x00000000" ]; then
                cap_bin="${capabilities#0x}"

                if ! printf '%s' "$cap_bin" | xxd -r -p | sudo setfattr -hn security.capability -v - "$local_path"; then
                    warn "Could not set capabilities on $local_path"
                fi
            fi
        fi
    done < "$UNIFIED_CONFIG"

    info "Building erofs image for [$part]"
    rm -f "$IMG_OUTPUT"
    if ! sudo mkfs.erofs \
        -z lz4hc,9 \
        -b 4096 \
        -T 1640995200 \
        --mount-point="/$part" \
        "$IMG_OUTPUT" "$SRC_SUBDIR/"; then
        die "mkfs.erofs failed for partition [$part]"
    fi

    if [ ! -s "$IMG_OUTPUT" ]; then
        die "mkfs.erofs produced no output for partition [$part]"
    fi

    info "Partition [$part] repacked."
done

find "$PORT" -maxdepth 1 -type f -name '*.img' -exec cp -- {} "$OUTPUT/" \;

info "All partitions repacked into $OUTPUT/super (erofs images)"
info "Loose partition images copied to $OUTPUT/"

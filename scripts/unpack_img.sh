#!/bin/bash
# Extract the super partition images and record per-file metadata (uid/gid/
# mode/SELinux context/capabilities) into $METADATA/unified_config-<part>.
# Meant to be sourced by build.sh — do not run directly.

if [ -d "$ROOTFS" ] && [ -n "$(ls -A "$ROOTFS" 2>/dev/null)" ]; then
    info "Rootfs already present at $ROOTFS"
    return 0
fi

if [ ! -f "$EXTRACTED/system.img" ] || [ ! -f "$EXTRACTED/vendor.img" ]; then
    if [ ! -f "$UNPACKED/super.img" ]; then
        die "super.img not found in $UNPACKED — nothing to unpack"
    fi

    mkdir -p "$EXTRACTED"
    info "Converting super.img to raw (sparse -> raw)..."
    if ! simg2img "$UNPACKED/super.img" "$UNPACKED/super.img.raw"; then
        rm -f "$UNPACKED/super.img.raw"
        die "simg2img failed on $UNPACKED/super.img"
    fi
    if [ ! -s "$UNPACKED/super.img.raw" ]; then
        rm -f "$UNPACKED/super.img.raw"
        die "simg2img produced an empty raw image"
    fi

    info "Lpunpacking..."
    if ! lpunpack "$UNPACKED/super.img.raw" "$EXTRACTED"; then
        rm -f "$UNPACKED/super.img.raw"
        die "lpunpack failed on $UNPACKED/super.img.raw"
    fi
    rm -f "$UNPACKED/super.img.raw"

    # Drop the inactive slot and normalize slot_a images to plain names.
    (
        cd "$EXTRACTED" || exit 1
        rm -f ./*_b.img
        for slot_file in ./*_a.img; do
            [ -f "$slot_file" ] || continue
            mv -- "$slot_file" "${slot_file%_a.img}.img"
        done
    ) || die "Failed to normalize slot images in $EXTRACTED"
fi

mapfile -t AVAILABLE_IMAGES < <(find "$EXTRACTED" -maxdepth 1 -type f -name '*.img' | sort)

if [ "${#AVAILABLE_IMAGES[@]}" -eq 0 ]; then
    die "No .img files found in $EXTRACTED"
fi

mkdir -p "$ROOTFS" "$METADATA"

FAILURES=0
for IMG_FILE in "${AVAILABLE_IMAGES[@]}"; do
    img_name="$(basename "$IMG_FILE" .img)"
    TARGET_OUT_DIR="$ROOTFS/$img_name"

    case "$TARGET_OUT_DIR" in
        "$ROOTFS"/*) ;;
        *) die "Refusing to remove unexpected path: $TARGET_OUT_DIR" ;;
    esac
    sudo rm -rf "$TARGET_OUT_DIR"
    mkdir -p "$TARGET_OUT_DIR"

    UNIFIED_CONFIG="$METADATA/unified_config-$img_name"
    : > "$UNIFIED_CONFIG"

    info "Unpacking $img_name..."
    if ! sudo fsck.erofs --extract="$TARGET_OUT_DIR" --xattrs --force --overwrite --preserve "$IMG_FILE" >/dev/null; then
        warn "Failed to unpack $img_name"
        sudo rm -rf "$TARGET_OUT_DIR"
        FAILURES=$((FAILURES + 1))
        continue
    fi
    if [ -z "$(ls -A "$TARGET_OUT_DIR" 2>/dev/null)" ]; then
        warn "Extraction of $img_name produced no files"
        sudo rm -rf "$TARGET_OUT_DIR"
        FAILURES=$((FAILURES + 1))
        continue
    fi

    FLIST="$(mktemp)"
    sudo find "$TARGET_OUT_DIR" > "$FLIST"

    while IFS= read -r f_path; do
        [ -z "$f_path" ] && continue

        read -r uid gid mode <<< "$(sudo stat -c '%u %g %a' "$f_path")"

        cap_raw="$(sudo getfattr -n security.capability --only-values -h --absolute-names "$f_path" 2>/dev/null | od -An -v -tx1 | tr -d ' \n')"
        if [ -z "$cap_raw" ]; then
            cap_raw="0x0"
        else
            cap_raw="0x$cap_raw"
        fi

        selinux_ctx="$(sudo getfattr -n security.selinux --only-values -h --absolute-names "$f_path" 2>/dev/null | tr -d '\0')"
        [ -z "$selinux_ctx" ] && selinux_ctx="u:object_r:unlabeled:s0"

        r_path="${f_path#"$TARGET_OUT_DIR"}"
        [ -z "$r_path" ] && r_path="/"

        printf '%s|%s|%s|%s|%s|%s\n' "$r_path" "$uid" "$gid" "$mode" "$selinux_ctx" "$cap_raw" >> "$UNIFIED_CONFIG"
    done < "$FLIST"
    rm -f "$FLIST"
    info "Partition $img_name mapped successfully."
done

if [ "$FAILURES" -gt 0 ]; then
    die "$FAILURES partition(s) failed to unpack"
fi

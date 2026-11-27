#!/bin/bash
# Unpack firmware.zip into $UNPACKED:
#   1. AP_*.tar(.md5) (if present) is extracted with tar (auto-detects compression)
#   2. *.lz4 payloads are decompressed in place
# Meant to be sourced by build.sh — do not run directly.

if [ -d "$UNPACKED" ] && [ -n "$(ls -A "$UNPACKED" 2>/dev/null)" ]; then
    info "Firmware already unpacked at $UNPACKED"
    return 0
fi

[ -f "$FIRMWARE" ] || die "No firmware.zip at $FIRMWARE — download it first"
mkdir -p "$UNPACKED"

if unzip -l "$FIRMWARE" | awk '{print $4}' | grep -q '^AP_'; then
    AP_FILE="$(unzip -l "$FIRMWARE" | awk '{print $4}' | grep -m1 '^AP_')"
    info "Extracting $AP_FILE ..."
    if ! unzip -p "$FIRMWARE" "$AP_FILE" | tar -xC "$UNPACKED"; then
        die "Failed to extract $AP_FILE from $FIRMWARE"
    fi
else
    info "No AP package found; extracting zip contents directly"
    if ! unzip -j -q "$FIRMWARE" '*' -d "$UNPACKED"; then
        die "Failed to extract $FIRMWARE"
    fi
fi

shopt -s nullglob
LZ_FILES=("$UNPACKED"/*.lz4)
shopt -u nullglob
if [ "${#LZ_FILES[@]}" -gt 0 ]; then
    info "Decompressing ${#LZ_FILES[@]} lz4 file(s)..."
    for LZ_FILE in "${LZ_FILES[@]}"; do
        if ! lz4 -d -f --rm "$LZ_FILE" "${LZ_FILE%.lz4}" >/dev/null; then
            die "lz4 decompression failed: $LZ_FILE"
        fi
    done
fi

if [ -z "$(ls -A "$UNPACKED" 2>/dev/null)" ]; then
    die "Unpacking produced nothing in $UNPACKED"
fi
info "Firmware unpacked to $UNPACKED"

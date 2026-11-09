#!/bin/bash

[ -d "$UNPACKED" ] && [ "$(ls -A "$UNPACKED" 2>/dev/null)" ] && { echo "Firmware is already here!"; return 0; }
[ ! -f "$FIRMWARE" ] && { echo  "There is no fw here..."; return 1; }

mkdir -p "$UNPACKED"

if unzip -l "$FIRMWARE" | grep -q "AP_"; then
    unzip -p "$FIRMWARE" "AP_*" | tar -xC "$UNPACKED" 2>/dev/null
else
    unzip -j -q "$FIRMWARE" "*" -d "$UNPACKED" 2>/dev/null
fi

if ls "$UNPACKED"/*.lz4 &>/dev/null; then
    echo "Decompressing all binaries..."
    for lz_file in "$UNPACKED"/*.lz4; do
        [ -f "$lz_file" ] || continue
        lz4 -d -f --rm "$lz_file" "${lz_file%.lz4}" &>/dev/null
    done
fi

[ "$(ls -A "$UNPACKED" 2>/dev/null)" ] && echo "All fw was unpacked!" || { echo "Something is wrong!"; return 1; }

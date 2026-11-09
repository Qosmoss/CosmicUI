#!/bin/bash

ORIG_VBMETA="$TARGET_UNPACKED/vbmeta.img"
PATCHED_VBMETA="$PORT/vbmeta_patched.img"

if [ -f "$ORIG_VBMETA" ]; then
    cp -a "$ORIG_VBMETA" "$PATCHED_VBMETA"
    printf "\x03" | dd of="$PATCHED_VBMETA" bs=1 seek=123 count=1 conv=notrunc &>/dev/null
    
    if [ $? -eq 0 ]; then
        echo -e "Vbmeta was patched."
    else
        echo "Error!"
        rm -f "$PATCHED_VBMETA"
    fi
else
    echo "vbmeta.img not found."
fi

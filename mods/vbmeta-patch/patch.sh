#!/bin/bash
# Patch vbmeta to disable AVB verification, so the bootloader accepts
# our repacked (unsigned) system images.
#
# vbmeta layout (libavb AvbVBMetaImageHeader): the flags field is a
# big-endian u32 at offset 120. We only rewrite the least-significant byte
# at offset 123 (dd conv=notrunc keeps the file the same size).
#   0x01 = AVB_VBMETA_IMAGE_FLAGS_HASHTREE_DISABLED
#   0x02 = AVB_VBMETA_IMAGE_FLAGS_VERIFICATION_DISABLED
#   0x03 = both.

ORIG_VBMETA="$TARGET_UNPACKED/vbmeta.img"
PATCHED_VBMETA="$PORT/vbmeta_patched.img"

if [ ! -f "$ORIG_VBMETA" ]; then
    echo "vbmeta-patch: $ORIG_VBMETA not found — skipping"
    return 0
fi

cp -- "$ORIG_VBMETA" "$PATCHED_VBMETA"
if printf '\x03' | dd of="$PATCHED_VBMETA" bs=1 seek=123 count=1 conv=notrunc status=none; then
    echo "vbmeta-patch: patched vbmeta (flags -> 0x03) $PATCHED_VBMETA"
else
    echo "vbmeta-patch: dd failed" >&2
    rm -f "$PATCHED_VBMETA"
    return 1
fi

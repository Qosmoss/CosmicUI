#!/bin/bash
# Show the ROM name as the build number in Settings → About phone.

PROP="$PORT_ROOTFS/system/system/build.prop"
[ -f "$PROP" ] || { echo "rom-branding: $PROP not found, skipping."; return 0; }

NEW_ID="$ROM_NAME"
[ -n "$ROM_VERSION" ] && NEW_ID="$ROM_NAME $ROM_VERSION"

# Escape characters that mean something to sed.
NEW_ID_ESC=$(printf '%s' "$NEW_ID" | sed 's/[&|\\]/\\&/g')

if sudo grep -q '^ro\.build\.display\.id=' "$PROP"; then
    sudo sed -i "s|^ro\.build\.display\.id=.*|ro.build.display.id=$NEW_ID_ESC|" "$PROP"
else
    echo "ro.build.display.id=$NEW_ID" | sudo tee -a "$PROP" >/dev/null
fi

echo "rom-branding: build number -> $NEW_ID"

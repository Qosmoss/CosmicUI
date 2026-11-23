#!/bin/bash
# Replace the system hosts file with the StevenBlack ad blocklist.

HOSTS_URL="https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
HOSTS_FILE="$PORT_ROOTFS/system/system/etc/hosts"

if [ ! -f "$HOSTS_FILE" ]; then
    echo "adblock-hosts: $HOSTS_FILE not found, skipping."
    return 0
fi

TMP=$(mktemp)
if ! curl -fsSL --max-time 60 "$HOSTS_URL" -o "$TMP"; then
    rm -f "$TMP"
    echo "adblock-hosts: download failed, skipping."
    return 0
fi

sudo tee "$HOSTS_FILE" < "$TMP" > /dev/null
rm -f "$TMP"
echo "adblock-hosts: replaced $HOSTS_FILE ($(sudo wc -l < "$HOSTS_FILE") lines)."

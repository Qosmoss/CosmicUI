#!/bin/bash
# Advertise arm64-v8a only, matching the A55's 64-bit-only vendor stack.
# Without this, Play Store keeps serving 32-bit apps (Chrome, etc.).

for prop in \
    system/system/build.prop \
    vendor/build.prop \
    product/etc/build.prop \
    odm/etc/build.prop; do
    f="$PORT_ROOTFS/$prop"
    [ -f "$f" ] || continue

    sudo sed -i \
        -e 's/^ro\.zygote=.*/ro.zygote=zygote64/' \
        -e 's/^ro\.product\.cpu\.abilist=.*/ro.product.cpu.abilist=arm64-v8a/' \
        -e 's/^ro\.product\.cpu\.abilist32=.*/ro.product.cpu.abilist32=/' \
        -e 's/^ro\.product\.cpu\.abilist64=.*/ro.product.cpu.abilist64=arm64-v8a/' \
        "$f"

    for line in \
        'ro.zygote=zygote64' \
        'ro.product.cpu.abilist=arm64-v8a' \
        'ro.product.cpu.abilist32=' \
        'ro.product.cpu.abilist64=arm64-v8a'; do
        key="${line%%=*}"
        sudo grep -q "^$key=" "$f" || echo "$line" | sudo tee -a "$f" > /dev/null
    done
done

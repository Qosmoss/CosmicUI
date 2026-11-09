#!/bin/bash
echo -e "Fetching $CURRENT_MODE Firmware ($MODEL)"

mkdir -p "$NODE_DIR/downloads"

if [ -f "$FIRMWARE" ]; then
    echo "Firmware package already exists"
    return 0
fi

SAM_CMD="-m $MODEL -r $REGION"

VERSION_TO_DOWNLOAD=""
if [ -n "$VERSION" ]; then
    echo "firmware version: $VERSION"
    VERSION_TO_DOWNLOAD="$VERSION"
else
    echo "Fetching firmware version."
    VERSION_TO_DOWNLOAD=$(samloader check-update $SAM_CMD)
    if [ -z "$VERSION_TO_DOWNLOAD" ]; then
        echo  "Failed to fetch."
        return 1
    fi
    echo "Latest version: $VERSION_TO_DOWNLOAD"
fi

# 5. Скачивание
echo "Starting download..."
samloader download $SAM_CMD -v "$VERSION_TO_DOWNLOAD" -o "$FIRMWARE"

# 7. Проверка результата
if [ -f "$FIRMWARE" ]; then
    echo "Firmware downloaded: $FIRMWARE"
else
    echo "Error: firmware.zip not found."
    return 1
fi

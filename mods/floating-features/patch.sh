#!/bin/bash
# Floating feature overrides. Add or uncomment set_feature lines below.
# Format: set_feature <TAG> <VALUE>

TARGET_XML_PATH="/system/system/etc/floating_feature.xml"
FILE_TO_PATCH="$PORT_ROOTFS$TARGET_XML_PATH"

if [ ! -f "$FILE_TO_PATCH" ]; then
    echo "floating-features: $FILE_TO_PATCH not found"
    return 0
fi

set_feature() {
    sudo sed -i "s|<\($1\)>[^<]*</\1>|<\1>$2</\1>|" "$FILE_TO_PATCH"
}

# --- AOD ---
#set_feature SEC_FLOATING_FEATURE_FRAMEWORK_CONFIG_AOD_ITEM aodversion=7,clocktransition
set_feature SEC_FLOATING_FEATURE_LCD_CONFIG_AOD_FULLSCREEN 1
set_feature SEC_FLOATING_FEATURE_LCD_CONFIG_AOD_BRIGHTNESS_ANIMATION 1
#set_feature SEC_FLOATING_FEATURE_LCD_CONFIG_AOD_REFRESH_RATE 1

# --- Animations / blur ---
#set_feature SEC_FLOATING_FEATURE_LAUNCHER_CONFIG_ANIMATION_TYPE HighEnd
#set_feature SEC_FLOATING_FEATURE_GRAPHICS_SUPPORT_CAPTURED_BLUR TRUE
#set_feature SEC_FLOATING_FEATURE_GRAPHICS_SUPPORT_PARTIAL_BLUR TRUE

# --- Display ---
#set_feature SEC_FLOATING_FEATURE_LCD_CONFIG_CONTROL_AUTO_BRIGHTNESS 5
#set_feature SEC_FLOATING_FEATURE_LCD_CONFIG_HFR_DEFAULT_REFRESH_RATE 120
#set_feature SEC_FLOATING_FEATURE_LCD_CONFIG_HFR_SUPPORTED_REFRESH_RATE 60,120

echo "floating-features: done"

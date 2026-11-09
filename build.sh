#!/bin/bash

TARGET=$1
SOURCE=$2

source "./config.sh"

source "./target/$TARGET/$SOURCE.sh"
CURRENT_MODE="$SOURCE"
source "./config.sh"
source "./scripts/download_fw.sh"
source "./scripts/unpack_fw.sh"
source "./scripts/unpack_img.sh"

source "./target/$TARGET/config.sh"
CURRENT_MODE="$TARGET"
source "./config.sh"
source "./scripts/download_fw.sh"
source "./scripts/unpack_fw.sh"
source "./scripts/unpack_img.sh"


source "./config.sh"
source "./scripts/patch_port.sh"
source "./scripts/repack_img.sh"

echo "Done!"

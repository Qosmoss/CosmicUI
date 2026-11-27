#!/bin/bash
# Download the firmware zip for the CURRENT_MODE firmware set.
# Uses samloader; MODEL/REGION/VERSION come from the sourced target/base
# config. VERSION may be empty, in which case the latest is resolved.
# Meant to be sourced by build.sh — do not run directly.

info "Fetching firmware ($CURRENT_MODE) — model $MODEL, CSC $REGION"

mkdir -p "$NODE_DIR/downloads"

if [ -f "$FIRMWARE" ]; then
    info "Firmware package already exists: $FIRMWARE"
    return 0
fi

if [ -n "$VERSION" ]; then
    info "Using pinned firmware version: $VERSION"
    VERSION_TO_DOWNLOAD="$VERSION"
else
    info "No VERSION pinned, checking for the latest release..."
    if ! VERSION_TO_DOWNLOAD="$(samloader check-update -m "$MODEL" -r "$REGION" | tail -n1 | tr -d '\r')"; then
        die "Failed to query the latest firmware version for $MODEL/$REGION"
    fi
    if [ -z "$VERSION_TO_DOWNLOAD" ]; then
        die "samloader returned an empty version for $MODEL/$REGION"
    fi
    info "Latest version: $VERSION_TO_DOWNLOAD"
fi

info "Starting download (this can take a while)..."
if ! samloader download -m "$MODEL" -r "$REGION" -v "$VERSION_TO_DOWNLOAD" -o "$FIRMWARE"; then
    die "samloader download failed for $MODEL/$REGION (version $VERSION_TO_DOWNLOAD)"
fi

if [ ! -s "$FIRMWARE" ]; then
    rm -f "$FIRMWARE"
    die "Download finished but $FIRMWARE is missing or empty"
fi

info "Firmware downloaded: $FIRMWARE"

#!/bin/bash
# Shared helpers for CosmicUI scripts. Sourced by build.sh and the phase
# scripts; not meant to be executed directly.

info() { printf '==> %s\n' "$*"; }
warn() { printf 'WARNING: %s\n' "$*" >&2; }
die()  { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

# Fail fast if any required tool is missing.
require_cmds() {
    local missing=() cmd
    for cmd in "$@"; do
        command -v "$cmd" >/dev/null 2>&1 || missing+=("$cmd")
    done
    if [ "${#missing[@]}" -gt 0 ]; then
        die "Missing required tools: ${missing[*]} (see docs/porting.md#dependencies)"
    fi
}

# Merge one or more metadata override files into a port unified_config file.
# Lines later in the list win on duplicate paths (port lines come first,
# override lines are appended, then duplicates are dropped keeping the last
# occurrence). Creates the port file if it does not exist.
merge_metadata() {
    local port_cfg="$1"; shift
    local sources=("$port_cfg") f
    if [ ! -f "$port_cfg" ]; then
        mkdir -p "$(dirname "$port_cfg")"
        : > "$port_cfg"
    fi
    for f in "$@"; do
        [ -f "$f" ] && sources+=("$f")
    done
    local tmp
    tmp="$(mktemp)"
    cat "${sources[@]}" > "$tmp"
    tac "$tmp" | awk -F'|' '!x[$1]++' | tac > "$port_cfg"
    rm -f "$tmp"
}

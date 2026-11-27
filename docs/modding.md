# Writing Mods for CosmicUI

A **mod** is a small, self-contained directory that makes one change to the
port tree. Mods are the only supported way to patch a build — if you find a
device bug while testing, the fix goes in a mod so the next rebuild stays
clean and reproducible.

---

### 1. Where mods live

```
mods/<mod-name>/
├── patch.sh            # optional — the actual change(s)
└── unified_config-*    # optional — extra metadata entries (one per partition)
```

Device-specific mods live under `mods/<device>/` (e.g. `mods/a55/camera-lib-fix`).
Shared, reusable mods live at the top level (`mods/rom-branding`, …).

### 2. Declare the mod

Mods are applied in the order they are listed in the **base config**
(`target/<device>/<base>.sh`):

```bash
MODS=("vendor-replacement" "selinux-mappings" "vbmeta-patch" … "a55/camera-lib-fix")
```

- Order matters: later mods can overwrite earlier ones (files, and metadata
  entries on the same path — the later entry wins).
- Stock-replacement mods (vendor-replacement, selinux-mappings, vintf, vndk)
  should run before device-specific fixes, so fixes apply on top of stock
  content.
- A mod that is listed but missing on disk is a hard error — the build stops
  and tells you which one.

### 3. How a mod runs

`scripts/patch_port.sh` does, for each entry in `MODS`:

1. **Metadata merge** — every `unified_config-*` file in the mod directory is
   merged into the port's `metadata/unified_config-*`. Merge semantics:
   existing port lines come first, the mod's lines are appended, and duplicate
   paths keep the *last* occurrence. So a mod's lines override donor lines,
   and a later mod's lines override an earlier mod's.
2. **patch.sh** — sourced in a subshell with `set -euo pipefail` enabled, in
   the repo root. If it exits non-zero the build fails with
   `ERROR: Mod '<name>' failed`. Early bail-out for optional cases: use
   `return 0` (not `exit`) to stop the mod while still counting it as a
   success.

### 4. Environment available to patch.sh

All of these are set before the first mod runs:

| Variable | Meaning |
|---|---|
| `ROOT_DIR` | repo root |
| `WORK_DIR`, `OUTPUT` | `workspace/`, `workspace/output` |
| `PORT`, `PORT_ROOTFS`, `PORT_METADATA` | the port tree being built |
| `SOURCE_UNPACKED`, `SOURCE_ROOTFS`, `SOURCE_METADATA` | donor firmware (e.g. s23fe) |
| `TARGET_UNPACKED`, `TARGET_ROOTFS`, `TARGET_METADATA` | target stock firmware (e.g. a55) |
| `MODEL`, `REGION`, `VERSION` | the **target** device identity |
| `ROM_NAME`, `ROM_VERSION` | from `config.sh` |
| `info`, `warn`, `die`, `merge_metadata` | helper functions from `scripts/lib.sh` |

Conventions:

- Use `sudo` for anything that writes inside `PORT_ROOTFS` (the tree is
  root-owned). Metadata files under `PORT_METADATA` are user-owned — plain
  redirection is fine there.
- Guard every input (`[ -f … ] && [ -d … ]`) and make missing optional files
  a `warn + return 0`, not a crash.
- End with a status message. The mod is "done" when its last command exits 0.

### 5. The unified_config format

One line per file, pipe-delimited, relative to the partition root:

```
<partition-relative path>|uid|gid|mode|selinux context|capabilities(hex or 0x0)
```

Example (from `mods/a55/camera-lib-fix`):

```
/lib64/libAImode_wrapper.camera.samsung.so|0|0|644|u:object_r:same_process_hal_file:s0|0x0
```

- The partition is named by the file suffix: `unified_config-vendor` feeds
  the `vendor` image, `unified_config-system` the `system` image, etc.
- Paths are relative to the partition (the vendor entry above means
  `<vendor>/lib64/…`).
- `repack_img.sh` applies these to the rootfs *before* running `mkfs.erofs`,
  so every file you add needs an entry here, or it gets default labels.
- Lines for paths that don't exist on disk are skipped by the repack step —
  deleting files does **not** require pruning metadata.
- `merge_metadata <port_cfg> <override_cfg> [more…]` is available inside
  patch.sh for more involved merges (e.g. `selinux-mappings`, `vintf`).

### 6. Example mod (deleting a directory + pruning metadata)

See `mods/chrome-64` for the minimal pattern: remove the donor's 32-bit
Chrome, prune its metadata lines, one `warn` path for when the dir is absent.

### 7. Test a mod without a full build

```bash
bash -n mods/<name>/patch.sh          # syntax check
```

A full re-run of `./build.sh` reuses the already-downloaded/unpacked
firmware in `workspace/firmwares/` (the download and unpack steps no-op if
the data is already there), so the mod phase is the part you are actually
testing. The build ends by writing `workspace/output/build-info.txt` — a
manifest with date, ROM version, target/base model+CSC+version, git commit,
dirty flag, and the exact mod list, so any output image can be traced back
to its inputs.

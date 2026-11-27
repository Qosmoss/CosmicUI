# How to Port with CosmicUI

CosmicUI is an engine built to make porting clean, modular, and unified—every device, every base, all in one place. Instead of hacking raw ROM files directly, you define your target device, pick a base firmware, stack your mods, and let the engine build it.

For writing and understanding individual mods, see **[Writing Mods](modding.md)**.

---

### Dependencies

All steps run as your user, but many use `sudo`. Install:

| Tool | Used for |
|---|---|
| `samloader` | firmware download (`download_fw.sh`) |
| `unzip`, `tar`, `lz4` | firmware unpacking |
| `simg2img`, `lpunpack` | super.img → partition images |
| `fsck.erofs`, `mkfs.erofs` (erofs-utils) | rootfs extract / repack |
| `getfattr`, `setfattr`, `xxd`, `awk`, `tac` | SELinux / capability round-trip |
| `curl` | mods that fetch content (adblock-hosts) |

`./build.sh` checks for all of these up front and fails fast if one is missing.

---

### 1. Set Up Your Target Folder

Head into the `target/` directory and create a folder named after the device you are porting to (for example, `a55` for the Galaxy A55). Keep it lowercase and clean so scripts and paths stay predictable.

### 2. Create `config.sh` Inside the Target Folder

Inside `target/<your_device>/`, create a file named `config.sh`. This tells CosmicUI the exact identity of the target device you are building for.

### 3. Define Target Device Variables

Add your target's `MODEL`, `REGION` (CSC), and optional specific `VERSION` string in `config.sh`:

```bash
MODEL="SM-A556B"
REGION="EUX"
VERSION="A556BXXSABYI1/A556BOXMABYI1/A556BXXSABYI1/A556BXXSABYI1"

```

*(Tip: Leaving `VERSION` empty makes script to pull latest version.)*

### 4. Choose Your Base Firmware

Decide which base ROM or donor firmware you want to use-for example, using `s23fe` as the base for an `a55` port. Pick a base that matches your phone most.

### 5. Create the Base Config File

In your target device folder (`target/<your_device>/`), create a new file named after the base you chose (for example, `s23fe.sh`).

### 6. Define Base Firmware Variables

Inside that base file, specify the `MODEL`, `REGION`, and `VERSION` for the base firmware you are pulling from:

```bash
MODEL="SM-S711B"
REGION="EUX"
VERSION="S711BXXU..."

```

### 7. Declare Your `MODS` List

In the **base config** you created in step 5 (`target/<device>/<base>.sh`), define the `MODS` array/list in the exact order you want CosmicUI to apply them. Ordering matters so later mods don't get overwritten.

```bash
MODS=("vendor-replacement" "selinux-mappings" "vbmeta-patch" "vintf" "vndk"
      "camera-fix" "a55/camera-lib-fix" "product-overlays" "a55/unify-vendor"
      "chrome-64" "32bit-to-64bit" "rom-branding" "floating-features" "adblock-hosts")
```

(See **[Writing Mods](modding.md)** for how each mod is applied and how to add your own.)

### 8. Run the Build

From the CosmicUI root directory, kick off the build using your target and base names:

```bash
./build.sh <target> <base>

```

*(Example: `./build.sh a55 s23fe`)*

The build downloads + unpacks each firmware only if it isn't already in
`workspace/firmwares/`, so re-running after a mod tweak is fast. Rebuilt
partition images land in `workspace/output/super/`, loose images in
`workspace/output/`. A build manifest is written to
`workspace/output/build-info.txt` (see step 10).

### 9. Hunt Bugs & Fix Them Through Mods

Flash or test the resulting build on your device. When something breaks—camera modes, fingerprint/biometrics, AOD, audio, permissions, or boot issues—don't patch one-offs into messy leftovers. Write or update a clean **mod** (see [Writing Mods](modding.md)) so your fixes stay reusable, reproducible, and easy to maintain across rebuilds.

### 10. Done

Once the build boots cleanly, passes your daily checks, and your fixes live properly in mods—you've got a repeatable CosmicUI port ready to rebuild whenever a new base or update drops.

Every build records its inputs in `workspace/output/build-info.txt`:
ROM name/version, target and base model/CSC/version, the git commit and
whether the tree was dirty, and the exact ordered `MODS` list. Keep that file
next to the flashed image so you can always trace a result back to the exact
firmware + mods that produced it.

# How to Port with CosmicUI

CosmicUI is an engine built to make porting clean, modular, and unified—every device, every base, all in one place. Instead of hacking raw ROM files directly, you define your target device, pick a base firmware, stack your mods, and let the engine build it.

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

In your configuration, define the `MODS` array/list in the exact order you want CosmicUI to apply them. Ordering matters so later mods don't get overwritten.

### 8. Run the Build

From the CosmicUI root directory, kick off the build using your target and base names:

```bash
./build.sh <target> <base>

```

*(Example: `./build.sh a55 s23fe`)*

### 9. Hunt Bugs & Fix Them Through Mods

Flash or test the resulting build on your device. When something breaks—camera modes, fingerprint/biometrics, AOD, audio, permissions, or boot issues—don't patch one-offs into messy leftovers. Write or update a clean **mod** in CosmicUI so your fixes stay reusable, reproducible, and easy to maintain across rebuilds.

### 10. Done

Once the build boots cleanly, passes your daily checks, and your fixes live properly in mods—you've got a repeatable CosmicUI port ready to rebuild whenever a new base or update drops.

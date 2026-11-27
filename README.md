<div align="center">

# CosmicUI
### *Making old devices feel new again.*

An automated, modular ROM build engine designed to bring newer firmware experiences to supported devices—cleanly, reproducibly, and all in one place.

</div>

---

### Overview
Porting custom firmware usually means maintaining messy, fragmented trees for every single device and redoing the same manual work every time an update drops. **CosmicUI** replaces that workflow with a single automated pipeline that downloads, unpacks, adapts, mods, and repacks firmware builds from start to finish.

Instead of hardcoding changes into raw system files, CosmicUI keeps **device targets**, **base firmwares**, and **mods** completely separate—allowing you to mix, match, and maintain ports with minimal friction.

---

### Core Philosophy
* **One Engine, Many Devices:** A unified build system capable of pairing different base firmwares across multiple target devices without duplicating work.
* **Mod-Driven Architecture:** Hardware fixes, feature unlocks, and system patches live as isolated, reusable modules rather than one-off hacks.
* **Repeatable Builds:** Define your target, pick a base, declare your mods, and rebuild cleanly whenever a new security patch or base update arrives.
* **End-to-End Automation:** From fetching raw firmware packages to repacking the final flashable output, the heavy lifting happens automatically.

---

### Documentation
* **[How to Port](docs/porting.md)** — Configuring a target device, selecting a base firmware, and building out your `MODS` list (includes the dependencies table).
* **[Writing Mods](docs/modding.md)** — The mod contract: layout, execution order, the `unified_config-*` format, and how to add your own fix.

---

### Roadmap
- [ ] Expand the mod library with cleaner, more versatile patches and feature unlocks
- [ ] Broaden compatibility across more target devices and base firmwares
- [ ] Introduce automated Smali patching support

---

### Contributing
Contributions are always welcome. If you've fixed a device-specific bug or added support for a new target, package it cleanly as a modular fix or target config and open a pull request so others can use it too.

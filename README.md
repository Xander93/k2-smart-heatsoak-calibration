# K2 Smart Heatsoak Calibration

Fixes inconsistent first layers on the **Creality K2 Plus**. Stock behavior calibrates on a cold machine, then heats — but the bed and frame expand while heating, so you print on an outdated calibration. This mod reverses the order: **heat → soak → calibrate → print.**

> This mod assumes you're comfortable with root access and editing Klipper configs. If that's not you, this mod isn't for you (yet).

**What it does:**
- Parallel heating with bed assist (bed boosts to 105 °C near the nozzle → chamber reaches target much faster)
- Filament-driven heatsoak with on-screen countdown (45 min ASA/ABS, 15 min PLA/PETG)
- **Warm-restart detection (triple-checked):** previous print ended < 30 min ago *and* chamber still near target *and* bed still residually warm → soak auto-shortens to 15 min
- Fresh nozzle clean + bed mesh **after** the soak, on the hot, stable machine
- All logic lives in one macro on the printer; the slicer only passes your filament profile values

**Files:**
| File | Goes where |
|---|---|
| `smart_heatsoak_calibrate.cfg` | on the printer (via Fluidd) |
| `machine_start_gcode.gcode` | CrealityPrint → Machine start G-code |
| `fallback/creality-stock-original.gcode` | restore factory behavior (uninstall) |

---

## Install

### A. Prepare (one-time checks)

1. CrealityPrint → printer settings → **Print Calibration** toggle **OFF**.
2. Check `printer.cfg` contains `forced_leveling: false`.
3. Every ASA/ABS filament profile: **chamber temperature 45 or higher**. Below 41 the printer never turns the heater on (it only runs a fan), so lower values silently do nothing.
4. Backup your current Machine start G-code to a text file.

### B. Macro on the printer

5. Fluidd → **Configuration** → create new file: `smart_heatsoak_calibrate.cfg`
6. Paste the contents of [`smart_heatsoak_calibrate.cfg`](smart_heatsoak_calibrate.cfg) → save.
7. Open `printer.cfg` → add near the other includes: `[include smart_heatsoak_calibrate.cfg]` → save.
8. Click **Firmware restart**.
9. Console smoke test, both macros: first `SMART_HEATSOAK_MARK_END` (no error = timestamp works), then `SMART_HEATSOAK_CALIBRATE BED_TEMP=60 CHAMBER_TEMP=0 EXTRUDER_TEMP=200` — countdown appears = macro works. Cancel it.

### C. Slicer

10. CrealityPrint → printer settings → **Machine start G-code** → select all → paste the contents of [`machine_start_gcode.gcode`](machine_start_gcode.gcode). Then open **Machine end G-code** and add this as the **first line** (keep the rest unchanged): `SMART_HEATSOAK_MARK_END` → save profile.
11. **Re-slice** your model (old sliced files still contain the old start code).
12. Print.

**Expected screen sequence:** `Kamer opwarmen...` → `Bed terug naar profieltemp` → `Heatsoak: nog 45 min` (counts down per 5 min) → `Kalibreren...` → print starts. On a warm restart, step 3 shows 15 min instead.

> **OrcaSlicer:** step 10 is identical — same field (printer settings → Machine G-code → Machine start G-code), same variables. This guide uses CrealityPrint naming.

## Why these soak times?

| Filament | Chamber | Soak | Reason |
|---|---|---|---|
| PLA / PETG (chamber = 0) | cooled to < 35 °C first | 15 min | Only the bed heats (60–80 °C); a light plate settles fast. Chamber heat is actively avoided — PLA softens near 55 °C. |
| ABS / ASA (chamber 45–60) | 55–60 °C | 45 min cold / 15 min warm restart | The whole frame, gantry and Z screws expand with the chamber. These heavy parts heat slowly; measurable Z drift typically stops after 30–45 min. |

These are deliberately conservative defaults, not magic numbers. Measure your own machine: once at temperature, run `PROBE_ACCURACY` every 10 minutes — the moment the Z value stops shifting is your minimum soak. Because this mod meshes *after* the soak, a somewhat shorter soak is far more forgiving than on stock (late drift is partly absorbed by the fresh mesh).

**Tuning:** all values (soak times, boost temp, warm-restart margin) are in the `_SMART_HEATSOAK_VARS` block at the top of the cfg. Change one number, firmware restart, done.

---

## FAQ

**Can I leave Print Calibration ON?** It works — our hot mesh overwrites the cold one — but you waste ~10 minutes, and the AI flow scan (run on a cold machine) may override your tuned profile flow with a guess made under the wrong conditions. Recommended: OFF.

**Bed shows 105 °C at the start?** That's the bed assist speeding up chamber heating. It returns to your profile temp *before* the soak clock starts. You never calibrate or print on the 105 shape.

**Printer calibrated instantly after a reboot, skipping everything?** That's the firmware's own self-check after restart (also after emergency stop) — not this mod. Its cold mesh is replaced by the fresh hot mesh after the soak.

**`Unknown command: SMART_HEATSOAK_CALIBRATE` after a firmware update?** The update wiped the macro/include. Redo install steps 5–8 (takes ~5 minutes). Need to print right now? Paste `fallback/creality-stock-original.gcode` temporarily.

**Cancel takes long?** During the soak: ~1 second (the countdown pauses per second). During chamber heating (M191): a normal cancel waits for the chamber target — use Fluidd's emergency stop for instant abort.

**45 min too long?** It's conservative on purpose. Measure your machine: once at temp, run `PROBE_ACCURACY` every 10 min; when Z stops shifting, that's your minimum soak. Then change one variable in the cfg.

**Cache the mesh to skip probing?** Don't. Bed shape follows current temperature; a cached hot mesh is wrong after any cool-down or plate removal. Probing costs ~2 min.

**Uninstall / back to stock?** Paste `fallback/creality-stock-original.gcode` into Machine start G-code, turn the Print Calibration toggle back ON, re-slice. Optionally remove the include line from `printer.cfg`.

**Multicolor/CFS?** Fully supported — the purge block stays in the slicer g-code, included.

**K2 Pro?** Same firmware family and chamber commands, should work identically — untested. Base **K2 is not supported** for ASA/ABS (no active chamber heater).

---

## Credits

Bed-assist concept and calibrate-after-stability principle inspired by [Jacob10383/k2-improvements](https://github.com/Jacob10383/k2-improvements) — reimplemented without invasive firmware mods, without the bed-stuck-at-105 issue, extended with filament-driven soak and warm-restart detection.

Tested on: Creality K2 Plus. Report your firmware + CrealityPrint version in issues.

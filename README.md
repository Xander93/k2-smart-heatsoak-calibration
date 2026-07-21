# K2 Smart Heatsoak Calibration

Fix inconsistent first layers on the Creality K2 Plus by calibrating **after** the machine is thermally stable — not before.

## The problem

The K2 Plus calibrates (bed mesh, Z reference) on a cold machine, then heats up. But the bed, frame and gantry expand as they heat: the bed changes shape, the Z reference drifts. By the time your ASA print actually starts, the machine no longer matches the calibration it is printing on. Result: inconsistent first layers, poor squish, parts detaching mid-print — the classic K2 complaints.

## The fix

Reverse the order. This mod:

1. **Heats everything in parallel** — chamber heater, bed and nozzle standby all start at once instead of sequentially.
2. **Bed assist** — while the chamber heats, the bed temporarily boosts to 105 °C and rises to Z5 (just under the nozzle) for maximum convection. The chamber reaches target noticeably faster. The bed then returns to your filament's bed temp *before* the soak clock starts, so the bed shape you soak, calibrate and print on is exactly the profile temperature. (Thermal expansion is elastic — the bed has no "memory" of the boost.)
3. **Filament-driven heatsoak** — 45 min for chamber-temp filaments (ASA/ABS), 15 min stabilisation for PLA/PETG, all driven by your filament profiles. A live countdown shows on the printer screen.
4. **Fresh calibration on the hot, stable machine** — nozzle clean + bed mesh happen *after* the soak, so the mesh describes the bed you actually print on. Every print, every time.
5. *(Macro version only)* **Warm-restart detection** — if the chamber is still near target when you start (back-to-back prints), the soak automatically shortens from 45 to 15 minutes.

No firmware mods are required for the basic version — it is pure slicer start g-code and survives every firmware update.

## Requirements

- Creality K2 Plus (K2 Pro should work identically — same firmware family and chamber commands; untested). The base K2 has **no** active chamber heater and is not supported for the ASA/ABS path.
- CrealityPrint (leading for this guide). **OrcaSlicer works identically** — CrealityPrint is Orca-based, the variables and the *Machine start G-code* field are the same.
- In CrealityPrint: **Print Calibration toggle OFF** (the mod replaces it with a better-timed calibration).
- `forced_leveling: false` in printer.cfg (usually already the case; check after firmware updates).
- Chamber temperature in your ASA/ABS filament profiles set to **45 °C or higher** — the firmware only actively heats above S40 (below that it only runs the fan).

## Option 1 — Slicer-only (recommended, works on stock firmware)

1. Open CrealityPrint → printer settings → **Machine start G-code**.
2. Copy the *top section* of your current start g-code somewhere safe (backup).
3. Replace everything **above** your `{if multicolor_method}` block with the contents of [`slicer-only/machine_start_gcode.gcode`](slicer-only/machine_start_gcode.gcode). Keep your multicolor/purge block below it, unchanged.
4. Save the printer profile, **re-slice** your model (old sliced files still contain the old start code!), print.

What you will see on screen, in order: `Heating chamber...` → `Bed back to profile temp` → `Heatsoak: 45 min left` counting down per 5 minutes → `Calibrating...` → print.

Cancelling during the soak takes effect within ~1 minute (the soak is split into 1-minute blocks). Cancelling during chamber heating waits until the chamber target is reached — use Fluidd's emergency stop if you need to abort instantly.

## Option 2 — Macro version (adds warm-restart detection)

Everything from Option 1, plus the printer decides by itself whether a full soak is needed: if the chamber is already within 8 °C of target at start (machine stayed warm between prints), it soaks 15 minutes instead of 45.

1. Open Fluidd → **Configuration** → create a new file `smart_heatsoak_calibrate.cfg`.
2. Paste the contents of [`macro/smart_heatsoak_calibrate.cfg`](macro/smart_heatsoak_calibrate.cfg), save.
3. In `printer.cfg`, add near the other includes: `[include smart_heatsoak_calibrate.cfg]`, save, **firmware restart**.
4. Test in the console: `SMART_HEATSOAK_CALIBRATE BED_TEMP=60 CHAMBER_TEMP=0 EXTRUDER_TEMP=200` — if you see the heatsoak countdown start, the macro is alive (cancel after a minute, this was just the smoke test).
5. Replace your Machine start G-code with [`macro/machine_start_gcode_thin.gcode`](macro/machine_start_gcode_thin.gcode) (a single `SMART_HEATSOAK_CALIBRATE` call + your multicolor block). Re-slice.

All tunables (soak times, boost temp, warm-restart margin) live in one `_SMART_HEATSOAK_VARS` block at the top of the cfg.

**Keep the Option 1 profile as a fallback.** If a firmware update ever wipes the macro, `SMART_HEATSOAK_CALIBRATE` returns *Unknown command* — slice with the Option 1 profile while you re-add the cfg.

## FAQ

**Why does my bed briefly show 105 °C?**
That is the bed assist during chamber heating. The target drops back to your profile temp before the soak starts; the actual temperature takes a few minutes to settle, which the 45-minute soak absorbs easily. You never calibrate or print on the 105 °C shape.

**The printer calibrated immediately after a restart, skipping everything.**
That was the firmware's own self-check after a reboot (including after an emergency stop) — not this mod. The cold mesh it makes is harmlessly replaced by the fresh hot mesh this mod probes after the soak.

**Can I cache the mesh and skip meshing next time?**
Not reliably. The bed shape follows its current temperature state; after any cool-down the cached hot mesh no longer matches reality, and removing the flex plate changes things too. Probing takes ~2 minutes on an hour-long start — it is the cheapest insurance in the whole procedure.

**Isn't 45 minutes long?**
It is deliberately conservative. The chamber air is fast; the frame and gantry are slow, and they determine when drift stops. You can measure your own machine's minimum: once at temp, run `PROBE_ACCURACY` every 10 minutes — the moment the Z value stops shifting is your true soak time. Because this mod meshes *after* the soak, a modestly shorter soak is more forgiving than on a stock setup.

**Does this work with the CFS / multicolor?**
Yes — the multicolor/purge block from Creality's default start g-code stays in the slicer, unchanged, below the mod.

**Orca users?**
Identical. Same field (printer settings → Machine G-code → Machine start G-code), same variables. CrealityPrint is used as the reference in this guide because it ships with the K2.

## Credits & background

Inspired in part by ideas from [Jacob10383/k2-improvements](https://github.com/Jacob10383/k2-improvements) (bed assist concept, calibrate-after-stability principle) — reimplemented without firmware mods and without the bed-stays-at-105 issue, and extended with filament-driven soak logic and warm-restart detection.

Tested on: Creality K2 Plus. Please report your firmware/CrealityPrint versions in issues so the compatibility list can grow.

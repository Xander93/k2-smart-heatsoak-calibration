# K2 Smart Heatsoak Calibration

Fixes inconsistent first layers on the Creality K2 Plus. Stock behavior calibrates on a cold machine, then heats — but the bed and frame expand while heating, so you print on an outdated calibration. This mod reverses the order: heat → soak → calibrate → print.

This mod assumes you're comfortable with root access and editing Klipper configs. If that's not you, this mod isn't for you (yet).

**What it does:**

- Parallel heating with bed assist (bed boosts to 105 °C near the nozzle → chamber reaches target much faster)
- Filament-driven heatsoak with on-screen countdown (45 min ASA/ABS, 15 min PLA/PETG)
- **Adaptive chamber cooling (PLA/PETG):** measures once per minute whether the chamber is still dropping. Stops at target, at a plateau (= ambient reached — e.g. a hot garage in summer), or at a hard cap. Can never hang indefinitely, unlike a bare `TEMPERATURE_WAIT`. The chamber fan runs at full speed during cooling.
- **Warm-restart detection (two independent signals):** a *soak stamp* written after every completed heatsoak (monotonic clock, survives print cancels), **or** the bed still residually warm (≥ 50 °C — physical proof of a recent print). Either one → soak auto-shortens: 45 → 15 min for ASA/ABS, 15 → 5 min for PLA/PETG. After a Klipper restart the stamp self-invalidates (clock resets) and only the temperature check applies. Fails safe in every direction.
- Fresh nozzle clean + bed mesh after the soak, on the hot, stable machine
- Nozzle standby (140 °C) is applied *after* the cooling phase, not before — no heater fighting the cooldown
- All logic lives in one macro on the printer; the slicer only passes your filament profile values

**Improved start G-code (bundled):**

- Purge line lengthened from Creality's 50 mm to 125 mm (X80→X205 on the front strip)
- Fully parametric: line height = `first layer height + 0.1`, extrusion amounts and speeds scale along — works correctly with 0.6+ nozzles and thick first layers, and stays byte-identical to the tuned values at 0.2 mm
- Nozzle wipe ends at first-layer height instead of Z0 — fixes the stock bug where the nozzle presses filament into the bed at the end of the purge line (the wipe can now never be more aggressive than the first layer itself, regardless of Z-offset)

**Files:**

| File | Goes where |
|---|---|
| `smart_heatsoak_calibrate.cfg` (v1.6) | on the printer (via Fluidd) |
| `machine_start_gcode_K2Plus_langere_purge.txt` (v1.3) | CrealityPrint → Machine start G-code |
| `fallback/creality-stock-original.gcode` | restore factory behavior (uninstall) |

## Install

### A. Prepare (one-time checks)

1. CrealityPrint → printer settings → **Print Calibration toggle OFF**.
2. Check `printer.cfg` contains `forced_leveling: false`.
3. Every ASA/ABS filament profile: chamber temperature **45 or higher**. Below 41 the printer never turns the heater on (it only runs a fan), so lower values silently do nothing.
4. Backup your current Machine start G-code to a text file.

### B. Macro on the printer

5. Fluidd → Configuration → create new file: `smart_heatsoak_calibrate.cfg`
6. Paste the contents of `smart_heatsoak_calibrate.cfg` → save.
7. Open `printer.cfg` → add near the other includes: `[include smart_heatsoak_calibrate.cfg]` → save.
8. Click **Firmware restart**.
9. Console smoke test: `SMART_HEATSOAK_CALIBRATE BED_TEMP=60 CHAMBER_TEMP=0 EXTRUDER_TEMP=200` — cooling/countdown messages appear = macro works. Cancel it.
10. Optional clock check: run `START_TIMER` in the console. `ns = <large number>` = the soak stamp works fully. `ns = 0` = your firmware lacks Creality's monotonic clock; everything degrades gracefully to the temperature-only check. Nothing breaks either way.

### C. Slicer

11. CrealityPrint → printer settings → Machine start G-code → select all → paste the contents of `machine_start_gcode_K2Plus_langere_purge.txt` → save profile.
    *(Unlike earlier versions of this mod, nothing needs to be added to the Machine **end** G-code — the soak stamp is written by the start macro itself, right after the soak completes. If you previously added `SMART_HEATSOAK_MARK_END` there, you may remove it; a harmless stub keeps it from erroring if you don't.)*
12. **Re-slice your model** (old sliced files still contain the old start code).
13. Print. Watch the first purge line once — it now starts further left (X80).

**Expected screen sequence (PLA, warm day):** `Kamer koelen (nu 38.3 C)` → `Koelen: 38.1 C` → `Kamer zakt niet meer - omgeving is ~38.1 C, doorgaan` → `Heatsoak: nog 15 min` → `Kalibreren...` → print starts.
**Expected sequence (ASA, cold start):** `Koude start - soak 45 min` → `Kamer opwarmen...` → `Bed terug naar profieltemp` → `Heatsoak: nog 45 min` (counts down per 5 min) → `Kalibreren...` → print. On a warm restart, the soak shows 15 (ASA) or 5 (PLA) minutes instead.

OrcaSlicer: step 11 is identical — same field (printer settings → Machine G-code → Machine start G-code), same variables. This guide uses CrealityPrint naming.

## Why these soak times?

| Filament | Chamber | Soak | Reason |
|---|---|---|---|
| PLA / PETG (chamber = 0) | cooled toward < 35 °C first (bounded, adaptive) | 15 min cold / 5 min warm restart | Only the bed heats (50–80 °C); a light plate settles fast. Chamber heat is actively avoided — PLA softens near 55 °C. If ambient is above 35 °C, cooling is physically impossible; the plateau detection recognizes this within ~1 minute and proceeds (PLA prints fine at a 38 °C chamber). |
| ABS / ASA (chamber 45–60) | 55–60 °C | 45 min cold / 15 min warm restart | The whole frame, gantry and Z screws expand with the chamber. These heavy parts heat slowly; measurable Z drift typically stops after 30–45 min. |

These are deliberately conservative defaults, not magic numbers. Measure your own machine: once at temperature, run `PROBE_ACCURACY` every 10 minutes — the moment the Z value stops shifting is your minimum soak. Because this mod meshes after the soak, a somewhat shorter soak is far more forgiving than on stock (late drift is partly absorbed by the fresh mesh).

**Tuning:** all values (soak times, boost temp, warm-restart thresholds, cooling cap `koel_max`, plateau sensitivity `koel_delta`, stamp validity window `stempel_venster`) are in the `_SMART_HEATSOAK_VARS` block at the top of the cfg. Change one number, firmware restart, done.

## FAQ

**Can I leave Print Calibration ON?** It works — our hot mesh overwrites the cold one — but you waste ~10 minutes, and the AI flow scan (run on a cold machine) may override your tuned profile flow with a guess made under the wrong conditions. Recommended: OFF.

**Bed shows 105 °C at the start?** That's the bed assist speeding up chamber heating. It returns to your profile temp before the soak clock starts. You never calibrate or print on the 105 shape.

**"Kamer zakt niet meer - omgeving is ~38 C"?** Working as intended. Your room is warmer than the 35 °C target, so cooling further is physically impossible; the macro detects the plateau within a minute and proceeds instead of waiting forever (which is exactly what the naive `TEMPERATURE_WAIT` approach did).

**I cancelled a print right after the heatsoak — do I lose 45 minutes on the next start?** No. The soak stamp is written the moment the soak completes, independent of how the print ends. A restart within the stamp window (default 45 min, same Klipper session) gets the short soak even if the bed has already cooled below 50 °C. Cancelling *during* the soak deliberately does not stamp — a half-soaked machine isn't done.

**Printer calibrated instantly after a reboot, skipping everything?** That's the firmware's own self-check after restart (also after emergency stop) — not this mod. Its cold mesh is replaced by the fresh hot mesh after the soak.

**`Unknown command: SMART_HEATSOAK_CALIBRATE` after a firmware update?** The update wiped the macro/include. Redo install steps 5–8 (takes ~5 minutes). Need to print right now? Paste `fallback/creality-stock-original.gcode` temporarily. Note this failure mode is safe by design: the print aborts immediately instead of silently starting cold.

**Cancel takes long?** During the soak and the cooling phase: ~1 second (both pause per second). During chamber heating (`M191`): a normal cancel waits for the chamber target — use Fluidd's emergency stop for instant abort. `M191` is firmware and has no timeout; don't set unreachable chamber temps in filament profiles.

**45 min too long?** It's conservative on purpose. Measure your machine (see above), then change one variable in the cfg.

**Cache the mesh to skip probing?** Don't. Bed shape follows current temperature; a cached hot mesh is wrong after any cool-down or plate removal. Probing costs ~2 min.

**Uninstall / back to stock?** Paste `fallback/creality-stock-original.gcode` into Machine start G-code, turn the Print Calibration toggle back ON, re-slice. Optionally remove the include line from `printer.cfg` and delete `~/heatsoak_state.cfg`.

**Multicolor/CFS?** Fully supported — the purge block stays in the slicer g-code, included and improved (see start G-code notes above).

**K2 Pro?** Same firmware family and chamber commands, should work identically — untested. Base K2 is not supported for ASA/ABS (no active chamber heater).

## Credits

Bed-assist concept and calibrate-after-stability principle inspired by [Jacob10383/k2-improvements](https://github.com/Jacob10383/k2-improvements) — reimplemented without invasive firmware mods, without the bed-stuck-at-105 issue, extended with filament-driven soak, adaptive plateau-detecting chamber cooling, dual-signal warm-restart detection (soak stamp + residual bed heat) and a parametric, longer purge line with a safe wipe.

Tested on: Creality K2 Plus, CrealityPrint 7.2, CFS. Report your firmware + CrealityPrint version in issues.

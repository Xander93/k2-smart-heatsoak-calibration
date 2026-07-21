; ============================================================
; K2 Smart Heatsoak Calibration - SLICER-ONLY VERSION (v6)
; Paste this as your Machine Start G-code in CrealityPrint.
; No firmware modification, no root access, survives updates.
;
; Requirements:
;  - "Print Calibration" toggle OFF in CrealityPrint
;  - forced_leveling: false in printer.cfg
;  - Chamber temp in ASA/ABS filament profiles set to 45+
;    (firmware only actively heats above S40)
; ============================================================

; --- Step 0: clean start ---
M140 S0            ; reset bed target
M104 S0            ; reset nozzle target
M104 S140          ; nozzle standby 140C: preheats along, minimal ooze

; --- Step 1: force cool chamber for filaments WITHOUT chamber temp ---
{if chamber_temperature[initial_no_support_extruder] == 0}
M141 S0            ; chamber heater off
TEMPERATURE_WAIT SENSOR="temperature_sensor chamber_temp" MAXIMUM=35   ; wait until chamber < 35C
{endif}

; --- Step 2+3a: filament WITH chamber temp (ASA/ABS) ---
{if chamber_temperature[initial_no_support_extruder] > 0}
M141 S{chamber_temperature[initial_no_support_extruder]}   ; chamber heater ON immediately (parallel)
M140 S105          ; bed assist: temporary boost to 105C
G28                ; home
G1 Z5 F600         ; bed just under the nozzle = maximum convection
M117 Heating chamber...
M191 S{chamber_temperature[initial_no_support_extruder]}   ; wait for chamber temp
M117 Bed back to profile temp
M140 S[bed_temperature_initial_layer_single]   ; bed back to filament temp
M190 S[bed_temperature_initial_layer_single]   ; wait until it is there
; soak clock starts now: bed is at exact print temp
M117 Heatsoak: 45 min left
G4 P60000
G4 P60000
G4 P60000
G4 P60000
G4 P60000
M117 Heatsoak: 40 min left
G4 P60000
G4 P60000
G4 P60000
G4 P60000
G4 P60000
M117 Heatsoak: 35 min left
G4 P60000
G4 P60000
G4 P60000
G4 P60000
G4 P60000
M117 Heatsoak: 30 min left
G4 P60000
G4 P60000
G4 P60000
G4 P60000
G4 P60000
M117 Heatsoak: 25 min left
G4 P60000
G4 P60000
G4 P60000
G4 P60000
G4 P60000
M117 Heatsoak: 20 min left
G4 P60000
G4 P60000
G4 P60000
G4 P60000
G4 P60000
M117 Heatsoak: 15 min left
G4 P60000
G4 P60000
G4 P60000
G4 P60000
G4 P60000
M117 Heatsoak: 10 min left
G4 P60000
G4 P60000
G4 P60000
G4 P60000
G4 P60000
M117 Heatsoak: 5 min left
G4 P60000
G4 P60000
G4 P60000
G4 P60000
G4 P60000
M117 Heatsoak done
{endif}

; --- Step 2+3b: filament WITHOUT chamber temp (PLA etc.) ---
{if chamber_temperature[initial_no_support_extruder] == 0}
M140 S[bed_temperature_initial_layer_single]
M190 S[bed_temperature_initial_layer_single]
M117 Heatsoak: 15 min left
G4 P60000
G4 P60000
G4 P60000
G4 P60000
G4 P60000
M117 Heatsoak: 10 min left
G4 P60000
G4 P60000
G4 P60000
G4 P60000
G4 P60000
M117 Heatsoak: 5 min left
G4 P60000
G4 P60000
G4 P60000
G4 P60000
G4 P60000
M117 Heatsoak done
{endif}

; --- Step 3c: calibrate NOW - machine is thermally stable ---
; (Creality's own macro homes, cleans the nozzle, probes a fresh mesh)
M117 Calibrating...
BED_MESH_CALIBRATE_START_PRINT BED_TEMP=[bed_temperature_initial_layer_single]

; --- Step 4: normal Creality start routine ---
START_PRINT EXTRUDER_TEMP=[nozzle_temperature_initial_layer] BED_TEMP=[bed_temperature_initial_layer_single]

; ============================================================
; IMPORTANT: keep your existing multicolor/purge block BELOW this
; line, unchanged (the {if multicolor_method} ... {endif} section
; from your original CrealityPrint machine start g-code).
; ============================================================

; ============================================================
; K2 Smart Heatsoak Calibration - SLICER-ONLY VERSION
; COMPLETE machine start g-code: replace everything in the
; Machine Start G-code field with this file. Nothing else needed.
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

{if multicolor_method}

M83 
M8200 P S[initial_no_support_extruder]
M220 S100
G0 Y200 F12000
G0 X10
SET_VELOCITY_LIMIT ACCEL=5000 ACCEL_TO_DECEL=25000
G0 F30000

M8200 C S0
SET_VELOCITY_LIMIT ACCEL=5000 ACCEL_TO_DECEL=5000
G0 Y345 F18000
G0 X139
G0 Y378
G0 X133
M8200 R
M104 S[nozzle_temperature_range_high[initial_no_support_extruder]]
M8200 L I[initial_no_support_extruder]
M106 S0
M106 P2 S0
T[initial_no_support_extruder]

; FLUSH_START
M106 S30
G1 F60
M400
G1 E{90 * 0.18} F{filament_max_volumetric_speed[initial_no_support_extruder]/2.4053*60}
G1 E{90 * 0.02} F60
G1 E{90 * 0.18} F{filament_max_volumetric_speed[initial_no_support_extruder]/2.4053*60}
G1 E{90 * 0.02} F60
G1 E{90 * 0.18} F{filament_max_volumetric_speed[initial_no_support_extruder]/2.4053*60}
G1 E{90 * 0.02} F60
G1 E{90 * 0.18} F{filament_max_volumetric_speed[initial_no_support_extruder]/2.4053*60}
G1 E{90 * 0.02} F60
G1 E{90 * 0.18} F{filament_max_volumetric_speed[initial_no_support_extruder]/2.4053*60}
G1 E{90 * 0.02} F60

M400
M106 S255
G4 P5000
M106 S30
G1 E-[retract_length_toolchange[initial_no_support_extruder]] F1800
; FLUSH_END

; WIPE
SET_VELOCITY_LIMIT ACCEL=5000 ACCEL_TO_DECEL=5000
G0 X160 F12000
G0 X135

G0 X160 Y374 F12000
G2 I4 J0 P1 F10000
G0 X170 Y374 F12000
G3 I-4 J0 P1 F10000

G0 X160 Y378 F12000
G0 X133 Y378 F12000
G0 X160 Y378 F12000
G0 X133 Y378 F12000
G0 X160 Y378 F12000
G0 X133 Y378 F12000

; FLUSH_START
G1 F60
M400
G1 E{90 * 0.18} F{filament_max_volumetric_speed[initial_no_support_extruder]/2.4053*60}
G1 E{90 * 0.02} F60
G1 E{90 * 0.18} F{filament_max_volumetric_speed[initial_no_support_extruder]/2.4053*60}
G1 E{90 * 0.02} F60
G1 E{90 * 0.18} F{filament_max_volumetric_speed[initial_no_support_extruder]/2.4053*60}
G1 E{90 * 0.02} F60
G1 E{90 * 0.18} F{filament_max_volumetric_speed[initial_no_support_extruder]/2.4053*60}
G1 E{90 * 0.02} F60
G1 E{90 * 0.18} F{filament_max_volumetric_speed[initial_no_support_extruder]/2.4053*60}
G1 E{90 * 0.02} F60

M400
M106 S255
G4 P5000
M106 S30
G1 E-[retract_length_toolchange[initial_no_support_extruder]] F1800
; FLUSH_END

; WIPE
SET_VELOCITY_LIMIT ACCEL=5000 ACCEL_TO_DECEL=5000
G0 X160 F12000
G0 X135

G0 X160 Y374 F12000
G2 I4 J0 P1 F10000
G0 X170 Y374 F12000
G3 I-4 J0 P1 F10000

G0 X160 Y378 F12000
G0 X133 Y378 F12000
G0 X160 Y378 F12000
G0 X133 Y378 F12000
G0 X160 Y378 F12000
G0 X133 Y378 F12000

; FLUSH_START
G1 F60
M400
M104 S[nozzle_temperature_initial_layer]
G1 E{90 * 0.18} F{filament_max_volumetric_speed[initial_no_support_extruder]/2.4053*60}
G1 E{90 * 0.02} F60
G1 E{90 * 0.18} F{filament_max_volumetric_speed[initial_no_support_extruder]/2.4053*60}
G1 E{90 * 0.02} F60
G1 E{90 * 0.18} F{filament_max_volumetric_speed[initial_no_support_extruder]/2.4053*60}
G1 E{90 * 0.02} F60
G1 E{90 * 0.18} F{filament_max_volumetric_speed[initial_no_support_extruder]/2.4053*60}
G1 E{90 * 0.02} F60
G1 E{90 * 0.18} F{filament_max_volumetric_speed[initial_no_support_extruder]/2.4053*60}
G1 E{90 * 0.02} F60

M400
M106 S255
G4 P5000
M106 S0
G1 E-[retract_length_toolchange[initial_no_support_extruder]] F1800
; FLUSH_END

; WIPE
SET_VELOCITY_LIMIT ACCEL=5000 ACCEL_TO_DECEL=5000
G0 X160 F12000
G0 X135

G0 X160 Y374 F12000
G2 I4 J0 P1 F10000
G0 X170 Y374 F12000
G3 I-4 J0 P1 F10000

G0 X160 Y378 F12000
G0 X133 Y378 F12000
G0 X160 Y378 F12000
G0 X133 Y378 F12000
G0 X160 Y378 F12000
G0 X133 Y378 F12000

M8200 O
M204 S2000
G1 Z3 F600
G1 X160 F12000
G1 X150 Y-1 F30000
G1 E[retraction_length]  F300
G1 Z0.3 F1200
G1 X175 E9  F{outer_wall_volumetric_speed/(24/20)  * 60}
G1 X180 E.3742  F{outer_wall_volumetric_speed/(0.3*0.5)/4*60}
G1 X185 E.3742  F{outer_wall_volumetric_speed/(0.3*0.5)*60}
G1 X190 E.3742  F{outer_wall_volumetric_speed/(0.3*0.5)/4*60}
G1 X195 E.3742  F{outer_wall_volumetric_speed/(0.3*0.5)*60}
G1 X200 E.3742  F{outer_wall_volumetric_speed/(0.3*0.5)/4*60}
G91
G1 X1 Z-0.300
G1 X4
G92 E0

{else}
T[initial_no_support_extruder]
M104 S[nozzle_temperature_initial_layer]
M204 S2000
G1 Z3 F600
M83
G1 X150 Y-1 F30000
G1 E[retraction_length]  F300
G1 Z0.3 F1200
G1 X175 E9  F{outer_wall_volumetric_speed/(24/20)  * 60}
G1 X180 E.3742  F{outer_wall_volumetric_speed/(0.3*0.5)/4*60}
G1 X185 E.3742  F{outer_wall_volumetric_speed/(0.3*0.5)*60}
G1 X190 E.3742  F{outer_wall_volumetric_speed/(0.3*0.5)/4*60}
G1 X195 E.3742  F{outer_wall_volumetric_speed/(0.3*0.5)*60}
G1 X200 E.3742  F{outer_wall_volumetric_speed/(0.3*0.5)/4*60}
G91
G1 X1 Z-0.300
G1 X4
G92 E0
G1 Z1 F600
{endif}

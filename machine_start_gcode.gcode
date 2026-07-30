; ============================================================
; MACHINE START G-CODE v1.1 - K2 Plus (dunne versie)
; Alle startlogica zit nu in de SMART_HEATSOAK_CALIBRATE-macro op de printer
; (smart_heatsoak_calibrate.cfg). Deze slicer-gcode geeft alleen de
; filamentwaardes door en doet daarna het multicolor/purge-blok.
; Vereist: smart_heatsoak_calibrate.cfg geinstalleerd + include in printer.cfg
; Print Calibration-schuif UIT, forced_leveling: false.
;
; v1.3 - purge-geometrie volledig parametrisch: lijnhoogte is nu
;        {initial_layer_print_height + 0.1}, de E-hoeveelheid en
;        snelheden schalen mee, en de afveegdaling is daardoor
;        altijd exact -0.1 (eindigt op eerste-laaghoogte).
;        Werkt daarmee ook correct met 0.6+ nozzles / dikke lagen.
; v1.2 - afveegdiepte niet meer hardcoded: eindigt nu op de eerste-
;        laaghoogte via {initial_layer_print_height - 0.3}. Vegen is
;        daarmee per definitie nooit lager/gevaarlijker dan de eerste
;        laag zelf, wat de Z-offset van de printer ook is.
; v1.1 - purge lijn verlengd van 50 mm (X150-X200) naar 125 mm (X80-X205)
;        rekenregel: 0.07484 mm filament per mm lijn
;        segmenten van 10 mm  ->  E{(initial_layer_print_height + 0.1) * 2.4947}
; ============================================================

SMART_HEATSOAK_CALIBRATE EXTRUDER_TEMP=[nozzle_temperature_initial_layer] BED_TEMP=[bed_temperature_initial_layer_single] CHAMBER_TEMP={chamber_temperature[initial_no_support_extruder]}

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
G1 X80 Y-1 F30000
G1 E[retraction_length]  F300
G1 Z{initial_layer_print_height + 0.1} F1200
G1 X105 E9  F{outer_wall_volumetric_speed/(24/20)  * 60}
G1 X115 E{(initial_layer_print_height + 0.1) * 2.4947}  F{outer_wall_volumetric_speed/((initial_layer_print_height + 0.1)*0.6)/4*60}
G1 X125 E{(initial_layer_print_height + 0.1) * 2.4947}  F{outer_wall_volumetric_speed/((initial_layer_print_height + 0.1)*0.6)*60}
G1 X135 E{(initial_layer_print_height + 0.1) * 2.4947}  F{outer_wall_volumetric_speed/((initial_layer_print_height + 0.1)*0.6)/4*60}
G1 X145 E{(initial_layer_print_height + 0.1) * 2.4947}  F{outer_wall_volumetric_speed/((initial_layer_print_height + 0.1)*0.6)*60}
G1 X155 E{(initial_layer_print_height + 0.1) * 2.4947}  F{outer_wall_volumetric_speed/((initial_layer_print_height + 0.1)*0.6)/4*60}
G1 X165 E{(initial_layer_print_height + 0.1) * 2.4947}  F{outer_wall_volumetric_speed/((initial_layer_print_height + 0.1)*0.6)*60}
G1 X175 E{(initial_layer_print_height + 0.1) * 2.4947}  F{outer_wall_volumetric_speed/((initial_layer_print_height + 0.1)*0.6)/4*60}
G1 X185 E{(initial_layer_print_height + 0.1) * 2.4947}  F{outer_wall_volumetric_speed/((initial_layer_print_height + 0.1)*0.6)*60}
G1 X195 E{(initial_layer_print_height + 0.1) * 2.4947}  F{outer_wall_volumetric_speed/((initial_layer_print_height + 0.1)*0.6)/4*60}
G1 X205 E{(initial_layer_print_height + 0.1) * 2.4947}  F{outer_wall_volumetric_speed/((initial_layer_print_height + 0.1)*0.6)*60}
G91
G1 X1 Z-0.1 F1200
G1 X4
G1 Z1 F600
G92 E0

{else}
T[initial_no_support_extruder]
M104 S[nozzle_temperature_initial_layer]
M204 S2000
G1 Z3 F600
M83
G1 X80 Y-1 F30000
G1 E[retraction_length]  F300
G1 Z{initial_layer_print_height + 0.1} F1200
G1 X105 E9  F{outer_wall_volumetric_speed/(24/20)  * 60}
G1 X115 E{(initial_layer_print_height + 0.1) * 2.4947}  F{outer_wall_volumetric_speed/((initial_layer_print_height + 0.1)*0.6)/4*60}
G1 X125 E{(initial_layer_print_height + 0.1) * 2.4947}  F{outer_wall_volumetric_speed/((initial_layer_print_height + 0.1)*0.6)*60}
G1 X135 E{(initial_layer_print_height + 0.1) * 2.4947}  F{outer_wall_volumetric_speed/((initial_layer_print_height + 0.1)*0.6)/4*60}
G1 X145 E{(initial_layer_print_height + 0.1) * 2.4947}  F{outer_wall_volumetric_speed/((initial_layer_print_height + 0.1)*0.6)*60}
G1 X155 E{(initial_layer_print_height + 0.1) * 2.4947}  F{outer_wall_volumetric_speed/((initial_layer_print_height + 0.1)*0.6)/4*60}
G1 X165 E{(initial_layer_print_height + 0.1) * 2.4947}  F{outer_wall_volumetric_speed/((initial_layer_print_height + 0.1)*0.6)*60}
G1 X175 E{(initial_layer_print_height + 0.1) * 2.4947}  F{outer_wall_volumetric_speed/((initial_layer_print_height + 0.1)*0.6)/4*60}
G1 X185 E{(initial_layer_print_height + 0.1) * 2.4947}  F{outer_wall_volumetric_speed/((initial_layer_print_height + 0.1)*0.6)*60}
G1 X195 E{(initial_layer_print_height + 0.1) * 2.4947}  F{outer_wall_volumetric_speed/((initial_layer_print_height + 0.1)*0.6)/4*60}
G1 X205 E{(initial_layer_print_height + 0.1) * 2.4947}  F{outer_wall_volumetric_speed/((initial_layer_print_height + 0.1)*0.6)*60}
G91
G1 X1 Z-0.1 F1200
G1 X4
G92 E0
G1 Z1 F600
{endif}

arch snes.cpu

include "functions/bass.asm"
include "var/global.asm"
include "functions/hack.asm"
include "data/data.asm"
include "cycle/main_ext.asm"
include "cycle/main.asm"

//===============================================================================
// internal header
//===============================================================================

seek($C0FFB0)

// game code (C3F6  ) 
db $43, $33, $46, $36, $20, $20

// padding?
db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00

// game title (FINAL FANTASY VI     )
db $46, $49, $4E, $41, $4C, $20, $46, $41, $4E, $54, $41, $53, $59, $20, $56, $49, $20, $20, $20, $20, $20

db $31         // ROM makeup (HiROM / FastROM)           

db $02         // ROM type (ROM / RAM)

db $0C         // ROM size (32 Mbits)

db $03         // SRAM size (64 Kbit)

db $01         // Country code (USA)

db $33         // License code (Square)

db $00         // Game version (1.0)
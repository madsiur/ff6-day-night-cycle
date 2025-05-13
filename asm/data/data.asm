//===============================================================================
// Data generated with data/data.ods
// Location of this data defined by data_bank in var/global.asm
//===============================================================================

seek(data_start)

//===============================================================================
// Maps tint enabled
// One bit per map, 1 for tint enabled, 0 for disabled
//===============================================================================
map_enable:
    insert "map_enable.bin"

//===============================================================================
// Cycle active on maps
// One bit per map, 1 for inactive cycle, 0 for active
//===============================================================================
map_active:
    insert "map_freeze.bin"

//===============================================================================
// Battle backgrounds tint enabled
// One bit per background, 1 for tint enabled, 0 for disabled
//===============================================================================
bg_enable:
    insert "bg_enable.bin"

bg_palette:
    insert "bg_palette.bin"

//===============================================================================
// World events tint enabled
// One byte per event, #$01 for tint enabled, #$00 for disabled
//=============================================================================== 
world_events:
    insert "events.bin"
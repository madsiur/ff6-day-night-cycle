//===============================================================================
// Data generated with data/data.ods
// Location of this data defined by data_bank in var/global.asm
//===============================================================================

seek(data_start)

//===============================================================================
// Maps tint enabled
// One bit per map, 1 for tint enabled, 0 for disabled
//===============================================================================
log_start("map_enable")
map_enable:
    insert "map_enable.bin"

//===============================================================================
// Cycle active on maps
// One bit per map, 1 for inactive cycle, 0 for active
//===============================================================================
log_start("map_active")
map_active:
    insert "map_active.bin"

//===============================================================================
// World events tint enabled
// One byte per event, #$01 for tint enabled, #$00 for disabled
//===============================================================================
log_start("world_events")
world_events:
    insert "world_events.bin"

//===============================================================================
// Battle backgrounds tint enabled
// One bit per background, 1 for tint enabled, 0 for disabled
//===============================================================================
log_start("bg_enable")
bg_enable:
    insert "bg_enable.bin"

//===============================================================================
// Alternate palette set option
//===============================================================================

if {NIGHT_BATTLE_PALS} > 0 {

    //===============================================================================
    // Battle backgrounds nighttime palette id (optional)
    // One byte per background, 0xFF means no palette (default is used)
    //===============================================================================
    log_start("bg_palette_id")
    bg_palette_id:
        insert "bg_palette_id.bin"

    //===============================================================================
    // Battle backgrounds nighttime palette set (optional)
    // Must be 56 entries with 48 colors each
    //===============================================================================
    log_start("bg_palette_data")
    bg_palette_data:
        insert "bg_palette_data.bin"
}

log_start("data ending")
//===============================================================================
// Bank $EE code
// World map module
//===============================================================================

constant branch_850A($EE850A)
constant branch_87B7($EE87B7)
constant branch_8AA5($EE8AA5)

seek($EE0139)                   // vehicle mode hook
    jsr main_loop_EE            // manage and apply tint effect   
nop

seek($EE03A6)                   // character mode hook
    jsr main_loop_EE            // manage and apply tint effect   
nop

seek($EE0301)                   // tent event hook
    jsr tent_event_EE           // switch to daytime

seek($EE01E0)
    jsr sprite_anim             // sprite initialization and animation

seek($EE0470)
    jsr sprite_anim             // sprite initialization and animation

seek($EE0A41)
    jsr sprite_anim             // sprite initialization and animation

seek($EE0D18)
    jsr sprite_anim             // sprite initialization and animation

seek($EE0E62)
    jsr sprite_anim             // sprite initialization and animation

seek($EE156E)
    jsr sprite_anim             // sprite initialization and animation

seek($EE9504)
    jsr sprite_anim             // sprite initialization and animation

seek($EE95BD)
    jsr sprite_anim             // sprite initialization and animation

seek($EE96DC)
    jsr sprite_anim             // sprite initialization and animation

seek($EE97C5)
    jsr sprite_anim             // sprite initialization and animation

seek($EE98A7)
    jsr sprite_anim             // sprite initialization and animation

seek($EE8695)                   // in airship mode initialization
    jsr copy_pal_EE             // load world map and objects palettes

seek($EE8928)                   // in chocobo mode initialization
    jsr copy_pal_EE             // load world map and objects palettes

seek($EE8BEE)                   // in character mode initialization
    jsr copy_pal_EE             // load world map and objects palettes

seek($EE84BA)                   // airship mode initialization
    bra branch_850A             // continue to $EE850A

seek($EE8767)                   // chocobo mode initialization
    bra branch_87B7             // continue to $EE87B7

seek($EE8A53)                   // character mode initialization
    bra branch_8AA5             // Skip next routines

//===============================================================================
// Bank $EE code (free space)
//===============================================================================

seek(CONST_FREE_EE)         

main_loop_EE:
    jsl main_loop_EE_ext
    rts

sprite_anim:
    jsl sprite_anim_ext
    rts

tent_event_EE:
    jsl tent_event_EE_ext
    rts

call_world_event:
    jsr ($43DB,x)               // execute animation / initialization
    rtl

//===============================================================================
// Palette copy main function
//===============================================================================

log_start("copy_pal_EE")

scope copy_pal_EE: {
    jsl copy_pal_EE_ext         // load palettes
    jsr $34D5                   // leftover from $EE hook
    rts
}

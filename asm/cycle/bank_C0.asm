//===============================================================================
// Bank $C0 code
// Regular map module
//===============================================================================

seek($C00079)                       // Field map reset
    jsr set_town_flag               // Set flag telling we are on a regular map

seek($C000AA)                       // Field map reset
    jsr main_loop_C0                // Manage and apply tint effect

seek($C003EA)                       // World map loading
    jsr clear_town_flag             // Clear flag telling we are on a regular map

seek($C00468)                       // Returning from world map
    jsr set_town_flag               // Set flag telling we are back on a
                                    // regular map

seek($C0BE25)                       // SRAM initialization
    jsl init_timer_ext              // Initialize timer related SRAM

seek($C0BF67)                       // Map initialization
    jsr init_map_C0                 // Save temp RAM used in bank $EE and set
                                    // initial tint

seek($C0C66B)                       // Tent event
    jsr tent_event_C0               // switch to daytime

seek($C0992C)                       // Event command table
    dw event_command_69             // Cycle management event command $69

//===============================================================================
// Bank $C0 code (free space)
//===============================================================================

seek(CONST_FREE_C0)
event_command_69:
    jsl event_command_69_ext
    lda #$02                        // Event command is two bytes
    jmp $9B5C                       // Read next event command

init_map_C0:
    jsl init_map_C0_ext
    jsr $2883                       // Load map data
    rts

main_loop_C0:
    jsr $0564                       // Wait for v-blank
    jsl main_loop_C0_ext
    rts

clear_town_flag:
    jsl clear_town_flag_ext
    rts

set_town_flag:
    jsl set_town_flag_ext
    rts

tent_event_C0:
    jsl tent_event_C0_ext
    rts
//-------------------------------------------------------------------------------
// Global variables and constants.
//-------------------------------------------------------------------------------

define CONST_LOG(1)

constant CONST_FREE_C0($C0D613)                // free space (bank $C0)
constant CONST_FREE_C1($C1FFE5)                // free space (bank $C1)
constant CONST_FREE_C2($C26469)                // free space (bank $C2)
constant CONST_FREE_C3($C3FFFE)                // free space (bank $C3)

constant long_short_jump_add_c0(CONST_FREE_C0) // long short jump $C0 function
constant long_short_jump_add_c1(CONST_FREE_C1) // long short jump $C1 function
constant long_short_jump_add_c2(CONST_FREE_C2) // long short jump $C2 function
constant long_short_jump_add_c3(CONST_FREE_C3) // long short jump $C3 function

constant data_bank($FF0000)
constant code_bank($F20000)

variable end_hack(0)                           // variable used to set next asm
                                               // file starting offset

//-------------------------------------------------------------------------------
// SRAM constants
//-------------------------------------------------------------------------------
// You need 3 bytes of SRAM for this hack: two bytes for the timer and one for
// its flags. You also need one event bit that will be set when the game consider
// being at nighttime.

// Some possibilities of SRAM to use:
// $7E1CF8-$7E1D27: Unused SRAM (FF6j SwTech names)
// $7E1E1D-$7E1E3F: Unused SRAM
// $7E1E70-$7E1E7F: Unused SRAM

constant timer($7E1E3D)         // Timer register ($7E1E3D-$7E1E3E)

constant flags($7E1E3F)         // Timer flags
                                // 0x80 = Progression toward nighttime (automatically toggled)
                                // 0x40 = Timer is disabled (from event command)
                                // 0x20 = Player is currently on a regular map (automatically set on regular maps)
                                // 0x10 = Initial tint is disabled (from event command)
                                // 0x01-0x0F = Numbers of transitions toward day or night

constant event_byte($7E1E80)    // Night event bit byte ($1E80:2)

constant event_bit($04)         // Event bit

//-------------------------------------------------------------------------------
// Cycle constants
//-------------------------------------------------------------------------------

constant transitions(9)         // Number of transitions (0 to 15). Real amount 
                                // is transitions minus 1. 15 is the limit setting
                                // but would make nighttime look black and blue only.
                                // Using a value below 4 would make nighttime and
                                // daytime look quite similar.

constant init_tint(0)           // init_flags bits (0 or 1)
constant regular_map(0)         // regular_map and night_prog should never be set
constant timer_disabled(0)      // manually to 1 other than for testing purpose.
constant night_prog(1)

constant trans_length($0040)    // Transition length time ($003C = one second)

constant day_length($0400)      // Daytime/nghttime length ($0E10 = one minute)

constant night_value($05)       // Transition ID where a current transition lower
                                // than this number will result in a nighttime.
                                // As an example, if this setting is set to 5, 
                                // transition 0 to 4 will result in nighttime

constant init_flags((night_prog << 7) + (timer_disabled << 6) + (regular_map << 5) + (init_tint << 4) + transitions)





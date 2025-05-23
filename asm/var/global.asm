//===============================================================================
// Global variables and constants
//===============================================================================

constant data_start($FF1000)
constant code_bank($FF0000)

constant CONST_FREE_C0($C0D386)                 // free space start (bank $C0)
constant CONST_FREE_C1($C1FFE5)                 // free space start (bank $C1)
constant CONST_FREE_C2($C26469)                 // free space start (bank $C2)
constant CONST_FREE_C3($C3F091)                 // free space start (bank $C3)
constant CONST_FREE_EE($EEAF01)                 // free space start (bank $EE)

define NIGHT_BATTLE_PALS(0)     // Set to 1 if you have a custom set of
                                // battle background palettes

define LOG(1)                   // Set to 1 to enable log messages from
                                // log_start, log_end and log_free_space 

//===============================================================================
// SRAM constants
//===============================================================================
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

//===============================================================================
// Bitmasks
//===============================================================================

constant TRANSITIONS($0F)
constant TINT_DISABLED($10)
constant REGULAR_MAP($20)
constant TIMER_DISABLED($40)
constant NIGHT_PROG($80)

//===============================================================================
// Cycle initial flags
//===============================================================================

constant transitions_init(9)    // Number of transitions (0 to 15). Real amount 
                                // is transitions minus 1. 15 is the limit setting
                                // but would make nighttime look black and blue only.
                                // Using a value below 4 would make nighttime and
                                // daytime look quite similar.

// INIT_FLAGS bits (0 or 1)
// regular_map_init and night_prog_init should never be set
// manually to 1 other than for testing purpose.

constant tint_disabled_init(0)  
constant regular_map_init(0)    
constant timer_disabled_init(0) 
constant night_prog_init(1)     

//===============================================================================
// Cycle constants
//===============================================================================

constant TRANS_LENGTH($0040)    // Transition length time ($003C = one second)

constant DAY_LENGTH($0400)      // Daytime/nghttime length ($0E10 = one minute)

constant NIGHT_VALUE($05)       // Transition ID where a current transition lower
                                // than this number will result in a nighttime.
                                // As an example, if this setting is set to 5, 
                                // transition 0 to 4 will result in nighttime

//===============================================================================
// Initial flags byte value calculation
//===============================================================================

constant INIT_FLAGS((night_prog_init << 7) + (timer_disabled_init << 6) + (regular_map_init << 5) + (tint_disabled_init << 4) + transitions_init)
log_var("Initial flags byte value", INIT_FLAGS)





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
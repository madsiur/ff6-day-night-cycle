//===============================================================================
// FF3us bass macros
// Can be used in FF3us hacks
//===============================================================================

//===============================================================================
// Constants
//===============================================================================

constant CONST_FREE_END_C0($C0DF9E)             // free space end (bank $C0)
constant CONST_FREE_END_C1($C1FFFE)             // free space end (bank $C1)
constant CONST_FREE_END_C2($C267FE)             // free space end (bank $C2)
constant CONST_FREE_END_C3($C3FFFE)             // free space end (bank $C3)

constant long_short_jump_add_c0(CONST_FREE_END_C0)    // long short jump function
constant long_short_jump_add_c1(CONST_FREE_END_C1)    // long short jump function
constant long_short_jump_add_c2(CONST_FREE_END_C2)    // long short jump function
constant long_short_jump_add_c3(CONST_FREE_END_C3)    // long short jump function

//===============================================================================
// long_short_jump_C0
//
// fake a short jump in bank $C0 from another bank
//===============================================================================
macro long_short_jump_C0(variable offset) {
   phk
   per $0009
   pea long_short_jump_add_c0
   pea offset-1
   jml long_short_jump_add_c0
}

//===============================================================================
// long_short_jump_C1
//
// fake a short jump in bank $C1 from another bank
//===============================================================================
macro long_short_jump_C1(variable offset) {
   phk
   per $0009
   pea long_short_jump_add_c1
   pea offset-1
   jml long_short_jump_add_c1
}

//===============================================================================
// long_short_jump_C2
//
// fake a short jump in bank $C2 from another bank
//===============================================================================
macro long_short_jump_C2(variable offset) {
   phk
   per $0009
   pea long_short_jump_add_c2
   pea offset-1
   jml long_short_jump_add_c2
}

//===============================================================================
// long_short_jump_C3
//
// fake a short jump in bank $C3 from another bank
//===============================================================================
macro long_short_jump_C3(variable offset) {
   phk
   per $0009
   pea long_short_jump_add_c3
   pea offset-1
   jml long_short_jump_add_c3
}

//===============================================================================
// rts / rtl needed for long short jumps
//===============================================================================

macro short_long_return() {
   rts
   rtl
}

seek(long_short_jump_add_c0)
   short_long_return()

seek(long_short_jump_add_c1)
   short_long_return()

seek(long_short_jump_add_c2)
   short_long_return()

seek(long_short_jump_add_c3)
   short_long_return()
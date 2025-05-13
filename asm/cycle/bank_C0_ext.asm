//===============================================================================
// Code called from bank_C0.asm
//===============================================================================

//===============================================================================
// Regular map main timer function
//===============================================================================

log_start("main_loop_C0_ext")

scope main_loop_C0_ext: {
    jsr check_state             // load map bit and verify if map is tintable
    lda $1B                     // load map freeze byte
    bne exit                    // exit if map is labeled as freezable
    lda flags                   // load timer flags
    bit #$40                    // check if freeze flag is set
    bne exit                    // exit if so
    bit #$10                    // check if cycle disabling flag is set
    bne exit                    // exit if so
    ldx #$000E                  // number of bytes to copy to the stack ($58-$65)               
loop_a:    
    lda $57,x                   // load one bytes from RAM
    pha                         // save to the stack
    dex                         // decrement loop counter               
    bne loop_a                  // loop if we have not done 14 bytes
    jsr decrease_timer          // decrement timer 
    lda $1C                     // load map tint byte
    beq skip                    // skip tint if map not tintable
    jsr tint_screen             // tint if neccesary
skip:
    ldx $00                     // init loop counter to 0
loop_b:
    pla                         // restore one bytes from the stack
    sta $58,x                   // save in RAM ($58-$64)
    inx                         // increment loop counter
    cpx #$000E                  // check if we have done 13 bytes
    bne loop_b                  // loop if not
exit:
    tdc                         // clear accumulator 
    rtl
}

//===============================================================================
// Initial tint setting function
//===============================================================================

log_start("init_map_C0_ext")

scope init_map_C0_ext: {
    jsr check_state             // load map bit and verify if map is tintable or not
    lda $1C                     // load map tint byte
    beq exit                    // exit if map is not tintable
    lda flags                   // load timer flags
    bit #$10                    // check if cycle disabling flag is set
    bne exit                    // exit if so
    ldx #$000A                  // number of bytes to copy to the stack ($5C-$65)               
loop_a:
    lda $5B,x                   // load one bytes from RAM
    pha                         // save to the stack  
    dex                         // decrement loop counter                     
    bne loop_a                  // loop if we have not done 12 bytes
    jsr init_tint_C0            // Set initial tint effect
    ldx $00                     // init loop counter to 0
loop_b:
    pla                         // restore one bytes from the stack
    sta $5C,x                   // save in RAM ($5C-$65)
    inx                         // increment loop counter
    cpx #$000A                  // check if we have done 8 bytes
    bne loop_b                  // loop if not
exit:
    tdc                         // clear accumulator
    rtl
}

//===============================================================================
// Regular map initial tint function
//===============================================================================

log_start("init_tint_C0")

scope init_tint_C0: {
    lda #$FF                    // full palette loop value
    sta $64                     // save as loop value
    jsr load_town_pal           // load regular map tint parameters
    lda #$20                    // regular map flag
    tsb flags                   // set as flag
    jsr get_dec_tint_num        // get number of loops for initial tinting
    jsr dec_pal_mul             // tint toward nighttime multiple times
    rts
}

//===============================================================================
// Regular map tent function
//===============================================================================

log_start("tent_event_C0_ext")

scope tent_event_C0_ext: {
    sta $056F                   // save tent event bank
    jsr tent_event              // switch to daytime
    rtl
}

//===============================================================================
// Regular map flag clearing function

// uncomment "jsr test" if you want to test the world map without needing 
// to restart a new game.. however if you do so make sure to save once on 
// world map then reassemble the file with those lines commented otherwise 
// the hack will not work at 100% when entering the world map from a town map.
//===============================================================================

log_start("clear_town_flag_ext")

scope clear_town_flag_ext: {
    lda #$20                    // regular map flag value
    trb flags                   // clear flag on timer flags byte
    jsr test                    // set intitial values for world map testing
    lda $1F70,y                 // leftover from hook
    rtl
}

//===============================================================================
// Regular map flag setting function
//===============================================================================

log_start("set_town_flag_ext")

scope set_town_flag_ext: {
    sta $11FA                   // leftover from hook
    lda #$20                    // regular map flag value
    tsb flags                   // set flag on timer flags byte
    rtl
}

//===============================================================================
// Timer and flags init function
//===============================================================================

log_start("init_timer_ext")

scope init_timer_ext: {
    ldx #trans_length           // load transition timer length
    stx timer                   // store as timer
    lda #init_flags             // load initial timer flags
    sta flags                   // store as flags byte
    lda $E6F566                 // leftover from $C0 hook
    rtl
}

//===============================================================================
// Cycle management event command
//
// 69 01: Freeze cycle               
// 69 02: Unfreeze cycle             
// 69 03: Disable cycle              
// 69 04: Enable cycle               
//===============================================================================

log_start("event_command_69_ext")

scope event_command_69_ext: {           
    lda $EB                     // load parameter
    cmp #$01
    beq freeze_cycle            // branch if we freeze the cycle
    cmp #$02
    beq unfreeze_cycle          // branch if we unfreeze the cycle
    cmp #$03
    beq disable_cycle           // branch if we disable the cycle
    cmp #$04
    beq enable_cycle            // branch if we enable the cycle
    bra exit                    // invalid event command
disable_cycle:
    lda #$10
    tsb flags                   // disable initial tint
freeze_cycle:
    lda #$40
    tsb flags                   // disable timer
    bra exit
enable_cycle:
    lda #$10
    trb flags                   // enable initial tint
unfreeze_cycle:
    lda #$40
    trb flags                   // enable timer
exit:
    rtl
}

//===============================================================================
// Test function
// TODO: Remove
//===============================================================================

log_start("test")

scope test: {
    ldx #trans_length           // load transition timer length 
    stx timer                   // store as timer
    lda #init_flags             // load initial timer flags
    sta flags                   // store as flags byte
    rts
}


//===============================================================================
// Code called from bank_EE.asm
//===============================================================================

//===============================================================================
// World tent event function
//===============================================================================

log_start("tent_event_EE_ext")

scope tent_event_EE_ext: {
    jsr tent_event              // switch to daytime
    stz $0205                   // clear multipurpose menu variable
    rtl
}

//===============================================================================
// World main timer function
//===============================================================================

log_start("main_loop_EE_ext")

scope main_loop_EE_ext: {
    lda flags                   // load timer flags
    bit #$10                    // check if cycle disabling flag is set
    bne exit                    // exit if so
    lda $65                     // load RAM we need to backup
    pha                         // save it
    jsr decrease_timer          // decrement timer 
    jsr tint_screen             // tint if neccesary
    pla                         // restore saved RAM
    sta $65                     // save it
exit:
    jsl $C30009                 // leftover from $EE hook
    rtl
}

//===============================================================================
// World events function 
//===============================================================================

log_start("sprite_anim_ext")

scope sprite_anim_ext: {
    php                         // save processor flags
    phb                         // save data bank
    rep #$30                    // 16-bit accumulator and Index
    ldx $00                     // clear X Index
next_event:
    lda $CA,x                   // load jump table event ID
    beq skip                    // skip event if first entry
    phx                         // save $CA-$D0 index
    pha                         // index event ID
    tax                         // save event ID
    lda world_events,x          // load event night cycle enabling byte
    beq exit                    // skip timer decreasing if event has no night cycle 
    sep #$20
    lda flags                   // load timer flags
    bit #$10
    bne exit
    phx 
    ldx #$000E                  // number of bytes to copy to the stack ($58-$65)               
save_stack:
    lda $57,x                   // load one bytes from RAM
    pha                         // save to the stack
    dex                         // decrement loop counter               
    bne save_stack              // loop if we have not done 14 bytes
    jsr decrease_timer          // decrement timer 
    jsr tint_screen             // tint if neccesary
    ldx $00                     // init loop counter to 0
save_ram:
    pla                         // restore one bytes from the stack
    sta $58,x                   // save in RAM ($58-$65)
    inx                         // increment loop counter
    cpx #$000E                  // check if we have done 14 bytes
    bne save_ram                // loop if not                    
    plx
exit:
    rep #$20 
    pla 
    asl                         // multiply by 2
    tax                         // index jump table entry offset
    jsl call_world_event
    plx                         // restore $CA-$D0 index
skip:
    inx 
    inx                         // increment $CA-$D0 index of 2
    cpx #$0008                  // have we done $CA through $D0?
    bne next_event              // branch if not
    plb                         // restore data bank
    plp                         // restore processor flags
    rtl
}

//===============================================================================
// World palette loading function
//===============================================================================

log_start("copy_pal_EE_ext")

scope copy_pal_EE_ext: {
    sep #$20    
    phb   
    lda #$7E
    pha
    plb         
    lda $001F64                 // load event byte
    pha
    bne is_not_wob_a            // check if not WOB
    ldx $00                     // WOB palettes start at $D2EC00
    bra load_palettes_a         // skip next instruction
is_not_wob_a:
    ldx #$0100                  // WOR palettes start at $D2ED00     
load_palettes_a:
    ldy $00                     // init RAM counter
    rep #$20                    // 16-bit accumulator    
next_color_a:
    lda $D2EC00,x               // load map palette color
    sta $E000,y                 // store in active palette
    sta $FE00,y
    iny
    iny                         // increase RAM palette color entry
    inx
    inx                         // increase ROM palette color entry
    cpy #$0100                  // have we done 128 colors yet?
    bne next_color_a            // loop if not
    sep #$20                    // 8-bit accumulator
    pla                         // load event byte
    bne is_not_wob_b            // check if not WOB
    ldx #$0200                  // WOB palettes start at $D2EE00
    bra load_palettes_b         // skip next instruction             
is_not_wob_b:
    ldx #$0300                  // WOB palettes start at $D2EF00
load_palettes_b:
    ldy $00                     // init RAM counter
    rep #$20                    // 16-bit accumulator  
next_color_b:
    lda $D2EC00,x               // overworld object palettes
    sta $E100,y                 // store in active palette
    sta $FF00,y
    iny
    iny                         // increase RAM palette color entry
    inx
    inx                         // increase ROM palette color entry
    cpy #$0100                  // have we done 128 colors yet?
    bne next_color_b            // branch if not
    plb
    sep #$20
    lda flags                   // load timer flags
    bit #$10
    bne skip_init_tint
    jsr init_tint_EE            // Set initial tint effect since we just loaded palettes
skip_init_tint:
    rep #$20                    // 16-bit accumulator
    rtl
}

//===============================================================================
// World initital tint function
//===============================================================================

log_start("init_tint_EE")

scope init_tint_EE: {
    lda #$FF                    // full palette loop value
    sta $64                     // save as loop value
    lda $65                     // load RAM we need to backup
    pha                         // save it
    jsr load_world_pal          // load world maps tint parameters
    jsr get_dec_tint_num        // get number of loops for initial tinting 
    jsr dec_pal_mul             // tint toward nighttime multiple times
    jsr load_horizon_pal        // load airship and chocobo modes horizon tint parameters
    jsr dec_pal_mul             // tint toward nighttime multiple times
    pla                         // restore saved RAM
    sta $65                     // save it
    rts
}



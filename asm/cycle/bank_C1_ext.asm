//===============================================================================
// Code called from bank_C1.asm
//===============================================================================

//===============================================================================
// Tint option macro
//===============================================================================

macro add_night_tint_code() {

    //===============================================================================
    // Battle background palette copy function
    //===============================================================================

    log_start("battle_pal_copy_ext")

    scope battle_pal_copy_ext: {
        sep #$20
        tay
    next_byte:
        lda $E70150,x
        sta $7EA0,y
        inx
        iny
        cpy #$0060
        bne next_byte
        tdc
        tay
        lda #$FF
        sta $25
        rtl
    }

    //===============================================================================
    // Battle background palette RAM copy function
    //===============================================================================

    log_start("battle_pal_copy_ram_ext")

    scope battle_pal_copy_ram_ext: {
        rep #$20                    // 16-bit accumulator
        ldx #$005F                  // 96 bytes to loop
    next_color:
        lda $7EA0,x                 // palette RAM offset
        sta $7CA0,x                 // save as duplicate
        dex
        dex                         // decrement loop index of 2
        bne next_color              // branch if we have not done 96 bytes
        sep #$20                    // 8-bit accumulator
        rtl
    }

    //===============================================================================
    // Battle background tint function
    //===============================================================================

    log_start("battle_tint_ext")

    scope battle_tint_ext: {
        tdc                         // clear accumulator
        pha                         // save accumulator
        plb                         // set DB as $00
        jsr check_state             // load map bit and verify if map is tintable or not
        lda $1C                     // load map tint byte
        beq exit_a                  // exit if map is not tintable
        lda flags                   // load timer flags
        bit #$10                    // check if cycle disabling flag is set
        bne exit_a                  // exit if so
        lda $22                     // battle background palette ID
        sta $4204                   // save as divident
        stz $4205                   // palette ID is only 1 byte
        lda #$08                    // a byte is 8 bits
        sta $4206                   // save as divider
        nop 
        nop 
        nop 
        nop 
        nop 
        nop 
        nop 
        nop                         // wait for division to be done
        ldx $4216                   // load leftover of division
        lda $C0BAFC,x               // load bit value from LUT     
        sta $25                     // save as temp RAM
        tdc                         // clear accumulator
        ldx $4214                   // load division result (palette ID byte index)
        lda bg_enable,x             // load palette ID byte
        bit $25                     // check if background is tintable
        beq exit_b                  // exit if it's not the case
        ldx #$000A                  // number of bytes to copy to the stack ($5C-$64)               
    save_next_byte:
        lda $5B,x                   // load one bytes from RAM
        pha                         // save to the stack  
        dex                         // decrement loop counter                     
        bne save_next_byte          // loop if we have not done 9 bytes
        lda #$7E
        pha
        plb                         // set DB as $7E
        tdc                         // clear accumulator
        lda $25                     // check which of the two $C1 functions we are coming from
        rep #$20                    // 16-bit accumulator
        beq is_battle               // branch if we come from $C11C36
        lda #$7EA0                  // background palette RAM offset ($7E7EA0)
        bra save_temp_ram           // save as temporary RAM
    is_battle:
        lda #$7E60                  // background palette RAM offset ($7E7E60)
    save_temp_ram:
        sta $5D                     // save as temporary RAM
        lda #$0060                  // number of bytes for loop (48 colors)
        sta $5F                     // save as temporary RAM
        ldy $00                     // clear Y index
        ldx $23                     // load palette ROM index
        sep #$20                    // 8-bit accumulator
    next_pal_byte:
        lda $E70150,x               // load color byte
        sta ($5D),y                 // save in RAM
        inx                         // increase palette ROM index
        iny                         // increase RAM index
        cpy #$0060                  // check if we have done 96 bytes
        bne next_pal_byte           // loop if not
        ldy $00                     // clear Y index
        jsr get_dec_tint_num        // get number of loops for initial tinting 
        jsr dec_pal_mul             // tint toward nighttime multiple times
        ldx $00                     // init loop counter to 0
    restore_next_byte:
        pla                         // restore one bytes from the stack
        sta $5C,x                   // save in RAM ($5D-$64)
        inx                         // increment loop counter
        cpx #$000A                  // check if we have done 9 bytes
        bne restore_next_byte       // loop if not
    exit_a:
        tdc                         // clear accumulator
    exit_b:
        rtl
    }
}

//===============================================================================
// Alternate palette set macro
//===============================================================================

macro add_night_palette_code() {

    //===============================================================================
    // Calculate palette offset depending on palette ID 
    //===============================================================================

    log_start("set_pal_offset_ext")

    scope set_pal_offset_ext: {
        and #$7F                    // don't take vanilla flag 0x80 in account
        rep #$20                    // 16-bit Accumulator
        asl
        asl
        asl
        asl
        asl                         // multiply by 32
        sta $22                     // save in temporary RAM
        asl                         // multiply by 2 (64)
        clc                         // clear carry for addition
        adc $22                     // add multiplication by 2 to the on by 32 (result is 96 times A)
        tax                         // index result 
        tdc                         // clear Accumulator
        sep #$20                    // 8-bit Accumulator
        tay                         // Clear Y
        lda #$FF                    // flag will be 0xFF for day and 0x00 for night           
        sta $22                     // save in temporary RAM
        rtl
    }

    //===============================================================================
    // Check if battle is considered nighttime or daytime
    //===============================================================================

    log_start("check_night_battle_ext")

    scope check_night_battle_ext: {
        lda flags                   // load timer flags
        and #$0F                    // isolate current transition
        sec                         // set carry for substraction
        sbc #night_value            // substract transition considered as night
        rtl
    }

    //===============================================================================
    // Load palette for hookpoint $C11C36
    //===============================================================================

    log_start("load_bg_pal_1C36_ext")

    scope load_bg_pal_1C36_ext: {
        jsr load_bg_pal_offset
    next_color:
        lda [$42],y                 // load palette byte
        sta $7EA0,x                 // save in RAM
        sta $7CA0,x                 // save in RAM
        inx                         // increment RAM counter
        iny                         // increment ROM counter
        cpy #$0060                  // have we done 48 colors?
        bne next_color              // branch if not
        rtl
    }
    
    //===============================================================================
    // Load palette for hookpoint $C11DF2
    //===============================================================================

    log_start("load_bg_pal_1DF2_ext")

    scope load_bg_pal_1DF2_ext: {
        lda $22                     // load day / night flag
        cmp #$FF                    // check if nighttime
        jsr load_bg_pal_offset      // load correct palette offset depending if daytime or nighttime
    next_color:
        lda [$42],y                 // load palette byte
        sta $7EA0,x                 // save in RAM
        inx                         // increment RAM counter
        iny                         // increment ROM counter
        cpy #$0060                  // have we done 48 colors?
        bne next_color              // branch if not
        rtl
    }

    //===============================================================================
    // Load correct palette offset depending if daytime or nighttime
    //===============================================================================

    log_start("load_bg_pal_offset")

    scope load_bg_pal_offset: {
        beq is_night                // branch if night time
        lda #$E7                    // daytime palettes bank
        sta $44                     // save in temporary RAM
        rep #$20                    // 16-bit Accumulator
        lda #$0150                  // daytime palettes address ($E70150)
        sta $42                     // save in temporary RAM
        bra skip_night              // branch to X and Y swapping
    is_night:
        lda #$C0                    // nighttime palettes bank
        sta $44                     // save in temporary RAM
        rep #$20
        lda #bg_palette_data        // nighttime palettes address
        sta $42                     // save in temporary RAM
    skip_night:
        tya
        txy
        tax                         // result is X and Y swapping for future loop
        sep #$20                    // 8-bit Accumulator
        rts
    }
}

//===============================================================================
// Wavy effect check function 
//===============================================================================

log_start("check_desert_ext")

scope check_desert_ext: {
    lda $E70000,x               // load background palette
    and #$7F                    // isolate palette ID
    cmp #$0B                    // check if wob desert palette
    beq desert_bg               // branch if so
    cmp #$34                    // check if wor desert palette
    beq desert_bg               // branch if so
    lda $E70000,x               // load background palette
    and #$80                    // isolate wavy bit
    sta $6283                   // save it
    bra exit                    // exit
desert_bg:            
    lda event_byte              // load night event bit
    bit #event_bit
    bne nighttime               // branch if nighttime
    lda #$80                    // wavy effect (day desert)
    sta $6283                   // save it
    bra exit
nighttime:
    stz $6283                   // no wavy effect
exit:
    rtl
}

// add the right code needed depending of
// NIGHT_BATTLE_PALS value in var/global.asm

if {NIGHT_BATTLE_PALS} > 0 {
    add_night_palette_code()
} else {
    add_night_tint_code()
}


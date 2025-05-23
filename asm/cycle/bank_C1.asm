//===============================================================================
// Bank $C1 code
// Battle module
//===============================================================================

//===============================================================================
// Tint option macros
//===============================================================================

macro scope function_1C36_tint() {
    lda $E70000,x               // load palette ID
    and #$7F                    // isolate palette ID
    rep #$20
    asl
    asl
    asl
    asl
    asl                         // multiply by $20
    sta $23                     // save in temp RAM
    asl                         // multiply by $40
    clc 
    adc $23                     // palette ID * $60
    sta $23                     // save in temp RAM
    tax                         // index result
    sep #$20
    lda $E9DE
    beq is_background           // branch if background
    tdc
    tay
next_color:
    lda $E70150,x               // load color byte?
    sta $7E60,y                 // save in RAM
    sta $7C60,y                 // save in RAM
    inx                         // increment color offset
    iny                         // increment RAM offset
    cpy #$0040                  // have we done $40 bytes?
    bne next_color              // branch if not
    bra C11C77         
is_background:
    stz $25                     // clear temp RAM
    jsl battle_tint_ext         // tint background if neccesary
    lda #$7E                           
    pha
    plb                         // set DB register to $7E
    jsl battle_pal_copy_ram_ext // duplicate palette
    fill 1, $EA                 // free space (1 bytes)  
C11C77:
}

macro scope function_1DF2_tint() {
    lda $E70000,x               // load palette ID
    and #$7F                    // isolate palette ID
    rep #$20
    asl
    asl
    asl
    asl
    asl                         // multiply by $20
    sta $23                     // save in temp RAM
    asl                         // multiply by $40
    clc 
    adc $23                     // palette ID * $60
    sta $23                     // save in temp RAM
    tax
    tdc
    jsl battle_pal_copy_ext     // transfer palette prior to potential tinting
    jsl battle_tint_ext         // tint background if neccesary
    lda #$7E
    pha
    plb                         // set DB register to $7E
    bra C11E18
    fill 1, $EA                 // free space (1 bytes)  
C11E18:
}

//===============================================================================
// Alternate palette set option macros
//===============================================================================

macro scope function_1C36_pal() {
    jsl check_night_battle_ext  // check if battle is considered nighttime or daytime
    bpl daytime                 // branch if daytime
    lda $26                     // load background ID
    txy                         // save X in Y
    tax                         // index background ID
    lda bg_palette_id,x         // load palette ID based on background ID
    bmi no_alt_palette          // if 0x80 or higher, there is no nighttime palette for this background
    jsl set_pal_offset_ext      // calculate palette offset depending on palette ID
    bra load_palette            // jump to load palette
no_alt_palette:
    tyx                         // restore previous palette ID index
daytime:
    lda $E70000,x               // load palette ID
    jsl set_pal_offset_ext      // calculate palette offset depending on palette ID
    stz $22                     // set day / night flag as daytime
load_palette:
    lda $E9DE               
    beq skip                    // skip palette loading if $E9DE == 0
next_color:
    lda $E70150,x               // dunno what this palette loading is, copied from vanilla
    sta $7E60,y                 // save in RAM
    sta $7C60,y                 // save in RAM
    inx                         // increment ROM counter
    iny                         // increment RAM counter
    cpy #$0040                  // have we done 32 colors?
    bne next_color              // branch if not
    bra exit                    // skip background palette loading
skip:
    lda $22                     // load day / night flag
    cmp #$FF                    // check if nighttime
    jsl load_bg_pal_1C36_ext    // load palette for hookpoint $C11C36
exit:
}

macro scope function_1DF2_pal() {
    jsl check_night_battle_ext  // check if battle is considered nighttime or daytime
    bpl daytime                 // branch if daytime
    lda $26                     // load background ID
    txy                         // save X in Y
    tax                         // index background ID
    lda bg_palette_id,x         // load palette ID based on background ID
    bmi no_alt_palette          // if 0x80 or higher, there is no nighttime palette for this background
    jsl set_pal_offset_ext      // calculate palette offset depending on palette ID
    bra load_palette            // jump to load palette
no_alt_palette:
    tyx                         // restore previous palette ID index
daytime:
    lda $E70000,x               // load palette ID
    jsl set_pal_offset_ext      // calculate palette offset depending on palette ID
    stz $22                     // set day / night flag as daytime
load_palette:
    jsl load_bg_pal_1DF2_ext    // load palette for hookpoint $C11DF2

    fill 1, $EA                 // free space (1 bytes)
}

//===============================================================================
// Battle background tint function 1
//===============================================================================

seek($C11C2D)
scope function_1C2D: {
    jsl check_desert_ext        // check if desert background and set wavy effect if day
    bra function_1C36
}

seek($C11C36)

log_start("function_1C36")

function_1C36: {
    // add the right code needed depending of
    // NIGHT_BATTLE_PALS value in var/global.asm

    if {NIGHT_BATTLE_PALS} > 0 {
        function_1C36_pal()
    } else {
        function_1C36_tint()
    }    
}

log_free_space($C11C77)

//===============================================================================
// Battle background tint function 2
//===============================================================================

seek($C11DE9)
scope function_1DE9: {
    jsl check_desert_ext        // check if desert background and set wavy effect if day
    bra function_1DF2
}

seek($C11DF2)

log_start("function_1DF2")

function_1DF2: {
    // add the right code needed depending of
    // NIGHT_BATTLE_PALS value in var/global.asm

    if {NIGHT_BATTLE_PALS} > 0 {
        function_1DF2_pal()
    } else {
        function_1DF2_tint()
    }  
}

log_free_space($C11E18)
//===============================================================================
// Code called from multiple external asm files (*_ext.asm)
//===============================================================================

//===============================================================================
// Tent event function
//===============================================================================

log_start("tent_event")

scope tent_event: {
    lda #NIGHT_PROG             // Transition direction flag
    tsb flags                   // set transition direction
    lda #TRANSITIONS            // load all possible transition bits
    trb flags                   // clear them
    lda #transitions_init       // load transition amount
    dec                         // transition amount minus 1
    tsb flags                   // set transition amount
    rep #$20                    // 16-bit accumulator
    lda #DAY_LENGTH             // load length of a day
    sta timer                   // set as timer
    sep #$20                    // 8-bit accumulator
    rts
}

//===============================================================================
// main timer function
//===============================================================================

log_start("decrease_timer")

scope decrease_timer: {
    rep #$20                    // 16-bit accumulator
    lda timer                   // load timer value
    cmp #$0002                  // is it third last frame
    beq three_frames_left       // branch if so
    cmp #$0001                  // is it second last frame
    beq two_frames_left         // branch if so
    lda timer                   // load timer value
    bne dec_timer               // decrement timer and exit if timer has not reach 0
    lda #TRANS_LENGTH           // load transition timer value (relevant when
                                // passing from daytime timer to transition timer)
    sta timer                   // save as timer
    bra is_last_frame           // we are the last frame
three_frames_left:
    dec timer                   // decrement timer
    sep #$20
    lda #$10
    sta $64                     // set third last frame flag
    bra tint                    // tint screen
two_frames_left:
    dec timer                   // decrement timer
    sep #$20
    stz $64                     // set second last frame flag
    bra tint                    // tint screen
is_last_frame:
    sep #$20                    // 8-bit accumulator
    lda flags                   // load timer flags
    sta $64
    bit #TRANSITIONS            // isolate transition ID
    beq is_darkest              // if 0, branch to full nighttime switch
    and #TRANSITIONS            // isolate transition ID
    cmp #transitions_init       // compare to number of transitions
    beq is_brightest            // if both equal, branch to full daytime switch
    lda flags                   // load timer flags
    and #NIGHT_PROG             // isolate transition direction
    bmi is_darker               // branch if we are going toward nighttime
    inc flags                   // increment transition ID by 1
    lda flags                   // load timer flags
    and #TRANSITIONS            // isolate transition ID
    sec
    sbc #NIGHT_VALUE            // subtract night transition
    bmi tint                    // exit if night
    lda #event_bit
    trb event_byte              // clear event bit
    bra tint                    // skip next instruction
is_darker:
    lda flags                   // load timer flags
    and #TRANSITIONS            // isolate transition ID
    sec
    sbc #NIGHT_VALUE            // subtract night transition
    bpl not_night               // branch if day
    lda #event_bit
    tsb event_byte              // set event bit
not_night:
    dec flags                   // decrement transition ID by 1
tint:                           // tint darker of lighter the palettes
    lda #$01
    sta $65
    rts

dec_timer:
    dec                         // decrement timer by 1
    sta timer                   // save as new timer value
    bra not_tint

is_darkest:                     // full nighttime switch
    lda #NIGHT_PROG             // Transition direction flag
    trb flags                   // set next progression to be toward day
    inc flags                   // increment transition ID by 1 (to avoid inifnite loop) 
    bra set_day_length          // set daylength timer

is_brightest:                   // full daytime switch
    lda #$80                    // Transition direction flag
    tsb flags                   // set next progression to be toward night
    dec flags                   // decrement transition ID by 1 (to avoid inifnite loop)

set_day_length:
    rep #$20                    // 16-bit accumulator
    lda #TRANS_LENGTH           // load length of nighttime
    sta timer                   // set as timer
not_tint:
    sep #$20                    // 8-bit accumulator
    stz $65
    rts
}

//===============================================================================
// map properties check function
//===============================================================================

log_start("check_state")

scope check_state: {
    rep #$20                    // 16-bit accumulator
    lda $1F64                   // load current map ID
    sta $4204                   // save as divident
    sep #$20                    // 8-bit accumulator
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
    sta $1A                     // save as temp RAM
    tdc                         // clear accumulator
    ldx $4214                   // load division result (map data byte index)
    lda map_active,x            // load map freeze byte
    and $1A                     // check if map is freezable
    sta $1B                     // save in temp RAM
    lda map_enable,x            // load map tintability byte
    and $1A                     // check if map is tintable
    sta $1C                     // save in temp RAM
    rts
}

//===============================================================================
// regular map palette range function
//===============================================================================

log_start("set_pal_loop")

scope set_pal_loop: {
    lda $64
    cmp #$FF
    beq is_init_tint            // check if initial tint
    lda $64                 
    beq is_first_frame          // check if first frame of tint
    cmp #$10
    beq is_second_frame         // check if second frame of tint
    ldx #$00E0                  // third frame, colors $A0-$E0
    ldy #$00A0
    bra store_loop_val          // exit
is_second_frame:
    ldx #$00A0                  // second frame, colors $40-$A0
    ldy #$0040
    bra store_loop_val          // exit
is_init_tint:
    ldx #$00E0                  // initial tint, all colors
    bra start_offset
is_first_frame:          
    ldx #$0040                  // first frame, colors $00-$40 
start_offset:
    ldy $00
store_loop_val:
    rts
}

//===============================================================================
// numerous tint number function
//===============================================================================

log_start("get_dec_tint_num")

scope get_dec_tint_num: {
    lda flags                   // load timer flags
    and #TRANSITIONS            // isolate tint value
    sta $63                     // store as temporary RAM
    lda #transitions_init       // compare to maximum tint vehicle
    dec
    sec                         // set carry for substraction
    sbc $63                     // substract transition value
    sta $63                     // save result in temporary RAM
    rts
}

//===============================================================================
// Main tint function
//===============================================================================

log_start("tint_screen")

scope tint_screen: {
    lda $65
    beq exit
    lda $1A
    lda flags                   // load timer flags
    bmi dec_tint                // branch if we are going toward daytime
    lda flags                   // load timer flags
    bit #REGULAR_MAP            // check if we are on a regular map
    bne regular_map_a           // exit if so
    jsr load_world_pal          // load world maps tint parameters
    jsr inc_pal                 // tint toward daytime
    jsr load_horizon_pal        // load mode 7 tint parameters
    bra tint_day
regular_map_a:
    jsr load_town_pal           // load regular map tint parameters
tint_day:
    jsr inc_pal                 // tint toward daytime
exit:
    rts

dec_tint:
    lda flags                   // load timer flags
    bit #REGULAR_MAP            // check if we are on a regular map
    bne regular_map_b           // exit if so
    jsr load_world_pal          // load world maps tint parameters
    jsr dec_pal
    jsr load_horizon_pal
    bra tint_night
regular_map_b:
    jsr load_town_pal           // load regular map tint parameters
tint_night:
    jsr dec_pal                 // tint toward nighttime 
    rts
}

//===============================================================================
// Map tint params loading function
//===============================================================================

log_start("load_town_pal")

scope load_town_pal: {
    jsr set_pal_loop
    iny
    iny
    stx $5F                     // save as temporary RAM
    ldx #$7200                  // reference map palette RAM offset ($7E7400)
    stx $5B                     // save result as temporary RAM
    ldx #$7400                  // active map palette RAM offset ($7E7400)
    stx $5D                     // save as temporary RAM
    rts
}

//===============================================================================
// World tint params loading function
//===============================================================================

log_start("load_world_pal")

scope load_world_pal: {
    jsr set_pal_loop            // set looping values for world map
    stx $5F                     // save as temporary RAM
    ldx #$FE00                  // reference map palette RAM offset ($7EFE00)
    stx $5B                     // save result as temporary RAM
    ldx #$E000                  // active map palette RAM offset ($7EE000)
    stx $5D                     // save as temporary RAM
    rts
}

//===============================================================================
// Mode 7 tint params loading function
//===============================================================================

log_start("load_horizon_pal")

scope load_horizon_pal: {
    lda $64                     // load palette loop value
    cmp #$FF             
    beq is_init_tint
    lda $64
    beq is_first_frame
    cmp #$10
    beq is_second_frame
    ldx #$0016
    ldy #$000E
    bra store_loop_val
is_second_frame:
    ldx #$000E
    ldy #$0008
    bra store_loop_val
is_init_tint:
    ldx #$0016
    bra start_offset
is_first_frame:                 // init starting palette offset to 2 (skip black screen border)
    ldx #$0008
start_offset:
    ldy $00
store_loop_val:
    stx $5F                     // save as temporary RAM
    ldx #$FF6A                  // reference map palette RAM offset ($7E7400)
    stx $5B                     // save result as temporary RAM
    ldx #$E16A                  // active map palette RAM offset ($7E7400)
    stx $5D                     // save as temporary RAM
    rts
}

//===============================================================================
// Color tinting function (1 color)
// Tint toward day 

// $59-$5A:  new active color        
// $5B-$5C:  ref color RAM offset    
// $5D-$5E:  active color offset     
// $5F-$60:  num color bytes for loop
// $61-$62:  temp reference color    
//===============================================================================

log_start("inc_pal")

scope inc_pal: {
    lda #$7E                    // RAM bank
    pha
    plb                         // set DB register to $7E
next_color:
    lda ($5B),y                 // load byte 1 of reference color
    and #$1F                    // isolate red
    beq exit_red                // exit if no red present
    sta $61                     // save in temporary RAM
    lda ($5D),y                 // load byte 1 of active color
    and #$1F                    // isolate red
    cmp #$1F                    // compare to maximum red
    beq exit_red                // exit if red is at maximum
    cmp $61                     // compare to reference red
    beq exit_red                // exit if active red is equal than reference red
    inc                         // increment red value by 1
exit_red:
    sta $59                     // save in temporary color
    inc $5D                     // increment active palette RAM address by 1
    lda ($5D),y                 // load byte 2 of active color
    and #$7C                    // isolate blue
    sta $5A                     // save in temporary color
    dec $5D                     // decrement active palette RAM address by 1
    rep #$20                    // 16-bit accumulator
    lda ($5B),y                 // load byte 1 and 2 of reference color
    and #$03E0                  // isolate green
    sta $61                     // save in temp color
    lda ($5D),y                 // load byte 1 and 2 of active color
    and #$03E0                  // isolate green
    cmp #$03E0                  // compare to maximum green
    beq exit_green              // exit if green is at maximum
    cmp $61                     // compare to reference green
    bcs exit_green              // exit if active green is higher or equal than reference green
    adc #$0020                  // increase green value by 1
exit_green:
    ora $59                     // combine green to blue and red
    sta ($5D),y                 // save as active RGB color
    sep #$20                    // 8-bit accumulator
    iny 
    iny                         // increase color entry
    cpy $5F                     // have we done all colors yet?
    bne next_color              // loop if not all colors are done
    tdc                         // clear accumulator
    pha               
    plb                         // set DB register to $00
    rts
}


//===============================================================================
// Color tinting function (1 color)
// Tint toward blue (night) 
 
// $5D-$5E:  active color offset     
// $5F-$60:  num color bytes for loop
// $61-$62:  temp reference color    
//===============================================================================

log_start("dec_pal")

scope dec_pal: {
    lda #$7E                    // RAM bank
    pha
    plb                         // set DB register to $7E
next_color:
    lda ($5D),y                 // load byte 1 of active color
    and #$1F                    // isolate active red
    sta $61                     // save active red in temporary RAM
    beq exit_red                // go to active blue if no active red present
    dec $61                     // decrement active red value by 1
exit_red:
    inc $5D                     // increment active palette RAM address by 1
    lda ($5D),y                 // load byte 2 of active color
    and #$7C                    // isolate active blue                  
    sta $62                     // save active blue in temporary RAM
    dec $5D                     // decrement active palette RAM address by 1
    rep #$20                    // 16-bit accumulator
    lda ($5D),y                 // load bytes 1 and 2 of active color
    and #$03E0                  // isolate active green
    beq exit_green              // merge color channels if no active green present
    sec                         // set carry flag for substraction
    sbc #$0020                  // decrement active green value by 1
exit_green:
    ora $61                     // combine active green to active blue and active red
    sta ($5D),y                 // save as active RGB color
    sep #$20                    // 8-bit accumulator
    iny 
    iny                         // increase color entry
    cpy $5F                     // check if we have done all colors
    bne next_color              // loop if not
    tdc                         // clear accumulator
    pha               
    plb                         // set DB register to $00
    rts
}

//===============================================================================
// tint function (multiple times)
// tint toward blue (night)
//
// $5C:      temp green ($00 to $1F) 
// $5D-$5E:  active color RAM offset 
// $5F-$60:  num color bytes for loop
// $61-$62:  new active color        
// $63:      tinting loop value      
//===============================================================================

log_start("dec_pal_mul")

scope dec_pal_mul: {
    lda #$7E                    // RAM bank
    pha
    plb                         // set DB register to $7E
next_color:
    tdc                         // clear accumulator
    lda ($5D),y                 // load byte 1 of active color
    and #$1F                    // isolate active red
    sta $61                     // save active red in temporary RAM
    beq exit_red                // go to active blue if no active red present
    cmp $63                     // compare active red value with number of loops to do 
    bcc red_smaller             // branch if active red value is smaller than number of loops
    lda $63                     // if equal or above, we'll use number of loops as looping value
    beq exit_red                // go to active blue if number of loops equal 0
red_smaller:
    tax                         // index number of loops
dec_red:
    dec $61                     // decrement active red value by 1
    dex                         // decrement loop counter by 1
    bne dec_red                 // branch if loop is not finish
exit_red:
    inc $5D                     // increment active palette RAM address by 1
    lda ($5D),y                 // load byte 2 of active color
    and #$7C                    // isolate active blue                  
    sta $62                     // save active blue in temporary RAM
    dec $5D                     // decrement active palette RAM address by 1
    rep #$20                    // 16-bit accumulator
    lda ($5D),y                 // load byte 1 and 2 of active color
    and #$03E0                  // isolate active green
    beq merge_green             // merge color channels if no active green present
    lsr
    lsr
    lsr
    lsr
    lsr                         // divide by 32 (index of #$00 to #$1F)
    sep #$20                    // 8-bit accumulator
    sta $5C                     // save active green in temporary RAM
    cmp $63                     // compare active green value with number of loops to do
    bcc green_smaller           // branch if active green value is smaller than number of loops
    lda $63                     // if equal or above, we'll use number of loops as looping value
    beq exit_green              // restore active green and merge channels if number of loops equal 0
green_smaller:
    tax                         // index number of loops
dec_green:
    dec $5C                     // decrement active green value by 1
    dex                         // decrement loop counter by 1
    bne dec_green               // branch if loop is not finish
exit_green:
    lda $5C                     // load active green value
    rep #$20                    // 16-bit accumulator
    asl
    asl
    asl
    asl
    asl                         // multiply by 32 (value of #$0020 to #$0320)
merge_green:
    ora $61                     // combine active green to active blue and active red
    sta ($5D),y                 // save as active RGB color
    sep #$20                    // 8-bit accumulator
    iny 
    iny                         // increase color entry
    cpy $5F                     // have we done all colors yet?
    bne next_color              // loop if not all colors are done
    tdc                         // clear accumulator
    pha               
    plb                         // set DB register to $00
    rts
}


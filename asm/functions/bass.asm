//===============================================================================
// General bass macros
// Can be used in any 65816 bass hack
//===============================================================================

//===============================================================================
// log_start
//
// write to console a string followed by the pc.
// e.g. "label_a : $C26468"
//===============================================================================
macro scope log_start(define str_message) {
    if {LOG} > 0 {
      log_offset({str_message})
    }
}

//===============================================================================
// log_end
//
// write to console the number of bytes between pc and a variable
// e.g. "size : $2000" if pc() returns $E00000 and start is a label at $DFE000
//===============================================================================
macro log_end(variable start) {
    if {LOG} > 0 {
      variable end(pc())
      log_num_bytes("size", start, end)
    }
}

//===============================================================================
// log_free_space
// write to console the number of bytes between a define and the pc
// e.g. "free : $2000" if pc() returns $DFE0000 and value is a label at $E00000
//===============================================================================
macro log_free_space(define value) {
    if {LOG} > 0 {
      variable count_end(pc())
      log_num_bytes("free space", count_end, {value})
    }
}

//===============================================================================
// log_offset
//
// write to console a message followed by the pc
//===============================================================================
macro log_offset(define str_message) {
	putchar(' ')
	putchar(' ')
	print {str_message}
    putchar(':')
	putchar(' ')
	print_pc(pc())
	putchar('\n')
}

//===============================================================================
// log_num_bytes
//
// write to console a message followed by the difference between a and b
//===============================================================================
macro log_num_bytes(define str_message, variable a, variable b) {
    variable diff(b - a)
	putchar(' ')
	putchar(' ')
	print {str_message}
    putchar(':')
	putchar(' ')
	print_number(diff)
	putchar('\n')
}

//===============================================================================
// log_var
//
// write to console a message followed by a value
//===============================================================================
macro log_var(define str_name, variable var) {
	putchar(' ')
	putchar(' ')
	print {str_name}
    putchar(':')
	putchar(' ')
	print_number(var)
	putchar('\n')
}

//===============================================================================
// print_pc
//
// print a hirom pc
//===============================================================================
macro print_pc(variable pc) {
    if pc < 0x400000 {
        evaluate pc(pc + 0xC00000)    
    }
    putchar('$')
    evaluate number((pc & 0xF00000) >> 20)
    get_char({number})
    evaluate number((pc & 0x0F0000) >> 16)
    get_char({number})
    evaluate number((pc & 0x00F000) >> 12)
    get_char({number})
    evaluate number((pc & 0x000F00) >> 8)
    get_char({number})
    evaluate number((pc & 0x0000F0) >> 4)
    get_char({number})
    evaluate number(pc & 0x00000F)
    get_char({number})
}

//===============================================================================
// print_number
//
// print an amount of bytes
// if num > 255, four chars will be used, if num <= 255, two chars will be used
//===============================================================================
macro print_number(variable num) {
    putchar('$')
    if num & 0xFF00 {
        evaluate number((num & 0xF000) >> 12)
        get_char({number})
        evaluate number((num & 0x0F00) >> 8)
        get_char({number})
        evaluate number((num & 0x00F0) >> 4)
        get_char({number})
        evaluate number(num & 0x000F)
        get_char({number})
    } else if num & 0xFF {
        evaluate number((num & 0xF0) >> 4)
        get_char({number})
        evaluate number(num & 0x0F)
        get_char({number})       
    } else if num == 0 {
        get_char(0)
        get_char(0)
    }
}

//===============================================================================
// get_char
//
// print a hex digit from a decimal digit
//===============================================================================
macro get_char(evaluate number) {
    if {number} == 0 {
        putchar('0')
    } else if {number} == 1 {
        putchar('1')
    } else if {number} == 2 {
        putchar('2')
    } else if {number} == 3 {
        putchar('3')
    } else if {number} == 4 {
        putchar('4')
    } else if {number} == 5 {
        putchar('5')
    } else if {number} == 6 {
        putchar('6')
    } else if {number} == 7 {
        putchar('7')
    } else if {number} == 8 {
        putchar('8')
    } else if {number} == 9 {
        putchar('9')
    } else if {number} == 10 {
        putchar('A')
    } else if {number} == 11 {
        putchar('B')
    } else if {number} == 12 {
        putchar('C')
    } else if {number} == 13 {
        putchar('D')
    } else if {number} == 14 {
        putchar('E')
    } else if {number} == 15 {
        putchar('F')
    }
}

//===============================================================================
// seek
//
// set an offset as assembling base
//===============================================================================
macro seek(variable offset) {
  origin (offset & $3FFFFF)
  base offset
}

//===============================================================================
// 8_bit_a
//
// set accumulator to 8-bit
//===============================================================================
macro 8_bit_a() {
	sep #$20
}

//===============================================================================
// 8_bit_x
//
// set indexes to 8-bit
//===============================================================================
macro 8_bit_x() {
	sep #$10
}

//===============================================================================
// 8_bit_ax
//
// set accumulator to 8-bit and set indexes to 8-bit
//===============================================================================
macro 8_bit_ax() {
	sep #$30
}

//===============================================================================
// 16_bit_a
//
// set accumulator to 16-bit
//===============================================================================
macro 16_bit_a() {
	rep #$20
}

//===============================================================================
// 16_bit_x
//
// set indexes to 16-bit
//===============================================================================
macro 16_bit_x() {
	rep #$10
}

//===============================================================================
// 16_bit_ax
//
// set accumulator to 16-bit and set indexes to 16-bit
//===============================================================================
macro 16_bit_ax() {
	rep #$30
}
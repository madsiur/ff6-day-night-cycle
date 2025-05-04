//---------------------------------------------------------------------
// various bass functions
// can be used with any bass hack
//---------------------------------------------------------------------

//=======================================
// logStart
//
// write to console a string 
//=======================================
macro scope logStart(define strMessage) {
if {CONST_LOG} > 0 {
      logOffset({strMessage})
    }
}

//=======================================
// logEnd
//
// write to console the number of bytes 
//=======================================
macro logEnd(variable start) {
if {CONST_LOG} > 0 {
      variable end(pc())
      logNumBytes("size", start, end)
    }
}

//=======================================
// logStartFree
//
// write to console a string 
//=======================================
macro scope logStartFree(define strMessage) {
if {CONST_LOG} > 0 {
      logOffset({strMessage})
    }
}

//=======================================
// logEndFree
//
// write to console the number of byte
//=======================================
macro logEndFree(define value) {
if {CONST_LOG} > 0 {
      variable count_end(pc())
      logNumBytes("free", count_end, {value})
    }
}

//=======================================
// logOffset
//
// write to console an offset
//=======================================
macro log_offset(define strMessage) {
	putchar(' ')
	putchar(' ')
	print {strMessage}
   putchar(':')
	putchar(' ')
	printPC(pc())
	putchar('\n')
}

//=======================================
// logNumBytes
//
// write to console the number of byte
//=======================================
macro log_num_bytes(define strMessage, variable a, variable b) {
   variable diff(b - a)
	putchar(' ')
	putchar(' ')
	print {strMessage}
   putchar(':')
	putchar(' ')
	printNum(diff)
	putchar('\n')
}

//=======================================
// printPC
//
// print a hirom offset
//=======================================
macro printPC(variable pc) {
    if pc < 0x400000 {
        evaluate pc(pc + 0xC00000)    
    }
    putchar('$')
    evaluate number((pc & 0xF00000) >> 20)
    getChar({number})
    evaluate number((pc & 0x0F0000) >> 16)
    getChar({number})
    evaluate number((pc & 0x00F000) >> 12)
    getChar({number})
    evaluate number((pc & 0x000F00) >> 8)
    getChar({number})
    evaluate number((pc & 0x0000F0) >> 4)
    getChar({number})
    evaluate number(pc & 0x00000F)
    getChar({number})
}

//=======================================
// printNum
//
// print an amount of bytes
//=======================================
macro printNum(variable num) {
    putchar('$')
    evaluate number((num & 0xF000) >> 12)
    getChar({number})
    evaluate number((num & 0x0F00) >> 8)
    getChar({number})
    evaluate number((num & 0x00F0) >> 4)
    getChar({number})
    evaluate number(num & 0x000F)
    getChar({number})
}

//=======================================
// getChar
//
// print a number char from a number
//=======================================
macro getChar(evaluate number) {
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

//=======================================
// seek
//
// set an offset as assembling base
//=======================================
macro seek(variable offset) {
  origin (offset & $3FFFFF)
  base offset
}

//=======================================
// setBattleTable
//
// create the battle table
//=======================================
macro setBattleTable() {
   //map ' ', 0x00, 0
   map 'A', 0x80, 26
   map 'a', 0x9A, 26
   map '0', 0xB4, 10
   map '!', 0xBE, 0
   map '?', 0xBF, 0
   map ':', 0xC1, 0
   map '\d', 0xC2, 0
   map '\s', 0xC3, 0
   map '-', 0xC4, 0
   map '.', 0xC5, 0
   map '\b', 0xC8, 0
   map '#', 0xC9, 0
   map '+', 0xCA, 0
   map '(', 0xCB, 0
   map ')', 0xCC, 0
   map '%', 0xCD, 0
   map '~', 0xCE, 0
   map '=', 0xD2, 0
   map ' ', 0xFF, 0
}

//=======================================
// clearTable
//
// clear a table
//=======================================
macro clearTable() {
   map 0, 0, 256
}

//=======================================
// longShortJumpC0
//
// fake a short jump in bank $C0
// from another bank
//=======================================
macro longShortJumpC0(variable offset) {
   phk
   per $0009
   pea long_short_jump_add_c0
   pea offset-1
   jml long_short_jump_add_c0
}

//=======================================
// longShortJumpC1
//
// fake a short jump in bank $C1
// from another bank
//=======================================
macro longShortJumpC1(variable offset) {
   phk
   per $0009
   pea long_short_jump_add_c1
   pea offset-1
   jml long_short_jump_add_c1
}

//=======================================
// longShortJumpC2
//
// fake a short jump in bank $C2
// from another bank
//=======================================
macro longShortJumpC2(variable offset) {
   phk
   per $0009
   pea long_short_jump_add_c2
   pea offset-1
   jml long_short_jump_add_c2
}

//=======================================
// longShortJumpC3
//
// fake a short jump in bank $C3
// from another bank
//=======================================
macro longShortJumpC3(variable offset) {
   phk
   per $0009
   pea long_short_jump_add_c3
   pea offset-1
   jml long_short_jump_add_c3
}

//=======================================
// 8bitAcc
//
// set accumulator to 8-bit
//=======================================
macro 8bitAcc() {
	sep #$20
}

//=======================================
// 8bitInd
//
// set indexes to 8-bit
//=======================================
macro 8bitInd() {
	sep #$10
}

//=======================================
// 8bitAccInd
//
// set accumulator to 8-bit
// set indexes to 8-bit
//=======================================
macro 8bitAccInd() {
	sep #$30
}

//=======================================
// 16bitAcc
//
// set accumulator to 16-bit
//=======================================
macro 16bitAcc() {
	rep #$20
}

//=======================================
// 16bitInd
//
// set indexes to 16-bit
//=======================================
macro 16bitInd() {
	rep #$10
}

//=======================================
// 16bitAccInd
//
// set accumulator to 16-bit
// set indexes to 16-bit
//=======================================
macro 16bitAccInd() {
	rep #$30
}
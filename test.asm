// Assembler: KickAssembler 4.4

BasicUpstart2(main)

.var vic = $0000
.var screen = vic + $0400
//.var screen_end = screen + 40 // $3e8

.var num1lo = $62
.var num1hi = $63
.var delta = $68

main:
// wait for next frame
!l:
    bit $d011
    bpl !l-
!l:
    bit $d011
    bmi !l-
    // draw next frame

    // `plot' character on screen
scr_ptr:
    inc screen
    //lda #160
//!ptr:
    //sta screen

///////// TODO check if table line entry has been completed

    // check if scr_ptr == current_line_entry
    lda scr_ptr + 1
tbl_low_ptr:
    cmp tbl_line
    bne !skip+
    lda scr_ptr + 2
tbl_high_ptr:
    cmp tbl_line + 1
    bne !skip+

    // get next table entry: update dir_ptr and tbl_low/high_ptr

    // update dir_ptr
    inc dir_ptr + 1
    bne !l+
    inc dir_ptr + 2
!l:
    // TODO if dir_ptr == 0, reset



    // tbl_low_ptr += 2, tbl_high_ptr += 2
    lda tbl_low_ptr + 1
    clc
    adc #2
    sta tbl_low_ptr + 1
    bne !l+
    inc tbl_low_ptr + 2
!l:
    lda tbl_high_ptr + 1
    clc
    adc #2
    sta tbl_high_ptr + 1
    bne !l+
    inc tbl_high_ptr + 2
!l:


    // TODO reset tbl_low_ptr/tbl_high_ptr if 0

    jmp main

!skip:

    // update screen pointer
    lda scr_ptr + 1
    sta num1lo
    lda scr_ptr + 2
    sta num1hi
dir_ptr:
    lda tbl_dir
    sta delta
    jsr adds8_16
    // store result
    lda num1lo
    sta scr_ptr + 1
    lda num1hi
    sta scr_ptr + 2

    jmp main

// screen pointer direction table
// resets when item is 0
tbl_dir:
    //.byte 40, 40, -1, -40, 0
    .byte 1, 40, -1, -40, 1, 0
    //.byte 1, 0
    // line table

// each entry determines when screen pointer changes direction
tbl_line:
    //.word screen + 4 * 40
    .word screen + 30
    .word screen + 15 * 40 + 30
    .word screen + 15 * 40
    .word screen + 4 * 40
    .word screen + 4 * 40 + 10
tbl_end:

adds8_16:
    ldx #$00 // implied high byte of delta
	lda delta // the signed 8-bit number
	bpl !l+
	dex // high byte becomes $ff to reflect negative delta
!l:
	clc
	adc num1lo // normal 16-bit addition
	sta num1lo
	txa
	adc num1hi
	sta num1hi
    rts
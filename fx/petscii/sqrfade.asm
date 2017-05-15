.pc = $0801 "Basic Upstart Program"
:BasicUpstart($0810)

.pc = $0810 "Main Program"

.const screen  = $0400
.const colram  = $d800
.const sidbase = $d400

/* init */

	// make sure we enter known processor state
	cld
	lda #%00110111 // #$37 is default memory map
	sta $1         // datasette off, I/O at $D000-$DFFF
	               // BASIC  ROM visible at $A000-$BFFF
	               // KERNAL ROM visible at $E000-$FFFF
// init
	lda #%11001000 // disable multicolor
	sta $d016
	lda #%00010101 // default memory setup
	sta $d018
	jsr clear_sid
	jsr idle
	jsr fill
	jmp done
// main
fill:
	lda #160
	// top row
	ldx #39
!loop:
toprow:
	sta screen, x
	dex
	bpl !loop-
	// bottom row
	ldx #39
!loop:
btmrow:
	sta screen + 24 * 40, x
	dex
	bpl !loop-
	ldx #$04
	jsr idle
	// update top row
	clc
	lda #40
	adc toprow + 1
	sta toprow + 1
	bcc !no_inc+
	inc toprow + 2
!no_inc:
	// update bottom row
	sec
	lda btmrow + 1
	sbc #40
	sta btmrow + 1
	bcs !no_dec+
	dec btmrow + 2
!no_dec:
	dec fill_y
	beq !done+
	jmp fill
!done:
	rts
fill_y:
	.byte 13

done:
	inc $d020
	jmp done

idle:
!wait:
	bit $d011
	bmi !wait-
!wait:
	bit $d011
	bpl !wait-
	dex
	bpl idle
	rts

clear_sid:
	lda #0
	ldx #$1c
!loop:
	sta sidbase, x
	dex
	bpl !loop-
	rts

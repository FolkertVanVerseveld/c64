.pc = $0801 "Basic Upstart Program"
:BasicUpstart($0810)

.pc = $0810 "Main Program"

.const screen = $0400
.const colram = $d800
.const vicbase = $d000
.const sidbase = $d400

// breakout effect

	// make sure we enter known processor state
	cld            // disable decimal mode
	lda #%00110110 // setup processor port and
	sta $1         // enable read access from ram
	               // at $A000-$BFFF and $E000-$FFFF
// TODO ensure correct case
	lda #%11001000 // disable multicolor
	sta $d016      //
	jsr clear_sid

	jsr dot_move
	jsr dot_draw

!loop:
	jmp !loop-

dot_draw:
	lda dot_pos
	sta !scrptr+ + 1
	lda dot_pos  + 1
	sta !scrptr+ + 2
	lda #'*'
!scrptr:
	sta screen
	rts

dot_move:
	// load move vector
	ldy dot_dir
// http://www.codebase64.org/doku.php?id=base:signed_8bit_16bit_addition
	ldx #$00
	// load delta
	lda dot_dtbl, y
	bpl !plus+
	dex
!plus:
	clc
	adc dot_pos
	sta dot_pos
	txa
	adc dot_pos + 1
	sta dot_pos + 1
	rts

//	clc             // add lower byte
//	adc dot_pos     // of pos to vector
//	sta dot_pos     // store lower byte
//	lda dot_pos + 1 // load high byte of pos
//	adc #0
//	sta dot_pos + 1
//	rts

//	bmi dec_high
//	bpl inc_high
//	// do nothing
//	rts
//dec_high:
//	dec dot_pos + 1 // decrement high byte
//	rts
//inc_high:
//	inc dot_pos + 1 // increment high byte
//	rts

//	adc #0          // add carry to high byte
//	sta dot_pos + 1
//	rts

// dot data
dot_pos:
	.word screen + 1 * 40 + 2
dot_dir:
	.byte 0
dot_dtbl:
	.byte 41, 39, -41, -39

// zero sid registers
clear_sid:
	lda #0
	ldx #$1c
!loop:
	sta sidbase, x
	dex
	bpl !loop-
	rts

/*
// unused stuff
// restore processor port
restore:
	lda #%00110111
	sta $1
// wait forever
!loop:
	brk
	jmp !loop-
*/

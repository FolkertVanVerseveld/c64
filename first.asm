.var brkFile = createFile("breakpoints.txt")
.macro break() {
.eval brkFile.writeln("break " + toHexString(*))
}

.pc = $0801 "Basic Upstart Program"
:BasicUpstart($0810)

.pc = $0810 "Main Program"

.const screen = $0400
.const colram = $d800
.const vicbase = $d000
.const sidbase = $d400

// breakout effect

/*******************************************/
/********* INITIALIZATION ROUTINE  *********/
/*******************************************/

	// make sure we enter known processor state
	cld            // disable decimal mode
	lda #%00110110 // setup processor port and
	sta $1         // enable read access from ram
	               // at $A000-$BFFF and $E000-$FFFF
// TODO ensure correct case
	lda #%11001000 // disable multicolor
	sta $d016      //
	jsr clear_sid
	jsr dot_save
	// fall through into kernel

/*******************************************/
/********* KERNEL DRAWING ROUTINES *********/
/*******************************************/

kernel:
	// restore dot
	ldx dot_oldch
	jsr dot_draw
	jsr dot_move
	jsr dot_save
	ldx #'*'
	jsr dot_draw
	// wait 4 frames
	ldx #$04
	jsr idle
	jmp kernel

// wait the specified number of frames
// input   : X: number of frames to wait
// destroys: NZV, X
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

/*******************************************/
/******** MOVING CHARACTER ROUTINES ********/
/*******************************************/

// save character under the moving dot
dot_save:
	// compute pointer to dot
	lda dot_pos
	sta !scrptr+ + 1
	lda dot_pos  + 1
	sta !scrptr+ + 2
!scrptr:
	lda screen
	sta dot_oldch
	rts

// draw a character at the position of the moving dot
// input: X: the character to draw
dot_draw:
	// compute pointer to dot
	lda dot_pos
	sta !scrptr+ + 1
	lda dot_pos  + 1
	sta !scrptr+ + 2
	txa
!scrptr:
	sta screen
	rts

dot_move:
	// TODO check formulas
	// determine if bottom is hit
	// compare dot_pos with $07c0
	lda dot_pos + 1
	cmp #(screen + 25 * 40) >> 8
	bcc !ignore+
	lda dot_pos
	cmp #$c0
	bcc !ignore+
	jsr flip_y
!ignore:
	// TODO check formulas
	// determine if top is hit
	// compare dot_pos with $0428
	lda dot_pos + 1
	cmp #(screen >> 8) + 1
	bcs !ignore+
	lda dot_pos
	cmp #40
	bcs !ignore+
	jsr flip_y
!ignore:
// now comes the tricky part, check if a horizontal collision has occurred
// if the dot is on the left side the least significant nibble of the lower byte is 0 or 8
	lda dot_pos
	// get lower nibble
	and #$f
	cmp #$0
	beq dot_chk_left
	cmp #$8
	beq dot_chk_left
// if the dot is on the right side the least significant nibble of the lower byte is 7 or f
	cmp #$7
	beq dot_chk_right
	cmp #$f
	beq dot_chk_right
!update:
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

// dot may or may not be at the left border
// this routine checks if it does and calls flip_x to flip the horizontal direction
dot_chk_left:
	lda dot_pos + 1
	sec
	sbc #3
	clc
	rol
	rol
	rol
	tay
	ldx #7
!loop:
	dey
	lda border_left_tbl, y
	cmp dot_pos
	bne !next+
	jsr flip_x
	jmp !update-
!next:
	dex
	bpl !loop-
	jmp !update-

// dot may or may not be at the left border
// this routine checks if it does and calls flip_x to flip the horizontal direction
// NOTE it is the same as dot_chk_left except for the line marked with `<-'
dot_chk_right:
	lda dot_pos + 1
	sec
	sbc #3
	clc
	rol
	rol
	rol
	tay
	ldx #7
!loop:
	dey
	lda border_right_tbl, y // <-
	cmp dot_pos
	bne !next+
	jsr flip_x
	jmp !update-
!next:
	dex
	bpl !loop-
	jmp !update-

flip_y:
	ldx dot_dir
	lda flip_y_tbl, x
	sta dot_dir
	rts

flip_x:
	ldx dot_dir
	lda flip_x_tbl, x
	sta dot_dir
	rts

// dot data
// NOTE dot cannot start next to a border because it may change the
//      direction in such a way that it will move out of the screen!
dot_pos:
	.word screen + 41 + 40 * (random() * 20) + random() * 40
dot_dir:
	.byte random() * 4
dot_oldch:
	.byte ' '
// read-only data
// dot delta table
// a dot can only move diagonally
// a screen row is 40 characters, so 40 + 1 results in (x + 1, y + 1)

// all directions:
//  0    1    2    3
// \      /  +-    -+
//  \|  |/   |\    /|
//  -+  +-     \  /
//
dot_dtbl:
	.byte 41, 39, -41, -39
flip_y_tbl:
	.byte 3, 2, 1, 0
flip_x_tbl:
	.byte 1, 0, 3, 2
// make sure each row is exactly 8 bytes, this makes it
// easier to lookup. some rows have bytes that are repeated
// at the end to compensate this.
border_left_tbl:
	.byte $00, $28, $50, $78, $A0, $C8, $F0, $F0
	.byte $18, $40, $68, $90, $B8, $E0, $E0, $E0
	.byte $08, $30, $58, $80, $A8, $D0, $F8, $F8
	.byte $20, $48, $70, $98, $C0, $C0, $C0, $C0
border_right_tbl:
	.byte $27, $4F, $77, $9F, $C7, $EF, $EF, $EF
	.byte $17, $3F, $67, $8F, $B7, $DF, $DF, $DF
	.byte $07, $2F, $57, $7F, $A7, $CF, $F7, $F7
	.byte $1F, $47, $6F, $97, $BF, $E7, $E7, $E7

// zero sid registers
clear_sid:
	lda #0
	ldx #$1c
!loop:
	sta sidbase, x
	dex
	bpl !loop-
	rts

.const screen = $0400
.const fillrow = screen + 40
.const dot_array_count = 6
.const crack_count = 12

breakout_init:
	// make sure we enter known processor state
	cld            // disable decimal mode
	lda #%00110110 // setup processor port and
	sta $1         // enable read access from ram
	               // at $A000-$BFFF and $E000-$FFFF
// TODO ensure correct case
	lda #%11001000 // disable multicolor
	sta $d016      //
	jsr clear_sid
	rts

	// check if row contains non-space characters
	// excluding first and last column
	ldx #37
	ldy #38
!loop:
	lda fillrow + 1, x
	cmp #' '
	bne !next+
	dey
!next:
	dex
	bpl !loop-
	tya
	bne !ignore+
	// place * in center
	lda #'*'
	sta fillrow + 19
	sta fillrow + 20
!ignore:
	jsr fill
	// fall through into breakout_kernel

/*******************************************/
/********* KERNEL DRAWING ROUTINES *********/
/*******************************************/

breakout_kernel:
	lda #0
	sta dot_index
!loop:
	ldx dot_index
	// load dot
	lda dot_array_posl, x
	sta dot_pos
	lda dot_array_posh, x
	sta dot_pos + 1
	lda dot_array_dir, x
	sta dot_dir
	lda dot_array_oldch, x
	sta dot_oldch
	lda dot_array_ch, x
	sta dot_ch
	// update dot
	jsr dot_logic
	// store dot
	ldx dot_index
	lda dot_pos
	sta dot_array_posl, x
	lda dot_pos + 1
	sta dot_array_posh, x
	lda dot_dir
	sta dot_array_dir, x
	lda dot_oldch
	sta dot_array_oldch, x
	lda dot_ch
	sta dot_array_ch, x
	// goto next dot
	inx
	stx dot_index
	cpx #dot_array_count
	bne !loop-
	// wait 1 frame
	ldx #$01
	jsr idle
	// increment timer
	inc breakout_kernel_timer
	beq nuke_dots
	jmp breakout_kernel
nuke_dots:
	// assume dot_index == dot_array_count
	dec dot_index
!loop:
	ldy dot_index
	ldx dot_array_oldch, y
	jsr dot_draw
	dec dot_index
	bpl !loop-
// create crack
crack_loop:
	ldy crack_index
	// compute pointer to character
	lda crack_tbl_low, y
	sta !ldptr+ + 1
	lda crack_tbl_high, y
	sta !ldptr+ + 2
////////////////////////////////////////////
// Add delta from crack_delta_tbl to stptr
	ldx #$00
	lda crack_delta_tbl, y
	bpl !plus+
	dex
!plus:
	clc
	adc crack_tbl_low, y
	sta crack_tbl_low, y
	txa
	adc crack_tbl_high, y
	sta crack_tbl_high, y
////////////////////////////////////////////
	// compute pointer to destination
	lda crack_tbl_low, y
	sta !stptr+ + 1
	lda crack_tbl_high, y
	sta !stptr+ + 2
!ldptr:
	lda screen
!stptr:
	sta screen
	ldx #$08
	jsr idle
	inc crack_index
	lda crack_index
	cmp #12
	bne crack_loop
hang:
	jmp hang
crack_index:
	.byte 0
crack_tbl_low:
	.byte $12, $8b, $04, $7d, $7d, $7d, $6b, $e2, $e2, $5b, $ac, $ac
crack_tbl_high:
	.byte   4,   4,   5,   5,   5,   5,   6,   6,   6,   7,   7,   7
crack_delta_tbl:
	.byte  41, -40,  41, -40,  40,  80,  40, -40,  40, -40, -40,  40
dot_index:
	.byte 0
breakout_kernel_timer:
	.byte $40

dot_logic:
	// restore dot
	// Does not work if multiple dots are overlapping.
	// I tried to fix it at first, but then I had changed my mind
	// and thought that I could use it for a simple crack effect
	ldx dot_oldch
	jsr dot_draw
	// ^^^ see comment above ^^^
	jsr dot_move
	jsr dot_save
	ldx dot_ch
	jsr dot_draw
	rts

fill:
	// search for first non-space character excluding first column
	ldx #1
!loop:
	lda fillrow, x
	cmp #' '
	bne !store+
	inx
	cpx #40
	bne !loop-
!store:
	stx fill_start
	sta fill_start_ch
	// search for last non-space character excluding last column
	ldx #39
!loop:
	lda fillrow, x
	cmp #' '
	bne !store+
	dex
	bne !loop-
!store:
	stx fill_end
	sta fill_end_ch
fill_kernel:
	// Y keeps track if left and right are filled
	ldy #0
	// fill left
	ldx fill_start
	beq !ignore+
	lda fill_start_ch
	sta fillrow, x
	dec fill_start
	dey
!ignore:
	iny
	// fill right
	ldx fill_end
	cpx #38
	beq !ignore+
	lda fill_end_ch
	sta fillrow, x
	inc fill_end
	dey
!ignore:
	iny
	// wait 8 frames
	ldx #$08
	jsr idle
	cpy #2           // if left and right are not filled yet
	bne fill_kernel  // continue fill_kernel
	// setup dot_array
	ldx #dot_array_count / 2
!loop:
	lda fillrow + 1, x
	sta dot_array_ch, x
	dex
	bpl !loop-
	ldx #dot_array_count / 2
!loop:
	lda fillrow + 38 - dot_array_count / 2 - 1, x
	sta dot_array_ch + dot_array_count / 2, x
	dex
	bpl !loop-
	rts

fill_start:
	.byte 0
fill_start_ch:
	.byte '*'
fill_end:
	.byte 0
fill_end_ch:
	.byte '*'

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
// Add delta from dot_dtbl to dot_pos. See also:
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

// dot may or may not be at the right border
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
	.word fillrow + 1
dot_dir:
	.byte random() * 4
dot_oldch:
	.byte ' '
dot_ch:
	.byte '@'
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

dot_array_posl:
.for (var i = 0; i < dot_array_count / 2; i++) {
	.byte (fillrow + i + 1) & $ff
}
.for (var i = 0; i < dot_array_count / 2; i++) {
	.byte (fillrow + 38 - i - 1) & $ff
}
dot_array_posh:
.for (var i = 0; i < dot_array_count; i++) {
	.byte (fillrow + i + 1) >> 8
}
dot_array_dir:
.for (var i = 0; i < dot_array_count; i++) {
	.byte mod(i, 4)
}
dot_array_oldch:
.for (var i = 0; i < dot_array_count; i++) {
	.byte ' '
}
dot_array_ch:
.for (var i = 0; i < dot_array_count; i++) {
	.byte '@'
}

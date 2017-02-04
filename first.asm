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

// drawing kernel
kernel:
	// restore dot
	ldx dot_oldch
	jsr dot_draw
	jsr dot_move
	jsr dot_save
	ldx #'*'
	jsr dot_draw
	ldx #$04
	jsr idle
	jmp kernel

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

// wait the specified number of frames
// X: number of frames to wait
// destroys: NZV, X
idle:
!wait:
	bit $d011
	bpl !wait-
!wait:
	bit $d011
	bmi !wait-
	dex
	bpl idle
	rts

dot_move:
	// determine if bottom is hit
	lda dot_pos + 1
	cmp #(screen + 25 * 40) >> 8
	bcc !ignore+
	lda dot_pos
	cmp #$c0
	bcc !ignore+
	jsr flip_y
!ignore:
	// determine if top is hit
	lda dot_pos + 1
	cmp #(screen >> 8) + 1
	bcs !ignore+
	lda dot_pos
	cmp #40
	bcs !ignore+
	jsr flip_y
!ignore:
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

flip_y:
	ldx dot_dir
	lda flip_y_tbl, x
	sta dot_dir
	rts

// dot data
dot_pos:
	.word screen + random() * 100
dot_dir:
	.byte random() * 4
dot_oldch:
	.byte ' '
// read-only data
dot_dtbl:
	.byte 41, 39, -41, -39
flip_y_tbl:
	.byte 3, 2, 1, 0

// zero sid registers
clear_sid:
	lda #0
	ldx #$1c
!loop:
	sta sidbase, x
	dex
	bpl !loop-
	rts

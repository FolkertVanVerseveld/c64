// converted from BASIC from the Commodore 64 Programmer's reference guide page 167
.pc = $0801 "Basic Upstart Program"
:BasicUpstart($0810)

.pc = $0810 "Main Program"

// animating dancing mouse
// it is a bit buggy in the sid kernel routine
.const delay = $60

.macro small_delay() {
	ldx #0
!t:
	inx
	cpx #delay
	bne !t-
}

	// setup sid
	lda #15
	sta $d418
	lda #220
	sta $d400
	lda #68
	sta $d401
	lda #15
	sta $d405
	lda #215
	sta $d406
	lda #120
	sta $d407
	lda #100
	sta $d408
	lda #15
	sta $d40c
	lda #215
	sta $d40d
	// clear screen
	ldx #0
!l:
	lda #' '
	sta $0400, x
	sta $0500, x
	sta $0600, x
	sta $06e8, x
	lda #2
	sta $d800, x
	inx
	bne !l-
	// clear sprite msb register
	lda #0
	sta $d010
	// enable sprite 0
	lda #1
	sta $d015
	// store pictures at $3000
	ldx #0
!l:
	lda mouse, x
	sta $3000, x
	inx
	cpx #190
	bne !l-
	// setup sprite 0
	lda #15
	sta $d027
	lda #68
	sta $d001
	// print text
	ldx #0
!l:
	lda text, x
	sta $04c8, x
	inx
	cpx #23
	bne !l-
	// vic kernel
kernel:
	// move 3 pixels at a time
	lda $d000
	clc
	adc #3
	sta $d000
	bcc sid
	lda $d010
	cmp #1
	bne !l+
	brk
!l:
	lda #1
	sta $d010
sid:
	// sid kernel
	lda sprptr
	cmp #192
	bne !l+
	lda #129
	sta $d404

	:small_delay()

	lda #128
	sta $d404
!l:
	lda sprptr
	cmp #193
	bne !l+
	lda #129
	sta $d40b

	:small_delay()

	lda #128
	sta $d40b
!l:
	// advance sprite
	inc sprptr
	lda sprptr
	cmp #195
	bne !l+
	lda #192
	sta sprptr
!l:
	// update sprite
	lda sprptr
	sta $07f8
	// vsync handling
.for (var i = 0; i < 2 * 3; i++) {
!wait:
	bit $d011
	bpl !wait-
!wait:
	bit $d011
	bmi !wait-
}
	jmp kernel
sprptr:
	.byte 192
text:
	.text "i am the dancing mouse!"
mouse:
	.byte %00011110, %00000000, %01111000
	.byte %00111111, %00000000, %11111100
	.byte %01111111, %10000001, %11111110
	.byte %01111111, %10000001, %11111110
	.byte %01111111, %10111101, %11111110
	.byte %01111111, %11111111, %11111110
	.byte %00111111, %11111111, %11111100
	.byte %00011111, %10111011, %11111000
	.byte %00000011, %10111011, %11000000
	.byte %00000001, %11111111, %10000000
	.byte %00000011, %10111101, %11000000
	.byte %00000001, %11001111, %10000000
	.byte %00000001, %11111111, %00000000
	.byte %00011111, %11111111, %00000000
	.byte %00000000, %01111100, %00000000
	.byte %00000000, %11111110, %00000000
	.byte %00000001, %11000111, %00100000
	.byte %00000011, %10000011, %11100000
	.byte %00000111, %00000001, %11000000
	.byte %00000001, %11000000, %00000000
	.byte %00000011, %11000000, %00000000
	.byte 0
	.byte %00011110, %00000000, %01111000
	.byte %00111111, %00000000, %11111100
	.byte %01111111, %10000001, %11111110
	.byte %01111111, %10000001, %11111110
	.byte %01111111, %10111101, %11111110
	.byte %01111111, %11111111, %11111110
	.byte %00111111, %11111111, %11111100
	.byte %00011111, %11011101, %11111000
	.byte %00000011, %11011101, %11000000
	.byte %00000001, %11111111, %10000000
	.byte %00000011, %11111111, %11000000
	.byte %00000001, %11000011, %10000000
	.byte %00000001, %11100111, %00000011
	.byte %00011111, %11111111, %11111111
	.byte %00000000, %01111100, %00000000
	.byte %00000000, %11111110, %00000000
	.byte %00000001, %11000111, %00000000
	.byte %00000111, %00000001, %10000000
	.byte %00000111, %00000000, %11001100
	.byte %00000001, %10000000, %01111100
	.byte %00000111, %10000000, %00111000
	.byte 0
	.byte %00011110, %00000000, %01111000
	.byte %00111111, %00000000, %11111100
	.byte %01111111, %10000001, %11111110
	.byte %01111111, %10000001, %11111110
	.byte %01111111, %10111101, %11111110
	.byte %01111111, %11111111, %11111110
	.byte %00111111, %11111111, %11111100
	.byte %00011111, %11011101, %11111000
	.byte %00000011, %11011101, %11000000
	.byte %00000001, %11111111, %10000110
	.byte %00000011, %10111101, %11001100
	.byte %00000001, %11000111, %10011000
	.byte %00000001, %11111111, %00110000
	.byte %00000001, %11111111, %11100000
	.byte %00000001, %11111100, %00000000
	.byte %00000011, %11111110, %00000000
	.byte %00000111, %00001110, %00000000
	.byte %11001100, %00001110, %00000000
	.byte %11111000, %00111000, %00000000
	.byte %01110000, %01110000, %00000000
	.byte %00000000, %00111100, %00000000
	.byte 0

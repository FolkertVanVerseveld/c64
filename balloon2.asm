// converted from BASIC from the Commodore 64 Programmer's reference guide page 147
.pc = $0801 "Basic Upstart Program"
:BasicUpstart($0810)

.pc = $0810 "Main Program"

	// enable sprites 0 through 5
	lda #63
	sta $d015
	// set background color to light blue
	lda #$e
	sta $d021
	// expand sprites 0 and 1 in both x and y
	lda #3
	sta $d017
	sta $d01d
	// update sprite pointers
	lda #192
	sta $7f8
	sta $7fa
	sta $7fc
	lda #193
	sta $7f9
	sta $7fb
	sta $7fd
	// update locations
	lda #30
	sta $d004
	lda #58
	sta $d005
	lda #65
	sta $d006
	lda #58
	sta $d007
	lda #100
	sta $d008
	lda #58
	sta $d009
	lda #100
	sta $d00a
	lda #58
	sta $d00b
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
	// print first row of text
	ldx #0
!l:
	lda text, x
	sta $040f, x
	inx
	cpx #25
	bne !l-
	// print second row of text
	ldx #0
!l:
	lda text2, x
	sta $045f, x
	inx
	cpx #20
	bne !l-
	// relocate first two sprites
	lda #100
	sta $d000
	sta $d001
	sta $d002
	sta $d003
	// update color
	lda #1
	sta $d027
	sta $d029
	sta $d02b
	lda #6
	sta $d028
	sta $d02a
	sta $d02c
	// patch sprites
	ldx #0
!l:
	lda sprites, x
	sta $3000, x
	inx
	cpx #127
	bne !l-
kernel:
	// check y flip
	lda $d001
	cmp #50
	bne !t+
	jsr yflip
!t:
	cmp #208
	bne !t+
	jsr yflip
!t:
	// check x flip
	lda $d000
	cmp #24
	bne !t+
	lda $d010
	and #1
	beq !t+
	jsr xflip
!t:
	lda $d000
	cmp #40
	bne !t+
	lda $d010
	and #1
	bne !t+
	jsr xflip
!t:
	lda $d000
	cmp #$ff
	bne !t+
	lda dx
	cmp #1
	bne !t+
	// x=-1:side=1
	lda #$ff
	sta x
	lda #3
	sta side
!t:
	lda $d000
	cmp #0
	bne !t+
	lda dx
	cmp #$ff
	bne !t+
	// x=256:side=0
	lda #0
	sta x
	lda #0
	sta side
!t:
	// adjust position
	lda x
	clc
	adc dx
	sta x
	lda y
	clc
	adc dy
	sta y
	// update position
	lda side
	sta $d010
	lda x
	sta $d000
	sta $d002
	lda y
	sta $d001
	sta $d003
	// vsync handling
!wait:
	bit $d011
	bpl !wait-
!wait:
	bit $d011
	bmi !wait-
	jmp kernel
xflip:
	lda dx
	eor #$fe
	sta dx
	rts
yflip:
	lda dy
	eor #$fe
	sta dy
	rts
x:
	.byte 100
y:
	.byte 100
dx:
	.byte 1
dy:
	.byte 1
side:
	.byte 0
text:
	.text "this is two hires sprites"
text2:
	.text "on top of each other"
sprites:
	.byte %00000000, %11111111, %00000000
	.byte %00000011, %10011001, %11000000
	.byte %00000111, %00011000, %11100000
	.byte %00000111, %00111100, %11100000
	.byte %00001110, %01111110, %01110000
	.byte %00001110, %01111110, %01110000
	.byte %00001110, %01111110, %01110000
	.byte %00000110, %01111110, %01100000
	.byte %00000111, %00111100, %11100000
	.byte %00000111, %00111100, %11100000
	.byte %00000001, %00111100, %10000000
	.byte %00000000, %10011001, %00000000
	.byte %00000000, %01011010, %00000000
	.byte %00000000, %00111100, %00000000
	.byte %00000000, %00111100, %00000000
	.byte %00000000, %00000000, %00000000
	.byte %00000000, %00000000, %00000000
	.byte %00000000, %01111110, %00000000
	.byte %00000000, %00101010, %00000000
	.byte %00000000, %01010100, %00000000
	.byte %00000000, %00101000, %00000000
	.byte %00000000, %00000000, %00000000
	.byte 0
	.byte %00000000, %01100110, %00000000
	.byte %00000000, %11100111, %00000000
	.byte %00000000, %11000011, %00000000
	.byte %00000001, %10000001, %10000000
	.byte %00000001, %10000001, %10000000
	.byte %00000001, %10000001, %10000000
	.byte %00000001, %10000001, %10000000
	.byte %00000000, %11000011, %00000000
	.byte %00000000, %11000011, %00000000
	.byte %00000100, %11000011, %00100000
	.byte %00000010, %01100110, %01000000
	.byte %00000010, %00100100, %01000000
	.byte %00000001, %00000000, %10000000
	.byte %00000001, %00000000, %10000000
	.byte %00000000, %10011001, %00000000
	.byte %00000000, %10011001, %00000000
	.byte %00000000, %00000000, %00000000
	.byte %00000000, %01010100, %00000000
	.byte %00000000, %00101010, %00000000
	.byte %00000000, %00010100, %00000000
	.byte 0

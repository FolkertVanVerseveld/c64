// converted from BASIC from the Commodore 64 Programmer's reference guide page 149
.pc = $0801 "Basic Upstart Program"
:BasicUpstart($0810)

.pc = $0810 "Main Program"

	// enable sprite 0
	lda #1
	sta $d015
	// set background color to light blue
	lda #$e
	sta $d021
	// expand sprites 0 and 1 in both x and y
	lda #1
	sta $d017
	sta $d01d
	// update sprite pointer
	lda #192
	sta $7f8
	// enable multicolor
	lda #1
	sta $d01c
	lda #7
	sta $d025
	lda #4
	sta $d026
	// relocate sprite 0
	lda #100
	sta $d000
	sta $d001
	// set sprite 0 color
	lda #2
	sta $d027
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
	// check for space
	jsr $ffe4
	cmp #$20
	bne !l+
	lda $d01c
	eor #1
	sta $d01c
!l:
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
sprites:
	.byte %01000000, %00000000, %00000001
	.byte %00010000, %10101010, %00000100
	.byte %00000110, %10101010, %10010000
	.byte %00001010, %10101010, %10100000
	.byte %00101010, %10101010, %10101000
	.byte %00101001, %01101001, %01101000
	.byte %10101001, %11101011, %01101010
	.byte %10101001, %11101011, %01101010
	.byte %10101001, %11101011, %01101010
	.byte %10101010, %10101010, %10101010
	.byte %10101010, %10101010, %10101010
	.byte %10101010, %10101010, %10101010
	.byte %10101010, %10101010, %10101010
	.byte %10100110, %10101010, %10011010
	.byte %10101001, %01010101, %01101010
	.byte %10101010, %01010101, %10101010
	.byte %00101010, %10101010, %10101000
	.byte %00001010, %10101010, %10100000
	.byte %00000001, %00000000, %01000000
	.byte %00000001, %00000000, %01000000
	.byte %00000101, %00000000, %01010000
	.byte 0

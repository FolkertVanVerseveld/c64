// converted from BASIC from the Commodore 64 Programmer's reference guide page 146
.pc = $0801 "Basic Upstart Program"
:BasicUpstart($0810)

.pc = $0810 "Main Program"

	// enable sprite 0
	lda #1
	sta $d015
	// set background color to light blue
	lda #$e
	sta $d021
	// expand sprite 0 in both x and y
	lda #1
	sta $d017
	sta $d01d
	// update sprite 0 pointer
	lda #192
	sta $7f8
	// set sprite 0 color to 1
	lda #1
	sta $d027
	ldx #0
!t:
	lda balloon, x
	sta $3000, x
	inx
	cpx #64
	bne !t-
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
	lda #1
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
	lda y
	sta $d001
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
balloon:
	.byte %00000000, %01111111, %00000000
	.byte %00000001, %11111111, %11000000
	.byte %00000011, %11111111, %11100000
	.byte %00000011, %11100111, %11100000
	.byte %00000111, %11011001, %11110000
	.byte %00000111, %11011111, %11110000
	.byte %00000111, %11011001, %11110000
	.byte %00000011, %11100111, %11100000
	.byte %00000011, %11111111, %11100000
	.byte %00000011, %11111111, %11100000
	.byte %00000010, %11111111, %10100000
	.byte %00000001, %01111111, %01000000
	.byte %00000001, %00111110, %01000000
	.byte %00000000, %10011100, %10000000
	.byte %00000000, %10011100, %10000000
	.byte %00000000, %01001001, %00000000
	.byte %00000000, %01001001, %00000000
	.byte %00000000, %00111110, %00000000
	.byte %00000000, %00111110, %00000000
	.byte %00000000, %00111110, %00000000
	.byte %00000000, %00011100, %00000000

// Assembler: KickAssembler 4.4
// Mouse is taken from programmer's reference guide
// from dancing mouse example

// My own variation just makes the sprite jump

BasicUpstart2(start)

.var vspeed_max = 8
.var ymax = 200

	* = $0810 "jump"

start:
	jsr scrclr
	jsr sprinit
	jsr irq_init
	jmp *

irq:
	asl $d019
	inc $d020
	jsr jump
	dec $d020
	pla
	tay
	pla
	tax
	pla
	rti

jump:
	// TODO jump
	lda $d001
	clc
	adc vspeed
	sta $d001

	inc vspeed
	lda $d001
	cmp #ymax

	bmi !l+

	lda #$f6
	sta vspeed
!l:
	rts

vspeed:
	.byte 1

sprinit:
	// setup sprite at $0340 (== 13 * 64)
	lda #13
	sta $07f8
	// copy sprite
	ldx #0
!l:
	lda mouse,x
	sta $0340,x
	inx
	cpx #64
	bne !l-
	// show sprite
	lda #1
	sta $d015
	sta $d027
	// move sprite
	lda #160
	sta $d001
	lda #100
	sta $d000
	lda #0
	sta $d010
	rts

scrclr:
	ldx #0
	lda #' '
!l:
	sta $0400,x
	sta $0500,x
	sta $0600,x
	sta $06e8,x
	inx
	bne !l-
	rts

#import "../irq/krnl1.asm"

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

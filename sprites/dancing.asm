// Assembler: KickAssembler 4.4
// dancing sprites

// All made by myself (except irq code)

BasicUpstart2(start)

	* = $0810 "dancing"

.function sinus(i, amplitude, center, noOfSteps) {
	.return round(center+amplitude*sin(toRadians(i*360/noOfSteps)))	
}

.function toSpritePtr(addr) {
	.return (addr&$3fff)/$40
}

start:
	jsr scrclr
	jsr sprinit
	jsr irq_init
	jmp *

sprinit:
	// setup sprite at $0340 (== 13 * 64)
	lda #12
	sta $07f8
	lda #13
	sta $07f9
	lda #14
	sta $07fa
	// copy sprites
	ldx #0
!l:
	lda m0spr,x
	sta $0300,x
	lda m1spr,x
	sta $0340,x
	lda m2spr,x
	sta $0380,x
	inx
	cpx #64
	bne !l-
	// show sprites
	lda #7
	sta $d015
	sta $d027
	sta $d028
	sta $d029
	rts

irq:
	asl $d019
	inc $d020
	jsr dance
	dec $d020
	pla
	tay
	pla
	tax
	pla
	rti

dance:
	ldx m0p
	lda sinus, x
	sta $d000
	lda sinus + $30, x
	sta $d001
	inx
	inx
	inx
	stx m0p
	ldx m1p
	lda sinus + $8, x
	sta $d002
	lda sinus + $38, x
	sta $d003
	inx
	inx
	inx
	stx m1p
	ldx m2p
	lda sinus + $10, x
	sta $d004
	lda sinus + $40, x
	sta $d005
	inx
	inx
	inx
	stx m2p
	rts

#import "../lib/scrclr.asm"
#import "../irq/krnl1.asm"

m0p:
	.byte 0
m1p:
	.byte 0
m2p:
	.byte 0

.align $100
m0spr:
	.byte %11111100, %00000000, %00111111
	.byte %10000100, %00000000, %00100001
	.byte %01000010, %00000000, %01000010
	.byte %01000010, %00000000, %01000010
	.byte %00100001, %00000000, %10000100
	.byte %00100001, %00000000, %10000100
	.byte %00010000, %10000001, %00001000
	.byte %00010000, %10000001, %00001000
	.byte %00001000, %01000010, %00010000
	.byte %00001000, %01000010, %00010000
	.byte %00000100, %00100100, %00100000
	.byte %00000100, %00011000, %00100000
	.byte %00000010, %00000000, %01000000
	.byte %00000010, %00000000, %01000000
	.byte %00000001, %00000000, %10000000
	.byte %00000001, %00000000, %10000000
	.byte %00000000, %10000001, %00000000
	.byte %00000000, %10000001, %00000000
	.byte %00000000, %01000010, %00000000
	.byte %00000000, %01000010, %00000000
	.byte %00000000, %00111100, %00000000
	.byte 0

m1spr:
	.byte %00000001, %11111111, %10000000
	.byte %00000001, %00000000, %10000000
	.byte %00000000, %10000001, %00000000
	.byte %00000000, %01000010, %00000000
	.byte %00000000, %01000010, %00000000
	.byte %00000000, %01000010, %00000000
	.byte %00000000, %01000010, %00000000
	.byte %00000000, %01000010, %00000000
	.byte %00000000, %01000010, %00000000
	.byte %00000000, %01000010, %00000000
	.byte %00000000, %01000010, %00000000
	.byte %00000000, %01000010, %00000000
	.byte %00000000, %01000010, %00000000
	.byte %00000000, %01000010, %00000000
	.byte %00000000, %01000010, %00000000
	.byte %00000000, %01000010, %00000000
	.byte %00000000, %01000010, %00000000
	.byte %00000000, %01000010, %00000000
	.byte %00000000, %10000001, %00000000
	.byte %00000001, %00000000, %10000000
	.byte %00000001, %11111111, %10000000
	.byte 0

m2spr:
	.byte %00000000, %11111111, %00000000
	.byte %00000001, %00000000, %10000000
	.byte %00000010, %00000000, %01000000
	.byte %00000100, %00000000, %00100000
	.byte %00000100, %01111110, %00100000
	.byte %00001000, %10000001, %00010000
	.byte %00001000, %10000001, %00010000
	.byte %00001001, %00000000, %10010000
	.byte %00010001, %00000000, %10001000
	.byte %00010001, %11111111, %10001000
	.byte %00010000, %00000000, %00001000
	.byte %00010000, %00000000, %00001000
	.byte %00010000, %00000000, %00001000
	.byte %00010001, %11111111, %10001000
	.byte %00010001, %00000000, %10001000
	.byte %00010001, %00000000, %10001000
	.byte %00010001, %00000000, %10001000
	.byte %00010001, %00000000, %10001000
	.byte %00010001, %00000000, %10001000
	.byte %00010001, %00000000, %10001000
	.byte %00011111, %00000000, %11111000
	.byte 0

.align $100

sinus:
	// <- The fill functions takes two argument. 
	.fill $100, round($90 + $40 * sin(toRadians(i * 360 / $100)))
	// The number of bytes to fill and an expression to execute for each
	// byte. 'i' is the byte number 
	//<- Its easier to use a function when you use the expression many times			
	//.fill $100, sinus(i, $40, $90, $100)

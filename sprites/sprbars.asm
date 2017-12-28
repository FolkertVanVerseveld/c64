// Assembler: KickAssembler 4.4
// taken from programmer's reference guide page 142

BasicUpstart2(start)

	* = $0810 "sprbars"
start:
	jsr scrclr
	// set sprite ptr
	lda #13
	sta $07f8
	// make sprite
	lda #129
	ldx #64
!l:
	dex
	sta $0340,x
	bne !l-
	// show sprite
	lda #1
	sta $d015
	sta $d027
	// move sprite
	lda #100
	sta $d001
	lda #100
	sta $d000
	lda #0
	sta $d010
	jsr irq_init
!l:
	inc $d020
	jmp !l-

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

scroll:
	inc $d000
	bne !l+
	lda $d010
	eor #$01
	sta $d010
!l:
	rts

#import "../irq/krnl1.asm"

irq:
	asl $d019
	inc $d020
	jsr scroll
	dec $d020
	pla
	tay
	pla
	tax
	pla
	rti

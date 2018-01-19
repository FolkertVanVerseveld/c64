// Assembler: KickAssembler v4.4
// Copyright Folkert van Verseveld

// All code is made by myself
// Print routines thrash A, and putbyte also thrashes X.
// Code could be made more efficient, but this is more compact.

BasicUpstart2(start)

.var screen = $0400

start:
	// just dump some text to test print routines
	jsr puts
	ldx #0
!l:
	txa
	jsr putnyb
	inx
	cpx #$10
	bne !l-
	lda #$ea
	jsr putbyte
	// just show the program is still running
!l:
	inc $d020
	jmp !l-

puts:
!fetch:
	lda text
	cmp #$ff
	beq !done+
	inc !fetch- + 1
	bne !l+
	inc !fetch- + 2
!l:
	jsr putchar
	jmp !fetch-
!done:
	rts
putbyte:
	tax
	lsr
	lsr
	lsr
	lsr
	jsr putnyb
	txa
	// fall through
putnyb:
	and #$f
	clc
	adc #'0'
	cmp #'0' + 10
	bmi !l+
	adc #'a' - '0' - 10 - 1
!l:
	// fall through
putchar:
!put:
	sta screen
	inc !put- + 1
	bne !l+
	inc !put- + 2
!l:
	rts

text:
	.text "hallo"
	.byte $ff

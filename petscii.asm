// Assembler: KickAssembler v4.19

BasicUpstart2(main)

.var vic = $0000
.var screen = vic + $0400

main:
	ldx #0
	lda #' '
!l:
	sta screen + 0 * $100, x
	sta screen + 1 * $100, x
	sta screen + 2 * $100, x
	sta screen + 3 * $0e8, x
	inx
	bne !l-

	ldx #0
!l:
	lda top, x
	sta screen + 0 * 40 + 2, x
	txa
	sta screen + 2 * 40 + 2, x
	clc
	adc #16
	sta screen + 3 * 40 + 2, x
	adc #16
	sta screen + 4 * 40 + 2, x
	adc #16
	sta screen + 5 * 40 + 2, x
	adc #16
	sta screen + 6 * 40 + 2, x
	adc #16
	sta screen + 7 * 40 + 2, x
	adc #16
	sta screen + 8 * 40 + 2, x
	adc #16
	sta screen + 9 * 40 + 2, x
	adc #16
	sta screen + 10 * 40 + 2, x
	adc #16
	sta screen + 11 * 40 + 2, x
	adc #16
	sta screen + 12 * 40 + 2, x
	adc #16
	sta screen + 13 * 40 + 2, x
	adc #16
	sta screen + 14 * 40 + 2, x
	adc #16
	sta screen + 15 * 40 + 2, x
	adc #16
	sta screen + 16 * 40 + 2, x
	adc #16
	sta screen + 17 * 40 + 2, x
	inx
	cpx #16
	bne !l-
	ldx #0
!l:
	lda top, x
!put:
	sta screen + 2 * 40
	clc
	lda !put- + 1
	adc #40
	sta !put- + 1
	bcc !skip+
	inc !put- + 2
!skip:
	inx
	cpx #16
	bne !l-
	jmp *

top:
	.text "0123456789abcdef"

BasicUpstart2(main)

main:
	ldx #$00
!l:
	txa
	sta $0400, x
	sta $d800, x
	inx
	cpx #16
	bne !l-
	jmp *

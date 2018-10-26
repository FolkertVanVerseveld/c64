// Assembler: KickAssembler v4.19

BasicUpstart2(main)

main:
	jsr clear

	lda #<str
	ldx #>str
	jsr puts

	lda #'!'
	jsr putchar

	jmp *

clear:
	lda #' '
	ldx #0
!l:
	sta $0400, x
	sta $0500, x
	sta $0600, x
	sta $06e8, x
	inx
	bne !l-
	rts

putchar:
!ptr:
	sta $0400
	inc !ptr- + 1
	bne !l+
	inc !ptr- + 2
!l:
	rts

puts:
	sta !fetch+ + 1
	stx !fetch+ + 2
!fetch:
	lda $0400
	cmp #$ff
	beq !done+
	jsr putchar
	inc !fetch- + 1
	bne !l+
	inc !fetch- + 2
!l:
	jmp !fetch-
!done:
	rts

str:
	.text "simpele puts en putchar. mooi"
	.byte $ff

// Assembler: KickAssembler
// Rasterbars source
// source: http://codebase64.org/doku.php?id=base:rasterbars_source

BasicUpstart2(start)

	* = $0810 "start"
start:
	sei

	lda #$00
	sta $d011
	sta $d020

main:
	ldy #$7a
	ldx #$00
loop:
	lda colors, x
	cpy $d012
	bne * - 3

	sta $d020

	cpx #51
	beq main

	inx
	iny

	jmp loop

colors:
	.byte $06, $06, $06, $0e, $06, $0e
	.byte $0e, $06, $0e, $0e, $0e, $03
	.byte $0e, $03, $03, $0e, $03, $03
	.byte $03, $01, $03, $01, $01, $03
	.byte $01, $01, $01, $03, $01, $01
	.byte $03, $01, $03, $03, $03, $0e
	.byte $03, $03, $0e, $03, $0e, $0e
	.byte $0e, $06, $0e, $0e, $06, $0e
	.byte $06, $06, $06, $00, $00, $00

	.byte $ff

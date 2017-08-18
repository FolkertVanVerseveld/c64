// Assembler: KickAssembler
// Rasterbars met behulp van een interrupt service routine

BasicUpstart2(start)

.var scr_clear_char = ' '
.var scr_clear_color = $0f

.var raster = 40

	* = $0810 "start"
start:
	jsr scr_clear
	lda #$00
	sta $d020
	sta $d021
	jsr irq_init
	jmp *

irq:
	asl $d019
	// BEGIN kernel
	inc $d020
	dec $d020

	// wacht even
	ldx #$00
!l:
	dex
	bne !l-

	lda $d011
	sta !herstel+ + 1
	lda #$00
	sta $d011
	sta $d020
	ldy #$7a
	ldx #$00
!l:
	lda colors, x
	cpy $d012
	bne * - 3
	sta $d020
	sta $d021
	cpx #51
	beq !done+
	inx
	iny
	jmp !l-
!done:
!herstel:
	lda #$00
	sta $d011

	// EIND kernel
	pla
	tay
	pla
	tax
	pla
	rti

irq_init:
	sei
	lda #<irq
	sta $0314
	lda #>irq
	sta $0315
	asl $d019
	lda #$7b
	sta $dc0d
	lda #$81
	sta $d01a
	lda #$1b
	sta $d011
	lda #raster
	sta $d012
	cli
	rts

scr_clear:
	lda #scr_clear_char
	ldx #0
	// `wis' alle karakters door alles te vullen met spaties
!l:
	sta $0400, x
	sta $0500, x
	sta $0600, x
	sta $06e8, x
	inx
	bne !l-
	// verander kleur van alle karakters
	lda #scr_clear_color
	ldx #0
!l:
	sta $d800, x
	sta $d900, x
	sta $da00, x
	sta $dae8, x
	inx
	bne !l-
	rts

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

// Assembler: KickAssembler 4.4
// dancing sprites

// All made by myself (except irq code)

BasicUpstart2(start)

.var irq_line = $10
.var spr_data = $2000

.var top_textptr = $0400
.var top_colptr = $d800

	* = $0810 "multifx"

start:
	jsr scrclr
	jsr top_init
	jsr spr_init
	jsr irq_init
	// it's showtime!
	lda #0
	sta $d020
	sta $d021
	jmp *

top_init:
	ldx #0
!l:
	lda !tbl+, x
	sta top_colptr, x
	inx
	cpx #40
	bne !l-
	rts

!tbl:
	.byte 11, 11, 12, 15
	.byte 1, 1, 1, 1, 1, 3, 14, 6

	.byte 14, 3, 1, 1, 1, 3, 14, 6
	.byte 6, 14, 3, 1, 1, 1, 3, 14
	
	.byte 6, 14, 3, 1, 1, 1, 1, 1
	.byte 15, 12, 11, 11

spr_init:
	// setup sprite at $0340 (== 13 * 64)
	lda #(spr_data + 64 * 0) / 64
	sta $07f8
	lda #(spr_data + 64 * 1) / 64
	sta $07f9
	lda #(spr_data + 64 * 2) / 64
	sta $07fa
	lda #(spr_data + 64 * 3) / 64
	sta $07fb
	lda #(spr_data + 64 * 3) / 64
	sta $07fc
	// copy sprites
	ldx #0
!l:
	lda m0spr, x
	sta spr_data + 64 * 0, x
	lda m1spr, x
	sta spr_data + 64 * 1, x
	lda m2spr, x
	sta spr_data + 64 * 2, x
	lda m3spr, x
	sta spr_data + 64 * 3, x
	// sprite 4 is identical to sprite 3
	inx
	cpx #64
	bne !l-
	// show sprites
	lda #$1f
	sta $d015
	lda #3
	sta $d027
	sta $d028
	sta $d029
	lda #4
	sta $d02a
	sta $d02b
	rts

irq:
	asl $d019
	//inc $d020
	jsr scroll
	jsr dance
	//dec $d020
	pla
	tay
	pla
	tax
	pla
	rti

scroll:
	// verplaats horizontaal
	lda scroll_xpos
	sec
	sbc scroll_speed
	and #$07
	sta scroll_xpos
	bcc !move+
	jmp !done+
!move:
	// verplaats alles één naar links
	ldx #$00
!l:
	lda top_textptr + 1, x
	sta top_textptr, x
	inx
	cpx #40
	bne !l-

	// haal eentje op uit de rij
!textptr:
	lda scroll_text
	cmp #$ff
	bne !nowrap+
	jsr top_restore
!nowrap:
	sta top_textptr + 39
	// werk text ptr bij
	inc !textptr- + 1
	bne !done+
	inc !textptr- + 2
!done:
	// pas horizontale verplaatsing toe
	lda #$c0
	ora scroll_xpos
	sta $d016
	rts

top_restore:
	// herstel ptr
	lda #<scroll_text
	sta !textptr- + 1
	sta !ptr+ + 1
	lda #>scroll_text
	sta !textptr- + 2
	sta !ptr+ + 2
!ptr:
	lda scroll_text
	rts

dance:
	ldx m0p
	lda sinx, x
	sta $d000
	lda siny + $30, x
	sta $d001
	inx
	inx
	inx
	stx m0p
	ldx m1p
	lda sinx + $8, x
	sta $d002
	lda siny + $38, x
	sta $d003
	inx
	inx
	inx
	stx m1p
	ldx m2p
	lda sinx + $10, x
	sta $d004
	lda siny + $40, x
	sta $d005
	inx
	inx
	inx
	stx m2p
	// side sprites
	ldx m3p
	lda #40
	sta $d006
	lda siny + $40, x
	sta $d007
	inx
	inx
	inx
	inx
	stx m3p
	ldx m4p
	lda #$10
	sta $d010
	lda #44
	sta $d008
	lda siny + $40 + $80, x
	sta $d009
	inx
	inx
	inx
	inx
	stx m4p
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

irq_init:
	// zet irq done
	sei
	lda #<irq
	sta $0314
	lda #>irq
	sta $0315
	// zorg dat de irq gebruikt wordt
	asl $d019

	// geen idee wat dit precies doet
	// het zet alle interrupts eerst uit en dan
	// de volgende aan: timer a, timer b, flag pin, serial shift
	lda #$7b
	sta $dc0d

	// zet raster interrupt aan
	lda #$81
	sta $d01a

	// bit-7 van de te schrijven waarde is bit-8 van de interruptregel (hier 0)
	// tekst mode (bit-5 uit)
	// scherm aan (bit-4 aan)
	// 25 rijen (bit-3 aan)
	// y scroll = 3 (bits 0-2)
	lda #$1b
	sta $d011

	// de onderste 8-bits van de interruptregel.
	// dus: regel $80 (128)
	lda #irq_line
	sta $d012

	// vanaf nu kunnen de interrupts gevuurd worden
	cli

	rts

m0p:
	.byte 0
m1p:
	.byte 0
m2p:
	.byte 0
m3p:
	.byte 0
m4p:
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

m3spr:
	.byte %00000001, %11111100, %00000000
	.byte %00000110, %00000011, %00000000
	.byte %00001000, %00000000, %10000000
	.byte %00010000, %00111000, %01000000
	.byte %00100000, %11000110, %01000000
	.byte %00100001, %00000001, %10000000
	.byte %01000010, %00000000, %11111111
	.byte %01000010, %00000000, %10000010
	.byte %10000100, %00000000, %10000100
	.byte %10000100, %00000000, %11111000
	.byte %10000100, %00000000, %00000000
	.byte %10000100, %00000000, %11111000
	.byte %10000100, %00000000, %10000100
	.byte %01000010, %00000000, %10000010
	.byte %01000010, %00000000, %11111111
	.byte %00100001, %00000001, %10000000
	.byte %00100000, %11000110, %01000000
	.byte %00010000, %00111000, %01000000
	.byte %00001000, %00000000, %10000000
	.byte %00000110, %00000011, %00000000
	.byte %00000001, %11111100, %00000000
	.byte 0

scroll_xpos:
	.byte 0
scroll_speed:
	.byte 2
scroll_char:
	.byte 0
scroll_text:
	.text "hello under construction 17! this is methos' little compofiller. "
	.text "as always, my hardest problem on the c64 is to get started at all! "
	.text "i'm still trying to wrap my head around irqs, sprites and lots of other stuff, so this is the best i can do for now... "
	.text "greetings fly out to alcatraz, abyss connection, fairlight, fossil, genesis project, mon, prosonix, scs-trc and all other groups and sceners! "
	.byte $ff

.align $100

sinx:
	.fill $100, round($a4 + $58 * sin(toRadians(i * 360 / $100)))
	.fill $100, round($a4 + $58 * sin(toRadians(i * 360 / $100)))
siny:
	.fill $100, round($90 + $40 * sin(toRadians(i * 360 / $100)))
	.fill $100, round($90 + $40 * sin(toRadians(i * 360 / $100)))

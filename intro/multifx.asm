// Assembler: KickAssembler 4.4
// dancing sprites

// All made by myself (except irq code)

BasicUpstart2(start)

.var irq_line_top = $30
.var irq_line_bottom = $e8
.var spr_data = $2800

.var top_textptr = $0400
.var top_colptr = $d800

.var music = LoadSid("Spijkerhoek.sid")

.var debug = false

	* = $0810 "multifx"

start:
	jsr scrclr
	jsr top_init
	jsr spr_init
	lda #music.startSong - 1
	jsr music.init
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
	.byte 1, 1, 1, 1, 3, 14, 6
	.byte 14, 3, 1, 1, 1, 3, 14, 6
	.byte 6, 14, 3, 1, 1, 1, 3, 14
	.byte 6, 14, 3, 1, 1, 1, 1
	.byte 15, 12, 11, 11, 11

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

irq_bottom:
	asl $d019
	.if (debug) {
	inc $d020
	}
	jsr scroll
	jsr dance
	jsr music.play

	lda #<irq_top
	sta $0314
	lda #>irq_top
	sta $0315

	lda #irq_line_top
	sta $d012

	.if (debug) {
	dec $d020
	}
	pla
	tay
	pla
	tax
	pla
	rti

irq_top:
	asl $d019

	.if (debug) {
	inc $d020
	}

	// screen at $400, font bitmap at $3000
	lda #%00011100
	sta $d018

	lda #<irq_bottom
	sta $0314
	lda #>irq_bottom
	sta $0315

	lda #irq_line_bottom
	sta $d012

	.if (debug) {
	dec $d020
	}

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
	stx m0p
	ldx m1p
	lda sinx + $8, x
	sta $d002
	lda siny + $38, x
	sta $d003
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
	stx m2p
	// side sprites
	ldx m3p
	lda #40
	sta $d006
	lda siny2 + $40, x
	sta $d007
	inx
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
	lda siny2 + $40 + $80, x
	sta $d009
	inx
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
	lda #<irq_bottom
	sta $0314
	lda #>irq_bottom
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
	lda #irq_line_top
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
	.byte %01111110, %00000000, %01111110
	.byte %01000010, %00000000, %01000010
	.byte %01000010, %00000000, %01000010
	.byte %01000010, %00000000, %01000010
	.byte %01000010, %00000000, %01000010
	.byte %01000010, %00000000, %01000010
	.byte %01000010, %00000000, %01000010
	.byte %01000010, %00000000, %01000010
	.byte %01000010, %00000000, %01000010
	.byte %01000010, %00000000, %01000010
	.byte %01000010, %00000000, %01000010
	.byte %01000001, %00000000, %10000010
	.byte %01000001, %00000000, %10000010
	.byte %01000000, %10000001, %00000010
	.byte %01000000, %01111110, %00000010
	.byte %01000000, %00000000, %00000010
	.byte %01000000, %00000000, %00000010
	.byte %00100000, %00000000, %00000100
	.byte %00010000, %00000000, %00001000
	.byte %00001100, %00000000, %00110000
	.byte %00000011, %11111111, %11000000
	.byte 0

m1spr:
	.byte %01111110, %00000000, %01111110
	.byte %01000001, %00000000, %01000010
	.byte %01000000, %10000000, %01000010
	.byte %01000000, %01000000, %01000010
	.byte %01000000, %00100000, %01000010
	.byte %01000000, %00010000, %01000010
	.byte %01000010, %00001000, %01000010
	.byte %01000011, %00000100, %01000010
	.byte %01000010, %10000010, %01000010
	.byte %01000010, %01000001, %01000010
	.byte %01000010, %00100000, %11000010
	.byte %01000010, %00010000, %00000010
	.byte %01000010, %00001000, %00000010
	.byte %01000010, %00000100, %00000010
	.byte %01000010, %00000010, %00000010
	.byte %01000010, %00000001, %00000010
	.byte %01000010, %00000000, %10000010
	.byte %01000010, %00000000, %01000010
	.byte %01000010, %00000000, %01000010
	.byte %01000010, %00000000, %01000010
	.byte %01111110, %00000000, %01111110
	.byte 0

m2spr:
	.byte %00000000, %01111111, %00000000
	.byte %00000001, %10000000, %11000000
	.byte %00000010, %00000000, %00100000
	.byte %00000100, %00001110, %00010000
	.byte %00001000, %00110001, %10010000
	.byte %00001000, %01000000, %01100000
	.byte %00010000, %10000000, %00000000
	.byte %00010000, %10000000, %00000000
	.byte %00100001, %00000000, %00000000
	.byte %00100001, %00000000, %00000000
	.byte %00100001, %00000000, %00000000
	.byte %00100001, %00000000, %00000000
	.byte %00100001, %00000000, %00000000
	.byte %00010000, %10000000, %00000000
	.byte %00010000, %10000000, %00000000
	.byte %00001000, %01000000, %01100000
	.byte %00001000, %00110001, %10010000
	.byte %00000100, %00001110, %00010000
	.byte %00000010, %00000000, %00100000
	.byte %00000001, %10000000, %11000000
	.byte %00000000, %01111111, %00000000
	.byte 0

m3spr:
	.byte %00000001, %11111100, %00000000
	.byte %00000111, %11111111, %00000000
	.byte %00001111, %11111111, %10000000
	.byte %00011111, %11111111, %11000000
	.byte %00111111, %11000111, %11000000
	.byte %00111111, %00000001, %10000000
	.byte %01111110, %00000000, %11111111
	.byte %01111110, %00000000, %11111110
	.byte %11111100, %00000000, %11111100
	.byte %11111100, %00000000, %11111000
	.byte %11111100, %00000000, %00000000
	.byte %11111100, %00000000, %11111000
	.byte %11111100, %00000000, %11111100
	.byte %01111110, %00000000, %11111110
	.byte %01111110, %00000000, %11111111
	.byte %00111111, %00000001, %10000000
	.byte %00111111, %11000111, %11000000
	.byte %00011111, %11111111, %11000000
	.byte %00001111, %11111111, %10000000
	.byte %00000111, %11111111, %00000000
	.byte %00000001, %11111100, %00000000
	.byte 0

scroll_xpos:
	.byte 0
scroll_speed:
	.byte 2
scroll_char:
	.byte 0
scroll_text:
	.text "hello under construction 2017! this is methos' little compofiller. "
	.text "as always, my hardest problem on the c64 is to get started at all! "
	.text "i'm still trying to wrap my head around irqs, sprites and lots of other stuff, so this is the best i can do for now... "
	.text "code by methos, music by evs. "

	.text "greetings fly out to abyss connection, censor design, duncan, fairlight, fred, genesis project, miri-kat, monoceros, prosonix, scs-trc, stephan and all other groups and sceners! "
	.text "have fun and see ya in 2018! .......  ...  .. .     "
	.byte $ff

	* = music.location "music"

	.fill music.size, music.getData(i)

	.print "music_init = $" + toHexString(music.init)
	.print "music_play = $" + toHexString(music.play)

	// sprite movement tables
.align $100

sinx:
	// waveform h, min 70, max 255
	.import binary "sin2.bin"
	.import binary "sin2.bin"
siny:
	// waveform h, min 70, max 170
	.import binary "sin3.bin"
	.import binary "sin3.bin"
siny2:
	.fill $100, round($90 + $40 * sin(toRadians(i * 360 / $100)))
	.fill $100, round($90 + $40 * sin(toRadians(i * 360 / $100)))

	* = $3000 "font data"

	.import binary "aeg_collection_05.64c", 2

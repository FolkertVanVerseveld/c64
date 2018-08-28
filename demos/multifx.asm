// Assembler: KickAssembler 4.4
// dancing sprites

// All made by myself (except irq code)

BasicUpstart2(start)

.var irq_line_top = $28
.var irq_line_top2 = $3a
.var irq_line_bottom = $fc
//.var spr_data = $2800

// Update this to your HVSC directory
.var music = LoadSid("/home/methos/Music/C64Music/MUSICIANS/0-9/20CC/van_Santen_Edwin/Spijkerhoek.sid")

//set variables and locations
.var buf = $2700
.var colram = $d800

.var vic = $4000
.var bitmap = vic + 0
.var screen = vic + $2000
.var spr_data = vic + $2400
.var font = vic + $3000

.var top_textptr = screen
.var top_colptr = $d800

.var debug = false

	* = $0810 "multifx"

start:
	jsr copy_buf_to_colram
	jsr scrclr
	jsr scr_init
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
	lda #' '
	sta screen, x
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

scr_init:
	//screen (colors12) at $2000    bitmap at $0000
	lda #%10000000
	sta $d018
	// multicolor (bit 4), 40 columns (bit 3)
	lda #%00011000
	sta $d016
	// bitmap mode (bit 5), screen on (bit 4), 25 rows (bit 3)
	lda #%00111011
	sta $d011
//Bits #0-#1: VIC bank. Values:
//
//    %00, 0: Bank #3, $C000-$FFFF, 49152-65535.
//
//    %01, 1: Bank #2, $8000-$BFFF, 32768-49151.
//
//    %10, 2: Bank #1, $4000-$7FFF, 16384-32767.
//
//    %11, 3: Bank #0, $0000-$3FFF, 0-16383.
//

	sei
	lda #%00000010
	sta $dd00
	cli
	rts

spr_init:
	// setup sprite at $0340 (== 13 * 64)
	lda #(spr_data - vic + 64 * 0) / 64
	sta screen + $03f8
	lda #(spr_data - vic + 64 * 1) / 64
	sta screen + $03f9
	lda #(spr_data - vic + 64 * 2) / 64
	sta screen + $03fa
	lda #(spr_data - vic + 64 * 3) / 64
	sta screen + $03fb
	lda #(spr_data - vic + 64 * 3) / 64
	sta screen + $03fc
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
	lda #2
	sta $d027
	lda #1
	sta $d028
	lda #6
	sta $d029
	lda #6
	sta $d02a
	sta $d02b
	rts

irq_bottom:
	asl $d019
	nop
	nop
	nop
	nop
	ldx #0
!l:
	lda !tbl+, x
	sta $d020
	jsr !d+
	jsr !d+
	jsr !d+
	jsr !d+
	nop
	inx
	cpx #6
	bne !l-

	lda #0
	sta $d020

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

!tbl:
	.byte 1, 3, 1, 3, 14, 3, 14, 6

irq_top:
	asl $d019

	nop
	nop
	nop
	nop
	ldx #0
!l:
	lda !tbl+, x
	sta $d020
	jsr !d+
	jsr !d+
	jsr !d+
	jsr !d+
	nop
	inx
	cpx #6
	bne !l-

	lda #0
	sta $d020

	.if (debug) {
	inc $d020
	}

	// apply horizontal position
	lda #%11000000
	ora scroll_xpos
	sta $d016

	// text mode (bit5 = 0), screen on (bit4 = 1), 25 rows (bit3 = 1)
	lda #%00011011
	sta $d011

	// screen at $400, font bitmap at $3000
	lda #%10001100
	sta $d018

	lda #<irq_top2
	sta $0314
	lda #>irq_top2
	sta $0315

	lda #irq_line_top2
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
!d:
	rts

!tbl:
	.byte 6, 14, 3, 14, 3, 1, 3, 1

irq_top2:
	asl $d019

	.if (debug) {
	inc $d020
	}

	//screen (colors12) at $2000    bitmap at $0000
	lda #%10000000
	sta $d018
	// multicolor (bit 4), 40 columns (bit 3)
	lda #%00011000
	sta $d016
	// bitmap mode (bit 5), screen on (bit 4), 25 rows (bit 3)
	lda #%00111011
	sta $d011

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

copy_buf_to_colram:
	ldx #0
!l:
	lda buf    + 0 * 256, x
	sta colram + 0 * 256, x
	lda buf    + 1 * 256, x
	sta colram + 1 * 256, x
	lda buf    + 2 * 256, x
	sta colram + 2 * 256, x
	lda buf    + 3 * 256, x
	sta colram + 3 * 256, x
	dex
	bne !l-
	rts

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
	lda $d011
	and #%01111111
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
	.byte %00000000, %00000000, %00000000
	.byte %00111111, %11111110, %00000000
	.byte %01111111, %11111111, %10000000
	.byte %00111111, %11111111, %11000000
	.byte %00001110, %00000001, %11100000
	.byte %00001110, %00000000, %11100000
	.byte %00001110, %00000000, %11100000
	.byte %00001110, %00000000, %11100000
	.byte %00001110, %00000000, %11100000
	.byte %00001110, %00000011, %11100000
	.byte %00001111, %11111111, %11100000
	.byte %00001111, %11111111, %11000000
	.byte %00001111, %11111111, %10000000
	.byte %00001110, %00001111, %00000000
	.byte %00001110, %00000111, %10000000
	.byte %00001110, %00000011, %11000000
	.byte %00001110, %00000001, %11100000
	.byte %00111111, %11000000, %11111000
	.byte %01111111, %11000000, %01111000
	.byte %00111111, %11000000, %01111000
	.byte %00000000, %00000000, %00000000
 	.byte 0

m1spr:
	.byte %00000000, %00000000, %00000000
	.byte %00111111, %11111111, %11000000
	.byte %01111111, %11111111, %11000000
	.byte %00111111, %11111111, %11000000
	.byte %00001110, %00000001, %11000000
	.byte %00001110, %00000001, %11000000
	.byte %00001110, %00000001, %11000000
	.byte %00001110, %00000000, %11000000
	.byte %00001110, %00001100, %00000000
	.byte %00001110, %00011100, %00000000
	.byte %00001111, %11111100, %00000000
	.byte %00001111, %11111100, %00000000
	.byte %00001110, %00011100, %00000000
	.byte %00001110, %00001100, %01100000
	.byte %00001110, %00000000, %11100000
	.byte %00001110, %00000000, %11100000
	.byte %00001110, %00000000, %11100000
	.byte %00111111, %11111111, %11100000
	.byte %01111111, %11111111, %11100000
	.byte %00111111, %11111111, %11100000
	.byte %00000000, %00000000, %00000000
 	.byte 0

m2spr:
	.byte %11111100, %00000000, %00111111
	.byte %11111100, %00000000, %00111111
	.byte %01111110, %00000000, %01111110
	.byte %01111110, %00000000, %01111110
	.byte %00111111, %00000000, %11111100
	.byte %00111111, %00000000, %11111100
	.byte %00011111, %10000001, %11111000
	.byte %00011111, %10000001, %11111000
	.byte %00001111, %11000011, %11110000
	.byte %00001111, %11000011, %11110000
	.byte %00000111, %11100111, %11100000
	.byte %00000111, %11111111, %11100000
	.byte %00000011, %11111111, %11000000
	.byte %00000011, %11111111, %11000000
	.byte %00000001, %11111111, %10000000
	.byte %00000001, %11111111, %10000000
	.byte %00000000, %11111111, %00000000
	.byte %00000000, %11111111, %00000000
	.byte %00000000, %01111110, %00000000
	.byte %00000000, %01111110, %00000000
	.byte %00000000, %00111100, %00000000
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
	.text "hey daar! methos here, this is my very first demo release. "
	.text "code by methos, music by ews, graphics by jvhertum. "
	.text "in 2016, i attended my first demoscene party (x16 of course!) and i would never think i liked the demoscene this much! "
	.text "sorry for this short low quality prod, but i have to start somewhere...... "
	.text "greetings to abyss connection, admbot, algotech, booze design, byte rapers, censor design, delysid, gorgomel, hoaxers, mirikat, monoceors, odymeister, oxyron, snorro, stephan, triad, trsi, vinci, yps "
	.text "and everyone i forgot. "
	.text "i have been thinking about starting my own group, but i think it's better to join a group because i can learn faster that way and improve my coding skills. "
	.text "if you want to start a group as well or are looking for new members, hit me up! "
	.text "my email: folkert.van.verseveld at gmail.com, my phone number: 0031630479450 or you can write to me at: cornelis lelylaan 3e14 1062hd amsterdam, the netherlands    "
	.text "methos signing out because out of space, text loops now .......... ... .. . .        "
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
	// waveform k, min 70, max 170
	.import binary "sin4.bin"
	.import binary "sin4.bin"
siny2:
	.fill $100, round($90 + $40 * sin(toRadians(i * 360 / $100)))
	.fill $100, round($90 + $40 * sin(toRadians(i * 360 / $100)))

	* = font "font"

	.import binary "../assets/aeg_collection_05.64c", 2

	* = bitmap "bitmap"
	.import binary "../assets/uva.koa", 2, 8000

	* = screen "screen"
	.import binary "../assets/uva.koa", 2 + 8000, 40 * 25

	* = buf "buf"
	.import binary "../assets/uva.koa", 2 + 8000 + 40 * 25, 40 * 25

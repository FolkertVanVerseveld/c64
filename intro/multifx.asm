// Assembler: KickAssembler 4.4
// dancing sprites

// All made by myself (except irq code)

BasicUpstart2(start)

.var irq_line_top = $30
.var irq_line_top2 = $3a
.var irq_line_bottom = $e8
//.var spr_data = $2800

.var music = LoadSid("Spijkerhoek.sid")

//set variables and locations
.var colours = $2400
.var timing = $2500
.var pattern = $2600
.var buf = $2700
.var colram = $d800

.var vic = $4000
.var bitmap = vic + 0
.var screen = vic + $2000
.var spr_data = vic + $2400
.var font = vic + $3000

.var top_textptr = screen
.var top_colptr = $d800

.var debug = true

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
	jsr flash
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

flash:
	ldx #$00
colrout:
	lda colours,x	//load in our custom colours
	sta $d020
	sta $d021
	ldy timing,x	//and corresponding timing.
!loop:
	dey
	bpl !loop-
	inx
	cpx #$10      	//how many do we have? - 192
	bne colrout     //keep going otherwise..

	lda #$00        //clear
	sta $d020
	sta $d021
	rts

	ldx #$00
!loop:
	lda colours+$01,x     //store our colours
	sta colours,x
	inx
	cpx #$c0
	bne !loop-

aa:
	lda pattern+$df       // 8)
	sta colours+$08
ab:
	lda pattern+$e0       //+1
	sta colours+$10       //+8
ac:
	lda pattern+$e1       //+2
	sta colours+$18       //+8
ad:
	lda pattern+$e2       //+3
	sta colours+$20       //+8
ae:
	lda pattern+$e3       //etc
	sta colours+$28
af:
	lda pattern+$e4
	sta colours+$30
ag:
	lda pattern+$e5
	sta colours+$38
ah:
	lda pattern+$e6
	sta colours+$40
ai:
	lda pattern+$e7
	sta colours+$48
aj:
	lda pattern+$e8
	sta colours+$50
ak:
	lda pattern+$e9
	sta colours+$58
al:
	lda pattern+$ea
	sta colours+$60
am:
	lda pattern+$eb
	sta colours+$68
an:
	lda pattern+$ec
	sta colours+$70
ao:
	lda pattern+$ed
	sta colours+$78
ap:
	lda pattern+$ee
	sta colours+$80
aq:
	lda pattern+$ef
	sta colours+$88
ar:
	lda pattern+$f0
	sta colours+$90
as:
	lda pattern+$f1
	sta colours+$98
at:
	lda pattern+$f2
	sta colours+$a0
au:
	lda pattern+$f3
	sta colours+$a8
av:
	lda pattern+$f4
	sta colours+$b0
ax:
	lda pattern+$f5
	sta colours+$b8
ay:
	lda pattern+$f6
	sta colours+$c0
az:
	lda pattern+$18
	sta colours+$c8
	inc aa+$01 //increase count of each
	inc ab+$01 //line
	inc ac+$01
	inc ad+$01
	inc ae+$01
	inc af+$01
	inc ag+$01
	inc ah+$01
	inc ai+$01
	inc aj+$01
	inc ak+$01
	inc al+$01
	inc am+$01
	inc an+$01
	inc ao+$01
	inc ap+$01
	inc aq+$01
	inc ar+$01
	inc as+$01
	inc at+$01
	inc au+$01
	inc av+$01
	inc ax+$01
	inc ay+$01
	inc az+$01

	lda #0
	sta $d020
	sta $d021
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

.pc = colours "colours"
.byte $0f,$01,$01,$0f,$0f,$0c,$0c,$0b
.byte $0b,$01,$0f,$0f,$0c,$0c,$0b,$0b
.byte $00,$0f,$0f,$0c,$0c,$0b,$0b,$00
.byte $06,$0f,$0c,$0c,$0b,$0b,$00,$06
.byte $06,$0c,$0c,$0b,$0b,$00,$06,$06
.byte $0e,$0c,$0b,$0b,$00,$06,$06,$08
.byte $0e,$0b,$0b,$00,$06,$06,$0e,$0e
.byte $03,$0b,$00,$06,$06,$0e,$0e,$03
.byte $03,$00,$06,$06,$0e,$0e,$03,$03
.byte $01,$06,$06,$0e,$0e,$03,$03,$01
.byte $01,$06,$0e,$0e,$03,$03,$01,$01
.byte $0f,$0e,$0e,$03,$03,$01,$01,$0f
.byte $0f,$0e,$03,$03,$01,$01,$0f,$0f
.byte $0c,$03,$03,$01,$01,$0f,$0f,$0c
.byte $0c,$03,$01,$01,$0f,$0f,$0c,$0c
.byte $0b,$01,$01,$0f,$0f,$0c,$0c,$0b
.byte $0b,$01,$0f,$0f,$0c,$0c,$0b,$0b
.byte $00,$0f,$0f,$0c,$0c,$0b,$0b,$00
.byte $0b,$0f,$0c,$0c,$0b,$0b,$00,$0b
.byte $0b,$0c,$0c,$0b,$0b,$00,$0b,$0b
.byte $05,$0c,$0b,$0b,$00,$0b,$0b,$05
.byte $05,$0b,$0b,$00,$0b,$0b,$05,$05
.byte $03,$0b,$00,$0b,$0b,$05,$05,$03
.byte $03,$00,$0b,$0b,$05,$05,$03,$03
.byte $0d,$00,$00,$00,$00,$00,$00,$0d //25
.byte $01,$00

.pc = timing "timing"
.byte $00,07,$07,$07,$07,$07,$07,$07
.byte $00,07,$07,$07,$07,$07,$07,$07
.byte $00,07,$07,$07,$07,$07,$07,$07
.byte $00,07,$07,$07,$07,$07,$07,$07
.byte $00,07,$07,$07,$07,$07,$07,$07
.byte $00,07,$07,$07,$07,$07,$07,$07
.byte $00,07,$07,$07,$07,$07,$07,$07
.byte $00,07,$07,$07,$07,$07,$07,$07
.byte $00,07,$07,$07,$07,$07,$07,$07
.byte $00,07,$07,$07,$07,$07,$07,$07
.byte $00,07,$07,$07,$07,$07,$07,$07
.byte $00,07,$07,$07,$07,$07,$07,$07
.byte $00,07,$07,$07,$07,$07,$07,$07
.byte $00,07,$07,$07,$07,$07,$07,$07
.byte $00,07,$07,$07,$07,$07,$07,$07
.byte $00,07,$07,$07,$07,$07,$07,$07
.byte $00,07,$07,$07,$07,$07,$07,$07
.byte $00,07,$07,$07,$07,$07,$07,$07
.byte $00,07,$07,$07,$07,$07,$07,$07
.byte $00,07,$07,$07,$07,$07,$07,$07
.byte $00,07,$07,$07,$07,$07,$07,$07
.byte $00,07,$07,$07,$07,$07,$07,$07
.byte $00,07,$07,$07,$07,$07,$07,$07
.byte $00,07,$07,$07,$07,$07,$07,$07
.byte $00,07,$07,$07,$07,$07,$07,$07 //25
.byte $00,07

.pc = pattern "pattern"
.byte $06,$06,$0e,$0e,$03,$03,$0d,$0d
.byte $07,$07,$0f,$0f,$0a,$0a,$02,$02
.byte $00,$0b,$0b,$0c,$0c,$0f,$0f,$01
.byte $01,$0f,$0f,$0c,$0c,$0b,$0b,$00
.byte $06,$06,$0e,$0e,$03,$03,$01,$01
.byte $03,$03,$0e,$0e,$06,$06,$00,$06
.byte $06,$0e,$0e,$03,$03,$0d,$0d,$07
.byte $07,$0f,$0f,$0a,$0a,$02,$02,$00
.byte $06,$06,$0e,$0e,$03,$03,$01,$01
.byte $0f,$0f,$0c,$0c,$0b,$0b,$00,$0b
.byte $0b,$05,$05,$03,$03,$0d,$0d,$07
.byte $07,$03,$03,$05,$05,$0b,$0b,$00
.byte $06,$06,$0e,$0e,$03,$03,$0d,$0d
.byte $07,$07,$0f,$0f,$0a,$0a,$02,$02
.byte $00,$0b,$0b,$0c,$0c,$0f,$0f,$01
.byte $01,$0f,$0f,$0c,$0c,$0b,$0b,$00
.byte $06,$06,$0e,$0e,$03,$03,$01,$01
.byte $03,$03,$0e,$0e,$06,$06,$00,$06
.byte $06,$0e,$0e,$03,$03,$0d,$0d,$07
.byte $07,$0f,$0f,$0a,$0a,$02,$02,$00
.byte $06,$06,$0e,$0e,$03,$03,$0d,$0d
.byte $07,$07,$0f,$0f,$0a,$0a,$02,$02
.byte $00,$0b,$0b,$0c,$0c,$0f,$0f,$01
.byte $01,$0f,$0f,$0c,$0c,$0b,$0b,$00
.byte $06,$06,$0e,$0e,$03,$03,$0d,$0d
.byte $07,$07,$0f,$0f,$0a,$0a,$02,$02
.byte $00,$0b,$0b,$0c,$0c,$0f,$0f,$01
.byte $01,$0f,$0f,$0c,$0c,$0b,$0b,$00
.byte $06,$06,$0e,$0e,$03,$03,$01,$01
.byte $0f,$0f,$0c,$0c,$0b,$0b,$00,$0b
.byte $0b,$05,$05,$03,$03,$0d,$0d,$07
.byte $07,$03,$03,$05,$05,$0b,$0b,$00

	* = font "font"

	.import binary "aeg_collection_05.64c", 2

	* = bitmap "bitmap"
	.import binary "revbkg.koa", 2, 8000

	* = screen "screen"
	.import binary "revbkg.koa", 2 + 8000, 40 * 25

	* = buf "buf"
	.import binary "revbkg.koa", 2 + 8000 + 40 * 25, 40 * 25

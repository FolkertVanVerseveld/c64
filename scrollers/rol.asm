// Assembler: KickAssembler 4.4
// rollende tekst

BasicUpstart2(start)

.var scr_clear_char = ' '
.var scr_clear_color = $00

	* = $0810 "start"

.var vic = $0000

.var scherm = $0400
.var spr_data = vic + $2400

.var wis_links = scherm + 4 * 40
.var links = wis_links + 3
.var wis_rechts = scherm + 7 * 40
.var rechts = wis_rechts + 39 - 3

//.var music = LoadSid("TV_Tunes_Mix.sid")
.var music = LoadSid("Fun_Fun.sid")
//.var music = LoadSid("Alternative_Fuel.sid")

.var num1lo = $62
.var num1hi = $63
.var num2lo = $64
.var num2hi = $65
.var reslo = $66
.var reshi = $67
.var delta = $68

.var irq_line_top = $20
.var irq_line_bottom = $e0
.var irq_line_bottom2 = $20

start:
	jsr scr_clear
	lda #$03
	sta $d020
	sta $d021
	lda #music.startSong - 1
	jsr music.init
	jsr spr_init
	jsr irq_init
	jmp *

irq_init:
	// zet irq done
	sei
	lda #<irq_top
	sta $0314
	lda #>irq_top
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
	lda $d011
	and #$7F
	sta $d011

	// vanaf nu kunnen de interrupts gevuurd worden
	cli

	rts

spr_init:
	// setup sprite at $0340 (== 13 * 64)
	lda #(spr_data - vic + 64 * 0) / 64
	sta scherm + $03f8
	// copy sprites
	ldx #0
!l:
	lda m0spr, x
	sta spr_data + 64 * 0, x
	// sprite 4 is identical to sprite 3
	inx
	cpx #64
	bne !l-
	// show sprites
	lda #$01
	sta $d015
	lda #$00
	sta $d027

	lda #$70
	sta $d000
	lda #$80
	sta $d001
	rts

// add 8-bit constant to 16-bit number

add8_16:
	clc
	lda num1lo
	adc #2     // the constant
	sta num1lo
	bcc !ok+
	inc num1hi
!ok:
	rts

balon:
	ldx balon_pos
	lda sinus, x
	sta $d001
	lda sinus2, x
	sta $d000
	inc balon_pos
	inc $d020
	rts

irq_top:
	asl $d019
	// BEGIN kernel
	inc $d020
	jsr scroll
	jsr balon
	jsr music.play
	dec $d020

	lda #<irq_bottom
	sta $0314
	lda #>irq_bottom
	sta $0315

	lda #irq_line_bottom
	sta $d012

	dec $d020
	// EIND kernel
	pla
	tay
	pla
	tax
	pla
	rti

irq_bottom:
	asl $d019
	// BEGIN kernel
	nop
	nop
	nop
	nop
	nop
	nop
	lda #$05
	sta $d020
	sta $d021

	lda #<irq_bottom2
	sta $0314
	lda #>irq_bottom2
	sta $0315

	lda #irq_line_bottom2
	sta $d012
	lda $d011
	ora #$80
	sta $d011

	// EIND kernel
	pla
	tay
	pla
	tax
	pla
	rti

irq_bottom2:
	asl $d019

	lda #$03
	sta $d020
	sta $d021

	lda #<irq_top
	sta $0314
	lda #>irq_top
	sta $0315

	lda #irq_line_top
	sta $d012
	lda $d011
	and #$7f
	sta $d011

	// EIND kernel
	pla
	tay
	pla
	tax
	pla
	rti

.var stappen = 40

scroll:
	lda #$00
	bne !a+
	jmp scroll_links
!a:
	jmp scroll_rechts

scroll_links:
rol_ptr_links:
	lda regel1_links
	beq !done+
text_ptr_links:
	sta links
	// verplaats rol_ptr
	inc rol_ptr_links + 1
	bne !skip+
	inc rol_ptr_links + 2
!skip:
	// verplaats text_ptr
	inc text_ptr_links + 1
	bne !skip+
	inc text_ptr_links + 2
!skip:
	rts
	// reset rechts logic
!done:
	inc scroll + 1
tabel_ptr_rechts_lo:
	lda regel_tabel_rechts
	sta rol_ptr_rechts + 1
tabel_ptr_rechts_hi:
	lda regel_tabel_rechts + 1
	sta rol_ptr_rechts + 2
	lda #<rechts
	sta text_ptr_rechts + 1
	lda #>rechts
	sta text_ptr_rechts + 2
	// verplaats tabel ptr
	lda tabel_ptr_rechts_lo + 1
	sta num1lo
	lda tabel_ptr_rechts_lo + 2
	sta num1hi
	jsr add8_16
	lda num1lo
	sta tabel_ptr_rechts_lo + 1
	lda num1hi
	sta tabel_ptr_rechts_lo + 2
	lda tabel_ptr_rechts_hi + 1
	sta num1lo
	lda tabel_ptr_rechts_hi + 2
	sta num1hi
	jsr add8_16
	lda num1lo
	sta tabel_ptr_rechts_hi + 1
	lda num1hi
	sta tabel_ptr_rechts_hi + 2
	// reset als eind
	lda tabel_ptr_rechts_lo + 1
	cmp #<regel_tabel_rechts_eind
	bne !skip+
	lda tabel_ptr_rechts_lo + 2
	cmp #>regel_tabel_rechts_eind
	bne !skip+
	// reset ptr
	lda #<regel_tabel_rechts
	sta tabel_ptr_rechts_lo + 1
	lda #>regel_tabel_rechts
	sta tabel_ptr_rechts_lo + 2
	lda #<regel_tabel_rechts + 1
	sta tabel_ptr_rechts_hi + 1
	lda #>regel_tabel_rechts + 1
	sta tabel_ptr_rechts_hi + 2
!skip:
	rts

scroll_rechts:
rol_ptr_rechts:
	lda regel2_rechts
	beq !done+
text_ptr_rechts:
	sta rechts
	// verplaats rol_ptr
	dec rol_ptr_rechts + 1
	lda rol_ptr_rechts + 1
	cmp #$ff
	bne !skip+
	dec rol_ptr_rechts + 2
!skip:
	// verplaats text_ptr
	dec text_ptr_rechts + 1
	lda text_ptr_rechts + 1
	cmp #$ff
	bne !skip+
	dec text_ptr_rechts + 2
!skip:
	rts
	// reset links logic
!done:
	// maak vertraging...
teller:
	lda #stappen
	beq !skip+
	dec teller + 1
	rts
!skip:
	lda #stappen
	sta teller + 1

	// ik wil het eigenlijk anders doen,
	// maar wis beide regels
	lda #' '
	ldx #0
!l:
	sta wis_links, x
	sta wis_rechts, x
	inx
	cpx #40
	bne !l-
	//inc $d020
	dec scroll + 1
tabel_ptr_links_lo:
	lda regel_tabel_links
	sta rol_ptr_links + 1
tabel_ptr_links_hi:
	lda regel_tabel_links + 1
	sta rol_ptr_links + 2
	lda #<links
	sta text_ptr_links + 1
	lda #>links
	sta text_ptr_links + 2
	// verplaats tabel ptr
	lda tabel_ptr_links_lo + 1
	sta num1lo
	lda tabel_ptr_links_lo + 2
	sta num1hi
	jsr add8_16
	lda num1lo
	sta tabel_ptr_links_lo + 1
	lda num1hi
	sta tabel_ptr_links_lo + 2
	lda tabel_ptr_links_hi + 1
	sta num1lo
	lda tabel_ptr_links_hi + 2
	sta num1hi
	jsr add8_16
	lda num1lo
	sta tabel_ptr_links_hi + 1
	lda num1hi
	sta tabel_ptr_links_hi + 2
	// reset als eind
	lda tabel_ptr_links_lo + 1
	cmp #<regel_tabel_links_eind
	bne !skip+
	lda tabel_ptr_links_lo + 2
	cmp #>regel_tabel_links_eind
	bne !skip+
	// reset ptr
	lda #<regel_tabel_links
	sta tabel_ptr_links_lo + 1
	lda #>regel_tabel_links
	sta tabel_ptr_links_lo + 2
	lda #<regel_tabel_links + 1
	sta tabel_ptr_links_hi + 1
	lda #>regel_tabel_links + 1
	sta tabel_ptr_links_hi + 2
!skip:
	rts

regel_tabel_links:
	.word regel3_links, regel5_links, regel7_links, regel1_links
regel_tabel_links_eind:

regel_tabel_rechts:
	.word regel2_rechts, regel4_rechts, regel6_rechts, regel8_rechts
regel_tabel_rechts_eind:

	.byte 0
regel1_links:
	.text "yo, daar zijn we weer"
regel1_rechts:
	.byte 0
regel2_links:
	.text "gezellig bij de hcc"
regel2_rechts:
	.byte '!'
	.byte 0
regel3_links:
	.text "laten we eens iets moois maken"
regel3_rechts:
	.byte '!'
	.byte 0
regel4_links:
	.text "dit is een klein probeelse"
regel4_rechts:
	.byte 'l'
	.byte 0
regel5_links:
	.text "dit was een paar uurtjes wer"
regel5_rechts:
	.byte 'k'
	.byte 0
regel6_links:
	.text "geinig toch"
regel6_rechts:
	.byte '?'
	.byte 0
regel7_links:
	.text "code door metho"
regel7_rechts:
	.byte 's'
	.byte 0
regel8_links:
	.text "muziek door wav"
regel8_rechts:
	.byte 'e'
	.byte 0

#import "screen.asm"

balon_pos:
	.byte 0

// sprite movement table
sinus:
	.fill $100, round($94 + $6 * sin(toRadians(i * 2 * 360 / $100)))
sinus2:
	.fill $100, round($70 + $12 * sin(toRadians(i * 360 / $100)))

	* = music.location "music"

	.fill music.size, music.getData(i)

	.print "music_init = $" + toHexString(music.init)
	.print "music_play = $" + toHexString(music.play)

.align $100
m0spr:
	.byte %00000000, %01111111, %00000000
	.byte %00000001, %11111111, %11000000
	.byte %00000011, %11111111, %11100000
	.byte %00000011, %11100011, %11100000
	.byte %00000111, %11011100, %11110000
	.byte %00000111, %11011101, %11110000
	.byte %00000111, %11011100, %11110000
	.byte %00000011, %11100011, %11100000
	.byte %00000011, %11111111, %11100000
	.byte %00000011, %11111111, %11100000
	.byte %00000010, %11111111, %10100000
	.byte %00000001, %01111111, %01000000
	.byte %00000001, %00111110, %01000000
	.byte %00000000, %10011100, %10000000
	.byte %00000000, %10011100, %10000000
	.byte %00000000, %01001001, %00000000
	.byte %00000000, %01001001, %00000000
	.byte %00000000, %00111110, %00000000
	.byte %00000000, %00111110, %00000000
	.byte %00000000, %00111110, %00000000
	.byte %00000000, %00011100, %00000000
	.byte 0

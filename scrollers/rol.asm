// Assembler: KickAssembler 4.4
// rollende tekst

BasicUpstart2(start)

.var scr_clear_char = ' '
.var scr_clear_color = $0f

	* = $0810 "start"

.var scherm = $0400
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

start:
	jsr scr_clear
	lda #$00
	sta $d020
	sta $d021
	lda #music.startSong - 1
	jsr music.init
	jsr irq_init
	jmp *

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

#import "../irq/krnl1.asm"

irq:
	asl $d019
	// BEGIN kernel
	inc $d020
	jsr scroll
	inc $d020
	jsr music.play
	dec $d020
	dec $d020
	// EIND kernel
	pla
	tay
	pla
	tax
	pla
	rti

.var stappen = 20

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
	inc $d020
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
	.word regel3_links, regel5_links, regel1_links
regel_tabel_links_eind:

regel_tabel_rechts:
	.word regel2_rechts, regel4_rechts, regel6_rechts
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
	.text "geinig toch"
regel5_rechts:
	.byte '?'
	.byte 0
regel6_links:
	.text "code by metho"
regel6_rechts:
	.byte 's'
	.byte 0

#import "screen.asm"

	* = music.location "music"

	.fill music.size, music.getData(i)

	.print "music_init = $" + toHexString(music.init)
	.print "music_play = $" + toHexString(music.play)

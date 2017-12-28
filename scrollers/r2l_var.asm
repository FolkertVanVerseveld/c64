// Assembler: KickAssembler 4.4
// right to left scroller
// horizontale scroller in één richting met instelbare snelheid
// alleen voor tekst mode met één regel

BasicUpstart2(start)

.var scr_clear_char = ' '
.var scr_clear_color = $0f

.var debug = false

	* = $810 "start"
start:
	jsr scr_clear
	lda #$00
	sta $d020
	sta $d021
	jsr irq_init
	jmp *

#import "../irq/krnl1.asm"

irq:
	asl $d019
	// BEGIN kernel
	inc $d020
	jsr scroll
	dec $d020
	// EIND kernel
	pla
	tay
	pla
	tax
	pla
	rti

#import "screen.asm"

.var scroll_screen = $0400

scroll:
	// verplaats horizontaal
	lda scroll_xpos
	sec
!spdptr:
	sbc scroll_speed_tbl
	and #$07
	sta scroll_xpos
	bcc !move+
	jmp !klaar+
!move:
	// verplaats alles één naar links
	ldx #$00
!l:
	lda scroll_screen + 1, x
	sta scroll_screen, x
	inx
	cpx #40
	bne !l-

	// haal eentje op uit de rij
!textptr:
	lda scroll_text
	cmp #$ff
	bne !nowrap+
	jsr scroll_herstel
!nowrap:
	sta scroll_screen + 39
	// werk textptr bij
	inc !textptr- + 1
	bne * + 5
	inc !textptr- + 2
	// werk timer bij
	inc scroll_timer
	// kijk of hij verlopen is
	lda scroll_timer
!timeptr:
	cmp scroll_time_tbl
	bcc !klaar+
	// hij is verlopen
.if (debug) {
	// laat het op het scherm zien
	inc $0500
}
	lda #0
	sta scroll_timer
	// werk timer ptr bij
	inc !timeptr- + 1
	bne * + 5
	inc !timeptr- + 2
	// werk speed ptr bij
	inc !spdptr- + 1
	bne * + 5
	inc !spdptr- + 2
	// kijk nu of de speedptr op het einde is
	// zo ja, herstel de timers
	lda !spdptr- + 1
	sta !ptr+ + 1
	lda !spdptr- + 2
	sta !ptr+ + 2
!ptr:
	lda scroll_speed_tbl
	cmp #$ff
	bne !klaar+
	jsr scroll_time_herstel
!klaar:
	// pas horizontale verplaatsing toe
	lda #$c0
	ora scroll_xpos
	sta $d016
	rts

scroll_time_herstel:
	// herstel timer
	lda #0
	sta scroll_timer
.if (debug) {
	lda #' '
	sta $0500
}
	// herstel time ptr
	lda #<scroll_time_tbl
	sta !timeptr- + 1
	lda #>scroll_time_tbl
	sta !timeptr- + 2
	// herstel speed ptr
	lda #<scroll_speed_tbl
	sta !spdptr- + 1
	lda #>scroll_speed_tbl
	sta !spdptr- + 2
	rts

scroll_herstel:
	// haal dit uit commentaar als je de snelheid
	// ook wil herstellen als de tekst rondgaat:
	//jsr scroll_time_herstel
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

scroll_xpos:
	.byte 0
scroll_char:
	.byte 0
scroll_text:
	.text "deze scroller kan met een wisselende snelheid bewegen. "
	.text "hij houdt twee lijsten bij voor de snelheid en duur van elke verandering. "
	.text "de scroller kan niet stilstaan en de maximumsnelheid is 7. "
	.byte $ff

scroll_timer:
	.byte 0

// tafels voor het scrollen met variërende snelheid
// de speed tafel moet eindigen met $ff en dus eentje langer zijn dan time_tbl
scroll_time_tbl:
	.byte 2, 2, 2, 2, 2, 4
scroll_speed_tbl:
	.byte 2, 3, 4, 3, 2, 1, $ff

// Assembler: KickAssembler 4.4
// left to right scroller

BasicUpstart2(start)

.var scr_clear_char = ' '
.var scr_clear_color = $0f

.var scroll_screen = $400

.var debug = true

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
	.if (debug) {
	inc $d020
	}
	jsr scroll
	.if (debug) {
	dec $d020
	}
	pla
	tay
	pla
	tax
	pla
	rti

#import "screen.asm"

scroll:
	lda scroll_xpos
	clc
	adc scroll_speed
	cmp #$08
	bpl !l+
	sta scroll_xpos
	jmp !done+
!l:
	and #$07
	sta scroll_xpos
!move:
	.if (false) {
	inc $d021
	}
	// verplaats alles één naar rechts
	ldx #38
!l:
	lda scroll_screen, x
	sta scroll_screen + 1, x
	dex
	bpl !l-

	// haal eentje op uit de rij
!textptr:
	lda scroll_text
	cmp #$ff
	bne !nowrap+
	jsr scroll_herstel
!nowrap:
	sta scroll_screen
	// werk text ptr bij
	lda !textptr- + 1
	bne !l+
	dec !textptr- + 2
!l:
	dec !textptr- + 1
!done:
	// pas horizontale verplaatsing toe
	lda #$c0
	ora scroll_xpos
	sta $d016
	rts

scroll_herstel:
	// herstel ptr
	lda #<scroll_text
	sta !textptr- + 1
	lda #>scroll_text
	sta !textptr- + 2
	lda scroll_text
	rts

scroll_xpos:
	.byte 0
scroll_speed:
	.byte 3
	.byte $ff
	.text " maar er is maar 1 manier om daar achter te komen... "
	.text " als het goed is kan hij ook teksten langer dan 256 karakters afhandelen."
	.text " hey, deze scroller gaat de verkeerde kant op!"

.label scroll_text = * - 1

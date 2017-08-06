// Assembler: KickAssembler 4.4
// right to left scroller
// horizontale scroller in één richting met instelbare snelheid
// alleen voor tekst mode met één regel

BasicUpstart2(start)

.var scr_clear_char = ' '
.var scr_clear_color = $0f

	* = $810 "start"
start:
	jsr scr_clear
	lda #$00
	sta $d020
	sta $d021
	jsr irq_init
	jmp *

#import "irq.asm"

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
	sbc scroll_speed
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
	// werk text ptr bij
	inc !textptr- + 1
	bne !klaar+
	inc !textptr- + 2
!klaar:
	// pas horizontale verplaatsing toe
	lda #$c0
	ora scroll_xpos
	sta $d016
	rts

scroll_herstel:
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
scroll_speed:
	.byte 2
scroll_char:
	.byte 0
scroll_text:
	.text "hey, deze scroller kan alleen van rechts naar links bewegen. "
	.text "hij gaat door tot 0xff en dan weer rond. "
	.byte $ff

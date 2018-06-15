// Assembler: KickAssembler 4.4
// rollende tekst

BasicUpstart2(start)

.var scr_clear_char = ' '
.var scr_clear_color = $0f

	* = $0810 "start"

.var scherm = $0400
.var links = scherm + 4 * 40 + 6

.var rechts = scherm + 7 * 40 + 39 - 6

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

scroll:
	lda #$00
	bne !a+
	jmp scroll_links
!a:
	jmp scroll_rechts

scroll_links:
rol_ptr_links:
	lda regel1
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
!done:
	// TODO reset rechts logic
	inc scroll + 1
	rts

scroll_rechts:
rol_ptr_rechts:
	lda regel3 - 2
	beq !done+
text_ptr_rechts:
	sta rechts
	// verplaats rol_ptr
	dec rol_ptr_rechts + 1
	bne !skip+
	dec rol_ptr_rechts + 2
!skip:
	// verplaats text_ptr
	dec text_ptr_rechts + 1
	bne !skip+
	dec text_ptr_rechts + 2
!skip:
	rts
!done:
	inc $d020
	dec scroll + 1
	// TODO reset links logic
	rts

	.byte 0
regel1:
	.text "yo, daar zijn we weer"
	.byte 0
regel2:
	.text "gezellig bij de hcc!"
	.byte 0
regel3:
	.text "laten we eens iets moois maken!"
	.byte 0
regel4:
	.text "dit is een klein probeelsel"
	.byte 0
regel5:
	.text "geinig toch?"
	.byte 0
regel_eind:

#import "screen.asm"

:BasicUpstart2(start)

// simple scroller that works in both horizontal directions

.var zp_scroll = $2
.var zp_scroll_speed = $3
.var tmp = $5
.var zp_scroll_pos = $6 // word
.var zp_scroll_pos2 = $8 // word
.var zp_scroll_timer = $a

// math stuff

.var num1lo = $62
.var num1hi = $63
.var num2lo = $64
.var num2hi = $65
.var reslo = $66
.var reshi = $67


.var hexbuf = $b // 4 bytes

.var irq_line_top = $38
.var irq_line_bottom = irq_line_top + 12

.const colram = $d800

.const screen = $0400
.const screen_scroll = screen + 40

// max_speed cannot exceed 7
.const max_speed = 7

start:
	sei
	lda #$35
	sta $1

	lda #0
	sta zp_scroll
	sta zp_scroll_timer

	lda #<text
	sta zp_scroll_pos
	sta screen + 4 * 40
	lda #>text
	sta zp_scroll_pos + 1
	sta screen + 4 * 40 + 1
	lda #<text_end - 39
	sta zp_scroll_pos2
	lda #>text_end - 39
	sta zp_scroll_pos2 + 1

	lda #$ff
	sta zp_scroll_speed

	ldx #0
!:
	lda #' '
	sta screen, x
	sta screen + $100, x
	sta screen + $200, x
	sta screen + $2e8, x
	lda #1
	sta colram + 0 * 250, x
	sta colram + 1 * 250, x
	sta colram + 2 * 250, x
	sta colram + 3 * 250, x
	dex
	bne !-

	lda #0
	sta $d020
	sta $d021

	lda #<irq_top
	sta $fffe
	lda #>irq_top
	sta $ffff
	lda #<dummy
	sta $fffa
	sta $fffc
	lda #>dummy
	sta $fffb
	sta $fffd

	lda #%00011011 // 0-2 vertical raster scroll: 3
	               //   3 screen height         : 25 rows
	               //   4 screen                : ON
	               //   5 graphics mode         : text
	               //   6 extended background   : OFF
	               //   7 raster high bit       : OFF
	sta $d011

	lda #%11001000 // 0-2 horizontal raster scroll: 0
	               //   3 screen width            : 40 columns
	               //   4 multicolor mode         : OFF
	               // 5-7 unknown
	sta $d016

	lda #irq_line_top
	sta $d012

	lda #%0001     // 0 raster interrrupt: ON
	               // 1 sprite-background: OFF
	               // 2 sprite-sprite    : OFF
	               // 3 light-pen        : OFF
	sta $d01a

	lda #%01111111 // disable timer A for CIA 1 and 2
	sta $dc0d
	sta $dd0d

	lda $dc0d      // clear pending interrrupts from CIA 1 and 2
	lda $dd0d

	lda #0         // disable timer B
	sta $dc0e
	sta $dd0e

	lda #%00011111
	sta $dc02

	lda #1         // acknowledge pending raster interrupt
	sta $d019      // it may happen that the raster interrupt we are
	               // interested in has occurred just as we are setting
	               // things up... which will block any new raster
	               // interrupts... so we have to acknowledge them

	cli

	jmp *

irq_top:
	pha
	lda zp_scroll
	and #%0111
	ora #%11000000
	sta $d016

	lda #<irq_bottom
	sta $fffe
	lda #>irq_bottom
	sta $ffff
	lda #irq_line_bottom
	sta $d012

	pla

	asl $d019
	rti

irq_bottom:
	pha
	txa
	pha
	tya
	pha

	inc $d020
	lda #%11001000
	sta $d016

	ldx #0 // x = zp_scroll_speed < 0 ? 0 : 1
	lda zp_scroll_speed
	bpl !l+
	inx
!l:

	// zp_scroll += zp_scroll_speed
	lda zp_scroll
	and #%0111
	sta tmp
	clc
	adc zp_scroll_speed
	sta zp_scroll

	txa
	bne !ll+ // jump if zp_scroll_speed < 0

	// move left to right

	// if zp_scroll_speed < 0 goto l+
	// e.g. tmp = old zp_scroll = 7, zp_scroll = 8
	// zp_scroll & 7 = 0
	// tmp = old zp_scroll & 7 = 7
	lda zp_scroll
	and #%0111
	cmp tmp
	bpl !done+
	// add char at begin
	jsr l2r
	jmp !done+
	// move right to left
!ll:
	// e.g. tmp = old zp_scroll = 0, zp_scroll = $ff
	// zp_scroll & 7 = 7
	// tmp = old zp_scroll & 7 = 0
	//sta $0400 + 4 * 40
	//pha
	//lda tmp
	//sta $0400 + 4 * 40 + 1
	//pla

	lda zp_scroll
	and #%0111
	cmp tmp
	beq !done+
	bmi !done+
	// update text pointer
	jsr r2l
!done:
	// joystick control
	lda $dc00
	tay
	and #%0100
	bne !+
	// increment
	ldx zp_scroll_timer
	inx
	stx zp_scroll_timer
	cpx #$8
	bne !+
	ldx #0
	stx zp_scroll_timer
	ldx zp_scroll_speed
	cpx #max_speed
	beq !+
	inx
	stx zp_scroll_speed
!:
	tya
	and #%1000
	bne !+
	// decrement
	ldx zp_scroll_timer
	inx
	stx zp_scroll_timer
	cpx #$8
	bne !+
	ldx #0
	stx zp_scroll_timer
	ldx zp_scroll_speed
	cpx #(0 - max_speed)
	beq !+
	dex
	stx zp_scroll_speed
	jmp !+
!l:
	lda #0
	sta zp_scroll_timer
!:

	// XXX debug stuff

	// zp_scroll_pos at (0,3) to (3,3)
	lda zp_scroll_pos
	ldy zp_scroll_pos + 1
	jsr w2h
	lda hexbuf + 0
	sta screen + 3 * 40
	lda hexbuf + 1
	sta screen + 3 * 40 + 1
	lda hexbuf + 2
	sta screen + 3 * 40 + 2
	lda hexbuf + 3
	sta screen + 3 * 40 + 3

	// zp_scroll_pos2 at (0,4) to (3,4)
	lda zp_scroll_pos2
	ldy zp_scroll_pos2 + 1
	jsr w2h
	lda hexbuf + 0
	sta screen + 4 * 40
	lda hexbuf + 1
	sta screen + 4 * 40 + 1
	lda hexbuf + 2
	sta screen + 4 * 40 + 2
	lda hexbuf + 3
	sta screen + 4 * 40 + 3

	// index of zp_scroll_pos (i.e. zp_scroll_pos - text)
	// at (5,3) to (8,3)
	lda zp_scroll_pos
	sta num1lo
	lda zp_scroll_pos + 1
	sta num1hi
	lda #<text
	sta num2lo
	lda #>text
	sta num2hi
	jsr sub16
	lda reslo
	ldy reshi
	jsr w2h
	lda hexbuf + 0
	sta screen + 3 * 40 + 5
	lda hexbuf + 1
	sta screen + 3 * 40 + 6
	lda hexbuf + 2
	sta screen + 3 * 40 + 7
	lda hexbuf + 3
	sta screen + 3 * 40 + 8

	// index of zp_scroll_pos2 (i.e. zp_scroll_pos2 - text)
	// at (5,4) to (8,4)
	lda zp_scroll_pos2
	sta num1lo
	lda zp_scroll_pos2 + 1
	sta num1hi
	lda #<text
	sta num2lo
	lda #>text
	sta num2hi
	jsr sub16
	lda reslo
	ldy reshi
	jsr w2h
	lda hexbuf + 0
	sta screen + 4 * 40 + 5
	lda hexbuf + 1
	sta screen + 4 * 40 + 6
	lda hexbuf + 2
	sta screen + 4 * 40 + 7
	lda hexbuf + 3
	sta screen + 4 * 40 + 8

	lda #<irq_top
	sta $fffe
	lda #>irq_top
	sta $ffff
	lda #irq_line_top
	sta $d012

	pla
	tay
	pla
	tax
	pla

	dec $d020
dummy:
	asl $d019      // acknowledge raster interrupt
	rti

r2l:
	// move
	ldx #0
!l:
	lda screen_scroll + 1, x
	sta screen_scroll, x
	inx
	cpx #38
	bne !l-

	ldx #0
	lda (zp_scroll_pos,x)
	// reset if last char
	cmp #$ff
	bne !l+
	lda #<text
	sta zp_scroll_pos
	lda #>text
	sta zp_scroll_pos + 1
!l:
	lda (zp_scroll_pos2,x)
	// reset if last char
	cmp #$ff
	bne !l+
	lda #<text
	sta zp_scroll_pos2
	lda #>text
	sta zp_scroll_pos2 + 1
!l:
	// add char to end
	lda (zp_scroll_pos,x)
	sta screen_scroll + 38
	// advance pointers
	inc zp_scroll_pos
	bne !l+
	inc zp_scroll_pos + 1
!l:
	inc zp_scroll_pos2
	bne !l+
	inc zp_scroll_pos2 + 1
!l:
	rts

l2r:
	// move
	ldx #39
!l:
	lda screen_scroll - 1, x
	sta screen_scroll, x
	dex
	bne !l-

	// decrement both scroll pos
	dec zp_scroll_pos
	lda zp_scroll_pos
	cmp #$ff
	bne !l+
	dec zp_scroll_pos + 1
!l:
	dec zp_scroll_pos2
	lda zp_scroll_pos2
	cmp #$ff
	bne !l+
	dec zp_scroll_pos2 + 1

	// reset if last char
!l:
	ldx #0
	lda (zp_scroll_pos,x)
	// reset if last char
	cmp #$ff
	bne !l+
	lda #<text_end - 1
	sta zp_scroll_pos
	lda #>text_end - 1
	sta zp_scroll_pos + 1
!l:
	lda (zp_scroll_pos2,x)
	// reset if last char
	cmp #$ff
	bne !l+
	lda #<text_end - 1
	sta zp_scroll_pos2
	lda #>text_end - 1
	sta zp_scroll_pos2 + 1
!l:
	lda (zp_scroll_pos2,x)
	sta screen_scroll
	rts

	.byte $ff
text:
	//.text "                                        "
	.text "yo! gebruik joy2 om de scroller te bewegen "
	.text "dit is een kleine demo... "
	.text "de code heeft geen dependencies omdat dat niet altijd handig is. "
	.text "met name wanneer je code aan elkaar aan het lappen bent. "
	.text "bijvoorbeeld bij het maken van een demo! "
	.text "over demo's gesproken, ik ben de laatste tijd niet echt actief geweest. "
	.text "ja slap excuus aangezien ik vakantie heb, maar soms kost het wat tijd "
	.text "om een idee te krijgen en dat uit te voeren! "
	.text "dat was het... tekst gaat weer rond... "
	.text "                                        "
text_end:
	.byte $ff
	// this should not be shown on screen
	.text "whoah ship ship ship"

// convert word to hexadecimal
// low byte in A, high byte in Y
// result is stored in zp hexbuf
w2h:
	pha
	and #%1111
	tax
	lda w2h_tbl, x
	sta hexbuf + 3
	pla
	lsr
	lsr
	lsr
	lsr
	tax
	lda w2h_tbl, x
	sta hexbuf + 2
	tya
	and #%1111
	tax
	lda w2h_tbl, x
	sta hexbuf + 1
	tya
	lsr
	lsr
	lsr
	lsr
	tax
	lda w2h_tbl, x
	sta hexbuf
	rts

w2h_tbl:
	.text "0123456789abcdef"

sub16:
	sec
	lda num1lo
	sbc num2lo
	sta reslo
	lda num1hi
	sbc num2hi
	sta reshi
	rts

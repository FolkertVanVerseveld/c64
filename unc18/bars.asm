:BasicUpstart2(start)

.var irq_line_top = $20 - 1

.var screen = $0400
.var colram = $d800

.var lines_border_top = $30 - irq_line_top + 1

// FIXME use proper value (now using dummy testvalue)
.var lines_middle = $60

.var lines_counter = $fb

#import "pseudo.lib"

start:
	lda #0
	sta $d020
	sta $d021

	jsr copy_image
	jsr blit_hide

	sei
	lda #$35		// Disable KERNAL and BASIC ROM
	sta $01			// Enable all RAM

	lda #<irq_top		// Setup IRQ vector
	sta $fffe
	lda #>irq_top
	sta $ffff

	lda #<dummy
	sta $fffa
	sta $fffc
	lda #>dummy
	sta $fffb
	sta $fffd

	lda #%00011011		// Load screen control:
				// Vertical scroll    : 3
				// Screen height      : 25 rows
				// Screen             : ON
				// Mode               : TEXT
				// Extended background: OFF
	sta $d011       	// Set screen control

	lda #irq_line_top
	sta $d012

	lda #$01		// Enable mask
	sta $d01a		// IRQ interrupt ON

	lda #%01111111		// Load interrupt control CIA 1:
				// Timer A underflow : OFF
				// Timer B underflow : OFF
				// TOD               : OFF
				// Serial shift reg. : OFF
				// Pos. edge FLAG pin: OFF
	sta $dc0d		// Set interrupt control CIA 1
	sta $dd0d		// Set interrupt control CIA 2

	lda $dc0d		// Clear pending interrupts CIA 1
	lda $dd0d		// Clear pending interrupts CIA 2

	lda #$00
	sta $dc0e

	lda #$01
	sta $d019		// Acknowledge pending interrupts

	cli			// Start firing interrupts

	jmp *

.align $100
irq_top:
	irq

	lda #<irq_top_wedge	// Daisy chain double IRQ for stable raster
	sta $fffe
	lda #>irq_top_wedge
	sta $ffff

	inc $d012		// Trigger wedge IRQ on next line.

	lda #$01		// Acknowledge IRQ
	sta $d019

	tsx
	cli
	.for (var i=0; i<8; i++) {
		nop
	}

irq_top_wedge:
	txs

	ldx #$08
	dex
	bne *-1
	bit $ea

	lda $d012
	cmp $d012
	beq *+2
	// vv stable raster here

	ldx #0
!:
	lda coltbl, x
	sta $d020

	// TODO figure out if badline
	ldy #8
	dey
	bne *-1
	bit $ea

	inx
	lda coltbl, x
	cpx #lines_border_top
	bne !-

!bad:
	// NOTE: one cycle spilled already from previous branch

	// bad line handling
	sta $d020     // 4, 5
	sta $d021     // 4, 9
	inx           // 2, 11
	// 10 cycles left, just prepare counter for normal lines
	lda #7        // 2, 15
	sta lines_counter // 3, 18

	// TODO figure out why we need 3 cycles
	jmp !fst+

	// this is duplicated from previous loop, but hey, it works...
!:
	nop
	nop
	bit $ea

!fst:

	lda coltbl, x
	sta $d020
	sta $d021

	ldy #5
	dey
	bne *-1

	inx
	lda coltbl, x
	cpx #lines_middle
	beq !ack+

	dec lines_counter
	bne !-

	nop
	nop
	nop
	nop
	jmp !bad-

!ack:
	asl $d019

	jsr roll
	jsr roll2
	jsr sinusroll

	qri #irq_line_top : #irq_top

bad_line:
	inx
// bad line handling: only 20 out of 63 cycles
	lda coltbl, x // 4, 4
	sta $d020     // 4, 8
	inx           // 2, 10
	cpx #16       // 2, 12
	beq !ack-     // 2, 14
	bit $ea       // 3, 17
	jmp !-        // 3, 20

dummy:
	rti

.align $80

coltbl:
flag:
	.byte 2, 2, 2, 2, 2, 2, 2, 2
	.byte 1, 1, 1, 1, 1, 1, 1, 1, 6, 6, 6, 6, 6, 6, 6, 6
	.byte 0, 0, 0, 0
	.byte 0, 0, 0, 0
	.byte 0, 0, 0, 0

	//.byte 1, 13, 5, 6, 11, 14, 3, 1, 0, 0, 0, 0, 0, 0, 0, 0
rolcol:
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	.byte 0, 0, 0, 0
sinusrol:
	.byte 0, 0
	.byte 0, 0, 0, 0, 0, 0, 0
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
sinusrol_end:
	.byte 4, 7, 1, 2, 3, 14, 9, 0, 12, 15, 8, 5, 10, 6, 13, 11
	.byte 0, 0, 0, 0, 0, 0, 0, 0

sinus:
	.fill $40, round($12*sin(toRadians(i*360/$80)))

roltbl:
	.byte 1, 1, 3, 14, 5, 4, 6, 11

rolpos:
	.byte 0

roll:
	ldx roldelay
	dex
	stx roldelay
	bne !done+
	ldx #2
	stx roldelay

	lda rolcol + 9 - 8
	sta rolcol + 9 - 9
	sta rolcol + 9 + 9
	lda rolcol + 9 - 7
	sta rolcol + 9 - 8
	sta rolcol + 9 + 8
	lda rolcol + 9 - 6
	sta rolcol + 9 - 7
	sta rolcol + 9 + 7
	lda rolcol + 9 - 5
	sta rolcol + 9 - 6
	sta rolcol + 9 + 6
	lda rolcol + 9 - 4
	sta rolcol + 9 - 5
	sta rolcol + 9 + 5
	lda rolcol + 9 - 3
	sta rolcol + 9 - 4
	sta rolcol + 9 + 4
	lda rolcol + 9 - 2
	sta rolcol + 9 - 3
	sta rolcol + 9 + 3
	lda rolcol + 9 - 1
	sta rolcol + 9 - 2
	sta rolcol + 9 + 2
	lda rolcol + 9 - 0
	sta rolcol + 9 - 1
	sta rolcol + 9 + 1

	ldx rolpos
	inx
	txa
	and #$07
	tax
	stx rolpos

	lda roltbl, x
	sta rolcol + 9

!done:
	rts

roldelay:
	.byte 2

roll2:
	ldx flag + 23
	lda flag + 22
	sta flag + 23
	lda flag + 21
	sta flag + 22
	lda flag + 20
	sta flag + 21
	lda flag + 19
	sta flag + 20
	lda flag + 18
	sta flag + 19
	lda flag + 17
	sta flag + 18
	lda flag + 16
	sta flag + 17
	lda flag + 15
	sta flag + 16
	lda flag + 14
	sta flag + 15
	lda flag + 13
	sta flag + 14
	lda flag + 12
	sta flag + 13
	lda flag + 11
	sta flag + 12
	lda flag + 10
	sta flag + 11
	lda flag + 9
	sta flag + 10
	lda flag + 8
	sta flag + 9
	lda flag + 7
	sta flag + 8
	lda flag + 6
	sta flag + 7
	lda flag + 5
	sta flag + 6
	lda flag + 4
	sta flag + 5
	lda flag + 3
	sta flag + 4
	lda flag + 2
	sta flag + 3
	lda flag + 1
	sta flag + 2
	lda flag + 0
	sta flag + 1
	stx flag
	rts

sinusroll:
	// veeg oude plek uit
	lda #0
	ldx sinuspos
	ldy sinus, x
	sta sinusrol, y
	inx
	txa
	and #$3f
	tax
	stx sinuspos
	lda #10
	ldy sinus, x
	sta sinusrol, y
	// vul de rest met dezelfde kleur
!:
	sta sinusrol, y
	iny
	cpy #sinusrol_end - sinusrol
	bne !-
	rts

sinuspos:
	.byte 0

copy_image:
	ldx #0
!l:
	lda image  + $000, x
	sta screen + $000, x
	lda image  + $100, x
	sta screen + $100, x
	lda image  + $200, x
	sta screen + $200, x
	lda image  + $2e8, x
	sta screen + $2e8, x

	lda #2
	lda colors + $000, x
	sta colram + $000, x
	lda colors + $100, x
	sta colram + $100, x
	lda colors + $200, x
	sta colram + $200, x
	lda colors + $2e8, x
	sta colram + $2e8, x
	dex
	bne !l-
	rts

blit_hide:
	ldx #0
	ldy #10
!:
	lda texts, x
	sta screen + 5 * 40 + (40 - $18) / 2, x
	tya
	sta colram + 5 * 40 + (40 - $18) / 2, x
	inx
	cpx #$18
	bne !-
	rts

/*
kleurentabel:
0: zwart
1: wit
2: rood
3: cyaan
4: paars
5: groen
6: blauw
7: geel
8: oranje
9: bruin
10: beige
11: donkergrijs
12: grijs
13: licht groen
14: lichtblauw
15: lichtgrijs
*/

.align $100
image:
	.byte	$20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
	.byte	$20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $0B, $0F, $05, $0C, $09, $05, $0A, $0F, $05, $0C, $09, $05, $21, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
	.byte	$20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
	.byte	$20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
	.byte	$20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
	.byte	$20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
	.byte	$20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
	.byte	$20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
	.byte	$20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $E9, $E0, $E0, $E0, $E0, $E0, $DF, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
	.byte	$20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $E9, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $DF, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
	.byte	$20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $E0, $4E, $77, $4D, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $DF, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
	.byte	$20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $E9, $4E, $E0, $E0, $E0, $4D, $E0, $E0, $4E, $77, $4D, $E0, $E0, $E0, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
	.byte	$20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $E0, $E0, $E9, $E0, $DF, $E0, $20, $4E, $E0, $E0, $E0, $4D, $E0, $E0, $DF, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
	.byte	$20, $20, $20, $20, $20, $20, $20, $20, $20, $E9, $E0, $E0, $DF, $E9, $E0, $E0, $E0, $51, $E0, $E0, $E0, $E0, $E9, $E0, $DF, $E0, $E0, $E0, $E0, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
	.byte	$20, $20, $20, $20, $20, $20, $20, $20, $20, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $5F, $E0, $69, $E0, $E0, $E0, $E0, $51, $E0, $E0, $E0, $E0, $E0, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
	.byte	$20, $20, $20, $20, $20, $20, $20, $20, $20, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $5F, $E0, $69, $E0, $E0, $E0, $E0, $DF, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
	.byte	$20, $20, $20, $20, $20, $20, $20, $20, $20, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
	.byte	$20, $20, $20, $20, $20, $20, $20, $20, $20, $E0, $E0, $E0, $E9, $E0, $E0, $DF, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
	.byte	$20, $20, $20, $20, $20, $20, $20, $20, $20, $5F, $E0, $E9, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
	.byte	$20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $5F, $E0, $E0, $E0, $E0, $69, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $E0, $69, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
	.byte	$20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $5F, $E0, $69, $E0, $E0, $E0, $E0, $69, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
	.byte	$20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
	.byte	$20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
	.byte	$20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
	.byte	$20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20

.align $100
colors:
	.byte	$0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E
	.byte	$0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E
	.byte	$0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E
	.byte	$0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E
	.byte	$0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E
	.byte	$0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E
	.byte	$0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E
	.byte	$0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E
	.byte	$0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $00, $00, $00, $00, $00, $00, $00, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E
	.byte	$0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0A, $0A, $0A, $0A, $00, $00, $00, $00, $00, $00, $00, $00, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E
	.byte	$0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0A, $00, $00, $00, $0A, $0A, $0A, $0A, $0A, $00, $00, $00, $00, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E
	.byte	$0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0A, $00, $0A, $0A, $0A, $00, $0A, $0A, $00, $00, $00, $0A, $00, $00, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E
	.byte	$0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0A, $0A, $00, $00, $00, $0A, $0E, $00, $0A, $0A, $0A, $00, $00, $00, $00, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E
	.byte	$0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0A, $0A, $0A, $0A, $0A, $0A, $0A, $00, $01, $00, $0A, $0A, $0A, $00, $00, $00, $0A, $0A, $00, $00, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E
	.byte	$0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0A, $0A, $0A, $0A, $0A, $0A, $0A, $00, $00, $00, $0A, $0A, $0A, $00, $01, $00, $0A, $0A, $0A, $0A, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E
	.byte	$0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0A, $0A, $0A, $0A, $0A, $0A, $0A, $0A, $0A, $0A, $0A, $0A, $0A, $00, $00, $00, $0A, $0A, $0A, $0A, $0A, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E
	.byte	$0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0A, $0A, $0A, $0A, $0A, $0A, $0A, $0A, $0A, $0A, $0A, $0A, $0A, $0A, $0A, $0A, $0A, $0A, $0A, $0A, $0A, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E
	.byte	$0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0A, $0A, $0A, $02, $02, $02, $02, $0A, $0A, $0A, $0A, $0A, $0A, $0A, $0A, $0A, $0A, $0A, $0A, $0A, $0A, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E
	.byte	$0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0A, $0A, $02, $02, $02, $02, $02, $0A, $0A, $0A, $0A, $0A, $0A, $0A, $0A, $0A, $0A, $0A, $0A, $0A, $0A, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E
	.byte	$0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0A, $02, $02, $02, $02, $02, $0A, $0A, $0A, $0A, $0A, $0A, $0A, $0A, $0A, $0A, $0A, $0A, $0A, $0A, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E
	.byte	$0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0A, $02, $02, $0A, $0A, $0A, $0A, $0A, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E
	.byte	$0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E
	.byte	$0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E
	.byte	$0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E
	.byte	$0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E


	//     0123456789abcdef0123456789abcdef
texts:
	.text "       yo gasten!       "
	.text "party coding to the max!"
	.text "     code: methos       "
	.text "      gfx: snorro       "

:BasicUpstart2(start)

.var irq_line_top = $10 - 1

.var screen = $0400
.var colram = $d800

.var lines_border_top = $30 - irq_line_top + 1

// FIXME use proper value (now using dummy testvalue)
.var lines_middle = $ea

.var lines_counter = $fb

#import "pseudo.lib"

start:
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
	ldy #9
	dey
	bne *-1
	nop

	inx
	cpx #lines_border_top
	bne !-

!bad:
	// NOTE: one cycle spilled already from previous branch

	// bad line handling
	lda coltbl, x // 4, 5
	sta $d020     // 4, 9
	inx           // 2, 11
	// 10 cycles left, just prepare counter for normal lines
	lda #7        // 2, 15
	sta lines_counter // 3, 18

	// TODO figure out why we need 3 cycles
	jmp !fst+

	// this is duplicated from previous loop, but hey, it works...
!:
	nop
!fst:
	bit $ea

	lda coltbl, x
	sta $d020

	ldy #7
	dey
	bne *-1

	inx
	cpx #lines_middle
	beq !ack+

	dec lines_counter
	bne !-

	bit $ea
	jmp !bad-

!ack:
	asl $d019

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

.align $100

coltbl:
	.byte 4, 7, 1, 2
	.byte 3, 14, 9, 0
	.byte 12, 15, 8, 5
	.byte 10, 6, 13, 11
	.byte 4, 7, 1, 2
	.byte 3, 14, 9, 0
	.byte 12, 15, 8, 5
	.byte 10, 6, 13, 11
	.byte 4, 7, 1, 2
	.byte 3, 14, 9, 0
	.byte 12, 15, 8, 5
	.byte 10, 6, 13, 11
	.byte 4, 7, 1, 2
	.byte 3, 14, 9, 0
	.byte 12, 15, 8, 5
	.byte 10, 6, 13, 11
	.byte 4, 7, 1, 2
	.byte 3, 14, 9, 0
	.byte 12, 15, 8, 5
	.byte 10, 6, 13, 11
	.byte 4, 7, 1, 2
	.byte 3, 14, 9, 0
	.byte 12, 15, 8, 5
	.byte 10, 6, 13, 11
	.byte 4, 7, 1, 2
	.byte 3, 14, 9, 0
	.byte 12, 15, 8, 5
	.byte 10, 6, 13, 11
	.byte 4, 7, 1, 2
	.byte 3, 14, 9, 0
	.byte 12, 15, 8, 5
	.byte 10, 6, 13, 11
	.byte 4, 7, 1, 2
	.byte 3, 14, 9, 0
	.byte 12, 15, 8, 5
	.byte 10, 6, 13, 11
	.byte 4, 7, 1, 2
	.byte 3, 14, 9, 0
	.byte 12, 15, 8, 5
	.byte 10, 6, 13, 11
	.byte 4, 7, 1, 2
	.byte 3, 14, 9, 0
	.byte 12, 15, 8, 5
	.byte 10, 6, 13, 11
	.byte 4, 7, 1, 2
	.byte 3, 14, 9, 0
	.byte 12, 15, 8, 5
	.byte 10, 6, 13, 11
	.byte 4, 7, 1, 2
	.byte 3, 14, 9, 0
	.byte 12, 15, 8, 5
	.byte 10, 6, 13, 11
	.byte 4, 7, 1, 2
	.byte 3, 14, 9, 0
	.byte 12, 15, 8, 5
	.byte 10, 6, 13, 11
	.byte 4, 7, 1, 2
	.byte 3, 14, 9, 0
	.byte 12, 15, 8, 5
	.byte 10, 6, 13, 11
	.byte 4, 7, 1, 2
	.byte 3, 14, 9, 0
	.byte 12, 15, 8, 5
	.byte 10, 6, 13, 11

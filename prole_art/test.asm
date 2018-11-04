// Assembler: KickAssembler v4.19

BasicUpstart2(main)

.var irq_line_top = $19 - 1
.var top_lines = $19

//.var irq_line_top = $20 - 1
//.var top_lines = $08

.var irq_line_bottom = 312 - 64

.var music = LoadSid("/home/methos/Music/C64Music/MUSICIANS/0-9/20CC/van_Santen_Edwin/Blackmail_Tune_1.sid")

main:
	lda #0
	jsr music.init

	sei			// Setup interrupts
	lda #$35		// Disable KERNAL and BASIC ROM
	sta $01			// Enable all RAM

	lda #<irq_top		// Setup IRQ vector
	sta $fffe
	lda #>irq_top
	sta $ffff

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
	pha
	txa
	pha
	tya
	pha

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
	beq *+2			// Stable raster line after this instruction.


	ldx #0
!l:
	lda raster_tbl,x	// 4, 4
	sta $d020		// 4, 8

	jsr delay2		// 6+6+6+6, 32
	jsr delay		// 6+6, 44
	inc dummy		// 6, 50
	nop
	nop
	inx			// 2, 56
	cpx top_counter		// 4, 60
	bne !l-			// 3, 63

	lda #14
	sta $d020

	lda #<irq_bottom	// Restore first IRQ for stable raster
	sta $fffe
	lda #>irq_bottom
	sta $ffff

	lda #irq_line_bottom	// Restore raster line
	sta $d012

	inc $d019		// Finally, acknowledge IRQ

	ldx top_counter
	cpx #top_lines
	beq !no_inc+
	inc top_counter
!no_inc:

	pla
	tay
	pla
	tax
	pla
	rti

delay2:
	jsr delay
delay:
	rts

irq_bottom:
	pha
	txa
	pha
	tya
	pha

	lda #<irq_top
	sta $fffe
	lda #>irq_top
	sta $ffff

	lda #irq_line_top
	sta $d012

	inc $d019

	jsr music.play

	pla
	tay
	pla
	tax
	pla
	rti


raster_tbl:
	.for (var i=0; i<top_lines; i++) {
		.byte 6
	}
dummy:
	.byte 0

top_counter:
	.byte 1

// MUSIC
	* = music.location "music"

	.fill music.size, music.getData(i)

	.print "music_init = $" + toHexString(music.init)
	.print "music_play = $" + toHexString(music.play)

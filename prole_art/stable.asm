// Assembler: KickAssembler v4.19
// source: codebase64.org/doku.php?id=base:dysp_d017

BasicUpstart2(start)

.var irq_line_top = $28 - 1

.var music = LoadSid("/home/methos/Music/HVSC69/MUSICIANS/0-9/20CC/van_Santen_Edwin/Blackmail_Tune_1.sid")
//.var music = LoadSid("/home/methos/Music/HVSC69/MUSICIANS/J/JCH/Training.sid")

start:
//	lda #6			// Set color to black
//	sta $d020		// for border
//	sta $d021		// and screen

	// setup interrupts

	sei
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
	beq *+2
	
	// Stable raster line here
	inc $d020
	jsr delay2
	dec $d020

	lda #<irq_top		// Restore first IRQ for stable raster
	sta $fffe
	lda #>irq_top
	sta $ffff

	lda #irq_line_top	// Restore raster line
	sta $d012

	inc $d019

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


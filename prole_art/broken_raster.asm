// Assembler: KickAssembler v4.19
// source: codebase64.org/doku.php?id=base:nmi_lock

BasicUpstart2(main)

// `Disable NMI' by Ninja/The Dreams/TempesT

.var irq_line_top = $28 - 1

main:
	sei                // disable IRQ

//	lda #<nmi
//	sta $0318          // change NMI vector
//	lda #>nmi          // to our routine
//	sta $0319
//	lda #$00           // stop Timer A
//	sta $dd0e
//	sta $dd04          // set Timer A to 0, after starting
//	sta $dd05          // NMI will occur immediately
//	lda #$81
//	sta $dd0d          // set Timer A as source for NMI
//	lda #$01
//	sta $dd0e          // start Timer A -> NMI

	// From here: NMI DISABLED

	lda #$35           // Disable KERNAL and BASIC ROM
	sta $01

	lda #<nmi
	sta $fffa
	sta $fffc
	lda #>nmi
	sta $fffb
	sta $fffd

	lda #<irq_top      // Setup IRQ vector
	sta $fffe
	lda #>irq_top
	sta $ffff
	lda #%00011011     // Setup screen control:
	                   // Extended background OFF,
	                   // Text mode ON, Screen ON,
		           // Screen height 25 rows,
		           // Vertical scroll = 3
	sta $d011          // Store screen control
	lda #irq_line_top
	sta $d012
	lda #$81
	sta $d01a
	lda #$7f
	sta $dc0d
	sta $dd0d
	asl $d019          // Acknowledge any pending interrupts

	// TODO now, setup irq
	cli

	jmp *
loop:
	inc $0400      // change screen memory, proves computer is alive
	lda #$10       // SPACE pressed?
	and $dc01
	bne nospc      // if not, branch
	lda #$01       // if yes, clear Timer A
	sta $dd0d      // as NMI source
	lda $dd0d      // acknowledge NMI, i.e. enable it
nospc:
	jmp loop       // endless loop

nmi:
	inc $d020      // change border colour, indication for a NMI
break:
	rti            // exit interrupt
	               // (not acknowledged!)


irq_top:
	pha
	txa
	pha
	tya
	pha

	lda #<irq_top_wedge
	sta $fffe
	lda #>irq_top_wedge
	sta $ffff

	inc $d012

	lda #$01
	sta $d019

	tsx
	cli

	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop

irq_top_wedge:
	txs

	ldx #$08
	dex
	bne *-1
	bit $00

	lda $d012
	cmp $d012

	beq *+2

	inc $d020
	dec $d020

	pla
	tay
	pla
	tax
	pla
	rti

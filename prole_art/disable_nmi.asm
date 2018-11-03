// Assembler: KickAssembler v4.19
// source: codebase64.org/doku.php?id=base:nmi_lock

BasicUpstart2(main)

// `Disable NMI' by Ninja/The Dreams/TempesT

main:
	sei          // disable IRQ
	lda #<nmi
	sta $0318    // change NMI vector
	lda #>nmi    // to our routine
	sta $0319
	lda #$00     // stop Timer A
	sta $dd0e
	sta $dd04    // set Timer A to 0, after starting
	sta $dd05    // NMI will occur immediately
	lda #$81
	sta $dd0d    // set Timer A as source for NMI
	lda #$01
	sta $dd0e    // start Timer A -> NMI
	// from here on NMI is disabled
loop:
	inc $0400    // change screen memory, proves computer is alive
	lda #$10     // SPACE pressed?
	and $dc01
	bne nospc    // if not, branch
	lda #$01     // if yes, clear Timer A
	sta $dd0d    // as NMI source
	lda $dd0d    // acknowledge NMI, i.e. enable it
nospc:
	jmp loop     // endless loop

nmi:
	inc $d020    // change border colour, indication for a NMI
	rti          // exit interrupt
	             // (not acknowledged!)

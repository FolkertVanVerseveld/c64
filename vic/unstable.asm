// Assembler: KickAssembler
// Poging voor stabiele raster bars... :S
// source: http://codebase64.org/doku.php?id=base:making_stable_raster_routines

BasicUpstart2(start)

.var brkFile = createFile("breakpoints.txt")

.macro break() {
	.eval brkFile.writeln("break " + toHexString(*))
}

// Select the video timing (processor clock cycles per raster line)
//.var cycles = 65 // 6567R8 and above, NTSC-M
//.var cycles = 64 // 6567R5 6A, NTSC-M
.var cycles = 63 // 6569 (all revisions), PAL-B

.var raster = 52 // start of raster interrupt
.var m = $fb // zero page variable

.var nmi = nmi_lda + 1
.var oldirq = oldptr + 1

	* = $0810 "start"
start:
	jmp install
	jmp *
install: // install the raster routine
	jsr restore // Disable the Restore key (disable NMI interrupts)
checkirq:
	lda $0314 // check the original IRQ vector
	ldx $0315 // (to avoid multiple installation)
	cmp <irq1
	bne irqinit
	cpx #>irq1
	beq skipinit
irqinit:
	sei
	sta oldirq // store the old IRQ vector
	stx oldirq+1
	lda #<irq1
	ldx #>irq1
	sta $0314 // set the new interrupt vector
	sta $0315
skipinit:
	lda #$1b
	sta $d011 // set the raster interrupt location
	lda #raster
	sta $d012
	ldx #$e
	clc
	adc #3
	tay
	lda #0
	sta m
!l:
	lda m
	sta $d000, x // set the sprite X
	adc #24
	sta m
	tya
	sta $d001, x // add Y coordinates
	dex
	dex
	bpl !l-
	lda #$7f
	sta $dc0d // disable timer interrupts
	sta $dd0d
	ldx #1
	stx $d01a // enable raster interrupt
	lda $dc0d // acknowledge CIA interrupts
	lsr $d019 // and video interrupts
	ldy #$ff
	sty $d015 // turn on all sprites
	cli
	rts
deinstall:
	sei // disable interrupts
	lda #$1b
	sta $d011 // restore text screen mode
	lda #$81
	sta $dc0d // enable Timer A interrupts on CIA 1
	lda #0
	sta $d01a // disable video interrupts
	lda oldirq
	sta $0314 // restore old IRQ vector
	lda oldirq + 1
	sta $0315
	bit $dd0d // re-enable NMI interrupts
	cli
	rts

// Auxiliary raster interrupt (for synchronization)
irq1:
// irq (event) // > 7 + at least 2 cycles of last instruction (9 to 16 total)
// pha
// txa
// pha
// tya
// pha
// tsx
// lda $0104, x
// and #xx
// beq
// jmp ($0314)
// ---
// 38 to 45 cycles delay at this stage
	break()
	lda #<irq2
	sta $0314
	lda #>irq2
	sta $0315
	nop // waste at least 12 cycles
	nop // (up to 64 bytes delay allowed here)
	nop
	nop
	nop
	nop
	inc $d012 // At this stage, $d012 has already been incremented by one.
	lda #1
	sta $d019 // acknowledge the first raster interrupt
	cli // enable interrupts (the second interrupt can now occur)
	ldy #9
	dey
	bne * - 1 // delay
	nop // The second interrupt will occur while executing these
	nop // two-cycle instructions.
	nop
	nop
	nop
oldptr: // Placeholer for self-modifying code
	jmp * // Return the original interrupt

// Main raster interrupt
irq2:
// irq(event)
// pha
// txa
// pha
// tya
// pha
// tsx
// lda $0104, x
// and #xx
// beq
// jmp ($0314)
// ---
// 38 to 39 cycles delay at this stage
	break()
	lda #<irq1
	sta $0314
	lda #>irq1
	sta $0315
	ldx $d012
	nop
.if (cycles == 63) {
	.if (cycles == 64) {
		nop // 6567R8, 65 cycles/line
		bit $24
	} else {
		nop // 6567R56A, 64 cycles/line
		nop
	}
} else {
	bit $24 // 6569, 63 cycles/line
}
	cpx $d012 // The comparison cycle is executed CYCLES or CYCLES+1 cycles
	// after the interrupt has occurred.
	beq * + 2 // Delay by one cycle if $d012 hadn't changed.
	// Now exactly CYCLES+3 cycles have passed since the interrupt.
	dex
	dex
	stx $d012 // restore original raster interrupt position
	ldx #1
	stx $d019 // acknowledge the raster interrupt
	ldx #2
	dex
	bne * - 1
	nop
	nop
	lda #20 // set the amount of raster lines-1 for the loop
	sta m
	ldx #$c8
irqloop:
	ldy #2
	dey
	bne * - 1 // delay
	dec $d016 // narrow the screen (exact timing required)
//
// FIXME schema
//
	stx $d016 // expand the screen
.if (cycles == 63) {
	.if (cycles == 64) {
		bit $24 // 6567R8
	} else {
		nop // 6567R56A
	}
} else {
	nop // 6569
}
	dec m
	bmi endirq
	clc
	lda $d011
	sbc $d012
	bne irqloop // This instruction takes 4 cycles instead of 3.
	// because the page boundary is crossed.
badline:
	dec m
	nop
	nop
	nop
	nop
	dec $d016
// FIXME schema
	stx $d016
// FIXME schema
	ldy #2
	dey
	bne * - 1
	nop
	nop
.if (cycles == 63) {
	.if (cycles == 64) {
		nop // 6567R8, 65 cycles/line
		nop
		nop
	} else {
		bit $24 // 6567R56A, 64 cycles/line
	}
} else {
	nop // 6569, 63 cycles/line
}
	dec m
	bpl irqloop // This is a 4-cycle branch (page boundary crossed)
endirq:
	jmp $ea81 // return to the auxiliary raster interrupt

restore:
	lda $0318
	ldy $0319
	pha
	lda #<nmi
	sta $0318
	lda #>nmi
	sta $0319
	ldx #$81
	stx $dd0d // Enable CIA 2 Timer A interrupt
	ldx #0
	stx $dd05
	inx
	stx $dd04 // Prepare Timer A to count from 1 to 0.
	ldx #$dd
	stx $dd0e // Cause an interrupt.
nmi_lda:
	lda #$40 // RTI placeholder
	sta $0318
	sty $0319 // restore original NMI vector (although it won't be used)
	pla
	break()
	rts

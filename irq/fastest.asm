// Assembler: KickAssembler 4.4
// fastest way to serve raster interrupt
// source: http://codebase64.org/doku.php?id=base:introduction_to_raster_irqs

	sta atmp + 1
	stx xtmp + 1
	sty ytmp + 1

	lsr $d019 // as stated earlier this might fail only on exotic HW like c65 etc.
	          // lda #$ff sta $d019 is equally fast, but uses two more bytes and
	          // trashes A
atmp:
	lda #$00
xtmp:
	ldx #$00
ytmp:
	ldy #$00

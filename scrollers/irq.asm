irq_init:
	// zet irq klaar
	sei
	lda #<irq
	sta $0314
	lda #>irq
	sta $0315
	// zorg dat de irq gebruikt wordt
	asl $d019

	// geen idee wat dit precies doet
	// het zet alle interrupts eerst uit en dan
	// de volgende aan: timer a, timer b, flag pin, serial shift
	lda #$7b
	sta $dc0d

	// zet raster interrupt aan
	lda #$81
	sta $d01a

	// bit-7 van de te schrijven waarde is bit-8 van de interruptregel (hier 0)
	// tekst mode (bit-5 uit)
	// scherm aan (bit-4 aan)
	// 25 rijen (bit-3 aan)
	// y scroll = 3 (bits 0-2)
	lda #$1b
	sta $d011

	// de onderste 8-bits van de interruptregel.
	// dus: regel $80 (128)
	lda #$80
	sta $d012

	// vanaf nu kunnen de interrupts gevuurd worden
	cli

	rts

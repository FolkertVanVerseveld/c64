// Assembler: KickAssembler 4.4
// busy wait till rasterline gets hit

BasicUpstart2(start)

.var line = 40

	* = $0810 "start"
start:
	lda #line
wait:
	cmp $d012
	bne wait
	// change border and waste some cycles
	inc $d020
	ldx #0
!l:
	inx
	bne !l-
	dec $d020
	jmp start

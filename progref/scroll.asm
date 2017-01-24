// converted from BASIC from the Commodore 64 Programmer's reference guide page 123
.pc = $0801 "Basic Upstart Program"
:BasicUpstart($0810)

.pc = $0810 "Main Program"

	// enable 24 row mode
	lda $d011
	and #$f7
	sta $d011
	// clear screen
	ldx #0
	lda #' '
!l:
	sta $0400, x
	sta $0500, x
	sta $0600, x
	sta $06c0, x
	inx
	bne !l-
	// setup scroll
	lda $d011
	and #$f8
	clc
	adc #7
	sta $d011
	// print hello
	lda #'h'
	sta $0798
	lda #'e'
	sta $0799
	lda #'l'
	sta $079a
	sta $079b
	lda #'o'
	sta $079c
	// scroll kernel
loop:
	ldx #6
!l:
	stx scrolly
	lda $d011
	and #$f8
	clc
	adc scrolly
	sta $d011
.for (var i = 0; i < 4; i++) {
!wait:
	bit $d011
	bpl !wait-
!wait:
	bit $d011
	bmi !wait-
}
	dex
	bne !l-
	jmp loop
scrolly:
	.byte 0

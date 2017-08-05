// Assembler: KickAssembler 4.4
// source: http://codebase64.org/doku.php?id=base:16bit_addition_and_subtraction

.var num1lo = $62
.var num1hi = $63
.var num2lo = $64
.var num2hi = $65
.var resultlo = $66
.var resulthi = $67

// 16-bit addition zero page

add16:
	clc
	lda num1lo
	adc num2lo
	sta reslo
	lda num1hi
	adc num2hi
	sta reshi
	rts

// 16-bit subtraction zero page

sub16:
	sec
	lda num1lo
	sbc num2lo
	sta reslo
	lda num1hi
	sbc num2hi
	sta reshi
	rts

// add 8-bit constant to 16-bit number

add8_16:
	clc
	lda num1lo
	adc #40     // the constant
	sta num1lo
	bcc !ok+
	inc num1hi
!ok:
	rts

// add signed 8-bit to 16-bit number
// source: http://codebase64.org/doku.php?id=base:signed_8bit_16bit_addition

	ldx #$00 // implied high byte of delta
	lda delta // the signed 8-bit number
	bpl !l+
	dex // high byte becomes $ff to reflect negative delta
!l:
	clc
	adc num1lo // normal 16-bit addition
	sta num1lo
	txa
	adc num1hi
	sta num1hi

// Assembler: KickAssembler v4.19
BasicUpstart2(main)

.var brkFile = createFile("breakpoints.txt")
.macro break() {
.eval brkFile.writeln("break " + toHexString(*))
}

.var vic = $0000
.var screen = vic + $0400

.var num1lo = $62
.var num1hi = $63
.var num2lo = $64
.var num2hi = $65
.var reslo = $66
.var reshi = $67

.var remlo = $68
.var remhi = $69

.var quotlo = $6a
.var quothi = $6b

// input for div40
.var numerator = $6c

main:
	break()
	lda #$69
	sta numerator
	lda #$02
	sta numerator + 1
	jsr div40
	// show result
	lda quotlo
	sta screen + 0 * 40 + 0
	lda quothi
	sta screen + 0 * 40 + 1
	lda reslo
	sta screen + 1 * 40 + 0
	lda reshi
	sta screen + 1 * 40 + 1
	jmp *

// only works for 0 <= numerator <= 1024, denominator == 40
div40:
	// divisor = denominator << 4 == 0x280
	// parity_mask = 0x800 (can probably inline this)
	ldx #5 // setup loop counter
	lda #0 // quotient = 0
	sta quotlo
	sta quothi
	lda #$80 // num2 = divisor = 0x280
	sta num2lo
	lda #$02
	sta num2hi
	lda numerator // num1 = numerator
	sta num1lo
	lda numerator + 1
	sta num1hi
!l:
	// remainder_next = remainder - divisor
	jsr sub16
	// left shift quotient
	clc
	rol quotlo
	rol quothi
	// check if remainder_next < 0
	lda reshi
	// FIXME convert bpl to bmi if evertyhing works
	bpl !sll+
	// implicit: remainder_next = remainder
	jmp !step+
!sll:
	// remainder = remainder_next
	lda reslo
	sta num1lo
	lda reshi
	sta num1hi
	// quotient |= 1
	lda #1
	ora quotlo
	sta quotlo
!step:
	// right shift divisor
	lsr num2hi
	ror num2lo
	dex
	bne !l-
	rts

sub16:
	sec
	lda num1lo
	sbc num2lo
	sta reslo
	lda num1hi
	sbc num2hi
	sta reshi
	rts

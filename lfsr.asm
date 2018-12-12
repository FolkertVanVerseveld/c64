// Assembler: KickAssembler v4.19
BasicUpstart2(main)

.var vic = $0000
.var screen = vic + $0400

.var lfsr_low = $80
.var lfsr_high = $81

.var lfsr_bit = $82

.var brkFile = createFile("breakpoints.txt")
.macro break() {
.eval brkFile.writeln("break " + toHexString(*))
}

main:
	// initialize and show start state
	jsr lfsr_init
	lda lfsr_low
	sta screen + 0 * 40 + 0
	lda lfsr_high
	sta screen + 0 * 40 + 1
	jsr lfsr_next
	lda lfsr_low
	sta screen + 1 * 40 + 0
	lda lfsr_high
	sta screen + 1 * 40 + 1
	jsr lfsr_next
	lda lfsr_low
	sta screen + 2 * 40 + 0
	lda lfsr_high
	sta screen + 2 * 40 + 1
	jmp *

lfsr_init:
	lda #$69
	sta lfsr_low
	lda #$02
	sta lfsr_high
	rts

	// bit = ((lfsr >> 0) ^ (lfsr >> 2) ^ (lfsr >> 3) ^ (lfsr >> 5)) & 1
	// lfsr = (lfsr >> 1) | (bit << 9)
lfsr_next:
	break()
	lda lfsr_low // bit = lfsr
	sta lfsr_bit // lfsr_bit = lfsr
	lsr lfsr_bit // lfsr_bit >>= 1
	lsr lfsr_bit // lfsr_bit >>= 1
	eor lfsr_bit // bit ^= lfsr_bit
	lsr lfsr_bit // lfsr_bit >>= 1
	eor lfsr_bit // bit ^= lfsr_bit
	lsr lfsr_bit // lfsr_bit >>= 1
	lsr lfsr_bit // lfsr_bit >>= 1
	eor lfsr_bit // bit ^= lfsr_bit
	clc
	ror lfsr_high // lfsr_high >>= 1
	ror lfsr_low  // lfsr_low >>= 1
	and #$01 // bit &= 1
	bcc !s+ // add bit << 9 if bit ninzero
	lda #$02
	ora lfsr_high
	sta lfsr_high
!s:
	rts

// Assembler: KickAssembler 4.4
// source: http://codebase64.org/doku.php?id=base:8bit_multiplication_8bit_product

// General 8bit * 8bit = 8bit multiply
// Multiplies "num1" by "num2" and returns result in .A

// by White Flame (aka David Holz) 20030207

// Input variables:
//   num1 (multiplicand)
//   num2 (multiplier), should be small for speed
//   Signedness should not matter

// .X and .Y are preserved
// num1 and num2 get clobbered

.var num1 = $60
.var num2 = $61

// Instead of using a bit counter, this routine ends when num2 reaches zero, thus saving iterations.

	lda #$00
	beq !loop_start+

!add:
	clc
	adc num1

!loop:
	asl num1
!loop_start: // For an accumulating multiply (.A = .A + num1*num2), set up num1 and num2, then enter here
	lsr num2
	bcs !add-
	bne !loop-

// 15 bytes

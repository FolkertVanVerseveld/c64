// Assembler: KickAssembler 4.4
// All made by myself

BasicUpstart2(start)

// constant variables
.const colram = $d800
.const vicbase = $d000
.const sidbase = $d400

// dynamic variables

// program entry
start:
	jsr breakout_init

!l:
	inc $d020
	jmp !l-

// zero sid registers
clear_sid:
	lda #0
	ldx #$1c
!loop:
	sta sidbase, x
	dex
	bpl !loop-
	rts

* = $1000 "breakout"
#import "breakout.asm"

.pc = $0801 "Basic Upstart Program"
:BasicUpstart($0810)

.pc = $0810 "Main Program"

.const screen  = $0400
.const colram  = $d800
.const sidbase = $d400

/* init */

	// make sure we enter known processor state
	cld
	lda #%00110111 // #$37 is default memory map
	sta $1         // datasette off, I/O at $D000-$DFFF
	               // BASIC  ROM visible at $A000-$BFFF
	               // KERNAL ROM visible at $E000-$FFFF
// init
	lda #%11001000 // disable multicolor
	sta $d016
	lda #%00010101 // default memory setup
	sta $d018
	jsr clear_sid
	jsr idle
// main
	ldx #160 // filled square
main:
!strptr:
	stx screen
	// increment pointer
	inc !strptr- + 1
	bne !next+
	inc !strptr- + 2
!next:
	jsr idle
	lda !strptr- + 2
	cmp #$07
	bne main
	lda !strptr- + 1
	cmp #$e8
	bne main
done:
	inc $d020
	jmp done

idle:
!wait:
	bit $d011
	bmi !wait-
!wait:
	bit $d011
	bpl !wait-
	rts

clear_sid:
	lda #0
	ldx #$1c
!loop:
	sta sidbase, x
	dex
	bpl !loop-
	rts

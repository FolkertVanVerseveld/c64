// converted from BASIC from the Commodore 64 Programmer's reference guide page 123
.pc = $0801 "Basic Upstart Program"
:BasicUpstart($0810)

.pc = $0810 "Main Program"

	lda $d018
	ora #8
	sta $d018
	lda $d011
	ora #32
	sta $d011
	// clear bitmap to black
	ldx #0
	lda #0
!l:
.for (var i = 0; i < 32; i++) {
	sta $2000 + $100 * i, x
}
	inx
	bne !l-
	// current screen still has some characters on it
	// remove these and set background to cyan
	ldx #0
	lda #3
!l:
	sta $0400, x
	sta $0500, x
	sta $0600, x
	sta $0700, x
	inx
	bne !l-
loop:
	jmp loop

// converted from BASIC from the Commodore 64 Programmer's reference guide page 117
.pc = $0801 "Basic Upstart Program"
:BasicUpstart($0810)

.pc = $0810 "Main Program"

	lda #1
	sta $d021
	lda #3
	sta $d022
	lda #8
	sta $d023
	lda $d016
	ora #16
	sta $d016
	lda #21
	sta $d018
	// clear screen
	ldx #0
!t:
	lda #' '
	sta $0400,x
	sta $0500,x
	sta $0600,x
	sta $0700,x
	inx
	bne !t-
	// store ten black 'A' characters
	ldx #0
!t:
	lda #8
	sta $d800,x
	lda #1
	sta $0400,x
	inx
	cpx #10
	bne !t-
loop:
	jmp loop

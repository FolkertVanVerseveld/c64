// converted from BASIC from the Commodore 64 Programmer's reference guide page 139
.pc = $0801 "Basic Upstart Program"
:BasicUpstart($0810)

.pc = $0810 "Main Program"

	// clear screen
	ldx #0
	lda #' '
!l:
	sta $0400, x
	sta $0500, x
	sta $0600, x
	sta $06e8, x
	inx
	bne !l-
	lda #13
	sta $07f8
	ldx #0
!l:
	lda #129
	sta $340, x
	inx
	cpx #63
	bne !l-
	lda #1
	sta $d015
	sta $d027
	lda #100
	sta $d001
	lda #0
	sta $d010
	lda #100
	sta $d000
loop:
	jmp loop

// converted from BASIC from the Commodore 64 Programmer's reference guide page 119
.pc = $0801 "Basic Upstart Program"
:BasicUpstart($0810)

.pc = $0810 "Main Program"

	// disable keyscan interrupt timer
	lda $dc0e
	and #$fe
	sta $dc0e
	// switch in characters
	lda 1
	and #$fb
	sta 1
	// copy all character rom to ram
	ldx #0
!l:
	txa
	lda $d000,x
	sta $3000,x
	lda $d100,x
	sta $3100,x
	inx
	bne !l-
	// enable keyscan interrupt timer
	lda $dc0e
	ora #1
	sta $dc0e
	// switch in i/o
	lda 1
	ora #4
	sta 1
	// update vic to read character set from ram
	lda $d018
	and #$f0
	clc
	adc #$c
	sta $d018
	// enable multicolor
	lda $d016
	ora #16
	sta $d016
	lda #0
	sta $d021
	lda #2
	sta $d022
	lda #7
	sta $d023

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
	// patch some characters
	ldx #0
!l:
	lda tbl,x
	sta $31e0,x
	inx
	cpx #32
	bne !l-
	// store some characters
	lda #'<'
	sta $0500
	lda #'='
	sta $0501
	lda #'>'
	sta $0528
	lda #'?'
	sta $0529
loop:
	jmp loop
tbl:
	.byte 129, 37, 21, 29, 93, 85, 85, 85
	.byte 66, 72, 84, 116, 117, 85, 85, 85
	.byte 87, 87, 85, 21, 8, 8, 40, 0
	.byte 213, 213, 85, 84, 32, 32, 40, 0

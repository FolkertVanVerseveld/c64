// converted from BASIC from the Commodore 64 Programmer's reference guide page 110
.pc = $0801 "Basic Upstart Program"
:BasicUpstart($0810)

.pc = $0810 "Main Program"

	lda #21
	sta $d018
	lda #$30
	sta $34
	sta $38
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
t:
	txa
	lda $d000,x
	//and #%10101010
	sta $3000,x
	lda $d100,x
	//and #%10101010
	sta $3100,x
	inx
	bne t
	// enable keyscan interrupt timer
	lda $dc0e
	ora #1
	sta $dc0e
	// switch in i/o
	lda 1
	ora #4
	sta 1
	// replace `t' with smiley
	ldx #0
l:
	lda tbl,x
	sta $30a0,x
	inx
	cpx #8
	bne l
	// update vic to read character set from ram
	lda $d018
	and #$f0
	clc
	adc #$c
	sta $d018
loop:
	jmp loop
tbl:
	.byte %00111100
	.byte %01000010
	.byte %10100101
	.byte %10000001
	.byte %10100101
	.byte %10011001
	.byte %01000010
	.byte %00111100

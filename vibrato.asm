// converted from BASIC from the Commodore 64 Programmer's reference guide page 203
.pc = $0801 "Basic Upstart Program"
:BasicUpstart($0810)

.pc = $0810 "Main Program"

.macro delay() {
!wait:
	bit $d011
	bpl !wait-
!wait:
	bit $d011
	bmi !wait-
}

	lda #0
	sta vindex
	// clear sid state
	lda #0
	ldx #0
!l:
	sta $d400, x
	inx
	cpx #$19
	bne !l-
	// setup voice 0
	lda #8
	sta $d403
	lda #41
	sta $d405
	lda #89
	sta $d406
	lda #117
	sta $d40e
	lda #16
	sta $d412
	lda #143
	sta $d418
	// setup kernel
kernel:
	ldx vindex
	lda #65
	sta $d404
	// fetch duration
	txa
	clc
	ror
	tax
	lda dr, x
	rol
	sta dur
	ldx vindex
wait:
	:delay()
	lda $d41b
	clc
	ror
	clc
	// add lower frequency
	adc fr, x
	sta $d400
	// reset acc (and forwarding carry to higher frequency)
	lda #0
	// add higher frequency
	adc fr + 1, x
	sta $d401
	:delay()
	dec dur
	bne wait
	// update index
	inc vindex
	inc vindex
	lda #64
	sta $d404
	:delay()
	// check end of music
	txa
	ror
	cmp #16
	bpl loop
	jmp kernel
loop:
	brk
	jmp loop
vindex:
	.byte 0
dur:
	.byte 0
fr:
	.word  4817,  5103, 5407
	.word  8583,  5407, 8583
	.word  5407,  8583, 9634
	.word 10207, 10814, 8583
	.word  9634, 10814, 8583
	.word  9634,  8583
dr:
	.byte 2,  2, 2
	.byte 4,  2, 4
	.byte 4, 12, 2
	.byte 2,  2, 2
	.byte 4,  2, 2
	.byte 4, 12

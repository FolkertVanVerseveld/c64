// converted from BASIC from the Commodore 64 Programmer's reference guide page 200
.pc = $0801 "Basic Upstart Program"
:BasicUpstart($0810)

.pc = $0810 "Main Program"

.macro small_delay() {
	.for (var i = 0; i < 3; i++) {
	ldy #0
!l:
	iny
	bne !l-
	}
}

	// clear sid state
	lda #0
	ldx #0
!l:
	sta $d400, x
	inx
	cpx #$19
	bne !l-
	// setup voice 1
	lda #128
	sta $d416
	lda #0
	sta $d415
	lda #1
	sta $d417
	lda #9
	sta $d405
	lda #0
	sta $d406
	lda #79
	sta $d418
	ldx #0
kernel:
	lda tune, x
	sta $d401
	inx
	lda tune, x
	sta $d400
	inx
	lda #33
	sta $d404
	lda tune, x
	inx
wait:
	:small_delay()
	tay
	dey
	tya
	bne wait
	lda #32
	sta $d404
	:small_delay()
	cpx #52
	bmi kernel
	brk
loop:
	jmp loop
tune:
	.byte 25, 177, 250 / 3, 28, 214, 250 / 3 // 6
	.byte 25, 177, 250 / 3, 25, 177, 250 / 3 // 12
	.byte 25, 177, 125 / 3, 28, 214, 125 / 3 // 18
	.byte 32,  94, 750 / 3, 25, 177, 250 / 3 // 24
	.byte 28, 214, 250 / 3, 19,  63, 250 / 3 // 30
	.byte 19,  63, 250 / 3, 19,  63, 250 / 3 // 36
	.byte 21, 154, 125 / 3, 24,  63, 125 / 3 // 42
	.byte 25, 177, 250 / 3, 24,  63, 125 / 3 // 48
	.byte 19,  63, 250 / 3 // 51


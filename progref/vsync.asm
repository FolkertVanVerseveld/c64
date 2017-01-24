.pc = $0801 "Basic Upstart Program"
:BasicUpstart($0810)

.pc = $0810 "Main Program"

	lda #21
	sta $d018
	lda #0
loop:
	sta $0400
	clc
	adc #1
// create some delay
.for (var i = 0; i < 8; i++) {
!wait:
	bit $d011
	bpl !wait-
!wait:
	bit $d011
	bmi !wait-
}
	jmp loop

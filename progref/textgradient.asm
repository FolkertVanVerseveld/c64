#import "cbm64mem.inc"
.pc = $0801 "Basic Upstart Program"
:BasicUpstart($0810)

.pc = $0810 "Main Program"

	ldx #$0
loop:
	txa
	sta screen, x
	sta colram, x
	inx
	cpx #27
	bne loop
	rts

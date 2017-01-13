#import "cbm64mem.inc"
.pc = $0801 "Basic Upstart Program"
:BasicUpstart($0810)

.pc = $0810 "Main Program"

	ldx #$0
t:
	txa
	sta screen, x
	lda #1
	sta colram, x
	inx
	bne t
	rts

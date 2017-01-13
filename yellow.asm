#import "cbm64mem.inc"
.pc = $0801 "Basic Upstart Program"
:BasicUpstart($0810)

.pc = $0810 "Main Program"

init:
	lda #$01
	sta screen
	lda #$07
	sta colram
loop:
	inc $d021
	jmp loop

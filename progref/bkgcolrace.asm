#import "cbm64mem.inc"
.pc = $0801 "Basic Upstart Program"
:BasicUpstart($0810)

.pc = $0810 "Main Program"

loop:
	inc vicbkg
	jmp loop

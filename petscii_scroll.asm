.var brkFile = createFile("breakpoints.txt")
.macro break() {
.eval brkFile.writeln("break " + toHexString(*))
}

.pc = $0801 "Basic Upstart Program"
:BasicUpstart($0810)

.pc = $0810 "Main Program"

.const screen  = $0400
// nothing special about this number
.const screen2 = $2400

	cld
	lda #%11001000
	sta $d016
	ldx #1
	jsr idle
	// copy picture to screen
	ldx #$ff
!loop:
	lda picture, x
	sta screen , x
	lda picture + $100, x
	sta screen  + $100, x
	lda picture + $200, x
	sta screen  + $200, x
	lda picture + $2e7, x
	sta screen  + $2e7, x
	dex
	bne !loop-
	ldx #$10
	jsr idle
	// enable 24 row mode
	lda $d011
	and #$F7
	sta $d011

	// scroll
!scroll:
	ldx #7
!loop:
	stx scrolly
	lda $d011
	and #$F8
	clc
	adc scrolly
	sta $d011
	ldx #$1
	jsr idle
	dec scrolly
	ldx scrolly
	bne !loop-
	lda scroll_timer
	beq halt
	// FIXME flicker in double buffer scroll
	lda blit_index
	eor #$1
	sta blit_index
	beq setup_scr
setup_scr2: // unused label, just for convenience
	jsr shift_first_to_second
	lda #%10010101
	sta $d018
	jmp !scroll-
setup_scr:
	jsr shift_second_to_first
	lda #%00010101
	sta $d018
	inc scroll_timer
	jmp !scroll-
halt:
	jmp halt

// index to blit the screen to
// 0 == screen, 1 == screen2
blit_index:
	.byte 0

scrolly:
	.byte 0
scroll_timer:
	.byte $f0
/*******************************************/
/******** DOUBLE BUFFERING ROUTINES ********/
/*******************************************/
shift_first_to_second:
	ldx #0
!loop:
	lda screen  + 40, x
	sta screen2     , x
	lda screen  + $100 + 40, x
	sta screen2 + $100     , x
	lda screen  + $200 + 40, x
	sta screen2 + $200     , x
	lda screen  + $2e8     , x
	sta screen2 + $2e8 - 40, x
	dex
	bne !loop-
	// everything has been shifted
	// now append last row from picture
	ldx #39
!loop:
	lda repeat           , x
	sta screen2 + 24 * 40, x
	dex
	bpl !loop-
	rts

shift_second_to_first:
	ldx #0
!loop:
	lda screen2 + 40, x
	sta screen      , x
	lda screen2 + $100 + 40, x
	sta screen  + $100     , x
	lda screen2 + $200 + 40, x
	sta screen  + $200     , x
	lda screen2 + $2e8     , x
	sta screen  + $2e8 - 40, x
	dex
	bne !loop-
	// everything has been shifted
	// now append last row from picture
	ldx #39
!loop:
	lda repeat           , x
	sta screen  + 24 * 40, x
	dex
	bpl !loop-
	rts

shift:
	ldx #39
!loop:
.for (var i = 0; i < 23; i++) {
	lda screen + i * 40 + 40, x
	sta screen + i * 40     , x
}
	dex
	bmi !ignore+
	jmp !loop-
!ignore:
	// everything has been shifted
	// now append last row from picture
	ldx #39
!loop:
	lda repeat, x
	sta screen + 23 * 40, x
	dex
	bpl !loop-
	inc shifty
	rts
shifty:
	.byte 0
// wait the specified number of frames
// input   : X: number of frames to wait
// destroys: NZV, X
idle:
!wait:
	bit $d011
	bpl !wait-
!wait:
	bit $d011
	bmi !wait-
	dex
	bpl idle
	rts
picture:
//            borderColor":"14","backgroundColor":"6","charset":"uppercase","charData":
//              0   1   2   3   4   5   6   7   8   9  10  11  12  13  14  15  16  17  18  19  20  21  22  23  24  25  26  27  28  29  30  31  32  33  34  35  36  37  38  39
	.byte  32, 32, 32, 78,233,105, 78, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 77, 95,223, 77, 32, 32, 32
	.byte  32, 32, 78,233,105, 78, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 77, 95,223, 77, 32, 32
	.byte  32, 78,233,105, 78, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 77, 95,223, 77, 32
	.byte  78,233,105, 78, 32, 32, 32, 13, 13, 13, 32, 32,  5,  5,  5, 20, 20, 20, 20, 20,  8, 32, 32,  8, 32, 15, 15, 15, 32, 32, 19, 19, 19, 19, 32, 32, 77, 95,223, 77
	.byte 233,105, 78, 32, 32, 32, 13, 32, 13, 32, 13,  5, 32, 32, 32, 32, 32, 20, 32, 32,  8, 32, 32,  8, 15, 15, 32, 15, 15, 19, 32, 32, 32, 32, 32, 32, 32, 77, 95,223
	.byte 105, 78, 32, 32, 32, 32, 13, 32, 13, 32, 13,  5, 32, 32, 32, 32, 32, 20, 32, 32,  8, 32, 32,  8, 15, 32, 32, 32, 15, 19, 32, 32, 32, 32, 32, 32, 32, 32, 77, 95
	.byte  78, 32, 32, 32, 32, 32, 13, 32, 13, 32, 13,  5,  5,  5, 32, 32, 32, 20, 32, 32,  8,  8,  8,  8, 15, 32, 32, 32, 15, 32, 19, 19, 19, 32, 32, 32, 32, 32, 32, 77
	.byte  32, 32, 32, 32, 32, 32, 13, 32, 32, 32, 13,  5, 32, 32, 32, 32, 32, 20, 32, 32,  8, 32, 32,  8, 15, 32, 32, 32, 15, 32, 32, 32, 32, 19, 32, 32, 32, 32, 32, 32
	.byte  32, 32, 32, 32, 32, 32, 13, 32, 32, 32, 13,  5, 32, 32, 32, 32, 32, 20, 32, 32,  8, 32, 32,  8, 15, 15, 32, 15, 15, 32, 32, 32, 32, 19, 32, 32, 32, 32, 32, 32
	.byte  32, 32, 32, 32, 32, 32, 13, 32, 32, 32, 13, 32,  5,  5,  5, 32, 32, 20, 32, 32,  8, 32, 32,  8, 32, 15, 15, 15, 32, 19, 19, 19, 19, 32, 32, 32, 32, 32, 32, 32
	.byte  45, 45, 45, 45, 45, 45, 67, 67,114, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67,114, 67, 67, 45, 45, 45, 45, 45, 45
	.byte  32, 32, 32, 32, 32, 32, 32, 32, 66, 32, 90, 90, 90, 32, 32, 19,  9, 12, 12, 25, 32,  4,  5, 13, 15, 32, 32, 90, 90, 90, 32, 66, 32, 32, 32, 32, 32, 32, 32, 32
	.byte  32, 32, 32, 32, 32, 32, 32, 32, 74, 67, 67, 67, 67, 67, 67, 67, 67, 67,114, 67, 67,114, 67, 67, 67, 67, 67, 67, 67, 67, 67, 75, 32, 32, 32, 32, 32, 32, 32, 32
	.byte  32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 66,127,127, 66, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32
	.byte  32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 66,127,127, 66, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32
	.byte  32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 66,127,127, 66, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 40, 81, 41, 32, 32, 32, 32
	.byte  32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32,233,223, 32, 32, 32, 32, 32, 66,127,127, 66, 32, 32, 32, 85, 73, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32
	.byte  32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 95,105,233,223, 32, 32, 32, 66,127,127, 66, 32, 32, 32, 74, 75, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32
	.byte  32, 32, 32, 32,233,247,123, 32, 32, 32, 32, 32, 32, 95,105, 32, 32, 32, 66,127,127, 66, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32
	.byte  32, 32, 32,233,160,213,238, 32, 32, 32, 32, 32, 32, 32, 32,233,223, 32, 66,127,127, 66, 32, 32, 32, 32, 32, 81, 32, 32, 32,108, 98, 98, 98,123, 32, 32, 32, 32
	.byte  32, 32, 32,160,213, 32, 32,160,105, 32, 32, 32, 32, 32, 32, 95,105, 32, 66,127,127, 66, 32, 32, 32, 32, 32, 32, 32, 32, 32,225,160,160,160, 97, 32, 32, 32, 32
	.byte  32, 32, 32,160,202, 32, 32,160,223, 32, 32, 32, 32, 32, 32, 32, 32, 32, 66,127,127, 66, 32, 32, 32, 32, 81, 32, 32, 32, 32,225,160,209,160, 97, 32, 32, 32, 32
	.byte  32, 32, 32, 95,160,202,253, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 66,127,127, 66, 32, 32, 32, 32, 32, 32, 32, 32, 32,225,160,158,160, 97, 32, 32, 32, 32
	.byte  32, 32, 32, 32, 95,239,126, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 66,127,127, 66, 32, 32, 32, 32, 32, 46, 32, 32, 32,124,226,226,226,126, 32, 32, 32, 32
repeat:
	.byte  32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 66,127,127, 66, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32, 32

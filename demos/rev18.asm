:BasicUpstart2(start)

// FIXME remove brown/yellow ish border
// FIXME update text

.const screen  = $0400
.const colram  = $d800
.const sidbase = $d400

.var methos = LoadBinary("methos.koa", BF_KOALA)

.var music = LoadSid("4Ten5.sid")

.const line_scroll = $78
.const line_music = $83

.var brkFile = createFile("breakpoints.txt")

.var vic = $2000
.var bitmap = vic + 0
.var spr_data = vic + $2400
.var font = vic + $3000

.macro break() {
	.eval brkFile.writeln("break " + toHexString(*))
}

start:
	// make sure we enter known processor state
	cld
	lda #%00110111 // #$37 is default memory map
	sta $1         // datasette off, I/O at $D000-$DFFF
	               // BASIC  ROM visible at $A000-$BFFF
	               // KERNAL ROM visible at $E000-$FFFF
// init
	lda #%11001000 // disable multicolor
	sta $d016
	lda $d018
	sta old
	lda #%00010101 // default memory setup
	sta $d018
	jsr clear_sid
	ldx #$01
	jsr idle
	jsr fill
	jsr fade
// setup first tune
	lda #$00
	tax
	tay
	jsr $1000
	jsr irq_init
// prepare first image
	jsr first
	jmp *
old:
	.byte 0
irq_init:
	sei
	lda #<irq
	sta $0314
	lda #>irq
	sta $0315
	asl $d019
	lda #$7b
	sta $dc0d
	lda #$81
	sta $d01a
	lda #$1b
	sta $d011
	lda #line_scroll
	sta $d012
	cli
	rts
irq:
	lda #$0
	sta $d021
	// setup next interrupt
	lda #<irq2
	sta $0314
	lda #>irq2
	sta $0315
	lda #line_music
	sta $d012
	// acknowledge interrupt
	asl $d019
	// back to text
	lda $d011
	and #%11011111
	sta $d011
	lda old
	sta $d018
	// set scroll
	jsr set_scroll
	pla
	tay
	pla
	tax
	pla
	rti
irq2:
	lda #$0
	sta $d020
	sta $d021
	nop
	nop
	nop
	// restore bitmap mode
	lda #$3b
	sta $d011
	lda #$d8
	sta $d016
	// restore first interrupt
	lda #<irq
	sta $0314
	lda #>irq
	sta $0315
	lda #line_scroll
	sta $d012
	lda #$38
	// 0011 1000
	// screen at 3: $0c00-$0fff
	// bitmap at 4: $2000-$3fff
	sta $d018
	// acknowledge interrupt
	asl $d019
	// debugging purposes
	jsr music.play
	jsr move_scroll
	pla
	tay
	pla
	tax
	pla
	rti
fill:
	lda #160
	// top row
	ldx #39
!loop:
toprow:
	sta screen, x
	dex
	bpl !loop-
	// bottom row
	ldx #39
!loop:
btmrow:
	sta screen + 24 * 40, x
	dex
	bpl !loop-
	ldx #$02
	jsr idle
	// update top row
	clc
	lda #40
	adc toprow + 1
	sta toprow + 1
	bcc !no_inc+
	inc toprow + 2
!no_inc:
	// update bottom row
	sec
	lda btmrow + 1
	sbc #40
	sta btmrow + 1
	bcs !no_dec+
	dec btmrow + 2
!no_dec:
	dec fill_y
	beq !done+
	jmp fill
!done:
	rts
fill_y:
	.byte 13
fade:
	ldy #$00
!loop2:
	lda fade_out_tbl, y
	ldx #$00
!loop:
.for (var i = 0; i < 4; i++) {
	sta colram + i * $0100, x
}
	dex
	bne !loop-
	sta $d020
	ldx #$02
	jsr idle
	iny
	cpy #$07
	bne !loop2-

	// clear screen
	lda $d020
	sta $d021
	lda #$20
	ldx #$00
!loop:
	sta screen        , x
	sta screen + $0100, x
	sta screen + $0200, x
	sta screen + $02e8, x
	dex
	bne !loop-
	rts

fade_out_tbl:
	.byte $08, $04, $0b, $02, $09, $06, $00

first:
	// setup VIC at bank 0
	lda $dd00
	and #$fc
	eor #$03
	sta $dd00
	// setup screen and bitmap
	lda #$38
	// 0011 1000
	// screen at 3: $0c00-$0fff
	// bitmap at 4: $2000-$3fff
	sta $d018
	lda #$d8
	sta $d016
	lda #$3b
	sta $d011
	lda #BLACK
	sta $d020
	lda #methos.getBackgroundColor()
	sta $d021
	ldx #0
!loop:
.for (var i = 0; i < 4; i++) {
	lda methos_colram + i * $100, x
	sta $d800         + i * $100, x
}
	inx
	bne !loop-

	// now put some text in default screen
	ldx #$00
	lda #' '
!loop:
	sta $0400, x
	sta $0500, x
	sta $0600, x
	sta $06e8, x
	dex
	bne !loop-

	ldx #40
	lda #0
!loop:
	sta $d93f, x
	sta $d98f, x
	dex
	bne !loop-
	rts

idle:
!wait:
	bit $d011
	bmi !wait-
!wait:
	bit $d011
	bpl !wait-
	dex
	bpl idle
	rts

clear_sid:
	lda #0
	ldx #$1c
!loop:
	sta sidbase, x
	dex
	bpl !loop-
	rts

set_scroll: {
value:
	lda #0
	and #$07
	ora #$c0
	sta $d016
	rts
}

move_scroll: {
	dec set_scroll.value + 1
	lda set_scroll.value + 1
	and #$07
	cmp #$07
	bne !exit+

	ldx #0
!loop:
	lda screen + 9 * 40 + 1, x
	sta screen + 9 * 40, x
	inx
	cpx #39
	bne !loop-
!ptr:
	lda text
	cmp #$ff
	bne !next+
	// reset pointer
	lda #<text
	sta !ptr- + 1
	lda #>text
	sta !ptr- + 2
	lda #' '
	jmp !skip+
!next:
	// increment pointer
	inc !ptr- + 1
	bne !skip+
	inc !ptr- + 2
!skip:
	sta screen + 9 * 40 + 39
	lda set_scroll.value + 1
!exit:
	sta set_scroll.value + 1
	rts
}

*=$0c00	"Methos ScreenRam";
	.fill methos.getScreenRamSize(), methos.getScreenRam(i)

.pc = music.location "Music"
.fill music.size, music.getData(i)

*=$4c00	"Methos ColorRam:";
methos_colram:
	.fill methos.getColorRamSize(), methos.getColorRam(i)

* = font "font"

	.import binary "aeg_collection_05.64c", 2

* = bitmap "Methos Bitmap";
	.fill methos.getBitmapSize(), methos.getBitmap(i)

text:
	.text " hey daar! methos here, this is my first demo and compofiller. "
	.text "code by methos, music by mhd, loader by krill "
	.text "text loops now   - "
	.byte $ff

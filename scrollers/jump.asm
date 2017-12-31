// Assembler: KickAssembler 4.4
// jumping text

.var irq_line = $d0

.var scr_clear_char = ' '
.var scr_clear_color = $0f

.var screen = $400
.var colram = $d800

.var jump_start_row = 2
.var jump_start_col = 10

.var jump_rows = 14

.var jump_start = screen + jump_start_row * 40 + jump_start_col
.var jump_start_colram = colram + jump_start_row * 40 + jump_start_col

.var vic = $0
.var font = vic + $2000

.var debug = false

BasicUpstart2(start)

start:
	jsr scr_clear
	lda #$00
	sta $d020
	sta $d021
	jsr text_init
	jsr irq_init
	jmp *

// FIXME remove copy stuff if scroll is working
text_init:
	ldx #$00
!l:
	lda jump_text, x
	sta jump_start, x
	lda #1
	.for (var j = 0; j < jump_rows; j++) {
	sta jump_start_colram + j * 40, x
	}
	inx
	cpx #19
	bne !l-

	// screen at $400, font bitmap at $2000
	lda #%00011000
	sta $d018

	rts

irq:
	asl $d019
	.if (debug) {
	inc $d020
	}
jump_ptr:
	jsr jump
	.if (debug) {
	dec $d020
	}
	pla
	tay
	pla
	tax
	pla
	rti

jump:
	lda jump_ypos
	clc
	adc jump_vspeed
	and #$07
	sta jump_ypos
	cmp jump_vspeed
	bmi !l+
!b:
	lda #%00011000
	ora jump_ypos
	sta $d011
	inc jump_vspeed
	rts
!l:
	jsr move_down
	jmp !b-

jump_up:
	lda jump_ypos
	sec
	sbc jump_vspeed
	//sbc #1
	and #$07
	sta jump_ypos
	cmp jump_vspeed
	bmi !l+
!b:
	lda #%00011000
	ora jump_ypos
	sta $d011
	dec jump_vspeed
	rts
!l:
	jsr move_up
	lda #7
	sec
	sbc jump_ypos
	sta jump_ypos
	jmp !b-

move_down:
	.for (var j = jump_rows - 1; j >= 0; j--) {
	.for (var i = 0; i < 40 - jump_start_col; i++) {
	lda jump_start + i + 40 * j
	sta jump_start + i + 40 * j + 40
	}
	}
	lda #' '
	.for (var i = 0; i < 40 - jump_start_col; i++) {
	sta jump_start + i
	}
	inc jump_row
	lda #jump_rows
	cmp jump_row
	bne !l+
	// reverse direction
	lda #0
	sta jump_row
	lda #<jump_up
	sta jump_ptr + 1
	lda #>jump_up
	sta jump_ptr + 2
	lda #jump_rows
	sta jump_row
!l:
	rts

move_up:
	dec jump_row
	bne !l+
	jmp !rev+
!l:
	.for (var j = 1; j <= jump_rows; j++) {
	.for (var i = 0; i < 40 - jump_start_col; i++) {
	lda jump_start + i + 40 * j
	sta jump_start + i + 40 * j - 40
	}
	}
	lda #' '
	.for (var i = 0; i < 40 - jump_start_col; i++) {
	sta jump_start + i + 40 * jump_rows
	}
	rts

!rev:
	// reverse direction
	lda #1
	sta jump_row
	sta jump_ypos
	lda #1
	sta jump_vspeed
	// revert pointer
	lda #<jump
	sta jump_ptr + 1
	lda #>jump
	sta jump_ptr + 2
	rts

jump_ypos:
	.byte 0
jump_vspeed:
	.byte 1
jump_row:
	.byte 0

#import "screen.asm"

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
	lda #%00011000
	sta $d011
	lda #irq_line
	sta $d012
	cli
	rts

.align $100

jump_text:
	.text "deze tekst springt!"
	.byte $ff

	* = font "font"

	.import binary "chars_02.64c", 2

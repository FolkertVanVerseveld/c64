// Assembler: KickAssembler v4.19

BasicUpstart2(main)

.var brkFile = createFile("breakpoints.txt")
.macro break() {
.eval brkFile.writeln("break " + toHexString(*))
}

#import "pseudo.lib"

.var irq_line_top = $20
.var tmp = $ff

// characters:
//
// $40  ---
//
//       |
// $42   |
//       |
//
// $55   /-
//       |
//
// $49  -\
//       |
//       |
// $4a   \-
//
//       |
// $4b  -/
//
//       *
// $51  ***
//       *
main:
	jsr clear
	jsr snake_init

	// inline: setup irq
		mov #$35 : $01            // <- Notice how different addressing modes can be used
		mov16 #irq_top : $fffe		  // <- 16 bit commands (or higher) can also be made
		mov #$1b : $d011
		mov #irq_line_top : $d012
		mov #$81 : $d01a
		mov #$7f : $dc0d
		mov #$7f : $dd0d
		lda $dc0d
		lda $dd0d
		mov #$ff : $d019
		cli

	jmp *

// clear screen
clear:
	lda #' '
	ldx #0
!l:
	sta $0400, x
	sta $0500, x
	sta $0600, x
	sta $06e8, x
	inx
	bne !l-
	rts

snake_init:
	lda #$e0
	jsr next_dot
	// remember our position
	mov dot_y : snake_y
	mov dot_x : snake_x
	mov16 dot_pos : snake_pos
	// setup target
	lda #$51
	jsr next_dot
	rts

next_dot:
	tay
	ldx dot_index
!l:
	// setup store address and save it elsewhere
	lda dots_low, x
	sta !put+ + 1
	sta dot_pos
	lda dots_high, x
	sta !put+ + 2
	sta dot_pos + 1
	// save y and x
	lda dots_y, x
	sta dot_y
	lda dots_x, x
	sta dot_x
	tya
!put:
	sta $0400
	// dot_index = (dot_index + 1) % 32
	inx
	txa
	and #31
	sta dot_index
	rts

step:
	// TODO change direction after some steps
snake_step:
	// check for xwrap
	ldx snake_dir
	lda fptr_snake, x
	sta !fptr+ + 1
	lda fptr_snake + 1, x
	sta !fptr+ + 2
!fptr:
	jsr !hang+

	// advance head
	lda snake_dp
	clc
	adc snake_pos
	sta snake_pos
	lda snake_dp + 1
	adc snake_pos + 1
	sta snake_pos + 1

	// update head
	lda snake_pos
	sta !fetch_head+ + 1
	sta !put_head+ + 1
	lda snake_pos + 1
	sta !fetch_head+ + 2
	sta !put_head+ + 2
!fetch_head:
	lda $0400
	cmp #$e0
	beq !die+
	cmp #$51
	bne !move+
	lda #$51
	jsr next_dot
!move:
	lda #$e0
!put_head:
	sta $0400
!hang:
	rts
!die:
	jsr clear
	jsr snake_init
	rts

dot_index:
	.byte 0
dot_pos:
	.word 0
dot_y:
	.byte 0
dot_x:
	.byte 0
snake_pos:
	.word 0
snake_y:
	.byte 0
snake_x:
	.byte 0
snake_dir:
	.byte 0
snake_dp:
	.word 0

.align $100

// precalculated random locations for dots
dots_low:
	.byte $34, $9A, $4D, $26, $13, $89, $44, $A2, $D1, $68, $34, $1A, $8D, $46, $23, $91, $C8, $E4, $72, $39, $9C, $CE, $E7, $F3, $F9, $FC, $7E, $BF, $5F, $AF, $57, $AB
dots_high:
	.byte $05, $04, $04, $06, $05, $06, $07, $05, $04, $04, $06, $05, $04, $06, $07, $07, $05, $04, $06, $07, $07, $07, $07, $04, $05, $06, $05, $06, $05, $06, $07, $07
dots_y:
	.byte $07, $03, $01, $0D, $06, $10, $14, $0A, $05, $02, $0E, $07, $03, $0E, $14, $16, $0B, $05, $0F, $14, $17, $18, $18, $07, $0C, $13, $09, $11, $08, $11, $15, $17
dots_x:
	.byte $1C, $22, $25, $1E, $23, $09, $24, $12, $09, $18, $04, $02, $15, $16, $03, $21, $10, $1C, $1A, $19, $04, $0E, $27, $03, $19, $04, $16, $17, $1F, $07, $0F, $13
// bytes used: 128

fptr_snake:
	.word step_snake_right, step_snake_up, step_snake_left, step_snake_down

irq_top:
	irq
	inc $d020
	jsr step
	dec $d020
	qri

step_snake_right:
	mov #0 : snake_dir
	lda snake_x
	cmp dot_x
	bne !move+
	lda snake_y
	cmp dot_y
	bmi !down+
	beq !next+
	jmp step_snake_up
!next:
!move:
	lda snake_x
	cmp #39
	beq !wrap+
	mov16 #1 : snake_dp
	inc snake_x
	rts
!wrap:
	mov16 #-39 : snake_dp
	mov #0 : snake_x
	rts
!down:
	jmp step_snake_down

step_snake_up:
	mov #2 : snake_dir
	lda snake_y
	cmp dot_y
	bne !move+
	lda snake_x
	cmp dot_x
	bmi !right+
	beq !next+
	jmp step_snake_left
!next:
!move:
	lda snake_y
	beq !wrap+
	mov16 #-40 : snake_dp
	dec snake_y
	rts
!wrap:
	mov16 #24 * 40 : snake_dp
	mov #24 : snake_y
	rts
!right:
	jmp step_snake_right

step_snake_left:
	mov #4 : snake_dir
	lda snake_x
	cmp dot_x
	bne !move+
	lda snake_y
	cmp dot_y
	bmi !down+
	beq !next+
	jmp step_snake_up
!next:
!move:
	lda snake_x
	beq !wrap+
	mov16 #-1 : snake_dp
	dec snake_x
	rts
!wrap:
	mov16 #39 : snake_dp
	mov #39 : snake_x
	rts
!down:
	jmp step_snake_down

step_snake_down:
	mov #6 : snake_dir
	lda snake_y
	cmp dot_y
	bne !move+
	lda snake_x
	cmp dot_x
	bmi !right+
	beq !next+
	jmp step_snake_left
!next:
!move:
	lda snake_y
	cmp #24
	beq !wrap+
	mov16 #40 : snake_dp
	inc snake_y
	rts
!wrap:
	mov16 #-24 * 40 : snake_dp
	mov #0 : snake_y
	rts
!right:
	jmp step_snake_right

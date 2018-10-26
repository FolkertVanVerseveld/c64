// Assembler: KickAssembler v4.19

BasicUpstart2(main)

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
	lda #$40
	jsr next_dot
	// remember our position
	lda dot_y
	sta snake_y
	lda dot_x
	sta snake_x
	// setup target
	lda #$51
	jsr next_dot
	rts

next_dot:
	tay
	ldx dot_index
!l:
	// setup store address
	lda dots_low, x
	sta !put+ + 1
	lda dots_high, x
	sta !put+ + 2
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

dot_index:
	.byte 0
dot_y:
	.byte 0
dot_x:
	.byte 0
snake_y:
	.byte 0
snake_x:
	.byte 0

.align $100

dots_low:
	.byte $34, $9A, $4D, $26, $13, $89, $44, $A2, $D1, $68, $34, $1A, $8D, $46, $23, $91, $C8, $E4, $72, $39, $9C, $CE, $E7, $F3, $F9, $FC, $7E, $BF, $5F, $AF, $57, $AB
dots_high:
	.byte $05, $04, $04, $06, $05, $06, $07, $05, $04, $04, $06, $05, $04, $06, $07, $07, $05, $04, $06, $07, $07, $07, $07, $04, $05, $06, $05, $06, $05, $06, $07, $07
dots_y:
	.byte $07, $03, $01, $0D, $06, $10, $14, $0A, $05, $02, $0E, $07, $03, $0E, $14, $16, $0B, $05, $0F, $14, $17, $18, $18, $07, $0C, $13, $09, $11, $08, $11, $15, $17
dots_x:
	.byte $1C, $22, $25, $1E, $23, $09, $24, $12, $09, $18, $04, $02, $15, $16, $03, $21, $10, $1C, $1A, $19, $04, $0E, $27, $03, $19, $04, $16, $17, $1F, $07, $0F, $13
// bytes used: 128


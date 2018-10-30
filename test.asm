// Assembler: KickAssembler v4.19

BasicUpstart2(main)

.var brkFile = createFile("breakpoints.txt")
.macro break() {
.eval brkFile.writeln("break " + toHexString(*))
}

//.var music = LoadSid("/home/methos/Music/C64Music/MUSICIANS/0-9/20CC/van_Santen_Edwin/13_Seconds_of_Massacre.sid")
.var music = LoadSid("/home/methos/Music/C64Music/MUSICIANS/0-9/20CC/van_Santen_Edwin/Blackmail_Tune_1.sid")
//.var music = LoadSid("/home/methos/Music/C64Music/MUSICIANS/T/Tel_Jeroen/Fun_Fun.sid")
//.var music = LoadSid("fallen_down_b.sid")

#import "pseudo.lib"

.var irq_line_top = $20

.var vic = $0000
.var screen = vic + $0400
.var spr_data = vic + $2400

.var col_delay = 4

.var tmp = $ff
// snake vars
.var grow = 4
.var max_size = 32

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
	lda #0
	jsr music.init
	jsr spr_init

	// inline: setup irq
	mov #$35 : $01
	mov16 #irq_top : $fffe
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

spr_init:
	// sprite logic
	lda #(spr_data - vic + 64 * 0) / 64
	sta screen + $03f8
	lda #(spr_data - vic + 64 * 1) / 64
	sta screen + $03f9
	lda #(spr_data - vic + 64 * 2) / 64
	sta screen + $03fa
	lda #(spr_data - vic + 64 * 3) / 64
	sta screen + $03fb
	lda #(spr_data - vic + 64 * 4) / 64
	sta screen + $03fc
	// copy sprites
	ldx #0
!l:
	lda m0spr, x
	sta spr_data + 64 * 0, x
	inx
	cpx #64
	bne !l-
	ldx #0
!l:
	lda m1spr, x
	sta spr_data + 64 * 1, x
	inx
	cpx #64
	bne !l-
!l:
	lda m2spr, x
	sta spr_data + 64 * 2, x
	inx
	cpx #64
	bne !l-
!l:
	lda m3spr, x
	sta spr_data + 64 * 3, x
	inx
	cpx #64
	bne !l-
!l:
	lda m4spr, x
	sta spr_data + 64 * 4, x
	inx
	cpx #64
	bne !l-

	// show sprites
	lda #$1f
	sta $d015
	lda #$01
	sta $d027
	lda #$03
	sta $d028
	lda #$0f
	sta $d029
	lda #$09
	sta $d02a
	lda #$0b
	sta $d02b

	lda #$88 + 0 * 20
	sta $d000
	lda #$88 + 1 * 20
	sta $d002
	lda #$88 + 2 * 20
	sta $d004
	lda #$88 + 3 * 20
	sta $d006
	lda #$88 + 4 * 20
	sta $d008
	lda #$80
	sta $d001
	sta $d003
	sta $d005
	sta $d007
	sta $d009

	rts

spr_step:
	lda spr_count0
	and #$3f
	tax
	lda sinus, x
	sta $d001
	inc spr_count0
	lda spr_count1
	and #$3f
	tax
	lda sinus, x
	sta $d003
	inc spr_count1
	lda spr_count2
	and #$3f
	tax
	lda sinus, x
	sta $d005
	inc spr_count2
	lda spr_count3
	and #$3f
	tax
	lda sinus, x
	sta $d007
	inc spr_count3
	lda spr_count4
	and #$3f
	tax
	lda sinus, x
	sta $d009
	inc spr_count4

	lda spr_delay
	beq !change+
	dec spr_delay
	rts

!change:
	mov #col_delay : spr_delay
	inc $d027
	inc $d027
	inc $d028
	inc $d028
	inc $d029
	inc $d029
	inc $d02a
	inc $d02a
	inc $d02b
	inc $d02b
	rts

spr_delay:
	.byte 4

spr_count0:
	.byte 0
spr_count1:
	.byte 2
spr_count2:
	.byte 4
spr_count3:
	.byte 6
spr_count4:
	.byte 8

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

	lda #0
	sta $d020
	// green: 5
	// light green: 13
	sta $d021

	lda #5
	ldx #0
!l:
	sta $d800, x
	sta $d900, x
	sta $da00, x
	sta $dae8, x
	inx
	bne !l-

	rts

snake_init:
	lda #' '
	jsr next_dot
	// remember our position
	mov dot_y : snake_y
	mov dot_x : snake_x
	mov16 dot_pos : snake_pos
	// setup other snake stuff
	mov #grow : snake_grow
	lda #0
	sta snake_head
	sta snake_tail
	sta snake_size
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

delay:
	.byte 0

step:
	jsr spr_step
// XXX uncomment this to slow down the game
//	ldx delay
//	beq snake_step
//	dec delay
//	rts
snake_step:
	mov #4 : delay
	// setup snake movement code
	ldx snake_dir
	lda fptr_snake, x
	sta !fptr+ + 1
	lda fptr_snake + 1, x
	sta !fptr+ + 2
!fptr:
	jsr !hang+

	// compute new head screen location
	lda snake_dp
	clc
	adc snake_pos
	sta snake_pos
	lda snake_dp + 1
	adc snake_pos + 1
	sta snake_pos + 1

	// grow code
	lda snake_size
	cmp #max_size
	beq !no_grow+
	ldx snake_grow
	beq !no_grow+
	dex
	//dec $d020
	stx snake_grow
	inc snake_size
	jmp !hold_tail+
!no_grow:
	// erase old tail
	ldx snake_tail
	lda snakes_tbl, x
	sta !erase+ + 1
	lda snakes_tbl + 1, x
	sta !erase+ + 2
	lda #' '
!erase:
	sta $0400
	// tail = (tail + 1) % 32
	lda snake_tail
	clc
	adc #2
	and #63
	sta snake_tail
!hold_tail:
	// NOTE tail should not overlap with target! (target becomes invisible)

	// update head and store head in table
	ldx snake_head
	lda snake_pos
	sta !fetch_head+ + 1
	sta !put_head+ + 1
	sta snakes_tbl, x
	lda snake_pos + 1
	sta !fetch_head+ + 2
	sta !put_head+ + 2
	sta snakes_tbl + 1, x

	// head = (head + 1) % 32
	lda snake_head
	clc
	adc #2
	and #63
	sta snake_head

!fetch_head:
	lda $0400
	cmp #$51
	beq !next+
	cmp #' '
	bne !die+
	jmp !move+
!next:
	inc snake_grow
	lda #$51
	jsr next_dot
!move:
	lda #$e0
!put_head:
	sta $0400
!hang:
	rts
!die:
	// reset screen state
	// remove snake
	ldx #0
	ldy #' '
!l:
	lda snakes_tbl, x
	sta !erase+ + 1
	lda snakes_tbl + 1, x
	sta !erase+ + 2
!erase:
	sty $0400
	inx
	inx
	cpx #$40
	bne !l-

	// remove target
	lda dot_pos
	sta !erase+ + 1
	lda dot_pos + 1
	sta !erase+ + 2
	lda #' '
!erase:
	sta $0400

	// reset snake state
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

irq_top:
	irq
	//inc $d020
	jsr step
	jsr music.play
	//dec $d020
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

snake_head:
	.byte 0
snake_tail:
	.byte 0
snake_grow:
	.byte 0
snake_size:
	.byte 0

.align $80

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

.align $40

snakes_tbl:
	.word 0, 0, 0, 0, 0, 0, 0, 0
	.word 0, 0, 0, 0, 0, 0, 0, 0
	.word 0, 0, 0, 0, 0, 0, 0, 0
	.word 0, 0, 0, 0, 0, 0, 0, 0

.align $40
m0spr:
	.byte $00,$00,$00,$0e,$00,$00,$0e,$00
	.byte $00,$0e,$00,$00,$0e,$00,$00,$0e
	.byte $00,$00,$0e,$00,$00,$0e,$00,$00
	.byte $0e,$00,$00,$0e,$00,$00,$0e,$00
	.byte $00,$0e,$00,$00,$0e,$00,$00,$0e
	.byte $00,$00,$0e,$00,$00,$0e,$00,$00
	.byte $0e,$00,$00,$0f,$ff,$f8,$0f,$ff
	.byte $f8,$0f,$ff,$f8,$00,$00,$00,$00


.align $40
m1spr:
	.byte $00,$00,$00,$00,$7e,$00,$00,$ff
	.byte $00,$01,$ff,$80,$03,$e7,$c0,$07
	.byte $81,$e0,$07,$81,$e0,$0f,$81,$f0
	.byte $0f,$00,$f0,$0f,$00,$f0,$0f,$ff
	.byte $f0,$0f,$ff,$f0,$0f,$ff,$f0,$0f
	.byte $00,$f0,$0f,$00,$f0,$0f,$00,$f0
	.byte $0f,$00,$f0,$0f,$00,$f0,$0f,$00
	.byte $f0,$0f,$00,$f0,$00,$00,$00,$00

.align $40
m2spr:
	.byte $00,$00,$00,$0f,$fc,$00,$0f,$ff
	.byte $00,$0f,$ff,$80,$0f,$07,$c0,$0f
	.byte $01,$e0,$0f,$01,$e0,$0f,$01,$f0
	.byte $0f,$00,$f0,$0f,$00,$f0,$0f,$00
	.byte $f0,$0f,$00,$f0,$0f,$00,$f0,$0f
	.byte $01,$f0,$0f,$01,$e0,$0f,$01,$e0
	.byte $0f,$07,$c0,$0f,$ff,$80,$0f,$ff
	.byte $00,$0f,$fc,$00,$00,$00,$00,$00

.align $40
m3spr:
	.byte $00,$00,$00,$0f,$ff,$f0,$0f,$ff
	.byte $f0,$0f,$ff,$f0,$0f,$00,$00,$0f
	.byte $00,$00,$0f,$00,$00,$0f,$00,$00
	.byte $0f,$00,$00,$0f,$ff,$c0,$0f,$ff
	.byte $c0,$0f,$ff,$c0,$0f,$00,$00,$0f
	.byte $00,$00,$0f,$00,$00,$0f,$00,$00
	.byte $0f,$00,$00,$0f,$ff,$f0,$0f,$ff
	.byte $f0,$0f,$ff,$f0,$00,$00,$00,$00
.align $40
m4spr:
	.byte $00,$00,$00,$0f,$00,$f0,$0f,$80
	.byte $f0,$0f,$80,$f0,$0f,$c0,$f0,$0f
	.byte $c0,$f0,$0f,$e0,$f0,$0f,$60,$f0
	.byte $0f,$70,$f0,$0f,$30,$f0,$0f,$38
	.byte $f0,$0f,$18,$f0,$0f,$1c,$f0,$0f
	.byte $0c,$f0,$0f,$0e,$f0,$0f,$06,$f0
	.byte $0f,$07,$f0,$0f,$03,$f0,$0f,$03
	.byte $f0,$0f,$01,$f0,$00,$00,$00,$00

.align $40

sinus:
	.fill $40, round($80 + $08 * sin(toRadians(i * 360 / $40)))

// MUSIC
	* = music.location "music"

	.fill music.size, music.getData(i)

	.print "music_init = $" + toHexString(music.init)
	.print "music_play = $" + toHexString(music.play)

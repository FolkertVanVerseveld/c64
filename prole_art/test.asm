// Assembler: KickAssembler v4.19

BasicUpstart2(main)

#import "../pseudo.lib"

// https://dustlayer.com/vic-ii/2013/4/25/vic-ii-for-beginners-beyond-the-screen-rasters-cycle
//
// 50 is net iets voor het begin van 25 rijenscherm


.var irq_line_top = (312 - 284) / 2

.var irq_line_screen_start = 49
//.var irq_line_top = $20

.var irq_line_bottom = 284 + 5

// intro idea:

// split lines with text introducing prole art?

// scroller idea:

// parallax scrolling with three areas, where dutch and sweden flag will reside
// while some stuff is scrolling (probably petscii, maybe bitmap?)

// dutch flag:
// red for raster sky?
// white for horizon?
// blue with water stuff (inc. boat?)

// swedish flag
// twister like effect?

// or methos and anton names with sprites/petscii with flag colors

.var music = LoadSid("/home/methos/Music/C64Music/MUSICIANS/0-9/20CC/van_Santen_Edwin/Blackmail_Tune_1.sid")

main:
	//lda #0
	//sta $0400

	lda #0
	jsr music.init

	// inline: setup irq
	sei
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

irq_top:
	irq // 21, 21

	lda #6 // 4, 25
	sta $d020 // 4, 29

!fptr:
	ldx scroll_top_size // 4, 33
!l:
	jsr delay2 // 14, 14
	jsr delay2 // 14, 28
	jsr delay2 // 14, 42
	jsr delay2 // 14, 56
	jmp !next+
!next:
	dex // 2, 61
	bne !l-

	lda #14
	sta $d020

	ldx scroll_top_size
	cpx #$24
	beq !no_inc+
	inx
	stx scroll_top_size
	qri2 #irq_line_bottom : #irq_bottom
!no_inc:
	lda #$4c
	sta !fptr-
	lda #<!done+
	sta !fptr- + 1
	lda #>!done+
	sta !fptr- + 2
	jmp !irq_change_once+
!done:
	qri #irq_line_screen_start : #irq_screen_top

scroll_top_size:
	.byte 1

irq_screen_top:
	irq

!irq_change_once:
	jsr delay
	jsr delay
	bit $ea

	lda #6
	sta $d020

	ldx wobble_size
	ldy wobble_pos
!l:
	lda wobble_tbl, y
	sta $d016
	jsr delay2
	jsr delay2
	jsr delay2
	nop
	iny
	tya
	and #$1f
	tay
	dex
	bne !l-

	ldx wobble_size
	cpx #$d7
	beq !no_inc+
	inx
	stx wobble_size
	inc wobble_pos

	lda #$c8
	sta $d016

	lda #14
	sta $d020
	jmp !done+
!no_inc:
	inc $0400
	inc wobble_pos
!done:
	qri2 #irq_line_bottom : #irq_bottom

irq_bottom:
	irq
	jsr music.play
	qri2 #irq_line_top : #irq_top

delay2:
	nop
delay:
	rts

wobble_size:
	.byte 2
wobble_pos:
	.byte 0

.align $10

wobble_tbl:
	.fill $20, round($c8 + 3 + 3 * sin(toRadians(i * 360 / $20)))

	.byte $c8, $c9, $ca, $cb, $cc, $cd, $ce, $cf
	.byte $cf, $ce, $cd, $cc, $cb, $ca, $c9, $c8

// MUSIC
	* = music.location "music"

	.fill music.size, music.getData(i)

	.print "music_init = $" + toHexString(music.init)
	.print "music_play = $" + toHexString(music.play)

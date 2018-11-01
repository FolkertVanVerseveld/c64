// Assembler: KickAssembler v4.19

BasicUpstart2(main)

#import "../pseudo.lib"

// https://dustlayer.com/vic-ii/2013/4/25/vic-ii-for-beginners-beyond-the-screen-rasters-cycle
//
// 50 is net iets voor het begin van 25 rijenscherm

//.var irq_line_top = 50
//.var irq_line_middle = 50 + 12 * 8
//.var irq_line_bottom = 50 + 25 * 8
.var irq_line_top = 0 * 103
.var irq_line_middle = 1 * 103
.var irq_line_bottom = 2 * 103

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

.var music = LoadSid("/home/methos/Music/C64Music/MUSICIANS/0-9/20CC/van_Santen_Edwin/Blackmail_Tune_1.sid")

main:
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

	.for (var i = 0; i < 16; i++) {
	mov #$e0 : $0400 + i
	mov #i : $d800 + i
	}

	jmp *

irq_top:
	irq
	mov #2 : $d020
	sta $d021
	jsr music.play
	qri2 #irq_line_middle : #irq_middle

irq_middle:
	irq
	jsr !delay+
	jsr !delay+
	bit $ea
	mov #1 : $d020
	sta $d021
	qri2 #irq_line_bottom : #irq_bottom


irq_bottom:
	irq
	jsr !delay+
	jsr !delay+
	bit $ea
	mov #6 : $d020
	sta $d021
	qri2 #irq_line_top : #irq_top

!delay:
	rts

// MUSIC
	* = music.location "music"

	.fill music.size, music.getData(i)

	.print "music_init = $" + toHexString(music.init)
	.print "music_play = $" + toHexString(music.play)

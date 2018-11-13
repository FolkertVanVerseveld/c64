// Assembler: KickAssembler v4.19

BasicUpstart2(main)

.var brkFile = createFile("breakpoints.txt")
.macro break() {
.eval brkFile.writeln("break " + toHexString(*))
}

.var irq_line_top = 40
.var irq_line_bottom = 240

.var roll_timer = 6

.var music = LoadSid("/home/methos/Music/C64Music/MUSICIANS/0-9/20CC/van_Santen_Edwin/Greystorm_unused_hi-score.sid")

main:
	lda #0
	jsr music.init

	// first loop
	ldy #0
	lda #$e0
!l:
!fetch:
	lda logo
!put:
	sta $0400 + 7 * 40
	inc !fetch- + 1
	bne !noinc+
	inc !fetch- + 2
!noinc:
	inc !put- + 1
	bne !noinc+
	inc !put- + 2
!noinc:
	iny
	bne !l-
	// second loop
!l:
!fetch:
	lda logo + $100
!put:
	sta $0500 + 7 * 40
	inc !fetch- + 1
	bne !noinc+
	inc !fetch- + 2
!noinc:
	inc !put- + 1
	bne !noinc+
	inc !put- + 2
!noinc:
	iny
	cpy #184
	bne !l-

	ldx #0
!l:
	lda txt_bottom, x
	sta $0400 + 19 * 40, x
	inx
	cpx #4 * 40
	bne !l-


	// INLINE setup irq
	sei
	lda #$35		// Disable KERNAL and BASIC ROM
	sta $01			// Enable all RAM

	lda #<irq_top		// Setup IRQ vector
	sta $fffe
	lda #>irq_top
	sta $ffff

	lda #<dummy
	sta $fffa
	sta $fffc
	lda #>dummy
	sta $fffb
	sta $fffd

	lda #%00011011		// Load screen control:
				// Vertical scroll    : 3
				// Screen height      : 25 rows
				// Screen             : ON
				// Mode               : TEXT
				// Extended background: OFF
	sta $d011       	// Set screen control

	lda #irq_line_top
	sta $d012

	lda #$01		// Enable mask
	sta $d01a		// IRQ interrupt ON

	lda #%01111111		// Load interrupt control CIA 1:
				// Timer A underflow : OFF
				// Timer B underflow : OFF
				// TOD               : OFF
				// Serial shift reg. : OFF
				// Pos. edge FLAG pin: OFF
	sta $dc0d		// Set interrupt control CIA 1
	sta $dd0d		// Set interrupt control CIA 2

	lda $dc0d		// Clear pending interrupts CIA 1
	lda $dd0d		// Clear pending interrupts CIA 2

	lda #$00
	sta $dc0e

	lda #$01
	sta $d019		// Acknowledge pending interrupts

	cli			// Start firing interrupts

	jmp *

irq_top:
	pha
	txa
	pha
	tya
	pha

	inc $d020
	ldx #8
!l:
	dex
	bne !l-

	// modify colors
!timer:
	ldx #roll_timer
	beq !roll+
	jmp !ignore+
!roll:
	ldx #roll_timer
	stx !timer- + 1

!i0:
	lda #14

	sta $d800 + 7 * 40 + 5 * 40 + 19
	sta $d800 + 7 * 40 + 5 * 40 + 20

	inc !i0- + 1

!i1:
	lda #13

	sta $d800 + 7 * 40 + 4 * 40 + 19
	sta $d800 + 7 * 40 + 4 * 40 + 20
	sta $d800 + 7 * 40 + 6 * 40 + 19
	sta $d800 + 7 * 40 + 6 * 40 + 20

	inc !i1- + 1

!i2:
	lda #12

	sta $d800 + 7 * 40 + 3 * 40 + 19
	sta $d800 + 7 * 40 + 3 * 40 + 20
	sta $d800 + 7 * 40 + 7 * 40 + 19
	sta $d800 + 7 * 40 + 7 * 40 + 20

	inc !i2- + 1

!i3:
	lda #11

	sta $d800 + 7 * 40 + 2 * 40 + 19
	sta $d800 + 7 * 40 + 2 * 40 + 20
	sta $d800 + 7 * 40 + 8 * 40 + 19
	sta $d800 + 7 * 40 + 8 * 40 + 20

	inc !i3- + 1

!i4:
	lda #10

	sta $d800 + 7 * 40 + 1 * 40 + 16
	sta $d800 + 7 * 40 + 1 * 40 + 17
	sta $d800 + 7 * 40 + 1 * 40 + 18
	sta $d800 + 7 * 40 + 1 * 40 + 19
	sta $d800 + 7 * 40 + 1 * 40 + 20
	sta $d800 + 7 * 40 + 1 * 40 + 21
	sta $d800 + 7 * 40 + 1 * 40 + 22
	sta $d800 + 7 * 40 + 1 * 40 + 23
	sta $d800 + 7 * 40 + 9 * 40 + 16
	sta $d800 + 7 * 40 + 9 * 40 + 17
	sta $d800 + 7 * 40 + 9 * 40 + 18
	sta $d800 + 7 * 40 + 9 * 40 + 19
	sta $d800 + 7 * 40 + 9 * 40 + 20
	sta $d800 + 7 * 40 + 9 * 40 + 21
	sta $d800 + 7 * 40 + 9 * 40 + 22
	sta $d800 + 7 * 40 + 9 * 40 + 23

	inc !i4- + 1

!i5:
	lda #9

	sta $d800 + 7 * 40 + 0 * 40 + 16
	sta $d800 + 7 * 40 + 0 * 40 + 17
	sta $d800 + 7 * 40 + 0 * 40 + 18
	sta $d800 + 7 * 40 + 0 * 40 + 19
	sta $d800 + 7 * 40 + 0 * 40 + 20
	sta $d800 + 7 * 40 + 0 * 40 + 21
	sta $d800 + 7 * 40 + 0 * 40 + 22
	sta $d800 + 7 * 40 + 0 * 40 + 23
	sta $d800 + 7 * 40 + 10 * 40 + 16
	sta $d800 + 7 * 40 + 10 * 40 + 17
	sta $d800 + 7 * 40 + 10 * 40 + 18
	sta $d800 + 7 * 40 + 10 * 40 + 19
	sta $d800 + 7 * 40 + 10 * 40 + 20
	sta $d800 + 7 * 40 + 10 * 40 + 21
	sta $d800 + 7 * 40 + 10 * 40 + 22
	sta $d800 + 7 * 40 + 10 * 40 + 23

	inc !i5- + 1

!v0:
	lda #0

	sta $d800 + 7 * 40 + 0 * 40 + 4
	sta $d800 + 7 * 40 + 0 * 40 + 5
	sta $d800 + 7 * 40 + 0 * 40 + 12
	sta $d800 + 7 * 40 + 0 * 40 + 13

	inc !v0- + 1

!v1:
	lda #1

	sta $d800 + 7 * 40 + 1 * 40 + 4
	sta $d800 + 7 * 40 + 1 * 40 + 5
	sta $d800 + 7 * 40 + 1 * 40 + 12
	sta $d800 + 7 * 40 + 1 * 40 + 13

	inc !v1- + 1

!v2:
	lda #2

	sta $d800 + 7 * 40 + 2 * 40 + 4
	sta $d800 + 7 * 40 + 2 * 40 + 5
	sta $d800 + 7 * 40 + 2 * 40 + 6
	sta $d800 + 7 * 40 + 2 * 40 + 11
	sta $d800 + 7 * 40 + 2 * 40 + 12
	sta $d800 + 7 * 40 + 2 * 40 + 13

	inc !v2- + 1

!v3:
	lda #3

	sta $d800 + 7 * 40 + 3 * 40 + 5
	sta $d800 + 7 * 40 + 3 * 40 + 6
	sta $d800 + 7 * 40 + 3 * 40 + 11
	sta $d800 + 7 * 40 + 3 * 40 + 12

	inc !v3- + 1

!v4:
	lda #4

	sta $d800 + 7 * 40 + 4 * 40 + 5
	sta $d800 + 7 * 40 + 4 * 40 + 6
	sta $d800 + 7 * 40 + 4 * 40 + 11
	sta $d800 + 7 * 40 + 4 * 40 + 12

	inc !v4- + 1

!v5:
	lda #5

	sta $d800 + 7 * 40 + 5 * 40 + 5
	sta $d800 + 7 * 40 + 5 * 40 + 6
	sta $d800 + 7 * 40 + 5 * 40 + 7
	sta $d800 + 7 * 40 + 5 * 40 + 10
	sta $d800 + 7 * 40 + 5 * 40 + 11
	sta $d800 + 7 * 40 + 5 * 40 + 12

	inc !v5- + 1

!v6:
	lda #6

	sta $d800 + 7 * 40 + 6 * 40 + 6
	sta $d800 + 7 * 40 + 6 * 40 + 7
	sta $d800 + 7 * 40 + 6 * 40 + 10
	sta $d800 + 7 * 40 + 6 * 40 + 11

	inc !v6- + 1

!v7:
	lda #7

	sta $d800 + 7 * 40 + 7 * 40 + 6
	sta $d800 + 7 * 40 + 7 * 40 + 7
	sta $d800 + 7 * 40 + 7 * 40 + 8
	sta $d800 + 7 * 40 + 7 * 40 + 9
	sta $d800 + 7 * 40 + 7 * 40 + 10
	sta $d800 + 7 * 40 + 7 * 40 + 11

	inc !v7- + 1

!v8:
	lda #8

	sta $d800 + 7 * 40 + 8 * 40 + 6
	sta $d800 + 7 * 40 + 8 * 40 + 7
	sta $d800 + 7 * 40 + 8 * 40 + 8
	sta $d800 + 7 * 40 + 8 * 40 + 9
	sta $d800 + 7 * 40 + 8 * 40 + 10
	sta $d800 + 7 * 40 + 8 * 40 + 11

	inc !v8- + 1

!v9:
	lda #9

	sta $d800 + 7 * 40 + 9 * 40 + 7
	sta $d800 + 7 * 40 + 9 * 40 + 8
	sta $d800 + 7 * 40 + 9 * 40 + 9
	sta $d800 + 7 * 40 + 9 * 40 + 10

	inc !v9- + 1

!v10:
	lda #10

	sta $d800 + 7 * 40 + 10 * 40 + 7
	sta $d800 + 7 * 40 + 10 * 40 + 8
	sta $d800 + 7 * 40 + 10 * 40 + 9
	sta $d800 + 7 * 40 + 10 * 40 + 10

	inc !v10- + 1

!a0:
	lda #15

	sta $d800 + 7 * 40 + 0 * 40 + 28
	sta $d800 + 7 * 40 + 0 * 40 + 29
	sta $d800 + 7 * 40 + 0 * 40 + 30
	sta $d800 + 7 * 40 + 0 * 40 + 31
	sta $d800 + 7 * 40 + 0 * 40 + 32
	sta $d800 + 7 * 40 + 0 * 40 + 33

	inc !a0- + 1

!a1:
	lda #14

	sta $d800 + 7 * 40 + 1 * 40 + 27
	sta $d800 + 7 * 40 + 1 * 40 + 28
	sta $d800 + 7 * 40 + 1 * 40 + 29
	sta $d800 + 7 * 40 + 1 * 40 + 30
	sta $d800 + 7 * 40 + 1 * 40 + 31
	sta $d800 + 7 * 40 + 1 * 40 + 32
	sta $d800 + 7 * 40 + 1 * 40 + 33
	sta $d800 + 7 * 40 + 1 * 40 + 34

	inc !a1- + 1

!a2:
	lda #13

	sta $d800 + 7 * 40 + 2 * 40 + 27
	sta $d800 + 7 * 40 + 2 * 40 + 28
	sta $d800 + 7 * 40 + 2 * 40 + 29
	sta $d800 + 7 * 40 + 2 * 40 + 32
	sta $d800 + 7 * 40 + 2 * 40 + 33
	sta $d800 + 7 * 40 + 2 * 40 + 34

	inc !a2- + 1

!a3:
	lda #12

	sta $d800 + 7 * 40 + 3 * 40 + 27
	sta $d800 + 7 * 40 + 3 * 40 + 28
	sta $d800 + 7 * 40 + 3 * 40 + 33
	sta $d800 + 7 * 40 + 3 * 40 + 34

	inc !a3- + 1

!a4:
	lda #11

	sta $d800 + 7 * 40 + 4 * 40 + 27
	sta $d800 + 7 * 40 + 4 * 40 + 28
	sta $d800 + 7 * 40 + 4 * 40 + 33
	sta $d800 + 7 * 40 + 4 * 40 + 34

	inc !a4- + 1

!a5:
	lda #10

	sta $d800 + 7 * 40 + 5 * 40 + 27
	sta $d800 + 7 * 40 + 5 * 40 + 28
	sta $d800 + 7 * 40 + 5 * 40 + 29
	sta $d800 + 7 * 40 + 5 * 40 + 30
	sta $d800 + 7 * 40 + 5 * 40 + 31
	sta $d800 + 7 * 40 + 5 * 40 + 32
	sta $d800 + 7 * 40 + 5 * 40 + 33
	sta $d800 + 7 * 40 + 5 * 40 + 34

	inc !a5- + 1

!a5:
	lda #9

	sta $d800 + 7 * 40 + 6 * 40 + 27
	sta $d800 + 7 * 40 + 6 * 40 + 28
	sta $d800 + 7 * 40 + 6 * 40 + 29
	sta $d800 + 7 * 40 + 6 * 40 + 30
	sta $d800 + 7 * 40 + 6 * 40 + 31
	sta $d800 + 7 * 40 + 6 * 40 + 32
	sta $d800 + 7 * 40 + 6 * 40 + 33
	sta $d800 + 7 * 40 + 6 * 40 + 34

	inc !a5- + 1

!a6:
	lda #8

	sta $d800 + 7 * 40 + 7 * 40 + 27
	sta $d800 + 7 * 40 + 7 * 40 + 28
	sta $d800 + 7 * 40 + 7 * 40 + 29
	sta $d800 + 7 * 40 + 7 * 40 + 32
	sta $d800 + 7 * 40 + 7 * 40 + 33
	sta $d800 + 7 * 40 + 7 * 40 + 34

	inc !a6- + 1

!a7:
	lda #7

	sta $d800 + 7 * 40 + 8 * 40 + 27
	sta $d800 + 7 * 40 + 8 * 40 + 28
	sta $d800 + 7 * 40 + 8 * 40 + 33
	sta $d800 + 7 * 40 + 8 * 40 + 34

	inc !a7- + 1

!a8:
	lda #6

	sta $d800 + 7 * 40 + 9 * 40 + 27
	sta $d800 + 7 * 40 + 9 * 40 + 28
	sta $d800 + 7 * 40 + 9 * 40 + 33
	sta $d800 + 7 * 40 + 9 * 40 + 34

	inc !a8- + 1

!a9:
	lda #5

	sta $d800 + 7 * 40 + 10 * 40 + 27
	sta $d800 + 7 * 40 + 10 * 40 + 28
	sta $d800 + 7 * 40 + 10 * 40 + 33
	sta $d800 + 7 * 40 + 10 * 40 + 34

	inc !a9- + 1

!ignore:
	dec !timer- + 1
	dec $d020

	lda #irq_line_bottom
	sta $d012

	lda #<irq_bottom
	sta $fffe
	lda #>irq_bottom
	sta $ffff

	// acknowledge irq
	asl $d019

	pla
	tay
	pla
	tax
	pla
dummy:
	rti

irq_bottom:
	pha
	txa
	pha
	tya
	pha

	inc $d020

	jsr music.play

	dec $d020

	lda #irq_line_top
	sta $d012

	lda #<irq_top
	sta $fffe
	lda #>irq_top
	sta $ffff

	asl $d019

	pla
	tay
	pla
	tax
	pla
	rti

txt_bottom:
	.text "  de commodore 64 workshop vindt plaats "
	.text "   op dinsdag 27 november 17:00-19:00   "
	.text "                                        "
	.text "ga naar: https://svia.nl/activities/644/"

logo:
	.byte $20, $20, $20, $20, $e0, $e0, $20, $20, $20, $20, $20, $20, $e0, $e0, $20, $20, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $20, $20, $20, $20, $e9, $e0, $e0, $e0, $e0, $df, $20, $20, $20, $20, $20, $20
	.byte $20, $20, $20, $20, $e0, $e0, $20, $20, $20, $20, $20, $20, $e0, $e0, $20, $20, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $20, $20, $20, $e9, $e0, $e0, $e0, $e0, $e0, $e0, $df, $20, $20, $20, $20, $20
	.byte $20, $20, $20, $20, $5f, $e0, $df, $20, $20, $20, $20, $e9, $e0, $69, $20, $20, $20, $20, $20, $e0, $e0, $20, $20, $20, $20, $20, $20, $e0, $e0, $69, $20, $20, $5f, $e0, $e0, $20, $20, $20, $20, $20
	.byte $20, $20, $20, $20, $20, $e0, $e0, $20, $20, $20, $20, $e0, $e0, $20, $20, $20, $20, $20, $20, $e0, $e0, $20, $20, $20, $20, $20, $20, $e0, $e0, $20, $20, $20, $20, $e0, $e0, $20, $20, $20, $20, $20
	.byte $20, $20, $20, $20, $20, $e0, $e0, $20, $20, $20, $20, $e0, $e0, $20, $20, $20, $20, $20, $20, $e0, $e0, $20, $20, $20, $20, $20, $20, $e0, $e0, $20, $20, $20, $20, $e0, $e0, $20, $20, $20, $20, $20
	.byte $20, $20, $20, $20, $20, $5f, $e0, $df, $20, $20, $e9, $e0, $69, $20, $20, $20, $20, $20, $20, $e0, $e0, $20, $20, $20, $20, $20, $20, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $20, $20, $20, $20, $20
	.byte $20, $20, $20, $20, $20, $20, $e0, $e0, $20, $20, $e0, $e0, $20, $20, $20, $20, $20, $20, $20, $e0, $e0, $20, $20, $20, $20, $20, $20, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $20, $20, $20, $20, $20
	.byte $20, $20, $20, $20, $20, $20, $e0, $e0, $e0, $e0, $e0, $e0, $20, $20, $20, $20, $20, $20, $20, $e0, $e0, $20, $20, $20, $20, $20, $20, $e0, $e0, $69, $20, $20, $5f, $e0, $e0, $20, $20, $20, $20, $20
	.byte $20, $20, $20, $20, $20, $20, $5f, $e0, $e0, $e0, $e0, $69, $20, $20, $20, $20, $20, $20, $20, $e0, $e0, $20, $20, $20, $20, $20, $20, $e0, $e0, $20, $20, $20, $20, $e0, $e0, $20, $20, $20, $20, $20
	.byte $20, $20, $20, $20, $20, $20, $20, $e0, $e0, $e0, $e0, $20, $20, $20, $20, $20, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $20, $20, $20, $e0, $e0, $20, $20, $20, $20, $e0, $e0, $20, $20, $20, $20, $20
	.byte $20, $20, $20, $20, $20, $20, $20, $5f, $e0, $e0, $69, $20, $20, $20, $20, $20, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $20, $20, $20, $e0, $e0, $20, $20, $20, $20, $e0, $e0, $20, $20, $20, $20, $20

	* = music.location "music"

	.fill music.size, music.getData(i)

	.print "music_init = $" + toHexString(music.init)
	.print "music_play = $" + toHexString(music.play)

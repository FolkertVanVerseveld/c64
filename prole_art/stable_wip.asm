// Assembler: KickAssembler v4.19

.pc = $0801 "Basic Upstart"
:BasicUpstart($8000)

.pc = $8000 "Program"

// https://dustlayer.com/vic-ii/2013/4/25/vic-ii-for-beginners-beyond-the-screen-rasters-cycle

.var irq_line_top = $28 - 1

// intro idea:

.var music = LoadSid("/home/methos/Music/C64Music/MUSICIANS/0-9/20CC/van_Santen_Edwin/Blackmail_Tune_1.sid")

main:
	jsr $ff81

	// TODO disable nmi

	// XXX disable nmi not working?
	lda #$ea
	sta $0328

	lda #<nmi
	sta $fffa
	lda #>nmi
	sta $fffb

	sei
	lda #$35
	sta $01

	jsr setupInterrupts
	cli

	jmp *

nmi:
	rti

setupInterrupts:
	lda #<int1
	ldy #>int1
	sta $fffe
	sty $ffff

	lda #$01
	sta $d01a
	lda #$7f
	sta $dc0d
	sta $dd0d
	lda $dc0d
	lda $dd0d
	lda #$1b
	sta $d011
	lda #$01
	sta $d019

	lda start
	sta $d012

	rts

start:
	.byte 56

int1:
	pha
	txa
	pha
	tya
	pha

	:STABILIZE()

	.for (var i=0; i<28; i++) {
		nop
	}

	.for (var i=0; i<8*6; i++) {
		inc $d020
		inc $d021
		.if ([i & %111] == 0) {
			// badline
			nop
			nop
			nop
			nop
		} else {
			// normal line
			.for (var j=0; j<24; j++) {
				nop
			}
			bit $ea
		}
	}

	lda #$00
	sta $d020
	sta $d021

	lda start
	sta $d012

	lda #<int1
	ldy #>int1
	sta $fffe
	sty $ffff

	lda #$01
	sta $d019

	pla
	tay
	pla
	tax
	pla

	rti

.macro STABILIZE() {
	lda #<nextRasterLineIRQ
	sta $fffe
	lda #>nextRasterLineIRQ
	sta $ffff

	inc $d012

	lda #$01
	sta $d019

	tsx

	cli

	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop

nextRasterLineIRQ:
	tsx

	ldx #$08
	dex
	bne *-1
	bit $00

	lda $d012
	cmp $d012

	beq *+2
}

// MUSIC
//	* = music.location "music"
//
//	.fill music.size, music.getData(i)
//
//	.print "music_init = $" + toHexString(music.init)
//	.print "music_play = $" + toHexString(music.play)

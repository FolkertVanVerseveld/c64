// Assembler: KickAssembler v4.19
// source: codebase64.org/doku.php?id=base:dysp_d017

BasicUpstart2(start)

//.var music = LoadSid("/home/methos/Music/HVSC69/MUSICIANS/0-9/20CC/van_Santen_Edwin/Blackmail_Tune_1.sid")
.var music = LoadSid("/home/methos/Music/HVSC69/MUSICIANS/J/JCH/Training.sid")

start:
	jsr $fda3
	jsr $fd15
	sei
	jsr create_sprite
	ldx #7
!m:	lda #$0340 / 64
	sta $07f8, x
	lda spr_colors, x
	sta $d027, x
	dex
	bpl !m-
	lda #0
	jsr music.init
	lda #$35
	sta $01
	lda #$7f
	sta $dc0d
	sta $dd0d
	lda #0
	sta $3fff
	sta $dc0e
	lda #$01
	sta $d01a
	lda #$1b
	sta $d011
	lda #$2d
	ldx #<irq1
	ldy #>irq1
	sta $d012
	stx $fffe
	sty $ffff
	ldx #<break
	ldy #>break
	stx $fffa
	sty $fffb
	stx $fffc
	sty $fffd
	bit $dc0d
	bit $dd0d
	inc $d019
	cli
	jmp *

// make sure timing loops don't cross page boundaries
.align $100

// `double IRQ' technique to stabilize raster
irq1:
	pha
	txa
	pha
	tya
	pha
	lda #$2e
	ldx #<irq2
	ldy #>irq2
	sta $d012
	stx $fffe
	sty $ffff
	lda #1
	inc $d019
	tsx
	cli
	.for (var i=0; i<11; i++) {
		nop
	}

irq2:
	txs
	ldx #8
!m:	dex
	bne !m-
	bit $ea
	lda $d012
	cmp $d012
	beq !p+
!p:	// stable raster here

	// set sprite positions
	lda #$32
	sta $d001
	sta $d003
	sta $d005
	sta $d007
	sta $d009
	sta $d00b
	sta $d00d
	sta $d00f
x0:	lda #$00
	sta $d000
x1:	lda #$18
	sta $d002
x2:	lda #$30
	sta $d004
x3:	lda #$48
	sta $d006
x4:	lda #$60
	sta $d008
x5:	lda #$78
	sta $d00a
x6:	lda #$90
	sta $d00c
x7:	lda #$a8
	sta $d00e
xmsb:	lda #$00
	sta $d010
	lda #$00
	sta $d01c
	sta $d01d
	lda #$ff
	sta $d015


	ldx #09
!m:	dex
	bne !m-
	nop
	nop
	nop
	jsr stretcher

	lda #$1b
	sta $d011
	lda #0
	sta $d015
	sta $d021
	dec $d020
	jsr clear_d017_table
	dec $d020
	jsr sinus_x
	jsr sinus_y
	dec $d020
	jsr update_d017_table
	lda #0
	sta $d020
	lda #$f9
	ldx #<irq3
	ldy #>irq3
	sta $d012
	stx $fffe
	sty $ffff
	lda #1
	sta $d019
	pla
	tay
	pla
	tax
	pla
break:	rti

irq3:
	pha
	txa
	pha
	tya
	pha
	ldx #3             // open top/bottom borders to allow us to open the
!m:	dex                // side borders earlier in the $d017 stretcher
	bne !m-
	stx $d011
	ldx #40
!m:	dex
	bne !m-
	lda #$1b
	sta $d011
	dec $d020
	jsr music.play

	lda #0
	sta $d020
	lda #$2d
	ldx #<irq1
	ldy #>irq1
	sta $d012
	stx $fffe
	sty $ffff
	lda #1
	sta $d019
	pla
	tay
	pla
	tax
	pla
	rti

create_sprite:
	ldx #0
!m:	lda sprite,x
	sta $0340,x
	inx
	cpx #63
	bne !m-
	rts

clear_d017_table:
	ldx #$ff
	ldx #$3f
!m:	sta d017_table,x
	dex
	bpl !m-
	rts

update_d017_table:
	// sprite 0
	ldx siny_table + 0
	ldy #18
!m:	lda d017_table,x
	and #%11111110
	sta d017_table,x
	inx
	dey
	bpl !m-

	// sprite 1
	ldx siny_table + 1
	ldy #18
!m:	lda d017_table,x
	and #%11111101
	sta d017_table,x
	inx
	dey
	bpl !m-

	ldx siny_table + 2
	ldy #18
!m:	lda d017_table,x
	and #%11111011
	sta d017_table,x
	inx
	dey
	bpl !m-

	ldx siny_table + 3
	ldy #18
!m:	lda d017_table,x
	and #%11110111
	sta d017_table,x
	inx
	dey
	bpl !m-

	ldx siny_table + 4
	ldy #18
!m:	lda d017_table,x
	and #%11101111
	sta d017_table,x
	inx
	dey
	bpl !m-

	ldx siny_table + 5
	ldy #18
!m:	lda d017_table,x
	and #%11011111
	sta d017_table,x
	inx
	dey
	bpl !m-

	ldx siny_table + 6
	ldy #18
!m:	lda d017_table,x
	and #%10111111
	sta d017_table,x
	inx
	dey
	bpl !m-

	ldx siny_table + 7
	ldy #18
!m:	lda d017_table,x
	and #%01111111
	sta d017_table,x
	inx
	dey
	bpl !m-
	rts

sinx_idx1:	.byte 0
sinx_idx2:	.byte 64
sinx_adc1:	.byte 8
sinx_adc2:	.byte 5
sinx_spd1:	.byte $fe
sinx_spd2:	.byte $03
sinx_temp:	.byte 0

sinus_x:
	lda #0
	sta xmsb_temp

	ldx sinx_idx1
	ldy sinx_idx2

	lda sinus256,x
	clc
	adc sinus88,y
	sta x0 + 1
	bcc !p+
	lda xmsb_temp
	ora #1
	sta xmsb_temp
!p:	txa
	clc
	adc sinx_adc1
	tax
	tya
	clc
	adc sinx_adc2
	tay

	lda sinus256,x
	clc
	adc sinus88,y
	sta x1 + 1
	bcc !p+
	lda xmsb_temp
	ora #2
	sta xmsb_temp
!p:	txa
	clc
	adc sinx_adc1
	tax
	tya
	clc
	adc sinx_adc2
	tay

	lda sinus256,x
	clc
	adc sinus88,y
	sta x2 + 1
	bcc !p+
	lda xmsb_temp
	ora #4
	sta xmsb_temp
!p:	txa
	clc
	adc sinx_adc1
	tax
	tya
	clc
	adc sinx_adc2
	tay

	lda sinus256,x
	clc
	adc sinus88,y
	sta x3 + 1
	bcc !p+
	lda xmsb_temp
	ora #8
	sta xmsb_temp
!p:	txa
	clc
	adc sinx_adc1
	tax
	tya
	clc
	adc sinx_adc2
	tay

	lda sinus256,x
	clc
	adc sinus88,y
	sta x4 + 1
	bcc !p+
	lda xmsb_temp
	ora #16
	sta xmsb_temp
!p:	txa
	clc
	adc sinx_adc1
	tax
	tya
	clc
	adc sinx_adc2
	tay

	lda sinus256,x
	clc
	adc sinus88,y
	sta x5 + 1
	bcc !p+
	lda xmsb_temp
	ora #32
	sta xmsb_temp
!p:	txa
	clc
	adc sinx_adc1
	tax
	tya
	clc
	adc sinx_adc2
	tay

	lda sinus256,x
	clc
	adc sinus88,y
	sta x6 + 1
	bcc !p+
	lda xmsb_temp
	ora #64
	sta xmsb_temp
!p:	txa
	clc
	adc sinx_adc1
	tax
	tya
	clc
	adc sinx_adc2
	tay

	lda sinus256,x
	clc
	adc sinus88,y
	sta x7 + 1
	bcc !p+
	lda xmsb_temp
	ora #128
	sta xmsb_temp
!p:
	lda xmsb_temp
	sta xmsb + 1

	lda sinx_adc1
	clc
	adc sinx_spd1
	sta sinx_adc1
	lda sinx_idx2
	clc
	adc sinx_spd2
	sta sinx_idx2
	rts

siny_table:	.byte 0, 0, 0, 0, 0, 0, 0, 0
siny_idx:	.byte 0
siny_adc:	.byte 16
siny_spd:	.byte 2
xmsb_temp:	.byte 0

sinus_y:
	ldy #0
	ldx siny_idx
!m:	lda sinus40,x
	clc
	adc #1
	sta siny_table,y
	txa
	clc
	adc siny_adc
	tax
	iny
	cpy #8
	bne !m-
	lda siny_idx
	clc
	adc siny_spd
	sta siny_idx
	rts

spr_colors:
	.byte 1, 7, 13, 15, 14, 4, 6, 9

sprite:
	.byte 0, 0, 0
	.byte %00000000, %00000000, %00000000
	.byte %00000000, %11111111, %00000000
	.byte %00000111, %11111111, %11100000
	.byte %00011111, %11000001, %11111000
	.byte %00111111, %10000000, %11100000
	.byte %01111111, %00000000, %00000000
	.byte %01111111, %00000000, %00000000
	.byte %11111111, %00000000, %00000000
	.byte %11111111, %00000000, %00000000
	.byte %11111111, %00000000, %00000000
	.byte %11111111, %00000000, %00000000
	.byte %11111111, %00000000, %00000000
	.byte %01111111, %00000000, %00000000
	.byte %01111111, %00000000, %11100000
	.byte %00111111, %10000000, %11111000
	.byte %00011111, %11000011, %11111000
	.byte %00000111, %11111111, %11100000
	.byte %00000000, %11111111, %00000000
	.byte %00000000, %00000000, %00000000
	.byte 0, 0, 0

.align $100

stretcher:
	ldy #0
	ldx #0
!m:	sty $d017
	lda d017_table,x
	sta $d017
	lda d011_table + 0,x
	bit $ea
	nop
	nop
	dec $d016
	sta $d011
	inc $d016
	inx
	cpx #64
	bne !m-
	rts

d017_table:
	.for (var i=0; i<64; i++) {
		.byte $ff
	}

d011_table:
	.for (var i=0; i<64; i++) {
		.byte (i & 7) | $10
	}

// MUSIC
	* = music.location "music"

	.fill music.size, music.getData(i)

	.print "music_init = $" + toHexString(music.init)
	.print "music_play = $" + toHexString(music.play)

.pc = $2000 "sinus"

sinus256:
	.fill $100, 127.5 + 128 * sin(toRadians(i * 360 / $100))
sinus88:
	.fill $100, 42.5 + 43 * sin(toRadians(i * 360 / $100))

sinus40:
	.fill $100, 19.5 + 20 * sin(toRadians(i * 360 / $100))

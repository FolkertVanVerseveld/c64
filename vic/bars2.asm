// Assembler: KickAssembler
// source: http://codebase64.org/doku.php?id=base:rasterbars_with_screen_on
// veel betere bars dan bars.asm. het werkt zelfs met het scherm aan

// coded by Bitbreaker Oxyron ^ Nuance ^ Arsenic
// feel free to change $d020/$d021 to other registers like $d022/$d023 for effects with multicolor charsets
// as you see, there are plenty of cycles free for more action.

BasicUpstart2(start)

        * = $2000
start:

.var tmpa    = $22
.var tmpx    = $23
.var tmpy    = $24
.var tmp_1   = $25

	sei
	lda #$7f
	sta $dc0d
	lda $dc0d
	lda #$01
	sta $d01a
	sta $d019
	lda #$32
	sta $d012
	lda $d011
	and #$3f
	sta $d011
	lda #$34
	sta $01
	lda #<irq1
	sta $fffe
	lda #>irq1
	sta $ffff
	cli
	jmp *

irq1:
	// irq enter stuff
	sta tmpa
	stx tmpx
	sty tmpy
	lda $01
	sta tmp_1
	lda #$35
	sta $01
	dec $d019

	ldx #$01
	dex
	bpl *-1

	// do raster
	jsr raster

	// exit irq
	lda tmp_1
	sta $01
	ldy tmpy
	ldx tmpx
	lda tmpa
	rti

raster:
	ldx #$00
!ll:
	ldy #$07       // 2

	lda tab,x      // 4
	sta $d020      // 4
	sta $d021      // 4
	inx            // 2
	cpx #$c8       // 2
	beq !d+        // 2
	nop            // 2 _20
!l:
	lda tab,x      // 4
	sta $d020      // 4
	sta $d021      // 4
	jsr !d+        // 12
	jsr !d+        // 12
	jsr !d+        // 12 _48
	nop            // 2
	inx            // 2
	cpx #$c8       // 2
	beq !d+        // 2
	dey            // 2
	beq !ll-       // 2 / 3 _61 (+2)
	bne !l-        // 3     _63
!d:
	rts

//!align 255, 0
	.align $100

// your colors go here
tab:
        .text "@kloaolk"
        .text "@kloaolk"
        .text "@kloaolk"
        .text "@kloaolk"
        .text "@kloaolk"
        .text "@kloaolk"
        .text "@kloaolk"
        .text "@kloaolk"
        .text "@kloaolk"
        .text "@kloaolk"
        .text "@kloaolk"
        .text "@kloaolk"
	.byte $06, $06, $06, $0e, $06, $0e
	.byte $0e, $06, $0e, $0e, $0e, $03
	.byte $0e, $03, $03, $0e, $03, $03
	.byte $03, $01, $03, $01, $01, $03
	.byte $01, $01, $01, $03, $01, $01
	.byte $03, $01, $03, $03, $03, $0e
	.byte $03, $03, $0e, $03, $0e, $0e
	.byte $0e, $06, $0e, $0e, $06, $0e
	.byte $06, $06, $06, $00, $00, $00
        .text "@kloaolk"
        .text "@kloaolk"
        .text "@kloaolk"
        .text "@kloaolk"
        .text "@kloaolk"
        .text "@kloaolk"
        .text "@kloaolk"
        .text "@kloaolk"
        .text "@kloaolk"
        .text "@kloaolk"
        .text "@kloaolk"
        .text "@kloaolk"
        .text "@kloaolk"

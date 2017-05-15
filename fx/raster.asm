.pc = $0801 "Basic Upstart Program"
:BasicUpstart($0810)

.pc = $0810 "Main Program"

.const screen  = $0400
.const colram  = $d800
.const sidbase = $d400

.const line_bar = $90
.const bar_delay = $10

start:
	jsr clear_sid
	jsr irq_init
idle:
	jmp idle

irq_init:
	sei
	lda #<irq_begin
	sta $0314
	lda #>irq_begin
	sta $0315
	asl $d019
	lda #$7b
	sta $dc0d
	lda #$81
	sta $d01a
	lda #$1b
	sta $d011
	lda #line_bar
	sta $d012
	cli
	rts

irq_begin:
	lda #<irq_wedge
	sta $0314
	lda #>irq_wedge
	sta $0315
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

irq_wedge:
	txs
	ldx #$08
!loop:
	dex
	bne !loop-
	bit $00
	lda $d012
	cmp $d012
	beq !delay+
!delay:
	// stable code
	ldx #$05
!loop:
	dex
	bne !loop-
	lda $d021
	sta raster_old
	lda $d020
	sta border_old
	ldy #$20
	// color line
!loop2:
	lda raster_tbl, y
	sta $d020
	sta $d021
	// wait
	ldx #$08
!loop:
	dex
	bne !loop-
	nop
	bit $00
	dey
	bne !loop2-

	lda border_old
	sta $d020
	lda raster_old
	sta $d021
	asl $d019 // ack
	pla
	tay
	pla
	tax
	pla
	rti

raster_tbl:
	.byte $0, $1, $2, $3
	.byte $4, $5, $6, $7
	.byte $8, $9, $a, $b
	.byte $c, $d, $e, $f
	.byte $f, $e, $d, $c
	.byte $b, $a, $9, $8
	.byte $7, $6, $5, $4
	.byte $3, $2, $1, $0


	lda $d021
	sta raster_old
	ldx #8
!loop:
	dex
	lda raster_tbl, x
	sta $d021
	bne !loop-
	lda raster_old
	sta $d021
	asl $d019 // ack
	pla
	tay
	pla
	tax
	pla
	rti
raster_old:
	.byte 0
border_old:
	.byte 0

raster_tbl2:
	.byte $b, $c, $f, $1, $f, $c, $b

clear_sid:
	ldx #$1c
	lda #0
!loop:
	sta sidbase, x
	dex
	bpl !loop-
	rts

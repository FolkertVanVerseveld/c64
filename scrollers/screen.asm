scr_clear:
	lda #scr_clear_char
	ldx #0
	// `wis' alle karakters door alles te vullen met spaties
!l:
	sta $0400, x
	sta $0500, x
	sta $0600, x
	sta $06e8, x
	inx
	bne !l-
	// verander kleur van alle karakters
	lda #scr_clear_color
	ldx #0
!l:
	sta $d800, x
	sta $d900, x
	sta $da00, x
	sta $dae8, x
	inx
	bne !l-
	rts

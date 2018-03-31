;Disk loader with flashing border done in ACME Cross-Assembler studied by Richard Bayliss

;Loader

                !to "disksaver.prg",cbm

                * = $c000
                sei
                lda #$37  ;Turn kernal on 
                sta $01
                jsr $ff81 ;Warm reset
                lda #$00  ;Black border + background
                sta $d020
                sta $d021

                ;Accumulate IRQ for flashing border routine
                lda #<flashload
                ldx #>flashload
                sta $0328
                stx $0329
                cli
                lda #$08
                ldx $ba ;Read from current disk drive present (Always use this instead of ldx #$08)
                tay
                jsr $ffba ;Is device present?
                lda #$06 ;File length
                ldx #<loadname
                ldy #>loadname     ;Set the load name
                jsr $ffbd          ;Disk drive searches/loads the loadname
                lda #$00
                jsr $ffd5          
                ldx #$08
                jsr $ffc3          
                jsr $ffcc
                jsr $ff81
                jsr $a659 ;BASIC RUN start
                jmp $a7ae

flashload       inc $d020
                dec $d020
                jmp $f6fe


loadname        !text"flname*"

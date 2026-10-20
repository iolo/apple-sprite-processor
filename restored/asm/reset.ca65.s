; ca65 translation of the adjacent Merlin source; ASP_ avoids reserved words.
.setcpu "6502"
.segment "CODE"
; Micro Software, January 1987, p.154, list 2.
; Reset-vector patch; install with CALL 912 ($0390).
.org $390
ASP_RAM:        BIT $C083
                BIT $C083
                LDA #<(ASP_HERE)
                STA $FFFC
                LDA #>(ASP_HERE)
                STA $FFFD
ASP_ROM:        BIT $C081
                BIT $C081
                RTS
ASP_HERE = *
                JSR ASP_ROM
                JMP $FA62

; ca65 translation of the adjacent Merlin source; ASP_ avoids reserved words.
.setcpu "6502"
.segment "CODE"
; GET-UTILITY - Micro Software, February 1987, pp.135-136, list 2.
.org $300
ASP_SCREEN = 0
ASP_MEMORY = 2
ASP_X = 6
ASP_Y = 7
ASP_WDTH = 8
ASP_HIGH = 9
ASP_CHRGET = $B1
ASP_GETBYT = $E6F8
ASP_GETBYTC = $E74C
ASP_FRENUM = $DD67
ASP_GETADR = $E752
ASP_ROM = $C081
ASP_RAM = $C083
                JSR ASP_CHRGET
                JSR ASP_GETBYT
                STX ASP_X
                JSR ASP_GETBYTC
                STX ASP_Y
                JSR ASP_GETBYTC
                STX ASP_LOOP+1
                JSR ASP_GETBYTC
                STX ASP_HIGH
                JSR ASP_CHRGET
                JSR ASP_FRENUM
                JSR ASP_GETADR
                LDA $50
                STA ASP_MEMORY
                LDA $51
                STA ASP_MEMORY+1
                BIT ASP_RAM
                LDX #0
ASP_LOOP:       LDA #0
                STA ASP_WDTH
                LDA ASP_Y
                LDY #0
                ASL
                BCC ASP_BRC01
                LDY #$A0
ASP_BRC01:      ASL
                BCC ASP_BRC02
                LDY #$50
ASP_BRC02:      AND #$1C
                ORA #$20
                STA ASP_SCREEN+1
                STY ASP_SCREEN
                LDA ASP_Y
                LSR
                LSR
                LSR
                LSR
                ROR ASP_SCREEN
                AND #3
                ORA ASP_SCREEN+1
                STA ASP_SCREEN+1
                LDY ASP_X
ASP_LOOP1:      LDA (ASP_SCREEN),Y
                STA (ASP_MEMORY,X)
                INY
                INC ASP_MEMORY
                BNE ASP_BRC03
                INC ASP_MEMORY+1
ASP_BRC03:      DEC ASP_WDTH
                BNE ASP_LOOP1
                INC ASP_Y
                DEC ASP_HIGH
                BNE ASP_LOOP
                BIT ASP_ROM
                RTS
ASP_END = *

* GET-UTILITY - Micro Software, February 1987, pp.135-136, list 2.
        ORG $300
        OBJ $300
SCREEN  = 0
MEMORY  = 2
X       = 6
Y       = 7
WDTH    = 8
HIGH    = 9
CHRGET  = $B1
GETBYT  = $E6F8
GETBYTC = $E74C
FRENUM  = $DD67
GETADR  = $E752
ROM     = $C081
RAM     = $C083
        JSR CHRGET
        JSR GETBYT
        STX X
        JSR GETBYTC
        STX Y
        JSR GETBYTC
        STX LOOP+1
        JSR GETBYTC
        STX HIGH
        JSR CHRGET
        JSR FRENUM
        JSR GETADR
        LDA $50
        STA MEMORY
        LDA $51
        STA MEMORY+1
        BIT RAM
        LDX #0
LOOP    LDA #0
        STA WDTH
        LDA Y
        LDY #0
        ASL
        BCC BRC01
        LDY #$A0
BRC01   ASL
        BCC BRC02
        LDY #$50
BRC02   AND #$1C
        ORA #$20
        STA SCREEN+1
        STY SCREEN
        LDA Y
        LSR
        LSR
        LSR
        LSR
        ROR SCREEN
        AND #3
        ORA SCREEN+1
        STA SCREEN+1
        LDY X
LOOP1   LDA (SCREEN),Y
        STA (MEMORY,X)
        INY
        INC MEMORY
        BNE BRC03
        INC MEMORY+1
BRC03   DEC WDTH
        BNE LOOP1
        INC Y
        DEC HIGH
        BNE LOOP
        BIT ROM
        RTS
END     = *

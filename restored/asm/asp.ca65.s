; ca65 translation of the adjacent Merlin source; ASP_ avoids reserved words.
.setcpu "6502"
.segment "CODE"
; Apple Sprite Processor, Version 1.0
; By SF-SOFTWARE.
; Created: Mar.31,1986; Modified: Nov.01,1986
; Assembler: Merlin
; Restored from Micro Software, February 1987, pp.137-147.
; Original source lines 1-78 (printed p.137 / PDF page 6).
ASP_START = $8700
ASP_PLANE = 56 ;Max127
ASP_PATTERN = 35 ;Max255
ASP_BKBUF = 37 ;Max63
ASP_PAR = 900 ;($384)
ASP_GPAGE = 230
ASP_BKPLANE = $D0 ;$D000
ASP_ROM = $C081
ASP_RAM1 = $C083
ASP_RAM2 = $C08B
ASP_PAGE1 = $C054
ASP_PAGE2 = $C055
ASP_COMM = $2FF-10
ASP_TMP = $FF
ASP_ZERO = 0
ASP_X1L = 2
ASP_X1H = 3
ASP_X2L = 4
ASP_X2H = 5
ASP_Y1L = 6
ASP_Y1H = 7
ASP_Y2L = 8
ASP_Y2H = 9
ASP_ILLERR = $E199
ASP_COUT1 = $FDF0
ASP_DELAY = $FCA8
.org ASP_START
ASP_SYS:        JMP ASP_MCNEW
                JMP ASP_PROCES
                JMP ASP_MCPUT
                JMP ASP_MCDEF
                JMP ASP_MCERASE
                JMP ASP_MCSET
                JMP ASP_MCGET
                JMP ASP_MCSWAP
                JMP ASP_MCCHANGE
                JMP ASP_MCIF
                JMP ASP_MCCMP
                JMP ASP_MCMOVE
                JMP ASP_MCCLEAR
                JMP ASP_MCDRAW
                JMP ASP_MCSHOW
                JMP ASP_MCMODE
                JMP ASP_MCHOME
                JMP ASP_MCCLIP
                JMP ASP_MCSOUND
                JMP ASP_MCINIT
; Original source lines 79-225 (p.138 / PDF page 7).
ASP_BGFUL1:     .byte 0 ;Bflag1
ASP_BGFUL2:     .byte 0 ;Bflag2
;START ASP Interpreter V1.1:
ASP_CHRGET = $B1
ASP_CHRGOT = $B7
ASP_TXT = $B8
ASP_SYNERR = $DEC9
ASP_GETBYT = $E6F8
ASP_GETBTC = $E74C
ASP_FRENUM = $DD67
ASP_GETDBL = $E752
ASP_CMDNUM = $00
ASP_BEGIN = *
                LDX #0
                STX ASP_CMDNUM
ASP_CMDLP0:     LDY #0
                INC ASP_CMDNUM
                LDA ASP_ASPCMD,X
                BEQ ASP_NOTCMD
                PHA
                CMP (ASP_TXT),Y
                BEQ ASP_TOKEN
                PLA
                BPL ASP_NXTCMD
                INX
                JMP ASP_CMDLP0
ASP_NOTOKN:     INY
                INX
ASP_CMDLP1:     LDA ASP_ASPCMD,X
                AND #$7F
                BEQ ASP_NOTCMD
                CMP (ASP_TXT),Y
                BNE ASP_NXTCMD
                LDA ASP_ASPCMD,X
                BMI ASP_CMDOK
                INX
                INY
                BNE ASP_CMDLP1
ASP_CMDLP2:     INX
ASP_NXTCMD:     LDA ASP_ASPCMD,X
                BPL ASP_CMDLP2
                INX
                JMP ASP_CMDLP0
ASP_NOTCMD:     RTS
ASP_TOKEN:      PLA
                BPL ASP_NOTOKN
                JSR ASP_CHRGET
                JMP ASP_EXEC
ASP_CMDOK:      TYA
                CLC
                ADC ASP_TXT
                STA ASP_TXT
                BCC *+4
                INC ASP_TXT+1
                JSR ASP_CHRGET
                JMP ASP_EXEC
ASP_ASPCMD = *
ASP_C1:         .byte $50, $52, $4F, $43, $45, $53, $D3
ASP_C2:         .byte $50, $55, $54, $A3
ASP_C3:         .byte $45, $52, $41, $53, $C5
ASP_C4:         .byte $AD ;if
ASP_C5:         .byte $43, $4D, $50, $A8
ASP_C6:         .byte $4D, $4F, $56, $C5
ASP_C7:         .byte $BD ;clear
ASP_C8:         .byte $53, $57, $41, $50, $A8
ASP_C9:         .byte $43, $4C, $49, $D0
ASP_C10:        .byte $94 ;draw
ASP_C11:        .byte $4D, $4F, $44, $C5
ASP_C12:        .byte $97 ;home
ASP_C13:        .byte $53, $48, $4F, $57, $A8
ASP_C14:        .byte $53, $50, $52, $49, $54, $45, $24, $A8
ASP_C15:        .byte $53, $45, $D4
ASP_C16:        .byte $BE ;get
ASP_C17:        .byte $43, $48, $41, $4E, $47, $45, $A8
ASP_C18:        .byte $50, $41, $47, $C5
ASP_C19:        .byte $53, $4F, $55, $4E, $C4
ASP_CEND:       .byte 0 ;EndFlag
ASP_EXEC:       LDX ASP_CMDNUM
ASP_PROC:       CPX #1
                BNE ASP_DEF
                JSR ASP_PROCES
                JMP ASP_CONTI
ASP_DEF:        CPX #14
                BNE ASP_ERASE
                JSR ASP_GETBYT
                STX ASP_PAR ;sn
                JSR ASP_TWOSKIP
                JSR ASP_GETBYT
                STX ASP_PAR+1 ;width
                JSR ASP_GETBTC
                STX ASP_PAR+2 ;high
                JSR ASP_GETNUM-3
                STY ASP_PAR+3 ;MainHi
                STX ASP_PAR+4 ;MainLo
                JSR ASP_CHRGOT
                LDY #$C0 ;flagSET
                CMP #','
                BNE *+5
                JSR ASP_GETNUM-3
                STY ASP_PAR+5 ;TsubHi
                STX ASP_PAR+6 ;TsubLo
                JSR ASP_MCDEF
                JMP ASP_CONTI
ASP_ERASE:      CPX #3
                BNE ASP_IF
                LDY #0
                STY ASP_PAR
                CMP #'#'
                BNE ASP_ERAS1
                LDY #1
                JSR ASP_CHRGET
                STY ASP_PAR
                JSR ASP_GETBYT
                STX ASP_PAR+1
ASP_ERAS1:      JSR ASP_MCERASE
                JMP ASP_CONTI
ASP_IF:         CPX #4
                BNE ASP_PUT
                JSR ASP_SHPCHK-3
                JSR ASP_GETBYT
                STX ASP_PAR
                JSR ASP_SHPCHK-3
                JSR ASP_GETBYT
                STX ASP_PAR+1
                JSR ASP_MCIF
                JSR ASP_CHRGET
                LDX ASP_PAR
                STX $9D ;ifflag
                JMP $D9CC ;Then-
ASP_PUT:        CPX #2
                BNE ASP_MOVE
; Original source lines 226-385 (p.139 / PDF page 8).
                JSR ASP_GETBYT
                STX ASP_PAR ;sp
                JSR ASP_TWOSKIP
                JSR ASP_GETNUM ;x
                STX ASP_PAR+1
                JSR ASP_GETNUM-3 ;y
                STX ASP_PAR+2
                JSR ASP_CHRGET
                LDX #0
                CMP #','
                BNE ASP_PUT0
                JSR ASP_GETBTC
ASP_PUT0:       STX ASP_PAR+3 ;sn
                JSR ASP_MCPUT
                JMP ASP_CONTI
ASP_MOVE:       CPX #6
                BNE ASP_CLIP
                JSR ASP_GETBYT
                STX ASP_PAR
                JSR ASP_CHRGET
                JSR ASP_GETBYT
                STX ASP_PAR+1
                JSR ASP_MCMOVE
                JMP ASP_CONTI
ASP_CLIP:       CPX #9
                BNE ASP_HOME
                JSR ASP_GETBYT
                STX ASP_PAR
                JSR ASP_GETBTC
                STX ASP_PAR+1
                JSR ASP_GETBTC
                STX ASP_PAR+2
                JSR ASP_GETBTC
                STX ASP_PAR+3
                JSR ASP_MCCLIP
                JMP ASP_CONTI
ASP_HOME:       CPX #12
                BNE ASP_SWAP
                JSR ASP_GETNUM
                STX ASP_PAR
                JSR ASP_GETNUM-3
                STX ASP_PAR+1
                JSR ASP_MCHOME
                JMP ASP_CONTI
ASP_SWAP:       CPX #8
                BNE ASP_DRAW
                JSR ASP_GETBYT
                STX ASP_PAR
                JSR ASP_GETBTC
                STX ASP_PAR+1
                JSR ASP_CHRGET
                JSR ASP_MCSWAP
                JMP ASP_CONTI
ASP_DRAW:       CPX #10
                BNE ASP_MODE
                JSR ASP_GETBYT
                STX ASP_PAR ;sn
                JSR ASP_TWOSKIP
                JSR ASP_GETNUM
                STX ASP_PAR+1 ;x
                JSR ASP_GETNUM-3
                STX ASP_PAR+2 ;y
                JSR ASP_CHRGET
                LDX #0
                CMP #','
                BEQ ASP_DRAW1
                JMP ASP_DRAW1+3
ASP_DRAW1:      JSR ASP_GETBTC
                STX ASP_PAR+3 ;page
                JSR ASP_MCDRAW
                JMP ASP_CONTI
ASP_MODE:       CPX #11
                BNE ASP_CLEAR
                LDY #1
                STY ASP_PAR+1
                STY ASP_PAR+2
                JSR ASP_GETBYT
                STX ASP_PAR ;screen
                JSR ASP_CHRGOT
                CMP #','
                BNE ASP_MODE1
                JSR ASP_GETBTC
                STX ASP_PAR+1 ;page1/2
                JSR ASP_CHRGOT
                CMP #','
                BNE ASP_MODE1
                JSR ASP_GETBTC
                STX ASP_PAR+2 ;ful/mix
ASP_MODE1:      JSR ASP_MCMODE
                JMP ASP_CONTI
ASP_CLEAR:      CPX #7
                BNE ASP_SHOW
                JSR ASP_GETBYT
                STX ASP_PAR
                JSR ASP_MCCLEAR
                JMP ASP_CONTI
ASP_SHOW:       CPX #13
                BNE ASP_CMP
                JSR ASP_GETBYT
                STX ASP_PAR
                JSR ASP_CHRGOT
                CMP #')'
                BEQ ASP_SHOW1
                JSR ASP_GETBTC
                JMP ASP_SHOW1+2
ASP_SHOW1:      LDX #77
                STX ASP_PAR+1
                JSR ASP_MCSHOW
                JSR ASP_CHRGET
                JMP ASP_CONTI
ASP_CMP:        CPX #5
                BNE ASP_CHANGE
                JSR ASP_GETBYT
                STX ASP_PAR
                JSR ASP_GETBTC
                STX ASP_PAR+1
                JSR ASP_TWOSKIP
                JSR ASP_CHRGET
                JSR ASP_GETBYT
                STX ASP_PAR+2
                JSR ASP_CHRGET
                JSR ASP_MCCMP
                JMP ASP_CONTI
ASP_CHANGE:     CPX #17
                BNE ASP_GET
                JSR ASP_GETBYT
                STX ASP_PAR
                JSR ASP_GETBTC
                STX ASP_PAR+1
                JSR ASP_CHRGET
                JSR ASP_MCCHANGE
                JMP ASP_CONTI
ASP_GET:        CPX #16
                BNE ASP_SET
                JSR ASP_SHPCHK
                JSR ASP_GETBYT
                STX ASP_PAR
                JSR ASP_GETNUM-3
                STX ASP_PAR+1
                STY ASP_PAR+2
                JSR ASP_MCGET
                JMP ASP_CONTI
ASP_SET:        CPX #15
                BNE ASP_PAGE
                JSR ASP_GETBYT
                STX ASP_PAR
                JSR ASP_SHPCHK-3
                JSR ASP_GETBYT
; Original source lines 386-540 (p.140 / PDF page 9).
                STX ASP_PAR+1
                JSR ASP_MCSET
                JMP ASP_CONTI
ASP_PAGE:       CPX #18
                BNE ASP_SOUND
                JSR ASP_GETBYT
                DEX
                CPX #2
                BCC *+5
                JMP ASP_ILLERR
                CPX #0
                BNE ASP_BPAGE2
                LDA #$20
                BNE ASP_BPAGE2+2
ASP_BPAGE2:     LDA #$40
                STA ASP_GPAGE
                JMP ASP_CONTI
ASP_SOUND:      CPX #19
                BNE ASP_LINK
                JSR ASP_GETBYT
                STX ASP_PAR ;reg-no.
                JSR ASP_GETBTC
                STX ASP_PAR+1 ;data
                LDX ASP_PSGND+1
                INX
                JSR ASP_CHRGOT
                CMP #','
                BNE *+5
                JSR ASP_GETBTC
                STX ASP_PAR+2 ;slot
                JSR ASP_MCSOUND
                JMP ASP_CONTI
ASP_LINK:       RTS
                NOP
                NOP
                RTS
ASP_CONTI:      JSR ASP_CHRGOT
                CMP #';'
                BNE ASP_CONTI-1
                JSR ASP_CHRGET
                JMP ASP_BEGIN
                JSR ASP_CHRGET
ASP_GETNUM:     JSR ASP_FRENUM
                JSR ASP_GETDBL
                LDX $50 ;Low
                LDY $51 ;Hi
                RTS
ASP_TWOSKIP:    JSR ASP_CHRGET
                JMP ASP_CHRGET
                JSR ASP_CHRGET
ASP_SHPCHK:     JSR ASP_CHRGOT
                CMP #'#'
                BEQ *+5
                JMP ASP_SYNERR
                JSR ASP_CHRGET
                RTS
;END ASP Interpreter
;BEGIN ASP MODULE
ASP_MCNEW = *
                BIT ASP_RAM1
                BIT ASP_ROM
ASP_AMPSET = *
                LDA #<(ASP_BEGIN)
                STA $3F6
                LDA #>(ASP_BEGIN)
                STA $3F7
ASP_HIMEM = *
                LDA #<(ASP_START)
                STA $6F
                STA $73
                LDA #>(ASP_START)
                STA $70
                STA $74
                LDA #$20
                STA ASP_GPAGE
                LDY #0
ASP_MSGLP:      LDA ASP_MSGTBL,Y
                BEQ ASP_MCINIT
                JSR ASP_COUT1
                INY
                BNE ASP_MSGLP
ASP_MSGTBL = *
                .byte $8D, $8D
                .byte $AF, $A0, $D7, $E5, $EC, $E3, $EF, $ED, $E5, $A0
                .byte $D4, $EF, $A0, $C1, $F0, $F0, $EC, $E5, $AD, $D3, $F0, $F2, $E9, $F4, $E5
                .byte $AD, $D0, $F2, $EF, $E3, $E5, $F3, $F3, $EF, $F2, $AE, $AE
                .byte $8D, $00
; 1.MODULE(INITIALIZE).
ASP_MCINIT = *
                LDY #ASP_PLANE-1
ASP_INIT1:      LDA #0
                STA ASP_STAT,Y
                DEY
                BPL ASP_INIT1
                STA ASP_BUF1
                STA ASP_BUF2
                LDA #$FF
ASP_INIT2:      JSR ASP_INIT3
                LDA #$2C ;Bit
                STA ASP_INIT2
                RTS
ASP_INIT3:      LDY #ASP_PATTERN
                STA ASP_TWDTH,Y
                DEY
                BPL ASP_INIT3+2
                RTS
; 2.MODULE(SPRITE-PROCESS).
; (Sprite-Processor), (C) Mar.31,1986
ASP_X = 6
ASP_Y = 7
ASP_HIGH = 8
ASP_WDTH = 9
ASP_SCRN = 0
ASP_SPRTPRCS = *
                BIT ASP_RAM1
                LDX #ASP_PLANE-1
ASP_SPLP:       LDA ASP_STAT,X
                BEQ *+5
                JSR ASP_SPRTON
                DEX
                BPL ASP_SPLP
                BIT ASP_ROM
                RTS
ASP_SPRTON = *
                TAY
                LDA ASP_TWDTH-1,Y
                BNE *+3
                RTS
                BMI *-1
                PHA
                STA ASP_YSKIP+3
; Original source lines 541-700 (p.141 / PDF page 10).
                LDA ASP_TX,X
                SEC
ASP_RELX:       SBC #0
                STA ASP_X ;setX
                PLA
                CLC
                ADC ASP_X
                STA ASP_WDTH ;setWDTH
                LDA ASP_TY,X
                SEC
ASP_RELY:       SBC #0
                STA ASP_Y ;setY
                LDA ASP_THIGH-1,Y
                STA ASP_HIGH ;setHIGH
                LDA ASP_TMAINL-1,Y
                STA ASP_MAINPTN+1 ;setMAIN
                LDA ASP_TMAINH-1,Y
                STA ASP_MAINPTN+2
                LDA ASP_TSUBL-1,Y
                STA ASP_SUBPTN+1 ;setSUB
                LDA ASP_TSUBH-1,Y
                STA ASP_SUBPTN+2
                BEQ ASP_PUTBLCK
                STX ASP_TMP
                LDX #0
                JSR ASP_PUTSPRT
                LDX ASP_TMP
                RTS
ASP_PUTBLCK = *
                LDA #$BD ;LDR
                STA ASP_MAINPTN
                STX ASP_TMP
                LDX #0
                JSR ASP_PUTSPRT
                LDX ASP_TMP
                LDA #$1D ;ORA
                STA ASP_MAINPTN
                RTS
;(Draw SPRITE on SPRITE-PLANE).
ASP_PUTSPRT = *
                LDY ASP_Y
ASP_CLIPSY1:    CPY #0
                BCC ASP_YSKIP
ASP_CLIPSY2:    CPY #192
                BCC ASP_GETHADR
ASP_YSKIP:      TXA
                CLC
                ADC #0 ;skipWITH
                TAX
                BCC *+8
                INC ASP_MAINPTN+2
                INC ASP_SUBPTN+2
                JMP ASP_SNXT1
ASP_GETHADR:    LDA ASP_HADRH,Y
                CLC
ASP_ADP:        ADC #$00
                STA ASP_SCRN+1
                LDA ASP_HADRL,Y
                STA ASP_SCRN
                LDY ASP_X
ASP_CLIPSX1:    CPY #0
                BCC ASP_WSKIP
ASP_CLIPSX2:    CPY #40
                BCS ASP_WSKIP
                LDA (ASP_SCRN),Y
ASP_SUBPTN:     AND $BCAD,X
ASP_MAINPTN:    ORA $ACAD,X
                STA (ASP_SCRN),Y
ASP_WSKIP:      INX
                BEQ ASP_INCADR
ASP_SNXT:       INY  ;x=x+1
                CPY ASP_WDTH
                BNE ASP_CLIPSX1
ASP_SNXT1:      INC ASP_Y ;y=y+1
                DEC ASP_HIGH ;h=h-1
                BNE ASP_PUTSPRT
                RTS
ASP_INCADR:     INC ASP_MAINPTN+2
                INC ASP_SUBPTN+2
                JMP ASP_SNXT
; 3.MODULE(PROCESS).
ASP_PROCES = *
                LDA ASP_GPAGE
                CMP #$20
                BNE ASP_SCREEN2
ASP_SCREEN1:    LDA #0
                STA ASP_ADP+1
                STA ASP_BADP+1
                JSR ASP_BGP1
                JSR ASP_BGM1
                JSR ASP_SPRTPRCS
ASP_MCVSW1:     LDA #$40
                STA ASP_GPAGE
                BIT ASP_PAGE1
                RTS
ASP_SCREEN2:    LDA #$20
                STA ASP_ADP+1
                STA ASP_BADP+1
                JSR ASP_BGP2
                JSR ASP_BGM2
                JSR ASP_SPRTPRCS
ASP_MCVSW2:     LDA #$20
                STA ASP_GPAGE
                BIT ASP_PAGE2
                RTS
; 4.MODULE(PATTERN-DEFINE).
ASP_MCDEF:      LDX ASP_PAR
                BEQ *+6
                CPX #ASP_PATTERN+1
                BCC *+5
                JMP ASP_ILLERR
                LDA ASP_PAR+1
                STA ASP_TWDTH-1,X
                LDA ASP_PAR+2
                STA ASP_THIGH-1,X
                LDA ASP_PAR+3
                STA ASP_TMAINH-1,X
                LDA ASP_PAR+4
                STA ASP_TMAINL-1,X
                LDA ASP_PAR+5
                CMP #$C0
                BEQ ASP_CALCSUB
                STA ASP_TSUBH-1,X
                LDA ASP_PAR+6
                STA ASP_TSUBL-1,X
                RTS
ASP_CALCSUB:    LDY #0
                LDA ASP_PAR+3
                STA ASP_ZERO+1
                LDA ASP_PAR+4
                STA ASP_ZERO
ASP_MCDF2:      LDA ASP_ZERO
                CLC
                ADC ASP_PAR+1
                STA ASP_ZERO
                BCC *+4
                INC ASP_ZERO+1
                INY
                CPY ASP_PAR+2
                BCC ASP_MCDF2
                LDA ASP_ZERO+1
                STA ASP_TSUBH-1,X
                LDA ASP_ZERO
; Original source lines 701-860 (p.142 / PDF page 11).
                STA ASP_TSUBL-1,X
                RTS
; 5.MODULE(ERASE-SPRITE).
ASP_MCERASE:    LDA ASP_PAR
                BNE ASP_MCERAS1
                TAY
ASP_MCERALP:    STA ASP_STAT,Y ;Global
                INY
                CPY #ASP_PLANE
                BCC ASP_MCERALP
                RTS
ASP_MCERAS1:    LDA #0 ;Local
                LDY ASP_PAR+1
                CPY #ASP_PLANE
                BCC *+5
                JMP ASP_ILLERR
                STA ASP_STAT,Y
                RTS
; 6.MODULE(IF).
ASP_MCIF = *
                LDX ASP_PAR ;sp1
                CPX #ASP_PLANE
                BCC *+5
ASP_XIFERR:     JMP ASP_ILLERR
                LDY ASP_PAR+1 ;sp2
                CPY #ASP_PLANE
                BCS ASP_XIFERR
                LDA ASP_STAT,Y
                BEQ ASP_FALSE
                TAX
                LDA ASP_TX,Y
                STA ASP_X2L
                CLC
                ADC ASP_TWDTH-1,X
                STA ASP_X2H
                LDA ASP_TY,Y
                STA ASP_Y2L
                CLC
                ADC ASP_THIGH-1,X
                STA ASP_Y2H
                LDY ASP_PAR ;sp1
                LDA ASP_STAT,Y
                BEQ ASP_FALSE
                TAX
                LDA ASP_TX,Y
                STA ASP_X1L
                CLC
                ADC ASP_TWDTH-1,X
                STA ASP_X1H
                LDA ASP_TY,Y
                STA ASP_Y1L
                CLC
                ADC ASP_THIGH-1,X
                STA ASP_Y1H
ASP_CHECK = *
                LDA ASP_Y1L
                CMP ASP_Y2H
                BCS ASP_FALSE
                LDA ASP_Y1H
                CMP ASP_Y2L
                BCC ASP_FALSE
                BEQ ASP_FALSE
                LDA ASP_X1L
                CMP ASP_X2H
                BCS ASP_FALSE
                LDA ASP_X1H
                CMP ASP_X2L
                BCC ASP_FALSE
                BEQ ASP_FALSE
ASP_TRUE:       LDA #1
                STA ASP_PAR
                RTS
ASP_FALSE:      LDA #0
                STA ASP_PAR
                RTS
; 7.MODULE(PUT-SPRITE).
ASP_MCPUT = *
                LDX ASP_PAR ;sp
                CPX #ASP_PLANE
                BCS ASP_XPUTERR
                LDA ASP_PAR+1 ;x
                STA ASP_TX,X
                LDA ASP_PAR+2 ;y
                STA ASP_TY,X
                LDY ASP_PAR+3 ;sn
                BNE ASP_MCPUT1
                LDA ASP_STAT,X
                TAY
                BEQ ASP_XPUTERR-1 ;abort
ASP_MCPUT1:     CPY #ASP_PATTERN+1
                BCS ASP_XPUTERR
                LDA ASP_TWDTH-1,Y
                BMI ASP_XPUTERR
                TYA
                STA ASP_STAT,X
                RTS
ASP_XPUTERR:    JMP ASP_ILLERR
; 8.MODULE(CMP).
ASP_MCCMP = *
                LDA #0 ;Reset Flag
                STA ASP_ZERO
                LDA ASP_PAR+2 ;sn2
                STA ASP_CMPLP+1
                LDA ASP_PAR ;sn0
                STA ASP_TMP
                LDA ASP_PAR+1 ;sn1
                CMP #ASP_PLANE
                BCC *+5
                JMP ASP_ILLERR
                STA ASP_CMPEND+1
ASP_CMPLP = *
                LDA #0
                STA ASP_PAR
                LDX ASP_TMP
                CPX ASP_CMPLP+1
                BEQ ASP_CMPNXT
                STX ASP_PAR+1
                JSR ASP_MCIF
                LDX ASP_TMP
                LDA ASP_PAR
                BEQ ASP_CMPNXT
                LDA #1
                STA ASP_ZERO
                STX ASP_CMPNT+1
ASP_CMPNXT = *
                INC ASP_TMP
ASP_CMPEND:     CPX #ASP_PLANE
                BCC ASP_CMPLP
                LDA ASP_ZERO
                STA ASP_PAR ;T/F
ASP_CMPNT:      LDX #0
                STX ASP_PAR+1 ;sp
                LDA ASP_STAT,X
                STA ASP_PAR+2 ;sn
                RTS
; 9.MODULE(MOVE-SCREEN).
ASP_SCRN1 = 0 ;0/1
ASP_SCRN2 = 2 ;2/3
ASP_SCRN3 = 4 ;4/5
ASP_BX = 6
ASP_BY = 7
ASP_BH = 8
ASP_BW = 9
; Original source lines 861-1020 (p.143 / PDF page 12).
ASP_MCMOVE = *
                LDA #<(ASP_MVLP2+1)
                STA ASP_MVADR+1
                LDA #>(ASP_MVLP2+1)
                STA ASP_MVADR+2
                LDY ASP_PAR
                JSR ASP_MVRTN
ASP_MVNXT:      LDA #<(ASP_MVPNT+1)
                STA ASP_MVADR+1
                LDA #>(ASP_MVPNT+1)
                STA ASP_MVADR+2
                LDY ASP_PAR+1
                JSR ASP_MVRTN
                BIT ASP_RAM2
                JSR ASP_MVDRAW
                BIT ASP_ROM
                RTS
ASP_MVRTN:      DEY
                CPY #3
                BCC *+5
                JMP ASP_ILLERR
                LDX #ASP_SCRN1
                CPY #2
                BNE *+4
                LDX #ASP_SCRN3
                CPY #1
                BNE *+4
                LDX #ASP_SCRN2
ASP_MVADR:      STX $CDEF
                RTS
ASP_MVDRAW = *
                LDA ASP_CLIPSX1+1
                STA ASP_BX ;x
                LDA ASP_CLIPSY1+1
                STA ASP_BY ;y
                TAX
                LDA ASP_CLIPSY2+1
                SEC
                SBC ASP_BY
                STA ASP_BH ;high
                LDA ASP_CLIPSX2+1
                STA ASP_BW ;width
ASP_MVLP1 = *
                LDA ASP_HADRH,X
                STA ASP_SCRN1+1
                CLC
                ADC #$20
                STA ASP_SCRN2+1
                ADC #ASP_BKPLANE-$40
                STA ASP_SCRN3+1
                LDA ASP_HADRL,X
                STA ASP_SCRN1
                STA ASP_SCRN3
                STA ASP_SCRN2
                LDY ASP_BX
ASP_MVLP2 = *
                LDA (ASP_SCRN1),Y
ASP_MVPNT:      STA (ASP_SCRN3),Y
                INY
                CPY ASP_BW
                BCC ASP_MVLP2
                INX
                DEC ASP_BH
                BNE ASP_MVLP1
                RTS
; 10.MODULE(CLIP).
ASP_MCCLIP = *
                LDA ASP_PAR ;Xmin
                CMP ASP_PAR+1
                BCS ASP_CLIPERR
                CMP #40
                BCS ASP_CLIPERR
                STA ASP_CLIPSX1+1
                STA ASP_CLIPBX1+1
                LDX ASP_PAR+1 ;Xmax
                CPX #41
                BCS ASP_CLIPERR
                STX ASP_CLIPSX2+1
                STX ASP_CLIPBX2+1
                LDA ASP_PAR+2 ;Ymin
                CMP ASP_PAR+3
                BCS ASP_CLIPERR
                CMP #192
                BCS ASP_CLIPERR
                STA ASP_CLIPSY1+1
                STA ASP_CLIPBY1+1
                LDX ASP_PAR+3 ;Ymax
                CPX #193
                BCS ASP_CLIPERR
                STX ASP_CLIPSY2+1
                STX ASP_CLIPBY2+1
                RTS
ASP_CLIPERR:    JMP ASP_ILLERR
; 11.MODULE(HOME).
ASP_MCHOME = *
                LDA ASP_PAR
                STA ASP_RELX+1
                STA ASP_RELX1+1
                LDA ASP_PAR+1
                STA ASP_RELY+1
                STA ASP_RELY1+1
                RTS
; 12.MODULE(SCREEN-MODE).
ASP_MCMODE:     LDY ASP_PAR
                CPY #3
                BCC *+5
ASP_XMODERR:    JMP ASP_ILLERR
                LDX ASP_PAR+2
                CPX #2
                BCS ASP_XMODERR
                STA $C052,X ;ful/mix
                CPY #0
                BNE ASP_GRAPH
ASP_TEXT:       BIT $C051
                JMP ASP_BOTH
ASP_GRAPH:      BIT $C050
                STA $C056-1,Y ;gr/hgr
ASP_BOTH:       LDY ASP_PAR+1
                DEY
                CPY #2
                BCS ASP_XMODERR
                STA $C054,Y ;page1/2
                RTS
; 13.MODULE(SHOW).
ASP_X1 = 6
ASP_X2 = 7
ASP_CNT = 8
ASP_MCSHOW:     DEC ASP_PAR
                LDY ASP_PAR
                CPY #3
                BCC *+5
                JMP ASP_ILLERR
                LDA #$60 ;rts
                STA ASP_MCVSW1
                STA ASP_MCVSW2
                LDX ASP_PAR+1 ;time
                STX ASP_WAIT+1
                LDX ASP_GPAGE
                CPX #$20
                BNE ASP_MCSHW1
                JSR ASP_SCREEN1
; Original source lines 1021-1180 (p.144 / PDF page 13).
                LDX #ASP_SCRN1
                LDY #ASP_SCRN2
                JSR ASP_MCSHW2
                JSR ASP_BGM2
                JMP ASP_MCSHW99
ASP_MCSHW1:     JSR ASP_SCREEN2
                LDX #ASP_SCRN2
                LDY #ASP_SCRN1
                JSR ASP_MCSHW2
                JSR ASP_BGM1
ASP_MCSHW99:    LDA #$A9 ;LDA#
                STA ASP_MCVSW1
                STA ASP_MCVSW2
                RTS
ASP_MCSHW2:     STX ASP_GSW1+1
                STY ASP_GSW2+1
                LDA ASP_PAR ;type?
                BNE ASP_MCSHOW2
; type1
                LDY #0 ;x=0
ASP_MCSHW11:    LDX #0 ;y=0
                JSR ASP_GCALC
                JSR ASP_SHOWMV
                INX
                CPX #192
                BCC ASP_MCSHW11+2
                JSR ASP_WAIT
                INY
                CPY #40
                BCC ASP_MCSHW11
                RTS
ASP_MCSHOW2:    CMP #1
                BNE ASP_MCSHOW3
; type2
                LDX #0 ;y=0
ASP_MCSHW21:    JSR ASP_GCALC
                LDY #0 ;x=0
ASP_MCSHW2LP:   JSR ASP_SHOWMV
                INY
                CPY #40
                BCC ASP_MCSHW2LP
                JSR ASP_WAIT
                INX
                CPX #192
                BCC ASP_MCSHW21
                RTS
ASP_MCSHOW3:    LDA #19 ;type3
                STA ASP_X1
                LDA #20
                STA ASP_X2
                STA ASP_CNT
ASP_MCSHW31:    LDX #0 ;y=0
                JSR ASP_GCALC
                LDY ASP_X1
                JSR ASP_SHOWMV
                LDY ASP_X2
                JSR ASP_SHOWMV
                INX
                CPX #192
                BCC ASP_MCSHW31+2
                DEC ASP_X1
                INC ASP_X2
                JSR ASP_WAIT
                DEC ASP_CNT
                BNE ASP_MCSHW31
                RTS
ASP_SHOWMV = *
ASP_GSW1:       LDA (ASP_SCRN2),Y
ASP_GSW2:       STA (ASP_SCRN1),Y
                RTS
ASP_GCALC:      LDA ASP_HADRH,X
                STA ASP_SCRN1+1
                CLC
                ADC #$20
                STA ASP_SCRN2+1
                LDA ASP_HADRL,X
                STA ASP_SCRN1
                STA ASP_SCRN2
                RTS
ASP_WAIT:       LDA #88
                JMP ASP_DELAY
; 14.MODULE(SET).
ASP_MCSET:      LDY ASP_PAR
                BEQ ASP_XSETERR
                LDA ASP_TWDTH-1,Y
                CMP #$FF ;NotDef?
                BNE *+5
ASP_XSETERR:    JMP ASP_ILLERR
                CPY #ASP_PATTERN+1
                BCS ASP_XSETERR
                TYA
                LDX ASP_PAR+1
                CPX #ASP_PLANE
                BCS ASP_XSETERR
                STA ASP_STAT,X
                RTS
; 15.MODULE(DRAW-PATTERN).
ASP_MCDRAW:     LDA ASP_ADP+1
                STA ASP_COMM+2
                LDX ASP_PAR ;sn
                BEQ ASP_XDRWERR
                CPX #ASP_PATTERN+1
                BCS ASP_XDRWERR
                LDA ASP_TWDTH-1,X
                CMP #$FF ;NotDef?
                BEQ ASP_XDRWERR
                LDY ASP_PAR+3 ;page
                BEQ ASP_MCDRAW1
                CPY #3
                BCC *+5
ASP_XDRWERR:    JMP ASP_ILLERR
                LDA #0
                CPY #1
                BEQ ASP_MCDRAW01
                CLC
                ADC #$20
ASP_MCDRAW01:   STA ASP_ADP+1
ASP_MCDRAW1:    LDA ASP_TX
                STA ASP_COMM
                LDA ASP_TY
                STA ASP_COMM+1
                LDA ASP_PAR+1
                STA ASP_TX
                LDA ASP_PAR+2
                STA ASP_TY
                TXA
                LDX #0
                BIT ASP_RAM1
                JSR ASP_SPRTON
                BIT ASP_ROM
                LDA ASP_COMM
                STA ASP_TX
                LDA ASP_COMM+1
                STA ASP_TY
                LDA ASP_COMM+2
                STA ASP_ADP+1
                RTS
; 16.MODULE(CHANGE).
ASP_MCCHANGE = *
                LDX ASP_PAR
                BEQ ASP_XCHNERR
                CPX #ASP_PATTERN+1
                BCS ASP_XCHNERR
                STX ASP_ZERO
; Original source lines 1181-1340 (p.145 / PDF page 14).
                LDY ASP_PAR+1
                BEQ ASP_MCCHN0 ;erase
                CPY #ASP_PATTERN+1
                BCS ASP_XCHNERR
ASP_MCCHN0 = *
                LDX #ASP_PLANE-1
ASP_MCCHN1:     LDA ASP_STAT,X
                CMP ASP_ZERO ;sn1
                BNE ASP_MCCHN2
                TYA
                STA ASP_STAT,X
ASP_MCCHN2:     DEX
                BPL ASP_MCCHN1
                RTS
ASP_XCHNERR:    JMP ASP_ILLERR
; 17.MODULE(SWAP).
ASP_MCSWAP = *
                LDA ASP_PAR
                BEQ ASP_XSWPERR
                CMP #ASP_PATTERN+1
                BCC *+5
ASP_XSWPERR:    JMP ASP_ILLERR
                LDA ASP_PAR+1
                BEQ ASP_XSWPERR
                CMP #ASP_PATTERN+1
                BCS ASP_XSWPERR
                LDX #ASP_PLANE-1
ASP_MCSWP1:     LDA ASP_STAT,X
                JSR ASP_MCSWPRTN
                STA ASP_STAT,X
                DEX
                BPL ASP_MCSWP1
                RTS
ASP_MCSWPRTN:   CMP ASP_PAR
                BNE *+6
                LDA ASP_PAR+1
                RTS
                CMP ASP_PAR+1
                BNE *-4
                LDA ASP_PAR
                RTS
; 18.MODULE(CLEAR).
ASP_MCCLEAR = *
                LDY ASP_PAR
                DEY
                CPY #3
                BCC *+5
                JMP ASP_ILLERR
                LDA #$A9 ;LDA#
                STA ASP_MVLP2
                LDA #0
                STA ASP_MVLP2+1
                LDA ASP_PAR
                STA ASP_PAR+1
                JSR ASP_MVNXT
                LDA #$B1 ;LD(z),Y
                STA ASP_MVLP2
                LDA #ASP_SCRN1
                STA ASP_MVLP2+1
                RTS
; 19.MODULE(GET).
ASP_MCGET:      LDA ASP_PAR+1
                STA ASP_MCGT1+1
                LDA ASP_PAR+2
                STA ASP_MCGT1+2
                LDX ASP_PAR
                CPX #ASP_PLANE
                BCC *+5
                JMP ASP_ILLERR
                LDA ASP_STAT,X
ASP_MCGT1:      STA $ACAD
                RTS
; 20.MODULE(SOUND).
; NEED Mocking-Board.
ASP_MCSOUND = *
                LDX ASP_PAR
                CPX #16
                BCS ASP_XPSGERR
                STX ASP_ZERO+2
                LDX ASP_PAR+2
                DEX
                CPX #2
                BCS ASP_XPSGERR
                STX ASP_PSGND+1
ASP_PSGINIT:    LDA #$FF
                STA $C403
                STA $C483
                LDA #7
                STA $C402
                STA $C482
                LDA #$C4
                STA ASP_ZERO+1
ASP_PSGND:      LDA #0 ;PSG1/2
                BEQ ASP_MCPSG1
                CLC
                ADC #$7F
ASP_MCPSG1:     STA ASP_ZERO
                LDX #7
                LDA ASP_ZERO+2 ;reg-no.
                JSR ASP_WRITE
                LDX #6
                LDA ASP_PAR+1 ;data
ASP_WRITE:      LDY #1
                STA (ASP_ZERO),Y
                TXA
                DEY
                STA (ASP_ZERO),Y
                LDA #4
                STA (ASP_ZERO),Y
                RTS
ASP_XPSGERR:    JMP ASP_ILLERR
; 21.MODULE(BGM).
ASP_BUF = 2
ASP_BGM1:       JSR ASP_BUF1SET
                STY ASP_BGFUL1
                JSR ASP_BGM
                JSR ASP_BGMCHK
                STX ASP_BGFUL1
                RTS
ASP_BGM2:       JSR ASP_BUF2SET
                STY ASP_BGFUL2
                JSR ASP_BGM
                JSR ASP_BGMCHK
                STX ASP_BGFUL2
                RTS
ASP_BGMCHK:     LDX #0
                LDA ASP_CNT
                CMP #ASP_BKBUF+1
                BCC *+4
                LDX #$80
                RTS
ASP_BUF1SET:    LDA #<(ASP_BUF1)
                STA ASP_BUF
                LDA #>(ASP_BUF1)
                STA ASP_BUF+1
                LDY #0
                RTS
; Original source lines 1341-1486 (p.146 / PDF page 15).
ASP_BUF2SET:    LDA #<(ASP_BUF2)
                STA ASP_BUF
                LDA #>(ASP_BUF2)
                STA ASP_BUF+1
                LDY #0
                RTS
ASP_BGM:        STY ASP_CNT ;cnt=0
                LDX #ASP_PLANE-1
ASP_BGMLP1:     LDA ASP_STAT,X
                BNE ASP_BGMON
                DEX
                BPL ASP_BGMLP1
                LDA #0
                STA (ASP_BUF),Y
                RTS
ASP_BGMON:      STX ASP_TMP
                TAX
                LDA ASP_TWDTH-1,X
                BNE *+6
                TXA
                JMP ASP_BGMLP1+5
                STA (ASP_BUF),Y
                INY
                LDA ASP_THIGH-1,X
                STA (ASP_BUF),Y
                INY
                LDX ASP_TMP
                LDA ASP_TX,X
                SEC
ASP_RELX1:      SBC #0
                STA (ASP_BUF),Y
                INY
                LDA ASP_TY,X
                SEC
ASP_RELY1:      SBC #0
                STA (ASP_BUF),Y
                INY
                INC ASP_CNT
                JMP ASP_BGMLP1+5
; 22.MODULE(BGP).
ASP_BGP1:       LDA ASP_BGFUL1
                BNE ASP_BGP11
                JSR ASP_BUF1SET
                JMP ASP_BGPWT
ASP_BGP11:      LDY #1
                BNE ASP_BGPALL
ASP_BGP2:       LDA ASP_BGFUL2
                BNE ASP_BGP21
                JSR ASP_BUF2SET
                JMP ASP_BGPWT
ASP_BGP21:      LDY #2
ASP_BGPALL:     LDA #3
                STA ASP_PAR
                STY ASP_PAR+1
                JMP ASP_MCMOVE
ASP_BGPWT:      BIT ASP_RAM2
ASP_BGPWTL:     LDA (ASP_BUF),Y ;Wdth=0?
                BEQ ASP_BGPWT0 ;Yes=EOJ
                TAX
                INY
                LDA (ASP_BUF),Y
                STA ASP_HIGH
                INY
                LDA (ASP_BUF),Y
                STA ASP_X
                TXA
                CLC
                ADC ASP_X
                STA ASP_WDTH
                INY
                LDA (ASP_BUF),Y
                TAX
                STY ASP_TMP
                JSR ASP_BGPRTN
                LDY ASP_TMP
                INY
                BNE ASP_BGPWTL
ASP_BGPWT0:     BIT ASP_ROM
                RTS
ASP_BGPRTN = *
ASP_CLIPBY1:    CPX #0
                BCC ASP_BSKIP
ASP_CLIPBY2:    CPX #192
                BCC ASP_GETBADR
ASP_BSKIP:      JMP ASP_BGP02
ASP_GETBADR:    LDA ASP_HADRH,X
                TAY
                CLC
ASP_BADP:       ADC #0
                STA ASP_SCRN1+1
                TYA
                CLC
                ADC #ASP_BKPLANE-$20
                STA ASP_SCRN3+1
                LDA ASP_HADRL,X
                STA ASP_SCRN1
                STA ASP_SCRN3
                LDY ASP_X
ASP_CLIPBX1:    CPY #0
                BCC ASP_BGP01
ASP_CLIPBX2:    CPY #40
                BCS ASP_BGP01
                LDA (ASP_SCRN3),Y
                STA (ASP_SCRN1),Y
ASP_BGP01:      INY
                CPY ASP_WDTH
                BNE ASP_CLIPBX1
ASP_BGP02:      INX
                DEC ASP_HIGH
                BNE ASP_BGPRTN
                RTS
;END ASP MODULE
; 22.TABLE(Hires-Address).
ASP_HADRL = *
                .byte $00, $00, $00, $00, $00, $00, $00, $00
                .byte $80, $80, $80, $80, $80, $80, $80, $80
                .byte $00, $00, $00, $00, $00, $00, $00, $00
                .byte $80, $80, $80, $80, $80, $80, $80, $80
                .byte $00, $00, $00, $00, $00, $00, $00, $00
                .byte $80, $80, $80, $80, $80, $80, $80, $80
                .byte $00, $00, $00, $00, $00, $00, $00, $00
                .byte $80, $80, $80, $80, $80, $80, $80, $80
                .byte $28, $28, $28, $28, $28, $28, $28, $28
                .byte $A8, $A8, $A8, $A8, $A8, $A8, $A8, $A8
                .byte $28, $28, $28, $28, $28, $28, $28, $28
                .byte $A8, $A8, $A8, $A8, $A8, $A8, $A8, $A8
                .byte $28, $28, $28, $28, $28, $28, $28, $28
                .byte $A8, $A8, $A8, $A8, $A8, $A8, $A8, $A8
                .byte $28, $28, $28, $28, $28, $28, $28, $28
; Original source lines 1487-1541 (p.147 / PDF page 16).
                .byte $A8, $A8, $A8, $A8, $A8, $A8, $A8, $A8
                .byte $50, $50, $50, $50, $50, $50, $50, $50
                .byte $D0, $D0, $D0, $D0, $D0, $D0, $D0, $D0
                .byte $50, $50, $50, $50, $50, $50, $50, $50
                .byte $D0, $D0, $D0, $D0, $D0, $D0, $D0, $D0
                .byte $50, $50, $50, $50, $50, $50, $50, $50
                .byte $D0, $D0, $D0, $D0, $D0, $D0, $D0, $D0
                .byte $50, $50, $50, $50, $50, $50, $50, $50
                .byte $D0, $D0, $D0, $D0, $D0, $D0, $D0, $D0
ASP_HADRH = *
                .byte $20, $24, $28, $2C, $30, $34, $38, $3C
                .byte $20, $24, $28, $2C, $30, $34, $38, $3C
                .byte $21, $25, $29, $2D, $31, $35, $39, $3D
                .byte $21, $25, $29, $2D, $31, $35, $39, $3D
                .byte $22, $26, $2A, $2E, $32, $36, $3A, $3E
                .byte $22, $26, $2A, $2E, $32, $36, $3A, $3E
                .byte $23, $27, $2B, $2F, $33, $37, $3B, $3F
                .byte $23, $27, $2B, $2F, $33, $37, $3B, $3F
                .byte $20, $24, $28, $2C, $30, $34, $38, $3C
                .byte $20, $24, $28, $2C, $30, $34, $38, $3C
                .byte $21, $25, $29, $2D, $31, $35, $39, $3D
                .byte $21, $25, $29, $2D, $31, $35, $39, $3D
                .byte $22, $26, $2A, $2E, $32, $36, $3A, $3E
                .byte $22, $26, $2A, $2E, $32, $36, $3A, $3E
                .byte $23, $27, $2B, $2F, $33, $37, $3B, $3F
                .byte $23, $27, $2B, $2F, $33, $37, $3B, $3F
                .byte $20, $24, $28, $2C, $30, $34, $38, $3C
                .byte $20, $24, $28, $2C, $30, $34, $38, $3C
                .byte $21, $25, $29, $2D, $31, $35, $39, $3D
                .byte $21, $25, $29, $2D, $31, $35, $39, $3D
                .byte $22, $26, $2A, $2E, $32, $36, $3A, $3E
                .byte $22, $26, $2A, $2E, $32, $36, $3A, $3E
                .byte $23, $27, $2B, $2F, $33, $37, $3B, $3F
                .byte $23, $27, $2B, $2F, $33, $37, $3B, $3F
;BEGIN ASP SPRITE-TABLE.
ASP_STAT:       .res ASP_PLANE
ASP_TX:         .res ASP_PLANE
ASP_TY:         .res ASP_PLANE
ASP_TWDTH:      .res ASP_PATTERN
ASP_THIGH:      .res ASP_PATTERN
ASP_TMAINH:     .res ASP_PATTERN
ASP_TMAINL:     .res ASP_PATTERN
ASP_TSUBH:      .res ASP_PATTERN
ASP_TSUBL:      .res ASP_PATTERN
ASP_BUF1:       .res ASP_BKBUF*4+1
ASP_BUF2:       .res ASP_BKBUF*4+1
ASP_END = *
;END ASP PROGRAM

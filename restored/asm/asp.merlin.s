* Apple Sprite Processor, Version 1.0
* By SF-SOFTWARE.
* Created: Mar.31,1986; Modified: Nov.01,1986
* Assembler: Merlin
* Restored from Micro Software, February 1987, pp.137-147.
* Original source lines 1-78 (printed p.137 / PDF page 6).
START   = $8700
PLANE   = 56          ;Max127
PATTERN = 35          ;Max255
BKBUF   = 37          ;Max63
PAR     = 900         ;($384)
GPAGE   = 230
BKPLANE = $D0         ;$D000
ROM     = $C081
RAM1    = $C083
RAM2    = $C08B
PAGE1   = $C054
PAGE2   = $C055
COMM    = $2FF-10
TMP     = $FF
ZERO    = 0
X1L     = 2
X1H     = 3
X2L     = 4
X2H     = 5
Y1L     = 6
Y1H     = 7
Y2L     = 8
Y2H     = 9
ILLERR  = $E199
COUT1   = $FDF0
DELAY   = $FCA8
        ORG START
        OBJ START
SYS     JMP MCNEW
        JMP PROCES
        JMP MCPUT
        JMP MCDEF
        JMP MCERASE
        JMP MCSET
        JMP MCGET
        JMP MCSWAP
        JMP MCCHANGE
        JMP MCIF
        JMP MCCMP
        JMP MCMOVE
        JMP MCCLEAR
        JMP MCDRAW
        JMP MCSHOW
        JMP MCMODE
        JMP MCHOME
        JMP MCCLIP
        JMP MCSOUND
        JMP MCINIT
* Original source lines 79-225 (p.138 / PDF page 7).
BGFUL1  DFB 0         ;Bflag1
BGFUL2  DFB 0         ;Bflag2
*START ASP Interpreter V1.1:
CHRGET  = $B1
CHRGOT  = $B7
TXT     = $B8
SYNERR  = $DEC9
GETBYT  = $E6F8
GETBTC  = $E74C
FRENUM  = $DD67
GETDBL  = $E752
CMDNUM  = $00
BEGIN   = *
        LDX #0
        STX CMDNUM
CMDLP0  LDY #0
        INC CMDNUM
        LDA ASPCMD,X
        BEQ NOTCMD
        PHA
        CMP (TXT),Y
        BEQ TOKEN
        PLA
        BPL NXTCMD
        INX
        JMP CMDLP0
NOTOKN  INY
        INX
CMDLP1  LDA ASPCMD,X
        AND #$7F
        BEQ NOTCMD
        CMP (TXT),Y
        BNE NXTCMD
        LDA ASPCMD,X
        BMI CMDOK
        INX
        INY
        BNE CMDLP1
CMDLP2  INX
NXTCMD  LDA ASPCMD,X
        BPL CMDLP2
        INX
        JMP CMDLP0
NOTCMD  RTS
TOKEN   PLA
        BPL NOTOKN
        JSR CHRGET
        JMP EXEC
CMDOK   TYA
        CLC
        ADC TXT
        STA TXT
        BCC *+4
        INC TXT+1
        JSR CHRGET
        JMP EXEC
ASPCMD  = *
C1      DCI 'PROCESS'
C2      DCI 'PUT#'
C3      DCI 'ERASE'
C4      DFB $AD       ;if
C5      DCI 'CMP('
C6      DCI 'MOVE'
C7      DFB $BD       ;clear
C8      DCI 'SWAP('
C9      DCI 'CLIP'
C10     DFB $94       ;draw
C11     DCI 'MODE'
C12     DFB $97       ;home
C13     DCI 'SHOW('
C14     DCI 'SPRITE$('
C15     DCI 'SET'
C16     DFB $BE       ;get
C17     DCI 'CHANGE('
C18     DCI 'PAGE'
C19     DCI 'SOUND'
CEND    DFB 0         ;EndFlag
EXEC    LDX CMDNUM
PROC    CPX #1
        BNE DEF
        JSR PROCES
        JMP CONTI
DEF     CPX #14
        BNE ERASE
        JSR GETBYT
        STX PAR       ;sn
        JSR TWOSKIP
        JSR GETBYT
        STX PAR+1     ;width
        JSR GETBTC
        STX PAR+2     ;high
        JSR GETNUM-3
        STY PAR+3     ;MainHi
        STX PAR+4     ;MainLo
        JSR CHRGOT
        LDY #$C0      ;flagSET
        CMP #','
        BNE *+5
        JSR GETNUM-3
        STY PAR+5     ;TsubHi
        STX PAR+6     ;TsubLo
        JSR MCDEF
        JMP CONTI
ERASE   CPX #3
        BNE IF
        LDY #0
        STY PAR
        CMP #'#'
        BNE ERAS1
        LDY #1
        JSR CHRGET
        STY PAR
        JSR GETBYT
        STX PAR+1
ERAS1   JSR MCERASE
        JMP CONTI
IF      CPX #4
        BNE PUT
        JSR SHPCHK-3
        JSR GETBYT
        STX PAR
        JSR SHPCHK-3
        JSR GETBYT
        STX PAR+1
        JSR MCIF
        JSR CHRGET
        LDX PAR
        STX $9D       ;ifflag
        JMP $D9CC     ;Then-
PUT     CPX #2
        BNE MOVE
* Original source lines 226-385 (p.139 / PDF page 8).
        JSR GETBYT
        STX PAR       ;sp
        JSR TWOSKIP
        JSR GETNUM    ;x
        STX PAR+1
        JSR GETNUM-3  ;y
        STX PAR+2
        JSR CHRGET
        LDX #0
        CMP #','
        BNE PUT0
        JSR GETBTC
PUT0    STX PAR+3     ;sn
        JSR MCPUT
        JMP CONTI
MOVE    CPX #6
        BNE CLIP
        JSR GETBYT
        STX PAR
        JSR CHRGET
        JSR GETBYT
        STX PAR+1
        JSR MCMOVE
        JMP CONTI
CLIP    CPX #9
        BNE HOME
        JSR GETBYT
        STX PAR
        JSR GETBTC
        STX PAR+1
        JSR GETBTC
        STX PAR+2
        JSR GETBTC
        STX PAR+3
        JSR MCCLIP
        JMP CONTI
HOME    CPX #12
        BNE SWAP
        JSR GETNUM
        STX PAR
        JSR GETNUM-3
        STX PAR+1
        JSR MCHOME
        JMP CONTI
SWAP    CPX #8
        BNE DRAW
        JSR GETBYT
        STX PAR
        JSR GETBTC
        STX PAR+1
        JSR CHRGET
        JSR MCSWAP
        JMP CONTI
DRAW    CPX #10
        BNE MODE
        JSR GETBYT
        STX PAR       ;sn
        JSR TWOSKIP
        JSR GETNUM
        STX PAR+1     ;x
        JSR GETNUM-3
        STX PAR+2     ;y
        JSR CHRGET
        LDX #0
        CMP #','
        BEQ DRAW1
        JMP DRAW1+3
DRAW1   JSR GETBTC
        STX PAR+3     ;page
        JSR MCDRAW
        JMP CONTI
MODE    CPX #11
        BNE CLEAR
        LDY #1
        STY PAR+1
        STY PAR+2
        JSR GETBYT
        STX PAR       ;screen
        JSR CHRGOT
        CMP #','
        BNE MODE1
        JSR GETBTC
        STX PAR+1     ;page1/2
        JSR CHRGOT
        CMP #','
        BNE MODE1
        JSR GETBTC
        STX PAR+2     ;ful/mix
MODE1   JSR MCMODE
        JMP CONTI
CLEAR   CPX #7
        BNE SHOW
        JSR GETBYT
        STX PAR
        JSR MCCLEAR
        JMP CONTI
SHOW    CPX #13
        BNE CMP
        JSR GETBYT
        STX PAR
        JSR CHRGOT
        CMP #')'
        BEQ SHOW1
        JSR GETBTC
        JMP SHOW1+2
SHOW1   LDX #77
        STX PAR+1
        JSR MCSHOW
        JSR CHRGET
        JMP CONTI
CMP     CPX #5
        BNE CHANGE
        JSR GETBYT
        STX PAR
        JSR GETBTC
        STX PAR+1
        JSR TWOSKIP
        JSR CHRGET
        JSR GETBYT
        STX PAR+2
        JSR CHRGET
        JSR MCCMP
        JMP CONTI
CHANGE  CPX #17
        BNE GET
        JSR GETBYT
        STX PAR
        JSR GETBTC
        STX PAR+1
        JSR CHRGET
        JSR MCCHANGE
        JMP CONTI
GET     CPX #16
        BNE SET
        JSR SHPCHK
        JSR GETBYT
        STX PAR
        JSR GETNUM-3
        STX PAR+1
        STY PAR+2
        JSR MCGET
        JMP CONTI
SET     CPX #15
        BNE PAGE
        JSR GETBYT
        STX PAR
        JSR SHPCHK-3
        JSR GETBYT
* Original source lines 386-540 (p.140 / PDF page 9).
        STX PAR+1
        JSR MCSET
        JMP CONTI
PAGE    CPX #18
        BNE SOUND
        JSR GETBYT
        DEX
        CPX #2
        BCC *+5
        JMP ILLERR
        CPX #0
        BNE BPAGE2
        LDA #$20
        BNE BPAGE2+2
BPAGE2  LDA #$40
        STA GPAGE
        JMP CONTI
SOUND   CPX #19
        BNE LINK
        JSR GETBYT
        STX PAR       ;reg-no.
        JSR GETBTC
        STX PAR+1     ;data
        LDX PSGND+1
        INX
        JSR CHRGOT
        CMP #','
        BNE *+5
        JSR GETBTC
        STX PAR+2     ;slot
        JSR MCSOUND
        JMP CONTI
LINK    RTS
        NOP
        NOP
        RTS
CONTI   JSR CHRGOT
        CMP #';'
        BNE CONTI-1
        JSR CHRGET
        JMP BEGIN
        JSR CHRGET
GETNUM  JSR FRENUM
        JSR GETDBL
        LDX $50       ;Low
        LDY $51       ;Hi
        RTS
TWOSKIP JSR CHRGET
        JMP CHRGET
        JSR CHRGET
SHPCHK  JSR CHRGOT
        CMP #'#'
        BEQ *+5
        JMP SYNERR
        JSR CHRGET
        RTS
*END ASP Interpreter
*BEGIN ASP MODULE
MCNEW   = *
        BIT RAM1
        BIT ROM
AMPSET  = *
        LDA #<BEGIN
        STA $3F6
        LDA #>BEGIN
        STA $3F7
HIMEM   = *
        LDA #<START
        STA $6F
        STA $73
        LDA #>START
        STA $70
        STA $74
        LDA #$20
        STA GPAGE
        LDY #0
MSGLP   LDA MSGTBL,Y
        BEQ MCINIT
        JSR COUT1
        INY
        BNE MSGLP
MSGTBL  = *
        HEX 8D8D
        ASC "/ Welcome "
        ASC "To Apple-Sprite"
        ASC "-Processor.."
        HEX 8D00
* 1.MODULE(INITIALIZE).
MCINIT  = *
        LDY #PLANE-1
INIT1   LDA #0
        STA STAT,Y
        DEY
        BPL INIT1
        STA BUF1
        STA BUF2
        LDA #$FF
INIT2   JSR INIT3
        LDA #$2C      ;Bit
        STA INIT2
        RTS
INIT3   LDY #PATTERN
        STA TWDTH,Y
        DEY
        BPL INIT3+2
        RTS
* 2.MODULE(SPRITE-PROCESS).
* (Sprite-Processor), (C) Mar.31,1986
X       = 6
Y       = 7
HIGH    = 8
WDTH    = 9
SCRN    = 0
SPRTPRCS = *
        BIT RAM1
        LDX #PLANE-1
SPLP    LDA STAT,X
        BEQ *+5
        JSR SPRTON
        DEX
        BPL SPLP
        BIT ROM
        RTS
SPRTON  = *
        TAY
        LDA TWDTH-1,Y
        BNE *+3
        RTS
        BMI *-1
        PHA
        STA YSKIP+3
* Original source lines 541-700 (p.141 / PDF page 10).
        LDA TX,X
        SEC
RELX    SBC #0
        STA X         ;setX
        PLA
        CLC
        ADC X
        STA WDTH      ;setWDTH
        LDA TY,X
        SEC
RELY    SBC #0
        STA Y         ;setY
        LDA THIGH-1,Y
        STA HIGH      ;setHIGH
        LDA TMAINL-1,Y
        STA MAINPTN+1 ;setMAIN
        LDA TMAINH-1,Y
        STA MAINPTN+2
        LDA TSUBL-1,Y
        STA SUBPTN+1  ;setSUB
        LDA TSUBH-1,Y
        STA SUBPTN+2
        BEQ PUTBLCK
        STX TMP
        LDX #0
        JSR PUTSPRT
        LDX TMP
        RTS
PUTBLCK = *
        LDA #$BD      ;LDR
        STA MAINPTN
        STX TMP
        LDX #0
        JSR PUTSPRT
        LDX TMP
        LDA #$1D      ;ORA
        STA MAINPTN
        RTS
*(Draw SPRITE on SPRITE-PLANE).
PUTSPRT = *
        LDY Y
CLIPSY1 CPY #0
        BCC YSKIP
CLIPSY2 CPY #192
        BCC GETHADR
YSKIP   TXA
        CLC
        ADC #0        ;skipWITH
        TAX
        BCC *+8
        INC MAINPTN+2
        INC SUBPTN+2
        JMP SNXT1
GETHADR LDA HADRH,Y
        CLC
ADP     ADC #$00
        STA SCRN+1
        LDA HADRL,Y
        STA SCRN
        LDY X
CLIPSX1 CPY #0
        BCC WSKIP
CLIPSX2 CPY #40
        BCS WSKIP
        LDA (SCRN),Y
SUBPTN  AND $BCAD,X
MAINPTN ORA $ACAD,X
        STA (SCRN),Y
WSKIP   INX
        BEQ INCADR
SNXT    INY           ;x=x+1
        CPY WDTH
        BNE CLIPSX1
SNXT1   INC Y         ;y=y+1
        DEC HIGH      ;h=h-1
        BNE PUTSPRT
        RTS
INCADR  INC MAINPTN+2
        INC SUBPTN+2
        JMP SNXT
* 3.MODULE(PROCESS).
PROCES  = *
        LDA GPAGE
        CMP #$20
        BNE SCREEN2
SCREEN1 LDA #0
        STA ADP+1
        STA BADP+1
        JSR BGP1
        JSR BGM1
        JSR SPRTPRCS
MCVSW1  LDA #$40
        STA GPAGE
        BIT PAGE1
        RTS
SCREEN2 LDA #$20
        STA ADP+1
        STA BADP+1
        JSR BGP2
        JSR BGM2
        JSR SPRTPRCS
MCVSW2  LDA #$20
        STA GPAGE
        BIT PAGE2
        RTS
* 4.MODULE(PATTERN-DEFINE).
MCDEF   LDX PAR
        BEQ *+6
        CPX #PATTERN+1
        BCC *+5
        JMP ILLERR
        LDA PAR+1
        STA TWDTH-1,X
        LDA PAR+2
        STA THIGH-1,X
        LDA PAR+3
        STA TMAINH-1,X
        LDA PAR+4
        STA TMAINL-1,X
        LDA PAR+5
        CMP #$C0
        BEQ CALCSUB
        STA TSUBH-1,X
        LDA PAR+6
        STA TSUBL-1,X
        RTS
CALCSUB LDY #0
        LDA PAR+3
        STA ZERO+1
        LDA PAR+4
        STA ZERO
MCDF2   LDA ZERO
        CLC
        ADC PAR+1
        STA ZERO
        BCC *+4
        INC ZERO+1
        INY
        CPY PAR+2
        BCC MCDF2
        LDA ZERO+1
        STA TSUBH-1,X
        LDA ZERO
* Original source lines 701-860 (p.142 / PDF page 11).
        STA TSUBL-1,X
        RTS
* 5.MODULE(ERASE-SPRITE).
MCERASE LDA PAR
        BNE MCERAS1
        TAY
MCERALP STA STAT,Y    ;Global
        INY
        CPY #PLANE
        BCC MCERALP
        RTS
MCERAS1 LDA #0        ;Local
        LDY PAR+1
        CPY #PLANE
        BCC *+5
        JMP ILLERR
        STA STAT,Y
        RTS
* 6.MODULE(IF).
MCIF    = *
        LDX PAR       ;sp1
        CPX #PLANE
        BCC *+5
XIFERR  JMP ILLERR
        LDY PAR+1     ;sp2
        CPY #PLANE
        BCS XIFERR
        LDA STAT,Y
        BEQ FALSE
        TAX
        LDA TX,Y
        STA X2L
        CLC
        ADC TWDTH-1,X
        STA X2H
        LDA TY,Y
        STA Y2L
        CLC
        ADC THIGH-1,X
        STA Y2H
        LDY PAR       ;sp1
        LDA STAT,Y
        BEQ FALSE
        TAX
        LDA TX,Y
        STA X1L
        CLC
        ADC TWDTH-1,X
        STA X1H
        LDA TY,Y
        STA Y1L
        CLC
        ADC THIGH-1,X
        STA Y1H
CHECK   = *
        LDA Y1L
        CMP Y2H
        BCS FALSE
        LDA Y1H
        CMP Y2L
        BCC FALSE
        BEQ FALSE
        LDA X1L
        CMP X2H
        BCS FALSE
        LDA X1H
        CMP X2L
        BCC FALSE
        BEQ FALSE
TRUE    LDA #1
        STA PAR
        RTS
FALSE   LDA #0
        STA PAR
        RTS
* 7.MODULE(PUT-SPRITE).
MCPUT   = *
        LDX PAR       ;sp
        CPX #PLANE
        BCS XPUTERR
        LDA PAR+1     ;x
        STA TX,X
        LDA PAR+2     ;y
        STA TY,X
        LDY PAR+3     ;sn
        BNE MCPUT1
        LDA STAT,X
        TAY
        BEQ XPUTERR-1 ;abort
MCPUT1  CPY #PATTERN+1
        BCS XPUTERR
        LDA TWDTH-1,Y
        BMI XPUTERR
        TYA
        STA STAT,X
        RTS
XPUTERR JMP ILLERR
* 8.MODULE(CMP).
MCCMP   = *
        LDA #0        ;Reset Flag
        STA ZERO
        LDA PAR+2     ;sn2
        STA CMPLP+1
        LDA PAR       ;sn0
        STA TMP
        LDA PAR+1     ;sn1
        CMP #PLANE
        BCC *+5
        JMP ILLERR
        STA CMPEND+1
CMPLP   = *
        LDA #0
        STA PAR
        LDX TMP
        CPX CMPLP+1
        BEQ CMPNXT
        STX PAR+1
        JSR MCIF
        LDX TMP
        LDA PAR
        BEQ CMPNXT
        LDA #1
        STA ZERO
        STX CMPNT+1
CMPNXT  = *
        INC TMP
CMPEND  CPX #PLANE
        BCC CMPLP
        LDA ZERO
        STA PAR       ;T/F
CMPNT   LDX #0
        STX PAR+1     ;sp
        LDA STAT,X
        STA PAR+2     ;sn
        RTS
* 9.MODULE(MOVE-SCREEN).
SCRN1   = 0           ;0/1
SCRN2   = 2           ;2/3
SCRN3   = 4           ;4/5
BX      = 6
BY      = 7
BH      = 8
BW      = 9
* Original source lines 861-1020 (p.143 / PDF page 12).
MCMOVE  = *
        LDA #<MVLP2+1
        STA MVADR+1
        LDA #>MVLP2+1
        STA MVADR+2
        LDY PAR
        JSR MVRTN
MVNXT   LDA #<MVPNT+1
        STA MVADR+1
        LDA #>MVPNT+1
        STA MVADR+2
        LDY PAR+1
        JSR MVRTN
        BIT RAM2
        JSR MVDRAW
        BIT ROM
        RTS
MVRTN   DEY
        CPY #3
        BCC *+5
        JMP ILLERR
        LDX #SCRN1
        CPY #2
        BNE *+4
        LDX #SCRN3
        CPY #1
        BNE *+4
        LDX #SCRN2
MVADR   STX $CDEF
        RTS
MVDRAW  = *
        LDA CLIPSX1+1
        STA BX        ;x
        LDA CLIPSY1+1
        STA BY        ;y
        TAX
        LDA CLIPSY2+1
        SEC
        SBC BY
        STA BH        ;high
        LDA CLIPSX2+1
        STA BW        ;width
MVLP1   = *
        LDA HADRH,X
        STA SCRN1+1
        CLC
        ADC #$20
        STA SCRN2+1
        ADC #BKPLANE-$40
        STA SCRN3+1
        LDA HADRL,X
        STA SCRN1
        STA SCRN3
        STA SCRN2
        LDY BX
MVLP2   = *
        LDA (SCRN1),Y
MVPNT   STA (SCRN3),Y
        INY
        CPY BW
        BCC MVLP2
        INX
        DEC BH
        BNE MVLP1
        RTS
* 10.MODULE(CLIP).
MCCLIP  = *
        LDA PAR       ;Xmin
        CMP PAR+1
        BCS CLIPERR
        CMP #40
        BCS CLIPERR
        STA CLIPSX1+1
        STA CLIPBX1+1
        LDX PAR+1     ;Xmax
        CPX #41
        BCS CLIPERR
        STX CLIPSX2+1
        STX CLIPBX2+1
        LDA PAR+2     ;Ymin
        CMP PAR+3
        BCS CLIPERR
        CMP #192
        BCS CLIPERR
        STA CLIPSY1+1
        STA CLIPBY1+1
        LDX PAR+3     ;Ymax
        CPX #193
        BCS CLIPERR
        STX CLIPSY2+1
        STX CLIPBY2+1
        RTS
CLIPERR JMP ILLERR
* 11.MODULE(HOME).
MCHOME  = *
        LDA PAR
        STA RELX+1
        STA RELX1+1
        LDA PAR+1
        STA RELY+1
        STA RELY1+1
        RTS
* 12.MODULE(SCREEN-MODE).
MCMODE  LDY PAR
        CPY #3
        BCC *+5
XMODERR JMP ILLERR
        LDX PAR+2
        CPX #2
        BCS XMODERR
        STA $C052,X   ;ful/mix
        CPY #0
        BNE GRAPH
TEXT    BIT $C051
        JMP BOTH
GRAPH   BIT $C050
        STA $C056-1,Y ;gr/hgr
BOTH    LDY PAR+1
        DEY
        CPY #2
        BCS XMODERR
        STA $C054,Y   ;page1/2
        RTS
* 13.MODULE(SHOW).
X1      = 6
X2      = 7
CNT     = 8
MCSHOW  DEC PAR
        LDY PAR
        CPY #3
        BCC *+5
        JMP ILLERR
        LDA #$60      ;rts
        STA MCVSW1
        STA MCVSW2
        LDX PAR+1     ;time
        STX WAIT+1
        LDX GPAGE
        CPX #$20
        BNE MCSHW1
        JSR SCREEN1
* Original source lines 1021-1180 (p.144 / PDF page 13).
        LDX #SCRN1
        LDY #SCRN2
        JSR MCSHW2
        JSR BGM2
        JMP MCSHW99
MCSHW1  JSR SCREEN2
        LDX #SCRN2
        LDY #SCRN1
        JSR MCSHW2
        JSR BGM1
MCSHW99 LDA #$A9      ;LDA#
        STA MCVSW1
        STA MCVSW2
        RTS
MCSHW2  STX GSW1+1
        STY GSW2+1
        LDA PAR       ;type?
        BNE MCSHOW2
* type1
        LDY #0        ;x=0
MCSHW11 LDX #0        ;y=0
        JSR GCALC
        JSR SHOWMV
        INX
        CPX #192
        BCC MCSHW11+2
        JSR WAIT
        INY
        CPY #40
        BCC MCSHW11
        RTS
MCSHOW2 CMP #1
        BNE MCSHOW3
* type2
        LDX #0        ;y=0
MCSHW21 JSR GCALC
        LDY #0        ;x=0
MCSHW2LP JSR SHOWMV
        INY
        CPY #40
        BCC MCSHW2LP
        JSR WAIT
        INX
        CPX #192
        BCC MCSHW21
        RTS
MCSHOW3 LDA #19       ;type3
        STA X1
        LDA #20
        STA X2
        STA CNT
MCSHW31 LDX #0        ;y=0
        JSR GCALC
        LDY X1
        JSR SHOWMV
        LDY X2
        JSR SHOWMV
        INX
        CPX #192
        BCC MCSHW31+2
        DEC X1
        INC X2
        JSR WAIT
        DEC CNT
        BNE MCSHW31
        RTS
SHOWMV  = *
GSW1    LDA (SCRN2),Y
GSW2    STA (SCRN1),Y
        RTS
GCALC   LDA HADRH,X
        STA SCRN1+1
        CLC
        ADC #$20
        STA SCRN2+1
        LDA HADRL,X
        STA SCRN1
        STA SCRN2
        RTS
WAIT    LDA #88
        JMP DELAY
* 14.MODULE(SET).
MCSET   LDY PAR
        BEQ XSETERR
        LDA TWDTH-1,Y
        CMP #$FF      ;NotDef?
        BNE *+5
XSETERR JMP ILLERR
        CPY #PATTERN+1
        BCS XSETERR
        TYA
        LDX PAR+1
        CPX #PLANE
        BCS XSETERR
        STA STAT,X
        RTS
* 15.MODULE(DRAW-PATTERN).
MCDRAW  LDA ADP+1
        STA COMM+2
        LDX PAR       ;sn
        BEQ XDRWERR
        CPX #PATTERN+1
        BCS XDRWERR
        LDA TWDTH-1,X
        CMP #$FF      ;NotDef?
        BEQ XDRWERR
        LDY PAR+3     ;page
        BEQ MCDRAW1
        CPY #3
        BCC *+5
XDRWERR JMP ILLERR
        LDA #0
        CPY #1
        BEQ MCDRAW01
        CLC
        ADC #$20
MCDRAW01 STA ADP+1
MCDRAW1 LDA TX
        STA COMM
        LDA TY
        STA COMM+1
        LDA PAR+1
        STA TX
        LDA PAR+2
        STA TY
        TXA
        LDX #0
        BIT RAM1
        JSR SPRTON
        BIT ROM
        LDA COMM
        STA TX
        LDA COMM+1
        STA TY
        LDA COMM+2
        STA ADP+1
        RTS
* 16.MODULE(CHANGE).
MCCHANGE = *
        LDX PAR
        BEQ XCHNERR
        CPX #PATTERN+1
        BCS XCHNERR
        STX ZERO
* Original source lines 1181-1340 (p.145 / PDF page 14).
        LDY PAR+1
        BEQ MCCHN0    ;erase
        CPY #PATTERN+1
        BCS XCHNERR
MCCHN0  = *
        LDX #PLANE-1
MCCHN1  LDA STAT,X
        CMP ZERO      ;sn1
        BNE MCCHN2
        TYA
        STA STAT,X
MCCHN2  DEX
        BPL MCCHN1
        RTS
XCHNERR JMP ILLERR
* 17.MODULE(SWAP).
MCSWAP  = *
        LDA PAR
        BEQ XSWPERR
        CMP #PATTERN+1
        BCC *+5
XSWPERR JMP ILLERR
        LDA PAR+1
        BEQ XSWPERR
        CMP #PATTERN+1
        BCS XSWPERR
        LDX #PLANE-1
MCSWP1  LDA STAT,X
        JSR MCSWPRTN
        STA STAT,X
        DEX
        BPL MCSWP1
        RTS
MCSWPRTN CMP PAR
        BNE *+6
        LDA PAR+1
        RTS
        CMP PAR+1
        BNE *-4
        LDA PAR
        RTS
* 18.MODULE(CLEAR).
MCCLEAR = *
        LDY PAR
        DEY
        CPY #3
        BCC *+5
        JMP ILLERR
        LDA #$A9      ;LDA#
        STA MVLP2
        LDA #0
        STA MVLP2+1
        LDA PAR
        STA PAR+1
        JSR MVNXT
        LDA #$B1      ;LD(z),Y
        STA MVLP2
        LDA #SCRN1
        STA MVLP2+1
        RTS
* 19.MODULE(GET).
MCGET   LDA PAR+1
        STA MCGT1+1
        LDA PAR+2
        STA MCGT1+2
        LDX PAR
        CPX #PLANE
        BCC *+5
        JMP ILLERR
        LDA STAT,X
MCGT1   STA $ACAD
        RTS
* 20.MODULE(SOUND).
* NEED Mocking-Board.
MCSOUND = *
        LDX PAR
        CPX #16
        BCS XPSGERR
        STX ZERO+2
        LDX PAR+2
        DEX
        CPX #2
        BCS XPSGERR
        STX PSGND+1
PSGINIT LDA #$FF
        STA $C403
        STA $C483
        LDA #7
        STA $C402
        STA $C482
        LDA #$C4
        STA ZERO+1
PSGND   LDA #0        ;PSG1/2
        BEQ MCPSG1
        CLC
        ADC #$7F
MCPSG1  STA ZERO
        LDX #7
        LDA ZERO+2    ;reg-no.
        JSR WRITE
        LDX #6
        LDA PAR+1     ;data
WRITE   LDY #1
        STA (ZERO),Y
        TXA
        DEY
        STA (ZERO),Y
        LDA #4
        STA (ZERO),Y
        RTS
XPSGERR JMP ILLERR
* 21.MODULE(BGM).
BUF     = 2
BGM1    JSR BUF1SET
        STY BGFUL1
        JSR BGM
        JSR BGMCHK
        STX BGFUL1
        RTS
BGM2    JSR BUF2SET
        STY BGFUL2
        JSR BGM
        JSR BGMCHK
        STX BGFUL2
        RTS
BGMCHK  LDX #0
        LDA CNT
        CMP #BKBUF+1
        BCC *+4
        LDX #$80
        RTS
BUF1SET LDA #<BUF1
        STA BUF
        LDA #>BUF1
        STA BUF+1
        LDY #0
        RTS
* Original source lines 1341-1486 (p.146 / PDF page 15).
BUF2SET LDA #<BUF2
        STA BUF
        LDA #>BUF2
        STA BUF+1
        LDY #0
        RTS
BGM     STY CNT       ;cnt=0
        LDX #PLANE-1
BGMLP1  LDA STAT,X
        BNE BGMON
        DEX
        BPL BGMLP1
        LDA #0
        STA (BUF),Y
        RTS
BGMON   STX TMP
        TAX
        LDA TWDTH-1,X
        BNE *+6
        TXA
        JMP BGMLP1+5
        STA (BUF),Y
        INY
        LDA THIGH-1,X
        STA (BUF),Y
        INY
        LDX TMP
        LDA TX,X
        SEC
RELX1   SBC #0
        STA (BUF),Y
        INY
        LDA TY,X
        SEC
RELY1   SBC #0
        STA (BUF),Y
        INY
        INC CNT
        JMP BGMLP1+5
* 22.MODULE(BGP).
BGP1    LDA BGFUL1
        BNE BGP11
        JSR BUF1SET
        JMP BGPWT
BGP11   LDY #1
        BNE BGPALL
BGP2    LDA BGFUL2
        BNE BGP21
        JSR BUF2SET
        JMP BGPWT
BGP21   LDY #2
BGPALL  LDA #3
        STA PAR
        STY PAR+1
        JMP MCMOVE
BGPWT   BIT RAM2
BGPWTL  LDA (BUF),Y   ;Wdth=0?
        BEQ BGPWT0    ;Yes=EOJ
        TAX
        INY
        LDA (BUF),Y
        STA HIGH
        INY
        LDA (BUF),Y
        STA X
        TXA
        CLC
        ADC X
        STA WDTH
        INY
        LDA (BUF),Y
        TAX
        STY TMP
        JSR BGPRTN
        LDY TMP
        INY
        BNE BGPWTL
BGPWT0  BIT ROM
        RTS
BGPRTN  = *
CLIPBY1 CPX #0
        BCC BSKIP
CLIPBY2 CPX #192
        BCC GETBADR
BSKIP   JMP BGP02
GETBADR LDA HADRH,X
        TAY
        CLC
BADP    ADC #0
        STA SCRN1+1
        TYA
        CLC
        ADC #BKPLANE-$20
        STA SCRN3+1
        LDA HADRL,X
        STA SCRN1
        STA SCRN3
        LDY X
CLIPBX1 CPY #0
        BCC BGP01
CLIPBX2 CPY #40
        BCS BGP01
        LDA (SCRN3),Y
        STA (SCRN1),Y
BGP01   INY
        CPY WDTH
        BNE CLIPBX1
BGP02   INX
        DEC HIGH
        BNE BGPRTN
        RTS
*END ASP MODULE
* 22.TABLE(Hires-Address).
HADRL   = *
        HEX 0000000000000000
        HEX 8080808080808080
        HEX 0000000000000000
        HEX 8080808080808080
        HEX 0000000000000000
        HEX 8080808080808080
        HEX 0000000000000000
        HEX 8080808080808080
        HEX 2828282828282828
        HEX A8A8A8A8A8A8A8A8
        HEX 2828282828282828
        HEX A8A8A8A8A8A8A8A8
        HEX 2828282828282828
        HEX A8A8A8A8A8A8A8A8
        HEX 2828282828282828
* Original source lines 1487-1541 (p.147 / PDF page 16).
        HEX A8A8A8A8A8A8A8A8
        HEX 5050505050505050
        HEX D0D0D0D0D0D0D0D0
        HEX 5050505050505050
        HEX D0D0D0D0D0D0D0D0
        HEX 5050505050505050
        HEX D0D0D0D0D0D0D0D0
        HEX 5050505050505050
        HEX D0D0D0D0D0D0D0D0
HADRH   = *
        HEX 2024282C3034383C
        HEX 2024282C3034383C
        HEX 2125292D3135393D
        HEX 2125292D3135393D
        HEX 22262A2E32363A3E
        HEX 22262A2E32363A3E
        HEX 23272B2F33373B3F
        HEX 23272B2F33373B3F
        HEX 2024282C3034383C
        HEX 2024282C3034383C
        HEX 2125292D3135393D
        HEX 2125292D3135393D
        HEX 22262A2E32363A3E
        HEX 22262A2E32363A3E
        HEX 23272B2F33373B3F
        HEX 23272B2F33373B3F
        HEX 2024282C3034383C
        HEX 2024282C3034383C
        HEX 2125292D3135393D
        HEX 2125292D3135393D
        HEX 22262A2E32363A3E
        HEX 22262A2E32363A3E
        HEX 23272B2F33373B3F
        HEX 23272B2F33373B3F
*BEGIN ASP SPRITE-TABLE.
STAT    DS PLANE
TX      DS PLANE
TY      DS PLANE
TWDTH   DS PATTERN
THIGH   DS PATTERN
TMAINH  DS PATTERN
TMAINL  DS PATTERN
TSUBH   DS PATTERN
TSUBL   DS PATTERN
BUF1    DS BKBUF*4+1
BUF2    DS BKBUF*4+1
END     = *
*END ASP PROGRAM

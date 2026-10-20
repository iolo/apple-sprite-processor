* Micro Software, January 1987, p.154, list 2.
* Reset-vector patch; install with CALL 912 ($0390).
        ORG $390
        OBJ $390
RAM     BIT $C083
        BIT $C083
        LDA #<HERE
        STA $FFFC
        LDA #>HERE
        STA $FFFD
ROM     BIT $C081
        BIT $C081
        RTS
HERE    = *
        JSR ROM
        JMP $FA62

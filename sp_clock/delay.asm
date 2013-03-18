; задержка 10мс
Delay10ms:
        ldi temp, 0x43
D10MS0: ldi tmpL, 0xC6
D10MS1: dec tmpL
        brne D10MS1
        dec tmpH
        brne D10MS0
        nop
        ret
; задержка 100мс
Delay100ms:
        ldi  temp, 0x61
D100MS0:ldi  tmpH, 0x06
D100MS1:ldi  tmpL, 0x5c
D100MS2:dec  tmpL
        brne D100MS2
        dec  tmpH
        brne D100MS1
        dec  temp
        brne D100MS0
        nop
        ret
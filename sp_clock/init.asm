; настройка стека        
        ldi temp, HIGH(RAMEND)
        out SPH, temp
        ldi temp, LOW(RAMEND)
        out SPL, temp

; настройка портов в/в
        ldi temp, 0xff
        out DIGITS_DDR, temp
        out STROBE_DDR, temp
        ldi temp, 0x00
        out DIGITS_PORT, temp
        out STROBE_PORT, temp
        ldi temp, 0xf0
        out DDRD, temp
        ldi temp, 0x00
        out PORTD, temp
        
        ldi temp, 0x03
        out DDRC, temp
        
; асинхронный режим
        ldi temp, (1<<AS2)
        out ASSR, temp
; предделитель на 128, переполнение за 1 сек
        ldi temp, (1<<CS22)|(1<<CS20)
        out TCCR2, temp        
; жду пока обновиться TCN
WaitForTCNUpdate:
        SKBC ASSR, TCN2UB, temp
        rjmp WaitForTCNUpdate

; таймер для будильника
        clr temp
        out TCCR1A, temp
;        ldi temp, (4<<CS10)
;        out TCCR1B, temp
        ldi temp, (1<<TOIE2)|(1<<OCIE1A)|(1<<OCIE1B)
        out TIMSK, temp

        clr temp
        clr tmpL
        clr tmpH
        clr temp_add
        ldi current_set, 0xff
        ldi interface_time, 0x55
        ldi interface_date, 0x15
        clr interface_set
        ldi temp, 0
        sts MODES, temp
        sts SHOW_DATE_CYCLE, temp

; загрузка рингтона в ОЗУ
        ldi ZH, high(2*Ringtone_ch2)
        ldi ZL, low(2*Ringtone_ch2)
        ldi XH, high(RINGTONE_1)
        ldi XL, low(RINGTONE_1)
LoadCh1:
        lpm
        mov tmpH, r0
        adiw ZL,1 
        lpm
        mov tmpL, r0
        adiw ZL,1 
        st X+, tmpH
        st X+, tmpL
        cpi tmpL, 0
	ldi temp, 0
	cpc tmpH, temp
        breq InitCh2
        rjmp LoadCh1
InitCh2:
        ldi ZH, high(2*Ringtone_ch1)
        ldi ZL, low(2*Ringtone_ch1)
        ldi XH, high(RINGTONE_2)
        ldi XL, low(RINGTONE_2)
LoadCh2:
        lpm
        mov tmpH, r0
        adiw ZL,1 
        lpm
        mov tmpL, r0
        adiw ZL,1 
        st X+, tmpH
        st X+, tmpL
        cpi tmpL, 0
	ldi temp, 0
	cpc tmpH, temp
        breq InitStartTime
        rjmp LoadCh2

InitStartTime:
; загрузка данных о времени
        ldi temp, 0
        sts ALARM, temp
        sts ALARM+1, temp
        ldi temp, 0
        sts SECOND, temp
        ldi temp, 0
        sts MINUTE, temp
        ldi temp, 0
        sts HOUR, temp
        ldi temp, 6
        sts DAY_OF_WEEK, temp
        ldi temp, 1
        sts DAY, temp
        ldi temp, 1
        sts MONTH, temp
        ldi temp, high(2000)
        sts YEAR, temp
        ldi temp, low(2000)
        sts YEAR+1, temp
        sei
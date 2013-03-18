ShowMainSettings:
        lds temp, CUR
        cpi temp, 1
        breq ShowMainTime
        cpi temp, 2
        breq ShowMainDate
        rjmp UpdateNow

ShowMainTime:
        ldi interface_time, (1<<shSecond)|(1<<shMinute)|(1<<shHour)|(1<<shTime)
        clr interface_date
        rjmp UpdateNow

ShowMainDate:
        ldi interface_date, (1<<shDay)|(1<<shMonth)|(1<<shYear)|(1<<shDate)
        clr interface_time
        rjmp UpdateNow

UpdateInterfaceSettings:
        cpi current_set, 0
        breq ShowMainSettings
UpdateNow:
        sbrc interface_time, shTime
        rjmp UpdateInterfaceTime
        sbrc interface_date, shDate
        rjmp UpdateInterfaceDate
; обновление информации о времени
UpdateInterfaceTime:
        clr temp
        sbrs interface_time, shSecond
        rjmp ClearSeconds
; преобразование секунд к упакованному BCD числу
        lds temp, SECOND
        sbrc interface_time, shSecondZero
        clr temp
        rcall bin2bcd8
ShowSecondZero: 
; вывод на индикатор секунд
        cbi STROBE_PORT, SECOND_OE
        sbi STROBE_PORT, SECOND_PE
        out DIGITS_PORT, temp
        cbi STROBE_PORT, SECOND_PE
        rjmp ShowMinute
ClearSeconds:
        sbi STROBE_PORT, SECOND_OE
ShowMinute:
        sbrs interface_time, shMinute
        rjmp ClearMinute
; преобразование минут к упакованному BCD числу
        lds temp, MINUTE
        sbrc interface_set, stMinute
        lds temp, TEMP_MINUTE
        sbrc interface_time, shCurMinute
        lds temp, CUR
        rcall bin2bcd8
; вывод на индикатор минут
        cbi STROBE_PORT, MINUTE_OE
        sbi STROBE_PORT, MINUTE_PE
        out DIGITS_PORT, temp
        cbi STROBE_PORT, MINUTE_PE
        rjmp ShowHour
ClearMinute:
        sbi STROBE_PORT, MINUTE_OE

ShowHour:
        sbrs interface_time, shHour
        rjmp ClearHour
; преобразование часов к упакованному BCD числу
        lds temp, HOUR
        sbrc interface_set, stMinute
        lds temp, TEMP_HOUR
        sbrc interface_time, shCurHour
        lds temp, CUR
        rcall bin2bcd8
; вывод на индикатор часов
        cbi STROBE_PORT, HOUR_OE
        sbi STROBE_PORT, HOUR_PE
        out DIGITS_PORT, temp
        cbi STROBE_PORT, HOUR_PE
        rjmp ShowDOW
ClearHour:
        sbi STROBE_PORT, HOUR_OE

ShowDOW:
        lds temp, DAY_OF_WEEK
        sbrs interface_time, shDOW
        clr temp
; вывод дней на индикатор
        in tmpL, PORTD
        andi tmpL, 0xf0
        swap temp
        adc tmpL, temp
        out PORTD, temp
        ret

; обновление информации о дате
UpdateInterfaceDate:
        sbrs interface_date, shDay
        rjmp ClearDay
; преобразование секунд к упакованному BCD числу
        lds temp, DAY
        sbrc interface_date, shCurDay
        lds temp, CUR
        rcall bin2bcd8
; вывод на индикатор секунд
        cbi STROBE_PORT, DAY_OE
        sbi STROBE_PORT, DAY_PE
        out DIGITS_PORT, temp
        cbi STROBE_PORT, DAY_PE
        rjmp ShowMonth
ClearDay:
        sbi STROBE_PORT, DAY_OE

ShowMonth:
        sbrs interface_date, shMonth
        rjmp ClearMonth
; преобразование минут к упакованному BCD числу
        lds temp, MONTH
        sbrc interface_date, shCurMonth
        lds temp, CUR
        rcall bin2bcd8
; вывод на индикатор минут
        cbi STROBE_PORT, MONTH_OE
        sbi STROBE_PORT, MONTH_PE
        out DIGITS_PORT, temp
        cbi STROBE_PORT, MONTH_PE
        rjmp ShowYear
ClearMonth:
        sbi STROBE_PORT, MONTH_OE

ShowYear:
        sbrs interface_date, shYear
        rjmp ClearYear
; преобразование лет к упакованному BCD числу
        lds dd16uH, YEAR
        lds dd16uL, YEAR+1
        ldi dv16uH, high(100)
        ldi dv16uL, low(100)
        rcall div16u
        mov temp, drem16uL
        sbrc interface_date, shCurYear
        lds temp, CUR
        rcall bin2bcd8
; вывод на индикатор последней части года
        cbi STROBE_PORT, YEAR_OE
        sbi STROBE_PORT, YEAR_PE
        out DIGITS_PORT, temp
        cbi STROBE_PORT, YEAR_PE
        rjmp ShowDateDOW
ClearYear:
        sbi STROBE_PORT, YEAR_OE

ShowDateDOW:
        lds temp, DAY_OF_WEEK
        sbrs interface_date, shDOW
        clr temp
; вывод дней на индикатор
        in tmpL, PORTD
        andi tmpL, 0xf0
        swap temp
        adc tmpL, temp 
        out PORTD, temp
        ret        
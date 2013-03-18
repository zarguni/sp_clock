CheckTimeToAlarm:
        lds temp, MINUTE
        lds tmpL, HOUR

        inc temp
        cpi temp, 60
        breq CheckTimeToAlarm_CorrectMinutes

CheckTimeToAlarm_Compare:
        lds temp_add, ALARM+1
        cp temp, temp_add
        brne NotThisTime

        lds temp_add, ALARM
        cp tmpL, temp_add
        brne NotThisTime

        ldi temp, (1<<inAlarm)|(1<<inInitAlarm)
        sts MODES, temp
NotThisTime:
        ret
CheckTimeToAlarm_CorrectMinutes:
        clr temp
        inc tmpL
        cpi tmpL, 24
        breq CheckTimeToAlarm_CorrectHours
        rjmp CheckTimeToAlarm_Compare

CheckTimeToAlarm_CorrectHours:
        clr tmpL
        rjmp CheckTimeToAlarm_Compare

UpdateDateTime:
; проверка секунд        
        lds temp, SECOND
        inc temp
        sts SECOND, temp
        cpi temp, 60
        brne Return
        sbis INDICATOR_PORT, INDICATOR_1
        rjmp ClearMinuteNow
        rcall CheckTimeToAlarm
ClearMinuteNow:        
        clr temp
        sts SECOND, temp
; проверка минут        
        lds temp, MINUTE
        inc temp
        sts MINUTE, temp
        cpi temp, 60
        brne Return
        clr temp
        sts MINUTE, temp
; проверка часов
        lds temp, HOUR
        inc temp
        sts HOUR, temp
        cpi temp, 24
        brne Return
        clr temp
        sts HOUR, temp
; проверка дн€ недели
        lds temp, DAY_OF_WEEK
        inc temp
        sts DAY_OF_WEEK, temp
        cpi temp, 8
        brne Check31Day
        ldi temp, 1
        sts DAY_OF_WEEK, temp
; проверка даты - 31 число
Check31Day:
        lds temp, DAY
        inc temp
        sts DAY, temp
        cpi temp, 32
        breq NextMonth
; проверка даты - 30 число
        cpi temp, 31
        breq CheckMonth
; проверка даты - 29 число
Check30Day:
        cpi temp, 30
        breq CheckFebruary
; проверка даты - 28 число
Check29Day:
        cpi temp, 29
        brne Return
; проверка ‘еврал€ в Ќ≈ висококсный год
        lds temp, MONTH
        cpi temp, 2
        breq CheckNotLeapYear
; выход
Return:
        ret
; следующий мес€ц пришел
NextMonth:
        ldi temp, 1
        sts DAY, temp
        lds temp, MONTH
        inc temp
        sts MONTH, temp
        cpi temp, 13
        breq NextYear
        rjmp Return

; проверка мес€ца на ‘евраль
CheckFebruary: 
        lds temp, MONTH
        cpi temp, 2
        breq NextMonth
        rjmp Check29Day

; проверка мес€ца 4, 6, 9, 11
CheckMonth:
        lds temp, MONTH
        cpi temp, 4
        breq Return
        cpi temp, 6
        breq Return
        cpi temp, 9
        breq Return
        cpi temp, 11
        breq Return
        rjmp Check30Day

; следующий год настал
NextYear: 
        ldi temp, 1
        sts MONTH, temp
        lds tmpH, YEAR
        lds tmpL, YEAR+1
        subi tmpL, low(-1)
	sbci tmpH, high(-1)
        sts YEAR, tmpH
        sts YEAR+1, tmpL
        
; проверка на високосный год
CheckNotLeapYear:
; год високосный, если он кратен 4, 
; но при этом не кратен 100, 
; либо кратен 400
;
; деление на 100
        lds dd16uH, YEAR
        lds dd16uL, YEAR+1
        ldi dv16uH, high(100)
        ldi dv16uL, low(100)
        rcall div16u
        mov tmpH, drem16uH
        mov tmpL, drem16uL
        cpi tmpL, low(0)	
	ldi temp, high(0)	
	cpc tmpH, temp	
        breq Div400             ; переход, если делитс€ на 100
; деление на 4
        lds temp, YEAR+1
        andi temp, 0xfc
        breq CheckMonth         ; год високосный
        rjmp Return             ; год не високосный
; деление на 400        
Div400:
        lds dd16uH, YEAR
        lds dd16uL, YEAR+1
        ldi dv16uH, high(400)
        ldi dv16uL, low(400)
        rcall div16u
        mov tmpH, drem16uH
        mov tmpL, drem16uL
        cpi tmpL, low(0)	
	ldi temp, high(0)	
	cpc tmpH, temp	
        brne CheckMonth         ; переход, если делитс€ на 400, год високосный
        rjmp Return             ; год не високосный

; вычисление дн€ недели
GetDOW:
        ldi temp, 14            ; 1. 14 - MONTH
        lds tmpL, MONTH
        sub temp, tmpL

        ldi dv8u, 12            ; 2. a = (1)/12
        rcall div8u             ; результат в dres8u - r16
        
        clr temp_add            ; 3. y = YAER - a
        lds tmpH, YEAR          
        lds tmpL, YEAR+1
        sub tmpL, temp
	sbc tmpH, temp_add
        sts USER_VARS, tmpH
        sts USER_VARS+1, tmpL   ; результат записал в USER_VARS:USER_VARS+1 - y
        	
        ldi temp_add, 12        ; 4. 12*a
        mul temp, temp_add      ; результат умножени€ в r0
        
        lds temp, MONTH         ; 5. MONTH + (4)
        add temp, r0

        subi temp, 2            ; 6. (5) - 2 - m

        ldi mp8u, 31            ; 7. 31*m
        rcall mpy8u             ; результат в m8uH:m8uL - r18:r18

        mov dd16uL, m8uL        ; 8. (7)/12 - var1
        mov dd16uH, m8uH
        ldi dv16uL, low(12)
        ldi dv16uH, high(12)    
        rcall div16u            ; результат в dres16uH:dres16uL
        sts USER_VARS+2, dres16uH
        sts USER_VARS+3, dres16uL ; результат записал в USER_VARS+2:USER_VARS+3 - var1

        lds dd16uH, USER_VARS   ; 9. y/400 - var2
        lds dd16uL, USER_VARS+1
        ldi dv16uL, low(400)
        ldi dv16uH, high(400)
        rcall div16u            ; результат в dres16uH:dres16uL
        sts USER_VARS+4, dres16uH
        sts USER_VARS+5, dres16uL ; результат записал в USER_VARS+4:USER_VARS+5 - var2

        lds dd16uH, USER_VARS   ; 10. y/100 - var3
        lds dd16uL, USER_VARS+1
        ldi dv16uL, low(100)
        ldi dv16uH, high(100)
        rcall div16u            ; результат в dres16uH:dres16uL
        sts USER_VARS+6, dres16uH
        sts USER_VARS+7, dres16uL ; результат записал в USER_VARS+6:USER_VARS+7 - var3

        lds dd16uH, USER_VARS   ; 11. y/4 - var4
        lds dd16uL, USER_VARS+1
        ldi dv16uL, low(4)
        ldi dv16uH, high(4)
        rcall div16u            ; результат в dres16uH:dres16uL
        sts USER_VARS+8, dres16uH
        sts USER_VARS+9, dres16uL ; результат записал в USER_VARS+6:USER_VARS+7 - var4

        lds temp, DAY           ; 12. DAY + y
        clr temp_add
        lds tmpH, USER_VARS
        lds tmpL, USER_VARS+1
        add temp, tmpL
	adc temp_add, tmpH

        lds tmpH, USER_VARS+8   ; 13. (12) + var4
        lds tmpL, USER_VARS+9
        add temp, tmpL
	adc temp_add, tmpH

        lds tmpH, USER_VARS+6   ; 14. (13) - var3
        lds tmpL, USER_VARS+7
        sub temp, tmpL
	sbc temp_add, tmpH

        lds tmpH, USER_VARS+4   ; 15. (14) + var2
        lds tmpL, USER_VARS+5
        add temp, tmpL
	adc temp_add, tmpH

        lds tmpH, USER_VARS+2   ; 16. (15) + var1
        lds tmpL, USER_VARS+3
        add temp, tmpL
	adc temp_add, tmpH

        subi temp, low(-7000)	; 17. (16) +7000
	sbci temp_add, high(-7000)

        mov dd16uH, temp_add    ; 18. (17) / 7 остаток от делени€
        mov dd16uL, temp
        ldi dv16uL, low(7)
        ldi dv16uH, high(7)
        rcall div16u
        mov temp, drem16uL
        ret
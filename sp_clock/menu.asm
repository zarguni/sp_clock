;********************************************************************************************
;                            ¬џ«ќ¬ »« ќ—Ќќ¬Ќќ… ѕ–ќ√–јћћџ
;********************************************************************************************     
        cpi current_set, 255
        breq SetDefaultLimit
MenuRoutine:  
        in temp, KEY_PORT               ; состо€ние порта в temp
        sbrs temp, KEY_PLUS             ; пропуск, если кнопка Plus не нажата
        rjmp NextMode                   ; иначе, переход на NextMode
        sbrs temp, KEY_MINUS            ; пропуск, если кнопка Minus не нажата
        rjmp PrevMode                   ; иначе, переход на PrevMode
        sbrs temp, KEY_MODE             ; пропуск, если кнопка Mode не нажата
        rjmp EnterMode                  ; иначе, переход на EnterMode
        sbrs temp, KEY_ALARM            ; пропуск, если кнопка Alarm не нажата
        rjmp SetAlarm                   ; иначе, переход на SetAlarm
        rjmp Start                      ; никака€ кнопка не нажета, переход в начало

SetDefaultLimit:
        ldi temp, 1
        sts MIN, temp
        sts CUR, temp
        ldi temp, 2
        sts MAX, temp
        rjmp MenuRoutine 

SetShowDate:
        ldi temp, 1<<inShowDate
        sts MODES, temp
        rjmp Start
;********************************************************************************************
;                                Ќќѕ ј NEXT Ќј∆ј“ј
;********************************************************************************************
NextMode:
        cpi current_set, 255
        breq SetShowDate
        rcall Delay100ms
        rcall Delay100ms
        rcall Delay100ms
        rcall Delay100ms
        rcall Delay100ms
        rcall Delay100ms
        lds temp, CUR                   ; загружаю текущее значение параметра CUR
        lds tmpL, MAX                   ; загружаю максимальное значение параметра MAX
        inc temp                        ; увеличиваю значание CUR на 1      
        cp tmpL, temp                   ; сравниваю MAX и CUR
        brlo OverMode                   ; переход. если MAX < CUR
        sts CUR, temp                   ; иначе, записываю текущее значени CUR
        rcall UpdateInterfaceSettings   ; обовл€ю интерфейс
        rjmp MenuRoutine                ; возврат

OverMode:
        lds temp, MIN
        sts CUR, temp
        rcall UpdateInterfaceSettings
        rjmp MenuRoutine
;********************************************************************************************
;                                Ќќѕ ј MINUS Ќј∆ј“ј
;********************************************************************************************
PrevMode:
        cpi current_set, 255
        breq SetShowDate
        rcall Delay100ms
        rcall Delay100ms
        rcall Delay100ms
        rcall Delay100ms
        rcall Delay100ms
        rcall Delay100ms
        lds temp, CUR                   ; загружаю текущее значение параметра CUR
        lds tmpL, MIN                   ; загружаю максимальное значение параметра MIN
        dec temp                        ; уменьшаю значание CUR на 1 
        cp temp, tmpL                   ; сравниваю MIN и CUR
        brlo LessMode                   ; переход. если CUR < MIN
        brmi LessMode
        sts CUR, temp                   ; иначе, записываю текущее значени CUR
        rcall UpdateInterfaceSettings   ; обовл€ю интерфейс
        rjmp MenuRoutine                ; возврат

LessMode:
        lds temp, MAX
        sts CUR, temp
        rcall UpdateInterfaceSettings
        rjmp Start
;********************************************************************************************
;                                Ќќѕ ј MODE Ќј∆ј“ј
;********************************************************************************************
EnterMode:
        rcall Delay100ms
WaitForReleaseMode:  
        sbis KEY_PORT, KEY_MODE
        rjmp WaitForReleaseMode
        sbi INDICATOR_PORT, INDICATOR_2
        cpi current_set, 255                    ; первый раз нажали на Mode
        breq SetMainMenu
        cpi current_set, 0                      ; нажали, после того, как выбрали что будем подводить
        breq SetSetting
; натсройка времени
        cpi current_set, 10                     ; нажали после того как подвели часы
        breq SetTimeHour
        cpi current_set, 11                     ; нажали после того как подвели минуты
        breq SetTimeMinute                      
        cpi current_set, 12                     ; нажали после того как определили врем€ запуска часов.
        breq SetTimeZeroStart                   
; настройка даты
        rjmp CheckDate

SetMainMenu:
        ldi current_set, 0                      
        ldi temp, 1<<inSettings                 ; останавливаю счет часов
        sts MODES, temp
WaitForReleaseMode1:  
        sbis KEY_PORT, KEY_MODE
        rjmp WaitForReleaseMode1
        rcall Delay100ms
        rjmp Start 
;********************************************************************************************                                    
SetSetting:                                     ; выбрали режим и нажали на mode
        lds temp, CUR                           
        cpi temp, 1
        breq SetTime                            ; если выбрали подвод часов, то переход на SetTime
        rjmp SetSettingDate

;********************************************************************************************        
;                       Ќј—“–ќ… ј ¬–≈ћ≈Ќ»
;***********************************************************************************************************
SetTime:
        ldi current_set, 10
        ldi interface_time, (1<<shHour)|(1<<shCurHour)|(1<<shTime)         ; отображать часы на индикаторах
        lds temp, HOUR
        sts CUR, temp
        ldi temp, 23
        sts MAX, temp
        ldi temp, 0
        sts MIN, temp
WaitForReleaseMode2: 
        sbis KEY_PORT, KEY_MODE
        rjmp WaitForReleaseMode2
        rcall Delay100ms
        rjmp Start        
SetTimeHour:
        ldi current_set, 11
        lds temp, CUR
        sts TEMP_HOUR, temp
        lds temp, MINUTE
        sts CUR, temp
        ldi temp, 59
        sts MAX, temp
        ldi temp, 0
        sts MIN, temp
        ldi interface_time, (1<<shMinute)|(1<<shCurMinute)|(1<<shTime)
        ldi interface_set, (1<<stHour)
WaitForReleaseMode3:  
        sbis KEY_PORT, KEY_MODE
        rjmp WaitForReleaseMode3
        rcall Delay100ms
        rjmp Start
SetTimeMinute:
        ldi current_set, 12
        ldi interface_time, (1<<shHour)|(1<<shMinute)|(1<<shSecond)|(1<<shSecondZero)|(1<<shTime)
        ldi interface_set, (1<<stHour)|(1<<stMinute)
        lds temp, CUR
        sts TEMP_MINUTE, temp
WaitForReleaseMode4:  
        sbis KEY_PORT, KEY_MODE
        rjmp WaitForReleaseMode4
        rcall Delay100ms
        rjmp Start
SetTimeZeroStart:
        lds temp, TEMP_HOUR
        sts HOUR, temp
        lds temp, TEMP_MINUTE
        sts MINUTE, temp
        clr temp
        sts SECOND, temp
        ldi current_set, 255
        ldi interface_time, 0x55
        ldi interface_date, 0x15
        ldi interface_set, 0
        clr temp
        sts MODES, temp
        cbi INDICATOR_PORT, INDICATOR_2
WaitForReleaseMode5:  
        sbis KEY_PORT, KEY_MODE
        rjmp WaitForReleaseMode5
        rcall Delay100ms
        rjmp Start
;********************************************************************************************
SetSettingDate:
        cpi temp, 2
        breq SetDate
        rjmp Start
;********************************************************************************************
; 
SetDateYear:
        ldi current_set, 21
        ldi interface_date, (1<<shMonth)|(1<<shCurMonth)|(1<<shDate)            ; отобразить мес€ц на индикаторах
        lds temp, CUR
        clr temp_add
        subi temp, low(-2000)
	sbci temp_add, high(-2000)
        sts YEAR, temp_add
        sts YEAR+1, temp
        lds temp, MONTH
        sts CUR, temp
        ldi temp, 1
        sts MIN, temp
        ldi temp, 12
        sts MAX, temp
WaitForReleaseMode8:  
        sbis KEY_PORT, KEY_MODE
        rjmp WaitForReleaseMode8
        rcall Delay100ms
        rjmp Start
;********************************************************************************************
CheckDate:        
        cpi current_set, 20                     ; нажали после того как подвели год
        breq SetDateYear
        cpi current_set, 21                     ; нажали после того как подвели мес€ц
        breq SetDateMonth                      
        cpi current_set, 22                     ; нажали после того как подвели день
        breq SetDateDay                   
        rjmp CheckAlarm

;********************************************************************************************
;                       Ќј—“–ќ… ј ƒј“џ
;***********************************************************************************************************
SetDate:
        ldi current_set, 20 
        ldi interface_date, (1<<shYear)|(1<<shCurYear)|(1<<shDate)              ; отобразить год на индикаторах
        lds dd16uH, YEAR                                                        
        lds dd16uL, YEAR+1
        ldi dv16uH, high(100)
        ldi dv16uL, low(100)
        rcall div16u                                                            ; YEAR / 100
        sts CUR, drem16uL                                                       ; остаток от делени€ в CUR
        ldi temp, 0
        sts MIN, temp
        ldi temp, 99
        sts MAX, temp
WaitForReleaseMode6:  
        sbis KEY_PORT, KEY_MODE
        rjmp WaitForReleaseMode6
        rcall Delay100ms
        rjmp Start
;
SetDateMonth:
        ldi current_set, 22
        ldi interface_date, (1<<shDay)|(1<<shCurDay)|(1<<shDate)                ; отобразить день на индикаторах
        lds temp, CUR
        sts MONTH, temp
        cpi temp, 4
        breq SetMaxDay_30
        cpi temp, 6
        breq SetMaxDay_30
        cpi temp, 9
        breq SetMaxDay_30
        cpi temp, 11
        breq SetMaxDay_30
        cpi temp, 2
        breq CheckLeapYear
        ldi temp, 31
SaveMaxDay:                
        sts MAX, temp
        lds temp_add, DAY
        cp temp, temp_add               ; сравниваю MAX и DAY
        brlo SetCurMIN                  ; переход. если MAX < DAY
        sts CUR, temp_add
SetMinDay:
        ldi temp, 1
        sts MIN, temp
WaitForReleaseMode9:  
        sbis KEY_PORT, KEY_MODE
        rjmp WaitForReleaseMode9
        rcall Delay100ms
        rjmp Start

SetCurMIN:
        ldi temp, 1
        sts CUR, temp
        rjmp SetMinDay
SetMaxDay_30:
        ldi temp, 30
        rjmp SaveMaxDay
CheckLeapYear:
        rcall CalcMaxFebDay
        rjmp SaveMaxDay

; 
SetDateDay:  
        ldi current_set, 255
        ldi interface_date, 0x15
        ldi interface_time, 0x55
        lds temp, CUR
        sts DAY, temp
        rcall GetDOW
        tst temp
        breq SetSunday
SetDOW:
        sts DAY_OF_WEEK, temp
        clr temp
        sts MODES, temp
        cbi INDICATOR_PORT, INDICATOR_2
WaitForReleaseMode7:  
        sbis KEY_PORT, KEY_MODE
        rjmp WaitForReleaseMode7
        rcall Delay100ms
        rjmp Start

SetSunday:
        ldi temp, 7
        rjmp SetDOW

; считаю сколько дней в феврале
CalcMaxFebDay:
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
        breq SDM_Div400         ; переход, если делитс€ на 100
; деление на 4
        lds temp, YEAR+1
        andi temp, ~0xfc
        breq SetMaxDay_29       ; год високосный
        rjmp SetMaxDay_28       ; год не високосный
; деление на 400        
SDM_Div400:
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
        brne SetMaxDay_29       ; переход, если делитс€ на 400, год високосный
        rjmp SetMaxDay_28       ; год не високосный
SetMaxDay_29:
        ldi temp, 29
        ret
SetMaxDay_28:
        ldi temp, 28
        ret

;***********************************************************************************************************
;                       ќ“ћ≈Ќ»“№ Ѕ”ƒ»Ћ№Ќ» 
;***********************************************************************************************************
SetStopAlarm:
        cbi INDICATOR_PORT, INDICATOR_1
        cbi INDICATOR_PORT, INDICATOR_2
        ldi current_set, 255
        ldi interface_time, 0x55
        ldi interface_date, 0x15
        clr temp
        sts MODES, temp
WaitForReleaseAlarm2:        
        sbis KEY_PORT, KEY_ALARM
        rjmp WaitForReleaseAlarm2
        rcall Delay100ms
        rjmp Start
; роутер дл€ будильника
CheckAlarm:        
        cpi current_set, 31                     ; нажали после того как подвели час
        breq SetAlarmHour
        cpi current_set, 32                     ; нажали после того как подвели минуты
        breq SetAlarmMinute                      
        rjmp Start

;***********************************************************************************************************
;                       Ќј—“–ќ… ј Ѕ”ƒ»Ћ№Ќ» ј
;***********************************************************************************************************
SetAlarm:
        rcall Delay100ms
WaitForReleaseAlarm:        
        sbis KEY_PORT, KEY_ALARM
        rjmp WaitForReleaseAlarm
        cpi current_set, 31
        breq SetStopAlarm
        cpi current_set, 32
        breq SetStopAlarm
        lds temp, MODES
        sbrc temp, inAlarm
        rjmp StopAlarm
        sbi INDICATOR_PORT, INDICATOR_2
        ldi temp, 1<<inSettings                 
        sts MODES, temp
        ldi current_set, 31
        ldi interface_time, (1<<shHour)|(1<<shCurHour)|(1<<shTime)
        lds temp, ALARM
        sts CUR, temp
        ldi temp, 23
        sts MAX, temp
        ldi temp, 0
        sts MIN, temp
WaitForReleaseAlarm1:        
        sbis KEY_PORT, KEY_ALARM
        rjmp WaitForReleaseAlarm1
        rcall Delay100ms
        rjmp Start        

SetAlarmHour:
        ldi current_set, 32
        ldi interface_time, (1<<shMinute)|(1<<shCurMinute)|(1<<shTime)
        lds temp, CUR
        sts ALARM, temp
        lds temp, ALARM+1
        sts CUR, temp
        ldi temp, 59
        sts MAX, temp
        ldi temp, 0
        sts MIN, temp
WaitForReleaseMode10:  
        sbis KEY_PORT, KEY_MODE
        rjmp WaitForReleaseMode10
        rcall Delay100ms
        rjmp Start
SetAlarmMinute:
        sbi INDICATOR_PORT, INDICATOR_1
        lds temp, CUR
        sts ALARM+1, temp
        ldi current_set, 255
        ldi interface_time, 0x55
        ldi interface_date, 0x15
        clr temp
        sts MODES, temp
        cbi INDICATOR_PORT, INDICATOR_2
WaitForReleaseMode11:  
        sbis KEY_PORT, KEY_MODE
        rjmp WaitForReleaseMode11
        rcall Delay100ms
        rjmp Start

StopAlarm:
        clr temp
        out TCCR1A, temp
        out TCCR1B, temp
        out TCNT1H, temp
        out TCNT1L, temp
        sts MODES, temp
        ldi YH, high(Ringtone_1 * 2)
        ldi YL, low(Ringtone_1 * 2)
        ldi ZH, high(Ringtone_2 * 2)
        ldi ZL, low(Ringtone_2 * 2)
WaitForReleaseAlarm5:        
        sbis KEY_PORT, KEY_ALARM
        rjmp WaitForReleaseAlarm5
        rcall Delay100ms
        rjmp Start
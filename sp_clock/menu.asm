;********************************************************************************************
;                            ����� �� �������� ���������
;********************************************************************************************     
        cpi current_set, 255
        breq SetDefaultLimit
MenuRoutine:  
        in temp, KEY_PORT               ; ��������� ����� � temp
        sbrs temp, KEY_PLUS             ; �������, ���� ������ Plus �� ������
        rjmp NextMode                   ; �����, ������� �� NextMode
        sbrs temp, KEY_MINUS            ; �������, ���� ������ Minus �� ������
        rjmp PrevMode                   ; �����, ������� �� PrevMode
        sbrs temp, KEY_MODE             ; �������, ���� ������ Mode �� ������
        rjmp EnterMode                  ; �����, ������� �� EnterMode
        sbrs temp, KEY_ALARM            ; �������, ���� ������ Alarm �� ������
        rjmp SetAlarm                   ; �����, ������� �� SetAlarm
        rjmp Start                      ; ������� ������ �� ������, ������� � ������

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
;                               ������ NEXT ������
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
        lds temp, CUR                   ; �������� ������� �������� ��������� CUR
        lds tmpL, MAX                   ; �������� ������������ �������� ��������� MAX
        inc temp                        ; ���������� �������� CUR �� 1      
        cp tmpL, temp                   ; ��������� MAX � CUR
        brlo OverMode                   ; �������. ���� MAX < CUR
        sts CUR, temp                   ; �����, ��������� ������� ������� CUR
        rcall UpdateInterfaceSettings   ; ������� ���������
        rjmp MenuRoutine                ; �������

OverMode:
        lds temp, MIN
        sts CUR, temp
        rcall UpdateInterfaceSettings
        rjmp MenuRoutine
;********************************************************************************************
;                               ������ MINUS ������
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
        lds temp, CUR                   ; �������� ������� �������� ��������� CUR
        lds tmpL, MIN                   ; �������� ������������ �������� ��������� MIN
        dec temp                        ; �������� �������� CUR �� 1 
        cp temp, tmpL                   ; ��������� MIN � CUR
        brlo LessMode                   ; �������. ���� CUR < MIN
        brmi LessMode
        sts CUR, temp                   ; �����, ��������� ������� ������� CUR
        rcall UpdateInterfaceSettings   ; ������� ���������
        rjmp MenuRoutine                ; �������

LessMode:
        lds temp, MAX
        sts CUR, temp
        rcall UpdateInterfaceSettings
        rjmp Start
;********************************************************************************************
;                               ������ MODE ������
;********************************************************************************************
EnterMode:
        rcall Delay100ms
WaitForReleaseMode:  
        sbis KEY_PORT, KEY_MODE
        rjmp WaitForReleaseMode
        sbi INDICATOR_PORT, INDICATOR_2
        cpi current_set, 255                    ; ������ ��� ������ �� Mode
        breq SetMainMenu
        cpi current_set, 0                      ; ������, ����� ����, ��� ������� ��� ����� ���������
        breq SetSetting
; ��������� �������
        cpi current_set, 10                     ; ������ ����� ���� ��� ������� ����
        breq SetTimeHour
        cpi current_set, 11                     ; ������ ����� ���� ��� ������� ������
        breq SetTimeMinute                      
        cpi current_set, 12                     ; ������ ����� ���� ��� ���������� ����� ������� �����.
        breq SetTimeZeroStart                   
; ��������� ����
        rjmp CheckDate

SetMainMenu:
        ldi current_set, 0                      
        ldi temp, 1<<inSettings                 ; ������������ ���� �����
        sts MODES, temp
WaitForReleaseMode1:  
        sbis KEY_PORT, KEY_MODE
        rjmp WaitForReleaseMode1
        rcall Delay100ms
        rjmp Start 
;********************************************************************************************                                    
SetSetting:                                     ; ������� ����� � ������ �� mode
        lds temp, CUR                           
        cpi temp, 1
        breq SetTime                            ; ���� ������� ������ �����, �� ������� �� SetTime
        rjmp SetSettingDate

;********************************************************************************************        
;                       ��������� �������
;***********************************************************************************************************
SetTime:
        ldi current_set, 10
        ldi interface_time, (1<<shHour)|(1<<shCurHour)|(1<<shTime)         ; ���������� ���� �� �����������
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
        ldi interface_date, (1<<shMonth)|(1<<shCurMonth)|(1<<shDate)            ; ���������� ����� �� �����������
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
        cpi current_set, 20                     ; ������ ����� ���� ��� ������� ���
        breq SetDateYear
        cpi current_set, 21                     ; ������ ����� ���� ��� ������� �����
        breq SetDateMonth                      
        cpi current_set, 22                     ; ������ ����� ���� ��� ������� ����
        breq SetDateDay                   
        rjmp CheckAlarm

;********************************************************************************************
;                       ��������� ����
;***********************************************************************************************************
SetDate:
        ldi current_set, 20 
        ldi interface_date, (1<<shYear)|(1<<shCurYear)|(1<<shDate)              ; ���������� ��� �� �����������
        lds dd16uH, YEAR                                                        
        lds dd16uL, YEAR+1
        ldi dv16uH, high(100)
        ldi dv16uL, low(100)
        rcall div16u                                                            ; YEAR / 100
        sts CUR, drem16uL                                                       ; ������� �� ������� � CUR
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
        ldi interface_date, (1<<shDay)|(1<<shCurDay)|(1<<shDate)                ; ���������� ���� �� �����������
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
        cp temp, temp_add               ; ��������� MAX � DAY
        brlo SetCurMIN                  ; �������. ���� MAX < DAY
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

; ������ ������� ���� � �������
CalcMaxFebDay:
; ��� ����������, ���� �� ������ 4, 
; �� ��� ���� �� ������ 100, 
; ���� ������ 400
;
; ������� �� 100
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
        breq SDM_Div400         ; �������, ���� ������� �� 100
; ������� �� 4
        lds temp, YEAR+1
        andi temp, ~0xfc
        breq SetMaxDay_29       ; ��� ����������
        rjmp SetMaxDay_28       ; ��� �� ����������
; ������� �� 400        
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
        brne SetMaxDay_29       ; �������, ���� ������� �� 400, ��� ����������
        rjmp SetMaxDay_28       ; ��� �� ����������
SetMaxDay_29:
        ldi temp, 29
        ret
SetMaxDay_28:
        ldi temp, 28
        ret

;***********************************************************************************************************
;                       �������� ���������
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
; ������ ��� ����������
CheckAlarm:        
        cpi current_set, 31                     ; ������ ����� ���� ��� ������� ���
        breq SetAlarmHour
        cpi current_set, 32                     ; ������ ����� ���� ��� ������� ������
        breq SetAlarmMinute                      
        rjmp Start

;***********************************************************************************************************
;                       ��������� ����������
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
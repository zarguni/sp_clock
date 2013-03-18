; определ€ю регистры
.def temp = r16
.def tmpL = r17
.def tmpH = r18
.def temp_add = r19
.def current_set = r21
.def interface_time = r22
        .equ shSecond = 0
        .equ shSecondZero = 1
        .equ shMinute = 2
        .equ shCurMinute = 3
        .equ shHour = 4
        .equ shCurHour = 5
        .equ shDOW = 6
        .equ shTime = 7
.def interface_date = r23
        .equ shDay = 0
        .equ shCurDay = 1
        .equ shMonth = 2
        .equ shCurMonth = 3
        .equ shYear = 4
        .equ shCurYear = 5
        .equ shDate = 7
.def interface_set = r24
        .equ stMinute = 0
        .equ stHour = 1
        .equ stYear = 2
        .equ stMonth = 3
        .equ stDay = 4

; определ€ю константы
.equ KEY_PORT = PIND
.equ KEY_MODE = PD1
.equ KEY_PLUS = PD2
.equ KEY_MINUS = PD3
.equ KEY_ALARM = PD0
.equ DIGITS_PORT = PORTA
.equ DIGITS_DDR = DDRA
.equ STROBE_PORT = PORTB
.equ STROBE_DDR = DDRB
.equ INDICATOR_PORT = PORTC
.equ SECOND_PE = PB0
.equ SECOND_OE = PB1
.equ YEAR_PE = PB0
.equ YEAR_OE = PB1
.equ MINUTE_PE = PB2
.equ MINUTE_OE = PB3
.equ MONTH_PE = PB2
.equ MONTH_OE = PB3
.equ HOUR_PE = PB4
.equ HOUR_OE = PB5
.equ DAY_PE = PB4
.equ DAY_OE = PB5
.equ RINGER_1 = PB6     
.equ RINGER_2 = PB7
.equ INDICATOR_1 = PC0  ; будильник
.equ INDICATOR_2 = PC1  ; настройка

; здесь храню информацию о времени, настройках и состоинии часов
.equ SSTART = SRAM_START
.equ SECOND = SSTART
.equ MINUTE = SSTART+1
.equ HOUR = SSTART+2
.equ DAY = SSTART+3
.equ DAY_OF_WEEK = SSTART+4
.equ MONTH = SSTART+5
.equ YEAR = SSTART+6
.equ ALARM = SSTART+8
.equ MODES = SSTART+10
.equ inShowDate = 0 
.equ inSettings = 1
.equ inAlarm = 2
.equ inInitAlarm =3

.equ SHOW_DATE_CYCLE = SSTART+11
.equ USER_VARS = SSTART+12
.equ CUR = SSTART+22
.equ MAX = SSTART+23
.equ MIN = SSTART+24
.equ RINGTONE_1 = SSTART+50
.equ RINGTONE_2 = SSTART+70

.equ TEMP_SECOND = SSTART+90
.equ TEMP_MINUTE = SSTART+91
.equ TEMP_HOUR = SSTART+92
.equ TEMP_DAY = SSTART+93
.equ TEMP_DAY_OF_WEEK = SSTART+94
.equ TEMP_MONTH = SSTART+95
.equ TEMP_YEAR = SSTART+96

; смотри AVR001
.MACRO SKBC  		
	.if @1>7
		.message "Only values 0-7 allowed for Bit parameter"
	.endif
	.if @0>0x3F
		lds	 @2, @0
		sbrc @2, @1
	.elif @0>0x1F
		in	 @2, @0
		sbrc @2, @1
	.else
		sbic @0, @1
	.endif
.ENDMACRO

; сохран€ю регистры в стеке
.MACRO SaveRegisters
        push r16
        push r17
        push r18
        push r19
        push r20
        push r21
        push r22
        push r23
        push r24
        in temp, SREG
        push temp
.ENDMACRO

; загружаю регистры из стеке
.MACRO LoadRegisters
        pop temp
        out SREG, temp
        pop r24
        pop r23
        pop r22
        pop r21
        pop r20
        pop r19
        pop r18
        pop r17
        pop r16
.ENDMACRO
/*
 * sp_clock.asm
 *
 *  Created: 26.06.2012 22:51:43
 *   Author: zarguni
 */ 
 
 .include "m32def.inc"
 .include "userdef.asm"
 
; вектра прерываний
.org 0
        rjmp Initialization
.org OVF2addr
        rjmp ClockTick
.org OC1Aaddr
        rjmp DinDon1
.org OC1Baddr
        rjmp DinDon2

;************************************************
Initialization:
.include "init.asm"
; основная программа
Start:  
; опрос кнопок, реализация меню
.include "menu.asm"        
        rjmp Start
; временные задержки
.include "delay.asm"
; математические преобразования
.include "math.asm"
;***************************************************************************************
;*      ПОДПРОГРАММА ПРЕРЫВНИИЯ ПО ПЕРЕПОЛНЕНИЮ ТАЙМЕРА (КАЖДУЮ СЕКУНДУ)
;***************************************************************************************
ClockTick:
        SaveRegisters
; обновляю счетчики часов
        rcall UpdateDateTime
; проверяю режимы даты, настройки или будильника
        lds temp, MODES
        sbrc temp, inSettings
        rjmp ShowTime
        sbrc temp, inInitAlarm
        rjmp AlarmAction
        sbrc temp, inShowDate
        rjmp ShowDate
        rcall UpdateInterfaceTime
        rjmp Exit
ShowTime:
        rcall UpdateInterfaceSettings
        rjmp Exit
; показываю дату
ShowDate:
        lds temp, SHOW_DATE_CYCLE
        inc temp
        sts SHOW_DATE_CYCLE, temp
        cpi temp, 4
        breq StopShowDate
        ldi interface_date, (1<<shDay)|(1<<shMonth)|(1<<shYear)|(1<<shDOW)
        rcall UpdateInterfaceDate
        rjmp Exit
; больше не показываю дату
StopShowDate:
        clr temp
        sts SHOW_DATE_CYCLE, temp
        sts MODES, temp
; выход
Exit:
        LoadRegisters
        reti
; сейчас начну звонить в колокола
AlarmAction:
        lds temp, MODES
        andi temp, ~(1<<inInitAlarm)
        sts MODES, temp
        ldi temp, (4<<CS10)
        out TCCR1B, temp
        ldi XH, high(RINGTONE_1)
        ldi XL, low(RINGTONE_1)
        ld tmpH, X+
        ld tmpL, X+
        out OCR1AH, tmpH
        out OCR1AL, tmpL
        ldi YH, high(RINGTONE_2)
        ldi YL, low(RINGTONE_2)
        ld tmpH, Y+
        ld tmpL, Y+
        out OCR1BH, tmpH
        out OCR1BL, tmpL
        rjmp ShowTime

; логика часов
.include "clock_logic.asm"

; работа с интерфейсом
.include "interface.asm"
;***************************************************************************************
;*                                 ЛЕВЫЙ КОЛОКОЛ
;***************************************************************************************
DinDon1:
        push temp
        push current_set
        in temp, SREG
        push temp
        sbic STROBE_PORT, RINGER_1
        rjmp OffRinger1
OnRinger1:
        sbi STROBE_PORT, RINGER_1
        rjmp LoadNextSequence1
OffRinger1:        
        cbi STROBE_PORT, RINGER_1
LoadNextSequence1:
        ld tmpH, X+
        ld tmpL, X+
        cpi tmpL, 0
        ldi temp, 0
	cpc tmpH, temp
        breq ReloadAlarm1
LoadAlarm1:
        out OCR1AH, tmpH
        out OCR1AL, tmpL
        pop temp
        out SREG, temp
        pop current_set
        pop temp
        reti
ReloadAlarm1:
        ldi XH, high(RINGTONE_1)
        ldi XL, low(RINGTONE_1)
        ld tmpH, X+
        ld tmpL, X+
        rjmp LoadAlarm1

;***************************************************************************************
;*                                 ПРАВЫЙ КОЛОКОЛ
;***************************************************************************************
DinDon2:
        push temp
        push current_set
        in temp, SREG
        push temp
        sbic STROBE_PORT, RINGER_2
        rjmp OffRinger2
OnRinger2:
        sbi STROBE_PORT, RINGER_2
        rjmp LoadNextSequence2
OffRinger2:        
        cbi STROBE_PORT, RINGER_2
LoadNextSequence2:
        ld tmpH, Y+
        ld tmpL, Y+
        cpi tmpL, 0
        ldi temp, 0
	cpc tmpH, temp
        breq ReloadAlarm2
LoadAlarm2:
        out OCR1BH, tmpH
        out OCR1BL, tmpL
        pop temp
        out SREG, temp
        pop current_set
        pop temp
        reti
ReloadAlarm2:
        ldi YH, high(RINGTONE_2)
        ldi YL, low(RINGTONE_2)
        ld tmpH, Y+
        ld tmpL, Y+
        rjmp LoadAlarm2

;***************************************************************************************
;*                                МЕЛОДИЯ
;***************************************************************************************
Ringtone_ch1:
        .db 0x20, 0x08, 0x29, 0xa4, 0x00, 0x00
Ringtone_ch2:
        .db 0x33, 0x40, 0x40, 0x10, 0x00, 0x00
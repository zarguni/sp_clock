; Подпрограмма деления 16/16 без знака
.def	drem16uL = r14                  ; остаток от деления
.def	drem16uH = r15
.def	dres16uL = r16                  ; результат
.def	dres16uH = r17
.def	dd16uL	 = r16                  ; делимое
.def	dd16uH	 = r17
.def	dv16uL	 = r18                  ; делитель
.def	dv16uH	 = r19
.def	dcnt16u	 = r20
div16u:
        clr	drem16uL	        ;clear remainder Low byte
	sub	drem16uH, drem16uH      ;clear remainder High byte and carry
	ldi	dcnt16u, 17	        ;init loop counter
d16u_1:	rol	dd16uL		        ;shift left dividend
	rol	dd16uH
	dec	dcnt16u		        ;decrement counter
	brne	d16u_2		        ;if done
	ret			        ;return
d16u_2:	rol	drem16uL	        ;shift dividend into remainder
	rol	drem16uH
	sub	drem16uL, dv16uL	;remainder = remainder - divisor
	sbc	drem16uH, dv16uH	;
	brcc	d16u_3		        ;if result negative
	add	drem16uL, dv16uL	;restore remainder
	adc	drem16uH, dv16uH
	clc			        ;clear carry to be shifted into result
	rjmp	d16u_1		        ;else
d16u_3:	sec			        ;set carry to be shifted into result
	rjmp	d16u_1

; попрограмма деления 8/8 без знака
.def	drem8u	=r15		;remainder
.def	dres8u	=r16		;result
.def	dd8u	=r16		;dividend
.def	dv8u	=r17		;divisor
.def	dcnt8u	=r18		;loop counter

div8u:	sub drem8u,drem8u	;clear remainder and carry
	ldi dcnt8u,9	        ;init loop counter
d8u_1:	rol dd8u		;shift left dividend
	dec dcnt8u		;decrement counter
	brne d8u_2		;if done
	ret			;    return
d8u_2:	rol drem8u		;shift dividend into remainder
	sub drem8u,dv8u	        ;remainder = remainder - divisor
	brcc d8u_3		;if result negative
	add drem8u,dv8u	        ;    restore remainder
	clc 		        ;    clear carry to be shifted into result
	rjmp d8u_1		;else
d8u_3:	sec 			;    set carry to be shifted into result
	rjmp d8u_1

; подпрограмма умножения 8*8 = 16 без знака
.def	mc8u	=r16		;multiplicand
.def	mp8u	=r17		;multiplier
.def	m8uL	=r17		;result Low byte
.def	m8uH	=r18		;result High byte
.def	mcnt8u	=r19		;loop counter

mpy8u:	clr m8uH		;clear result High byte
	ldi mcnt8u, 8	        ;init loop counter
	lsr mp8u		;rotate multiplier
	
m8u_1:	brcc m8u_2		;carry set 
	add m8uH, mc8u	        ;   add multiplicand to result High byte
m8u_2:	ror m8uH		;rotate right result High byte
	ror m8uL		;rotate right result L byte and multiplier
	dec mcnt8u		;decrement loop counter
	brne m8u_1		;if not done, loop more
	ret

; подпрограмма конвертации бинарного числа с BCD формат
.def	fbin	=r16		;8-bit binary value
.def	tBCDL	=r16		;BCD result MSD
.def	tBCDH	=r17		;BCD result LSD
bin2bcd8:
	clr	tBCDH		;clear result MSD
bBCD8_1:subi	fbin, 10	;input = input - 10
	brcs	bBCD8_2		;abort if carry set
;	inc	tBCDH		;inc MSD
;---------------------------------------------------------------------------
;				;Replace the above line with this one
;				;for packed BCD output				
	subi	tBCDH, -$10 	;tBCDH = tBCDH + 10
;---------------------------------------------------------------------------
	rjmp	bBCD8_1		;loop again
bBCD8_2:subi	fbin, -10	;compensate extra subtraction
;---------------------------------------------------------------------------
;				;Add this line for packed BCD output
	add	fbin,tBCDH	
;---------------------------------------------------------------------------	
        nop
	ret
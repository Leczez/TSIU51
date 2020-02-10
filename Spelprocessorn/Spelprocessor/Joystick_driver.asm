



.equ Channel_P1_X = $00
.equ Channel_P1_Y = $01
.equ Channel_P2_X = $02
.equ Channel_P2_Y = $03


.equ Forward = 3
.equ Backward = 1
.equ Neutral = 0

	.macro INCSRAM	; inc byte in SRAM
		lds	r16,@0
		inc	r16
		sts	@0,r16
	.endmacro

	.macro DECSRAM	; dec byte in SRAM
		lds	r16,@0
		dec	r16
		sts	@0,r16
	.endmacro


.org $60

Joystick_Init:
	ldi r16,(1<<ADEN)
	out ADCSRA,r16

	ldi r16,$00
	out DDRA,r16
	
	ret



Input:

	out ADMUX,r16

	ldi r16,(1<<ADSC)
	out ADCSRA,r16

Wait:
	sbic ADCSRA,ADSC
	rjmp Wait

	in r16, ADCH

	ret

Input_P1:
	push r16

	ldi r16,(0<<REFS1)|(0<<REFS0)|(0<<ADLAR)|(Channel_P1_X)
	rcall Input
	rcall Check_X1

	ldi r16,(0<<REFS1)|(0<<REFS0)|(0<<ADLAR)|(Channel_P1_Y)
	rcall Input
	rcall Check_Y1

	pop r16

	ret

Input_P2:
	push r16

	ldi r16,(0<<REFS1)|(0<<REFS0)|(0<<ADLAR)|(Channel_P2_X)
	rcall Input
	rcall Check_X2

	ldi r16,(0<<REFS1)|(0<<REFS0)|(0<<ADLAR)|(Channel_P2_Y)
	rcall Input
	rcall Check_Y2
	
	pop r16

	ret

Check_X1:
	
	//Forward X
	cpi r16,Forward
	breq X1_INC
	cpi r16,Backward
	breq X1_DEC

	rjmp X1_DONE

X1_INC:	
	INCSRAM P1X
	// se till att X är mindre än 8 här
	cpi r16,8
	breq X1_DEC//minska P1X

	rjmp X1_DONE

X1_DEC:
	DECSRAM P1X
	// se till att X är större än -1 här
	cpi r16, 255
	breq X1_INC//öka P1X


	rjmp X1_DONE

X1_DONE:	

	ret

Check_X2:
	
	//Forward X
	cpi r16,Forward
	breq X2_INC
	cpi r16,Backward
	breq X2_DEC

	rjmp X2_DONE

X2_INC:	
	INCSRAM P2X
	// se till att X är mindre än 8 här
	cpi r16,8
	breq X2_DEC//minska P1X

	rjmp X2_DONE

X2_DEC:
	DECSRAM P2X
	// se till att X är större än -1 här
	cpi r16, 255
	breq X2_INC//öka P1X


	rjmp X2_DONE

X2_DONE:	

	ret






Check_Y1:

	cpi r16,Forward
	breq Y1_INC
	cpi r16,Backward
	breq Y1_DEC

	rjmp Y1_DONE

Y1_INC:	
	INCSRAM P1Y
	// se till att X är mindre än 8 här
	cpi r16,8
	breq Y1_DEC//minska P1X

	rjmp Y1_DONE

Y1_DEC:
	DECSRAM P1Y
	// se till att X är större än -1 här
	cpi r16, 255
	breq Y1_INC//öka P1X


	rjmp Y1_DONE

Y1_DONE:	

	ret


Check_Y2:

	cpi r16,Forward
	breq Y2_INC
	cpi r16,Backward
	breq Y2_DEC

	rjmp Y2_DONE

Y2_INC:	
	INCSRAM P2Y
	// se till att X är mindre än 8 här
	cpi r16,8
	breq Y2_DEC//minska P1X

	rjmp Y2_DONE

Y2_DEC:
	DECSRAM P2Y
	// se till att X är större än -1 här
	cpi r16, 255
	breq Y2_INC//öka P1X


	rjmp Y2_DONE

Y2_DONE:	
	

	ret
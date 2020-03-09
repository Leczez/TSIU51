
.org 0x500

UART_INIT:
	ldi r17, 0x00
	ldi r16, 0x0c



;Set baud rate
	out UBRRH, r17
	out UBRRL, r16

;Reciever and reciver-interrupt enable
	ldi r16, (1<<RXEN | 1<<RXCIE)
	out UCSRB, r16

; Set frame format: 8data, 1stop bit
	ldi r16, (1<<URSEL | 3<<UCSZ0)
	out UCSRC, r16

;Double asynchronous speed
	ldi r16, (1<<U2X)
	out UCSRA, r16


	clr r16
	sts CURR_INS_BYTE,r16

	sei
	ret


RECEIVE:
	push ZH
	push ZL
	push r19
	push r18
	push r17
	push r16
	in r16, SREG
	push r16





READ:
;READ UART BUFFERS
	in r16, UCSRA
	in r17, UCSRB
	in r18, UDR

;ERROR CHECK
	andi r16,(1<<FE | 1<<DOR | 1<<PE)
	breq NO_ERROR
	rjmp DATA_RECEIVED

	NO_ERROR:
	;FILTER STOP-BIT
		lsr r17
		andi r17, 0x01

STORE:
;CHECK START BYTE AND STORE

	lds r19,CURR_INS_BYTE
	cpi r19,0x03
	brne NO_RESET
	clr r19
	sts CURR_INS_BYTE,r19


	NO_RESET:
	cpi r18, 0xff
	breq DATA_RECEIVED
	;hacking noises
	STORE_INSTRUCT:
		ldi ZH, high(NEXT_INSTRUCTION)
		ldi ZL, low(NEXT_INSTRUCTION)
		lds r19, CURR_INS_BYTE
		add ZL, r19
		st Z, r18
		inc r19
		sts CURR_INS_BYTE, r19


DATA_RECEIVED:


;ALL BYTES READ, EXIT
	pop r16
	out SREG, r16
	pop r16
	pop r17
	pop r18
	pop r19
	pop ZL
	pop ZH
	reti


	/*
 * Display.asm
 *
 *  Created: 2020-02-21 09:47:27
 *   Author: linny471
 */ 


.org 0x00
	jmp START
/*
.org 0x014
	jmp LOAD_DATA 
*/
.dseg
	.org 0x300
	SEND_BYTE: .byte 4
	SEND_BUFF: .byte 1
	LOOP: .byte 1

	ROWS: .byte 24 ;rgb,rgb,rgb...
	INDEX: .byte 1 ;register with shifting 0
	ROW_POS: .byte 1 ;ROW_POS*3 = next row of rgb

.cseg
START:
	ldi r16,high(RAMEND)
	out SPH,r16

	ldi r16,low(RAMEND)
	out SPL,r16	

	ldi r16,$FF
	out DDRA,r16

	call INIT

MEMORY_INIT:
	ldi r16, 0b11111110
	sts INDEX, r16
		
	CLEAR_MEM:
		clr r16
		clr r17
		ldi ZH,high(ROWS)
		ldi ZL,low(ROWS)
		CLR_LOOP:
			inc r17
			st Z+,r16
			cpi r17, 24
			brne CLR_LOOP
		


RESET_PTR:
	rcall PULL_LATCH
	rcall MEMORY_READ
	ldi ZH, high(SEND_BYTE)
	ldi ZL, low(SEND_BYTE)
	clr r16
	sts LOOP, r16

MAIN:
	lds r16, LOOP
	cpi r16, 0x04
	breq RESET_PTR
	rcall LOAD_DATA
	lds r16, SEND_BUFF
	out SPDR, r16 ; SEND DATA

	WAIT:
		sbis SPSR,SPIF
		rjmp WAIT
		rjmp MAIN





MEMORY_READ:
	lds r16, INDEX
	rol r16
	sts SEND_BYTE+3, r16
	
	ldi XH,high(ROWS)
	ldi XL,low(ROWS)

	lds r16, ROW_POS 
	clr r17

	NEXT_POS:
		inc r16
		inc r17
		cpi r17, 0x03
		brne NEXT_POS
	
	add XL, r16
	cpi r16, 24
	brne NOT_END
	clr r16
	sts ROW_POS, r16
		
	ld r16, X++
	sts SEND_BYTE, r16
	
	ld r16, X++
	sts SEND_BYTE +1, r16
	
	ld r16, X++
	sts SEND_BYTE +2, r16 	
	
	ret

LOAD_DATA:
	ld r16, Z++
	sts SEND_BUFF, r16

	lds r16, LOOP
	inc r16
	sts LOOP, r16

	ret

PULL_LATCH:
	sbi PORTB, 4 
	nop
	cbi PORTB, 4
	ret

INIT:
;//SPI initalization
	ldi r16, 0xB0
	out DDRB, r16

	ldi r16,(1<<SPE | 1<<MSTR | 0<<SPIE | 0<<SPR0)
	out SPCR, r16

	ret